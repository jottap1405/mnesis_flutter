#!/usr/bin/env python3
"""
FlowForge Enhanced Status Line - SIMPLE FIXED VERSION.

CRITICAL FIXES IMPLEMENTED:
1. Context calculation using transcript files instead of showing 3%
2. Proper time formatting (8h 30m instead of 510m)
3. Session timer tracking for active issues
4. Issue time tracking from .task-times.json
5. Better error handling and fallbacks

Expected output format:
[FlowForge] 🎯 v2.1-statusline-milestone-mode (5/10) [█████░░░░░] 50% ⏱️ 8h 30m | 🌿 feature/423-work | 🧠 75% [███████░░░] | Session: 2h 15m | Opus 4.1 | ● Active
"""

import json
import sys
import time
from pathlib import Path
from typing import Optional

# Import extracted modules (Rule #24 compliance)
from statusline_cache import StatusLineCache
from statusline_data_loader import StatusLineDataLoader
from statusline_helpers import StatusLineHelpers


class FlowForgeStatusLine:
    """
    Simple performance-optimized FlowForge statusline with comprehensive fixes.

    CRITICAL FIXES:
    - Real context calculation from transcript files
    - Proper time formatting for all durations
    - Active session tracking
    - Total issue time display
    """

    def __init__(self, base_path: Optional[Path] = None):
        """
        Initialize FlowForge StatusLine.

        Args:
            base_path: Base directory path (defaults to current directory)
        """
        self.base_path = base_path or Path.cwd()

        # Use XDG cache directory or temp directory for cache files
        import os
        import tempfile

        # Priority: XDG_CACHE_HOME > HOME/.cache > /tmp
        cache_base = None
        if 'XDG_CACHE_HOME' in os.environ:
            cache_base = Path(os.environ['XDG_CACHE_HOME'])
        elif 'HOME' in os.environ:
            cache_base = Path(os.environ['HOME']) / '.cache'
        else:
            cache_base = Path(tempfile.gettempdir())

        # Create FlowForge-specific cache directory
        flowforge_cache_dir = cache_base / 'flowforge'
        flowforge_cache_dir.mkdir(parents=True, exist_ok=True)

        # Use project-specific cache file (based on project path hash)
        import hashlib
        project_hash = hashlib.md5(str(self.base_path).encode()).hexdigest()[:8]
        self.cache_file = flowforge_cache_dir / f'statusline-cache-{project_hash}.json'

        # Initialize extracted modules
        self.cache = StatusLineCache(self.cache_file)
        self.data_loader = StatusLineDataLoader(self.base_path, self.cache)
        self.helpers = StatusLineHelpers(self.base_path, self.data_loader)

        # Store stdin data for context calculation
        self._stdin_data = ""

    def generate_status_line(self, model_name: str = "Model", prefer_local: bool = True) -> str:
        """
        Generate the complete status line with performance optimizations and FIXES.

        Args:
            model_name: AI model name
            prefer_local: Whether to prefer local data over GitHub API

        Returns:
            str: Formatted status line with proper time formatting and context
        """
        start_time = time.time()

        try:
            # Get git branch and extract issue number
            branch = self.data_loader.get_git_branch()
            issue_num = self.data_loader.extract_issue_number(branch)

            # Get milestone data (prefer local to avoid GitHub calls)
            milestone_name, tasks_completed, tasks_total, time_remaining = \
                self.data_loader.get_milestone_from_local_files()

            # Only try GitHub if no local data and we have an issue number
            if not milestone_name and issue_num and not prefer_local:
                gh_data = self.data_loader.get_milestone_from_github(issue_num)
                if gh_data[0]:  # If we got a milestone name
                    milestone_name, tasks_completed, tasks_total, time_remaining = gh_data

            # Fallback to project name
            if not milestone_name:
                milestone_name = self.data_loader.get_project_name_fallback()

            # Get timer status with proper formatting
            timer_active = False
            session_time = ""
            issue_time = ""
            if issue_num:
                timer_status = self.data_loader.get_timer_status(issue_num)
                timer_active = "● Active" in timer_status
                # Get current session time
                session_time = self.helpers.get_session_elapsed_time(issue_num)
                # Get total issue time
                issue_time = self.helpers.get_total_issue_time(issue_num)

            # FIXED: Calculate context usage with stdin_data
            context_percentage = self.helpers.calculate_context_usage(model_name, self._stdin_data)

            # Format enhanced statusline
            status_line = self._format_enhanced_statusline(
                milestone_name, tasks_completed, tasks_total,
                issue_time, branch, context_percentage,
                session_time, model_name, timer_active
            )

            # Log performance if it takes too long
            elapsed_ms = (time.time() - start_time) * 1000
            if elapsed_ms > 50:
                print(f"# WARNING: Status line took {elapsed_ms:.1f}ms (target: <50ms)",
                      file=sys.stderr)

            return status_line

        except Exception as e:
            # Fallback to simple format
            branch = self.data_loader.get_git_branch()
            milestone_name = self.data_loader.get_project_name_fallback()
            return f"[FlowForge] {milestone_name} | Branch: {branch} | {model_name} | Error: {e}"

    def _format_enhanced_statusline(self, milestone_name: str, tasks_completed: int,
                                   tasks_total: int, issue_time: str, branch: str,
                                   context_percentage: float, session_time: str,
                                   model_name: str, timer_active: bool) -> str:
        """
        Format the enhanced statusline with all components.

        Returns:
            str: Complete formatted statusline
        """
        components = []

        # Base FlowForge indicator
        components.append("[FlowForge]")

        # Milestone with progress
        milestone_section = f"🎯 {milestone_name}"
        if tasks_total > 0:
            percentage = (tasks_completed / tasks_total) * 100
            # Progress bar
            progress_chars = int((percentage / 100) * 10)
            progress_bar = "█" * progress_chars + "░" * (10 - progress_chars)
            milestone_section += f" ({tasks_completed}/{tasks_total}) [{progress_bar}] {percentage:.0f}%"

        components.append(milestone_section)

        # Issue time (total time worked) - FIXED FORMAT
        if issue_time and issue_time != "0m":
            components.append(f"⏱️ {issue_time}")

        # Git branch
        components.append(f"🌿 {branch}")

        # Context usage with progress bar - FIXED CALCULATION
        context_chars = int((context_percentage / 100) * 10)
        context_bar = "█" * context_chars + "░" * (10 - context_chars)
        components.append(f"🧠 {context_percentage:.0f}% [{context_bar}]")

        # Session time if active - FIXED FORMAT
        if session_time and session_time != "0m":
            components.append(f"Session: {session_time}")

        # Model name
        components.append(model_name)

        # Active indicator
        if timer_active:
            components.append("● Active")

        return " | ".join(components)


def main():
    """
    Main entry point - reads JSON from stdin and outputs status line.

    Expects JSON input with model information and generates
    appropriate status line output with FIXES applied.
    """
    try:
        # Read JSON input from stdin (need to preserve this for context calculation)
        stdin_content = sys.stdin.read()
        input_data = json.loads(stdin_content) if stdin_content else {}
        model_name = input_data.get('model', {}).get('display_name', 'Model')

        # Generate status line with stdin data for context calculation
        statusline = FlowForgeStatusLine()
        statusline._stdin_data = stdin_content  # Pass stdin data for context calculation
        status = statusline.generate_status_line(model_name)

        print(status, end='')

    except (json.JSONDecodeError, KeyError):
        # Fallback for invalid input
        statusline = FlowForgeStatusLine()
        status = statusline.generate_status_line()
        print(status, end='')

    except Exception as e:
        # Emergency fallback
        print(f"[FlowForge] StatusError | Branch: unknown | {e}", end='', file=sys.stderr)
        print("[FlowForge] StatusError | Branch: unknown | Model", end='')


if __name__ == "__main__":
    main()