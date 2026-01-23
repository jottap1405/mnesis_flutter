#!/usr/bin/env python3
"""
NormalModeFormatter - Formats FlowForge statusline in normal mode display.

Generates statusline in the format:
⚩ FF v2.0 📋 317/21 [▓▓▓░░] 14% | ⏱ 00:23/0:30 | 💰 4:30h left | 🌿 feature/317 | 🧠 85% [████░] | Opus

This formatter implements the strategy pattern for statusline formatting,
providing comprehensive status information in a visually rich format.
All functions follow FlowForge Rule #26 documentation standards.

Features:
- FlowForge branding with version display
- Task progress with visual indicators
- Time tracking with elapsed/planned display
- Budget/time remaining calculations
- Git branch information
- Context usage indicators
- Model identification
- Terminal width constraints handling
- Graceful fallback for missing data

Author: FlowForge Team
Since: 2.1.0
"""

import re
from typing import Dict, Any, Optional, Tuple
from dataclasses import dataclass
from progress_bar_renderer import ProgressBarRenderer, render_task_progress
from formatter_utils import (
    sanitize_string,
    validate_time_format,
    parse_time_to_minutes,
    detect_terminal_width,
    get_warning_indicator,
    calculate_eta,
    truncate_to_width,
    format_percentage_with_bar,
    get_git_branch,
    MAX_BRANCH_LENGTH,
    MAX_MODEL_NAME_LENGTH,
    MAX_VERSION_LENGTH
)


class NormalModeFormatterError(Exception):
    """
    Custom exception for NormalModeFormatter errors.
    
    Raised when:
    - Invalid statusline data structure
    - Terminal width constraints cannot be met
    - Required formatters are unavailable
    """
    pass


@dataclass
class StatusLineData:
    """
    Data structure for statusline components.
    
    Attributes:
        version: FlowForge version (e.g., "v2.0")
        tasks_completed: Number of completed tasks
        tasks_total: Total number of tasks
        task_percentage: Task completion percentage
        elapsed_time: Time elapsed in format "00:23"
        planned_time: Planned time in format "0:30"
        remaining_budget: Remaining time budget (e.g., "4:30h")
        git_branch: Current git branch name
        context_usage: Context usage percentage (0-100)
        model_name: Model name (e.g., "Opus")
        milestone_name: Current milestone name (optional)
    """
    version: str = "v2.0"
    tasks_completed: int = 0
    tasks_total: int = 0
    task_percentage: float = 0.0
    elapsed_time: str = "00:00"
    planned_time: str = "0:00"
    remaining_budget: str = "0:00h"
    git_branch: str = "main"
    context_usage: float = 0.0
    model_name: str = "Model"
    milestone_name: str = ""


