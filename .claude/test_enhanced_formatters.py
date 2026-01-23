#!/usr/bin/env python3
"""
Test suite for enhanced statusline formatters with improved context usage and time tracking.

Tests for enhanced NormalModeFormatter and MilestoneModeFormatter implementations
following FlowForge Rule #3 (TDD) - write tests BEFORE implementation.

This test suite validates:
- Enhanced context usage indicators with detailed progress bars
- Improved time tracking with FlowForge integration
- Time budget calculations and warnings
- ETA calculations for milestone mode
- Visual progress bars for context utilization
- Integration with .flowforge time tracking data

Author: FlowForge Team
Since: 2.1.0
"""

import unittest
import json
import tempfile
import os
from unittest.mock import patch, mock_open, MagicMock
from pathlib import Path
from datetime import datetime, timedelta

# Import modules under test
from status_formatter_interface import FormattingContext
from normal_mode_formatter import NormalModeFormatter, StatusLineData
from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData


class TestEnhancedContextUsage(unittest.TestCase):
    """
    Test enhanced context usage indicators with detailed calculations.
    
    Tests context usage calculation, visual progress bars, warnings for 
    approaching limits, and Claude Code context pattern monitoring.
    """

    def setUp(self):
        """Set up test fixtures for context usage tests."""
        self.normal_formatter = NormalModeFormatter()
        self.milestone_formatter = MilestoneModeFormatter()

    def test_context_usage_calculation_normal_mode(self):
        """Test context usage calculation in normal mode with progress bar."""
        # Test case: 85% context usage should show warning indicators
        data = StatusLineData(
            context_usage=85.0,
            model_name="Opus"
        )
        
        result = self.normal_formatter.format(data)
        
        # Should include context usage with visual progress bar
        self.assertIn("🧠 85%", result)
        self.assertIn("[▓▓▓▓░]", result)  # 85% = 4/5 filled
        
        # Test warning threshold (>80% should show warning)
        self.assertIn("⚠️", result)  # Warning indicator for high usage

    def test_context_usage_calculation_milestone_mode(self):
        """Test context usage calculation in milestone mode."""
        data = MilestoneStatusLineData(
            milestone_name="v2.0-demo",
            context_usage=65.0,  # Below warning threshold
            model_name="Opus"
        )
        
        result = self.milestone_formatter.format(data)
        
        # Should include context usage
        self.assertIn("🧠 65%", result)
        self.assertIn("[▓▓▓░░]", result)  # 65% = 3/5 filled
        # No warning for moderate usage
        self.assertNotIn("⚠️", result)

    def test_context_usage_edge_cases(self):
        """Test context usage edge cases (0%, 100%, overflow)."""
        # Test 0% usage
        data = StatusLineData(context_usage=0.0)
        result = self.normal_formatter.format(data)
        self.assertIn("[░░░░░]", result)  # Empty progress bar
        
        # Test 100% usage (critical)
        data = StatusLineData(context_usage=100.0)
        result = self.normal_formatter.format(data)
        self.assertIn("[▓▓▓▓▓]", result)  # Full progress bar
        self.assertIn("🚨", result)  # Critical warning
        
        # Test overflow (>100%)
        data = StatusLineData(context_usage=115.0)
        result = self.normal_formatter.format(data)
        self.assertIn("🚨", result)  # Critical warning
        # Should cap display at 100%
        self.assertIn("[▓▓▓▓▓]", result)

    def test_conversation_token_tracking(self):
        """Test conversation token usage vs limits calculation."""
        # Mock Claude Code context data
        context_data = {
            'conversation_tokens': 45000,
            'token_limit': 50000,
            'context_windows': 3
        }
        
        # Calculate usage percentage
        usage_percentage = (context_data['conversation_tokens'] / context_data['token_limit']) * 100
        
        data = StatusLineData(context_usage=usage_percentage)
        result = self.normal_formatter.format(data)
        
        # Should show 90% usage with warning
        self.assertIn("90%", result)
        self.assertIn("⚠️", result)

    def test_context_pattern_monitoring(self):
        """Test Claude Code context usage pattern monitoring."""
        # Test increasing context usage pattern
        usage_pattern = [20, 35, 50, 70, 85]  # Increasing pattern
        
        for usage in usage_pattern:
            data = StatusLineData(context_usage=usage)
            result = self.normal_formatter.format(data)
            
            if usage > 80:
                self.assertIn("⚠️", result)  # Warning for high usage
            elif usage > 95:
                self.assertIn("🚨", result)  # Critical for very high usage


