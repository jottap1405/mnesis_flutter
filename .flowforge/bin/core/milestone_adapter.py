#!/usr/bin/env python3
"""
MilestoneModeAdapter - Adapter for milestone statusline with FlowForge session data.

Provides integration between MilestoneModeFormatter and FlowForge session data,
automatically calculating milestone progress and estimates.

Author: FlowForge Team
Since: 2.1.0
"""

import json
from pathlib import Path
from typing import Dict, Any, Optional
from dataclasses import dataclass

from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData
from milestone_detector import MilestoneDetector, MilestoneData
from formatter_utils import get_git_branch, calculate_eta, parse_time_to_minutes


class MilestoneModeAdapter:
    """
    Adapter for milestone statusline with FlowForge session data.
    
    Integrates MilestoneModeFormatter with FlowForge session tracking,
    milestone detection, and automatic progress calculation.
    
    Example:
        >>> adapter = MilestoneModeAdapter()
        >>> statusline = adapter.generate_statusline()
        '🎯 MILESTONE: v2.0-demo [Track A] | 5/12 | ⏱ 01:15 | ETA: 3.2h | ...'
    """
    
    def __init__(self, base_path: Optional[Path] = None):
        """
        Initialize milestone adapter.
        
        Args:
            base_path: Base directory for FlowForge files (default: current)
        """
        self.base_path = base_path or Path.cwd()
        self.formatter = MilestoneModeFormatter()
        self.milestone_detector = MilestoneDetector()
        
    def generate_statusline(self) -> str:
        """
        Generate complete milestone statusline with current data.
        
        Returns:
            str: Formatted milestone statusline
            
        Example:
            >>> adapter = MilestoneModeAdapter()
            >>> adapter.generate_statusline()
            '🎯 MILESTONE: v2.0-demo [Track A] | 5/12 | ⏱ 01:15 | ...'
        """
        data = self._collect_statusline_data()
        return self.formatter.format(data)
    
    def _collect_statusline_data(self) -> MilestoneStatusLineData:
        """
        Collect all statusline data from various sources.
        
        Returns:
            MilestoneStatusLineData: Complete data for formatting
        """
        # Get milestone info
        milestone_name, track_name = self._get_milestone_info()
        
        # Get session data
        session_time = self._get_session_time()
        
        # Get task progress
        tasks_completed, tasks_total = self._get_task_progress()
        
        # Calculate ETA
        eta = self._calculate_intelligent_eta(
            tasks_completed, tasks_total, session_time
        )
        
        # Get git info
        branch = get_git_branch()
        
        # Get model info
        model = self._detect_model()
        
        # Get context usage
        context_usage = self._get_context_usage()
        
        return MilestoneStatusLineData(
            milestone_name=milestone_name,
            track_name=track_name,
            tasks_completed=tasks_completed,
            tasks_total=tasks_total,
            current_session_time=session_time,
            eta_remaining=eta,
            git_branch=branch,
            model_name=model,
            context_usage=context_usage
        )
    
    def _get_milestone_info(self) -> tuple[str, str]:
        """
        Get milestone name and track from detector.
        
        Returns:
            tuple: (milestone_name, track_name)
        """
        try:
            milestone_data = self.milestone_detector.detect_milestone_mode()
            if milestone_data:
                return milestone_data.name, milestone_data.purpose or ""
        except Exception:
            pass
        return "", ""
    
    def _get_session_time(self) -> str:
        """
        Get current session elapsed time.
        
        Returns:
            str: Session time in HH:MM format
        """
        try:
            session_file = self.base_path / ".flowforge" / "local" / "session.json"
            if session_file.exists():
                with open(session_file) as f:
                    data = json.load(f)
                    if "elapsed_time" in data:
                        return data["elapsed_time"]
        except Exception:
            pass
        return "00:00"
    
    def _get_task_progress(self) -> tuple[int, int]:
        """
        Get task completion progress.
        
        Returns:
            tuple: (tasks_completed, tasks_total)
        """
        try:
            tasks_file = self.base_path / ".flowforge" / "tasks.json"
            if tasks_file.exists():
                with open(tasks_file) as f:
                    data = json.load(f)
                    if "milestones" in data:
                        # Find active milestone
                        for milestone in data["milestones"]:
                            if milestone.get("active"):
                                completed = milestone.get("tasks_completed", 0)
                                total = milestone.get("tasks_total", 0)
                                return completed, total
        except Exception:
            pass
        return 0, 0
    
    def _calculate_intelligent_eta(self, completed: int, total: int, session_time: str) -> str:
        """
        Calculate ETA based on progress and time.
        
        Args:
            completed: Tasks completed
            total: Total tasks
            session_time: Current session time string
            
        Returns:
            str: ETA string
        """
        try:
            if completed > 0 and total > 0 and session_time != "00:00":
                minutes = parse_time_to_minutes(session_time)
                if minutes > 0:
                    return calculate_eta(completed, total, minutes)
        except Exception:
            pass
        return "0.0h"
    
    def _detect_model(self) -> str:
        """
        Detect current AI model.
        
        Returns:
            str: Model name
        """
        # Simplified - would integrate with actual model detection
        return "Opus"
    
    def _get_context_usage(self) -> float:
        """
        Get current context usage percentage.
        
        Returns:
            float: Context usage (0-100)
        """
        try:
            # Would integrate with actual context tracking
            context_file = self.base_path / ".claude" / ".flowforge" / ".statusline-cache.json"
            if context_file.exists():
                with open(context_file) as f:
                    data = json.load(f)
                    return data.get("context_usage", 0.0)
        except Exception:
            pass
        return 0.0


__all__ = ['MilestoneModeAdapter']