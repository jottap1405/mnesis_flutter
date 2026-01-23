#!/usr/bin/env python3
"""
Data models for FlowForge time tracking integration.
Extracted to reduce main module size (Rule #24).
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


class FlowForgeTimeError(Exception):
    """Custom exception for FlowForge time integration errors."""
    pass


@dataclass
class SessionTimeData:
    """
    Session time information data structure.
    
    Attributes:
        elapsed_time: Current session elapsed time (HH:MM format)
        planned_time: Planned session time (H:MM format)
        remaining_budget: Remaining time budget
        session_start: Session start timestamp
        is_active: Whether timer is currently active
        overtime_minutes: Minutes over planned time
        budget_warning: Budget warning level
        efficiency_score: Time efficiency score (0-100)
    """
    elapsed_time: str = "00:00"
    planned_time: str = "0:00"
    remaining_budget: str = "0:00h"
    session_start: Optional[datetime] = None
    is_active: bool = False
    overtime_minutes: int = 0
    budget_warning: str = 'none'
    efficiency_score: float = 0.0


@dataclass
class MilestoneTimeData:
    """
    Milestone time information data structure.
    
    Attributes:
        eta_remaining: Estimated time to completion
        current_session_time: Current session time (HH:MM)
        progress_rate: Tasks completed per hour
        estimated_completion: Estimated completion datetime
        eta_warning: ETA warning level
        time_efficiency: Time efficiency for milestone
    """
    eta_remaining: str = "0.0h"
    current_session_time: str = "00:00"
    progress_rate: float = 0.0
    estimated_completion: Optional[datetime] = None
    eta_warning: str = 'none'
    time_efficiency: float = 0.0