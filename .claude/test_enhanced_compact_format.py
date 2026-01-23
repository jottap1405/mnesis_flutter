#!/usr/bin/env python3
"""
Test Suite for Enhanced Compact Format Implementation.

Tests the enhanced statusline format with icons and all components:
[FlowForge] 🎯 v2.1-statusline-milestone-mode (3/4) ⏱️ 30m | 🌿 feature/423-work | 📊 85% | Opus 4.1 | ● Active

Following TDD principles (Rule #3), these tests are written BEFORE implementation.
All tests must pass with 80%+ coverage as per FlowForge standards.

Author: FlowForge Team
Since: 2.1.0
"""

import unittest
from unittest.mock import Mock, patch
from dataclasses import dataclass
from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData


class TestEnhancedCompactFormat(unittest.TestCase):
    """
    Test suite for enhanced compact statusline format.

    Tests all components, icons, and formatting requirements for the
    enhanced milestone mode display with proper separation and visual indicators.
    """

    def setUp(self):
        """Set up test fixtures."""
        self.formatter = MilestoneModeFormatter()

        # Standard test data
        self.test_data = MilestoneStatusLineData(
            milestone_name="v2.1-statusline-milestone-mode",
            track_name="Feature",
            tasks_completed=3,
            tasks_total=4,
            current_session_time="00:30",
            eta_remaining="30m",
            git_branch="feature/423-work",
            model_name="Opus 4.1",
            context_usage=85.0
        )

    def test_basic_enhanced_format(self):
        """Test basic enhanced format with all components."""
        result = self.formatter.format_enhanced(self.test_data)

        # Check presence of all required components
        self.assertIn("[FlowForge]", result)
        self.assertIn("🎯", result)
        self.assertIn("v2.1-statusline-milestone-mode", result)
        self.assertIn("(3/4)", result)
        self.assertIn("⏱️", result)
        self.assertIn("30m", result)
        self.assertIn("🌿", result)
        self.assertIn("feature/423-work", result)
        self.assertIn("📊", result)
        self.assertIn("85%", result)
        self.assertIn("Opus 4.1", result)
        self.assertIn("●", result)  # Active timer

    def test_format_structure(self):
        """Test the exact format structure and order."""
        result = self.formatter.format_enhanced(self.test_data)

        expected = "[FlowForge] 🎯 v2.1-statusline-milestone-mode (3/4) ⏱️ 30m | 🌿 feature/423-work | 📊 85% | Opus 4.1 | ● Active"
        self.assertEqual(result, expected)

    def test_inactive_timer_display(self):
        """Test inactive timer shows ○ instead of ●."""
        # Create data with inactive timer
        data = MilestoneStatusLineData(
            milestone_name="test-milestone",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining="15m",
            git_branch="main",
            model_name="Claude",
            timer_active=False  # Inactive timer
        )

        result = self.formatter.format_enhanced(data)
        self.assertIn("○ Inactive", result)
        self.assertNotIn("● Active", result)

    def test_no_context_usage(self):
        """Test format without context usage (should omit 📊 section)."""
        data = MilestoneStatusLineData(
            milestone_name="test-milestone",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining="15m",
            git_branch="main",
            model_name="Claude",
            context_usage=0  # No context usage
        )

        result = self.formatter.format_enhanced(data)
        self.assertNotIn("📊", result)
        self.assertNotIn("0%", result)

        # Should have proper structure without context part
        self.assertIn("[FlowForge] 🎯 test-milestone (1/2) ⏱️ 15m | 🌿 main | Claude |", result)

    def test_edge_case_long_milestone_name(self):
        """Test handling of very long milestone names."""
        data = MilestoneStatusLineData(
            milestone_name="very-long-milestone-name-that-exceeds-normal-length-limits-for-display",
            tasks_completed=5,
            tasks_total=10,
            eta_remaining="2h",
            git_branch="feature/long",
            model_name="GPT-4"
        )

        result = self.formatter.format_enhanced(data)
        # Should truncate but maintain format
        self.assertIn("[FlowForge] 🎯", result)
        self.assertIn("(5/10)", result)
        self.assertIn("⏱️", result)

    def test_time_format_conversions(self):
        """Test various time format conversions in enhanced display."""
        test_cases = [
            ("30m", "30m"),
            ("1h", "60m"),
            ("2.5h", "150m"),
            ("0.5h", "30m"),
            ("00:45", "45m"),
            ("01:30", "90m")
        ]

        for input_time, expected_display in test_cases:
            data = MilestoneStatusLineData(
                milestone_name="test",
                tasks_completed=1,
                tasks_total=2,
                eta_remaining=input_time,
                git_branch="main",
                model_name="Claude"
            )

            result = self.formatter.format_enhanced(data)
            self.assertIn(f"⏱️ {expected_display}", result,
                         f"Failed for input {input_time}")

    def test_separator_consistency(self):
        """Test that pipe separators are consistently used."""
        result = self.formatter.format_enhanced(self.test_data)

        # Count pipe separators
        pipe_count = result.count(" | ")
        self.assertEqual(pipe_count, 4, "Should have exactly 4 pipe separators")

        # Check spacing around pipes
        self.assertNotIn("  |", result)  # No double spaces before pipe
        self.assertNotIn("|  ", result)  # No double spaces after pipe

    def test_icon_spacing(self):
        """Test proper spacing around icons."""
        result = self.formatter.format_enhanced(self.test_data)

        # Icons should have proper spacing
        self.assertIn("🎯 v2.1", result)  # Space after milestone icon
        self.assertIn(") ⏱️ ", result)    # Space before and after time icon
        self.assertIn("| 🌿 ", result)    # Space after branch icon
        self.assertIn("| 📊 ", result)    # Space after context icon

    def test_missing_data_graceful_handling(self):
        """Test graceful handling of missing data fields."""
        # Test with minimal data
        data = MilestoneStatusLineData(
            milestone_name="minimal",
            tasks_completed=0,
            tasks_total=0
        )

        result = self.formatter.format_enhanced(data)

        # Should still have basic structure
        self.assertIn("[FlowForge]", result)
        self.assertIn("🎯 minimal", result)
        self.assertIn("(0/0)", result)
        self.assertIn("⏱️ 0m", result)  # Default time
        self.assertIn("🌿 main", result)  # Default branch

    def test_high_context_usage_warning(self):
        """Test context usage display with high percentage."""
        data = MilestoneStatusLineData(
            milestone_name="test",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining="15m",
            git_branch="main",
            model_name="Claude",
            context_usage=95.0  # High context usage
        )

        result = self.formatter.format_enhanced(data)
        self.assertIn("📊 95%", result)

    def test_unicode_handling(self):
        """Test proper handling of unicode in various fields."""
        data = MilestoneStatusLineData(
            milestone_name="milestone-ünicode",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining="15m",
            git_branch="feature/ümlaut",
            model_name="Cláude"
        )

        result = self.formatter.format_enhanced(data)
        self.assertIn("milestone-ünicode", result)
        self.assertIn("feature/ümlaut", result)
        self.assertIn("Cláude", result)

    def test_performance_with_large_numbers(self):
        """Test handling of large task numbers."""
        data = MilestoneStatusLineData(
            milestone_name="large-project",
            tasks_completed=999,
            tasks_total=1000,
            eta_remaining="1m",
            git_branch="main",
            model_name="Claude"
        )

        result = self.formatter.format_enhanced(data)
        self.assertIn("(999/1000)", result)

    def test_zero_total_tasks(self):
        """Test handling when total tasks is zero."""
        data = MilestoneStatusLineData(
            milestone_name="empty-milestone",
            tasks_completed=0,
            tasks_total=0,
            eta_remaining="0m",
            git_branch="main",
            model_name="Claude"
        )

        result = self.formatter.format_enhanced(data)
        self.assertIn("(0/0)", result)
        self.assertIn("⏱️ 0m", result)

    def test_model_name_variations(self):
        """Test various model name formats."""
        model_names = [
            "Opus 4.1",
            "Claude-3-Opus",
            "GPT-4-Turbo",
            "Sonnet",
            "Haiku"
        ]

        for model in model_names:
            data = MilestoneStatusLineData(
                milestone_name="test",
                tasks_completed=1,
                tasks_total=2,
                eta_remaining="15m",
                git_branch="main",
                model_name=model
            )

            result = self.formatter.format_enhanced(data)
            self.assertIn(model, result)

    def test_branch_name_truncation(self):
        """Test truncation of very long branch names."""
        data = MilestoneStatusLineData(
            milestone_name="test",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining="15m",
            git_branch="feature/very-long-branch-name-that-exceeds-reasonable-display-limits-and-should-be-truncated",
            model_name="Claude"
        )

        result = self.formatter.format_enhanced(data)
        # Should contain branch but be reasonable length
        self.assertIn("🌿", result)
        self.assertLess(len(result), 200, "Total length should be reasonable")