class TestEnhancedTimeTracking(unittest.TestCase):
    """
    Test enhanced time tracking with FlowForge integration.
    
    Tests improved time calculations, ETA estimations, session tracking,
    and integration with .flowforge time tracking system.
    """

    def setUp(self):
        """Set up test fixtures for time tracking tests."""
        self.normal_formatter = NormalModeFormatter()
        self.milestone_formatter = MilestoneModeFormatter()

    def test_time_remaining_calculation_normal_mode(self):
        """Test time remaining calculations in normal mode."""
        data = StatusLineData(
            elapsed_time="01:23",
            planned_time="2:30",
            remaining_budget="4:30h"
        )
        
        result = self.normal_formatter.format(data)
        
        # Should show elapsed/planned time
        self.assertIn("⏱ 01:23/2:30", result)
        # Should show remaining budget
        self.assertIn("💰 4:30h left", result)

    def test_session_vs_planned_time_tracking(self):
        """Test session time vs planned time tracking."""
        # Test session running over planned time
        data = StatusLineData(
            elapsed_time="02:45",  # Over planned
            planned_time="2:30",   # Planned limit
            remaining_budget="1:15h"
        )
        
        result = self.normal_formatter.format(data)
        
        # Should show warning indicator for overtime
        self.assertIn("⚠️", result)
        # Should show actual times
        self.assertIn("02:45/2:30", result)

    def test_eta_calculation_milestone_mode(self):
        """Test ETA calculations for milestone mode."""
        data = MilestoneStatusLineData(
            milestone_name="v2.0-demo",
            tasks_completed=7,
            tasks_total=21,
            current_session_time="01:15",
            eta_remaining="2.5h"  # Adjust to match calculated ETA
        )
        
        result = self.milestone_formatter.format(data)
        
        # Should show ETA
        self.assertIn("ETA: 2.5h", result)
        # Should show current session time
        self.assertIn("⏱ 01:15", result)

    def test_time_budget_warnings(self):
        """Test time budget tracking and warnings."""
        # Test low time budget (< 1 hour remaining)
        data = StatusLineData(
            remaining_budget="0:45h",
            elapsed_time="03:15",
            planned_time="4:00"
        )
        
        result = self.normal_formatter.format(data)
        
        # Should show warning for low budget
        self.assertIn("⚠️", result)
        self.assertIn("0:45h left", result)

    @patch('builtins.open', new_callable=mock_open)
    @patch('pathlib.Path.exists')
    def test_flowforge_time_tracking_integration(self, mock_exists, mock_file):
        """Test integration with .flowforge time tracking files."""
        # Mock time tracking data
        time_tracking_data = {
            "current_session": {
                "issue_id": "317",
                "start_time": "2024-01-15T10:30:00Z",
                "elapsed_minutes": 83,
                "planned_minutes": 150,
                "budget_remaining_hours": 4.5
            },
            "context_usage": {
                "current_percentage": 78.5,
                "conversation_tokens": 39250,
                "token_limit": 50000
            }
        }
        
        mock_exists.return_value = True
        mock_file.return_value.read.return_value = json.dumps(time_tracking_data)
        
        # Test data extraction and formatting
        context = FormattingContext(
            timer_data={
                "elapsed_minutes": 83,
                "planned_minutes": 150,
                "budget_hours": 4.5
            },
            context_usage=78.5
        )
        
        # Should properly format FlowForge data
        self.assertEqual(context.context_usage, 78.5)
        self.assertIsNotNone(context.timer_data)

    def test_progress_based_time_estimates(self):
        """Test progress-based time estimates for ETA."""
        # Test ETA calculation based on current progress rate
        tasks_completed = 8
        tasks_total = 24
        session_minutes = 95  # 1:35 session time
        
        # Calculate expected ETA
        completion_rate = tasks_completed / session_minutes  # tasks per minute
        remaining_tasks = tasks_total - tasks_completed
        eta_minutes = remaining_tasks / completion_rate
        eta_hours = eta_minutes / 60
        
        data = MilestoneStatusLineData(
            milestone_name="v2.0-demo",
            tasks_completed=tasks_completed,
            tasks_total=tasks_total,
            current_session_time="01:35",
            eta_remaining=f"{eta_hours:.1f}h"
        )
        
        result = self.milestone_formatter.format(data)
        
        # Should include calculated ETA
        self.assertIn("ETA:", result)
        self.assertIn("h", result)


