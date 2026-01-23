#!/usr/bin/env python3
"""
Comprehensive test suite for progress bar functionality.

Tests all aspects of the progress bar implementation including:
- Milestone progress bars
- Context usage progress bars
- Complete statusline formatting
- Edge cases and error handling

Author: FlowForge Team
Since: 2.1.0
"""

import json
import unittest
from unittest.mock import patch, MagicMock
import sys
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, str(Path(__file__).parent))

from milestone_mode_formatter import (
    MilestoneModeFormatter,
    MilestoneStatusLineData
)


class TestProgressBarImplementation(unittest.TestCase):
    """Complete test suite for progress bar implementation."""

    def setUp(self):
        """Set up test fixtures."""
        self.formatter = MilestoneModeFormatter()

    def test_complete_statusline_format(self):
        """Test the complete statusline format with all progress bars."""
        data = MilestoneStatusLineData(
            milestone_name="v2.1-statusline-milestone-mode",
            tasks_completed=5,
            tasks_total=10,
            eta_remaining="150m",
            git_branch="feature/423-work",
            model_name="Opus 4.1",
            context_usage=85.0,
            timer_active=True
        )

        result = self.formatter.format_enhanced_with_progress_bars(data)

        # Verify all components are present
        self.assertIn("[FlowForge]", result)
        self.assertIn("🎯 v2.1-statusline-milestone-mode", result)
        self.assertIn("(5/10)", result)
        self.assertIn("[█████░░░░░]", result)
        self.assertIn("50%", result)
        self.assertIn("⏱️ 150m", result)
        self.assertIn("🌿 feature/423-work", result)
        self.assertIn("📊 85%", result)
        self.assertIn("[████████░░]", result)
        self.assertIn("Opus 4.1", result)
        self.assertIn("● Active", result)

    def test_progress_bar_calculations(self):
        """Test progress bar calculations for various percentages."""
        test_cases = [
            (0, "[░░░░░░░░░░]"),
            (10, "[█░░░░░░░░░]"),
            (25, "[██░░░░░░░░]"),
            (33, "[███░░░░░░░]"),
            (50, "[█████░░░░░]"),
            (66, "[██████░░░░]"),
            (75, "[███████░░░]"),
            (85, "[████████░░]"),
            (90, "[█████████░]"),
            (100, "[██████████]"),
        ]

        for percentage, expected in test_cases:
            with self.subTest(percentage=percentage):
                result = self.formatter._create_progress_bar(percentage)
                self.assertEqual(result, expected,
                               f"Progress bar for {percentage}% incorrect")

    def test_milestone_percentage_calculation(self):
        """Test milestone completion percentage calculation."""
        test_cases = [
            (0, 10, 0),
            (1, 10, 10),
            (3, 10, 30),
            (5, 10, 50),
            (7, 10, 70),
            (10, 10, 100),
            (11, 10, 110),  # Over 100% should be handled
        ]

        for completed, total, expected_pct in test_cases:
            with self.subTest(completed=completed, total=total):
                data = MilestoneStatusLineData(
                    milestone_name="test",
                    tasks_completed=completed,
                    tasks_total=total,
                    eta_remaining="0m",
                    git_branch="main",
                    model_name="Model",
                    context_usage=0
                )

                result = self.formatter.format_enhanced_with_progress_bars(data)

                # Check that the correct percentage appears
                if total > 0:
                    # Don't cap at 100% - show actual percentage even if over 100%
                    actual_pct = int((completed / total) * 100)
                    self.assertIn(f"{actual_pct}%", result)

    def test_context_usage_display(self):
        """Test context usage display with various percentages."""
        test_cases = [0, 25, 50, 75, 85, 90, 95, 100]

        for context_pct in test_cases:
            with self.subTest(context_pct=context_pct):
                data = MilestoneStatusLineData(
                    milestone_name="test",
                    tasks_completed=5,
                    tasks_total=10,
                    eta_remaining="0m",
                    git_branch="main",
                    model_name="Model",
                    context_usage=context_pct
                )

                result = self.formatter.format_enhanced_with_progress_bars(data)

                if context_pct > 0:
                    # Should contain context percentage and icon
                    self.assertIn("📊", result)
                    self.assertIn(f"{int(context_pct)}%", result)

                    # Should contain appropriate progress bar
                    filled_blocks = int(10 * context_pct / 100)
                    self.assertTrue(
                        "█" * filled_blocks in result or
                        "█" * max(0, filled_blocks - 1) in result,
                        f"Progress bar not found for {context_pct}%"
                    )

    def test_empty_data_handling(self):
        """Test handling of empty or minimal data."""
        data = MilestoneStatusLineData()

        result = self.formatter.format_enhanced_with_progress_bars(data)

        # Should still produce valid output
        self.assertIn("[FlowForge]", result)
        self.assertIn("(0/0)", result)  # Default task counts
        self.assertIn("main", result)  # Default branch
        self.assertIn("Model", result)  # Default model name

    def test_time_format_conversion(self):
        """Test time format conversion for display."""
        test_cases = [
            ("30m", "30m"),
            ("1h", "60m"),
            ("1.5h", "90m"),
            ("2h 30m", "150m"),
            ("2.5h", "150m"),
            ("0h", "0m"),
        ]

        for input_time, expected_output in test_cases:
            with self.subTest(input_time=input_time):
                data = MilestoneStatusLineData(
                    milestone_name="test",
                    tasks_completed=5,
                    tasks_total=10,
                    eta_remaining=input_time,
                    git_branch="main",
                    model_name="Model"
                )

                result = self.formatter.format_enhanced_with_progress_bars(data)

                # Check that the converted time appears
                self.assertIn(f"⏱️ {expected_output}", result)

    def test_timer_status_display(self):
        """Test timer active/inactive status display."""
        # Test active timer
        data_active = MilestoneStatusLineData(
            milestone_name="test",
            tasks_completed=5,
            tasks_total=10,
            timer_active=True
        )

        result_active = self.formatter.format_enhanced_with_progress_bars(data_active)
        self.assertIn("● Active", result_active)

        # Test inactive timer
        data_inactive = MilestoneStatusLineData(
            milestone_name="test",
            tasks_completed=5,
            tasks_total=10,
            timer_active=False
        )

        result_inactive = self.formatter.format_enhanced_with_progress_bars(data_inactive)
        self.assertIn("○ Inactive", result_inactive)

    def test_long_strings_truncation(self):
        """Test that long strings are handled properly."""
        data = MilestoneStatusLineData(
            milestone_name="v" * 100,  # Very long milestone name
            tasks_completed=5,
            tasks_total=10,
            eta_remaining="150m",
            git_branch="feature/" + "x" * 100,  # Very long branch name
            model_name="Model" * 10,  # Long model name
            context_usage=85.0
        )

        result = self.formatter.format_enhanced_with_progress_bars(data)

        # Should produce valid output without breaking
        self.assertIsNotNone(result)
        self.assertIn("[FlowForge]", result)

        # Verify truncation occurred (indirectly by checking reasonable length)
        self.assertLess(len(result), 500, "Output should be reasonably sized")

    def test_division_by_zero(self):
        """Test handling of division by zero in percentage calculations."""
        data = MilestoneStatusLineData(
            milestone_name="test",
            tasks_completed=5,
            tasks_total=0,  # This could cause division by zero
            context_usage=85.0
        )

        # Should not raise an exception
        try:
            result = self.formatter.format_enhanced_with_progress_bars(data)
            self.assertIsNotNone(result)
            self.assertIn("0%", result)  # Should show 0% when total is 0
        except ZeroDivisionError:
            self.fail("Division by zero not handled properly")

    def test_negative_values(self):
        """Test handling of negative values."""
        data = MilestoneStatusLineData(
            milestone_name="test",
            tasks_completed=-5,  # Negative completed
            tasks_total=10,
            context_usage=-50  # Negative context usage
        )

        result = self.formatter.format_enhanced_with_progress_bars(data)

        # Should handle negatives gracefully
        self.assertIsNotNone(result)
        self.assertIn("[░░░░░░░░░░]", result)  # Empty progress bar for negative