class TestEnhancedFormatIntegration(unittest.TestCase):
    """Integration tests for enhanced format with real data sources."""

    @patch('milestone_mode_formatter.get_git_branch')
    @patch('milestone_mode_formatter.MilestoneDetector')
    def test_integration_with_milestone_detector(self, mock_detector, mock_git):
        """Test integration with MilestoneDetector."""
        # Mock milestone detector response
        mock_detector.return_value.detect_milestone_mode.return_value = Mock(
            name="v2.1-statusline-milestone-mode",
            purpose="Feature Development",
            branch="feature/423-work"
        )

        # Mock git branch
        mock_git.return_value = "feature/423-work"

        formatter = MilestoneModeFormatter()
        result = formatter.format_enhanced_with_context()

        # Verify enhanced format is used
        self.assertIn("[FlowForge]", result)
        self.assertIn("🎯", result)
        self.assertIn("🌿 feature/423-work", result)

    def test_backwards_compatibility(self):
        """Test that old format method still works."""
        formatter = MilestoneModeFormatter()
        data = MilestoneStatusLineData(
            milestone_name="v2.1-statusline-milestone-mode",
            tasks_completed=3,
            tasks_total=4,
            eta_remaining="30m"
        )

        # Old format should still work
        old_result = formatter.format(data)
        self.assertIn("[FlowForge]", old_result)
        self.assertIn("v2.1-statusline-milestone-mode", old_result)
        self.assertIn("(3/4)", old_result)

        # New enhanced format should be different
        new_result = formatter.format_enhanced(data)
        self.assertNotEqual(old_result, new_result)
        self.assertIn("🎯", new_result)  # Enhanced has icons


if __name__ == '__main__':
    # Run tests with coverage reporting
    unittest.main(verbosity=2)