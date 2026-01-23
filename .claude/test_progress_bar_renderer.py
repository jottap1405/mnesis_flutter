#!/usr/bin/env python3
"""
Comprehensive test suite for ProgressBarRenderer component.
Following FlowForge Rule #3: TDD - Tests written FIRST.

Test Coverage:
- Basic percentage rendering (0%, 25%, 50%, 75%, 100%)
- Fractional percentage handling (33.33%, 66.67%)
- Edge cases (negative values, > 100%, None values)
- Task completion ratio calculations
- Time-based progress calculations
- Different visual styles
- Error handling and input validation
- Performance requirements
"""

import unittest
import sys
from unittest.mock import patch, MagicMock
from pathlib import Path

# Add the .claude directory to the path for imports
sys.path.insert(0, str(Path(__file__).parent))


class TestProgressBarRenderer(unittest.TestCase):
    """
    Test suite for ProgressBarRenderer class.
    Rule #25: Comprehensive testing with 80%+ coverage required.
    """

    def setUp(self):
        """Set up test fixtures before each test method."""
        # Will be imported after implementation
        pass

    def test_basic_percentage_rendering(self):
        """
        Test basic percentage values render correctly.
        Expected behavior: 5-character bars with proper fill ratios.
        """
        # Rule #3: Write test BEFORE implementation
        from progress_bar_renderer import ProgressBarRenderer
        
        renderer = ProgressBarRenderer()
        
        # Test cases: percentage -> expected 5-char bar
        test_cases = [
            (0, "[░░░░░]"),      # 0% - all empty
            (20, "[▓░░░░]"),     # 20% - 1/5 filled
            (40, "[▓▓░░░]"),     # 40% - 2/5 filled
            (60, "[▓▓▓░░]"),     # 60% - 3/5 filled
            (80, "[▓▓▓▓░]"),     # 80% - 4/5 filled
            (100, "[▓▓▓▓▓]"),    # 100% - all filled
        ]
        
        for percentage, expected in test_cases:
            with self.subTest(percentage=percentage):
                result = renderer.render(percentage)
                self.assertEqual(result, expected)
                self.assertEqual(len(result), 7)  # [▓▓▓░░] = 7 chars total

    def test_fractional_percentage_handling(self):
        """
        Test fractional percentages round correctly.
        Rule #8: Proper handling of edge cases.
        """
        from progress_bar_renderer import ProgressBarRenderer
        
        renderer = ProgressBarRenderer()
        
        # Fractional test cases - using round(percentage / 20.0)
        test_cases = [
            (33.33, "[▓▓░░░]"),   # 33.33% -> round(33.33/20) = round(1.67) = 2
            (66.67, "[▓▓▓░░]"),   # 66.67% -> round(66.67/20) = round(3.33) = 3  
            (16.67, "[▓░░░░]"),   # 16.67% -> round(16.67/20) = round(0.83) = 1
            (83.33, "[▓▓▓▓░]"),   # 83.33% -> round(83.33/20) = round(4.17) = 4
            (10.1, "[▓░░░░]"),    # 10.1% -> round(10.1/20) = round(0.51) = 1
            (89.9, "[▓▓▓▓░]"),    # 89.9% -> round(89.9/20) = round(4.495) = 4
        ]
        
        for percentage, expected in test_cases:
            with self.subTest(percentage=percentage):
                result = renderer.render(percentage)
                self.assertEqual(result, expected)

    def test_edge_case_handling(self):
        """
        Test edge cases and error conditions.
        Rule #8: Comprehensive error handling required.
        """
        from progress_bar_renderer import ProgressBarRenderer
        from progress_bar_renderer import ProgressBarError
        
        renderer = ProgressBarRenderer()
        
        # Test negative values - should raise error
        with self.assertRaises(ProgressBarError):
            renderer.render(-10)
        
        # Test values > 100% - should cap at 100%
        result = renderer.render(150)
        self.assertEqual(result, "[▓▓▓▓▓]")
        
        # Test None value - should raise error
        with self.assertRaises(ProgressBarError):
            renderer.render(None)
        
        # Test non-numeric string - should raise error
        with self.assertRaises(ProgressBarError):
            renderer.render("invalid")

    def test_task_completion_ratio(self):
        """
        Test task completion ratio calculations.
        Example: 317 completed / 21 total should handle correctly.
        """
        from progress_bar_renderer import ProgressBarRenderer
        
        renderer = ProgressBarRenderer()
        
        # Test ratio-based rendering
        test_cases = [
            (3, 21, "[▓░░░░]"),    # 3/21 ≈ 14.3% -> round(14.3/20) = 1
            (10, 21, "[▓▓░░░]"),   # 10/21 ≈ 47.6% -> round(47.6/20) = 2  
            (15, 21, "[▓▓▓▓░]"),   # 15/21 ≈ 71.4% -> round(71.4/20) = 4
            (21, 21, "[▓▓▓▓▓]"),   # 21/21 = 100% -> round(100/20) = 5
            (0, 21, "[░░░░░]"),    # 0/21 = 0% -> round(0/20) = 0
        ]
        
        for completed, total, expected in test_cases:
            with self.subTest(completed=completed, total=total):
                result = renderer.render_ratio(completed, total)
                self.assertEqual(result, expected)

    def test_time_based_progress(self):
        """
        Test time-based progress calculations.
        Example: 23 minutes elapsed / 30 minutes planned.
        """
        from progress_bar_renderer import ProgressBarRenderer
        
        renderer = ProgressBarRenderer()
        
        # Test time-based rendering
        test_cases = [
            (5, 30, "[▓░░░░]"),    # 5/30 ≈ 16.7% -> round(16.7/20) = 1
            (15, 30, "[▓▓░░░]"),   # 15/30 = 50% -> round(50/20) = 2 (not 3!)
            (23, 30, "[▓▓▓▓░]"),   # 23/30 ≈ 76.7% -> round(76.7/20) = 4
            (30, 30, "[▓▓▓▓▓]"),   # 30/30 = 100% -> round(100/20) = 5
            (35, 30, "[▓▓▓▓▓]"),   # 35/30 > 100% -> capped at 5/5
        ]
        
        for elapsed, planned, expected in test_cases:
            with self.subTest(elapsed=elapsed, planned=planned):
                result = renderer.render_time(elapsed, planned)
                self.assertEqual(result, expected)

    def test_different_visual_styles(self):
        """
        Test different visual styles for progress bars.
        Rule #24: Modular design allows style variations.
        """
        from progress_bar_renderer import ProgressBarRenderer, ProgressBarStyle
        
        # Test ASCII style
        ascii_renderer = ProgressBarRenderer(style=ProgressBarStyle.ASCII)
        result = ascii_renderer.render(60)
        self.assertEqual(result, "[###..]")  # ASCII style with # and .
        
        # Test Unicode filled style
        unicode_renderer = ProgressBarRenderer(style=ProgressBarStyle.UNICODE_FILLED)
        result = unicode_renderer.render(60)
        self.assertEqual(result, "[███░░]")  # Solid blocks
        
        # Test default style (current requirement)
        default_renderer = ProgressBarRenderer()
        result = default_renderer.render(60)
        self.assertEqual(result, "[▓▓▓░░]")  # Default blocks

    def test_input_validation(self):
        """
        Test comprehensive input validation.
        Rule #8: Zero tolerance for invalid inputs.
        """
        from progress_bar_renderer import ProgressBarRenderer
        from progress_bar_renderer import ProgressBarError
        
        renderer = ProgressBarRenderer()
        
        # Test invalid ratio inputs
        with self.assertRaises(ProgressBarError):
            renderer.render_ratio(-1, 10)  # Negative completed
        
        with self.assertRaises(ProgressBarError):
            renderer.render_ratio(10, 0)   # Zero total
        
        with self.assertRaises(ProgressBarError):
            renderer.render_ratio(10, -5)  # Negative total
        
        # Test invalid time inputs
        with self.assertRaises(ProgressBarError):
            renderer.render_time(-5, 30)   # Negative elapsed
        
        with self.assertRaises(ProgressBarError):
            renderer.render_time(30, 0)    # Zero planned
        
        with self.assertRaises(ProgressBarError):
            renderer.render_time(30, -10)  # Negative planned

    def test_performance_requirements(self):
        """
        Test performance meets FlowForge requirements.
        Rule #8: Performance standards must be met.
        """
        from progress_bar_renderer import ProgressBarRenderer
        import time
        
        renderer = ProgressBarRenderer()
        
        # Test single render performance
        start_time = time.time()
        renderer.render(50)
        elapsed_ms = (time.time() - start_time) * 1000
        self.assertLess(elapsed_ms, 1.0)  # Should be < 1ms
        
        # Test batch render performance
        start_time = time.time()
        for i in range(1000):
            renderer.render(i / 10.0)
        elapsed_ms = (time.time() - start_time) * 1000
        self.assertLess(elapsed_ms, 100.0)  # 1000 renders < 100ms

    def test_unicode_character_integrity(self):
        """
        Test Unicode characters render correctly.
        Rule #25: Edge case testing for character encoding.
        """
        from progress_bar_renderer import ProgressBarRenderer
        
        renderer = ProgressBarRenderer()
        
        # Test all progress levels preserve Unicode integrity
        for percentage in range(0, 101, 10):
            result = renderer.render(percentage)
            
            # Verify Unicode characters are preserved appropriately
            # Note: 10% rounds to 0 filled blocks due to round(10/20) = round(0.5) = 0
            if percentage >= 20:  # Only check for filled blocks at 20% and above
                self.assertIn('▓', result)  # Filled block should be present
            if percentage < 100:
                self.assertIn('░', result)  # Empty block should be present if < 100%
            
            # Verify brackets are preserved
            self.assertTrue(result.startswith('['))
            self.assertTrue(result.endswith(']'))
            
            # Verify exactly 5 progress characters inside brackets
            inner_content = result[1:-1]
            self.assertEqual(len(inner_content), 5)

    def test_thread_safety(self):
        """
        Test thread safety for concurrent usage.
        Rule #8: Must handle concurrent access properly.
        """
        from progress_bar_renderer import ProgressBarRenderer
        import threading
        import queue
        
        renderer = ProgressBarRenderer()
        result_queue = queue.Queue()
        
        def render_worker(percentage):
            """Worker function for thread testing."""
            result = renderer.render(percentage)
            result_queue.put((percentage, result))
        
        # Create multiple threads rendering different percentages
        threads = []
        test_percentages = [0, 25, 50, 75, 100]
        
        for percentage in test_percentages:
            thread = threading.Thread(target=render_worker, args=(percentage,))
            threads.append(thread)
            thread.start()
        
        # Wait for all threads to complete
        for thread in threads:
            thread.join()
        
        # Verify all results are correct
        results = {}
        while not result_queue.empty():
            percentage, result = result_queue.get()
            results[percentage] = result
        
        # Verify expected results - using correct rounding
        expected = {
            0: "[░░░░░]",    # 0% -> round(0/20) = 0
            25: "[▓░░░░]",   # 25% -> round(25/20) = 1 (not 2!)
            50: "[▓▓░░░]",   # 50% -> round(50/20) = 2 (not 3!)  
            75: "[▓▓▓▓░]",   # 75% -> round(75/20) = 4
            100: "[▓▓▓▓▓]"   # 100% -> round(100/20) = 5
        }
        
        for percentage, expected_result in expected.items():
            self.assertEqual(results[percentage], expected_result)

    def test_memory_efficiency(self):
        """
        Test memory efficiency for large-scale usage.
        Rule #30: Maintainable and efficient code required.
        """
        from progress_bar_renderer import ProgressBarRenderer
        import tracemalloc
        
        tracemalloc.start()
        
        renderer = ProgressBarRenderer()
        
        # Render many progress bars
        results = []
        for i in range(10000):
            results.append(renderer.render(i / 100.0))
        
        current, peak = tracemalloc.get_traced_memory()
        tracemalloc.stop()
        
        # Memory usage should be reasonable (< 1MB for 10k renders)
        self.assertLess(peak / 1024 / 1024, 1.0)  # < 1MB


