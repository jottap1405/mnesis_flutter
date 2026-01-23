#!/usr/bin/env python3
"""
FlowForge Enhanced Status Line - PERFORMANCE OPTIMIZED VERSION WITH FIXES.

Main StatusLine module refactored for Rule #24 compliance (<700 lines).
Uses extracted modules for cache, data loading, and helper functions.

CRITICAL FIXES IMPLEMENTED:
1. Context calculation using transcript files instead of showing 3%
2. Proper time formatting (8h 30m instead of 510m)
3. Session timer tracking for active issues
4. Issue time tracking from .task-times.json
5. Better error handling and fallbacks

Expected output format:
[FlowForge] 🎯 v2.1-statusline-milestone-mode (5/10) [█████░░░░░] 50% ⏱️ 8h 30m | 🌿 feature/423-work | 🧠 75% [███████░░░] | Session: 2h 15m | Opus 4.1 | ● Active

Key optimizations:
1. Lazy GitHub authentication - only when needed
2. Background GitHub data fetching
3. Aggressive caching of gh auth status
4. Deferred module imports
5. Pre-warmed regex patterns at module level
"""

import json
import sys
import time
import threading
from pathlib import Path
from typing import Optional
from functools import lru_cache

# Import extracted modules (Rule #24 compliance)
from statusline_cache import StatusLineCache
from statusline_data_loader import StatusLineDataLoader
from statusline_helpers import StatusLineHelpers

# Import formatting-related classes at module level
from status_formatter_interface import StatusFormatterInterface, FormattingContext, FormatterError
from normal_mode_formatter import NormalModeFormatter
from milestone_mode_formatter import MilestoneModeFormatter
from milestone_detector import MilestoneDetector


def lazy_import(module_name: str, from_list: list = None):
    """
    Lazy import function to defer module loading.

    Args:
        module_name: Name of module to import
        from_list: List of names to import from module

    Returns:
        Import function or dict of imported names
    """
    def _import():
        if from_list:
            module = __import__(module_name, fromlist=from_list)
            return {name: getattr(module, name) for name in from_list}
        return __import__(module_name)
    return _import


# Lazy imports for heavy modules
_formatter_modules = None
_milestone_detector = None


def get_formatter_modules():
    """
    Lazy load formatter modules only when needed.

    Returns:
        Dict of formatter module classes
    """
    global _formatter_modules
    if _formatter_modules is None:
        from status_formatter_interface import StatusFormatterInterface, FormattingContext, FormatterError
        from normal_mode_formatter import NormalModeFormatter
        from milestone_mode_formatter import MilestoneModeFormatter
        _formatter_modules = {
            'StatusFormatterInterface': StatusFormatterInterface,
            'FormattingContext': FormattingContext,
            'FormatterError': FormatterError,
            'NormalModeFormatter': NormalModeFormatter,
            'MilestoneModeFormatter': MilestoneModeFormatter,
        }
    return _formatter_modules


def get_milestone_detector():
    """
    Lazy load milestone detector only when needed.

    Returns:
        MilestoneDetector class
    """
    global _milestone_detector
    if _milestone_detector is None:
        from milestone_detector import MilestoneDetector
        _milestone_detector = MilestoneDetector
    return _milestone_detector


