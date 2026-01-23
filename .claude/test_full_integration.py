#!/usr/bin/env python3
"""
Full Integration Test for Enhanced Compact Format.

Tests the complete integration of the enhanced statusline format
through the entire pipeline from statusline.py to formatted output.

Author: FlowForge Team
Since: 2.1.0
"""

import json
import sys
import unittest
from unittest.mock import Mock, patch, MagicMock
from io import StringIO

# Import the components
from statusline import FlowForgeStatusLine, FormattingContext, MilestoneModeFormatterAdapter
from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData


class TestFullIntegration(unittest.TestCase):
    """Test full integration of enhanced format through the statusline system."""

    def setUp(self):
        """Set up test fixtures."""
        self.statusline = FlowForgeStatusLine()
        self.adapter = MilestoneModeFormatterAdapter(self.statusline)

    def test_adapter_uses_enhanced_format(self):
        """Test that the adapter now uses format_enhanced method."""
        context = FormattingContext(
            issue_id="423",
            project_name="FlowForge",
            version="v2.1",
            task_data={"completed": 3, "total": 4},
            milestone_data={
                "name": "v2.1-statusline-milestone-mode",
                "time_remaining": "30m",
                "tasks_completed": 3,
                "tasks_total": 4
            },
            git_branch="feature/423-work",
            context_usage=85.0,
            model_name="Opus 4.1",
            mode="milestone",
            timer_active=True
        )

        # Format using the adapter
        result = self.adapter.format(context)

        # Should use enhanced format with icons
        self.assertIn("[FlowForge]", result)
        self.assertIn("🎯", result)
        self.assertIn("v2.1-statusline-milestone-mode", result)
        self.assertIn("(3/4)", result)
        self.assertIn("⏱️", result)
        self.assertIn("30m", result)
        self.assertIn("🌿", result)
        self.assertIn("feature/423-work", result)
        self.assertIn("📊 85%", result)
        self.assertIn("Opus 4.1", result)
        self.assertIn("● Active", result)

    def test_full_pipeline_with_json_input(self):
        """Test full pipeline from JSON input to formatted output."""
        # Simulate JSON input
        json_input = {
            "model": "Opus 4.1",
            "issue": "423",
            "project": "FlowForge",
            "version": "v2.1",
            "milestone": {
                "name": "v2.1-statusline-milestone-mode",
                "tasks_completed": 3,
                "tasks_total": 4,
                "time_remaining": "45m"
            },
            "branch": "feature/423-work",
            "context_usage": 75.5,
            "timer_active": True,
            "mode": "milestone"
        }

        # Mock the helpers
        with patch.object(self.statusline.helpers, 'get_session_elapsed_time', return_value='00:45'):
            with patch.object(self.statusline.helpers, 'extract_track_name', return_value='Feature'):
                # Create context from JSON
                context = FormattingContext(
                    issue_id=json_input.get('issue'),
                    project_name=json_input.get('project'),
                    version=json_input.get('version'),
                    milestone_data=json_input.get('milestone'),
                    git_branch=json_input.get('branch'),
                    context_usage=json_input.get('context_usage', 0),
                    model_name=json_input.get('model'),
                    mode=json_input.get('mode', 'normal'),
                    timer_active=json_input.get('timer_active', True)
                )

                # Format using adapter
                result = self.adapter.format(context)

                # Verify enhanced format output
                self.assertIn("[FlowForge] 🎯", result)
                self.assertIn("(3/4)", result)
                self.assertIn("⏱️ 45m", result)
                self.assertIn("🌿 feature/423-work", result)
                self.assertIn("📊 75%", result)  # Should show context usage
                self.assertIn("Opus 4.1", result)
                self.assertIn("● Active", result)

    def test_inactive_timer_display(self):
        """Test that inactive timer shows correctly."""
        context = FormattingContext(
            milestone_data={"name": "test-milestone"},
            timer_active=False
        )

        result = self.adapter.format(context)
        self.assertIn("○ Inactive", result)
        self.assertNotIn("● Active", result)

    def test_no_context_usage_omits_icon(self):
        """Test that zero context usage omits the 📊 section."""
        context = FormattingContext(
            milestone_data={"name": "test-milestone"},
            context_usage=0
        )

        result = self.adapter.format(context)
        self.assertNotIn("📊", result)

    def test_fallback_to_default_values(self):
        """Test graceful fallback when data is missing."""
        context = FormattingContext()  # Minimal context

        result = self.adapter.format(context)

        # Should still produce valid output
        self.assertIn("[FlowForge]", result)
        self.assertIn("🎯", result)
        self.assertIn("(0/0)", result)  # Default task counts
        self.assertIn("⏱️", result)
        self.assertIn("🌿 main", result)  # Default branch

    def test_milestone_specific_vs_general_tasks(self):
        """Test priority of milestone-specific task counts over general counts."""
        # Case 1: With milestone data - should use milestone counts
        context1 = FormattingContext(
            task_data={"completed": 10, "total": 20},  # General project tasks
            milestone_data={
                "name": "milestone-1",
                "tasks_completed": 3,  # Milestone-specific
                "tasks_total": 5
            }
        )

        result1 = self.adapter.format(context1)
        self.assertIn("(3/5)", result1)  # Should use milestone counts
        self.assertNotIn("(10/20)", result1)

        # Case 2: Without milestone data - should use general counts
        context2 = FormattingContext(
            task_data={"completed": 10, "total": 20}
            # No milestone_data
        )

        result2 = self.adapter.format(context2)
        self.assertIn("(10/20)", result2)  # Should use general counts

    def test_time_conversion_in_pipeline(self):
        """Test various time formats through the full pipeline."""
        time_tests = [
            ("30m", "30m"),
            ("1h", "60m"),
            ("2.5h", "150m"),
            ("01:30", "90m")
        ]

        for input_time, expected_output in time_tests:
            context = FormattingContext(
                milestone_data={
                    "name": "time-test",
                    "time_remaining": input_time
                }
            )

            result = self.adapter.format(context)
            self.assertIn(f"⏱️ {expected_output}", result,
                         f"Failed for input {input_time}")


