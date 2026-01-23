#!/usr/bin/env python3
"""
MilestoneModeFormatter - Formats FlowForge statusline in milestone mode display.

Generates milestone-focused statusline in the format:
🎯 MILESTONE: v2.0-demo [Track A] | 317/21 [▓▓▓░░] | ⏱ 00:23 | ETA: 4.5h | 🌿 feature/317 | Opus

This formatter implements the strategy pattern for statusline formatting,
providing milestone-centric status information with deadline and timeline focus.
All functions follow FlowForge Rule #26 documentation standards.

Features:
- Milestone-focused visual format with deadline emphasis
- Task progress with visual indicators (no percentage - focus on count)
- Current session time tracking
- ETA calculations based on progress and time
- Git branch information
- Model identification
- Terminal width constraints handling
- Integration with MilestoneDetector for milestone context
- Graceful fallback for missing milestone data

Author: FlowForge Team
Since: 2.1.0
"""

import json
import re
import shutil
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
from dataclasses import dataclass
from progress_bar_renderer import ProgressBarRenderer
from milestone_detector import MilestoneDetector, MilestoneData
from formatter_utils import (
    sanitize_string,
    validate_time_format,
    parse_time_to_minutes,
    detect_terminal_width,
    get_warning_indicator,
    calculate_eta,
    get_git_branch,
    MAX_BRANCH_LENGTH,
    MAX_MODEL_NAME_LENGTH
)


def detect_terminal_width(min_width: int = 50, default: int = 120) -> int:
    """
    Detect terminal width with fallback to default.
    
    Args:
        min_width: Minimum acceptable width
        default: Default width if detection fails
        
    Returns:
        int: Terminal width in columns
    """
    try:
        import shutil
        width = shutil.get_terminal_size().columns
        return max(width, min_width)
    except:
        return default


class MilestoneModeFormatterError(Exception):
    """Custom exception for formatter errors."""
    pass


@dataclass
class MilestoneStatusLineData:
    """Data structure for milestone statusline components."""
    milestone_name: str = ""
    track_name: str = ""
    tasks_completed: int = 0
    tasks_total: int = 0
    current_session_time: str = "00:00"
    eta_remaining: str = "0.0h"
    git_branch: str = "main"
    model_name: str = "Model"
    context_usage: float = 0.0


