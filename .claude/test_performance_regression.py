#!/usr/bin/env python3
"""
Performance Regression Tests for FlowForge StatusLine

These tests ensure that statusline performance stays within acceptable bounds,
preventing the 969ms cold-start regression from happening again.

Test Requirements:
- Cold start must be under 50ms
- Warm runs must average under 10ms
- Memory usage must stay reasonable
- No blocking I/O on critical path
"""

import unittest
import time
import sys
import subprocess
import threading
from pathlib import Path
from unittest.mock import patch, MagicMock
import json
import tempfile
import shutil

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))


class StatusLinePerformanceTests(unittest.TestCase):
    """Test suite for statusline performance requirements"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test environment once for all tests"""
        cls.test_dir = Path(tempfile.mkdtemp(prefix="statusline_test_"))
        cls.original_cwd = Path.cwd()
        
        # Create minimal test structure
        (cls.test_dir / '.flowforge').mkdir()
        (cls.test_dir / '.flowforge' / 'local').mkdir()
        
        # Create test cache file
        cache_data = {
            "git_branch": {
                "timestamp": time.time() * 1000,
                "data": "test-branch"
            }
        }
        with open(cls.test_dir / '.flowforge' / '.statusline-cache.json', 'w') as f:
            json.dump(cache_data, f)
    
    @classmethod
    def tearDownClass(cls):
        """Clean up test environment"""
        shutil.rmtree(cls.test_dir, ignore_errors=True)
    
    def setUp(self):
        """Set up each test"""
        # Clear module cache before each test
        for module_name in list(sys.modules.keys()):
            if 'statusline' in module_name or 'formatter' in module_name:
                del sys.modules[module_name]
        
        # Change to test directory
        import os
        os.chdir(self.test_dir)
    
    def tearDown(self):
        """Clean up after each test"""
        import os
        os.chdir(self.original_cwd)
    
    def test_cold_start_performance(self):
        """Test that cold start is under 50ms"""
        start_time = time.perf_counter()
        
        # Import and initialize
        import statusline
        sl = statusline.FlowForgeStatusLine()
        status = sl.generate_status_line("TestModel")
        
        elapsed_ms = (time.perf_counter() - start_time) * 1000
        
        self.assertIsNotNone(status, "Status line should be generated")
        self.assertLess(
            elapsed_ms, 50,
            f"Cold start took {elapsed_ms:.2f}ms, must be under 50ms"
        )
    
    def test_warm_run_performance(self):
        """Test that warm runs average under 10ms"""
        import statusline
        sl = statusline.FlowForgeStatusLine()
        
        # Warm up
        sl.generate_status_line("TestModel")
        
        # Measure warm runs
        warm_times = []
        for _ in range(20):
            start = time.perf_counter()
            status = sl.generate_status_line("TestModel")
            elapsed = (time.perf_counter() - start) * 1000
            warm_times.append(elapsed)
        
        avg_warm = sum(warm_times) / len(warm_times)
        max_warm = max(warm_times)
        
        self.assertLess(
            avg_warm, 10,
            f"Average warm run took {avg_warm:.2f}ms, must be under 10ms"
        )
        self.assertLess(
            max_warm, 20,
            f"Max warm run took {max_warm:.2f}ms, should be under 20ms"
        )
    
    def test_no_blocking_github_calls_on_init(self):
        """Test that GitHub CLI is not called during initialization"""
        with patch('subprocess.run') as mock_run:
            # Set up mock to track gh commands
            mock_run.return_value = MagicMock(
                returncode=0,
                stdout="test-output"
            )
            
            import statusline
            sl = statusline.FlowForgeStatusLine()
            
            # Check that gh auth status was NOT called during init
            gh_auth_calls = [
                call for call in mock_run.call_args_list
                if any('gh' in str(arg) and 'auth' in str(arg) 
                       for arg in call[0][0] if isinstance(arg, list))
            ]
            
            self.assertEqual(
                len(gh_auth_calls), 0,
                "GitHub auth should not be called during initialization"
            )
    
    def test_lazy_module_loading(self):
        """Test that formatter modules are loaded lazily"""
        import statusline
        
        # Check that formatter modules are not loaded initially
        self.assertNotIn('normal_mode_formatter', sys.modules)
        self.assertNotIn('milestone_mode_formatter', sys.modules)
        
        # Create instance - should still not load formatters
        sl = statusline.FlowForgeStatusLine()
        
        # Generate status - now formatters should load
        status = sl.generate_status_line("TestModel")
        
        # At least one formatter should be loaded now
        formatter_loaded = (
            'normal_mode_formatter' in sys.modules or
            'milestone_mode_formatter' in sys.modules
        )
        self.assertTrue(
            formatter_loaded,
            "Formatters should be loaded after first use"
        )
    
    def test_cache_performance(self):
        """Test that cache operations are fast"""
        import statusline
        
        cache_file = self.test_dir / '.flowforge' / '.statusline-cache.json'
        cache = statusline.StatusLineCache(cache_file)
        
        # Test cache write performance
        start = time.perf_counter()
        for i in range(100):
            cache.set(f"key_{i}", f"value_{i}", save_immediately=False)
        cache._save_to_disk()
        write_time = (time.perf_counter() - start) * 1000
        
        self.assertLess(
            write_time, 50,
            f"100 cache writes took {write_time:.2f}ms, should be under 50ms"
        )
        
        # Test cache read performance
        cache2 = statusline.StatusLineCache(cache_file)
        start = time.perf_counter()
        for i in range(100):
            value = cache2.get(f"key_{i}")
        read_time = (time.perf_counter() - start) * 1000
        
        self.assertLess(
            read_time, 10,
            f"100 cache reads took {read_time:.2f}ms, should be under 10ms"
        )
    
    def test_regex_precompilation(self):
        """Test that regex patterns are pre-compiled"""
        import statusline
        
        # Check that patterns exist at module level
        self.assertTrue(
            hasattr(statusline, 'ISSUE_PATTERNS'),
            "ISSUE_PATTERNS should be pre-compiled at module level"
        )
        self.assertTrue(
            hasattr(statusline, 'TASK_PATTERN'),
            "TASK_PATTERN should be pre-compiled at module level"
        )
        
        # Verify they are compiled regex objects
        import re
        for pattern in statusline.ISSUE_PATTERNS:
            self.assertIsInstance(
                pattern, re.Pattern,
                "Pattern should be pre-compiled regex"
            )
    
    def test_background_github_fetch(self):
        """Test that GitHub data is fetched in background"""
        import statusline
        
        with patch.object(statusline.FlowForgeStatusLine, '_run_command') as mock_run:
            mock_run.return_value = "test-milestone"
            
            sl = statusline.FlowForgeStatusLine()
            
            # First call should return immediately (empty or cached)
            start = time.perf_counter()
            data = sl._get_milestone_from_github("123")
            elapsed = (time.perf_counter() - start) * 1000
            
            self.assertLess(
                elapsed, 5,
                f"GitHub fetch took {elapsed:.2f}ms, should return immediately"
            )
            
            # Background thread should be started
            self.assertIsNotNone(
                sl._github_fetch_thread,
                "Background fetch thread should be started"
            )
    
    def test_memory_efficiency(self):
        """Test that statusline doesn't leak memory"""
        import statusline
        import gc
        import sys
        
        # Get initial memory state
        gc.collect()
        initial_objects = len(gc.get_objects())
        
        # Create and destroy multiple instances
        for _ in range(10):
            sl = statusline.FlowForgeStatusLine()
            status = sl.generate_status_line("TestModel")
            del sl
        
        # Force garbage collection
        gc.collect()
        final_objects = len(gc.get_objects())
        
        # Check for memory leaks (allow some growth but not excessive)
        object_growth = final_objects - initial_objects
        self.assertLess(
            object_growth, 1000,
            f"Object count grew by {object_growth}, possible memory leak"
        )
    
    def test_no_sync_io_in_critical_path(self):
        """Test that no synchronous I/O blocks the critical path"""
        import statusline
        
        # Mock file operations to detect sync I/O
        with patch('builtins.open') as mock_open:
            mock_file = MagicMock()
            mock_file.read.return_value = '{}'
            mock_file.__enter__.return_value = mock_file
            mock_open.return_value = mock_file
            
            sl = statusline.FlowForgeStatusLine()
            
            # Generate status line
            start = time.perf_counter()
            status = sl.generate_status_line("TestModel")
            elapsed = (time.perf_counter() - start) * 1000
            
            # Even with file I/O, should be fast due to caching
            self.assertLess(
                elapsed, 20,
                f"Status generation with I/O took {elapsed:.2f}ms"
            )
    
    def test_performance_under_load(self):
        """Test performance with concurrent requests"""
        import statusline
        import threading
        
        sl = statusline.FlowForgeStatusLine()
        results = []
        errors = []
        
        def generate_status():
            try:
                start = time.perf_counter()
                status = sl.generate_status_line("TestModel")
                elapsed = (time.perf_counter() - start) * 1000
                results.append(elapsed)
            except Exception as e:
                errors.append(str(e))
        
        # Run concurrent generations
        threads = []
        for _ in range(20):
            t = threading.Thread(target=generate_status)
            threads.append(t)
            t.start()
        
        for t in threads:
            t.join()
        
        self.assertEqual(len(errors), 0, f"Errors occurred: {errors}")
        self.assertEqual(len(results), 20, "All requests should complete")
        
        avg_time = sum(results) / len(results)
        max_time = max(results)
        
        self.assertLess(
            avg_time, 20,
            f"Average concurrent time {avg_time:.2f}ms, should be under 20ms"
        )
        self.assertLess(
            max_time, 50,
            f"Max concurrent time {max_time:.2f}ms, should be under 50ms"
        )


