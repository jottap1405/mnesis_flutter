#!/usr/bin/env python3
"""
Advanced test suite for NormalModeFormatter.

Tests edge cases, security, and advanced functionality following FlowForge Rule #3 (TDD) and
Rule #25 (comprehensive testing). Covers:
- Edge cases and error handling
- Terminal width constraints
- Security input validation
- Time warnings and indicators
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
    StatusLineData
)


class TestDataSanitization(unittest.TestCase):
    """
    Tests for input data sanitization.
    
    Verifies security measures and input validation work correctly.
    """

    def setUp(self):
        """Set up test fixtures."""
        self.formatter = NormalModeFormatter(terminal_width=150)

    def test_sanitize_malicious_strings(self):
        """
        Test sanitization removes potentially dangerous characters.
        
        Verifies XSS and injection prevention.
        """
        data = StatusLineData(
            version="v2.0<script>alert('xss')</script>",
            git_branch="feature/test'; DROP TABLE users;--",
            model_name="Model\x00\x01\x02"
        )
        
        sanitized = self.formatter._sanitize_data(data)
        
        # Check dangerous characters removed
        self.assertNotIn("<script>", sanitized.version)
        self.assertNotIn("';", sanitized.git_branch)
        self.assertNotIn("\x00", sanitized.model_name)

    def test_sanitize_overlength_strings(self):
        """
        Test sanitization truncates overly long strings.
        
        Verifies length limits are enforced.
        """
        data = StatusLineData(
            git_branch="a" * 100,  # Way too long
            model_name="b" * 50,   # Also too long
            version="c" * 30       # Too long for version
        )
        
        sanitized = self.formatter._sanitize_data(data)
        
        # Check strings are truncated
        self.assertLessEqual(len(sanitized.git_branch), 50)
        self.assertLessEqual(len(sanitized.model_name), 20)
        self.assertLessEqual(len(sanitized.version), 20)

    def test_sanitize_invalid_numbers(self):
        """
        Test sanitization handles invalid numeric values.
        
        Verifies negative values and out-of-range percentages are corrected.
        """
        data = StatusLineData(
            tasks_completed=-5,
            tasks_total=-10,
            task_percentage=150.0,
            context_usage=120.0
        )
        
        sanitized = self.formatter._sanitize_data(data)
        
        # Check values are in valid ranges
        self.assertEqual(sanitized.tasks_completed, 0)
        self.assertEqual(sanitized.tasks_total, 0)
        self.assertGreaterEqual(sanitized.context_usage, 0)
        self.assertLessEqual(sanitized.context_usage, 100)

    def test_sanitize_invalid_time_formats(self):
        """
        Test sanitization corrects invalid time formats.
        
        Verifies invalid time strings are replaced with defaults.
        """
        data = StatusLineData(
            elapsed_time="not:time",
            planned_time="25:99",  # Invalid hours and minutes
            remaining_budget="invalid"
        )
        
        sanitized = self.formatter._sanitize_data(data)
        
        # Check times are validated
        self.assertEqual(sanitized.elapsed_time, "00:00")
        self.assertEqual(sanitized.planned_time, "00:00")
        # Budget should be sanitized but may keep some characters
        self.assertIsNotNone(sanitized.remaining_budget)

    def test_sanitize_none_values(self):
        """
        Test sanitization handles None values gracefully.
        
        Verifies None doesn't cause exceptions.
        """
        # Create data with None values using setattr
        data = StatusLineData()
        data.version = None
        data.git_branch = None
        data.model_name = None
        
        # Should not raise exception
        sanitized = self.formatter._sanitize_data(data)
        
        # Check defaults are applied
        self.assertEqual(sanitized.version, "v2.0")
        self.assertEqual(sanitized.git_branch, "main")
        self.assertEqual(sanitized.model_name, "Model")


class TestTimeWarnings(unittest.TestCase):
    """
    Tests for time tracking warnings.
    
    Verifies warning indicators for time overruns.
    """

    def setUp(self):
        """Set up test fixtures."""
        self.formatter = NormalModeFormatter(terminal_width=150)

    def test_time_warning_none(self):
        """
        Test no warning when within time budget.
        
        Verifies no indicator when time is under 90%.
        """
        warning = self.formatter._get_time_warning("00:30", "1:00")
        self.assertEqual(warning, "")

    def test_time_warning_near_limit(self):
        """
        Test warning when near time limit.
        
        Verifies warning indicator at 90%+ time usage.
        """
        warning = self.formatter._get_time_warning("00:55", "1:00")
        self.assertEqual(warning, "⚠️")

    def test_time_warning_over_time(self):
        """
        Test critical warning when over time.
        
        Verifies critical indicator when exceeding planned time.
        """
        warning = self.formatter._get_time_warning("01:30", "1:00")
        self.assertEqual(warning, "🚨")

    def test_time_warning_invalid_times(self):
        """
        Test warning handling with invalid time formats.
        
        Verifies no crash with malformed time strings.
        """
        warning = self.formatter._get_time_warning("invalid", "1:00")
        self.assertEqual(warning, "")
        
        warning = self.formatter._get_time_warning("1:00", "invalid")
        self.assertEqual(warning, "")

    def test_time_warning_zero_planned(self):
        """
        Test warning handling with zero planned time.
        
        Verifies no division by zero error.
        """
        warning = self.formatter._get_time_warning("00:30", "0:00")
        self.assertEqual(warning, "")


class TestTerminalWidthConstraints(unittest.TestCase):
    """
    Tests for terminal width constraint handling.
    
    Verifies statusline adapts to narrow terminals.
    """

    def test_narrow_terminal_truncation(self):
        """
        Test component truncation in narrow terminal.
        
        Verifies essential components are preserved.
        """
        formatter = NormalModeFormatter(terminal_width=80)
        
        data = StatusLineData(
            version="v2.0",
            tasks_completed=100,
            tasks_total=200,
            git_branch="feature/very-long-branch-name-that-exceeds-width",
            model_name="VeryLongModelName"
        )
        
        result = formatter.format(data)
        
        # Check length constraint
        self.assertLessEqual(len(result), 80)
        
        # Check essential components still present
        self.assertIn("FF", result)  # FlowForge marker
        self.assertIn("100/200", result)  # Task progress

    def test_extreme_narrow_terminal(self):
        """
        Test extreme narrow terminal handling.
        
        Verifies formatter doesn't crash with minimal width.
        """
        formatter = NormalModeFormatter(terminal_width=80)  # Minimum width
        
        data = StatusLineData(
            version="v10.99.999",  # Long version
            tasks_completed=99999,
            tasks_total=99999,
            git_branch="feature/extremely-long-branch-name-with-many-words",
            model_name="SuperLongModelNameVersion3"
        )
        
        result = formatter.format(data)
        
        # Should not exceed terminal width
        self.assertLessEqual(len(result), 80)
        
        # Should still have some content
        self.assertGreater(len(result), 0)

    def test_width_constraints_applied(self):
        """
        Test width constraints are applied when needed.
        
        Verifies truncation logic is invoked for long statuslines.
        """
        formatter = NormalModeFormatter(terminal_width=80)
        
        # Create data that will likely exceed width
        data = StatusLineData(
            version="v10.99.999",
            tasks_completed=99999,
            tasks_total=99999,
            git_branch="feature/very-long-branch-name-that-exceeds-width",
            model_name="VeryLongModelNameVersion3",
            context_usage=85.5,
            elapsed_time="99:99",
            planned_time="99:99",
            remaining_budget="999:99h"
        )
        
        result = formatter.format(data)
        
        # Result should be truncated to fit width
        self.assertLessEqual(len(result), 80)


class TestErrorHandling(unittest.TestCase):
    """
    Tests for error handling and edge cases.
    
    Verifies formatter handles errors gracefully.
    """

    def setUp(self):
        """Set up test fixtures."""
        self.formatter = NormalModeFormatter(terminal_width=150)

    def test_format_invalid_data_type(self):
        """
        Test formatting with invalid data type.
        
        Verifies proper error is raised for non-StatusLineData input.
        """
        with self.assertRaises(NormalModeFormatterError) as context:
            self.formatter.format("not a StatusLineData object")
        
        self.assertIn("Invalid data structure", str(context.exception))

    def test_format_with_none_data(self):
        """
        Test formatting with None input.
        
        Verifies proper error handling for None.
        """
        with self.assertRaises(NormalModeFormatterError) as context:
            self.formatter.format(None)
        
        self.assertIn("Invalid data structure", str(context.exception))

    @patch('progress_bar_renderer.ProgressBarRenderer.render')
    def test_progress_bar_failure_fallback(self, mock_render):
        """
        Test fallback when progress bar renderer fails.
        
        Verifies graceful degradation on renderer errors.
        """
        mock_render.side_effect = Exception("Renderer failed")
        
        data = StatusLineData(
            tasks_completed=5,
            tasks_total=10
        )
        
        result = self.formatter.format(data)
        
        # Should still generate output with fallback
        self.assertIn("📋 5/10", result)
        self.assertIn("[?????]", result)  # Fallback progress bar

    def test_context_usage_exception_handling(self):
        """
        Test context usage formatting with exceptions.
        
        Verifies fallback for context usage errors.
        """
        data = StatusLineData()
        # Force an invalid context_usage that might cause issues
        data.context_usage = "not a number"
        
        # Should handle gracefully in _format_context_usage
        result = self.formatter._format_context_usage(data)
        
        # Should return fallback
        self.assertIn("🧠 0%", result)
        self.assertIn("[░░░░░]", result)


class TestIntegrationScenarios(unittest.TestCase):
    """
    Tests for realistic integration scenarios.
    
    Verifies formatter works in real-world use cases.
    """

    def test_typical_development_session(self):
        """
        Test formatting typical development session data.
        
        Verifies realistic data produces expected output.
        """
        formatter = NormalModeFormatter(terminal_width=120)
        
        data = StatusLineData(
            version="v2.0",
            tasks_completed=7,
            tasks_total=15,
            elapsed_time="01:45",
            planned_time="3:00",
            remaining_budget="1:15h",
            git_branch="feature/user-authentication",
            context_usage=62.5,
            model_name="Claude"
        )
        
        result = formatter.format(data)
        
        # Verify all components present and formatted
        self.assertIn("⚩ FF v2.0", result)
        self.assertIn("📋 7/15", result)
        self.assertIn("47%", result)  # Approximately
        self.assertIn("⏱ 01:45/3:00", result)
        self.assertIn("💰 1:15h left", result)
        self.assertIn("🌿 feature/user-authentication", result)
        self.assertIn("🧠 62%", result)
        self.assertIn("Claude", result)

    def test_sprint_completion_scenario(self):
        """
        Test formatting sprint completion scenario.
        
        Verifies overflow handling when tasks exceed plan.
        """
        formatter = NormalModeFormatter()
        
        data = StatusLineData(
            version="v2.0",
            tasks_completed=25,
            tasks_total=20,  # Completed more than planned
            elapsed_time="04:30",
            planned_time="4:00",  # Over time
            remaining_budget="0:00h",
            git_branch="release/v2.0",
            context_usage=95.0,  # High context usage
            model_name="GPT-4"
        )
        
        result = formatter.format(data)
        
        # Check overflow handling
        self.assertIn("25/20", result)
        self.assertIn("125%", result)  # Over 100%
        self.assertIn("🚨", result)  # Should have warnings
        
    def test_minimal_session_start(self):
        """
        Test formatting at session start with minimal data.
        
        Verifies clean display with mostly zero values.
        """
        formatter = NormalModeFormatter()
        
        data = StatusLineData(
            version="v2.0",
            tasks_completed=0,
            tasks_total=10,
            elapsed_time="00:00",
            planned_time="2:00",
            remaining_budget="2:00h",
            git_branch="main",
            context_usage=0.0,
            model_name="Claude"
        )
        
        result = formatter.format(data)
        
        # Verify clean initial state
        self.assertIn("📋 0/10", result)
        self.assertIn("0%", result)
        self.assertIn("⏱ 00:00/2:00", result)
        self.assertIn("💰 2:00h left", result)
        self.assertNotIn("⚠️", result)  # No warnings at start
        self.assertNotIn("🚨", result)


class TestGetComponentInfo(unittest.TestCase):
    """
    Tests for component information method.
    
    Verifies component descriptions are provided.
    """

    def test_get_component_info_completeness(self):
        """
        Test component info includes all components.
        
        Verifies all emoji indicators are documented.
        """
        formatter = NormalModeFormatter()
        info = formatter.get_component_info()
        
        # Check all emojis are documented
        self.assertIn("⚩", info)
        self.assertIn("📋", info)
        self.assertIn("⏱", info)
        self.assertIn("💰", info)
        self.assertIn("🌿", info)
        self.assertIn("🧠", info)
        self.assertIn("Model", info)

    def test_get_component_info_descriptions(self):
        """
        Test component descriptions are meaningful.
        
        Verifies descriptions provide useful information.
        """
        formatter = NormalModeFormatter()
        info = formatter.get_component_info()
        
        # Check descriptions are not empty
        for key, description in info.items():
            self.assertIsNotNone(description)
            self.assertGreater(len(description), 0)
            # Check description is informative (contains relevant keywords)
            if key == "⚩":
                self.assertIn("FlowForge", description)
            elif key == "📋":
                self.assertIn("Task", description)


if __name__ == "__main__":
    unittest.main()