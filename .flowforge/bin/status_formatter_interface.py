#!/usr/bin/env python3
"""
StatusFormatter Interface - Abstract base class for FlowForge statusline formatting strategies.

Defines the contract for statusline formatters implementing the strategy pattern.
This interface ensures consistent behavior between NormalModeFormatter and
MilestoneModeFormatter while allowing specialized formatting logic.

All implementations must follow FlowForge Rule #26 documentation standards.

Author: FlowForge Team
Since: 2.1.0
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, Optional
from dataclasses import dataclass


@dataclass
class FormattingContext:
    """
    Context data structure for statusline formatting.
    
    Contains all data needed by formatters to generate statuslines,
    allowing the main StatusLine class to remain agnostic to formatting details.
    
    Attributes:
        model_name: Model name (e.g., "Opus")
        git_branch: Current git branch name
        issue_number: Extracted issue number from branch (optional)
        milestone_data: Milestone-related information (optional)
        task_data: Task progress information (optional) 
        timer_data: Time tracking information (optional)
        context_usage: Context usage percentage (0-100)
        terminal_width: Terminal width for formatting constraints
    """
    model_name: str = "Model"
    git_branch: str = "main"
    issue_number: Optional[str] = None
    milestone_data: Optional[Dict[str, Any]] = None
    task_data: Optional[Dict[str, Any]] = None
    timer_data: Optional[Dict[str, Any]] = None
    context_usage: float = 0.0
    terminal_width: int = 120


class StatusFormatterInterface(ABC):
    """
    Abstract base class defining the interface for statusline formatters.
    
    Implements the strategy pattern allowing different formatting approaches
    (normal mode vs milestone mode) while maintaining a consistent interface.
    
    Each formatter receives a FormattingContext containing all necessary
    data and returns a fully formatted statusline string.
    
    Subclasses must implement:
    - format(context): Main formatting method
    - get_component_info(): Component documentation
    
    Optional implementations:
    - format_compact(context): Compact format for narrow terminals
    - validate_context(context): Context validation
    """
    
    @abstractmethod
    def format(self, context: FormattingContext) -> str:
        """
        Formats complete statusline using provided context data.
        
        Args:
            context: FormattingContext containing all statusline data
            
        Returns:
            str: Formatted statusline string
            
        Raises:
            FormatterError: If formatting fails or context is invalid
        """
        pass
    
    @abstractmethod
    def get_component_info(self) -> Dict[str, str]:
        """
        Returns information about statusline components and their meanings.
        
        Returns:
            Dict[str, str]: Component descriptions with emoji indicators
        """
        pass
    
    def format_compact(self, context: FormattingContext) -> str:
        """
        Formats compact statusline for narrow terminals (optional).
        
        Args:
            context: FormattingContext containing statusline data
            
        Returns:
            str: Compact formatted statusline string
            
        Note:
            Default implementation falls back to regular format().
            Subclasses can override for specialized compact formatting.
        """
        return self.format(context)
    
    def validate_context(self, context: FormattingContext) -> bool:
        """
        Validates formatting context for completeness (optional).
        
        Args:
            context: FormattingContext to validate
            
        Returns:
            bool: True if context is valid, False otherwise
            
        Note:
            Default implementation always returns True.
            Subclasses can override for specialized validation.
        """
        return isinstance(context, FormattingContext)
    
    def get_formatter_name(self) -> str:
        """
        Returns the formatter name for debugging and logging.
        
        Returns:
            str: Formatter identification string
        """
        return self.__class__.__name__


class FormatterError(Exception):
    """
    Base exception for statusline formatting errors.
    
    Raised when:
    - Invalid formatting context
    - Terminal width constraints cannot be met
    - Required formatters are unavailable
    - Data validation fails
    """
    pass


# Type aliases for convenience
StatusFormatter = StatusFormatterInterface