class MilestoneModeFormatter:
    """
    Formats FlowForge statusline in milestone mode display.
    
    Implements the strategy pattern for statusline formatting, generating
    milestone-focused status information with emphasis on deadlines and
    timeline information compared to normal mode.
    
    The formatter integrates with MilestoneDetector to get milestone context,
    calculates ETA based on current progress, handles terminal width constraints,
    and provides graceful fallback for missing milestone data.
    
    Example:
        >>> formatter = MilestoneModeFormatter()
        >>> data = MilestoneStatusLineData(
        ...     milestone_name="v2.0-demo", track_name="Track A",
        ...     tasks_completed=317, tasks_total=21,
        ...     current_session_time="00:23", eta_remaining="4.5h"
        ... )
        >>> formatter.format(data)
        '🎯 MILESTONE: v2.0-demo [Track A] | 317/21 [▓▓▓░░] | ⏱ 00:23 | ETA: 4.5h | 🌿 feature/317 | Opus'
    """

    EMOJI_MILESTONE = "🎯"
    EMOJI_TIME = "⏱"
    EMOJI_BRANCH = "🌿"
    MIN_TERMINAL_WIDTH = 80
    PROGRESS_BAR_WIDTH = 7
    MAX_MILESTONE_LENGTH = 40
    MAX_TRACK_LENGTH = 20
    MAX_BRANCH_LENGTH = 50
    MAX_MODEL_NAME_LENGTH = 20

    def __init__(self, terminal_width: Optional[int] = None, base_path: Optional[Path] = None):
        """
        Initialize MilestoneModeFormatter with optional terminal width and base path.
        
        Args:
            terminal_width: Terminal width in characters (auto-detected if None)
            base_path: Base directory path for FlowForge files (default: current dir)
            
        Raises:
            MilestoneModeFormatterError: If terminal width is too small
            
        Example:
            >>> formatter = MilestoneModeFormatter()
            >>> formatter_80 = MilestoneModeFormatter(terminal_width=80)
        """
        # Detect terminal width if not provided
        if terminal_width is None:
            try:
                terminal_width = shutil.get_terminal_size().columns
            except Exception:
                terminal_width = 120  # Safe default
        
        self.terminal_width = max(terminal_width, self.MIN_TERMINAL_WIDTH)
        if self.terminal_width < self.MIN_TERMINAL_WIDTH:
            raise MilestoneModeFormatterError(
                f"Terminal width {self.terminal_width} too small "
                f"(minimum: {self.MIN_TERMINAL_WIDTH})"
            )
        self.base_path = base_path or Path.cwd()
        self.progress_renderer = ProgressBarRenderer()
        self.milestone_detector = MilestoneDetector()

    def format(self, data: MilestoneStatusLineData) -> str:
        """Format complete milestone statusline."""
        if not isinstance(data, MilestoneStatusLineData):
            raise MilestoneModeFormatterError("Invalid data structure")
        sanitized_data = self._sanitize_data(data)
        components = [
            self._format_milestone_header(sanitized_data),
            self._format_task_progress(sanitized_data),
            self._format_session_time(sanitized_data),
            self._format_eta_remaining(sanitized_data),
            self._format_git_branch(sanitized_data),
            self._format_context_usage(sanitized_data),
            self._format_model_name(sanitized_data)
        ]
        statusline = " | ".join(components)
        if len(statusline) > self.terminal_width * 1.2:
            statusline = self._apply_width_constraints(statusline, components)
        return statusline

    def format_with_context(self) -> str:
        """
        Formats milestone statusline with automatically detected context.
        
        Uses MilestoneDetector to get milestone information and current
        git branch, then generates appropriate statusline data.
        
        Returns:
            str: Formatted milestone statusline with detected context
            
        Example:
            >>> formatter = MilestoneModeFormatter()
            >>> formatter.format_with_context()
            '🎯 MILESTONE: v2.0-demo [Feature] | 5/12 [▓▓░░░] | ⏱ 01:15 | ETA: 3.2h | 🌿 feature/142 | Opus'
        """
        # Get milestone context
        milestone_name, track_name = self._get_milestone_context()
        
        # Get current branch (could also extract task info from branch)
        git_branch = get_git_branch()
        
        # Get current session info (simplified for now)
        session_time = self._get_current_session_time()
        
        # Create data structure
        data = MilestoneStatusLineData(
            milestone_name=milestone_name,
            track_name=track_name,
            tasks_completed=0,  # TODO: Calculate from project state
            tasks_total=0,      # TODO: Calculate from project state
            current_session_time=session_time,
            eta_remaining="0.0h",  # TODO: Calculate based on progress
            git_branch=git_branch,
            model_name="Model"  # TODO: Detect current model
        )
        
        return self.format(data)

    def _format_milestone_header(self, data: MilestoneStatusLineData) -> str:
        """Format milestone header."""
        header = f"{self.EMOJI_MILESTONE} MILESTONE: {data.milestone_name}"
        if data.track_name:
            header += f" [{data.track_name}]"
        return header

    def _format_task_progress(self, data: MilestoneStatusLineData) -> str:
        """Format task progress with bar."""
        if data.tasks_total > 0:
            percentage = min((data.tasks_completed / data.tasks_total) * 100, 100)
            try:
                progress_bar = self.progress_renderer.render(percentage)
            except Exception:
                progress_bar = "[?????]"
        else:
            progress_bar = "[░░░░░]"
        return f"{data.tasks_completed}/{data.tasks_total} {progress_bar}"

    def _format_session_time(self, data: MilestoneStatusLineData) -> str:
        """Format session time."""
        session_time = validate_time_format(data.current_session_time)
        return f"{self.EMOJI_TIME} {session_time}"

    def _format_eta_remaining(self, data: MilestoneStatusLineData) -> str:
        """Format ETA with warnings."""
        eta_display = data.eta_remaining if data.eta_remaining else "0.0h"
        eta_warning = self._get_eta_warning_indicator(eta_display)
        base_format = f"ETA: {eta_display}"
        return f"{base_format} {eta_warning}" if eta_warning else base_format

    def _format_git_branch(self, data: MilestoneStatusLineData) -> str:
        """Format git branch."""
        branch = data.git_branch[:MAX_BRANCH_LENGTH]
        return f"{self.EMOJI_BRANCH} {branch}"

    def _format_model_name(self, data: MilestoneStatusLineData) -> str:
        """Format model name."""
        return data.model_name[:self.MAX_MODEL_NAME_LENGTH]

    def _calculate_eta(self, tasks_completed: int, tasks_total: int, session_minutes: int) -> str:
        """
        Calculates ETA based on current progress and time tracking.
        
        Args:
            tasks_completed: Number of completed tasks
            tasks_total: Total number of tasks
            session_minutes: Current session time in minutes
            
        Returns:
            str: Formatted ETA (e.g., "4.5h", "∞", "0.0h")
            
        Note:
            Uses current completion rate to estimate remaining time.
            Handles edge cases like no progress or completion.
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

    def _get_milestone_context(self) -> Tuple[str, str]:
        """
        Gets milestone context using MilestoneDetector.
        
        Returns:
            Tuple[str, str]: (milestone_name, track_name)
            
        Note:
            Handles missing milestone context gracefully.
            Uses milestone purpose as track name if available.
        """
        try:
            milestone_data = self.milestone_detector.detect_milestone_mode()
            if milestone_data:
                milestone_name = milestone_data.name
                # Use purpose as track name, or extract from branch pattern
                track_name = milestone_data.purpose or self._extract_track_from_milestone(milestone_data)
                return milestone_name, track_name or ""
        except Exception:
            # Graceful fallback on any error
            pass
        
        return "", ""

    def _extract_track_from_milestone(self, milestone_data: MilestoneData) -> str:
        """
        Extracts track information from milestone data.
        
        Args:
            milestone_data: MilestoneData from detector
            
        Returns:
            str: Track name extracted from milestone metadata
        """
        # Try to extract meaningful track info from branch or other metadata
        if milestone_data.branch:
            # Extract track from branch name patterns
            if "track" in milestone_data.branch.lower():
                parts = milestone_data.branch.split("/")
                for part in parts:
                    if "track" in part.lower():
                        return part.title()
        
        # Default track designation
        return "Feature" if milestone_data.source == "worktree-config" else ""

    def _get_current_session_time(self) -> str:
        """
        Gets current session elapsed time.
        
        Returns:
            str: Session time in HH:MM format
            
        Note:
            Simplified implementation - in real usage would integrate
            with FlowForge session tracking.
        """
        # Integrate with FlowForge session tracking
        try:
            from flowforge_time_integration import FlowForgeTimeIntegration
            integration = FlowForgeTimeIntegration(base_path=self.base_path)
            session_data = integration.get_session_time_data()
            return session_data.elapsed_time
        except Exception:
            return "00:00"
    
    def _calculate_milestone_data(self) -> MilestoneStatusLineData:
        """
        Calculates complete milestone data from project state.
        
        Returns:
            MilestoneStatusLineData: Complete milestone data with all fields populated
            
        Example:
            >>> formatter = MilestoneModeFormatter()
            >>> data = formatter._calculate_milestone_data()
            >>> data.milestone_name
            'v2.0-demo'
        """
        # Get milestone context
        milestone_name, track_name = self._get_milestone_context()
        
        # Get current branch
        git_branch = get_git_branch()
        
        # Get current session info
        session_time = self._get_current_session_time()
        
        # Get task counts
        tasks_completed = self._get_tasks_completed()
        tasks_total = self._get_tasks_total()
        
        # Calculate ETA
        eta_remaining = self._calculate_eta()
        
        # Detect model
        model_name = self._detect_current_model()
        
        # Create data structure
        return MilestoneStatusLineData(
            milestone_name=milestone_name,
            track_name=track_name,
            tasks_completed=tasks_completed,
            tasks_total=tasks_total,
            current_session_time=session_time,
            eta_remaining=eta_remaining,
            git_branch=git_branch,
            model_name=model_name
        )

    def _sanitize_data(self, data: MilestoneStatusLineData) -> MilestoneStatusLineData:
        """Sanitize input data for security."""
        return MilestoneStatusLineData(
            milestone_name=sanitize_string(data.milestone_name, self.MAX_MILESTONE_LENGTH, ""),
            track_name=sanitize_string(data.track_name, self.MAX_TRACK_LENGTH, ""),
            tasks_completed=max(0, int(data.tasks_completed or 0)),
            tasks_total=max(0, int(data.tasks_total or 0)),
            current_session_time=validate_time_format(data.current_session_time),
            eta_remaining=sanitize_string(data.eta_remaining, 15, "0.0h"),
            git_branch=sanitize_string(data.git_branch, MAX_BRANCH_LENGTH, "main"),
            model_name=sanitize_string(data.model_name or "Model", MAX_MODEL_NAME_LENGTH, "Model"),
            context_usage=max(0, min(100, float(data.context_usage or 0)))
        )
    
    def _format_context_usage(self, data: MilestoneStatusLineData) -> str:
        """Format context usage component."""
        try:
            pct = max(0, min(100, float(data.context_usage or 0)))
            bar = self.progress_renderer.render(pct)
            warn = get_warning_indicator(pct)
            base = f"🧠 {pct:.0f}% {bar}"
            return f"{base} {warn}" if warn else base
        except Exception:
            return "🧠 0% [░░░░░]"
    
    def _calculate_intelligent_eta(self, data: MilestoneStatusLineData) -> str:
        """
        Calculates intelligent ETA based on current progress and session data.
        
        Args:
            data: MilestoneStatusLineData with progress information
            
        Returns:
            str: Calculated ETA string or empty string if calculation fails
        """
        try:
            if (data.tasks_completed > 0 and data.tasks_total > 0 and 
                data.current_session_time and data.current_session_time != "00:00"):
                
                # Parse session time to minutes
                session_minutes = parse_time_to_minutes(data.current_session_time)
                
                if session_minutes > 0:
                    # Calculate using shared utility
                    return calculate_eta(data.tasks_completed, data.tasks_total, session_minutes)
                    
        except Exception:
            pass
        
        return ""  # Return empty string if calculation fails
    
    def _get_eta_warning_indicator(self, eta_str: str) -> str:
        """
        Gets warning indicator for ETA estimates.
        
        Args:
            eta_str: ETA string (e.g., "4.5h", "∞")
            
        Returns:
            str: Warning indicator emoji or empty string
        """
        try:
            if eta_str == "∞":
                return "🚨"  # Infinite ETA is critical
            
            # Extract hours from ETA
            import re
            match = re.search(r'(\d+(?:\.\d+)?)h', eta_str)
            if match:
                hours = float(match.group(1))
                if hours > 8:  # More than 8 hours remaining
                    return "⚠️"  # Long ETA warning
            return ""
        except Exception:
            return ""

    def _apply_width_constraints(self, statusline: str, components: list) -> str:
        """Apply terminal width constraints."""
        if len(statusline) <= self.terminal_width:
            return statusline
        
        # Priority: milestone, ETA, model (essential)
        essential = [0, 3, 6]  # milestone, ETA, model indices
        optional = [1, 2, 4, 5]  # tasks, time, branch, context
        
        # Try essential components only
        essential_comps = [components[i] for i in essential if i < len(components)]
        result = " | ".join(essential_comps)
        
        if len(result) > self.terminal_width:
            # Extreme case: truncate milestone
            if len(essential_comps) >= 3:
                milestone, eta, model = essential_comps[0], essential_comps[1], essential_comps[2]
                fixed_len = len(eta) + len(model) + 6  # 6 = " | " * 2
                avail = self.terminal_width - fixed_len
                if avail > 20:
                    return f"{milestone[:avail-1]}- | {eta} | {model}"
            return result[:self.terminal_width]
        
        # Add optional components if space allows
        for idx in optional:
            if idx < len(components):
                test = result + " | " + components[idx]
                if len(test) <= self.terminal_width:
                    result = test
                else:
                    break
        
        return result

    def get_component_info(self):
        """Get component display names."""
        return {'🎯': 'Milestone', 'Tasks': 'Progress', '⏱': 'Time', 'ETA': 'ETA', '🌿': 'Branch', 'Model': 'Model'}
    
    def _detect_current_model(self) -> str:
        """Detect current model."""
        return "Model"

def format_milestone_statusline(**kw):
    """Convenience function for formatting."""
    return MilestoneModeFormatter().format(MilestoneStatusLineData(**kw))

__all__ = [
    'MilestoneModeFormatter',
    'MilestoneModeFormatterError', 
    'MilestoneStatusLineData',
    'format_milestone_statusline'
]
