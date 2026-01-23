#!/usr/bin/env python3
"""
Shared formatter utility functions.

Provides common utility functions used by both NormalModeFormatter and
MilestoneModeFormatter to reduce code duplication and maintain consistency.

Following FlowForge Rule #24: File under 700 lines
Following FlowForge Rule #26: Full documentation
Following FlowForge Rule #33: No AI references
"""

import re
import shutil
from typing import Any, Dict, List, Optional


def sanitize_string(value: Any, max_length: int, default: str) -> str:
    """
    Sanitizes string input with length and content validation.
    
    Args:
        value: Input value to sanitize
        max_length: Maximum allowed length
        default: Default value if input is invalid
        
    Returns:
        str: Sanitized string
        
    Example:
        >>> sanitize_string("test<script>", 10, "default")
        'test'
        >>> sanitize_string(None, 10, "default")
        'default'
    """
    if value is None or (isinstance(value, str) and not value):
        return default
    
    # Convert to string if not already
    str_value = str(value)
    
    # Remove potentially harmful characters (keep alphanumeric, dash, dot, slash, colon, underscore, space, brackets)
    sanitized = re.sub(r'[^\w\-\.\/\:\_\s\[\]]', '', str_value)
    
    if not sanitized:
        return default
    
    # Apply length limit
    return sanitized[:max_length]


def validate_time_format(time_str: Any) -> str:
    """
    Validates and normalizes time format strings.
    
    Args:
        time_str: Time string to validate (e.g., "00:23", "1:30")
        
    Returns:
        str: Validated time string or "00:00" if invalid
        
    Example:
        >>> validate_time_format("12:30")
        '12:30'
        >>> validate_time_format("25:00")
        '00:00'
    """
    if not isinstance(time_str, str):
        return "00:00"
    
    # Basic time format validation with range checking
    match = re.match(r'^(\d{1,2}):(\d{2})$', time_str)
    if match:
        hours = int(match.group(1))
        minutes = int(match.group(2))
        
        # Validate ranges: hours 0-23, minutes 0-59
        if 0 <= hours <= 23 and 0 <= minutes <= 59:
            return time_str
    
    # Fallback for invalid format
    return "00:00"


def parse_time_to_minutes(time_str: Any) -> int:
    """
    Parses time string to total minutes.
    
    Args:
        time_str: Time string in format "HH:MM" or "H:MM"
        
    Returns:
        int: Total minutes (0 if parsing fails)
        
    Example:
        >>> parse_time_to_minutes("1:30")
        90
        >>> parse_time_to_minutes("invalid")
        0
    """
    if not isinstance(time_str, str):
        return 0
    
    try:
        match = re.match(r'^(\d{1,2}):(\d{2})$', time_str)
        if match:
            hours = int(match.group(1))
            minutes = int(match.group(2))
            if 0 <= hours <= 23 and 0 <= minutes <= 59:
                return hours * 60 + minutes
    except Exception:
        pass
    
    return 0


def detect_terminal_width(min_width: int, default_width: int = 100) -> int:
    """
    Detects current terminal width.
    
    Args:
        min_width: Minimum acceptable width
        default_width: Default width if detection fails
        
    Returns:
        int: Terminal width in characters
        
    Example:
        >>> width = detect_terminal_width(80, 100)
        >>> width >= 80
        True
    """
    try:
        width = shutil.get_terminal_size().columns
        return max(width, min_width)
    except Exception:
        return default_width


def get_warning_indicator(percentage: float) -> str:
    """
    Gets warning indicator for percentage levels.
    
    Args:
        percentage: Percentage value (0-100)
        
    Returns:
        str: Warning indicator emoji or empty string
        
    Example:
        >>> get_warning_indicator(50)
        ''
        >>> get_warning_indicator(85)
        '⚠️'
        >>> get_warning_indicator(98)
        '🚨'
    """
    if percentage >= 95:
        return "🚨"  # Critical warning
    elif percentage >= 80:
        return "⚠️"  # Moderate warning
    else:
        return ""  # No warning


def calculate_eta(tasks_completed: int, tasks_total: int, session_minutes: int) -> str:
    """
    Calculates ETA based on current progress and time tracking.
    
    Args:
        tasks_completed: Number of completed tasks
        tasks_total: Total number of tasks
        session_minutes: Current session time in minutes
        
    Returns:
        str: Formatted ETA (e.g., "4.5h", "∞", "0.0h")
        
    Example:
        >>> calculate_eta(5, 10, 30)
        '0.5h'
        >>> calculate_eta(0, 10, 30)
        '∞'
    """
    # Handle edge cases
    if tasks_total == 0:
        return "0.0h"
    
    if tasks_completed == 0 or session_minutes == 0:
        return "∞"
    
    if tasks_completed >= tasks_total:
        return "0.0h"
    
    # Calculate average time per task
    minutes_per_task = session_minutes / tasks_completed
    
    # Calculate remaining tasks
    remaining_tasks = tasks_total - tasks_completed
    
    # Calculate ETA in minutes
    eta_minutes = remaining_tasks * minutes_per_task
    
    # Convert to hours with 1 decimal place
    eta_hours = eta_minutes / 60
    
    return f"{eta_hours:.1f}h"


