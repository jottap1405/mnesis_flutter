#!/usr/bin/env python3
"""
Tests for transcript-based context calculation.
Following Rule #3: TDD - Write tests before implementation.
Following Rule #25: Comprehensive test coverage (80%+).
"""

import json
import tempfile
import os
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock, mock_open


class TestTranscriptContextParser(unittest.TestCase):
    """
    Test suite for parsing context from Claude transcript files.

    Tests the new transcript-based context calculation approach
    that reads from transcript.jsonl files provided by Claude Code.
    """

    def setUp(self):
        """Set up test fixtures."""
        self.test_transcript_content = [
            '{"type":"message","role":"user","content":"Test message from user"}',
            '{"type":"message","role":"assistant","content":"Test response from assistant with longer text to simulate actual usage"}',
            '{"type":"system","content":"System message with context"}',
            '{"type":"message","role":"user","content":"Another user message to add more content"}',
        ]

    def test_parse_empty_transcript(self):
        """Test parsing an empty transcript file."""
        from context_usage_calculator import get_context_from_transcript

        with tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False) as f:
            temp_path = f.name

        try:
            result = get_context_from_transcript(temp_path)
            self.assertIsNotNone(result)
            self.assertEqual(result['used'], 0)
            self.assertEqual(result['percentage'], 0)
        finally:
            os.unlink(temp_path)

    def test_parse_valid_transcript(self):
        """Test parsing a valid transcript with multiple messages."""
        from context_usage_calculator import get_context_from_transcript

        with tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False) as f:
            for line in self.test_transcript_content:
                f.write(line + '\n')
            temp_path = f.name

        try:
            result = get_context_from_transcript(temp_path)
            self.assertIsNotNone(result)
            self.assertGreater(result['used'], 0)
            self.assertLessEqual(result['percentage'], 100)
            self.assertEqual(result['max'], 200000)  # Opus 4.1 limit
        finally:
            os.unlink(temp_path)

    def test_parse_nonexistent_transcript(self):
        """Test handling of nonexistent transcript file."""
        from context_usage_calculator import get_context_from_transcript

        result = get_context_from_transcript('/nonexistent/path/transcript.jsonl')
        self.assertIsNone(result)

    def test_parse_malformed_transcript(self):
        """Test handling of malformed JSON in transcript."""
        from context_usage_calculator import get_context_from_transcript

        with tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False) as f:
            f.write('{"valid":"json"}\n')
            f.write('not valid json\n')
            f.write('{"another":"valid"}\n')
            temp_path = f.name

        try:
            result = get_context_from_transcript(temp_path)
            # Should still return a result, skipping bad lines
            self.assertIsNotNone(result)
        finally:
            os.unlink(temp_path)

    def test_calculate_token_estimation(self):
        """Test token estimation from character count."""
        from context_usage_calculator import estimate_tokens_from_chars

        # Test various character counts
        test_cases = [
            (0, 0),
            (4, 1),      # 4 chars = ~1 token
            (100, 25),   # 100 chars = ~25 tokens
            (1000, 250), # 1000 chars = ~250 tokens
        ]

        for char_count, expected_tokens in test_cases:
            result = estimate_tokens_from_chars(char_count)
            self.assertEqual(result, expected_tokens)

    def test_percentage_calculation(self):
        """Test context percentage calculation."""
        from context_usage_calculator import calculate_context_percentage

        # Test various scenarios
        test_cases = [
            (0, 200000, 0.0),
            (100000, 200000, 50.0),
            (200000, 200000, 100.0),
            (300000, 200000, 100.0),  # Should cap at 100%
        ]

        for used, max_tokens, expected_percentage in test_cases:
            result = calculate_context_percentage(used, max_tokens)
            self.assertAlmostEqual(result, expected_percentage, places=1)

    def test_stdin_with_transcript_path(self):
        """Test reading transcript path from stdin JSON."""
        from context_usage_calculator import extract_transcript_path_from_stdin

        stdin_data = {
            "model": {"id": "claude-3-opus", "display_name": "Opus 4.1"},
            "workspace": {"current_dir": "/test", "project_dir": "/test"},
            "session_id": "test-session",
            "transcript_path": "/path/to/transcript.jsonl"
        }

        with patch('sys.stdin.read', return_value=json.dumps(stdin_data)):
            path = extract_transcript_path_from_stdin()
            self.assertEqual(path, "/path/to/transcript.jsonl")

    def test_stdin_without_transcript_path(self):
        """Test handling stdin without transcript_path."""
        from context_usage_calculator import extract_transcript_path_from_stdin

        stdin_data = {
            "model": {"id": "claude-3-opus", "display_name": "Opus 4.1"},
            "workspace": {"current_dir": "/test", "project_dir": "/test"}
        }

        with patch('sys.stdin.read', return_value=json.dumps(stdin_data)):
            path = extract_transcript_path_from_stdin()
            self.assertIsNone(path)

    def test_large_transcript_performance(self):
        """Test performance with large transcript files."""
        from context_usage_calculator import get_context_from_transcript
        import time

        # Create a large transcript (1000 messages)
        with tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False) as f:
            for i in range(1000):
                message = {
                    "type": "message",
                    "role": "user" if i % 2 == 0 else "assistant",
                    "content": f"Message {i} " * 50  # ~250 chars per message
                }
                f.write(json.dumps(message) + '\n')
            temp_path = f.name

        try:
            start_time = time.time()
            result = get_context_from_transcript(temp_path)
            elapsed = time.time() - start_time

            self.assertIsNotNone(result)
            self.assertGreater(result['used'], 0)
            # Should complete within 100ms even for large files
            self.assertLess(elapsed, 0.1)
        finally:
            os.unlink(temp_path)

    def test_integration_with_statusline(self):
        """Test integration with main statusline function."""
        # This will test that the statusline properly uses transcript data
        # when context data is not directly in stdin

        stdin_data = {
            "model": {"id": "claude-3-opus", "display_name": "Opus 4.1"},
            "transcript_path": "/tmp/test_transcript.jsonl"
        }

        # Create a test transcript
        with tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False) as f:
            for line in self.test_transcript_content:
                f.write(line + '\n')
            transcript_path = f.name

        try:
            # Update stdin_data with actual transcript path
            stdin_data['transcript_path'] = transcript_path

            # Test that context is properly extracted
            from context_usage_calculator import get_context_from_stdin

            with patch('sys.stdin.read', return_value=json.dumps(stdin_data)):
                context = get_context_from_stdin()
                self.assertIsNotNone(context)
                self.assertIn('used', context)
                self.assertIn('max', context)
                self.assertIn('percentage', context)
                self.assertGreater(context['used'], 0)
        finally:
            os.unlink(transcript_path)


class TestModelLimits(unittest.TestCase):
    """Test model-specific token limits."""

    def test_get_model_token_limit(self):
        """Test getting token limits for different models."""
        from context_usage_calculator import get_model_token_limit

        test_cases = [
            ("Opus 4.1", 200000),
            ("Claude 3 Opus", 200000),
            ("Claude 3.5 Sonnet", 200000),
            ("Claude 3 Haiku", 200000),
            ("Unknown Model", 200000),  # Default
        ]

        for model_name, expected_limit in test_cases:
            result = get_model_token_limit(model_name)
            self.assertEqual(result, expected_limit)


if __name__ == '__main__':
    unittest.main()