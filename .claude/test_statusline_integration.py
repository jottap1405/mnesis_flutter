#!/usr/bin/env python3
"""
Integration Test Suite for Refactored FlowForge StatusLine
Tests the strategy pattern implementation and all integration requirements.

Author: FlowForge Team
Since: 2.1.0
"""

import unittest
import json
import sys
import tempfile
import os
from pathlib import Path
from io import StringIO
from unittest.mock import patch, MagicMock

from statusline import FlowForgeStatusLine, NormalModeFormatterAdapter, MilestoneModeFormatterAdapter
from status_formatter_interface import FormattingContext
from milestone_detector import MilestoneDetector


class TestStatusLineIntegration(unittest.TestCase):
    """Integration tests for refactored statusline with strategy pattern."""
    
    def setUp(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.temp_dir)
        
        # Create test FlowForge structure
        flowforge_dir = Path(self.temp_dir) / '.flowforge'
        flowforge_dir.mkdir()
        
        self.statusline = FlowForgeStatusLine()
    
    def tearDown(self):
        """Clean up test environment."""
        os.chdir(self.original_cwd)
        # Clean up temp directory
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_milestone_detection_integration(self):
        """Test MilestoneDetector integration with strategy selection."""
        # Test normal mode (no milestone context)
        formatter = self.statusline._get_current_formatter()
        self.assertIsInstance(formatter, NormalModeFormatterAdapter)
        
        # Create milestone context file
        milestone_file = Path(self.temp_dir) / '.milestone-context'
        milestone_file.write_text('test-milestone-v2.0')
        
        # Clear formatter cache to force re-detection
        self.statusline._cached_formatter = None
        
        # Test milestone mode
        formatter = self.statusline._get_current_formatter()
        self.assertIsInstance(formatter, MilestoneModeFormatterAdapter)
    
    def test_strategy_pattern_implementation(self):
        """Test that strategy pattern correctly delegates to formatters."""
        # Create test context
        context = FormattingContext(
            model_name="TestModel",
            git_branch="feature/123",
            milestone_data={'name': 'test', 'tasks_completed': 5, 'tasks_total': 10},
            task_data={'completed': 5, 'total': 10, 'percentage': 50.0}
        )
        
        # Test normal formatter adapter
        normal_formatter = NormalModeFormatterAdapter(self.statusline)
        normal_result = normal_formatter.format(context)
        self.assertIn("⚩ FF v2.1", normal_result)
        self.assertIn("5/10", normal_result)
        self.assertIn("TestModel", normal_result)
        
        # Test milestone formatter adapter
        milestone_formatter = MilestoneModeFormatterAdapter(self.statusline)
        milestone_result = milestone_formatter.format(context)
        self.assertIn("🎯 MILESTONE:", milestone_result)
        self.assertIn("5/10", milestone_result)
        self.assertIn("TestModel", milestone_result)
    
    def test_backward_compatibility(self):
        """Test that existing API behavior is preserved."""
        # Test basic generate_status_line call
        result = self.statusline.generate_status_line("TestModel")
        
        # Should return a string
        self.assertIsInstance(result, str)
        
        # Should contain basic elements from legacy format
        self.assertIn("TestModel", result)
        
        # Test with parameters
        result_with_params = self.statusline.generate_status_line("CustomModel", prefer_local=False)
        self.assertIsInstance(result_with_params, str)
        self.assertIn("CustomModel", result_with_params)
    
    def test_caching_system_preserved(self):
        """Test that performance caching is maintained."""
        # First call should populate cache
        result1 = self.statusline.generate_status_line("Model1")
        
        # Second call should use cache (same formatter)
        formatter_before = self.statusline._cached_formatter
        result2 = self.statusline.generate_status_line("Model2")
        formatter_after = self.statusline._cached_formatter
        
        # Formatter should be cached (same instance)
        self.assertIs(formatter_before, formatter_after)
    
    def test_data_collection_centralized(self):
        """Test that data collection remains in main class."""
        # Mock git branch on data_loader (after refactoring)
        with patch.object(self.statusline.data_loader, 'get_git_branch', return_value='feature/test-123'):
            context = self.statusline._build_formatting_context("TestModel", True)
            
            self.assertEqual(context.git_branch, 'feature/test-123')
            self.assertEqual(context.model_name, 'TestModel')
            self.assertIsInstance(context, FormattingContext)
    
    def test_error_handling_fallback(self):
        """Test graceful fallback to legacy format on errors."""
        # Mock formatter to raise exception
        original_formatter = self.statusline._normal_formatter
        mock_formatter = MagicMock()
        mock_formatter.format.side_effect = Exception("Test error")
        self.statusline._normal_formatter = mock_formatter
        self.statusline._cached_formatter = mock_formatter
        
        try:
            # Should not raise exception, should return fallback
            result = self.statusline.generate_status_line("TestModel")
            self.assertIsInstance(result, str)
            self.assertIn("TestModel", result)
        finally:
            # Restore original formatter
            self.statusline._normal_formatter = original_formatter
    
    def test_formatting_context_adapter(self):
        """Test that context adaptation works correctly."""
        milestone_data = {'name': 'test-milestone', 'tasks_completed': 3, 'tasks_total': 7, 'time_remaining': '2h'}
        task_data = {'completed': 3, 'total': 7, 'percentage': 42.86}
        
        context = FormattingContext(
            model_name="AdapterTest",
            git_branch="feature/adapter",
            milestone_data=milestone_data,
            task_data=task_data
        )
        
        # Test normal adapter
        normal_data = self.statusline.create_normal_formatter_adapter(context)
        self.assertEqual(normal_data.tasks_completed, 3)
        self.assertEqual(normal_data.tasks_total, 7)
        self.assertEqual(normal_data.model_name, "AdapterTest")
        self.assertEqual(normal_data.git_branch, "feature/adapter")
        
        # Test milestone adapter
        milestone_data_result = self.statusline.create_milestone_formatter_adapter(context)
        self.assertEqual(milestone_data_result.tasks_completed, 3)
        self.assertEqual(milestone_data_result.tasks_total, 7)
        self.assertEqual(milestone_data_result.model_name, "AdapterTest")
        self.assertEqual(milestone_data_result.milestone_name, "test-milestone")
    
    def test_cli_interface_compatibility(self):
        """Test that CLI interface remains compatible."""
        # Test JSON input processing
        test_input = {"model": {"display_name": "CLITest"}}
        
        # Mock stdin
        old_stdin = sys.stdin
        sys.stdin = StringIO(json.dumps(test_input))
        
        try:
            # Import and test main function
            from statusline import main
            
            # Capture stdout
            old_stdout = sys.stdout
            captured_output = StringIO()
            sys.stdout = captured_output
            
            try:
                main()
                output = captured_output.getvalue()
                self.assertIn("CLITest", output)
                # Should be a valid statusline (contains basic elements)
                self.assertTrue(len(output.strip()) > 20)
            finally:
                sys.stdout = old_stdout
                
        finally:
            sys.stdin = old_stdin


