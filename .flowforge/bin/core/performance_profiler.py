#!/usr/bin/env python3
"""
Performance Profiler for FlowForge StatusLine
Identifies the 969ms cold-start bottleneck
"""

import time
import sys
import os
import json
import cProfile
import pstats
import io
from pathlib import Path
from contextlib import contextmanager
from typing import Dict, Any, List, Tuple
import importlib.util
import subprocess

# Add current directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))


@contextmanager
def timer(name: str):
    """Context manager for timing operations"""
    start = time.perf_counter()
    yield
    elapsed = (time.perf_counter() - start) * 1000
    print(f"{name}: {elapsed:.2f}ms")


class StatusLineProfiler:
    """Profiles the statusline initialization and execution"""
    
    def __init__(self):
        self.timings: Dict[str, float] = {}
        self.import_times: Dict[str, float] = {}
        
    def profile_imports(self):
        """Profile import times for each module"""
        print("\n=== IMPORT PROFILING ===")
        
        modules_to_test = [
            'json',
            'subprocess',
            'os',
            'time',
            're',
            'pathlib',
            'typing',
            'dataclasses',
            'functools',
            'contextlib',
        ]
        
        for module_name in modules_to_test:
            start = time.perf_counter()
            __import__(module_name)
            elapsed = (time.perf_counter() - start) * 1000
            self.import_times[module_name] = elapsed
            print(f"  {module_name}: {elapsed:.2f}ms")
        
        # Test local imports
        print("\n=== LOCAL MODULE IMPORTS ===")
        local_modules = [
            'status_formatter_interface',
            'milestone_detector',
            'normal_mode_formatter',
            'milestone_mode_formatter',
        ]
        
        for module_name in local_modules:
            try:
                start = time.perf_counter()
                spec = importlib.util.spec_from_file_location(
                    module_name,
                    Path(__file__).parent / f"{module_name}.py"
                )
                if spec and spec.loader:
                    module = importlib.util.module_from_spec(spec)
                    spec.loader.exec_module(module)
                elapsed = (time.perf_counter() - start) * 1000
                self.import_times[module_name] = elapsed
                print(f"  {module_name}: {elapsed:.2f}ms")
            except Exception as e:
                print(f"  {module_name}: ERROR - {e}")
    
    def profile_initialization(self):
        """Profile FlowForgeStatusLine initialization"""
        print("\n=== INITIALIZATION PROFILING ===")
        
        # Clear any cached modules
        if 'statusline' in sys.modules:
            del sys.modules['statusline']
        
        # Time the import
        with timer("Import statusline module"):
            import statusline
        
        # Time initialization
        with timer("FlowForgeStatusLine.__init__()"):
            sl = statusline.FlowForgeStatusLine()
        
        # Profile individual initialization components
        print("\n=== COMPONENT INITIALIZATION ===")
        
        # Test path operations
        with timer("Path operations"):
            base_path = Path.cwd()
            cache_file = base_path / '.flowforge' / '.statusline-cache.json'
            flowforge_dir = base_path / '.flowforge'
            local_dir = flowforge_dir / 'local'
        
        # Test cache initialization
        with timer("StatusLineCache initialization"):
            from statusline import StatusLineCache
            cache = StatusLineCache(cache_file)
        
        # Test detector initialization
        with timer("MilestoneDetector initialization"):
            from milestone_detector import MilestoneDetector
            detector = MilestoneDetector(base_path)
        
        # Test formatter initialization
        with timer("NormalModeFormatter initialization"):
            from normal_mode_formatter import NormalModeFormatter
            formatter = NormalModeFormatter()
        
        with timer("MilestoneModeFormatter initialization"):
            from milestone_mode_formatter import MilestoneModeFormatter
            milestone_formatter = MilestoneModeFormatter()
    
    def profile_git_operations(self):
        """Profile git command execution"""
        print("\n=== GIT OPERATIONS PROFILING ===")
        
        commands = [
            (['git', 'branch', '--show-current'], "git branch --show-current"),
            (['git', 'status', '--porcelain'], "git status --porcelain"),
            (['git', 'rev-parse', '--abbrev-ref', 'HEAD'], "git rev-parse HEAD"),
        ]
        
        for cmd, desc in commands:
            try:
                start = time.perf_counter()
                result = subprocess.run(
                    cmd,
                    capture_output=True,
                    text=True,
                    timeout=2,
                    cwd=Path.cwd()
                )
                elapsed = (time.perf_counter() - start) * 1000
                print(f"  {desc}: {elapsed:.2f}ms (returncode: {result.returncode})")
            except Exception as e:
                print(f"  {desc}: ERROR - {e}")
    
    def profile_file_operations(self):
        """Profile file I/O operations"""
        print("\n=== FILE I/O PROFILING ===")
        
        test_files = [
            '.flowforge/.statusline-cache.json',
            '.flowforge/tasks.json',
            '.flowforge/local/session.json',
            '.flowforge/milestones.json',
            '.task-times.json',
            'package.json',
        ]
        
        base_path = Path.cwd()
        
        for file_path in test_files:
            full_path = base_path / file_path
            
            # Test file existence check
            start = time.perf_counter()
            exists = full_path.exists()
            elapsed = (time.perf_counter() - start) * 1000
            print(f"  {file_path}.exists(): {elapsed:.2f}ms (exists: {exists})")
            
            if exists:
                # Test file read
                try:
                    start = time.perf_counter()
                    with open(full_path, 'r') as f:
                        content = f.read()
                    elapsed = (time.perf_counter() - start) * 1000
                    size = len(content)
                    print(f"    read: {elapsed:.2f}ms (size: {size} bytes)")
                    
                    # Test JSON parse
                    start = time.perf_counter()
                    data = json.loads(content)
                    elapsed = (time.perf_counter() - start) * 1000
                    print(f"    json.loads: {elapsed:.2f}ms")
                except Exception as e:
                    print(f"    ERROR: {e}")
    
    def profile_regex_compilation(self):
        """Profile regex pattern compilation"""
        print("\n=== REGEX COMPILATION PROFILING ===")
        
        import re
        
        patterns = [
            (r'\b(?:feature|issue|hotfix|bugfix)[/-](\d{1,6})\b', "Issue pattern 1"),
            (r'^(\d{1,6})(?:-[^\s]+)?$', "Issue pattern 2"),
            (r'v\d{1,3}\.\d{1,3}-[^-]{1,50}-(\d{1,6})$', "Issue pattern 3"),
            (r'^-\s{0,5}\[[ x]\]', "Task pattern"),
            (r'^-\s{0,5}\[x\]', "Completed task pattern"),
            (r'^-\s{0,5}\[ \].{0,100}?\[(\d{1,4}(?:\.\d{1,2})?)[hH]\]', "Time pattern"),
        ]
        
        for pattern, desc in patterns:
            start = time.perf_counter()
            compiled = re.compile(pattern, re.MULTILINE if 'Task' in desc or 'Time' in desc else 0)
            elapsed = (time.perf_counter() - start) * 1000
            print(f"  {desc}: {elapsed:.2f}ms")
    
    def profile_full_execution(self):
        """Profile full statusline execution"""
        print("\n=== FULL EXECUTION PROFILING ===")
        
        # First run (cold start)
        if 'statusline' in sys.modules:
            del sys.modules['statusline']
        
        start = time.perf_counter()
        import statusline
        sl = statusline.FlowForgeStatusLine()
        status = sl.generate_status_line("Opus")
        cold_elapsed = (time.perf_counter() - start) * 1000
        print(f"Cold start: {cold_elapsed:.2f}ms")
        print(f"  Result: {status[:80]}...")
        
        # Warm runs
        warm_times = []
        for i in range(10):
            start = time.perf_counter()
            status = sl.generate_status_line("Opus")
            elapsed = (time.perf_counter() - start) * 1000
            warm_times.append(elapsed)
        
        avg_warm = sum(warm_times) / len(warm_times)
        min_warm = min(warm_times)
        max_warm = max(warm_times)
        
        print(f"\nWarm runs (10 iterations):")
        print(f"  Average: {avg_warm:.2f}ms")
        print(f"  Min: {min_warm:.2f}ms")
        print(f"  Max: {max_warm:.2f}ms")
        
        # Performance ratio
        print(f"\nCold/Warm ratio: {cold_elapsed/avg_warm:.1f}x slower")
    
    def profile_with_cprofile(self):
        """Use cProfile for detailed profiling"""
        print("\n=== DETAILED CPROFILE ANALYSIS ===")
        
        # Clear modules
        if 'statusline' in sys.modules:
            del sys.modules['statusline']
        
        pr = cProfile.Profile()
        pr.enable()
        
        # Profile the import and first execution
        import statusline
        sl = statusline.FlowForgeStatusLine()
        status = sl.generate_status_line("Opus")
        
        pr.disable()
        
        # Print statistics
        s = io.StringIO()
        ps = pstats.Stats(pr, stream=s).sort_stats('cumulative')
        ps.print_stats(30)  # Top 30 functions
        
        print(s.getvalue())
    
    def run_full_profile(self):
        """Run complete performance profile"""
        print("=" * 60)
        print("FLOWFORGE STATUSLINE PERFORMANCE PROFILER")
        print("=" * 60)
        
        self.profile_imports()
        self.profile_git_operations()
        self.profile_file_operations()
        self.profile_regex_compilation()
        self.profile_initialization()
        self.profile_full_execution()
        self.profile_with_cprofile()
        
        print("\n" + "=" * 60)
        print("PROFILING COMPLETE")
        print("=" * 60)


if __name__ == "__main__":
    profiler = StatusLineProfiler()
    profiler.run_full_profile()