class TestIntegrationScenarios(unittest.TestCase):
    """Integration test scenarios."""

    def test_realistic_scenario_early_milestone(self):
        """Test realistic scenario: early in milestone."""
        formatter = MilestoneModeFormatter()

        data = MilestoneStatusLineData(
            milestone_name="v2.2-authentication-refactor",
            tasks_completed=2,
            tasks_total=15,
            eta_remaining="8h",
            git_branch="feature/auth-refactor",
            model_name="Claude 3 Opus",
            context_usage=23.5,
            timer_active=True
        )

        result = formatter.format_enhanced_with_progress_bars(data)

        # Verify realistic output
        self.assertIn("2/15", result)
        self.assertIn("13%", result)  # 2/15 = 13.33%
        self.assertIn("480m", result)  # 8h = 480m
        self.assertIn("23%", result)  # Context usage

    def test_realistic_scenario_near_completion(self):
        """Test realistic scenario: near milestone completion."""
        formatter = MilestoneModeFormatter()

        data = MilestoneStatusLineData(
            milestone_name="v2.1-bug-fixes",
            tasks_completed=18,
            tasks_total=20,
            eta_remaining="45m",
            git_branch="hotfix/critical-bugs",
            model_name="GPT-4",
            context_usage=92.0,
            timer_active=True
        )

        result = formatter.format_enhanced_with_progress_bars(data)

        # Verify near-completion state
        self.assertIn("18/20", result)
        self.assertIn("90%", result)  # 18/20 = 90%
        self.assertIn("45m", result)
        self.assertIn("92%", result)  # High context usage
        self.assertIn("[█████████░]", result)  # 90% progress bar


if __name__ == "__main__":
    # Run tests with verbosity
    unittest.main(verbosity=2)