#!/usr/bin/env python3
"""
Test suite to simulate Claude's exact behavior and ensure progress bars work.
Comprehensive test of stdin handling and progress bar rendering.
"""

import json
import subprocess
import os
import sys

def test_with_context():
    """Test statusline with context data (should show progress bars)."""
    test_data = {
        "model": {
            "display_name": "Opus 4.1"
        },
        "context": {
            "used": 85000,
            "max": 100000
        }
    }

    # Run statusline with JSON input
    result = subprocess.run(
        ['python', '.claude/statusline.py'],
        input=json.dumps(test_data),
        capture_output=True,
        text=True,
        cwd='/home/cruzalex/projects/dev/cruzalex/flowforge/FlowForge-statsline'
    )

    output = result.stdout
    print(f"WITH CONTEXT: {output}")

    # Check for expected elements
    assert "Opus 4.1" in output, f"Model name missing: {output}"

    # Look for progress bar elements (filled blocks █ or ▓)
    has_progress_bar = ("█" in output or "▓" in output or "░" in output)
    assert has_progress_bar, f"No progress bars found: {output}"

    # Check for context percentage
    has_context = ("85" in output or "📊" in output)
    assert has_context, f"No context percentage found: {output}"

    return output


def test_without_context():
    """Test statusline without context data (fallback behavior)."""
    test_data = {
        "model": {
            "display_name": "Opus 4.1"
        }
        # No context field
    }

    # Run statusline with JSON input
    result = subprocess.run(
        ['python', '.claude/statusline.py'],
        input=json.dumps(test_data),
        capture_output=True,
        text=True,
        cwd='/home/cruzalex/projects/dev/cruzalex/flowforge/FlowForge-statsline'
    )

    output = result.stdout
    print(f"WITHOUT CONTEXT: {output}")

    # Should still have basic elements
    assert "Opus 4.1" in output, f"Model name missing: {output}"
    assert "[FlowForge]" in output, f"FlowForge prefix missing: {output}"

    return output


def test_empty_stdin():
    """Test statusline with empty stdin (error handling)."""
    # Run statusline with empty input
    result = subprocess.run(
        ['python', '.claude/statusline.py'],
        input="",
        capture_output=True,
        text=True,
        cwd='/home/cruzalex/projects/dev/cruzalex/flowforge/FlowForge-statsline'
    )

    output = result.stdout
    print(f"EMPTY STDIN: {output}")

    # Should have fallback output
    assert "[FlowForge]" in output, f"FlowForge prefix missing: {output}"

    return output


def test_invalid_json():
    """Test statusline with invalid JSON (error handling)."""
    # Run statusline with invalid JSON
    result = subprocess.run(
        ['python', '.claude/statusline.py'],
        input="This is not JSON",
        capture_output=True,
        text=True,
        cwd='/home/cruzalex/projects/dev/cruzalex/flowforge/FlowForge-statsline'
    )

    output = result.stdout
    print(f"INVALID JSON: {output}")

    # Should have fallback output
    assert "[FlowForge]" in output, f"FlowForge prefix missing: {output}"

    return output


def main():
    """Run all tests and report results."""
    print("=" * 60)
    print("CLAUDE STATUSLINE SIMULATION TESTS")
    print("=" * 60)

    try:
        # Test 1: With context (should show progress bars)
        print("\n1. Testing WITH context data...")
        output1 = test_with_context()
        print("✅ PASSED: Progress bars and context shown")

        # Test 2: Without context (fallback)
        print("\n2. Testing WITHOUT context data...")
        output2 = test_without_context()
        print("✅ PASSED: Fallback without context works")

        # Test 3: Empty stdin
        print("\n3. Testing EMPTY stdin...")
        output3 = test_empty_stdin()
        print("✅ PASSED: Empty stdin handled gracefully")

        # Test 4: Invalid JSON
        print("\n4. Testing INVALID JSON...")
        output4 = test_invalid_json()
        print("✅ PASSED: Invalid JSON handled gracefully")

        print("\n" + "=" * 60)
        print("ALL TESTS PASSED! 🎉")
        print("=" * 60)

        print("\n📊 EXPECTED OUTPUT WITH CONTEXT:")
        print(output1)

        print("\n📊 ACTUAL BEHAVIOR:")
        print("- Progress bars: ✅ (when context provided)")
        print("- Context percentage: ✅ (when context provided)")
        print("- Fallback: ✅ (when no context)")
        print("- Error handling: ✅")

    except AssertionError as e:
        print(f"\n❌ TEST FAILED: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ UNEXPECTED ERROR: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()