class NormalModeFormatter:
    """
    Formats FlowForge statusline in normal mode display.
    
    Implements the strategy pattern for statusline formatting, generating
    comprehensive status information in the specified visual format with
    emoji indicators and progress bars.
    
    The formatter handles terminal width constraints, missing data gracefully,
    and integrates with the existing progress bar renderer system.
    
    Example:
        >>> formatter = NormalModeFormatter()
        >>> data = StatusLineData(
        ...     tasks_completed=317, tasks_total=21,
        ...     elapsed_time="00:23", planned_time="0:30"
        ... )
        >>> formatter.format(data)
        '⚩ FF v2.0 📋 317/21 [▓▓▓░░] 14% | ⏱ 00:23/0:30 | ...'
    """

    # Component emoji indicators (Rule #27: Document component meanings)
    EMOJI_FLOWFORGE = "⚩"          # FlowForge brand indicator
    EMOJI_TASKS = "📋"              # Task/milestone progress indicator
    EMOJI_TIME = "⏱"               # Time tracking indicator
    EMOJI_BUDGET = "💰"             # Budget/remaining time indicator
    EMOJI_BRANCH = "🌿"             # Git branch indicator
    EMOJI_CONTEXT = "🧠"            # Context usage indicator

    # Format configuration
    MIN_TERMINAL_WIDTH = 80         # Minimum terminal width for full display
    PROGRESS_BAR_WIDTH = 5          # Fixed progress bar width: [▓▓▓░░]
    CONTEXT_BAR_WIDTH = 5           # Fixed context bar width: [████░]

    def __init__(self, terminal_width: Optional[int] = None):
        """
        Initialize NormalModeFormatter with optional terminal width.
        
        Args:
            terminal_width: Terminal width in characters (auto-detected if None)
            
        Raises:
            NormalModeFormatterError: If terminal width is too small
            
        Example:
            >>> formatter = NormalModeFormatter()
            >>> formatter_80 = NormalModeFormatter(terminal_width=80)
        """
        self.terminal_width = terminal_width or detect_terminal_width(
            self.MIN_TERMINAL_WIDTH, 100
        )
        
        if self.terminal_width < self.MIN_TERMINAL_WIDTH:
            raise NormalModeFormatterError(
                f"Terminal width {self.terminal_width} too small "
                f"(minimum: {self.MIN_TERMINAL_WIDTH})"
            )
        
        # Initialize progress bar renderer
        self.progress_renderer = ProgressBarRenderer()

    def format(self, data: StatusLineData) -> str:
        """
        Formats complete statusline with all components.
        
        Args:
            data: StatusLineData containing all statusline components
            
        Returns:
            str: Formatted statusline string
            
        Raises:
            NormalModeFormatterError: If data is invalid or formatting fails
            
        Example:
            >>> data = StatusLineData(version="v2.0", tasks_completed=5)
            >>> formatter.format(data)
            '⚩ FF v2.0 📋 5/0 [░░░░░] 0% | ⏱ 00:00/0:00 | ...'
        """
        # Rule #8: Input validation
        if not isinstance(data, StatusLineData):
            raise NormalModeFormatterError("Invalid data structure")
        
        # Sanitize inputs for security
        sanitized_data = self._sanitize_data(data)
        
        # Build statusline components
        components = [
            self._format_flowforge_header(sanitized_data),
            self._format_task_progress(sanitized_data),
            self._format_time_tracking(sanitized_data),
            self._format_budget_remaining(sanitized_data),
            self._format_git_branch(sanitized_data),
            self._format_context_usage(sanitized_data),
            self._format_model_name(sanitized_data)
        ]
        
        # Join with separators and handle width constraints
        statusline = " | ".join(components)
        
        # Apply width constraints only if we significantly exceed terminal width
        # Allow 20% buffer to prevent premature truncation
        if len(statusline) > (self.terminal_width * 1.2):
            statusline = self._apply_width_constraints(statusline, components)
        
        return statusline

    def _format_flowforge_header(self, data: StatusLineData) -> str:
        """
        Formats FlowForge header component.
        
        Args:
            data: StatusLineData containing version info
            
        Returns:
            str: Formatted header (e.g., "⚩ FF v2.0")
            
        Note:
            Includes brand emoji and version number.
        """
        return f"{self.EMOJI_FLOWFORGE} FF {data.version}"

    def _format_task_progress(self, data: StatusLineData) -> str:
        """
        Formats task progress component with progress bar.
        
        Args:
            data: StatusLineData containing task progress info
            
        Returns:
            str: Formatted task progress (e.g., "📋 317/21 [▓▓▓░░] 14%")
            
        Note:
            Includes emoji, counts, progress bar, and percentage.
        """
        # Rule #27: Handle overflow cases explicitly
        # Tasks completed can exceed total in overflow scenarios
        percentage = data.task_percentage
        if data.tasks_total > 0:
            calculated_percentage = (data.tasks_completed / data.tasks_total) * 100
            percentage = calculated_percentage
        
        # Cap display percentage at 100% for progress bar
        display_percentage = min(percentage, 100)
        
        try:
            progress_bar = self.progress_renderer.render(display_percentage)
        except Exception:
            # Fallback if progress bar fails
            progress_bar = "[?????]"
        
        # Format percentage - handle overflow display
        if percentage > 100:
            percentage_str = f"{percentage:.0f}%"  # Show actual percentage
        else:
            percentage_str = f"{percentage:.0f}%"
        
        return f"{self.EMOJI_TASKS} {data.tasks_completed}/{data.tasks_total} {progress_bar} {percentage_str}"

    def _format_time_tracking(self, data: StatusLineData) -> str:
        """
        Formats time tracking component.
        
        Args:
            data: StatusLineData containing time info
            
        Returns:
            str: Formatted time tracking (e.g., "⏱ 00:23/0:30")
            
        Note:
            Shows elapsed/planned time for immediate context.
        """
        # Validate time formats
        elapsed = validate_time_format(data.elapsed_time)
        planned = validate_time_format(data.planned_time)
        
        # Add warning if over time
        time_warning = self._get_time_warning(elapsed, planned)
        
        base_format = f"{self.EMOJI_TIME} {elapsed}/{planned}"
        
        if time_warning:
            return f"{base_format} {time_warning}"
        else:
            return base_format

    def _format_budget_remaining(self, data: StatusLineData) -> str:
        """
        Formats budget/time remaining component.
        
        Args:
            data: StatusLineData containing budget info
            
        Returns:
            str: Formatted budget remaining (e.g., "💰 4:30h left")
            
        Note:
            Critical for time tracking - developers need to know remaining budget.
        """
        # Sanitize budget format
        budget = sanitize_string(data.remaining_budget, 15, "0:00h")
        
        # Add warning for low budget (if budget is in h:mmh format)
        budget_warning = self._get_budget_warning(budget)
        
        base_format = f"{self.EMOJI_BUDGET} {budget} left"
        
        if budget_warning:
            return f"{base_format} {budget_warning}"
        else:
            return base_format

    def _format_git_branch(self, data: StatusLineData) -> str:
        """
        Formats git branch component.
        
        Args:
            data: StatusLineData containing branch info
            
        Returns:
            str: Formatted git branch (e.g., "🌿 feature/317")
            
        Note:
            Truncates long branch names to fit terminal width.
        """
        # Rule #8: Security - limit branch name length
        branch = data.git_branch[:MAX_BRANCH_LENGTH]
        return f"{self.EMOJI_BRANCH} {branch}"

    def _format_context_usage(self, data: StatusLineData) -> str:
        """
        Formats context usage component with progress bar.
        
        Args:
            data: StatusLineData containing context usage info
            
        Returns:
            str: Formatted context usage (e.g., "🧠 85% [████░]")
            
        Note:
            Shows context usage with warning indicators when high.
        """
        try:
            # Keep original percentage for display (can be > 100%)
            original_percentage = float(data.context_usage or 0)
            
            # Clamp percentage for progress bar display (0-100%)
            display_percentage = max(0, min(100, original_percentage))
            
            # Use progress bar renderer for visual consistency
            context_bar = self.progress_renderer.render(display_percentage)
            
            # Get warning indicator based on original percentage
            warning_indicator = get_warning_indicator(original_percentage)
            
            # Show original percentage but cap display at 100% if overflow
            shown_percentage = min(100, original_percentage)
            base_format = f"{self.EMOJI_CONTEXT} {shown_percentage:.0f}% {context_bar}"
            
            if warning_indicator:
                return f"{base_format} {warning_indicator}"
            else:
                return base_format
                
        except Exception:
            # Fallback on any error
            return f"{self.EMOJI_CONTEXT} 0% [░░░░░]"

    def _format_model_name(self, data: StatusLineData) -> str:
        """
        Formats model name component.
        
        Args:
            data: StatusLineData containing model info
            
        Returns:
            str: Formatted model name (e.g., "Opus")
            
        Note:
            No emoji prefix to maintain clean terminal appearance.
        """
        # Rule #8: Security - limit model name length
        model = data.model_name[:MAX_MODEL_NAME_LENGTH]
        return model

    def _sanitize_data(self, data: StatusLineData) -> StatusLineData:
        """
        Sanitizes input data for security and validation.
        
        Args:
            data: Raw StatusLineData
            
        Returns:
            StatusLineData: Sanitized data with validated ranges
            
        Note:
            Applies security limits and validates numeric ranges.
        """
        # Rule #8: Comprehensive input validation
        sanitized = StatusLineData(
            version=sanitize_string(data.version, MAX_VERSION_LENGTH, "v2.0"),
            tasks_completed=max(0, int(data.tasks_completed or 0)),
            tasks_total=max(0, int(data.tasks_total or 0)),
            task_percentage=max(0, float(data.task_percentage or 0)),
            elapsed_time=validate_time_format(data.elapsed_time),
            planned_time=validate_time_format(data.planned_time),
            remaining_budget=sanitize_string(data.remaining_budget, 15, "0:00h"),
            git_branch=sanitize_string(data.git_branch, MAX_BRANCH_LENGTH, "main"),
            context_usage=max(0, min(100, float(data.context_usage or 0))),
            model_name=sanitize_string(data.model_name, MAX_MODEL_NAME_LENGTH, "Model"),
            milestone_name=sanitize_string(data.milestone_name, 50, "")
        )
        
        # Recalculate percentage if needed
        if sanitized.tasks_total > 0:
            sanitized.task_percentage = (sanitized.tasks_completed / sanitized.tasks_total) * 100
        
        return sanitized

    def _get_time_warning(self, elapsed: str, planned: str) -> str:
        """
        Gets warning indicator for time overruns.
        
        Args:
            elapsed: Elapsed time string
            planned: Planned time string
            
        Returns:
            str: Warning indicator emoji or empty string
        """
        try:
            elapsed_minutes = parse_time_to_minutes(elapsed)
            planned_minutes = parse_time_to_minutes(planned)
            
            if planned_minutes > 0:
                percentage_used = (elapsed_minutes / planned_minutes) * 100
                
                if percentage_used > 100:
                    return "🚨"  # Over time
                elif percentage_used > 90:
                    return "⚠️"  # Near limit
            
            return ""
        except Exception:
            return ""
    
    def _get_budget_warning(self, budget: str) -> str:
        """
        Gets warning indicator for low budget.
        
        Args:
            budget: Budget string (e.g., "0:45h", "2:30h")
            
        Returns:
            str: Warning indicator emoji or empty string
        """
        try:
            # Parse budget to get hours/minutes
            import re
            match = re.match(r'(\d+):(\d+)h', budget)
            if match:
                hours = int(match.group(1))
                minutes = int(match.group(2))
                total_minutes = hours * 60 + minutes
                
                # Don't warn if budget is 0 (no budget set)
                if total_minutes == 0:
                    return ""
                    
                if total_minutes < 30:  # Less than 30 minutes
                    return "🚨"  # Critical budget warning
                elif total_minutes < 60:  # Less than 1 hour
                    return "⚠️"  # Low budget warning
            
            return ""
        except Exception:
            return ""

    def _apply_width_constraints(self, statusline: str, components: list) -> str:
        """
        Applies terminal width constraints by truncating components.
        
        Args:
            statusline: Full statusline string
            components: List of statusline components
            
        Returns:
            str: Truncated statusline that fits terminal width
            
        Note:
            Prioritizes essential components (version, tasks, model).
        """
        # Use shared truncation logic
        return truncate_to_width(components, self.terminal_width, "normal")

    def get_component_info(self) -> Dict[str, str]:
        """
        Returns information about statusline components and their meanings.
        
        Returns:
            dict: Component descriptions with emoji indicators
            
        Example:
            >>> formatter.get_component_info()
            {'⚩': 'FlowForge brand and version', ...}
        """
        return {
            self.EMOJI_FLOWFORGE: "FlowForge brand and version",
            self.EMOJI_TASKS: "Task progress with visual indicator",
            self.EMOJI_TIME: "Time tracking (elapsed/planned)",
            self.EMOJI_BUDGET: "Remaining time budget",
            self.EMOJI_BRANCH: "Current git branch",
            self.EMOJI_CONTEXT: "Context usage with warnings",
            "Model": "Model identifier"
        }

    def format_with_context(self) -> str:
        """
        Formats statusline with automatically detected context.
        
        Uses git branch, session time tracking, and other context
        to generate appropriate statusline data.
        
        Returns:
            str: Formatted statusline with detected context
            
        Example:
            >>> formatter = NormalModeFormatter()
            >>> formatter.format_with_context()
            '⚩ FF v2.0 📋 5/12 [▓▓░░░] 42% | ⏱ 01:15/3:00 | 💰 1:45h left | 🌿 feature/142 | 🧠 45% [▓▓░░░] | Opus'
        """
        # Get current git branch
        git_branch = get_git_branch()
        
        # Get current session info (simplified for now)
        elapsed_time = self._get_current_session_time()
        
        # Create data structure with detected context
        data = StatusLineData(
            version="v2.0",  # TODO: Detect from package.json or config
            tasks_completed=0,  # TODO: Calculate from project state
            tasks_total=0,      # TODO: Calculate from project state
            task_percentage=0.0,
            elapsed_time=elapsed_time,
            planned_time="0:00",  # TODO: Get from session tracking
            remaining_budget="0:00h",  # TODO: Calculate from budget
            git_branch=git_branch,
            context_usage=0.0,  # TODO: Calculate from API usage
            model_name="Model"  # TODO: Detect current model
        )
        
        return self.format(data)
    
    def format_compact(self, data: StatusLineData) -> str:
        """
        Formats statusline in compact mode for narrow terminals.
        
        Args:
            data: StatusLineData containing all statusline components
            
        Returns:
            str: Compact formatted statusline string
            
        Note:
            Uses aggressive width constraints to fit narrow terminals.
        """
        # Force narrow terminal width for compact mode
        original_width = self.terminal_width
        self.terminal_width = 80  # Force compact width
        
        try:
            # Get all components
            sanitized_data = self._sanitize_data(data)
            components = [
                self._format_flowforge_header(sanitized_data),
                self._format_task_progress(sanitized_data),
                self._format_model_name(sanitized_data)  # Only essential components for compact
            ]
            
            # Force width constraints
            result = self._apply_width_constraints(" | ".join(components), components)
            return result
        finally:
            # Restore original width
            self.terminal_width = original_width

    def _get_current_session_time(self) -> str:
        """
        Gets current session elapsed time.
        
        Returns:
            str: Session time in HH:MM format
            
        Note:
            Simplified implementation - in real usage would integrate
            with FlowForge session tracking.
        """
        # TODO: Integrate with actual FlowForge session tracking
        # For now, return placeholder
        return "00:00"