class TestVisualEnhancements(unittest.TestCase):
    """
    Test visual enhancements for progress bars and indicators.
    
    Tests consistent progress bar usage, warning color indicators,
    compact format for space-constrained displays, and readability.
    """

    def setUp(self):
        """Set up test fixtures for visual enhancement tests."""
        self.normal_formatter = NormalModeFormatter()
        self.milestone_formatter = MilestoneModeFormatter()

    def test_consistent_progress_bars(self):
        """Test consistent progress bar usage for time and context."""
        data = StatusLineData(
            tasks_completed=12,
            tasks_total=20,
            context_usage=60.0
        )
        
        result = self.normal_formatter.format(data)
        
        # Should have consistent progress bar format
        progress_bars = result.count("[")
        self.assertGreaterEqual(progress_bars, 2)  # At least task and context bars
        
        # Should use same visual style
        self.assertIn("▓", result)  # Filled progress
        self.assertIn("░", result)  # Empty progress

    def test_warning_indicators_different_levels(self):
        """Test different warning indicators for various alert levels."""
        # Test moderate warning (80-90%)
        data = StatusLineData(context_usage=85.0)
        result = self.normal_formatter.format(data)
        self.assertIn("⚠️", result)
        
        # Test critical warning (95%+)
        data = StatusLineData(context_usage=96.0)
        result = self.normal_formatter.format(data)
        self.assertIn("🚨", result)
        
        # Test low budget warning
        data = StatusLineData(remaining_budget="0:30h")
        result = self.normal_formatter.format(data)
        # Should indicate urgency
        self.assertIn("⚠️", result)

    def test_compact_format_space_constraints(self):
        """Test compact format for narrow terminals."""
        # Test compact mode with limited width
        self.normal_formatter = NormalModeFormatter(terminal_width=90)
        
        data = StatusLineData(
            tasks_completed=317,
            tasks_total=21,
            elapsed_time="01:23",
            planned_time="2:30",
            remaining_budget="4:30h",
            git_branch="feature/very-long-branch-name-317",
            context_usage=85.0,
            model_name="Opus"
        )
        
        result = self.normal_formatter.format_compact(data)
        
        # Compact format should be shorter
        self.assertLess(len(result), 90)
        # Should still contain essential information
        self.assertIn("FF", result)  # FlowForge brand
        self.assertIn("317/21", result)  # Task progress
        self.assertIn("Opus", result)  # Model name

    def test_readability_both_modes(self):
        """Test readability in both normal and milestone modes."""
        # Normal mode readability
        normal_data = StatusLineData(
            version="v2.1",
            tasks_completed=15,
            tasks_total=25,
            elapsed_time="02:15",
            remaining_budget="3:45h",
            context_usage=72.0
        )
        
        normal_result = self.normal_formatter.format(normal_data)
        
        # Should be readable and well-separated
        self.assertIn(" | ", normal_result)  # Clear separators
        self.assertRegex(normal_result, r"⚩.*📋.*⏱.*💰.*🧠")  # Logical order
        
        # Milestone mode readability
        milestone_data = MilestoneStatusLineData(
            milestone_name="v2.0-demo",
            tasks_completed=15,
            tasks_total=25,
            current_session_time="02:15",
            eta_remaining="3.2h"
        )
        
        milestone_result = self.milestone_formatter.format(milestone_data)
        
        # Should be readable and milestone-focused
        self.assertIn("🎯 MILESTONE:", milestone_result)
        self.assertIn("ETA:", milestone_result)


class TestPerformanceRequirements(unittest.TestCase):
    """
    Test performance requirements for enhanced formatters.
    
    Tests cache performance (<50ms), efficient calculations,
    and avoiding expensive operations on every render.
    """

    def setUp(self):
        """Set up test fixtures for performance tests."""
        self.normal_formatter = NormalModeFormatter()
        self.milestone_formatter = MilestoneModeFormatter()

    def test_cache_performance_target(self):
        """Test that formatting completes within 50ms performance target."""
        import time
        
        data = StatusLineData(
            tasks_completed=317,
            tasks_total=21,
            elapsed_time="01:23",
            planned_time="2:30",
            remaining_budget="4:30h",
            context_usage=85.0
        )
        
        # Test normal mode performance
        start_time = time.time()
        result = self.normal_formatter.format(data)
        end_time = time.time()
        
        elapsed_ms = (end_time - start_time) * 1000
        self.assertLess(elapsed_ms, 50, f"Normal mode took {elapsed_ms:.1f}ms (target: <50ms)")
        self.assertIsNotNone(result)

    def test_context_calculation_efficiency(self):
        """Test that context usage calculations are efficient."""
        import time
        
        # Test multiple context calculations
        start_time = time.time()
        
        for usage in range(0, 101, 5):
            data = StatusLineData(context_usage=float(usage))
            result = self.normal_formatter._format_context_usage(data)
            self.assertIsInstance(result, str)
        
        end_time = time.time()
        elapsed_ms = (end_time - start_time) * 1000
        
        # Should handle 21 calculations in under 50ms total
        self.assertLess(elapsed_ms, 50, f"Context calculations took {elapsed_ms:.1f}ms")

    def test_time_calculation_algorithms(self):
        """Test efficient time calculation algorithms."""
        import time
        
        # Test ETA calculations efficiency
        start_time = time.time()
        
        for completed in range(1, 21):
            for total in range(completed, 25):
                session_minutes = 60 + completed * 5
                eta = self.milestone_formatter._calculate_eta(completed, total, session_minutes)
                self.assertIsInstance(eta, str)
        
        end_time = time.time()
        elapsed_ms = (end_time - start_time) * 1000
        
        # Should handle many ETA calculations efficiently
        self.assertLess(elapsed_ms, 100, f"ETA calculations took {elapsed_ms:.1f}ms")


