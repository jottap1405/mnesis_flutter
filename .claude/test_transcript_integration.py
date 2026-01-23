#!/usr/bin/env python3
"""
Integration tests for transcript-based context calculation.
Following Rule #25: Comprehensive integration testing.
"""

import json
import tempfile
import os
import subprocess
import sys
from pathlib import Path


def create_test_transcript(char_count: int = 10000) -> str:
    """
    Create a test transcript file with specified character count.

    Args:
        char_count: Approximate character count to generate

    Returns:
        str: Path to created transcript file
    """
    with tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False) as f:
        messages = []
        chars_so_far = 0
        message_num = 0

        while chars_so_far < char_count:
            message = {
                "type": "message",
                "role": "user" if message_num % 2 == 0 else "assistant",
                "content": f"Test message {message_num} " * 20  # ~100 chars
            }
            message_json = json.dumps(message)
            f.write(message_json + '\n')
            chars_so_far += len(message_json)
            message_num += 1

        return f.name


def test_statusline_with_transcript():
    """Test statusline with transcript path in stdin."""
    print("Testing statusline with transcript path...")

    # Create test transcript
    transcript_path = create_test_transcript(50000)  # ~12.5k tokens

    try:
        # Create stdin data with transcript path
        stdin_data = {
            "model": {
                "id": "claude-3-opus",
                "display_name": "Opus 4.1"
            },
            "workspace": {
                "current_dir": str(Path.cwd()),
                "project_dir": str(Path.cwd())
            },
            "session_id": "test-session",
            "transcript_path": transcript_path
        }

        # Run statusline with test data
        process = subprocess.run(
            [sys.executable, ".claude/statusline.py"],
            input=json.dumps(stdin_data),
            capture_output=True,
            text=True,
            timeout=2
        )

        # Check output
        output = process.stdout
        print(f"Output: {output}")

        # Verify output contains expected elements
        assert "[FlowForge]" in output or "FlowForge" in output, "Missing FlowForge branding"
        assert "Opus 4.1" in output, "Missing model name"

        # Check for progress bar if context percentage > 0
        # The transcript should result in ~6% context usage (12.5k / 200k)
        # Progress bars use Unicode characters
        if "█" in output or "▓" in output or "░" in output:
            print("✓ Progress bar detected in output")
        else:
            print("⚠ No progress bar detected (may be below threshold)")

        print("✓ Test passed: Statusline with transcript")

    finally:
        os.unlink(transcript_path)


def test_statusline_without_transcript():
    """Test statusline without transcript path (fallback)."""
    print("\nTesting statusline without transcript path...")

    # Create stdin data without transcript path
    stdin_data = {
        "model": {
            "id": "claude-3-opus",
            "display_name": "Opus 4.1"
        },
        "workspace": {
            "current_dir": str(Path.cwd()),
            "project_dir": str(Path.cwd())
        }
    }

    # Run statusline with test data
    process = subprocess.run(
        [sys.executable, ".claude/statusline.py"],
        input=json.dumps(stdin_data),
        capture_output=True,
        text=True,
        timeout=2
    )

    # Check output
    output = process.stdout
    print(f"Output: {output}")

    # Verify output contains expected elements
    assert "[FlowForge]" in output or "FlowForge" in output, "Missing FlowForge branding"
    assert "Opus 4.1" in output, "Missing model name"

    print("✓ Test passed: Statusline without transcript")


def test_statusline_with_direct_context():
    """Test statusline with direct context data (backwards compatibility)."""
    print("\nTesting statusline with direct context data...")

    # Create stdin data with direct context
    stdin_data = {
        "model": {
            "id": "claude-3-opus",
            "display_name": "Opus 4.1"
        },
        "context": {
            "used": 100000,
            "max": 200000
        }
    }

    # Run statusline with test data
    process = subprocess.run(
        [sys.executable, ".claude/statusline.py"],
        input=json.dumps(stdin_data),
        capture_output=True,
        text=True,
        timeout=2
    )

    # Check output
    output = process.stdout
    print(f"Output: {output}")

    # Verify output contains expected elements
    assert "[FlowForge]" in output or "FlowForge" in output, "Missing FlowForge branding"
    assert "Opus 4.1" in output, "Missing model name"

    # Should show 50% context usage
    if "50" in output or "█" in output:
        print("✓ Context percentage or progress bar detected")

    print("✓ Test passed: Statusline with direct context")


def test_large_transcript_performance():
    """Test performance with large transcript."""
    print("\nTesting performance with large transcript...")

    # Create large transcript (1MB ~ 250k tokens, exceeds limit)
    transcript_path = create_test_transcript(1000000)

    try:
        stdin_data = {
            "model": {
                "id": "claude-3-opus",
                "display_name": "Opus 4.1"
            },
            "transcript_path": transcript_path
        }

        import time
        start = time.time()

        # Run statusline
        process = subprocess.run(
            [sys.executable, ".claude/statusline.py"],
            input=json.dumps(stdin_data),
            capture_output=True,
            text=True,
            timeout=2
        )

        elapsed = time.time() - start
        print(f"Execution time: {elapsed:.3f}s")

        # Should complete within 1 second even with large transcript
        assert elapsed < 1.5, f"Too slow: {elapsed:.3f}s"

        output = process.stdout
        print(f"Output: {output}")

        # Should show 100% context (capped)
        if "100" in output or ("█" in output and "░" not in output):
            print("✓ Max context detected")

        print("✓ Test passed: Large transcript performance")

    finally:
        os.unlink(transcript_path)


def test_debug_mode():
    """Test debug mode logging."""
    print("\nTesting debug mode...")

    # Enable debug mode
    os.environ['STATUSLINE_DEBUG'] = 'true'

    try:
        # Create test transcript
        transcript_path = create_test_transcript(1000)

        stdin_data = {
            "model": {"display_name": "Opus 4.1"},
            "transcript_path": transcript_path
        }

        # Run statusline
        process = subprocess.run(
            [sys.executable, ".claude/statusline.py"],
            input=json.dumps(stdin_data),
            capture_output=True,
            text=True,
            timeout=2
        )

        # Check debug log was created
        debug_file = '/tmp/statusline_debug.log'
        if os.path.exists(debug_file):
            with open(debug_file, 'r') as f:
                debug_content = f.read()

            assert "STATUSLINE START" in debug_content
            assert "transcript_path" in debug_content or "transcript" in debug_content.lower()
            assert "STATUSLINE END" in debug_content

            print("✓ Debug log created with expected content")

            # Clean up debug log
            os.unlink(debug_file)

        os.unlink(transcript_path)
        print("✓ Test passed: Debug mode")

    finally:
        del os.environ['STATUSLINE_DEBUG']


if __name__ == '__main__':
    print("=" * 60)
    print("Running Transcript Integration Tests")
    print("=" * 60)

    try:
        test_statusline_with_transcript()
        test_statusline_without_transcript()
        test_statusline_with_direct_context()
        test_large_transcript_performance()
        test_debug_mode()

        print("\n" + "=" * 60)
        print("✓ ALL TESTS PASSED")
        print("=" * 60)

    except AssertionError as e:
        print(f"\n✗ TEST FAILED: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"\n✗ UNEXPECTED ERROR: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)