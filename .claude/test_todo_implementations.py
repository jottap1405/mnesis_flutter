#!/usr/bin/env python3
"""
Test suite for TODO implementations in statusline components.

Testing all missing functionality that was marked as TODO:
1. Context usage detection in statusline.py
2. Session time tracking in statusline.py  
3. Model name auto-detection
4. ETA calculation for milestone mode
5. Track name extraction from milestone context

Following Rule #3: TDD - Write tests BEFORE implementation
"""

import unittest
import json
import tempfile
import os
from pathlib import Path
from datetime import datetime, timedelta
from unittest.mock import patch, MagicMock, mock_open

# Import the modules we're testing
import sys
sys.path.insert(0, str(Path(__file__).parent))

from statusline import FlowForgeStatusLine
from status_formatter_interface import FormattingContext
from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData
from context_usage_calculator import ContextUsageCalculator
from flowforge_time_integration import FlowForgeTimeIntegration


class TestContextUsageDetection(unittest.TestCase):
    """Tests for context usage detection implementation."""
    
    def setUp(self):
        """Set up test environment with temporary directory."""
        self.temp_dir = tempfile.mkdtemp()
        self.base_path = Path(self.temp_dir)
        
        # Create necessary directories
        (self.base_path / '.flowforge' / 'local').mkdir(parents=True)
        (self.base_path / '.flowforge' / 'billing').mkdir(parents=True)
        
        # Create test session file with context usage data
        session_data = {
            'active': True,
            'context_usage': {
                'conversation_tokens': 42500,
                'token_limit': 50000
            },
            'current_issue': '420',
            'session_start': datetime.now().isoformat()
        }
        
        session_file = self.base_path / '.flowforge' / 'local' / 'session.json'
        with open(session_file, 'w') as f:
            json.dump(session_data, f)
    
    def tearDown(self):
        """Clean up temporary directory."""
        import shutil
        shutil.rmtree(self.temp_dir)
    
    def test_context_usage_in_formatting_context(self):
        """Test that FormattingContext includes accurate context usage."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        # Build formatting context  
        context = statusline._build_formatting_context(
            model_name="Claude-3-Opus",
            prefer_local=True
        )
        
        # Verify context usage is calculated (85% = 42500/50000)
        self.assertAlmostEqual(context.context_usage, 85.0, places=1)
        self.assertIsInstance(context.context_usage, float)
        self.assertGreaterEqual(context.context_usage, 0.0)
        self.assertLessEqual(context.context_usage, 100.0)
    
    def test_context_usage_from_calculator(self):
        """Test direct context usage calculation."""
        calculator = ContextUsageCalculator(base_path=self.base_path)
        
        usage_data = calculator.calculate_context_usage()
        
        # Should read from session file
        self.assertEqual(usage_data.conversation_tokens, 42500)
        self.assertEqual(usage_data.token_limit, 50000)
        self.assertAlmostEqual(usage_data.percentage, 85.0, places=1)
        self.assertEqual(usage_data.warning_level, 'moderate')
    
    def test_context_usage_fallback_when_no_data(self):
        """Test fallback when no context data available."""
        empty_path = Path(tempfile.mkdtemp())
        statusline = FlowForgeStatusLine(base_path=empty_path)
        
        context = statusline._build_formatting_context(
            model_name="Claude-3-Opus",
            prefer_local=True
        )
        
        # Should fallback to 0.0
        self.assertEqual(context.context_usage, 0.0)
        
        import shutil
        shutil.rmtree(empty_path)


class TestSessionTimeTracking(unittest.TestCase):
    """Tests for session time tracking implementation."""
    
    def setUp(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.base_path = Path(self.temp_dir)
        
        # Create necessary directories
        (self.base_path / '.flowforge' / 'local').mkdir(parents=True)
        (self.base_path / '.flowforge' / 'billing').mkdir(parents=True)
        
        # Create test session with start time
        session_start = datetime.now() - timedelta(hours=1, minutes=23)
        session_data = {
            'active': True,
            'current_issue': '420',
            'session_start': session_start.isoformat(),
            'planned_time': '2:00',  # 2 hours planned
            'elapsed_minutes': 83  # 1:23 elapsed
        }
        
        session_file = self.base_path / '.flowforge' / 'local' / 'session.json'
        with open(session_file, 'w') as f:
            json.dump(session_data, f)
    
    def tearDown(self):
        """Clean up temporary directory."""
        import shutil
        shutil.rmtree(self.temp_dir)
    
    def test_elapsed_time_in_normal_formatter_adapter(self):
        """Test elapsed time is populated in NormalStatusData."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        context = statusline._build_formatting_context(
            model_name="Claude-3-Opus",
            prefer_local=True
        )
        
        # Create adapter data
        normal_data = statusline.create_normal_formatter_adapter(context)
        
        # Should have elapsed time from session
        self.assertEqual(normal_data.elapsed_time, "01:23")
        self.assertNotEqual(normal_data.elapsed_time, "00:00")
    
    def test_planned_time_in_normal_formatter_adapter(self):
        """Test planned time is populated in NormalStatusData."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        context = statusline._build_formatting_context(
            model_name="Claude-3-Opus", 
            prefer_local=True
        )
        
        normal_data = statusline.create_normal_formatter_adapter(context)
        
        # Should have planned time from session
        self.assertEqual(normal_data.planned_time, "2:00")
        self.assertNotEqual(normal_data.planned_time, "0:00")
    
    def test_session_time_in_milestone_formatter_adapter(self):
        """Test session time is populated in MilestoneStatusData."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        context = statusline._build_formatting_context(
            model_name="Claude-3-Opus",
            prefer_local=True
        )
        
        milestone_data = statusline.create_milestone_formatter_adapter(context)
        
        # Should have current session time
        self.assertEqual(milestone_data.current_session_time, "01:23")
        self.assertNotEqual(milestone_data.current_session_time, "00:00")
    
    def test_session_time_from_time_integration(self):
        """Test direct session time retrieval."""
        integration = FlowForgeTimeIntegration(base_path=self.base_path)
        
        session_data = integration.get_session_time_data('420')
        
        # Should match test data
        self.assertEqual(session_data.elapsed_time, "01:23")
        self.assertEqual(session_data.planned_time, "2:00")
        self.assertTrue(session_data.is_active)
        self.assertEqual(session_data.overtime_minutes, 0)  # Under planned time