class FlowForgeStatusLine:
    """
    Performance-optimized FlowForge statusline with comprehensive fixes.

    Main coordinator class that uses extracted modules for:
    - Caching (StatusLineCache)
    - Data loading (StatusLineDataLoader)
    - Helper functions (StatusLineHelpers)

    Key optimizations:
    - Deferred GitHub CLI calls (no auth on startup)
    - Lazy module imports
    - Background data fetching for non-critical data
    - Aggressive caching
    - Pre-compiled regex patterns

    CRITICAL FIXES:
    - Real context calculation from transcript files
    - Proper time formatting for all durations
    - Active session tracking
    - Total issue time display
    """

    # Constants
    CACHE_CLEANUP_INTERVAL = 30
    FORMATTER_CACHE_TTL = 5000

    def __init__(self, base_path: Optional[Path] = None):
        """
        Initialize FlowForge StatusLine.

        Args:
            base_path: Base directory path (defaults to current directory)
        """
        self.base_path = base_path or Path.cwd()

        # Use XDG cache directory or temp directory for cache files
        # This prevents git tracking issues completely
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
        # Use 5 minute TTL for GitHub data caching (300000ms)
        self.cache = StatusLineCache(self.cache_file, ttl_ms=300000)
        self.data_loader = StatusLineDataLoader(self.base_path, self.cache)
        self.helpers = StatusLineHelpers(self.base_path, self.data_loader)

        self._last_cleanup_time = time.time()

        # Lazy-loaded components (not initialized until needed)
        self._milestone_detector = None
        self._normal_formatter = None
        self._milestone_formatter = None
        self._cached_formatter = None
        self._formatter_cache_time = 0

        # Store stdin data for context calculation
        self._stdin_data = ""

    def _get_current_formatter(self):
        """
        Gets the appropriate formatter with lazy loading.

        Returns:
            Formatter instance (NormalModeFormatterAdapter or MilestoneModeFormatterAdapter)
        """
        current_time = time.time() * 1000

        # Check if cached formatter is still valid
        if (self._cached_formatter is not None and
            current_time - self._formatter_cache_time < self.FORMATTER_CACHE_TTL):
            return self._cached_formatter

        # Lazy load formatters
        if self._milestone_detector is None:
            MilestoneDetector = get_milestone_detector()
            self._milestone_detector = MilestoneDetector(self.base_path)

        # Detect current mode and select formatter
        try:
            milestone_data = self._milestone_detector.detect_milestone_mode()
            if milestone_data:
                if self._milestone_formatter is None:
                    self._milestone_formatter = MilestoneModeFormatterAdapter(self)
                formatter = self._milestone_formatter
            else:
                if self._normal_formatter is None:
                    self._normal_formatter = NormalModeFormatterAdapter(self)
                formatter = self._normal_formatter
        except Exception:
            if self._normal_formatter is None:
                self._normal_formatter = NormalModeFormatterAdapter(self)
            formatter = self._normal_formatter

        # Cache the selected formatter
        self._cached_formatter = formatter
        self._formatter_cache_time = current_time

        return formatter

    def _build_formatting_context(self, model_name: str, prefer_local: bool) -> FormattingContext:
        """
        Builds formatting context with all necessary data and FIXED calculations.

        Args:
            model_name: AI model name
            prefer_local: Whether to prefer local data over GitHub

        Returns:
            FormattingContext: Complete context for formatters
        """
        # Get git branch and extract issue number
        branch = self.data_loader.get_git_branch()
        issue_num = self.data_loader.extract_issue_number(branch)

        # Get milestone data (prefer GitHub for accurate data, fallback to local)
        milestone_name, tasks_completed, tasks_total, time_remaining = "", 0, 0, "0m"

        # Try GitHub first if we have an issue number (unless prefer_local is set)
        if issue_num and not prefer_local:
            # This will return cached or empty data, and trigger background fetch
            gh_data = self.data_loader.get_milestone_from_github(issue_num)
            if gh_data[0]:  # If we got a milestone name
                milestone_name, tasks_completed, tasks_total, time_remaining = gh_data

        # Fallback to local files if no GitHub data
        if not milestone_name:
            milestone_name, tasks_completed, tasks_total, time_remaining = \
                self.data_loader.get_milestone_from_local_files()

        # Fallback to project name
        if not milestone_name:
            milestone_name = self.data_loader.get_project_name_fallback()

        # Get timer status with proper formatting
        timer_status = ""
        session_time = ""
        issue_time = ""
        if issue_num:
            timer_status = self.data_loader.get_timer_status(issue_num)
            # Get current session time
            session_time = self.helpers.get_session_elapsed_time(issue_num)
            # Get total issue time
            issue_time = self.helpers.get_total_issue_time(issue_num)

        # Get terminal width
        terminal_width = self.helpers.get_terminal_width()

        # FIXED: Calculate context usage with stdin_data
        context_percentage = self.helpers.calculate_context_usage(model_name, self._stdin_data)

        return FormattingContext(
            model_name=model_name,
            git_branch=branch,
            issue_number=issue_num,
            milestone_data={
                'name': milestone_name,
                'tasks_completed': tasks_completed,
                'tasks_total': tasks_total,
                'time_remaining': time_remaining
            } if milestone_name else None,
            task_data={
                'completed': tasks_completed,
                'total': tasks_total,
                'percentage': (tasks_completed / tasks_total) * 100 if tasks_total > 0 else 0
            } if tasks_total > 0 else None,
            timer_data={
                'active': "● Active" in timer_status,
                'issue_number': issue_num,
                'status_text': timer_status,
                'session_time': session_time,
                'issue_time': issue_time
            } if issue_num else None,
            context_usage=context_percentage,
            terminal_width=terminal_width
        )

    def generate_status_line(self, model_name: str = "Model", prefer_local: bool = False) -> str:
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
            # Build formatting context
            context = self._build_formatting_context(model_name, prefer_local)

            # Create enhanced statusline format
            status_line = self._format_enhanced_statusline(context)

            # Clean up expired cache entries periodically
            current_time = time.time()
            if current_time - self._last_cleanup_time >= self.CACHE_CLEANUP_INTERVAL:
                # Do this in background to not block
                threading.Thread(target=self.cache._save_to_disk, daemon=True).start()
                self._last_cleanup_time = current_time

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
            timer_status = ""
            return f"[FlowForge] {milestone_name} | Branch: {branch} | {model_name}{timer_status}"

    def _format_enhanced_statusline(self, context: FormattingContext) -> str:
        """
        Format the enhanced statusline with all components.

        Args:
            context: FormattingContext with all data

        Returns:
            str: Complete formatted statusline
        """
        components = []

        # Base FlowForge indicator
        components.append("[FlowForge]")

        # Milestone with progress
        milestone_data = context.milestone_data or {}
        task_data = context.task_data or {}
        timer_data = context.timer_data or {}

        milestone_name = milestone_data.get('name', 'Unknown')
        tasks_completed = task_data.get('completed', 0)
        tasks_total = task_data.get('total', 0)
        percentage = task_data.get('percentage', 0)

        # Format milestone section
        milestone_section = f"🎯 {milestone_name}"
        if tasks_total > 0:
            # Progress bar
            progress_chars = int((percentage / 100) * 10)
            progress_bar = "█" * progress_chars + "░" * (10 - progress_chars)
            milestone_section += f" ({tasks_completed}/{tasks_total}) [{progress_bar}] {percentage:.0f}%"

        components.append(milestone_section)

        # Issue time (total time worked)
        if timer_data and timer_data.get('issue_time'):
            components.append(f"⏱️ {timer_data['issue_time']}")

        # Git branch
        components.append(f"🌿 {context.git_branch}")

        # Context usage with progress bar
        context_percentage = context.context_usage
        context_chars = int((context_percentage / 100) * 10)
        context_bar = "█" * context_chars + "░" * (10 - context_chars)
        components.append(f"🧠 {context_percentage:.0f}% [{context_bar}]")

        # Session time if active
        if timer_data and timer_data.get('session_time') and timer_data.get('session_time') != "0m":
            components.append(f"Session: {timer_data['session_time']}")

        # Model name
        components.append(context.model_name)

        # Active indicator
        if timer_data and timer_data.get('active'):
            components.append("● Active")

        return " | ".join(components)

    def create_normal_formatter_adapter(self, context: FormattingContext):
        """
        Creates NormalModeFormatter data structure from FormattingContext.

        Args:
            context: FormattingContext with all statusline data

        Returns:
            NormalStatusData: Data structure for NormalModeFormatter
        """
        from normal_mode_formatter import StatusLineData as NormalStatusData

        milestone_data = context.milestone_data or {}
        task_data = context.task_data or {}
        timer_data = context.timer_data or {}

        return NormalStatusData(
            version="v2.1",
            tasks_completed=task_data.get('completed', 0),
            tasks_total=task_data.get('total', 0),
            task_percentage=task_data.get('percentage', 0.0),
            elapsed_time=timer_data.get('session_time', '0m'),
            planned_time=self.helpers.get_planned_time(),
            remaining_budget=milestone_data.get('time_remaining', '0:00h'),
            git_branch=context.git_branch,
            context_usage=context.context_usage,
            model_name=context.model_name,
            milestone_name=milestone_data.get('name', '')
        )

    def create_milestone_formatter_adapter(self, context: FormattingContext):
        """
        Creates MilestoneModeFormatter data structure from FormattingContext.

        Args:
            context: FormattingContext with all statusline data

        Returns:
            MilestoneStatusData: Data structure for MilestoneModeFormatter
        """
        from milestone_mode_formatter import MilestoneStatusLineData as MilestoneStatusData

        milestone_data = context.milestone_data or {}
        task_data = context.task_data or {}
        timer_data = context.timer_data or {}

        return MilestoneStatusData(
            milestone_name=milestone_data.get('name', ''),
            track_name=self.helpers.extract_track_name(),
            tasks_completed=task_data.get('completed', 0),
            tasks_total=task_data.get('total', 0),
            current_session_time=timer_data.get('session_time', '0m'),
            eta_remaining=milestone_data.get('time_remaining', '0.0h'),
            git_branch=context.git_branch,
            model_name=context.model_name
        )


