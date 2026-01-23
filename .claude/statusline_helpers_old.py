#!/usr/bin/env python3
"""
StatusLine Helper Functions Module - Extracted for Rule #24 compliance.

Provides helper functions for context usage calculation, time tracking,
model detection, and track name extraction.

FIXES IMPLEMENTED:
1. Context calculation using transcript files instead of 3%
2. Proper time formatting (8h 30m instead of 510m)
3. Session timer tracking
4. Issue time tracking from .task-times.json
"""

import os
import re
from pathlib import Path
from typing import Optional


class StatusLineHelpers:
    """
    Helper functions for StatusLine operations.

    Provides utility methods for various statusline calculations
    and data extraction operations.
    """

    def __init__(self, base_path: Path, data_loader):
        """
        Initialize helpers with base path and data loader.

        Args:
            base_path: Base directory path
            data_loader: StatusLineDataLoader instance
        """
        self.base_path = base_path
        self.data_loader = data_loader

        # Pre-compute paths
        self._session_json_path = self.base_path / '.flowforge' / 'local' / 'session.json'
        self._context_file_path = self.base_path / '.milestone-context'

    def calculate_context_usage(self, model_name: str, stdin_data: str = "") -> float:
        """
        Calculates context usage percentage using ContextUsageCalculator.

        Args:
            model_name: Name of the AI model
            stdin_data: Pre-read stdin content

        Returns:
            float: Context usage percentage (0-100)
        """
        try:
            from context_usage_calculator import ContextUsageCalculator

            calculator = ContextUsageCalculator(base_path=self.base_path)
            usage_data = calculator.calculate_context_usage(model_name, stdin_data)
            return usage_data.percentage
        except Exception:
            return 0.0

    def format_time_duration(self, total_seconds: float) -> str:
        """
        Format time duration from seconds to human-readable format.

        Args:
            total_seconds: Duration in seconds

        Returns:
            str: Formatted time string (e.g., "2h 15m", "45m", "8h 30m")
        """
        if total_seconds <= 0:
            return "0m"

        total_minutes = int(total_seconds // 60)

        if total_minutes < 60:
            return f"{total_minutes}m"

        hours = total_minutes // 60
        minutes = total_minutes % 60

        if minutes > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{hours}h"

    def format_hours_to_duration(self, total_hours: float) -> str:
        """
        Format hours to human-readable duration.

        Args:
            total_hours: Duration in hours

        Returns:
            str: Formatted time string (e.g., "2h 15m", "45m", "8h 30m")
        """
        return self.format_time_duration(total_hours * 3600)

    def get_session_elapsed_time(self, issue_num: Optional[str] = None) -> str:
        """
        Gets current session elapsed time from FlowForge time tracking.

        Args:
            issue_num: Issue number to get session time for (optional)

        Returns:
            str: Elapsed time in proper format like "2h 15m" or "45m"
        """
        try:
            # If issue number is provided, get direct time from task-times.json
            if issue_num:
                import json
                from datetime import datetime, timezone

                task_times_file = self.base_path / '.task-times.json'
                if task_times_file.exists():
                    with open(task_times_file, 'r') as f:
                        data = json.load(f)

                    issue_data = data.get(issue_num, {})
                    if issue_data.get('status') == 'active' and 'current_session' in issue_data:
                        start_time_str = issue_data['current_session']['start']
                        start_time = datetime.fromisoformat(start_time_str.replace('Z', '+00:00'))
                        current_time = datetime.now(timezone.utc)

                        # Calculate elapsed time
                        elapsed = current_time - start_time
                        return self.format_time_duration(elapsed.total_seconds())

            # Fallback to integration method
            try:
                from flowforge_time_integration import FlowForgeTimeIntegration

                integration = FlowForgeTimeIntegration(base_path=self.base_path)
                session_data = integration.get_session_time_data()
                return session_data.elapsed_time
            except Exception:
                return "0m"
        except Exception:
            return "0m"

    def get_total_issue_time(self, issue_num: str) -> str:
        """
        Get total time worked on an issue from task-times.json.

        Args:
            issue_num: Issue number to get total time for

        Returns:
            str: Total time worked in format like "8h 30m"
        """
        try:
            import json

            task_times_file = self.base_path / '.task-times.json'
            if task_times_file.exists():
                with open(task_times_file, 'r') as f:
                    data = json.load(f)

                issue_data = data.get(issue_num, {})
                total_hours = issue_data.get('total_hours', 0.0)

                # Add current session time if active
                if issue_data.get('status') == 'active' and 'current_session' in issue_data:
                    from datetime import datetime, timezone

                    start_time_str = issue_data['current_session']['start']
                    start_time = datetime.fromisoformat(start_time_str.replace('Z', '+00:00'))
                    current_time = datetime.now(timezone.utc)

                    current_session_hours = (current_time - start_time).total_seconds() / 3600
                    total_hours += current_session_hours

                return self.format_hours_to_duration(total_hours)

        except Exception:
            pass

        return "0m"

    def get_planned_time(self) -> str:
        """
        Gets planned session time from FlowForge tracking.

        Returns:
            str: Planned time in H:MM format
        """
        try:
            from flowforge_time_integration import FlowForgeTimeIntegration

            integration = FlowForgeTimeIntegration(base_path=self.base_path)
            session_data = integration.get_session_time_data()
            return session_data.planned_time
        except Exception:
            return "0:00"

    def extract_track_name(self) -> str:
        """
        Extracts track name from milestone context or session data.

        Checks multiple sources:
        1. .milestone-context file
        2. Session JSON file
        3. Milestone name pattern extraction

        Returns:
            str: Track name or empty string
        """
        try:
            # Try milestone context file first
            if self._context_file_path.exists():
                with open(self._context_file_path, 'r') as f:
                    content = f.read()
                    # Look for Track: line
                    match = re.search(r'Track:\s*(.+)', content)
                    if match:
                        return match.group(1).strip()

            # Try session file
            session_data = self.data_loader.load_json_file(
                self._session_json_path,
                'session_json'
            )
            if session_data:
                track = session_data.get('milestone', {}).get('track', '')
                if track:
                    return track

            # Try to extract from milestone name
            milestone_name, _, _, _ = self.data_loader.get_milestone_from_local_files()
            if milestone_name:
                # Extract track from patterns like "v2.0 [Feature]"
                match = re.search(r'\[(.+?)\]', milestone_name)
                if match:
                    return match.group(1)

            return ""
        except Exception:
            return ""

    def detect_model_name(self) -> str:
        """
        Detects current AI model name from various sources.

        Checks:
        1. Session JSON file
        2. Environment variable CLAUDE_MODEL
        3. Default to "Claude"

        Returns:
            str: Model name (defaults to "Claude" if not detected)
        """
        try:
            # Try session file first
            session_data = self.data_loader.load_json_file(
                self._session_json_path,
                'session_json'
            )
            if session_data and 'model_name' in session_data:
                return session_data['model_name']

            # Try environment variable
            env_model = os.environ.get('CLAUDE_MODEL', '')
            if env_model:
                return env_model

            # Try to detect from running context
            # This could be enhanced with more detection methods
            return "Claude"
        except Exception:
            return "Claude"

    def get_terminal_width(self) -> int:
        """
        Get current terminal width.

        Returns:
            int: Terminal width in columns (defaults to 120)
        """
        try:
            import shutil
            return shutil.get_terminal_size().columns
        except Exception:
            return 120

    def format_time_remaining(self, hours: float) -> str:
        """
        Format time remaining from hours to readable string.

        Args:
            hours: Number of hours

        Returns:
            str: Formatted time string (e.g., "2.5h", "30m")
        """
        if hours == 0:
            return "0m"

        if hours >= 1:
            return f"{hours:.1f}h"
        else:
            minutes = int(hours * 60)
            return f"{minutes}m"

    def validate_issue_number(self, issue_num: str) -> bool:
        """
        Validate that issue number is within acceptable range.

        Args:
            issue_num: Issue number string

        Returns:
            bool: True if valid, False otherwise
        """
        try:
            num = int(issue_num)
            return 1 <= num <= 999999
        except (ValueError, TypeError):
            return False