#!/usr/bin/env python3
"""
Test suite for formatter utility functions.

Tests shared formatting utilities following FlowForge Rule #3 (TDD) and
Rule #25 (comprehensive testing). Tests must be written BEFORE implementation.

Following FlowForge Rule #26: Full documentation
Following FlowForge Rule #33: No AI references
"""

import unittest
from unittest.mock import patch, MagicMock
import sys
from pathlib import Path

# Add the .claude directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))


class TestFormatterUtils(unittest.TestCase):
    """
    Tests for shared formatter utility functions.
    
    Covers input sanitization, time validation, string truncation,
    and other shared formatting helpers.
    """
    
    def test_sanitize_string_removes_dangerous_characters(self):
        """
        Test sanitize_string removes potentially dangerous characters.
        
        Ensures only safe characters are allowed in statusline output.
        """
        from formatter_utils import sanitize_string
        
        # Test removal of control characters
        result = sanitize_string("test\x00\x01string", 50, "default")
        self.assertEqual(result, "teststring")
        
        # Test preservation of allowed characters
        result = sanitize_string("test-123_file.txt/path:time [tag]", 50, "default")
        self.assertEqual(result, "test-123_file.txt/path:time [tag]")
    
    def test_sanitize_string_applies_length_limit(self):
        """
        Test sanitize_string enforces maximum length.
        
        Verifies strings are truncated to specified maximum length.
        """
        from formatter_utils import sanitize_string
        
        long_string = "a" * 100
        result = sanitize_string(long_string, 10, "default")
        self.assertEqual(len(result), 10)
        self.assertEqual(result, "a" * 10)
    
    def test_sanitize_string_returns_default_for_invalid_input(self):
        """
        Test sanitize_string returns default for invalid input.
        
        Handles None, empty strings, and non-string types.
        """
        from formatter_utils import sanitize_string
        
        # Test None input
        result = sanitize_string(None, 50, "default")
        self.assertEqual(result, "default")
        
        # Test empty string
        result = sanitize_string("", 50, "default")
        self.assertEqual(result, "default")
        
        # Test non-string type
        result = sanitize_string(123, 50, "default")
        self.assertEqual(result, "123")
    
    def test_validate_time_format_accepts_valid_formats(self):
        """
        Test validate_time_format accepts valid time strings.
        
        Verifies HH:MM and H:MM formats with valid ranges.
        """
        from formatter_utils import validate_time_format
        
        # Test HH:MM format
        self.assertEqual(validate_time_format("00:00"), "00:00")
        self.assertEqual(validate_time_format("23:59"), "23:59")
        
        # Test H:MM format
        self.assertEqual(validate_time_format("0:00"), "0:00")
        self.assertEqual(validate_time_format("9:30"), "9:30")
    
    def test_validate_time_format_rejects_invalid_formats(self):
        """
        Test validate_time_format rejects invalid time strings.
        
        Returns "00:00" for invalid formats or out-of-range values.
        """
        from formatter_utils import validate_time_format
        
        # Test invalid format
        self.assertEqual(validate_time_format("not:time"), "00:00")
        self.assertEqual(validate_time_format("12-30"), "00:00")
        
        # Test out of range
        self.assertEqual(validate_time_format("24:00"), "00:00")
        self.assertEqual(validate_time_format("12:60"), "00:00")
        
        # Test non-string input
        self.assertEqual(validate_time_format(None), "00:00")
        self.assertEqual(validate_time_format(123), "00:00")
    
    def test_parse_time_to_minutes_converts_correctly(self):
        """
        Test parse_time_to_minutes converts time strings to minutes.
        
        Verifies correct conversion of HH:MM format to total minutes.
        """
        from formatter_utils import parse_time_to_minutes
        
        # Test standard times
        self.assertEqual(parse_time_to_minutes("00:00"), 0)
        self.assertEqual(parse_time_to_minutes("00:30"), 30)
        self.assertEqual(parse_time_to_minutes("1:00"), 60)
        self.assertEqual(parse_time_to_minutes("2:30"), 150)
        self.assertEqual(parse_time_to_minutes("23:59"), 1439)
    
    def test_parse_time_to_minutes_handles_invalid_input(self):
        """
        Test parse_time_to_minutes handles invalid input.
        
        Returns 0 for invalid time formats.
        """
        from formatter_utils import parse_time_to_minutes
        
        self.assertEqual(parse_time_to_minutes("invalid"), 0)
        self.assertEqual(parse_time_to_minutes(""), 0)
        self.assertEqual(parse_time_to_minutes(None), 0)
    
    def test_detect_terminal_width_returns_valid_width(self):
        """
        Test detect_terminal_width returns valid terminal width.
        
        Ensures minimum width is enforced and fallback works.
        """
        from formatter_utils import detect_terminal_width
        
        with patch('shutil.get_terminal_size') as mock_size:
            # Test normal terminal size
            mock_size.return_value = MagicMock(columns=120)
            self.assertEqual(detect_terminal_width(80), 120)
            
            # Test too small terminal
            mock_size.return_value = MagicMock(columns=60)
            self.assertEqual(detect_terminal_width(80), 80)
            
            # Test exception handling
            mock_size.side_effect = Exception("No terminal")
            self.assertEqual(detect_terminal_width(80, 100), 100)
    
    def test_get_warning_indicator_for_percentage(self):
        """
        Test get_warning_indicator returns appropriate warnings.
        
        Verifies correct warning levels for different percentages.
        """
        from formatter_utils import get_warning_indicator
        
        # Test no warning
        self.assertEqual(get_warning_indicator(50), "")
        self.assertEqual(get_warning_indicator(79), "")
        
        # Test moderate warning
        self.assertEqual(get_warning_indicator(80), "⚠️")
        self.assertEqual(get_warning_indicator(94), "⚠️")
        
        # Test critical warning
        self.assertEqual(get_warning_indicator(95), "🚨")
        self.assertEqual(get_warning_indicator(100), "🚨")
    
    def test_calculate_eta_handles_edge_cases(self):
        """
        Test calculate_eta handles various edge cases.
        
        Verifies ETA calculation for zero progress, completion, etc.
        """
        from formatter_utils import calculate_eta
        
        # Test no tasks
        self.assertEqual(calculate_eta(0, 0, 30), "0.0h")
        
        # Test no progress
        self.assertEqual(calculate_eta(0, 10, 30), "∞")
        
        # Test no time elapsed
        self.assertEqual(calculate_eta(5, 10, 0), "∞")
        
        # Test completed
        self.assertEqual(calculate_eta(10, 10, 60), "0.0h")
        
        # Test over-completion
        self.assertEqual(calculate_eta(15, 10, 60), "0.0h")
    
    def test_calculate_eta_calculates_correctly(self):
        """
        Test calculate_eta calculates remaining time correctly.
        
        Verifies accurate ETA based on current progress rate.
        """
        from formatter_utils import calculate_eta
        
        # Test 50% complete in 30 minutes -> 30 minutes remaining
        self.assertEqual(calculate_eta(5, 10, 30), "0.5h")
        
        # Test 25% complete in 60 minutes -> 180 minutes remaining
        self.assertEqual(calculate_eta(1, 4, 60), "3.0h")
        
        # Test 80% complete in 40 minutes -> 10 minutes remaining
        self.assertEqual(calculate_eta(4, 5, 40), "0.2h")


