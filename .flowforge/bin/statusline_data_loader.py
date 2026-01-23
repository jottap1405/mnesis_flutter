#!/usr/bin/env python3
"""
StatusLine Data Loader Module - Extracted for Rule #24 compliance.

Handles all data loading operations including JSON files, Git operations,
and GitHub API interactions with background fetching support.
"""

import json
import subprocess
import threading
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import Dict, Any, Optional, Tuple


class StatusLineDataLoader:
    """
    Handles all data loading operations for StatusLine.
    
    Provides methods for loading JSON files, fetching Git information,
    and interacting with GitHub API using background threads.
    """
    
    # Pre-compiled regex patterns for performance
    ISSUE_PATTERNS = [
        re.compile(r'\b(?:feature|issue|hotfix|bugfix)[/-](\d{1,6})\b'),
        re.compile(r'^(\d{1,6})(?:-[^\s]+)?$'),
        re.compile(r'v\d{1,3}\.\d{1,3}-[^-]{1,50}-(\d{1,6})$'),
    ]
    TASK_PATTERN = re.compile(r'^-\s{0,5}\[[ x]\]', re.MULTILINE)
    COMPLETED_TASK_PATTERN = re.compile(r'^-\s{0,5}\[x\]', re.MULTILINE)
    TIME_PATTERN = re.compile(r'^-\s{0,5}\[ \].{0,100}?\[(\d{1,4}(?:\.\d{1,2})?)[hH]\]', re.MULTILINE)
    
    # Constants
    MAX_BRANCH_LENGTH = 200
    MAX_BODY_LENGTH = 50000
    MAX_ISSUE_NUMBER = 999999
    
    def __init__(self, base_path: Path, cache):
        """
        Initialize data loader with base path and cache.
        
        Args:
            base_path: Base directory path
            cache: StatusLineCache instance for caching
        """
        self.base_path = base_path
        self.cache = cache
        
        # Pre-compute frequently used paths
        self._flowforge_dir = self.base_path / '.flowforge'
        self._local_dir = self._flowforge_dir / 'local'
        self._tasks_json_path = self._flowforge_dir / 'tasks.json'
        self._session_json_path = self._local_dir / 'session.json'
        self._milestones_json_path = self._flowforge_dir / 'milestones.json'
        # FIXED: Use correct timer file path
        self._time_tracking_json_path = self._flowforge_dir / 'billing' / 'time-tracking.json'
        self._task_times_json_path = self.base_path / '.task-times.json'  # Legacy fallback
        self._package_json_path = self.base_path / 'package.json'
        
        # Background GitHub data fetching
        self._github_data_lock = threading.Lock()
        self._github_data = {}
        self._github_fetch_thread = None
    
    def run_command(self, cmd: list, timeout: int = 2) -> Optional[str]:
        """
        Run command with timeout and error handling.
        
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
    
    def load_json_file(self, file_path: Path, cache_key: str) -> Optional[Dict[str, Any]]:
        """
        Load JSON file with caching and error handling.
        
        Args:
            file_path: Path to JSON file
            cache_key: Key for caching the data
            
        Returns:
            Parsed JSON data or None if failed
        """
        cached_data = self.cache.get(cache_key)
        if cached_data is not None:
            return cached_data
        
        if not file_path.exists():
            self.cache.set(cache_key, None, save_immediately=False)
            return None
            
        try:
            with open(file_path, 'r') as f:
                data = json.load(f)
                self.cache.set(cache_key, data, save_immediately=False)
                return data
        except (json.JSONDecodeError, IOError):
            self.cache.set(cache_key, None, save_immediately=False)
            return None
    
    def get_git_branch(self) -> str:
        """
        Get current git branch.
        
        Returns:
            Branch name or 'no-branch' if not in git repo
        """
        cached_branch = self.cache.get('git_branch')
        if cached_branch is not None:
            return cached_branch
            
        branch = self.run_command(['git', 'branch', '--show-current'])
        if branch is None:
            branch = 'no-branch'
        
        self.cache.set('git_branch', branch)
        return branch
    
    def extract_issue_number(self, branch: str) -> Optional[str]:
        """
        Extract issue number from branch name using pre-compiled patterns.
        
        Args:
            branch: Git branch name
            
        Returns:
            Issue number or None if not found
        """
        if len(branch) > self.MAX_BRANCH_LENGTH:
            branch = branch[:self.MAX_BRANCH_LENGTH]
        
        for pattern in self.ISSUE_PATTERNS:
            try:
                match = pattern.search(branch)
                if match:
                    issue_num = match.group(1)
                    if issue_num.isdigit() and 1 <= int(issue_num) <= self.MAX_ISSUE_NUMBER:
                        return issue_num
            except re.error:
                continue
        
        return None
    
    def format_eta_duration(self, delta):
        """
        Format time delta into human-readable ETA string.

        Args:
            delta: timedelta object

        Returns:
            str: Formatted duration (e.g., "5h 30m", "3d 12h", "Overdue")
        """
        if not delta or delta.total_seconds() <= 0:
            return "0m"

        total_seconds = delta.total_seconds()
        days = int(total_seconds // 86400)
        hours = int((total_seconds % 86400) // 3600)
        minutes = int((total_seconds % 3600) // 60)

        if days > 0:
            if hours > 0:
                return f"{days}d {hours}h"
            else:
                return f"{days}d"
        elif hours > 0:
            if minutes > 0:
                return f"{hours}h {minutes}m"
            else:
                return f"{hours}h"
        else:
            return f"{max(1, minutes)}m"  # Show at least 1m

    def get_milestone_eta_from_github(self, issue_num: str):
        """
        Get milestone data with ETA calculated from due date.

        Args:
            issue_num: GitHub issue number

        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, eta_string)
        """
        try:
            milestone_name = ""
            tasks_completed = 0
            tasks_total = 0
            eta_string = "0m"

            # Get milestone name first
            milestone_result = self.run_command([
                'gh', 'issue', 'view', issue_num,
                '--json', 'milestone', '-q', '.milestone.title // ""'
            ], timeout=3)

            if milestone_result:
                milestone_name = milestone_result

                # Get milestone details including due date
                milestone_details = self.run_command([
                    'gh', 'api', f'repos/JustCode-CruzAlex/FlowForge/milestones',
                    '--jq', f'[.[] | select(.title == "{milestone_name}")] | .[0]'
                ], timeout=3)

                if milestone_details:
                    try:
                        milestone_data = json.loads(milestone_details)

                        # Extract due date and calculate ETA
                        due_on = milestone_data.get('due_on')
                        if due_on:
                            due_date = datetime.fromisoformat(due_on.replace('Z', '+00:00'))
                            current_time = datetime.now(timezone.utc)
                            time_delta = due_date - current_time

                            if time_delta.total_seconds() < 0:
                                eta_string = "Overdue"
                            else:
                                eta_string = self.format_eta_duration(time_delta)

                        # Get task counts from milestone data
                        tasks_total = milestone_data.get('open_issues', 0) + milestone_data.get('closed_issues', 0)
                        tasks_completed = milestone_data.get('closed_issues', 0)

                    except (json.JSONDecodeError, ValueError, KeyError):
                        pass

                # If we didn't get counts from milestone API, try issue counts
                if tasks_total == 0:
                    total_result = self.run_command([
                        'gh', 'issue', 'list', '--milestone', milestone_name,
                        '--state', 'all', '--json', 'number', '--limit', '100', '-q', '. | length'
                    ], timeout=3)

                    completed_result = self.run_command([
                        'gh', 'issue', 'list', '--milestone', milestone_name,
                        '--state', 'closed', '--json', 'number', '--limit', '100', '-q', '. | length'
                    ], timeout=3)

                    if total_result and total_result.isdigit():
                        tasks_total = int(total_result)
                    if completed_result and completed_result.isdigit():
                        tasks_completed = int(completed_result)

            # If no ETA from due date, try to calculate from task estimates
            if eta_string == "0m":
                body_result = self.run_command([
                    'gh', 'issue', 'view', issue_num,
                    '--json', 'body', '-q', '.body // ""'
                ], timeout=3)

                if body_result:
                    body = body_result[:self.MAX_BODY_LENGTH] if len(body_result) > self.MAX_BODY_LENGTH else body_result

                    # Extract time from uncompleted tasks
                    time_hours = 0.0
                    uncompleted_lines = self.TIME_PATTERN.findall(body)
                    for time_match in uncompleted_lines:
                        try:
                            hours = float(time_match)
                            if 0 <= hours <= 9999:
                                time_hours += hours
                        except ValueError:
                            continue

                    if time_hours > 0:
                        time_minutes = int(time_hours * 60)
                        if time_minutes > 0:
                            eta_string = f"{time_minutes}m"

            return (milestone_name, tasks_completed, tasks_total, eta_string)

        except Exception:
            return ("", 0, 0, "0m")

    def fetch_github_data_background(self, issue_num: str):
        """
        Fetch GitHub data in background thread (non-blocking).

        Args:
            issue_num: GitHub issue number
        """
        def fetch():
            try:
                # Only try if gh is available
                if not self.cache.is_gh_available():
                    return

                # Check if already cached
                cache_key = f'github_issue_{issue_num}'
                if self.cache.get(cache_key) is not None:
                    return

                # Get milestone data with ETA
                result = self.get_milestone_eta_from_github(issue_num)

                with self._github_data_lock:
                    self._github_data[issue_num] = result

                self.cache.set(cache_key, result)

            except Exception:
                pass

        # Start background thread
        if self._github_fetch_thread is None or not self._github_fetch_thread.is_alive():
            self._github_fetch_thread = threading.Thread(target=fetch, daemon=True)
            self._github_fetch_thread.start()
    
    def get_milestone_from_github(self, issue_num: str, wait_for_fetch: bool = True) -> Tuple[str, int, int, str]:
        """
        Get milestone data from GitHub.

        Args:
            issue_num: GitHub issue number
            wait_for_fetch: If True, wait for GitHub data; if False, return immediately

        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining_or_eta)
        """
        # Check if data is already available
        with self._github_data_lock:
            if issue_num in self._github_data:
                return self._github_data[issue_num]

        # Check cache
        cache_key = f'github_issue_{issue_num}'
        cached_data = self.cache.get(cache_key)
        if cached_data is not None:
            return cached_data

        # If wait_for_fetch is True, do synchronous fetch with ETA
        if wait_for_fetch and self.cache.is_gh_available():
            return self.get_milestone_eta_from_github(issue_num)

        # Otherwise start background fetch for next time
        self.fetch_github_data_background(issue_num)

        # Return empty data (will use local files as fallback)
        return ("", 0, 0, "0m")

    def _fetch_github_data_sync(self, issue_num: str) -> Tuple[str, int, int, str]:
        """
        Synchronously fetch GitHub data.

        Deprecated: Use get_milestone_eta_from_github instead.

        Args:
            issue_num: GitHub issue number

        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining)
        """
        # Delegate to the new method with ETA calculation
        return self.get_milestone_eta_from_github(issue_num)
    
    def get_milestone_from_local_files(self) -> Tuple[str, int, int, str]:
        """
        Get milestone data from local FlowForge files.
        
        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining)
        """
        # Try .flowforge/tasks.json first
        tasks_data = self.load_json_file(self._tasks_json_path, 'tasks_json')
        if tasks_data and isinstance(tasks_data, dict):
            milestone_name = tasks_data.get('current_milestone', {}).get('name', '')
            if milestone_name:
                return (
                    milestone_name,
                    tasks_data.get('current_milestone', {}).get('completed', 0),
                    tasks_data.get('current_milestone', {}).get('total', 0),
                    tasks_data.get('current_milestone', {}).get('timeRemaining', '0m')
                )
        
        # Try .flowforge/local/session.json
        session_data = self.load_json_file(self._session_json_path, 'session_json')
        if session_data and isinstance(session_data, dict):
            milestone_name = session_data.get('milestone', {}).get('name', '')
            if milestone_name:
                return (
                    milestone_name,
                    session_data.get('milestone', {}).get('completed', 0),
                    session_data.get('milestone', {}).get('total', 0),
                    session_data.get('milestone', {}).get('timeRemaining', '0m')
                )
        
        # Try .flowforge/milestones.json
        milestones_data = self.load_json_file(self._milestones_json_path, 'milestones_json')
        if milestones_data and isinstance(milestones_data, dict):
            current = milestones_data.get('current', {})
            if current and isinstance(current, dict):
                return (
                    current.get('name', ''),
                    current.get('completed', 0),
                    current.get('total', 0),
                    current.get('timeRemaining', '0m')
                )
        
        return ('', 0, 0, '0m')
    
    def get_timer_status(self, issue_num: str) -> str:
        """
        Check if timer is active for the current issue.

        Args:
            issue_num: Issue number to check

        Returns:
            Timer status string (' | ● Active' or empty)
        """
        # FIXED: Check new time-tracking.json format FIRST
        if self._time_tracking_json_path.exists():
            try:
                import json
                with open(self._time_tracking_json_path, 'r') as f:
                    time_tracking_data = json.load(f)

                if time_tracking_data and isinstance(time_tracking_data, dict):
                    issue_data = time_tracking_data.get(issue_num, {})
                    if issue_data.get('status') == 'active':
                        return ' | ● Active'
            except (json.JSONDecodeError, IOError):
                pass

        # Fallback to legacy .task-times.json
        possible_paths = [
            self._task_times_json_path,
            self.base_path.parent / '.task-times.json',
            self.base_path.parent.parent / '.task-times.json',
            self.base_path.parent.parent.parent / '.task-times.json',
        ]

        for task_times_path in possible_paths:
            if task_times_path.exists():
                try:
                    import json
                    with open(task_times_path, 'r') as f:
                        task_times_data = json.load(f)

                    if task_times_data and isinstance(task_times_data, dict):
                        issue_data = task_times_data.get(issue_num, {})
                        if issue_data.get('status') == 'active':
                            return ' | ● Active'
                except (json.JSONDecodeError, IOError):
                    continue

        return ''
    
    def get_project_name_fallback(self) -> str:
        """
        Get project name as fallback for milestone name.
        
        Returns:
            Project name from package.json or directory name
        """
        package_data = self.load_json_file(self._package_json_path, 'package_json')
        if package_data and isinstance(package_data, dict):
            name = package_data.get('name', '')
            if name:
                return name
        
        return self.base_path.name