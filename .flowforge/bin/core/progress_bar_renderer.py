#!/usr/bin/env python3
"""
ProgressBarRenderer - 5-character visual progress indicators.
Generates progress bars in format: [▓▓▓░░]

This module provides comprehensive progress visualization for FlowForge,
supporting task completion ratios, time-based progress, and multiple visual styles.
All functions follow FlowForge Rule #26 documentation standards.

Features:
- Exact 5-character progress bars with brackets
- Multiple visual styles (Unicode, ASCII)
- Task completion ratio calculations
- Time-based progress tracking
- Comprehensive input validation
- Thread-safe operations
- Performance optimized (< 1ms per render)

Author: FlowForge Team
Since: 2.0.0
"""

import threading
from enum import Enum
from typing import Union, Optional
from dataclasses import dataclass


class ProgressBarError(Exception):
    """
    Custom exception for ProgressBarRenderer errors.
    
    Raised when:
    - Invalid input values (negative, None, non-numeric)
    - Division by zero in ratio calculations
    - Invalid style specifications
    """
    pass


class ProgressBarStyle(Enum):
    """
    Visual styles for progress bar rendering.
    
    DEFAULT: Uses ▓ for filled, ░ for empty (requirement specification)
    ASCII: Uses # for filled, . for empty (terminal compatibility)
    UNICODE_FILLED: Uses █ for filled, ░ for empty (solid blocks)
    """
    DEFAULT = "default"
    ASCII = "ascii"
    UNICODE_FILLED = "unicode_filled"


@dataclass
class ProgressBarConfig:
    """
    Configuration for progress bar rendering.
    
    Attributes:
        filled_char: Character for completed progress
        empty_char: Character for remaining progress
        bracket_left: Left bracket character
        bracket_right: Right bracket character
        bar_length: Number of progress characters (fixed at 5)
    """
    filled_char: str
    empty_char: str
    bracket_left: str = "["
    bracket_right: str = "]"
    bar_length: int = 5


