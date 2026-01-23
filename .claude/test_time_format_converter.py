#!/usr/bin/env python3
"""
Test suite for Time Format Converter - Rule #3 TDD Implementation.

Tests written FIRST before implementation following FlowForge standards.
"""

import unittest
import sys
from pathlib import Path

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).parent))

from statusline_helpers import StatusLineHelpers


class TestTimeFormatConverter(unittest.TestCase):
    """
    Test suite for time format conversion functionality.

    Following Rule #3: Tests written before implementation.
    Coverage target: 80%+ as per Rule #25
    """

    def setUp(self):
        """Set up test fixtures."""
        self.base_path = Path("/tmp/test")
        self.data_loader = None  # Mock data loader for testing
        self.helpers = StatusLineHelpers(self.base_path, self.data_loader)

    def test_convert_minutes_to_readable_format(self):
        """
        Test conversion of minutes to customer-friendly format.

        Expected use case: 40320m → "4w" or "28d"
        """
        # Test 4 weeks worth of minutes
        result = self.helpers.convert_time_to_readable("40320m")
        self.assertIn(result, ["4w", "28d", "4 weeks"])

        # Test 1 week
        result = self.helpers.convert_time_to_readable("10080m")
        self.assertIn(result, ["1w", "7d", "1 week"])

        # Test 1 day
        result = self.helpers.convert_time_to_readable("1440m")
        self.assertIn(result, ["1d", "1 day"])

        # Test hours
        result = self.helpers.convert_time_to_readable("120m")
        self.assertEqual(result, "2h")

        # Test small minutes
        result = self.helpers.convert_time_to_readable("30m")
        self.assertEqual(result, "30m")

    def test_convert_hours_format(self):
        """Test conversion of hour-based formats."""
        result = self.helpers.convert_time_to_readable("48h")
        self.assertIn(result, ["2d", "48h"])

        result = self.helpers.convert_time_to_readable("2.5h")
        self.assertEqual(result, "2.5h")

    def test_convert_already_readable_format(self):
        """Test handling of already readable formats."""
        result = self.helpers.convert_time_to_readable("4 weeks")
        self.assertEqual(result, "4 weeks")

        result = self.helpers.convert_time_to_readable("2 days")
        self.assertEqual(result, "2 days")

        result = self.helpers.convert_time_to_readable("3w")
        self.assertEqual(result, "3w")

    def test_edge_cases(self):
        """Test edge cases and boundary conditions."""
        # Empty input
        result = self.helpers.convert_time_to_readable("")
        self.assertEqual(result, "0m")

        # Zero values
        result = self.helpers.convert_time_to_readable("0m")
        self.assertEqual(result, "0m")

        # Large values
        result = self.helpers.convert_time_to_readable("80640m")  # 8 weeks
        self.assertIn(result, ["8w", "56d", "8 weeks"])

        # Decimal minutes (should convert to hours if over 60)
        result = self.helpers.convert_time_to_readable("90.5m")
        self.assertEqual(result, "1.5h")

    def test_failure_cases(self):
        """Test error handling for invalid inputs."""
        # Invalid format
        result = self.helpers.convert_time_to_readable("invalid")
        self.assertEqual(result, "invalid")  # Should return original for unknown formats

        # Negative values
        result = self.helpers.convert_time_to_readable("-60m")
        self.assertEqual(result, "-60m")  # Should handle gracefully

    def test_multiple_formats_support(self):
        """Test support for various input formats."""
        test_cases = [
            ("40320", "4w"),  # Assume minutes if no unit, convert to weeks
            ("40320m", ["4w", "28d"]),  # Minutes with unit
            ("168h", ["1w", "7d"]),  # Hours to week/days
            ("1440", "1d"),  # Large number assumed as minutes → day
        ]

        for input_val, expected in test_cases:
            result = self.helpers.convert_time_to_readable(input_val)
            if isinstance(expected, list):
                self.assertIn(result, expected, f"Failed for input: {input_val}")
            else:
                self.assertEqual(result, expected, f"Failed for input: {input_val}")

    def test_customer_friendly_priority(self):
        """
        Test that output prioritizes customer-friendly formats.

        Should prefer: weeks > days > hours > minutes
        """
        # Should prefer weeks over days for large values
        result = self.helpers.convert_time_to_readable("40320m")  # 4 weeks
        self.assertTrue(result.endswith("w") or "week" in result.lower())

        # Should prefer days over hours for day-sized values
        result = self.helpers.convert_time_to_readable("1440m")  # 1 day
        self.assertTrue(result.endswith("d") or "day" in result.lower())

        # Should keep hours for hour-sized values
        result = self.helpers.convert_time_to_readable("120m")  # 2 hours
        self.assertTrue(result.endswith("h") or "hour" in result.lower())


class TestMergeConflictDetection(unittest.TestCase):
    """
    Test suite for merge conflict detection functionality.

    Rule #3: TDD - tests written first
    """

    def setUp(self):
        """Set up test fixtures."""
        self.base_path = Path("/tmp/test")
        self.data_loader = None
        self.helpers = StatusLineHelpers(self.base_path, self.data_loader)

    def test_detect_merge_conflict_markers(self):
        """Test detection of standard Git merge conflict markers."""
        # Test content with merge conflict
        conflict_content = '''
        normal content
        <<<<<<< HEAD
        current branch content
        =======
        incoming branch content
        >>>>>>> feature-branch
        more normal content
        '''

        result = self.helpers.has_merge_conflicts(conflict_content)
        self.assertTrue(result)

    def test_detect_individual_markers(self):
        """Test detection of individual merge conflict markers."""
        # Test each marker individually
        self.assertTrue(self.helpers.has_merge_conflicts("<<<<<<< HEAD"))
        self.assertTrue(self.helpers.has_merge_conflicts("======="))
        self.assertTrue(self.helpers.has_merge_conflicts(">>>>>>> branch"))

    def test_no_merge_conflicts(self):
        """Test clean content without merge conflicts."""
        clean_content = '''
        {
            "version": "2.0.0",
            "current_milestone": {
                "name": "v2.1-statusline-milestone-mode"
            }
        }
        '''

        result = self.helpers.has_merge_conflicts(clean_content)
        self.assertFalse(result)

    def test_edge_cases_merge_detection(self):
        """Test edge cases for merge conflict detection."""
        # Empty content
        self.assertFalse(self.helpers.has_merge_conflicts(""))

        # Content with similar but not exact markers
        self.assertFalse(self.helpers.has_merge_conflicts("< < < < < < <"))
        self.assertFalse(self.helpers.has_merge_conflicts("= = = = = = ="))
        self.assertFalse(self.helpers.has_merge_conflicts("> > > > > > >"))

        # Markers in comments (should still detect)
        self.assertTrue(self.helpers.has_merge_conflicts("# <<<<<<< HEAD"))


if __name__ == '__main__':
    # Rule #8: Proper logging instead of console.log
    import logging
    logging.basicConfig(level=logging.INFO)

    # Run all tests
    unittest.main(verbosity=2)