#!/usr/bin/env python3
"""
Integration test showing how MilestoneDetector integrates with FlowForge statusline.
Rule #25: Integration tests to verify component compatibility.
"""

import sys
import os
import tempfile
from pathlib import Path

# Add current directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from milestone_detector import MilestoneDetector
from statusline import FlowForgeStatusLine


def test_statusline_with_milestone_detection():
    """
    Integration test showing milestone detection in statusline context.
    Demonstrates how the MilestoneDetector can enhance status display.
    """
    print("=== FlowForge MilestoneDetector Integration Test ===\n")
    
    # Test 1: Normal mode (no milestone)
    print("1. Testing Normal Mode:")
    detector = MilestoneDetector()
    milestone_data = detector.detect_milestone_mode()
    
    if milestone_data:
        print(f"   ❌ Unexpected: Found milestone {milestone_data.name}")
    else:
        print("   ✅ Correctly detected normal mode (no milestone)")
    
    # Test 2: Milestone mode with sample data
    print("\n2. Testing Milestone Mode:")
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        
        # Create sample milestone context
        milestone_context_file = temp_path / ".milestone-context"
        milestone_context_file.write_text("v2.1-feature-milestone")
        
        # Create sample worktree config
        worktree_dir = temp_path / ".flowforge"
        worktree_dir.mkdir()
        worktree_config = worktree_dir / "worktree.json"
        worktree_config.write_text("""
{
  "milestone": "v2.1-feature-milestone",
  "branch": "milestone/v2.1-feature-milestone",
  "branch_pattern": "milestone/v2.1-feature-milestone/issue/{issue}",
  "merge_strategy": "milestone_first",
  "worktree_path": "/tmp/test-worktree",
  "created": "2024-12-09T10:30:00Z",
  "created_by": "test-developer",
  "purpose": "Feature development milestone"
}
        """.strip())
        
        # Test milestone detection
        milestone_detector = MilestoneDetector(temp_path)
        milestone_data = milestone_detector.detect_milestone_mode()
        
        if milestone_data:
            print(f"   ✅ Detected milestone: {milestone_data.name}")
            print(f"   ✅ Branch pattern: {milestone_data.branch_pattern}")
            print(f"   ✅ Source: {milestone_data.source}")
            print(f"   ✅ Created by: {milestone_data.created_by}")
        else:
            print("   ❌ Failed to detect milestone mode")
    
    # Test 3: Performance comparison
    print("\n3. Performance Test:")
    import time
    
    # Test normal statusline performance
    statusline = FlowForgeStatusLine()
    start_time = time.time()
    normal_status = statusline.generate_status_line("TestModel")
    normal_time = (time.time() - start_time) * 1000
    
    print(f"   Normal statusline: {normal_time:.2f}ms")
    print(f"   Status: {normal_status}")
    
    # Test milestone detection performance
    start_time = time.time()
    milestone_data = detector.detect_milestone_mode()
    milestone_time = (time.time() - start_time) * 1000
    
    print(f"   Milestone detection: {milestone_time:.2f}ms")
    
    if milestone_time < 10:  # Should be very fast
        print("   ✅ Milestone detection is performant")
    else:
        print("   ⚠️  Milestone detection might need optimization")
    
    print("\n=== Integration Test Complete ===")


def demo_enhanced_statusline():
    """
    Demonstration of how milestone data could enhance the statusline display.
    This shows the potential integration pattern.
    """
    print("\n=== Enhanced Statusline Demo ===")
    
    detector = MilestoneDetector()
    milestone_data = detector.detect_milestone_mode()
    
    if milestone_data:
        # Milestone mode statusline format
        enhanced_status = (
            f"🎯 MILESTONE: {milestone_data.name} | "
            f"Pattern: {milestone_data.branch_pattern} | "
            f"Source: {milestone_data.source} | "
            f"TestModel"
        )
        print(f"Milestone Mode: {enhanced_status}")
    else:
        # Normal mode statusline
        statusline = FlowForgeStatusLine()
        normal_status = statusline.generate_status_line("TestModel")
        print(f"Normal Mode: {normal_status}")


if __name__ == "__main__":
    try:
        test_statusline_with_milestone_detection()
        demo_enhanced_statusline()
    except Exception as e:
        print(f"Integration test failed: {e}")
        sys.exit(1)