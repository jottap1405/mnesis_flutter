#!/usr/bin/env python3
"""
Context Usage Calculator for FlowForge StatusLine.

Calculates context usage from Claude Code transcript files.
Following Rule #26: Complete documentation for all functions.
Following Rule #8: Proper error handling in all functions.
"""

import json
import os
import sys
from typing import Optional, Dict, Any, NamedTuple
from pathlib import Path
import time


class ContextUsageData(NamedTuple):
    """
    Context usage data structure.

    Attributes:
        used_tokens: Number of tokens used
        max_tokens: Maximum tokens allowed
        percentage: Usage percentage (0-100)
        char_count: Character count for debugging
        exceeds_limit: Whether context exceeds 200k tokens
        should_display: Whether to display context in statusline
    """
    used_tokens: int
    max_tokens: int
    percentage: float
    char_count: int
    exceeds_limit: bool = False
    should_display: bool = True


class ContextUsageCalculator:
    """
    Context usage calculator that parses Claude transcript files.

    Provides methods to calculate context usage from Claude Code's
    transcript files instead of relying on stdin context data.
    """

    # Model token limits (updated for 2025)
    MODEL_LIMITS = {
        "Opus 4.1": 200000,
        "Claude 3 Opus": 200000,
        "Claude 3.5 Sonnet": 200000,
        "Claude 3 Haiku": 200000,
        "Claude-3-opus": 200000,
        "Claude-3.5-sonnet": 200000,
        "Claude-3-haiku": 200000,
        "Claude Opus": 200000,
        "Claude Sonnet": 200000,
        "Claude Haiku": 200000,
        # Claude Sonnet 4 with 1M context window
        "Claude Sonnet 4 1M": 1000000,
        "Claude Sonnet 4 (1M)": 1000000,
        "Claude-sonnet-4-1m": 1000000,
    }

    # Token estimation ratio
    CHARS_PER_TOKEN = 4

    def __init__(self, base_path: Optional[Path] = None):
        """
        Initialize context usage calculator.

        Args:
            base_path: Base directory path (defaults to current directory)
        """
        self.base_path = base_path or Path.cwd()

    def estimate_tokens_from_chars(self, char_count: int) -> int:
        """
        Estimate token count from character count.

        Uses the rough approximation of 1 token ≈ 4 characters,
        which is a common estimate for English text with Claude/GPT models.

        Args:
            char_count: Number of characters

        Returns:
            int: Estimated number of tokens
        """
        return max(0, char_count // self.CHARS_PER_TOKEN)

    def calculate_percentage(self, used_tokens: int, max_tokens: int) -> float:
        """
        Calculate context usage percentage.

        Args:
            used_tokens: Number of tokens used
            max_tokens: Maximum tokens allowed

        Returns:
            float: Percentage used (0-100), capped at 100
        """
        if max_tokens <= 0:
            return 0.0

        percentage = (used_tokens / max_tokens) * 100
        return min(100.0, max(0.0, percentage))

    def get_model_token_limit(self, model_name: str, stdin_data: str = "") -> int:
        """
        Get token limit for a specific model.

        Detects model from stdin data if available, checking for:
        1. Explicit context_window field
        2. Model name with 1M indicator
        3. Known model names

        Args:
            model_name: Name of the model
            stdin_data: Optional stdin data with model info

        Returns:
            int: Token limit for the model
        """
        # First check stdin for explicit context window
        if stdin_data:
            try:
                data = json.loads(stdin_data)
                model_info = data.get('model', {})

                # Check for explicit context_window field
                context_window = model_info.get('context_window', '')
                if '1M' in str(context_window) or '1000000' in str(context_window):
                    return 1000000
                elif '200k' in str(context_window) or '200000' in str(context_window):
                    return 200000

                # Check display_name for 1M indicator
                display_name = model_info.get('display_name', '')
                if '1M' in display_name or '1000000' in display_name:
                    return 1000000
            except (json.JSONDecodeError, KeyError, TypeError):
                pass

        # Check if model name indicates 1M context
        if '1M' in model_name or '1000000' in model_name:
            return 1000000

        # Check if model name contains any known model
        model_name_lower = model_name.lower()
        for known_model, limit in self.MODEL_LIMITS.items():
            if known_model.lower() in model_name_lower:
                return limit

        # Default to 200k for unknown models
        return 200000

    def parse_transcript_file(self, transcript_path: str) -> Optional[Dict[str, Any]]:
        """
        Parse transcript file to calculate context usage.

        Reads a JSONL transcript file and extracts token usage from
        the last message's usage data, or falls back to character counting.

        Args:
            transcript_path: Path to the transcript.jsonl file

        Returns:
            Dict with 'used', 'max', 'percentage', 'char_count' keys, or None if error
        """
        if not transcript_path or not os.path.exists(transcript_path):
            return None

        total_chars = 0
        lines_processed = 0
        last_usage_data = None

        try:
            with open(transcript_path, 'r', encoding='utf-8') as f:
                for line in f:
                    line = line.strip()
                    if not line:
                        continue

                    try:
                        data = json.loads(line)
                        lines_processed += 1

                        # Check for usage data in message (preferred method)
                        if 'message' in data and 'usage' in data['message']:
                            usage = data['message']['usage']
                            # Store the last message's usage data
                            last_usage_data = usage

                        # Count content from various message types (fallback)
                        if 'content' in data:
                            content = data['content']
                            if isinstance(content, str):
                                total_chars += len(content)
                            elif isinstance(content, list):
                                # Handle structured content (like tool calls)
                                for item in content:
                                    if isinstance(item, dict):
                                        if 'text' in item:
                                            total_chars += len(item['text'])
                                        # Count tool call parameters
                                        if 'parameters' in item:
                                            total_chars += len(str(item['parameters']))
                                    elif isinstance(item, str):
                                        total_chars += len(item)

                        # Also count tool inputs/outputs if present
                        if 'tool_input' in data:
                            total_chars += len(str(data['tool_input']))
                        if 'tool_output' in data:
                            total_chars += len(str(data['tool_output']))

                        # Count function call content
                        if 'function_call' in data:
                            total_chars += len(str(data['function_call']))

                        # Count assistant content
                        if 'assistant' in data:
                            total_chars += len(str(data['assistant']))

                        # Count user message content
                        if 'user' in data:
                            total_chars += len(str(data['user']))

                    except (json.JSONDecodeError, KeyError, TypeError):
                        # Skip malformed lines but continue processing
                        continue

        except (IOError, UnicodeDecodeError, OSError) as e:
            # Rule #8: Proper error handling
            return None

        # Use actual token data if available
        if last_usage_data:
            # Active context = cache_read + cache_creation tokens
            cache_read = last_usage_data.get('cache_read_input_tokens', 0)
            cache_creation = last_usage_data.get('cache_creation_input_tokens', 0)
            actual_tokens = cache_read + cache_creation

            # If no cache tokens, fall back to input/output tokens
            if actual_tokens == 0:
                input_tokens = last_usage_data.get('input_tokens', 0)
                output_tokens = last_usage_data.get('output_tokens', 0)
                actual_tokens = input_tokens + output_tokens

            if actual_tokens > 0:
                max_tokens = 200000  # Default Opus 4.1 limit
                percentage = self.calculate_percentage(actual_tokens, max_tokens)

                return {
                    'used': actual_tokens,
                    'max': max_tokens,
                    'percentage': percentage,
                    'char_count': total_chars,
                    'lines_processed': lines_processed,
                    'source': 'usage_data'
                }

        # Fall back to character-based estimation
        estimated_tokens = self.estimate_tokens_from_chars(total_chars)
        max_tokens = 200000  # Default Opus 4.1 limit
        percentage = self.calculate_percentage(estimated_tokens, max_tokens)

        return {
            'used': estimated_tokens,
            'max': max_tokens,
            'percentage': percentage,
            'char_count': total_chars,
            'lines_processed': lines_processed,
            'source': 'character_estimation'
        }

    def extract_transcript_path_from_stdin(self, stdin_data: str) -> Optional[str]:
        """
        Extract transcript path from stdin JSON data.

        Claude Code sends a JSON object via stdin that includes
        the path to the current transcript file.

        Args:
            stdin_data: Pre-read stdin content

        Returns:
            str: Path to transcript file, or None if not found
        """
        if not stdin_data:
            return None

        try:
            data = json.loads(stdin_data)
            return data.get('transcript_path')

        except (json.JSONDecodeError, KeyError):
            return None

    def calculate_context_usage(self, model_name: str, stdin_data: str = "") -> ContextUsageData:
        """
        Calculate context usage from transcript file.

        This is the main entry point that:
        1. Tries to extract transcript_path from stdin
        2. Parses the transcript file
        3. Calculates context usage with model-specific limits

        Args:
            model_name: AI model name for token limit
            stdin_data: Pre-read stdin content (optional)

        Returns:
            ContextUsageData: Context usage data
        """
        # Get model-specific token limit
        max_tokens = self.get_model_token_limit(model_name, stdin_data)

        # Default values - include new fields with defaults
        default_data = ContextUsageData(0, max_tokens, 0.0, 0, False, True)

        # First check if context data is directly in stdin (backwards compatibility)
        if stdin_data:
            try:
                data = json.loads(stdin_data)

                # Check if context is directly provided (old format)
                if 'context' in data:
                    context = data['context']
                    if 'used' in context and 'max' in context:
                        percentage = self.calculate_percentage(
                            context['used'],
                            context['max']
                        )
                        return ContextUsageData(
                            used_tokens=context['used'],
                            max_tokens=context['max'],
                            percentage=percentage,
                            char_count=0,  # Unknown for old format
                            exceeds_limit=False,
                            should_display=True
                        )

                # New format: transcript_path is provided
                transcript_path = data.get('transcript_path')
                if transcript_path:
                    # Parse transcript
                    context_data = self.parse_transcript_file(transcript_path)

                    if context_data:
                        # Use model-aware max tokens
                        percentage = self.calculate_percentage(
                            context_data['used'],
                            max_tokens
                        )

                        return ContextUsageData(
                            used_tokens=context_data['used'],
                            max_tokens=max_tokens,
                            percentage=percentage,
                            char_count=context_data['char_count'],
                            exceeds_limit=False,
                            should_display=True
                        )

            except (json.JSONDecodeError, KeyError, ValueError, TypeError):
                # Fall through to default
                pass

        # Try to find transcript file in common locations if stdin doesn't have it
        transcript_candidates = [
            # Claude Code common locations
            Path.home() / '.claude' / 'transcript.jsonl',
            Path('/tmp') / 'claude_transcript.jsonl',
            self.base_path / 'transcript.jsonl',
            # Look for most recent transcript in temp directories
            Path('/var/folders').glob('*/*/T/TemporaryItems/**/transcript*.jsonl'),
            Path('/tmp').glob('transcript*.jsonl'),
        ]

        for candidate in transcript_candidates:
            if isinstance(candidate, Path) and candidate.exists():
                context_data = self.parse_transcript_file(str(candidate))
                if context_data:
                    percentage = self.calculate_percentage(
                        context_data['used'],
                        max_tokens
                    )

                    return ContextUsageData(
                        used_tokens=context_data['used'],
                        max_tokens=max_tokens,
                        percentage=percentage,
                        char_count=context_data['char_count'],
                        exceeds_limit=False,
                        should_display=True
                    )

        return default_data

    def calculate_context_usage_with_exceeds_flag(self, model_name: str, stdin_data: str = "") -> ContextUsageData:
        """
        Calculate context usage with exceeds_200k_tokens flag support.

        This method implements the new behavior:
        1. If exceeds_200k_tokens is true, return 100% and display
        2. If exceeds_200k_tokens is false or missing, try to calculate from transcript
        3. Only hide context if we can't calculate it at all

        Args:
            model_name: AI model name for token limit
            stdin_data: Pre-read stdin content containing exceeds flag

        Returns:
            ContextUsageData: Context usage data with display flag

        Raises:
            No exceptions - returns safe defaults on any error
        """
        # Get model-aware token limit
        max_tokens = self.get_model_token_limit(model_name, stdin_data)

        # Default: don't display context
        default_data = ContextUsageData(
            used_tokens=0,
            max_tokens=max_tokens,
            percentage=0.0,
            char_count=0,
            exceeds_limit=False,
            should_display=False
        )

        if not stdin_data:
            return default_data

        try:
            data = json.loads(stdin_data)

            # Extract exceeds flag for the model's specific limit
            # For 1M models, check exceeds_1m_tokens if available
            if max_tokens == 1000000:
                exceeds_flag = data.get('exceeds_1m_tokens', data.get('exceeds_200k_tokens', False))
            else:
                exceeds_flag = data.get('exceeds_200k_tokens', False)

            # Handle various data types for the flag
            if isinstance(exceeds_flag, str):
                exceeds_flag = exceeds_flag.lower() in ['true', '1']
            elif isinstance(exceeds_flag, (int, float)):
                exceeds_flag = bool(exceeds_flag)

            if exceeds_flag:
                # When context exceeds limit, show 100%
                return ContextUsageData(
                    used_tokens=max_tokens,
                    max_tokens=max_tokens,
                    percentage=100.0,
                    char_count=0,  # Unknown when using flag
                    exceeds_limit=True,
                    should_display=True
                )

            # When exceeds_200k_tokens is false, try to calculate from transcript
            transcript_path = data.get('transcript_path')
            if transcript_path:
                context_data = self.parse_transcript_file(transcript_path)
                if context_data:
                    # Use model-aware max tokens for percentage calculation
                    percentage = self.calculate_percentage(
                        context_data['used'],
                        max_tokens
                    )

                    # Always display if we successfully calculated context
                    return ContextUsageData(
                        used_tokens=context_data['used'],
                        max_tokens=max_tokens,
                        percentage=percentage,
                        char_count=context_data['char_count'],
                        exceeds_limit=False,
                        should_display=True  # Show context when we have data
                    )

            # Only hide context if we really can't calculate it
            # (no transcript or parsing failed)
            return ContextUsageData(
                used_tokens=0,
                max_tokens=max_tokens,
                percentage=0.0,
                char_count=0,
                exceeds_limit=False,
                should_display=False  # Hide only when no data available
            )

        except (json.JSONDecodeError, KeyError, ValueError, TypeError, Exception):
            # Rule #8: Proper error handling - return safe default
            return default_data