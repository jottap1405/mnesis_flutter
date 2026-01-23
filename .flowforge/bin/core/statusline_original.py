#!/usr/bin/env python3
"""
FlowForge Enhanced Status Line - PERFORMANCE OPTIMIZED VERSION.

Main StatusLine module refactored for Rule #24 compliance (<700 lines).
Uses extracted modules for cache, data loading, and helper functions.

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
    Performance-optimized FlowForge statusline.
    
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
        self.cache = StatusLineCache(self.cache_file)
        self.data_loader = StatusLineDataLoader(self.base_path, self.cache)
        self.helpers = StatusLineHelpers(self.base_path, self.data_loader)
        
        self._last_cleanup_time = time.time()
        
        # Lazy-loaded components (not initialized until needed)
        self._milestone_detector = None
        self._normal_formatter = None
        self._milestone_formatter = None
        self._cached_formatter = None
        self._formatter_cache_time = 0
    
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
        Builds formatting context with all necessary data.
        
        Args:
            model_name: AI model name
            prefer_local: Whether to prefer local data over GitHub
            
        Returns:
            FormattingContext: Complete context for formatters
        """
        # Get git branch and extract issue number
        branch = self.data_loader.get_git_branch()
        issue_num = self.data_loader.extract_issue_number(branch)
        
        # Get milestone data (prefer local to avoid GitHub calls)
        milestone_name, tasks_completed, tasks_total, time_remaining = "", 0, 0, "0m"
        
        # Always try local files first for performance
        milestone_name, tasks_completed, tasks_total, time_remaining = \
            self.data_loader.get_milestone_from_local_files()
        
        # Only try GitHub if no local data and we have an issue number
        if not milestone_name and issue_num and not prefer_local:
            # This will return cached or empty data, and trigger background fetch
            gh_data = self.data_loader.get_milestone_from_github(issue_num)
            if gh_data[0]:  # If we got a milestone name
                milestone_name, tasks_completed, tasks_total, time_remaining = gh_data
        
        # Fallback to project name
        if not milestone_name:
            milestone_name = self.data_loader.get_project_name_fallback()
        
        # Get timer status
        timer_status = ""
        if issue_num:
            timer_status = self.data_loader.get_timer_status(issue_num)
        
        # Get terminal width
        terminal_width = self.helpers.get_terminal_width()
        
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
                'status_text': timer_status
            } if issue_num else None,
            context_usage=self.helpers.calculate_context_usage(model_name),
            terminal_width=terminal_width
        )
    
    def generate_status_line(self, model_name: str = "Model", prefer_local: bool = True) -> str:
        """
        Generate the complete status line with performance optimizations.
        
        Args:
            model_name: AI model name
            prefer_local: Whether to prefer local data over GitHub API
            
        Returns:
            str: Formatted status line
        """
        start_time = time.time()
        
        try:
            # Build formatting context
            context = self._build_formatting_context(model_name, prefer_local)
            
            # Select formatter and generate output
            formatter = self._get_current_formatter()
            status_line = formatter.format(context)
            
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
            elapsed_time=self.helpers.get_session_elapsed_time(),
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
        
        return MilestoneStatusData(
            milestone_name=milestone_data.get('name', ''),
            track_name=self.helpers.extract_track_name(),
            tasks_completed=task_data.get('completed', 0),
            tasks_total=task_data.get('total', 0),
            current_session_time=self.helpers.get_session_elapsed_time(),
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
        Format using NormalModeFormatter with context adaptation.
        
        Args:
            context: FormattingContext with statusline data
            
        Returns:
            str: Formatted status line
        """
        if self.formatter is None:
            modules = get_formatter_modules()
            NormalModeFormatter = modules['NormalModeFormatter']
            self.formatter = NormalModeFormatter()
        
        # Adapt context to NormalStatusData
        from normal_mode_formatter import StatusLineData as NormalStatusData
        
        milestone_data = context.milestone_data or {}
        task_data = context.task_data or {}
        
        data = NormalStatusData(
            version="v2.1",
            tasks_completed=task_data.get('completed', 0),
            tasks_total=task_data.get('total', 0),
            task_percentage=task_data.get('percentage', 0.0),
            elapsed_time=self.statusline.helpers.get_session_elapsed_time(context.issue_number),
            planned_time=self.statusline.helpers.get_planned_time(),
            remaining_budget=milestone_data.get('time_remaining', '0:00h'),
            git_branch=context.git_branch,
            context_usage=context.context_usage,
            model_name=context.model_name,
            milestone_name=milestone_data.get('name', '')
        )
        return self.formatter.format(data)


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
        Format using MilestoneModeFormatter with context adaptation.
        
        Args:
            context: FormattingContext with statusline data
            
        Returns:
            str: Formatted status line
        """
        if self.formatter is None:
            modules = get_formatter_modules()
            MilestoneModeFormatter = modules['MilestoneModeFormatter']
            self.formatter = MilestoneModeFormatter()
        
        # Adapt context to MilestoneStatusData
        from milestone_mode_formatter import MilestoneStatusLineData as MilestoneStatusData
        
        milestone_data = context.milestone_data or {}
        task_data = context.task_data or {}
        
        data = MilestoneStatusData(
            milestone_name=milestone_data.get('name', ''),
            track_name=self.statusline.helpers.extract_track_name(),
            tasks_completed=task_data.get('completed', 0),
            tasks_total=task_data.get('total', 0),
            current_session_time=self.statusline.helpers.get_session_elapsed_time(context.issue_number),
            eta_remaining=milestone_data.get('time_remaining', '0.0h'),
            git_branch=context.git_branch,
            model_name=context.model_name
        )
        return self.formatter.format(data)


def main():
    """
    Main entry point - reads JSON from stdin and outputs status line.
    
    Expects JSON input with model information and generates
    appropriate status line output.
    """
    try:
        # Read JSON input from stdin
        input_data = json.load(sys.stdin)
        model_name = input_data.get('model', {}).get('display_name', 'Model')
        
        # Generate status line
        statusline = FlowForgeStatusLine()
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