class TestProgressBarRendererIntegration(unittest.TestCase):
    """
    Integration tests for ProgressBarRenderer with real-world scenarios.
    Rule #25: Include integration testing.
    """

    def test_flowforge_statusline_integration(self):
        """
        Test integration with FlowForge statusline format.
        """
        from progress_bar_renderer import ProgressBarRenderer
        
        renderer = ProgressBarRenderer()
        
        # Simulate real FlowForge usage patterns
        progress_bar = renderer.render_ratio(3, 21)  # 3 of 21 tasks done
        
        # Should integrate cleanly into statusline format
        statusline = f"[FlowForge] Sprint Planning(3/21){progress_bar}:2h30m | Branch: feature/142"
        
        # Verify format integrity
        self.assertIn("[▓░░░░]", statusline)
        self.assertRegex(statusline, r'\[FlowForge\].*\[▓░░░░\].*Branch:')

    def test_milestone_progress_integration(self):
        """
        Test integration with milestone tracking.
        """
        from progress_bar_renderer import ProgressBarRenderer
        
        renderer = ProgressBarRenderer()
        
        # Test various milestone scenarios
        scenarios = [
            ("Initial Setup", 2, 8),      # Just started
            ("Development", 15, 20),      # Nearly done
            ("Testing", 8, 10),           # Most complete
            ("Documentation", 0, 5),      # Not started
        ]
        
        for milestone_name, completed, total in scenarios:
            progress_bar = renderer.render_ratio(completed, total)
            statusline = f"[FlowForge] {milestone_name}({completed}/{total}){progress_bar}"
            
            # Verify each scenario produces valid output
            self.assertRegex(statusline, r'\[FlowForge\].*\[.{5}\]')
            self.assertEqual(len(progress_bar), 7)  # [▓▓░░░] format


if __name__ == '__main__':
    # Rule #26: Document test execution
    print("Running ProgressBarRenderer test suite...")
    print("Following FlowForge Rule #3: TDD - Tests written FIRST")
    print("Target coverage: 80%+ (Rule #25)")
    
    unittest.main(verbosity=2)