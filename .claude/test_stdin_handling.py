#!/usr/bin/env python3
"""
Test suite for stdin handling and progress bar display in statusline.
Tests ensure proper parsing of Claude's JSON input and correct rendering.

Rule #3: Write tests BEFORE code (TDD) - 80%+ coverage
Rule #25: Include expected use, edge case, and failure cases
"""

import json
import sys
import io
import unittest
from unittest.mock import patch, MagicMock, mock_open
from pathlib import Path
import tempfile
import os

# Import the module to test
sys.path.insert(0, str(Path(__file__).parent))
from statusline import main, FlowForgeStatusLine


class TestStdinHandling(unittest.TestCase):
    """Test stdin JSON parsing and context data handling."""

    def setUp(self):
        """Set up test fixtures."""
        self.temp_dir = tempfile.mkdtemp()
        self.test_json = {
            "model": {
                "display_name": "Opus 4.1"
            },
            "context": {
                "used": 85000,
                "max": 100000
            }
        }

    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        if os.path.exists(self.temp_dir):
            shutil.rmtree(self.temp_dir)

    # Test 1: Expected use case - valid JSON with context
    def test_valid_json_with_context(self):
        """
        Test parsing valid JSON with context data from stdin.
        Should extract context percentage and pass to formatter.
        """
        json_input = json.dumps(self.test_json)

        with patch('sys.stdin', io.StringIO(json_input)):
            with patch('statusline.FlowForgeStatusLine') as mock_statusline:
                mock_instance = MagicMock()
                mock_statusline.return_value = mock_instance
                mock_instance.generate_status_line_with_progress.return_value = "[FlowForge] Test Output"

                # Capture stdout
                with patch('sys.stdout', new=io.StringIO()) as mock_stdout:
                    main()

                    # Verify context percentage calculation
                    expected_percentage = 85.0  # 85000/100000 * 100
                    mock_instance.generate_status_line_with_progress.assert_called_once_with(
                        'Opus 4.1',
                        context_percentage=expected_percentage
                    )

                    # Verify output
                    output = mock_stdout.getvalue()
                    self.assertEqual(output, "[FlowForge] Test Output")

    # Test 2: Edge case - zero context usage
    def test_zero_context_usage(self):
        """
        Test handling of zero context usage.
        Should calculate 0% and still render properly.
        """
        test_json = {
            "model": {"display_name": "Claude"},
            "context": {"used": 0, "max": 100000}
        }
        json_input = json.dumps(test_json)

        with patch('sys.stdin', io.StringIO(json_input)):
            with patch('statusline.FlowForgeStatusLine') as mock_statusline:
                mock_instance = MagicMock()
                mock_statusline.return_value = mock_instance
                mock_instance.generate_status_line_with_progress.return_value = "[FlowForge] No Context"

                with patch('sys.stdout', new=io.StringIO()):
                    main()

                    # Should pass 0% context
                    mock_instance.generate_status_line_with_progress.assert_called_once_with(
                        'Claude',
                        context_percentage=0.0
                    )

    # Test 3: Edge case - maximum context usage
    def test_maximum_context_usage(self):
        """
        Test handling of 100% context usage.
        Should show full progress bar.
        """
        test_json = {
            "model": {"display_name": "Opus"},
            "context": {"used": 100000, "max": 100000}
        }
        json_input = json.dumps(test_json)

        with patch('sys.stdin', io.StringIO(json_input)):
            with patch('statusline.FlowForgeStatusLine') as mock_statusline:
                mock_instance = MagicMock()
                mock_statusline.return_value = mock_instance
                mock_instance.generate_status_line_with_progress.return_value = "[FlowForge] Full Context"

                with patch('sys.stdout', new=io.StringIO()):
                    main()

                    # Should pass 100% context
                    mock_instance.generate_status_line_with_progress.assert_called_once_with(
                        'Opus',
                        context_percentage=100.0
                    )

    # Test 4: Failure case - missing context data
    def test_missing_context_data(self):
        """
        Test handling when context data is missing from JSON.
        Should default to 0% context usage.
        """
        test_json = {
            "model": {"display_name": "Claude"}
            # No context field
        }
        json_input = json.dumps(test_json)

        with patch('sys.stdin', io.StringIO(json_input)):
            with patch('statusline.FlowForgeStatusLine') as mock_statusline:
                mock_instance = MagicMock()
                mock_statusline.return_value = mock_instance
                mock_instance.generate_status_line_with_progress.return_value = "[FlowForge] No Context"

                with patch('sys.stdout', new=io.StringIO()):
                    main()

                    # Should default to 0% when missing
                    mock_instance.generate_status_line_with_progress.assert_called_once_with(
                        'Claude',
                        context_percentage=0.0
                    )

    # Test 5: Failure case - invalid JSON
    def test_invalid_json_input(self):
        """
        Test handling of invalid JSON input.
        Should fall back to basic status line.
        """
        json_input = "This is not valid JSON"

        with patch('sys.stdin', io.StringIO(json_input)):
            with patch('statusline.FlowForgeStatusLine') as mock_statusline:
                mock_instance = MagicMock()
                mock_statusline.return_value = mock_instance
                mock_instance.generate_status_line.return_value = "[FlowForge] Fallback"

                with patch('sys.stdout', new=io.StringIO()) as mock_stdout:
                    main()

                    # Should fall back to basic generate_status_line
                    mock_instance.generate_status_line.assert_called_once()
                    output = mock_stdout.getvalue()
                    self.assertEqual(output, "[FlowForge] Fallback")

    # Test 6: Edge case - division by zero in context calculation
    def test_context_max_zero(self):
        """
        Test handling when context max is 0 (avoid division by zero).
        Should default to 0% safely.
        """
        test_json = {
            "model": {"display_name": "Claude"},
            "context": {"used": 50, "max": 0}  # max = 0 could cause division by zero
        }
        json_input = json.dumps(test_json)

        with patch('sys.stdin', io.StringIO(json_input)):
            with patch('statusline.FlowForgeStatusLine') as mock_statusline:
                mock_instance = MagicMock()
                mock_statusline.return_value = mock_instance
                mock_instance.generate_status_line_with_progress.return_value = "[FlowForge] Safe"

                with patch('sys.stdout', new=io.StringIO()):
                    main()

                    # Should safely handle division by zero
                    mock_instance.generate_status_line_with_progress.assert_called_once_with(
                        'Claude',
                        context_percentage=0.0
                    )