class NormalModeFormatterAdapter:
    """
    Adapter to make NormalModeFormatter work with FormattingContext.

    Bridges between the FormattingContext data structure and
    NormalModeFormatter's expected data format.
    """

    def __init__(self, statusline_instance: FlowForgeStatusLine):
        """
        Initialize adapter with statusline instance.

        Args:
            statusline_instance: FlowForgeStatusLine instance
        """
        self.statusline = statusline_instance
        self.formatter = None  # Lazy load

    def format(self, context: FormattingContext) -> str:
        """
        Format using enhanced statusline format.

        Args:
            context: FormattingContext with statusline data

        Returns:
            str: Formatted status line
        """
        # Use enhanced formatting instead of old formatter
        return self.statusline._format_enhanced_statusline(context)


class MilestoneModeFormatterAdapter:
    """
    Adapter to make MilestoneModeFormatter work with FormattingContext.

    Bridges between the FormattingContext data structure and
    MilestoneModeFormatter's expected data format.
    """

    def __init__(self, statusline_instance: FlowForgeStatusLine):
        """
        Initialize adapter with statusline instance.

        Args:
            statusline_instance: FlowForgeStatusLine instance
        """
        self.statusline = statusline_instance
        self.formatter = None  # Lazy load

    def format(self, context: FormattingContext) -> str:
        """
        Format using enhanced statusline format.

        Args:
            context: FormattingContext with statusline data

        Returns:
            str: Formatted status line
        """
        # Use enhanced formatting instead of old formatter
        return self.statusline._format_enhanced_statusline(context)


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

        # Handle both nested and flat model structures
        model_info = input_data.get('model', 'Model')
        if isinstance(model_info, dict):
            model_name = model_info.get('display_name', 'Model')
        else:
            # If model is a string, use it directly
            model_name = model_info if model_info else 'Model'

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
        print(f"[FlowForge] Error | {e}", end='', file=sys.stderr)
        print("[FlowForge] StatusError | Branch: unknown | Model", end='')


if __name__ == "__main__":
    main()