class TestModelNameDetection(unittest.TestCase):
    """Tests for model name auto-detection."""
    
    def setUp(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.base_path = Path(self.temp_dir)
        
        # Create necessary directories
        (self.base_path / '.flowforge' / 'local').mkdir(parents=True)
        
        # Create session with model info
        session_data = {
            'active': True,
            'model_name': 'Claude-3-Opus',
            'model_version': '4.1'
        }
        
        session_file = self.base_path / '.flowforge' / 'local' / 'session.json'
        with open(session_file, 'w') as f:
            json.dump(session_data, f)
    
    def tearDown(self):
        """Clean up temporary directory."""
        import shutil
        shutil.rmtree(self.temp_dir)
    
    def test_model_name_from_session_file(self):
        """Test model name detection from session file."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        # Should detect from session file
        model_name = statusline._detect_model_name()
        
        self.assertEqual(model_name, "Claude-3-Opus")
        self.assertNotEqual(model_name, "Model")  # Not placeholder
    
    def test_model_name_from_environment(self):
        """Test model name detection from environment variable."""
        with patch.dict(os.environ, {'CLAUDE_MODEL': 'Claude-3-Sonnet'}):
            statusline = FlowForgeStatusLine(base_path=Path(tempfile.mkdtemp()))
            
            model_name = statusline._detect_model_name()
            
            self.assertEqual(model_name, "Claude-3-Sonnet")
    
    def test_model_name_fallback(self):
        """Test model name fallback when no data available."""
        empty_path = Path(tempfile.mkdtemp())
        statusline = FlowForgeStatusLine(base_path=empty_path)
        
        model_name = statusline._detect_model_name()
        
        # Should use fallback
        self.assertEqual(model_name, "Claude")
        
        import shutil
        shutil.rmtree(empty_path)
    
    def test_model_name_in_milestone_formatter(self):
        """Test model name in MilestoneModeFormatter."""
        formatter = MilestoneModeFormatter(base_path=self.base_path)
        
        data = MilestoneStatusLineData(
            milestone_name="v2.0",
            track_name="Feature",
            tasks_completed=5,
            tasks_total=12,
            current_session_time="01:23",
            eta_remaining="3.2h",
            git_branch="feature/420",
            model_name=""  # Empty, should be detected
        )
        
        # Should detect and populate model name
        formatted = formatter.format(data)
        self.assertIn("Opus", formatted)  # Should include detected model


class TestETACalculation(unittest.TestCase):
    """Tests for ETA calculation in milestone mode."""
    
    def setUp(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.base_path = Path(self.temp_dir)
        
        # Create necessary directories
        (self.base_path / '.flowforge' / 'local').mkdir(parents=True)
        
        # Create session with progress data
        session_data = {
            'active': True,
            'elapsed_minutes': 95,  # 95 minutes elapsed
            'milestone': {
                'tasks_completed': 8,
                'tasks_total': 24
            }
        }
        
        session_file = self.base_path / '.flowforge' / 'local' / 'session.json'
        with open(session_file, 'w') as f:
            json.dump(session_data, f)
    
    def tearDown(self):
        """Clean up temporary directory."""
        import shutil
        shutil.rmtree(self.temp_dir)
    
    def test_eta_calculation_from_progress(self):
        """Test ETA calculation based on progress rate."""
        integration = FlowForgeTimeIntegration(base_path=self.base_path)
        
        # 8 tasks in 95 minutes = 11.875 min/task
        # 16 remaining tasks = 190 minutes = 3.17 hours
        milestone_data = integration.get_milestone_time_data(8, 24)
        
        self.assertEqual(milestone_data.eta_remaining, "3.2h")
        self.assertAlmostEqual(milestone_data.progress_rate, 5.05, places=1)  # tasks/hour
    
    def test_eta_in_milestone_formatter(self):
        """Test ETA calculation in MilestoneModeFormatter."""
        formatter = MilestoneModeFormatter(base_path=self.base_path)
        
        # Should calculate ETA from project state
        data = formatter._calculate_milestone_data()
        
        # ETA should be calculated, not placeholder
        self.assertNotEqual(data.eta_remaining, "0.0h")
        self.assertIn("h", data.eta_remaining)  # Should have hours unit
    
    def test_eta_warning_levels(self):
        """Test ETA warning level determination."""
        integration = FlowForgeTimeIntegration(base_path=self.base_path)
        
        # Test long ETA (>8 hours)
        milestone_data = integration.get_milestone_time_data(2, 100)  # Very slow progress
        self.assertIn(milestone_data.eta_warning, ['long', 'critical'])
        
        # Test normal ETA
        milestone_data = integration.get_milestone_time_data(20, 24)  # Almost done
        self.assertEqual(milestone_data.eta_warning, 'none')


class TestTrackNameExtraction(unittest.TestCase):
    """Tests for track name extraction from milestone context."""
    
    def setUp(self):
        """Set up test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.base_path = Path(self.temp_dir)
        
        # Create milestone context file
        milestone_context = """
        🎯 Milestone: v2.0-launch [Feature Track]
        Track: Feature Development
        Priority: High
        """
        
        context_file = self.base_path / '.milestone-context'
        with open(context_file, 'w') as f:
            f.write(milestone_context)
        
        # Also create session with milestone info
        (self.base_path / '.flowforge' / 'local').mkdir(parents=True)
        session_data = {
            'milestone': {
                'name': 'v2.0-launch',
                'track': 'Feature Development'
            }
        }
        
        session_file = self.base_path / '.flowforge' / 'local' / 'session.json'
        with open(session_file, 'w') as f:
            json.dump(session_data, f)
    
    def tearDown(self):
        """Clean up temporary directory."""
        import shutil
        shutil.rmtree(self.temp_dir)
    
    def test_track_name_from_milestone_context(self):
        """Test track name extraction from .milestone-context file."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        # Extract track name
        track_name = statusline._extract_track_name()
        
        self.assertEqual(track_name, "Feature Development")
        self.assertNotEqual(track_name, "")
    
    def test_track_name_from_session_file(self):
        """Test track name extraction from session file."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        context = statusline._build_formatting_context(
            model_name="Claude-3-Opus",
            prefer_local=True
        )
        
        milestone_data = statusline.create_milestone_formatter_adapter(context)
        
        # Should have track name from session
        self.assertEqual(milestone_data.track_name, "Feature Development")
    
    def test_track_name_in_formatter_output(self):
        """Test track name appears in formatted output."""
        formatter = MilestoneModeFormatter(base_path=self.base_path)
        
        data = MilestoneStatusLineData(
            milestone_name="v2.0-launch",
            track_name="Feature Development",
            tasks_completed=5,
            tasks_total=12,
            current_session_time="01:23",
            eta_remaining="3.2h",
            git_branch="feature/420",
            model_name="Opus"
        )
        
        formatted = formatter.format(data)
        
        # Track name should appear in output
        self.assertIn("Feature Development", formatted)
        self.assertIn("[Feature Development]", formatted)