class TestComponentPriority(unittest.TestCase):
    """
    Tests for component priority and truncation logic.
    
    Ensures statusline components are prioritized correctly
    when terminal width constraints apply.
    """
    
    def test_get_component_priority_normal_mode(self):
        """
        Test component priority for normal mode formatting.
        
        Verifies correct priority order for normal mode components.
        """
        from formatter_utils import get_component_priority
        
        priority = get_component_priority("normal")
        self.assertEqual(priority["essential"], [0, 1, 6])  # version, tasks, model
        self.assertEqual(priority["optional"], [2, 3, 4, 5])  # time, budget, branch, context
    
    def test_get_component_priority_milestone_mode(self):
        """
        Test component priority for milestone mode formatting.
        
        Verifies correct priority order for milestone mode components.
        """
        from formatter_utils import get_component_priority
        
        priority = get_component_priority("milestone")
        self.assertEqual(priority["essential"], [0, 3, 5])  # milestone, ETA, model
        self.assertEqual(priority["optional"], [1, 4, 2])  # tasks, branch, time
    
    def test_truncate_to_width_preserves_essential(self):
        """
        Test truncate_to_width preserves essential components.
        
        Ensures essential components are kept even under extreme constraints.
        """
        from formatter_utils import truncate_to_width
        
        components = [
            "⚩ FF v2.0",
            "📋 10/20 [▓▓░░░] 50%",
            "⏱ 00:23/0:30",
            "💰 4:30h left",
            "🌿 feature/test",
            "🧠 85% [████░]",
            "Opus"
        ]
        
        # Test with limited width
        result = truncate_to_width(components, 50, "normal")
        
        # Essential components should be present
        self.assertIn("⚩ FF v2.0", result)
        self.assertIn("Opus", result)


if __name__ == "__main__":
    unittest.main()