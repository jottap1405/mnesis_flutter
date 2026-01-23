#!/usr/bin/env python3
"""Targeted test for the billing file loading."""

import json
from unittest.mock import Mock, patch, mock_open
from pathlib import Path

from flowforge_time_integration import FlowForgeTimeIntegration

# Test data
sample_billing_data = {
    'current_session': {
        'issue_id': '420',
        'elapsed_minutes': 95
    }
}

def mock_exists(self):
    """Mock exists to return True only for billing file."""
    return str(self).endswith('time-tracking.json')

def mock_open_func(filename, mode='r'):
    """Mock open to only return data for billing file."""
    if 'time-tracking.json' in str(filename):
        return mock_open(read_data=json.dumps(sample_billing_data))()
    raise FileNotFoundError(f"No such file: {filename}")

# Patch more selectively
with patch.object(Path, 'exists', mock_exists):
    with patch('builtins.open', mock_open_func):
        integration = FlowForgeTimeIntegration()
        
        # Get session info
        session_info = integration._get_current_session_info(None)
        print(f"Session info: {session_info}")
        print(f"elapsed_minutes: {session_info.get('elapsed_minutes')}")
        
        # Get milestone data
        data = integration.get_milestone_time_data(8, 24)
        print(f"Progress rate: {data.progress_rate}")
        
        # Expected: 8 tasks in 95 minutes = 8/95 * 60 = 5.05 tasks/hour
        expected_rate = (8 / 95) * 60
        print(f"Expected rate: {expected_rate:.2f}")