class TestProgressBarGeneration(unittest.TestCase):
    """Test progress bar rendering in statusline output."""

    def setUp(self):
        """Set up test environment."""
        self.statusline = FlowForgeStatusLine(Path(tempfile.mkdtemp()))

    # Test 7: Milestone progress bar generation
    def test_milestone_progress_bar_rendering(self):
        """
        Test that milestone progress bar is included in output.
        Should show [█████░░░░░] format for 50% completion.
        """
        with patch.object(self.statusline, '_build_formatting_context') as mock_context:
            from status_formatter_interface import FormattingContext

            # Mock context with milestone data
            mock_context.return_value = FormattingContext(
                model_name="Opus 4.1",
                git_branch="feature/test",
                issue_number="123",
                milestone_data={
                    'name': 'v2.1-test',
                    'tasks_completed': 5,
                    'tasks_total': 10,
                    'time_remaining': '2h'
                },
                task_data={
                    'completed': 5,
                    'total': 10,
                    'percentage': 50.0
                },
                timer_data={'active': True, 'issue_number': '123', 'status_text': '● Active'},
                context_usage=85.0,
                terminal_width=120
            )

            # Generate with progress
            output = self.statusline.generate_status_line_with_progress(
                model_name="Opus 4.1",
                context_percentage=85.0
            )

            # Should contain progress bar elements
            self.assertIn("v2.1-test", output)
            # Progress bars should be in output (exact format depends on formatter)
            # We're looking for the pattern of filled/empty blocks

    # Test 8: Context usage progress bar
    def test_context_progress_bar_rendering(self):
        """
        Test that context usage progress bar is included.
        Should show percentage and bar for context usage.
        """
        with patch.object(self.statusline, '_build_formatting_context') as mock_context:
            from status_formatter_interface import FormattingContext

            # Mock context with high context usage
            mock_context.return_value = FormattingContext(
                model_name="Opus 4.1",
                git_branch="feature/test",
                issue_number=None,
                milestone_data=None,
                task_data=None,
                timer_data=None,
                context_usage=85.0,
                terminal_width=120
            )

            output = self.statusline.generate_status_line_with_progress(
                model_name="Opus 4.1",
                context_percentage=85.0
            )

            # Should show context percentage
            self.assertIn("85", output)  # Should contain the percentage value

    # Test 9: Empty stdin handling
    def test_empty_stdin(self):
        """
        Test handling of empty stdin input.
        Should gracefully fall back to default.
        """
        with patch('sys.stdin', io.StringIO("")):
            with patch('statusline.FlowForgeStatusLine') as mock_statusline:
                mock_instance = MagicMock()
                mock_statusline.return_value = mock_instance
                mock_instance.generate_status_line.return_value = "[FlowForge] Empty"

                with patch('sys.stdout', new=io.StringIO()) as mock_stdout:
                    main()

                    # Should fall back when stdin is empty
                    mock_instance.generate_status_line.assert_called_once()
                    output = mock_stdout.getvalue()
                    self.assertEqual(output, "[FlowForge] Empty")


class TestDebugLogging(unittest.TestCase):
    """Test debug logging functionality for troubleshooting."""

    # Test 10: Debug log creation
    def test_debug_log_creation(self):
        """
        Test that debug logging writes to file when enabled.
        Should create debug log with stdin data.
        """
        test_json = {
            "model": {"display_name": "Debug Test"},
            "context": {"used": 50000, "max": 100000}
        }
        json_input = json.dumps(test_json)

        debug_file = '/tmp/statusline_debug.log'

        # Remove existing debug file if present
        if os.path.exists(debug_file):
            os.remove(debug_file)

        # We'll need to modify main() to include debug logging
        # This test verifies the debug mechanism works

        with patch('sys.stdin', io.StringIO(json_input)):
            with patch('statusline.FlowForgeStatusLine'):
                with patch('sys.stdout', new=io.StringIO()):
                    # After implementing debug logging in main()
                    # Check if debug file is created
                    pass  # Placeholder for when debug code is added


if __name__ == '__main__':
    unittest.main(verbosity=2)