class TestIntegrationWithFlowForge(unittest.TestCase):
    """Tests for complete FlowForge integration."""
    
    def setUp(self):
        """Set up complete test environment."""
        self.temp_dir = tempfile.mkdtemp()
        self.base_path = Path(self.temp_dir)
        
        # Create full FlowForge structure
        (self.base_path / '.flowforge' / 'local').mkdir(parents=True)
        (self.base_path / '.flowforge' / 'billing').mkdir(parents=True)
        
        # Create comprehensive session data
        session_start = datetime.now() - timedelta(hours=1, minutes=45)
        session_data = {
            'active': True,
            'current_issue': '420',
            'session_start': session_start.isoformat(),
            'planned_time': '3:00',
            'elapsed_minutes': 105,
            'context_usage': {
                'conversation_tokens': 47500,
                'token_limit': 50000
            },
            'model_name': 'Claude-3-Opus',
            'milestone': {
                'name': 'v2.0-launch',
                'track': 'Feature Development',
                'tasks_completed': 9,
                'tasks_total': 24
            }
        }
        
        session_file = self.base_path / '.flowforge' / 'local' / 'session.json'
        with open(session_file, 'w') as f:
            json.dump(session_data, f)
        
        # Create milestone context
        context_file = self.base_path / '.milestone-context'
        with open(context_file, 'w') as f:
            f.write("Track: Feature Development\n")
    
    def tearDown(self):
        """Clean up temporary directory."""
        import shutil
        shutil.rmtree(self.temp_dir)
    
    def test_complete_statusline_with_all_features(self):
        """Test complete statusline with all TODO features implemented."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        # Generate statusline
        output = statusline.generate_status_line(
            model_name="Claude-3-Opus",
            prefer_local=True
        )
        
        # Verify all components are present and not placeholders
        self.assertIn("01:45", output)  # Elapsed time
        self.assertIn("95.0", output)  # Context usage (95%)
        self.assertIn("Opus", output)  # Model name
        self.assertIn("Feature Development", output)  # Track name
        self.assertNotIn("00:00", output)  # No placeholder times
        self.assertNotIn("0.0h", output)  # Real ETA calculated
        self.assertNotIn("TODO", output)  # No TODO markers
    
    def test_milestone_mode_complete_integration(self):
        """Test milestone mode with all features."""
        formatter = MilestoneModeFormatter(base_path=self.base_path)
        
        # Get full data from integration
        data = formatter._calculate_milestone_data()
        
        # Verify all fields are populated
        self.assertEqual(data.milestone_name, "v2.0-launch")
        self.assertEqual(data.track_name, "Feature Development")
        self.assertEqual(data.tasks_completed, 9)
        self.assertEqual(data.tasks_total, 24)
        self.assertEqual(data.current_session_time, "01:45")
        self.assertNotEqual(data.eta_remaining, "0.0h")
        self.assertEqual(data.model_name, "Claude-3-Opus")
    
    def test_normal_mode_complete_integration(self):
        """Test normal mode with all features."""
        statusline = FlowForgeStatusLine(base_path=self.base_path)
        
        context = statusline._build_formatting_context(
            model_name="Claude-3-Opus",
            prefer_local=True
        )
        
        normal_data = statusline.create_normal_formatter_adapter(context)
        
        # Verify all fields are populated correctly
        self.assertEqual(normal_data.elapsed_time, "01:45")
        self.assertEqual(normal_data.planned_time, "3:00")
        self.assertAlmostEqual(normal_data.context_usage, 95.0, places=1)
        self.assertEqual(normal_data.model_name, "Claude-3-Opus")
        self.assertEqual(normal_data.tasks_completed, 9)
        self.assertEqual(normal_data.tasks_total, 24)


if __name__ == '__main__':
    # Run tests with verbose output
    unittest.main(verbosity=2)