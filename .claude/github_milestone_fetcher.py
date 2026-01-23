#!/usr/bin/env python3
"""
GitHubMilestoneFetcher - Fetches live milestone data from GitHub API.

Provides real-time milestone information from GitHub instead of relying
on stale local files, ensuring accurate task counts and progress tracking.

Author: FlowForge Team
Since: 2.1.0
"""

import json
import subprocess
import threading
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
from dataclasses import dataclass
import time


@dataclass
class GitHubMilestoneData:
    """Data structure for GitHub milestone information."""
    name: str
    state: str
    closed_issues: int
    open_issues: int
    total_issues: int
    description: str = ""
    due_date: Optional[str] = None
    progress_percentage: float = 0.0


class GitHubMilestoneFetcher:
    """
    Fetches live milestone data directly from GitHub API.

    Provides methods to get real-time milestone information including
    accurate task counts, avoiding stale local data issues.
    """

    # Cache TTL in seconds
    CACHE_TTL = 60  # 1 minute cache for API calls

    def __init__(self, base_path: Optional[Path] = None):
        """
        Initialize GitHub milestone fetcher.

        Args:
            base_path: Base directory path for the project
        """
        self.base_path = base_path or Path.cwd()
        self._cache: Dict[str, Tuple[float, Any]] = {}
        self._lock = threading.Lock()

    def fetch_milestone_for_issue(self, issue_num: str) -> Optional[GitHubMilestoneData]:
        """
        Fetch milestone data for a specific issue from GitHub API.

        Args:
            issue_num: GitHub issue number

        Returns:
            GitHubMilestoneData or None if not found
        """
        cache_key = f"issue_milestone_{issue_num}"

        # Check cache first
        cached_data = self._get_from_cache(cache_key)
        if cached_data:
            return cached_data

        try:
            # Get issue milestone information
            milestone_title = self._run_gh_command([
                'gh', 'issue', 'view', issue_num,
                '--json', 'milestone',
                '-q', '.milestone.title // ""'
            ])

            if not milestone_title:
                return None

            # Get detailed milestone data
            milestone_data = self._run_gh_command([
                'gh', 'api',
                f'repos/:owner/:repo/milestones',
                '--jq', f'.[] | select(.title == "{milestone_title}")'
            ])

            if milestone_data:
                parsed = json.loads(milestone_data)
                result = GitHubMilestoneData(
                    name=parsed.get('title', ''),
                    state=parsed.get('state', 'open'),
                    closed_issues=parsed.get('closed_issues', 0),
                    open_issues=parsed.get('open_issues', 0),
                    total_issues=parsed.get('closed_issues', 0) + parsed.get('open_issues', 0),
                    description=parsed.get('description', ''),
                    due_date=parsed.get('due_on'),
                    progress_percentage=self._calculate_progress_percentage(
                        parsed.get('closed_issues', 0),
                        parsed.get('open_issues', 0)
                    )
                )

                # Cache the result
                self._set_cache(cache_key, result)
                return result

        except (subprocess.SubprocessError, json.JSONDecodeError, KeyError):
            pass

        return None

    def fetch_milestone_by_name(self, milestone_name: str) -> Optional[GitHubMilestoneData]:
        """
        Fetch milestone data by milestone name from GitHub API.

        Args:
            milestone_name: Name of the milestone

        Returns:
            GitHubMilestoneData or None if not found
        """
        cache_key = f"milestone_{milestone_name}"

        # Check cache first
        cached_data = self._get_from_cache(cache_key)
        if cached_data:
            return cached_data

        try:
            # Get milestone data directly
            milestone_data = self._run_gh_command([
                'gh', 'api',
                'repos/:owner/:repo/milestones',
                '--jq', f'.[] | select(.title == "{milestone_name}")'
            ])

            if milestone_data:
                parsed = json.loads(milestone_data)
                result = GitHubMilestoneData(
                    name=parsed.get('title', ''),
                    state=parsed.get('state', 'open'),
                    closed_issues=parsed.get('closed_issues', 0),
                    open_issues=parsed.get('open_issues', 0),
                    total_issues=parsed.get('closed_issues', 0) + parsed.get('open_issues', 0),
                    description=parsed.get('description', ''),
                    due_date=parsed.get('due_on'),
                    progress_percentage=self._calculate_progress_percentage(
                        parsed.get('closed_issues', 0),
                        parsed.get('open_issues', 0)
                    )
                )

                # Cache the result
                self._set_cache(cache_key, result)
                return result

        except (subprocess.SubprocessError, json.JSONDecodeError, KeyError):
            pass

        return None

    def get_milestone_task_counts(self, issue_num: str) -> Tuple[int, int]:
        """
        Get task counts (completed, total) for issue's milestone.

        Args:
            issue_num: GitHub issue number

        Returns:
            Tuple of (completed_tasks, total_tasks)
        """
        milestone_data = self.fetch_milestone_for_issue(issue_num)
        if milestone_data:
            return (milestone_data.closed_issues, milestone_data.total_issues)
        return (0, 0)

    def get_milestone_progress_data(self, issue_num: str) -> Tuple[str, int, int, str]:
        """
        Get complete milestone progress data for statusline.

        Args:
            issue_num: GitHub issue number

        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining)
        """
        milestone_data = self.fetch_milestone_for_issue(issue_num)

        if milestone_data:
            # Calculate time remaining based on progress
            time_remaining = self._estimate_time_remaining(
                milestone_data.closed_issues,
                milestone_data.total_issues
            )

            return (
                milestone_data.name,
                milestone_data.closed_issues,
                milestone_data.total_issues,
                time_remaining
            )

        return ("", 0, 0, "0m")

    def _run_gh_command(self, cmd: list, timeout: int = 5) -> Optional[str]:
        """
        Run GitHub CLI command with timeout.

        Args:
            cmd: Command list to execute
            timeout: Timeout in seconds

        Returns:
            Command output or None if failed
        """
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=self.base_path
            )
            return result.stdout.strip() if result.returncode == 0 else None
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, FileNotFoundError):
            return None

    def _calculate_progress_percentage(self, closed: int, open: int) -> float:
        """
        Calculate progress percentage from issue counts.

        Args:
            closed: Number of closed issues
            open: Number of open issues

        Returns:
            Progress percentage (0-100)
        """
        total = closed + open
        if total == 0:
            return 0.0
        return (closed / total) * 100

    def _estimate_time_remaining(self, completed: int, total: int) -> str:
        """
        Estimate time remaining based on progress.

        Args:
            completed: Number of completed tasks
            total: Total number of tasks

        Returns:
            Time remaining string (e.g., "2h 15m")
        """
        if completed >= total:
            return "0m"

        if completed == 0:
            return "∞"

        # This is a simplified estimate
        # In production, would integrate with actual time tracking
        remaining = total - completed
        estimated_minutes = remaining * 30  # Assume 30 minutes per task average

        if estimated_minutes >= 60:
            hours = estimated_minutes // 60
            minutes = estimated_minutes % 60
            if minutes > 0:
                return f"{hours}h {minutes}m"
            return f"{hours}h"

        return f"{estimated_minutes}m"

    def _get_from_cache(self, key: str) -> Optional[GitHubMilestoneData]:
        """
        Get data from cache if not expired.

        Args:
            key: Cache key

        Returns:
            Cached data or None if expired/not found
        """
        with self._lock:
            if key in self._cache:
                timestamp, data = self._cache[key]
                if time.time() - timestamp < self.CACHE_TTL:
                    return data
                # Remove expired entry
                del self._cache[key]
        return None

    def _set_cache(self, key: str, data: GitHubMilestoneData):
        """
        Set data in cache with timestamp.

        Args:
            key: Cache key
            data: Data to cache
        """
        with self._lock:
            self._cache[key] = (time.time(), data)

    def clear_cache(self):
        """Clear all cached data."""
        with self._lock:
            self._cache.clear()


# Convenience functions
def get_live_milestone_data(issue_num: str) -> Tuple[str, int, int, str]:
    """
    Get live milestone data for an issue.

    Args:
        issue_num: GitHub issue number

    Returns:
        Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining)
    """
    fetcher = GitHubMilestoneFetcher()
    return fetcher.get_milestone_progress_data(issue_num)


def get_milestone_task_counts(issue_num: str) -> Tuple[int, int]:
    """
    Get task counts for issue's milestone.

    Args:
        issue_num: GitHub issue number

    Returns:
        Tuple of (completed_tasks, total_tasks)
    """
    fetcher = GitHubMilestoneFetcher()
    return fetcher.get_milestone_task_counts(issue_num)


__all__ = [
    'GitHubMilestoneFetcher',
    'GitHubMilestoneData',
    'get_live_milestone_data',
    'get_milestone_task_counts'
]