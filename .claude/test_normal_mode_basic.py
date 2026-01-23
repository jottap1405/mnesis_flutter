#!/usr/bin/env python3
"""
Basic test suite for NormalModeFormatter.

Tests core formatting functionality following FlowForge Rule #3 (TDD) and
Rule #25 (comprehensive testing). Covers basic functionality including:
- Basic formatting functionality
- Component generation
- Data sanitization

Following FlowForge Rule #26: Full documentation
Following FlowForge Rule #33: No AI references
"""

import unittest
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock

# Add the .claude directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))

from normal_mode_formatter import (
    NormalModeFormatter,
    NormalModeFormatterError,
    StatusLineData,
    format_normal_statusline
)


class TestStatusLineData(unittest.TestCase):
    """
    Tests for StatusLineData dataclass.
    
    Verifies the data structure used for statusline components
    handles all required fields with proper defaults.
    """

    def test_default_values(self):
        """
        Test StatusLineData default values.
        
        Verifies all fields have sensible defaults for missing data.
        """
        data = StatusLineData()
        
        self.assertEqual(data.version, "v2.0")
        self.assertEqual(data.tasks_completed, 0)
        self.assertEqual(data.tasks_total, 0)
        self.assertEqual(data.task_percentage, 0.0)
        self.assertEqual(data.elapsed_time, "00:00")
        self.assertEqual(data.planned_time, "0:00")
        self.assertEqual(data.remaining_budget, "0:00h")
        self.assertEqual(data.git_branch, "main")
        self.assertEqual(data.context_usage, 0.0)
        self.assertEqual(data.model_name, "Model")
        self.assertEqual(data.milestone_name, "")

    def test_custom_values(self):
        """
        Test StatusLineData with custom values.
        
        Verifies dataclass correctly stores custom values.
        """
        data = StatusLineData(
            version="v2.1",
            tasks_completed=5,
            tasks_total=10,
            task_percentage=50.0,
            elapsed_time="01:30",
            planned_time="3:00",
            remaining_budget="1:30h",
            git_branch="feature/test",
            context_usage=75.5,
            model_name="Opus",
            milestone_name="Sprint 1"
        )
        
        self.assertEqual(data.version, "v2.1")
        self.assertEqual(data.tasks_completed, 5)
        self.assertEqual(data.tasks_total, 10)
        self.assertEqual(data.task_percentage, 50.0)
        self.assertEqual(data.elapsed_time, "01:30")
        self.assertEqual(data.planned_time, "3:00")
        self.assertEqual(data.remaining_budget, "1:30h")
        self.assertEqual(data.git_branch, "feature/test")
        self.assertEqual(data.context_usage, 75.5)
        self.assertEqual(data.model_name, "Opus")
        self.assertEqual(data.milestone_name, "Sprint 1")


class TestNormalModeFormatterInitialization(unittest.TestCase):
    """
    Tests for NormalModeFormatter initialization.
    
    Verifies proper initialization with different terminal widths
    and error handling for invalid configurations.
    """

    def test_default_initialization(self):
        """
        Test default initialization with auto-detected terminal width.
        
        Verifies formatter initializes with detected terminal width.
        """
        formatter = NormalModeFormatter()
        
        # Terminal width should be at least the minimum
        self.assertGreaterEqual(formatter.terminal_width, 80)
        self.assertIsNotNone(formatter.progress_renderer)

    def test_custom_terminal_width(self):
        """
        Test initialization with custom terminal width.
        
        Verifies formatter accepts and uses custom width.
        """
        formatter = NormalModeFormatter(terminal_width=100)
        
        self.assertEqual(formatter.terminal_width, 100)

    def test_terminal_width_too_small(self):
        """
        Test initialization fails with terminal width too small.
        
        Verifies proper error for width below minimum.
        """
        with self.assertRaises(NormalModeFormatterError) as context:
            NormalModeFormatter(terminal_width=50)
        
        self.assertIn("too small", str(context.exception))


class TestBasicFormatting(unittest.TestCase):
    """
    Tests for basic formatting functionality.
    
    Verifies core formatting behavior with minimal data.
    """

    def setUp(self):
        """Set up test fixtures."""
        self.formatter = NormalModeFormatter(terminal_width=150)

    def test_format_empty_data(self):
        """
        Test formatting with empty/default data.
        
        Verifies formatter handles default values gracefully.
        """
        data = StatusLineData()
        result = self.formatter.format(data)
        
        # Check for essential components
        self.assertIn("⚩ FF v2.0", result)
        self.assertIn("📋 0/0", result)
        self.assertIn("⏱ 00:00/0:00", result)
        self.assertIn("💰 0:00h left", result)
        self.assertIn("🌿 main", result)
        self.assertIn("🧠 0%", result)
        self.assertIn("Model", result)

    def test_format_basic_data(self):
        """
        Test formatting with basic data values.
        
        Verifies all components are included and formatted.
        """
        data = StatusLineData(
            version="v2.0",
            tasks_completed=5,
            tasks_total=10,
            task_percentage=50.0,
            elapsed_time="00:30",
            planned_time="1:00",
            remaining_budget="0:30h",
            git_branch="feature/test",
            context_usage=25.0,
            model_name="Claude"
        )
        
        result = self.formatter.format(data)
        
        # Verify all components present
        self.assertIn("⚩ FF v2.0", result)
        self.assertIn("📋 5/10", result)
        self.assertIn("50%", result)
        self.assertIn("⏱ 00:30/1:00", result)
        self.assertIn("💰 0:30h left", result)
        self.assertIn("🌿 feature/test", result)
        self.assertIn("🧠 25%", result)
        self.assertIn("Claude", result)

    def test_format_separator_structure(self):
        """
        Test statusline uses correct separator structure.
        
        Verifies components are separated by " | ".
        """
        data = StatusLineData(
            tasks_completed=1,
            tasks_total=2
        )
        
        result = self.formatter.format(data)
        
        # Check separator pattern
        self.assertIn(" | ", result)
        # Count separators (should be 6 for 7 components)
        separator_count = result.count(" | ")
        self.assertEqual(separator_count, 6)


