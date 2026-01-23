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

# Import ETA calculator for dual ETA display
try:
    from eta_calculator import ETACalculator, format_eta
    from estimate_parser import EstimateParser
    ETA_CALCULATOR_AVAILABLE = True
except ImportError:
    ETA_CALCULATOR_AVAILABLE = False


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

        # Initialize ETA calculator if available
        self.eta_calculator = None
        if ETA_CALCULATOR_AVAILABLE:
            try:
                self.eta_calculator = ETACalculator(
                    time_tracking_path=str(self.base_path / '.flowforge' / 'billing' / 'time-tracking.json'),
                    velocity_history_path=str(self.base_path / '.flowforge' / 'billing' / 'velocity-history.json')
                )
            except Exception:
                self.eta_calculator = None

        # Store stdin data for context calculation
        self._stdin_data = ""

    def generate_status_line(self, model_name: str = "Model", prefer_local: bool = False) -> str:
        """
        Generate the complete status line with performance optimizations and FIXES.

        Args:
            model_name: AI model name
            prefer_local: Whether to prefer local data over GitHub API (default: False - checks GitHub first)

        Returns:
            str: Formatted status line with proper time formatting and context
        """
        start_time = time.time()

        try:
            # Get git branch and extract issue number
            branch = self.data_loader.get_git_branch()
            issue_num = self.data_loader.extract_issue_number(branch)

            # FIXED: Try GitHub FIRST for fresh data, fallback to local
            milestone_name = ""
            tasks_completed = 0
            tasks_total = 0
            time_remaining = "0m"

            # Try GitHub first if we have an issue number (for fresh data)
            if issue_num and not prefer_local:
                gh_data = self.data_loader.get_milestone_from_github(issue_num)
                if gh_data[0]:  # If we got a milestone name from GitHub
                    milestone_name, tasks_completed, tasks_total, time_remaining = gh_data

            # Fallback to local files if no GitHub data AND we're on a ticket branch
            if not milestone_name and issue_num:
                local_data = self.data_loader.get_milestone_from_local_files()
                milestone_name, tasks_completed, tasks_total, time_remaining = local_data
            # If we got GitHub data but no time remaining, try to get it from local
            elif time_remaining == "0m":
                local_data = self.data_loader.get_milestone_from_local_files()
                if local_data[3] and local_data[3] != "0m":
                    time_remaining = local_data[3]

            # Fallback to project name
            if not milestone_name:
                milestone_name = self.data_loader.get_project_name_fallback()

            # Get timer status with proper formatting
            timer_active = False
            session_time = ""
            issue_time = ""
            ticket_eta = None
            milestone_eta = None

            if issue_num:
                timer_status = self.data_loader.get_timer_status(issue_num)
                timer_active = "● Active" in timer_status
                # Get current session time
                session_time = self.helpers.get_session_elapsed_time(issue_num)
                # Get total issue time
                issue_time = self.helpers.get_total_issue_time(issue_num)

                # Calculate dual ETAs if calculator available
                if self.eta_calculator:
                    try:
                        # Calculate ticket ETA
                        ticket_eta_hours = self.eta_calculator.calculate_ticket_eta(issue_num)
                        ticket_eta = format_eta(ticket_eta_hours)
                    except Exception:
                        # Fall back to original time_remaining on calculation failure
                        ticket_eta = None

            # Calculate milestone ETA (can work without issue_num)
            if self.eta_calculator and milestone_name:
                try:
                    milestone_eta_hours = self.eta_calculator.calculate_milestone_eta(milestone_name)
                    milestone_eta = format_eta(milestone_eta_hours)
                except Exception:
                    # Fall back to original time_remaining on calculation failure
                    milestone_eta = None

            # FIXED: Calculate context usage with exceeds_200k_tokens flag
            context_percentage = self.helpers.calculate_context_usage(model_name, self._stdin_data)

            # Format enhanced statusline with dual ETA parameters
            status_line = self._format_enhanced_statusline(
                milestone_name, tasks_completed, tasks_total,
                time_remaining, branch, context_percentage,
                session_time, model_name, timer_active,
                issue_num, ticket_eta, milestone_eta
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
                                   tasks_total: int, time_remaining: str, branch: str,
                                   context_percentage: float, session_time: str,
                                   model_name: str, timer_active: bool,
                                   issue_num: Optional[str] = None, ticket_eta: Optional[str] = None,
                                   milestone_eta: Optional[str] = None) -> str:
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

        # Dual ETA display (ticket + milestone) or fallback to original
        eta_component = self._format_eta_component(
            issue_num, ticket_eta, milestone_eta, time_remaining
        )
        if eta_component:
            components.append(eta_component)

        # Git branch
        components.append(f"🌿 {branch}")

        # Context usage with progress bar - Only show if we have valid percentage
        # -1.0 signals "don't display context"
        if context_percentage >= 0:
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

    def _format_eta_component(self, issue_num: Optional[str], ticket_eta: Optional[str],
                             milestone_eta: Optional[str], fallback_time: str) -> str:
        """
        Format the ETA component with dual display or fallback.

        Args:
            issue_num: Current issue number
            ticket_eta: Calculated ticket ETA
            milestone_eta: Calculated milestone ETA
            fallback_time: Original time_remaining as fallback

        Returns:
            str: Formatted ETA component or empty string
        """
        # If we have both ETAs, show dual display
        if ticket_eta and milestone_eta and issue_num:
            # Check available space for format decision
            terminal_width = self.helpers.get_terminal_width()

            if terminal_width > 120:  # Full format
                if ticket_eta == "0m" or "Overrun" in ticket_eta:
                    return f"⏰ Overrun on #{issue_num} | {milestone_eta} milestone"
                else:
                    return f"⏰ {ticket_eta} on #{issue_num} | {milestone_eta} milestone"
            else:  # Compact format
                if ticket_eta == "0m" or "Overrun" in ticket_eta:
                    return f"⏰ #{issue_num}: Overrun/{milestone_eta}"
                else:
                    return f"⏰ #{issue_num}: {ticket_eta}/{milestone_eta}"

        # If we only have milestone ETA
        elif milestone_eta:
            return f"⏰ {milestone_eta} milestone"

        # If we only have ticket ETA
        elif ticket_eta and issue_num:
            if ticket_eta == "0m" or "Overrun" in ticket_eta:
                return f"⏰ Overrun on #{issue_num}"
            else:
                return f"⏰ {ticket_eta} on #{issue_num}"

        # Fallback to original time display
        elif fallback_time and fallback_time != "0m":
            return f"⏱️ {fallback_time}"

        # No ETA to display
        return ""


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