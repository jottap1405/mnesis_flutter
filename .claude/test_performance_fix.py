#!/usr/bin/env python3
"""
Test the performance fix for statusline cold-start issue
"""

import time
import sys
import subprocess
from pathlib import Path

def test_performance(module_name: str):
    """Test performance of a statusline module"""
    print(f"\n{'='*60}")
    print(f"Testing: {module_name}")
    print('='*60)
    
    # Clear module cache
    for mod in list(sys.modules.keys()):
        if module_name in mod or 'formatter' in mod or 'milestone' in mod:
            del sys.modules[mod]
    
    # Import module
    start = time.perf_counter()
    if module_name == 'statusline':
        import statusline as sl_module
    else:
        import statusline_optimized as sl_module
    
    # Create instance
    sl = sl_module.FlowForgeStatusLine()
    
    # First run (cold)
    status = sl.generate_status_line("Opus")
    cold_time = (time.perf_counter() - start) * 1000
    
    print(f"Cold start: {cold_time:.2f}ms")
    print(f"Output: {status[:80]}...")
    
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
    
    # Performance assessment
    print(f"\nPerformance:")
    if cold_time < 50:
        print(f"  ✅ EXCELLENT: Cold start under 50ms target")
    elif cold_time < 100:
        print(f"  ✅ GOOD: Cold start under 100ms")
    elif cold_time < 500:
        print(f"  ⚠️  WARNING: Cold start {cold_time:.0f}ms (target: <50ms)")
    else:
        print(f"  ❌ FAILED: Cold start {cold_time:.0f}ms (target: <50ms)")
    
    print(f"  Cold/Warm ratio: {cold_time/avg_warm:.1f}x")
    
    return cold_time, avg_warm

# Test original version
print("FLOWFORGE STATUSLINE PERFORMANCE TEST")
print("="*60)

original_cold, original_warm = test_performance('statusline')

# Test optimized version
optimized_cold, optimized_warm = test_performance('statusline_optimized')

# Summary
print(f"\n{'='*60}")
print("PERFORMANCE COMPARISON")
print('='*60)
print(f"Original version:")
print(f"  Cold start: {original_cold:.2f}ms")
print(f"  Warm average: {original_warm:.2f}ms")

print(f"\nOptimized version:")
print(f"  Cold start: {optimized_cold:.2f}ms")
print(f"  Warm average: {optimized_warm:.2f}ms")

print(f"\nImprovement:")
improvement = ((original_cold - optimized_cold) / original_cold) * 100
print(f"  Cold start: {improvement:.1f}% faster")
print(f"  Speed-up: {original_cold / optimized_cold:.1f}x")

if optimized_cold < 50:
    print(f"\n✅ SUCCESS: Optimized version meets <50ms target!")
elif optimized_cold < 100:
    print(f"\n✅ GOOD: Optimized version is under 100ms")
else:
    print(f"\n⚠️  More optimization needed: {optimized_cold:.0f}ms > 50ms target")