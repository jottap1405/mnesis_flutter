#!/usr/bin/env python3
"""
Debug script to log exactly what stdin data Claude is sending.
This will help us understand if the context data is being passed.
"""

import sys
import json
import time

# Log file for debugging
log_file = '/tmp/claude_stdin_debug.log'

def log_message(msg):
    """Write message to debug log."""
    with open(log_file, 'a') as f:
        f.write(f"{time.time()}: {msg}\n")
        f.flush()

def main():
    """Read stdin and log everything for debugging."""
    try:
        log_message("=== DEBUG STDIN START ===")

        # Read all stdin
        stdin_raw = sys.stdin.read()
        log_message(f"Raw stdin length: {len(stdin_raw)}")
        log_message(f"Raw stdin content: {repr(stdin_raw)}")

        # Try to parse as JSON
        if stdin_raw:
            try:
                data = json.loads(stdin_raw)
                log_message(f"JSON parsed successfully")
                log_message(f"Keys: {list(data.keys())}")
                log_message(f"Model data: {data.get('model', {})}")
                log_message(f"Context data: {data.get('context', {})}")

                # Check for context
                context = data.get('context', {})
                if context:
                    used = context.get('used', 0)
                    max_val = context.get('max', 1)
                    percentage = (used / max_val * 100) if max_val > 0 else 0
                    log_message(f"Context percentage: {percentage}%")
                else:
                    log_message("NO CONTEXT DATA FOUND")

            except json.JSONDecodeError as e:
                log_message(f"JSON parse error: {e}")
        else:
            log_message("EMPTY STDIN")

        # Output a simple statusline to not break Claude
        print("[FlowForge] Debug Mode | Check /tmp/claude_stdin_debug.log", end='')

    except Exception as e:
        log_message(f"Error: {e}")
        print("[FlowForge] Debug Error", end='')
    finally:
        log_message("=== DEBUG STDIN END ===\n")

if __name__ == "__main__":
    main()