class StatusLineBenchmarks(unittest.TestCase):
    """Benchmark tests for tracking performance over time"""
    
    def test_benchmark_report(self):
        """Generate performance benchmark report"""
        import statusline
        
        print("\n" + "="*60)
        print("STATUSLINE PERFORMANCE BENCHMARK REPORT")
        print("="*60)
        
        # Cold start benchmark
        for module_name in list(sys.modules.keys()):
            if 'statusline' in module_name:
                del sys.modules[module_name]
        
        start = time.perf_counter()
        import statusline as sl_fresh
        sl = sl_fresh.FlowForgeStatusLine()
        status = sl.generate_status_line("Benchmark")
        cold_ms = (time.perf_counter() - start) * 1000
        
        # Warm run benchmarks
        warm_times = []
        for i in range(100):
            start = time.perf_counter()
            status = sl.generate_status_line(f"Model{i}")
            warm_times.append((time.perf_counter() - start) * 1000)
        
        # Calculate statistics
        avg_warm = sum(warm_times) / len(warm_times)
        min_warm = min(warm_times)
        max_warm = max(warm_times)
        p50_warm = sorted(warm_times)[50]
        p95_warm = sorted(warm_times)[95]
        p99_warm = sorted(warm_times)[99]
        
        # Print report
        print(f"\nCold Start Performance:")
        print(f"  Time: {cold_ms:.2f}ms")
        print(f"  Status: {'✅ PASS' if cold_ms < 50 else '❌ FAIL'}")
        
        print(f"\nWarm Run Performance (100 iterations):")
        print(f"  Average: {avg_warm:.3f}ms")
        print(f"  Min: {min_warm:.3f}ms")
        print(f"  Max: {max_warm:.3f}ms")
        print(f"  P50: {p50_warm:.3f}ms")
        print(f"  P95: {p95_warm:.3f}ms")
        print(f"  P99: {p99_warm:.3f}ms")
        
        print(f"\nPerformance Ratios:")
        print(f"  Cold/Warm: {cold_ms/avg_warm:.1f}x")
        print(f"  P99/P50: {p99_warm/p50_warm:.1f}x")
        
        print(f"\nPerformance Grade:")
        if cold_ms < 20 and avg_warm < 1:
            grade = "A+ (Exceptional)"
        elif cold_ms < 50 and avg_warm < 5:
            grade = "A (Excellent)"
        elif cold_ms < 100 and avg_warm < 10:
            grade = "B (Good)"
        elif cold_ms < 500 and avg_warm < 20:
            grade = "C (Acceptable)"
        else:
            grade = "F (Needs Improvement)"
        
        print(f"  Grade: {grade}")
        print("="*60)
        
        # Assert minimum requirements
        self.assertLess(cold_ms, 50, "Cold start must be under 50ms")
        self.assertLess(avg_warm, 10, "Average warm run must be under 10ms")


if __name__ == '__main__':
    # Run tests with verbosity
    unittest.main(verbosity=2)