def get_component_priority(mode: str) -> Dict[str, List[int]]:
    """
    Gets component priority for different display modes.
    
    Args:
        mode: Display mode ("normal" or "milestone")
        
    Returns:
        dict: Essential and optional component indices
        
    Example:
        >>> priority = get_component_priority("normal")
        >>> priority["essential"]
        [0, 1, 6]
    """
    if mode == "milestone":
        return {
            "essential": [0, 3, 5],  # milestone header, ETA, model
            "optional": [1, 4, 2]    # tasks, branch, time
        }
    else:  # normal mode
        return {
            "essential": [0, 1, 5, 6],  # version, tasks, context, model
            "optional": [2, 3, 4] # time, budget, branch
        }


def truncate_to_width(components: List[str], max_width: int, mode: str) -> str:
    """
    Truncates statusline components to fit terminal width.
    
    Args:
        components: List of statusline components
        max_width: Maximum width in characters
        mode: Display mode for priority selection
        
    Returns:
        str: Truncated statusline that fits width
        
    Example:
        >>> components = ["⚩ FF v2.0", "📋 10/20", "Opus"]
        >>> truncate_to_width(components, 30, "normal")
        '⚩ FF v2.0 | Opus'
    """
    priority = get_component_priority(mode)
    separator = " | "
    
    # Start with essential components
    essential_components = [components[i] for i in priority["essential"] if i < len(components)]
    result = separator.join(essential_components)
    
    # If even essentials don't fit, truncate the first component
    if len(result) > max_width:
        if len(essential_components) >= 2:
            # Keep last essential component, truncate first
            last_component = essential_components[-1]
            available_space = max_width - len(last_component) - len(separator)
            
            if available_space > 10:  # Minimum meaningful length
                truncated_first = essential_components[0][:available_space - 1] + "-"
                return f"{truncated_first}{separator}{last_component}"
        
        # Ultra extreme case - return truncated string
        return result[:max_width]
    
    # Add optional components if space allows
    for idx in priority["optional"]:
        if idx < len(components):
            test_result = result + separator + components[idx]
            if len(test_result) <= max_width:
                result = test_result
            else:
                break  # Stop adding if we exceed width
    
    return result


def format_percentage_with_bar(percentage: float, renderer) -> str:
    """
    Formats percentage with progress bar visualization.
    
    Args:
        percentage: Percentage value (0-100)
        renderer: ProgressBarRenderer instance
        
    Returns:
        str: Formatted percentage with progress bar
        
    Example:
        >>> format_percentage_with_bar(75, renderer)
        '75% [▓▓▓▓░]'
    """
    try:
        # Ensure percentage is in valid range
        safe_percentage = max(0, min(100, float(percentage)))
        progress_bar = renderer.render(safe_percentage)
        return f"{safe_percentage:.0f}% {progress_bar}"
    except Exception:
        return "0% [░░░░░]"


def get_git_branch() -> str:
    """
    Gets current git branch name.
    
    Returns:
        str: Current git branch name or "main" as fallback
        
    Example:
        >>> branch = get_git_branch()
        >>> isinstance(branch, str)
        True
    """
    import subprocess
    try:
        result = subprocess.run(
            ['git', 'branch', '--show-current'],
            capture_output=True,
            text=True,
            timeout=2
        )
        if result.returncode == 0:
            return result.stdout.strip() or "main"
    except Exception:
        pass
    
    return "main"


# Security constants
MAX_STRING_LENGTH = 100
MAX_BRANCH_LENGTH = 50
MAX_MODEL_NAME_LENGTH = 20
MAX_VERSION_LENGTH = 20


# Rule #33: No AI references in module metadata
__all__ = [
    'sanitize_string',
    'validate_time_format',
    'parse_time_to_minutes',
    'detect_terminal_width',
    'get_warning_indicator',
    'calculate_eta',
    'get_component_priority',
    'truncate_to_width',
    'format_percentage_with_bar',
    'get_git_branch',
    'MAX_STRING_LENGTH',
    'MAX_BRANCH_LENGTH',
    'MAX_MODEL_NAME_LENGTH',
    'MAX_VERSION_LENGTH'
]

__version__ = "2.1.0"
__author__ = "FlowForge Team"