class ProgressBarRenderer:
    """
    Renders 5-character visual progress indicators.
    
    Generates progress bars in the format [▓▓▓░░] for various progress types:
    - Percentage-based progress (0-100%)
    - Task completion ratios (completed/total)
    - Time-based progress (elapsed/planned)
    
    Thread-safe and performance optimized for FlowForge integration.
    
    Example:
        >>> renderer = ProgressBarRenderer()
        >>> renderer.render(60)
        '[▓▓▓░░]'
        >>> renderer.render_ratio(3, 5)
        '[▓▓▓░░]'
    """

    # Class-level lock for thread safety
    _lock = threading.Lock()
    
    # Style configurations
    _STYLE_CONFIGS = {
        ProgressBarStyle.DEFAULT: ProgressBarConfig(
            filled_char="▓",
            empty_char="░"
        ),
        ProgressBarStyle.ASCII: ProgressBarConfig(
            filled_char="#",
            empty_char="."
        ),
        ProgressBarStyle.UNICODE_FILLED: ProgressBarConfig(
            filled_char="█",
            empty_char="░"
        )
    }

    def __init__(self, style: ProgressBarStyle = ProgressBarStyle.DEFAULT):
        """
        Initialize ProgressBarRenderer with specified style.
        
        Args:
            style: Visual style for progress bars (default: ProgressBarStyle.DEFAULT)
            
        Raises:
            ProgressBarError: If style is not supported
            
        Example:
            >>> renderer = ProgressBarRenderer()
            >>> ascii_renderer = ProgressBarRenderer(ProgressBarStyle.ASCII)
        """
        if style not in self._STYLE_CONFIGS:
            raise ProgressBarError(f"Unsupported style: {style}")
        
        self._config = self._STYLE_CONFIGS[style]

    def render(self, percentage: Union[int, float]) -> str:
        """
        Renders progress bar for given percentage.
        
        Args:
            percentage: Progress percentage (0-100). Values > 100 are capped at 100.
            
        Returns:
            str: 7-character progress bar string in format [▓▓▓░░]
            
        Raises:
            ProgressBarError: If percentage is negative, None, or non-numeric
            
        Example:
            >>> renderer = ProgressBarRenderer()
            >>> renderer.render(60)
            '[▓▓▓░░]'
            >>> renderer.render(0)
            '[░░░░░]'
            >>> renderer.render(100)
            '[▓▓▓▓▓]'
        """
        # Rule #8: Comprehensive input validation
        if percentage is None:
            raise ProgressBarError("Percentage cannot be None")
        
        try:
            percentage = float(percentage)
        except (TypeError, ValueError):
            raise ProgressBarError(f"Percentage must be numeric, got: {type(percentage).__name__}")
        
        if percentage < 0:
            raise ProgressBarError("Percentage cannot be negative")
        
        # Cap at 100% for values over 100
        if percentage > 100:
            percentage = 100
        
        # Calculate filled segments (0-5)
        # Rule #27: Explain complex calculation logic
        # 5 segments means each segment represents 20%
        # Round to nearest segment: 0-10% = 0, 10-30% = 1, 30-50% = 2, 50-70% = 3, 70-90% = 4, 90-100% = 5
        filled_segments = round(percentage / 20.0)
        
        # Ensure within bounds (0-5)
        filled_segments = max(0, min(5, filled_segments))
        
        return self._render_bar(filled_segments)

    def render_ratio(self, completed: Union[int, float], total: Union[int, float]) -> str:
        """
        Renders progress bar for completion ratio.
        
        Args:
            completed: Number of completed items
            total: Total number of items
            
        Returns:
            str: 7-character progress bar string in format [▓▓▓░░]
            
        Raises:
            ProgressBarError: If completed/total are invalid or total is zero
            
        Example:
            >>> renderer = ProgressBarRenderer()
            >>> renderer.render_ratio(3, 5)
            '[▓▓▓░░]'
            >>> renderer.render_ratio(317, 21)  # Handles overflow
            '[▓▓▓▓▓]'
        """
        # Rule #8: Comprehensive input validation
        if completed is None or total is None:
            raise ProgressBarError("Completed and total cannot be None")
        
        try:
            completed = float(completed)
            total = float(total)
        except (TypeError, ValueError):
            raise ProgressBarError("Completed and total must be numeric")
        
        if completed < 0:
            raise ProgressBarError("Completed cannot be negative")
        
        if total <= 0:
            raise ProgressBarError("Total must be greater than zero")
        
        # Calculate percentage and render
        percentage = (completed / total) * 100.0
        return self.render(percentage)

    def render_time(self, elapsed: Union[int, float], planned: Union[int, float]) -> str:
        """
        Renders progress bar for time-based progress.
        
        Args:
            elapsed: Time elapsed (any unit: minutes, hours, seconds)
            planned: Planned total time (same unit as elapsed)
            
        Returns:
            str: 7-character progress bar string in format [▓▓▓░░]
            
        Raises:
            ProgressBarError: If elapsed/planned are invalid or planned is zero
            
        Example:
            >>> renderer = ProgressBarRenderer()
            >>> renderer.render_time(23, 30)  # 23 of 30 minutes
            '[▓▓▓▓░]'
            >>> renderer.render_time(2.5, 4.0)  # 2.5 of 4.0 hours
            '[▓▓▓░░]'
        """
        # Rule #8: Comprehensive input validation
        if elapsed is None or planned is None:
            raise ProgressBarError("Elapsed and planned cannot be None")
        
        try:
            elapsed = float(elapsed)
            planned = float(planned)
        except (TypeError, ValueError):
            raise ProgressBarError("Elapsed and planned must be numeric")
        
        if elapsed < 0:
            raise ProgressBarError("Elapsed time cannot be negative")
        
        if planned <= 0:
            raise ProgressBarError("Planned time must be greater than zero")
        
        # Calculate percentage and render
        percentage = (elapsed / planned) * 100.0
        return self.render(percentage)

    def _render_bar(self, filled_segments: int) -> str:
        """
        Renders the actual progress bar string.
        
        Args:
            filled_segments: Number of filled segments (0-5)
            
        Returns:
            str: Progress bar string with brackets
            
        Note:
            This is a private method for internal bar rendering logic.
            Thread-safe through class-level locking.
        """
        # Rule #8: Thread safety through locking
        with self._lock:
            # Rule #27: Clear logic explanation
            # Create 5-character bar: filled_segments of filled_char + remaining of empty_char
            empty_segments = self._config.bar_length - filled_segments
            
            bar_content = (
                self._config.filled_char * filled_segments +
                self._config.empty_char * empty_segments
            )
            
            return f"{self._config.bracket_left}{bar_content}{self._config.bracket_right}"

    def get_style_info(self) -> dict:
        """
        Returns information about current style configuration.
        
        Returns:
            dict: Style configuration details
            
        Example:
            >>> renderer = ProgressBarRenderer()
            >>> info = renderer.get_style_info()
            >>> info['filled_char']
            '▓'
        """
        return {
            'filled_char': self._config.filled_char,
            'empty_char': self._config.empty_char,
            'bracket_left': self._config.bracket_left,
            'bracket_right': self._config.bracket_right,
            'bar_length': self._config.bar_length
        }

    @classmethod
    def get_available_styles(cls) -> list:
        """
        Returns list of available progress bar styles.
        
        Returns:
            list: Available ProgressBarStyle enum values
            
        Example:
            >>> ProgressBarRenderer.get_available_styles()
            [<ProgressBarStyle.DEFAULT: 'default'>, ...]
        """
        return list(cls._STYLE_CONFIGS.keys())


# Convenience functions for quick usage
def render_progress(percentage: Union[int, float]) -> str:
    """
    Quick function to render progress bar with default style.
    
    Args:
        percentage: Progress percentage (0-100)
        
    Returns:
        str: Progress bar string in format [▓▓▓░░]
        
    Example:
        >>> render_progress(75)
        '[▓▓▓▓░]'
    """
    renderer = ProgressBarRenderer()
    return renderer.render(percentage)


def render_task_progress(completed: Union[int, float], total: Union[int, float]) -> str:
    """
    Quick function to render task completion progress.
    
    Args:
        completed: Number of completed tasks
        total: Total number of tasks
        
    Returns:
        str: Progress bar string in format [▓▓▓░░]
        
    Example:
        >>> render_task_progress(7, 10)
        '[▓▓▓▓░]'
    """
    renderer = ProgressBarRenderer()
    return renderer.render_ratio(completed, total)


def render_time_progress(elapsed: Union[int, float], planned: Union[int, float]) -> str:
    """
    Quick function to render time-based progress.
    
    Args:
        elapsed: Time elapsed
        planned: Planned total time
        
    Returns:
        str: Progress bar string in format [▓▓▓░░]
        
    Example:
        >>> render_time_progress(45, 60)  # 45 of 60 minutes
        '[▓▓▓▓░]'
    """
    renderer = ProgressBarRenderer()
    return renderer.render_time(elapsed, planned)


# Rule #33: No AI references in module metadata
__all__ = [
    'ProgressBarRenderer',
    'ProgressBarStyle', 
    'ProgressBarError',
    'ProgressBarConfig',
    'render_progress',
    'render_task_progress', 
    'render_time_progress'
]

__version__ = "2.0.0"
__author__ = "FlowForge Team"