class TestPerformanceRegression(unittest.TestCase):
    """Performance regression tests to ensure caching is working."""
    
    def setUp(self):
        """Set up performance test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.original_cwd = os.getcwd()
        os.chdir(self.temp_dir)
        
        self.statusline = FlowForgeStatusLine()
    
    def tearDown(self):
        """Clean up performance test environment."""
        os.chdir(self.original_cwd)
        import shutil
        shutil.rmtree(self.temp_dir, ignore_errors=True)
    
    def test_cached_calls_performance(self):
        """Test that cached calls perform well."""
        import time
        
        # First call (cache population)
        start = time.time()
        self.statusline.generate_status_line("PerfTest1")
        first_call_time = time.time() - start
        
        # Second call (should use cache)
        start = time.time()
        self.statusline.generate_status_line("PerfTest2")
        second_call_time = time.time() - start
        
        # Cache should make subsequent calls faster
        # Second call should be significantly faster (less than 50% of first call time)
        self.assertLess(second_call_time, first_call_time * 0.5)
    
    def test_formatter_cache_effectiveness(self):
        """Test that formatter caching reduces overhead."""
        # Multiple calls should reuse same formatter instance
        formatter1 = self.statusline._get_current_formatter()
        formatter2 = self.statusline._get_current_formatter()
        formatter3 = self.statusline._get_current_formatter()
        
        # All should be the same instance due to caching
        self.assertIs(formatter1, formatter2)
        self.assertIs(formatter2, formatter3)


if __name__ == '__main__':
    # Run integration tests
    print("Running FlowForge StatusLine Integration Tests...")
    unittest.main(verbosity=2)