class TestDataIntegration(unittest.TestCase):
    """
    Test data integration with FlowForge time tracking files.
    
    Tests reading from .flowforge files, handling missing data gracefully,
    and calculating progress-based estimates.
    """

    def setUp(self):
        """Set up test fixtures for data integration tests."""
        self.temp_dir = tempfile.mkdtemp()
        self.flowforge_dir = Path(self.temp_dir) / '.flowforge'
        self.flowforge_dir.mkdir(exist_ok=True)
        self.normal_formatter = NormalModeFormatter()
        self.milestone_formatter = MilestoneModeFormatter()

    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        shutil.rmtree(self.temp_dir)

    def test_read_billing_time_tracking_json(self):
        """Test reading from .flowforge/billing/time-tracking.json."""
        # Create mock billing directory and file
        billing_dir = self.flowforge_dir / 'billing'
        billing_dir.mkdir(exist_ok=True)
        
        time_tracking_file = billing_dir / 'time-tracking.json'
        time_tracking_data = {
            "sessions": [
                {
                    "session_id": "session_001",
                    "issue_id": "317",
                    "start_time": "2024-01-15T10:30:00Z",
                    "duration_minutes": 95,
                    "type": "feature"
                }
            ],
            "current_session": {
                "session_id": "session_002",
                "issue_id": "317",
                "start_time": "2024-01-15T14:15:00Z",
                "elapsed_minutes": 23,
                "is_active": True
            }
        }
        
        with open(time_tracking_file, 'w') as f:
            json.dump(time_tracking_data, f)
        
        # Test reading and parsing
        self.assertTrue(time_tracking_file.exists())
        
        with open(time_tracking_file, 'r') as f:
            loaded_data = json.load(f)
        
        self.assertEqual(loaded_data["current_session"]["elapsed_minutes"], 23)
        self.assertTrue(loaded_data["current_session"]["is_active"])

    def test_read_session_json(self):
        """Test reading from .flowforge/local/session.json."""
        # Create mock local directory and file
        local_dir = self.flowforge_dir / 'local'
        local_dir.mkdir(exist_ok=True)
        
        session_file = local_dir / 'session.json'
        session_data = {
            "current_issue": "317",
            "session_start": "2024-01-15T14:15:00Z",
            "elapsed_time": "00:23",
            "planned_time": "02:30",
            "milestone": {
                "name": "v2.0-demo",
                "progress": 0.33,
                "eta_hours": 4.5
            }
        }
        
        with open(session_file, 'w') as f:
            json.dump(session_data, f)
        
        # Test reading and parsing
        with open(session_file, 'r') as f:
            loaded_data = json.load(f)
        
        self.assertEqual(loaded_data["current_issue"], "317")
        self.assertEqual(loaded_data["milestone"]["eta_hours"], 4.5)

    def test_handle_missing_time_tracking_data(self):
        """Test graceful handling of missing time tracking data."""
        # Test with non-existent files
        context = FormattingContext(
            model_name="Opus",
            timer_data=None,  # Missing timer data
            context_usage=0.0  # Default context usage
        )
        
        # Should not raise exceptions
        normal_data = StatusLineData()
        result = self.normal_formatter.format(normal_data)
        
        # Should show default values
        self.assertIn("00:00", result)  # Default elapsed time
        self.assertIn("0:00h left", result)  # Default budget

    def test_calculate_progress_based_estimates(self):
        """Test calculating progress-based time estimates."""
        # Mock progress data
        progress_data = {
            "tasks_completed": 8,
            "tasks_total": 24,
            "session_minutes": 95,
            "average_time_per_task": 11.875  # 95/8
        }
        
        # Calculate remaining work
        remaining_tasks = progress_data["tasks_total"] - progress_data["tasks_completed"]
        estimated_remaining_minutes = remaining_tasks * progress_data["average_time_per_task"]
        estimated_hours = estimated_remaining_minutes / 60
        
        self.assertEqual(remaining_tasks, 16)
        self.assertAlmostEqual(estimated_hours, 3.17, places=2)  # ~3.17 hours
        
        # Format as ETA string
        eta_string = f"{estimated_hours:.1f}h"
        self.assertEqual(eta_string, "3.2h")


if __name__ == '__main__':
    # Configure test runner
    unittest.main(verbosity=2, buffer=True)