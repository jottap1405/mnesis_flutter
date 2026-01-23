#!/usr/bin/env python3
"""
GitHub Cache Module - ACID Compliant Cache Operations (Rule #19).

Implements atomic, consistent, isolated, and durable cache operations
for GitHub API data with proper fallback chain.
"""

import json
import tempfile
import shutil
import threading
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
import time


class GitHubCache:
    """
    ACID-compliant cache for GitHub API data.

    Implements:
    - Atomicity: Operations complete fully or not at all
    - Consistency: Data structures remain valid
    - Isolation: Concurrent operations don't interfere
    - Durability: Data persists after operation
    """

    def __init__(self, base_path: Path):
        """
        Initialize GitHub cache with ACID properties.

        Args:
            base_path: Base directory for cache files
        """
        self.base_path = base_path
        self._flowforge_dir = self.base_path / '.flowforge'
        self._cache_file = self._flowforge_dir / '.github-cache.json'
        self._lock = threading.RLock()  # Reentrant lock for isolation

        # Ensure directory exists
        self._flowforge_dir.mkdir(exist_ok=True)

    def _atomic_write(self, data: Dict[str, Any]) -> bool:
        """
        Atomically write data to cache file.

        Args:
            data: Data to write

        Returns:
            True if write successful, False otherwise
        """
        try:
            # Create temporary file in same directory for atomic rename
            with tempfile.NamedTemporaryFile(
                mode='w',
                dir=self._flowforge_dir,
                suffix='.tmp',
                delete=False
            ) as tmp_file:
                json.dump(data, tmp_file, indent=2)
                tmp_path = Path(tmp_file.name)

            # Atomic rename (POSIX guarantee)
            shutil.move(str(tmp_path), str(self._cache_file))
            return True

        except Exception:
            # Cleanup temp file if it exists
            if 'tmp_path' in locals() and tmp_path.exists():
                try:
                    tmp_path.unlink()
                except Exception:
                    pass
            return False

    def _consistent_read(self) -> Dict[str, Any]:
        """
        Consistently read cache data with validation.

        Returns:
            Cache data dictionary or empty dict if invalid
        """
        if not self._cache_file.exists():
            return {}

        try:
            with open(self._cache_file, 'r') as f:
                data = json.load(f)

            # Validate data structure consistency
            if not isinstance(data, dict):
                return {}

            # Validate each entry has required fields (create list to avoid iteration issues)
            keys_to_remove = []
            for key, value in data.items():
                if not isinstance(value, dict):
                    keys_to_remove.append(key)
                    continue
                if 'data' not in value or 'timestamp' not in value:
                    keys_to_remove.append(key)

            # Remove invalid entries
            for key in keys_to_remove:
                del data[key]

            return data

        except (json.JSONDecodeError, IOError):
            return {}

    def set_issue_data(
        self,
        issue_num: str,
        milestone_name: str,
        tasks_completed: int,
        tasks_total: int,
        time_remaining: str,
        ttl_minutes: int = 5
    ) -> bool:
        """
        Set GitHub issue data with ACID properties.

        Args:
            issue_num: GitHub issue number
            milestone_name: Milestone name
            tasks_completed: Number of completed tasks
            tasks_total: Total number of tasks
            time_remaining: Remaining time string
            ttl_minutes: Cache TTL in minutes

        Returns:
            True if successful, False otherwise
        """
        with self._lock:  # Isolation
            try:
                # Read current state
                data = self._consistent_read()

                # Update data (store as list for JSON serialization)
                cache_entry = {
                    'data': [milestone_name, tasks_completed, tasks_total, time_remaining],
                    'timestamp': time.time(),
                    'ttl_minutes': ttl_minutes
                }

                data[f'github_issue_{issue_num}'] = cache_entry

                # Atomic write
                return self._atomic_write(data)

            except Exception:
                return False

    def get_issue_data(
        self,
        issue_num: str,
        ttl_minutes: int = 5
    ) -> Optional[Tuple[str, int, int, str]]:
        """
        Get GitHub issue data with TTL checking.

        Args:
            issue_num: GitHub issue number
            ttl_minutes: TTL in minutes

        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining)
            or None if not found or expired
        """
        with self._lock:  # Isolation
            try:
                data = self._consistent_read()
                cache_key = f'github_issue_{issue_num}'

                if cache_key not in data:
                    return None

                entry = data[cache_key]
                if not isinstance(entry, dict):
                    return None

                # Check TTL
                current_time = time.time()
                entry_time = entry.get('timestamp', 0)
                entry_ttl = entry.get('ttl_minutes', ttl_minutes)

                if current_time - entry_time > entry_ttl * 60:
                    # Expired - remove from cache
                    del data[cache_key]
                    self._atomic_write(data)
                    return None

                # Return cached data (convert list back to tuple)
                cached_data = entry.get('data')
                if isinstance(cached_data, (list, tuple)) and len(cached_data) == 4:
                    return tuple(cached_data)

                return None

            except Exception:
                return None

    def get_fallback_chain_data(self, issue_num: str) -> Tuple[str, int, int, str]:
        """
        Get data from complete fallback chain.

        Fallback order:
        1. GitHub API cache (if not expired)
        2. Local .flowforge files
        3. Default values

        Args:
            issue_num: GitHub issue number

        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining)
        """
        # Try cached GitHub data first
        cached_data = self.get_issue_data(issue_num)
        if cached_data:
            return cached_data

        # Try local files fallback
        local_data = self._get_local_files_data()
        if local_data[0]:  # If milestone name found
            return local_data

        # Default fallback
        return ('', 0, 0, '0m')

    def _get_local_files_data(self) -> Tuple[str, int, int, str]:
        """
        Get milestone data from local FlowForge files.

        Returns:
            Tuple of (milestone_name, tasks_completed, tasks_total, time_remaining)
        """
        # Try .flowforge/tasks.json first
        tasks_json = self._flowforge_dir / 'tasks.json'
        if tasks_json.exists():
            try:
                with open(tasks_json, 'r') as f:
                    tasks_data = json.load(f)

                if isinstance(tasks_data, dict):
                    milestone = tasks_data.get('current_milestone', {})
                    if isinstance(milestone, dict) and milestone.get('name'):
                        return (
                            milestone.get('name', ''),
                            milestone.get('completed', 0),
                            milestone.get('total', 0),
                            milestone.get('timeRemaining', '0m')
                        )
            except (json.JSONDecodeError, IOError):
                pass

        # Try .flowforge/local/session.json
        session_json = self._flowforge_dir / 'local' / 'session.json'
        if session_json.exists():
            try:
                with open(session_json, 'r') as f:
                    session_data = json.load(f)

                if isinstance(session_data, dict):
                    milestone = session_data.get('milestone', {})
                    if isinstance(milestone, dict) and milestone.get('name'):
                        return (
                            milestone.get('name', ''),
                            milestone.get('completed', 0),
                            milestone.get('total', 0),
                            milestone.get('timeRemaining', '0m')
                        )
            except (json.JSONDecodeError, IOError):
                pass

        # Try .flowforge/milestones.json
        milestones_json = self._flowforge_dir / 'milestones.json'
        if milestones_json.exists():
            try:
                with open(milestones_json, 'r') as f:
                    milestones_data = json.load(f)

                if isinstance(milestones_data, dict):
                    current = milestones_data.get('current', {})
                    if isinstance(current, dict) and current.get('name'):
                        return (
                            current.get('name', ''),
                            current.get('completed', 0),
                            current.get('total', 0),
                            current.get('timeRemaining', '0m')
                        )
            except (json.JSONDecodeError, IOError):
                pass

        return ('', 0, 0, '0m')

    def cleanup_expired(self) -> int:
        """
        Cleanup expired cache entries.

        Returns:
            Number of entries removed
        """
        with self._lock:  # Isolation
            try:
                data = self._consistent_read()
                current_time = time.time()
                removed_count = 0

                # Check each entry for expiration
                keys_to_remove = []
                for key, entry in data.items():
                    if not isinstance(entry, dict):
                        keys_to_remove.append(key)
                        continue

                    entry_time = entry.get('timestamp', 0)
                    entry_ttl = entry.get('ttl_minutes', 5)

                    if current_time - entry_time > entry_ttl * 60:
                        keys_to_remove.append(key)

                # Remove expired entries
                for key in keys_to_remove:
                    del data[key]
                    removed_count += 1

                # Write back if changes made
                if removed_count > 0:
                    self._atomic_write(data)

                return removed_count

            except Exception:
                return 0

    def get_cache_stats(self) -> Dict[str, Any]:
        """
        Get cache statistics for monitoring.

        Returns:
            Dictionary with cache statistics
        """
        with self._lock:
            try:
                data = self._consistent_read()
                current_time = time.time()

                stats = {
                    'total_entries': len(data),
                    'expired_entries': 0,
                    'valid_entries': 0,
                    'cache_size_bytes': 0
                }

                # Analyze entries
                for entry in data.values():
                    if not isinstance(entry, dict):
                        continue

                    entry_time = entry.get('timestamp', 0)
                    entry_ttl = entry.get('ttl_minutes', 5)

                    if current_time - entry_time > entry_ttl * 60:
                        stats['expired_entries'] += 1
                    else:
                        stats['valid_entries'] += 1

                # Calculate cache file size
                if self._cache_file.exists():
                    stats['cache_size_bytes'] = self._cache_file.stat().st_size

                return stats

            except Exception:
                return {'error': 'Unable to calculate stats'}