class TestSystemIntegration(unittest.TestCase):
    """Test integration with the FlowForgeStatusLine system."""

    @patch('statusline.get_formatter_modules')
    def test_lazy_loading_formatter(self, mock_get_modules):
        """Test that formatter is lazy loaded correctly."""
        # Mock the module loading
        mock_modules = {
            'MilestoneModeFormatter': MilestoneModeFormatter
        }
        mock_get_modules.return_value = mock_modules

        statusline = FlowForgeStatusLine()
        adapter = MilestoneModeFormatterAdapter(statusline)

        # Formatter should not be loaded yet
        self.assertIsNone(adapter.formatter)

        # First format call should load formatter
        context = FormattingContext(
            milestone_data={"name": "test"}
        )
        result = adapter.format(context)

        # Formatter should now be loaded
        self.assertIsNotNone(adapter.formatter)
        self.assertIsInstance(adapter.formatter, MilestoneModeFormatter)

        # Should produce enhanced format
        self.assertIn("🎯", result)

    def test_performance_multiple_formats(self):
        """Test performance with multiple format calls."""
        adapter = MilestoneModeFormatterAdapter(FlowForgeStatusLine())

        contexts = [
            FormattingContext(
                milestone_data={
                    "name": f"milestone-{i}",
                    "tasks_completed": i,
                    "tasks_total": 10
                },
                context_usage=i * 10
            )
            for i in range(10)
        ]

        results = []
        for context in contexts:
            result = adapter.format(context)
            results.append(result)
            # Each should have unique milestone name
            self.assertIn(f"milestone-{contexts.index(context)}", result)

        # All results should be unique
        self.assertEqual(len(set(results)), 10)


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)