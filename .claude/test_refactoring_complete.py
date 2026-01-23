#!/usr/bin/env python3
"""
Final verification that refactoring meets Rule #24 requirements.

Ensures:
1. milestone_mode_formatter.py is under 700 lines
2. All tests still pass
3. Extracted modules work correctly
4. No functionality was lost

Author: FlowForge Team
Since: 2.1.0
"""

import subprocess
import sys
from pathlib import Path

def check_line_count():
    """Verify main file is under 700 lines."""
    file_path = Path(__file__).parent / "milestone_mode_formatter.py"
    with open(file_path) as f:
        line_count = len(f.readlines())
    
    print(f"✅ Line count check: {line_count} lines (limit: 700)")
    if line_count > 700:
        print(f"  ❌ FAILED: File has {line_count - 700} lines over limit!")
        return False
    else:
        print(f"  ✅ PASSED: {700 - line_count} lines under limit")
        return True

def check_imports():
    """Verify all modules can be imported."""
    try:
        from milestone_mode_formatter import (
            MilestoneModeFormatter,
            MilestoneStatusLineData,
            format_milestone_statusline
        )
        print("✅ Main module imports successfully")
        
        from milestone_adapter import MilestoneModeAdapter
        print("✅ Adapter module imports successfully")
        
        return True
    except ImportError as e:
        print(f"❌ Import failed: {e}")
        return False

def run_tests():
    """Run all milestone formatter tests."""
    print("\n📋 Running test suite...")
    result = subprocess.run(
        [sys.executable, "test_milestone_mode_formatter.py"],
        capture_output=True,
        text=True,
        cwd=Path(__file__).parent
    )
    
    if "OK" in result.stderr or "OK" in result.stdout:
        print("✅ All tests passed")
        return True
    else:
        print("❌ Some tests failed")
        if "FAILED" in result.stderr:
            # Extract failure summary
            for line in result.stderr.split('\n'):
                if "FAILED" in line or "ERROR" in line:
                    print(f"  {line}")
        return False

def verify_functionality():
    """Verify core functionality still works."""
    from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData
    
    formatter = MilestoneModeFormatter(terminal_width=150)
    data = MilestoneStatusLineData(
        milestone_name="v2.0-demo",
        track_name="Track A",
        tasks_completed=5,
        tasks_total=10,
        current_session_time="01:30",
        eta_remaining="1.5h",
        git_branch="feature/test",
        model_name="Opus"
    )
    
    result = formatter.format(data)
    
    # Check all expected components are present
    checks = [
        ("🎯 MILESTONE: v2.0-demo", "Milestone header"),
        ("5/10", "Task progress"),
        ("ETA: 1.5h", "ETA display"),
        ("Opus", "Model name")
    ]
    
    all_good = True
    for expected, description in checks:
        if expected in result:
            print(f"  ✅ {description}: Found")
        else:
            print(f"  ❌ {description}: Missing!")
            all_good = False
    
    return all_good

def main():
    """Run all verification checks."""
    print("=" * 60)
    print("🔍 REFACTORING VERIFICATION - Rule #24 Compliance")
    print("=" * 60)
    
    results = []
    
    # Check 1: Line count
    print("\n📏 Check 1: Line Count")
    results.append(check_line_count())
    
    # Check 2: Imports
    print("\n📦 Check 2: Module Imports")
    results.append(check_imports())
    
    # Check 3: Tests
    print("\n🧪 Check 3: Test Suite")
    results.append(run_tests())
    
    # Check 4: Functionality
    print("\n⚙️ Check 4: Core Functionality")
    results.append(verify_functionality())
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 SUMMARY")
    print("=" * 60)
    
    if all(results):
        print("✅ ✅ ✅ REFACTORING SUCCESSFUL! ✅ ✅ ✅")
        print("All checks passed - Rule #24 compliance achieved!")
        return 0
    else:
        print("❌ REFACTORING INCOMPLETE")
        failed = sum(1 for r in results if not r)
        print(f"{failed} check(s) failed - needs attention")
        return 1

if __name__ == "__main__":
    sys.exit(main())