#!/usr/bin/env python3
"""
FlowForgeTimeIntegration - Time tracking integration with FlowForge.

Integrates with FlowForge time tracking to provide session timing,
budget calculations, and ETA estimates for statusline formatters.

Author: FlowForge Team
Since: 2.1.0
"""

import json
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, Any, Optional, Tuple
from functools import lru_cache

# Import data models from separate file (Rule #24)
from time_data_models import (
    FlowForgeTimeError,
    SessionTimeData,
    MilestoneTimeData
)


# Constants
LOW_BUDGET_THRESHOLD_MIN = 60
CRITICAL_BUDGET_THRESHOLD_MIN = 30
LONG_ETA_THRESHOLD_HRS = 8
CACHE_TTL_MS = 300


class FlowForgeTimeIntegration:
    """
    Time tracking integration with FlowForge infrastructure.
    Provides session metrics, budget monitoring, and ETA predictions.
    """
    
    def __init__(self, base_path: Optional[Path] = None):
        """Initialize with optional base path."""
        self.base_path = base_path or Path.cwd()
        self._cache: Dict[str, Tuple[float, Any]] = {}
        self._flowforge_dir = self.base_path / '.flowforge'
        self._session_file = self._flowforge_dir / 'local' / 'session.json'
        self._billing_file = self._flowforge_dir / 'billing' / 'time-tracking.json'
        self._task_times_file = self.base_path / '.task-times.json'
        
    def get_session_time_data(self, issue_id: Optional[str] = None) -> SessionTimeData:
        """
        Gets session time data.
        
        Args:
            issue_id: Issue ID to track
            
        Returns:
            SessionTimeData: Session timing information
        """
        try:
            session_info = self._get_current_session_info(issue_id)
            planned_time = self._get_planned_time(issue_id)
            budget_info = self._get_budget_info(issue_id)
            
            return SessionTimeData(
                elapsed_time=self._format_elapsed_time(session_info),
                planned_time=self._format_planned_time(planned_time),
                remaining_budget=self._format_budget(budget_info),
                session_start=session_info.get('start_time'),
                is_active=session_info.get('is_active', False),
                overtime_minutes=self._calculate_overtime_minutes(session_info, planned_time),
                budget_warning=self._determine_budget_warning(budget_info),
                efficiency_score=self._calculate_efficiency_score(session_info, planned_time)
            )
        except Exception:
            return self._create_fallback_session_data()
    
    def get_milestone_time_data(self, tasks_completed: int = 0, tasks_total: int = 0) -> MilestoneTimeData:
        """
        Gets milestone time data with ETA.
        
        Args:
            tasks_completed: Completed tasks
            tasks_total: Total tasks
            
        Returns:
            MilestoneTimeData: Milestone timing info
        """
        try:
            session_info = self._get_current_session_info(None)  # Pass None explicitly for cache consistency
            eta_remaining = self._calculate_progress_eta(tasks_completed, tasks_total, session_info)
            
            return MilestoneTimeData(
                eta_remaining=eta_remaining,
                current_session_time=self._format_elapsed_time(session_info),
                progress_rate=self._calculate_progress_rate(tasks_completed, session_info),
                estimated_completion=self._estimate_completion_time(eta_remaining),
                eta_warning=self._determine_eta_warning(eta_remaining),
                time_efficiency=self._calculate_milestone_efficiency(tasks_completed, tasks_total, session_info)
            )
        except Exception:
            return self._create_fallback_milestone_data()
    
    def calculate_eta_hours(self, tasks_completed: int, tasks_total: int, session_minutes: int) -> float:
        """Calculate ETA in hours based on progress rate."""
        if tasks_completed <= 0 or tasks_total <= 0 or session_minutes <= 0:
            raise FlowForgeTimeError("Invalid ETA parameters")
        
        if tasks_completed >= tasks_total:
            return 0.0
        
        minutes_per_task = session_minutes / tasks_completed
        remaining_tasks = tasks_total - tasks_completed
        return (remaining_tasks * minutes_per_task) / 60.0
    
    def parse_time_to_minutes(self, time_str: str) -> int:
        """Parse time string to minutes."""
        try:
            match = re.match(r'^(\d{1,2}):(\d{2})$', time_str)
            if match:
                hours = int(match.group(1))
                minutes = int(match.group(2))
                if 0 <= hours <= 23 and 0 <= minutes <= 59:
                    return hours * 60 + minutes
            raise FlowForgeTimeError(f"Invalid time: {time_str}")
        except Exception as e:
            raise FlowForgeTimeError(f"Parse failed: {e}")
    
    @lru_cache(maxsize=8)
    def _get_current_session_info(self, issue_id: Optional[str] = None) -> Dict[str, Any]:
        """Get current session info from FlowForge files."""
        session_info = {'is_active': False, 'elapsed_minutes': 0}
        
        # Try session file
        if self._try_load_session_file(session_info, issue_id):
            return session_info
        
        # Try billing file
        if self._try_load_billing_file(session_info, issue_id):
            return session_info
        
        # Try task-times file
        self._try_load_task_times_file(session_info, issue_id)
        return session_info
    
    def _try_load_session_file(self, session_info: Dict, issue_id: Optional[str]) -> bool:
        """Try loading session.json file."""
        try:
            if self._session_file.exists():
                with open(self._session_file, 'r') as f:
                    data = json.load(f)
                    
                if issue_id is None or data.get('current_issue') == issue_id:
                    session_info.update(data)
                    session_info['is_active'] = True
                    
                    start_time_str = data.get('session_start')
                    if start_time_str:
                        start_time = datetime.fromisoformat(start_time_str.replace('Z', '+00:00'))
                        elapsed = datetime.now() - start_time.replace(tzinfo=None)
                        session_info['elapsed_minutes'] = int(elapsed.total_seconds() / 60)
                    return True
        except (json.JSONDecodeError, IOError, KeyError, ValueError):
            pass
        return False
    
    def _try_load_billing_file(self, session_info: Dict, issue_id: Optional[str]) -> bool:
        """Try loading time-tracking.json file."""
        try:
            if self._billing_file.exists():
                with open(self._billing_file, 'r') as f:
                    data = json.load(f)
                    current_session = data.get('current_session', {})
                    if issue_id is None or current_session.get('issue_id') == issue_id:
                        # Update session_info with values from current_session
                        if 'elapsed_minutes' in current_session:
                            session_info['elapsed_minutes'] = current_session['elapsed_minutes']
                            session_info['is_active'] = True
                        if 'issue_id' in current_session:
                            session_info['issue_id'] = current_session['issue_id']
                        # Copy any other relevant fields
                        for key in ['start_time', 'planned_minutes']:
                            if key in current_session:
                                session_info[key] = current_session[key]
                        return True
        except (json.JSONDecodeError, IOError, KeyError):
            pass
        return False
    
    def _try_load_task_times_file(self, session_info: Dict, issue_id: Optional[str]) -> bool:
        """Try loading .task-times.json file."""
        try:
            if self._task_times_file.exists():
                with open(self._task_times_file, 'r') as f:
                    data = json.load(f)
                    if issue_id and issue_id in data:
                        issue_data = data[issue_id]
                        if issue_data.get('status') == 'active':
                            session_info['is_active'] = True
                            return True
        except (json.JSONDecodeError, IOError, KeyError):
            pass
        return False
    
    def _get_planned_time(self, issue_id: Optional[str] = None) -> Dict[str, Any]:
        """Get planned time info."""
        planned_info = {'planned_minutes': 0}
        try:
            if self._session_file.exists():
                with open(self._session_file, 'r') as f:
                    data = json.load(f)
                    planned_time_str = data.get('planned_time', '0:00')
                    planned_info['planned_minutes'] = self.parse_time_to_minutes(planned_time_str)
        except Exception:
            pass
        return planned_info
    
    def _get_budget_info(self, issue_id: Optional[str] = None) -> Dict[str, Any]:
        """Get budget info."""
        budget_info = {'budget_hours': 0.0}
        try:
            if self._session_file.exists():
                with open(self._session_file, 'r') as f:
                    data = json.load(f)
                    milestone = data.get('milestone', {})
                    budget_info['budget_hours'] = milestone.get('eta_hours', 0.0)
        except Exception:
            pass
        return budget_info
    
    def _format_elapsed_time(self, session_info: Dict[str, Any]) -> str:
        """Format elapsed time as HH:MM."""
        elapsed_minutes = session_info.get('elapsed_minutes', 0)
        hours = elapsed_minutes // 60
        minutes = elapsed_minutes % 60
        return f"{hours:02d}:{minutes:02d}"
    
    def _format_planned_time(self, planned_info: Dict[str, Any]) -> str:
        """Format planned time as H:MM."""
        planned_minutes = planned_info.get('planned_minutes', 0)
        hours = planned_minutes // 60
        minutes = planned_minutes % 60
        return f"0:{minutes:02d}" if hours == 0 else f"{hours}:{minutes:02d}"
    
    def _format_budget(self, budget_info: Dict[str, Any]) -> str:
        """Format budget as time string."""
        budget_hours = budget_info.get('budget_hours', 0.0)
        if budget_hours >= 1.0:
            return f"{budget_hours:.1f}h"
        else:
            budget_minutes = int(budget_hours * 60)
            return f"0:{budget_minutes:02d}h"
    
    def _calculate_overtime_minutes(self, session_info: Dict[str, Any], planned_info: Dict[str, Any]) -> int:
        """Calculate overtime minutes."""
        elapsed_minutes = session_info.get('elapsed_minutes', 0)
        planned_minutes = planned_info.get('planned_minutes', 0)
        return max(0, elapsed_minutes - planned_minutes)
    
    def _determine_budget_warning(self, budget_info: Dict[str, Any]) -> str:
        """Determine budget warning level."""
        budget_minutes = budget_info.get('budget_hours', 0.0) * 60
        if budget_minutes <= CRITICAL_BUDGET_THRESHOLD_MIN:
            return 'critical'
        elif budget_minutes <= LOW_BUDGET_THRESHOLD_MIN:
            return 'low'
        return 'none'
    
    def _calculate_efficiency_score(self, session_info: Dict[str, Any], planned_info: Dict[str, Any]) -> float:
        """Calculate time efficiency score (0-100)."""
        elapsed_minutes = session_info.get('elapsed_minutes', 0)
        planned_minutes = planned_info.get('planned_minutes', 1)
        if elapsed_minutes == 0:
            return 100.0
        return max(0, min(100, (planned_minutes / elapsed_minutes) * 100))
    
    def _calculate_progress_eta(self, tasks_completed: int, tasks_total: int, session_info: Dict[str, Any]) -> str:
        """Calculate ETA based on progress - time to complete remaining tasks."""
        try:
            if tasks_completed > 0 and tasks_total > tasks_completed:
                session_minutes = session_info.get('elapsed_minutes', 0)
                if session_minutes > 0:
                    # Calculate time per task based on current progress
                    minutes_per_task = session_minutes / tasks_completed
                    remaining_tasks = tasks_total - tasks_completed

                    # ETA is time to complete remaining tasks, not total session time
                    eta_minutes = remaining_tasks * minutes_per_task

                    # Format as hours and minutes for better readability
                    if eta_minutes < 60:
                        return f"{int(eta_minutes)}m"
                    else:
                        hours = int(eta_minutes // 60)
                        mins = int(eta_minutes % 60)
                        return f"{hours}h {mins}m" if mins > 0 else f"{hours}h"
            return "0m"
        except Exception:
            return "∞"
    
    def _calculate_progress_rate(self, tasks_completed: int, session_info: Dict[str, Any]) -> float:
        """Calculate progress rate (tasks/hour)."""
        session_minutes = session_info.get('elapsed_minutes', 0)
        if session_minutes > 0 and tasks_completed > 0:
            return (tasks_completed / session_minutes) * 60
        return 0.0
    
    def _determine_eta_warning(self, eta_str: str) -> str:
        """Determine ETA warning level."""
        if eta_str == "∞":
            return 'critical'
        try:
            match = re.search(r'(\d+(?:\.\d+)?)h', eta_str)
            if match and float(match.group(1)) > LONG_ETA_THRESHOLD_HRS:
                return 'long'
        except Exception:
            pass
        return 'none'
    
    def _calculate_milestone_efficiency(self, tasks_completed: int, tasks_total: int, session_info: Dict[str, Any]) -> float:
        """Calculate milestone efficiency."""
        if tasks_total == 0:
            return 100.0
        progress_ratio = tasks_completed / tasks_total
        session_minutes = session_info.get('elapsed_minutes', 0)
        if session_minutes > 0:
            return max(0, min(100, (progress_ratio * 60) / (session_minutes / 60)))
        return 0.0
    
    def _estimate_completion_time(self, eta_str: str) -> Optional[datetime]:
        """Estimate completion time."""
        try:
            match = re.search(r'(\d+(?:\.\d+)?)h', eta_str)
            if match:
                return datetime.now() + timedelta(hours=float(match.group(1)))
        except Exception:
            pass
        return None
    
    def _create_fallback_session_data(self) -> SessionTimeData:
        """Create fallback session data."""
        return SessionTimeData()
    
    def _create_fallback_milestone_data(self) -> MilestoneTimeData:
        """Create fallback milestone data."""
        return MilestoneTimeData()
    
    def clear_cache(self):
        """Clear internal cache."""
        self._cache.clear()
        self._get_current_session_info.cache_clear()


# Convenience functions
def get_session_elapsed_time(base_path: Optional[Path] = None) -> str:
    """Get current session elapsed time."""
    integration = FlowForgeTimeIntegration(base_path)
    return integration.get_session_time_data().elapsed_time


def calculate_simple_eta(tasks_completed: int, tasks_total: int, session_minutes: int) -> str:
    """Calculate ETA string."""
    try:
        integration = FlowForgeTimeIntegration()
        eta_hours = integration.calculate_eta_hours(tasks_completed, tasks_total, session_minutes)
        return f"{eta_hours:.1f}h"
    except Exception:
        return "∞"


__all__ = [
    'FlowForgeTimeIntegration',
    'SessionTimeData',
    'MilestoneTimeData',
    'FlowForgeTimeError',
    'get_session_elapsed_time',
    'calculate_simple_eta'
]

__version__ = "2.1.0"
__author__ = "FlowForge Team"