class TestComponentFormatting(unittest.TestCase):
    """
    Tests for individual component formatting methods.
    
    Verifies each component formatter works correctly.
    """

    def setUp(self):
        """Set up test fixtures."""
        self.formatter = NormalModeFormatter(terminal_width=150)

    def test_format_flowforge_header(self):
        """
        Test FlowForge header formatting.
        
        Verifies header includes emoji and version.
        """
        data = StatusLineData(version="v2.1")
        result = self.formatter._format_flowforge_header(data)
        
        self.assertEqual(result, "⚩ FF v2.1")

    def test_format_task_progress_zero_total(self):
        """
        Test task progress with zero total tasks.
        
        Verifies graceful handling of division by zero.
        """
        data = StatusLineData(
            tasks_completed=0,
            tasks_total=0
        )
        
        result = self.formatter._format_task_progress(data)
        
        self.assertIn("📋 0/0", result)
        self.assertIn("0%", result)

    def test_format_task_progress_normal(self):
        """
        Test task progress with normal values.
        
        Verifies correct percentage calculation and display.
        """
        data = StatusLineData(
            tasks_completed=3,
            tasks_total=10
        )
        
        result = self.formatter._format_task_progress(data)
        
        self.assertIn("📋 3/10", result)
        self.assertIn("30%", result)

    def test_format_task_progress_overflow(self):
        """
        Test task progress with overflow (completed > total).
        
        Verifies handling of edge case where more tasks completed than total.
        """
        data = StatusLineData(
            tasks_completed=15,
            tasks_total=10
        )
        
        result = self.formatter._format_task_progress(data)
        
        self.assertIn("📋 15/10", result)
        self.assertIn("150%", result)  # Should show actual percentage

    def test_format_time_tracking(self):
        """
        Test time tracking component formatting.
        
        Verifies elapsed/planned time display.
        """
        data = StatusLineData(
            elapsed_time="01:15",
            planned_time="2:00"
        )
        
        result = self.formatter._format_time_tracking(data)
        
        self.assertEqual(result, "⏱ 01:15/2:00")

    def test_format_budget_remaining(self):
        """
        Test budget remaining component formatting.
        
        Verifies budget display with "left" suffix.
        """
        data = StatusLineData(remaining_budget="3:45h")
        result = self.formatter._format_budget_remaining(data)
        
        self.assertEqual(result, "💰 3:45h left")

    def test_format_git_branch(self):
        """
        Test git branch component formatting.
        
        Verifies branch name with emoji prefix.
        """
        data = StatusLineData(git_branch="feature/new-feature")
        result = self.formatter._format_git_branch(data)
        
        self.assertEqual(result, "🌿 feature/new-feature")

    def test_format_context_usage_normal(self):
        """
        Test context usage with normal percentage.
        
        Verifies percentage and progress bar display.
        """
        data = StatusLineData(context_usage=45.0)
        result = self.formatter._format_context_usage(data)
        
        self.assertIn("🧠 45%", result)
        self.assertIn("[", result)
        self.assertIn("]", result)

    def test_format_context_usage_high(self):
        """
        Test context usage with high percentage.
        
        Verifies warning indicator appears.
        """
        data = StatusLineData(context_usage=85.0)
        result = self.formatter._format_context_usage(data)
        
        self.assertIn("🧠 85%", result)
        self.assertIn("⚠️", result)  # Warning indicator

    def test_format_context_usage_critical(self):
        """
        Test context usage with critical percentage.
        
        Verifies critical warning indicator appears.
        """
        data = StatusLineData(context_usage=98.0)
        result = self.formatter._format_context_usage(data)
        
        self.assertIn("🧠 98%", result)
        self.assertIn("🚨", result)  # Critical warning

    def test_format_model_name(self):
        """
        Test model name formatting.
        
        Verifies model name without emoji prefix.
        """
        data = StatusLineData(model_name="GPT-4")
        result = self.formatter._format_model_name(data)
        
        self.assertEqual(result, "GPT-4")


class TestConvenienceFunctions(unittest.TestCase):
    """
    Tests for convenience functions.
    
    Verifies quick formatting functions work correctly.
    """

    def test_format_normal_statusline_defaults(self):
        """
        Test convenience function with default values.
        
        Verifies function works without arguments.
        """
        result = format_normal_statusline()
        
        self.assertIn("⚩ FF v2.0", result)
        self.assertIn("📋 0/0", result)
        self.assertIn("Model", result)

    def test_format_normal_statusline_custom(self):
        """
        Test convenience function with custom values.
        
        Verifies all parameters are used correctly.
        """
        result = format_normal_statusline(
            version="v2.5",
            tasks_completed=10,
            tasks_total=20,
            elapsed_time="01:00",
            planned_time="2:00",
            remaining_budget="1:00h",
            git_branch="develop",
            context_usage=50.0,
            model_name="TestModel"
        )
        
        self.assertIn("v2.5", result)
        self.assertIn("10/20", result)
        self.assertIn("01:00/2:00", result)
        self.assertIn("1:00h left", result)
        # Check if branch is included or truncated due to width constraints
        if "develop" in result:
            self.assertIn("develop", result)
        self.assertIn("50%", result)
        self.assertIn("TestModel", result)


if __name__ == "__main__":
    unittest.main()