# Convenience functions for quick usage
def format_normal_statusline(
    version: str = "v2.0",
    tasks_completed: int = 0,
    tasks_total: int = 0,
    elapsed_time: str = "00:00",
    planned_time: str = "0:00",
    remaining_budget: str = "0:00h",
    git_branch: str = "main",
    context_usage: float = 0.0,
    model_name: str = "Model"
) -> str:
    """
    Quick function to format normal mode statusline.
    
    Args:
        version: FlowForge version
        tasks_completed: Number of completed tasks
        tasks_total: Total number of tasks
        elapsed_time: Time elapsed in HH:MM format
        planned_time: Planned time in HH:MM format
        remaining_budget: Remaining budget (e.g., "4:30h")
        git_branch: Current git branch name
        context_usage: Context usage percentage (0-100)
        model_name: Model name
        
    Returns:
        str: Formatted statusline string
        
    Example:
        >>> format_normal_statusline("v2.0", 317, 21, "00:23", "0:30", "4:30h", "feature/317", 85, "Opus")
        '⚩ FF v2.0 📋 317/21 [▓▓▓▓▓] 1510% | ⏱ 00:23/0:30 | 💰 4:30h left | 🌿 feature/317 | 🧠 85% [████░] | Opus'
    """
    formatter = NormalModeFormatter()
    data = StatusLineData(
        version=version,
        tasks_completed=tasks_completed,
        tasks_total=tasks_total,
        task_percentage=0,  # Will be calculated
        elapsed_time=elapsed_time,
        planned_time=planned_time,
        remaining_budget=remaining_budget,
        git_branch=git_branch,
        context_usage=context_usage,
        model_name=model_name
    )
    
    return formatter.format(data)


# Rule #33: No vendor references in module metadata
__all__ = [
    'NormalModeFormatter',
    'NormalModeFormatterError',
    'StatusLineData',
    'format_normal_statusline'
]