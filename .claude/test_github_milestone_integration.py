#!/usr/bin/env python3
"""
Test suite for GitHub milestone integration in statusline.

Tests the fetching of live GitHub milestone data instead of stale local data,
including proper icon display, session timer, and context percentage.

Author: FlowForge Team
Since: 2.1.0
"""

import unittest
from unittest.mock import Mock, patch, MagicMock, call
from pathlib import Path
import json
import subprocess
from datetime import datetime, timedelta

# Import modules to test
from statusline_data_loader import StatusLineDataLoader
from milestone_mode_formatter import MilestoneModeFormatter, MilestoneStatusLineData
from github_milestone_fetcher import GitHubMilestoneFetcher  # To be created


class TestGitHubMilestoneIntegration(unittest.TestCase):
    """Test GitHub milestone data fetching and display."""

    def setUp(self):
        """Set up test fixtures."""
        self.base_path = Path('/tmp/test_project')
        # Create required directories
        self.base_path.mkdir(parents=True, exist_ok=True)
        (self.base_path / '.flowforge').mkdir(exist_ok=True)
        (self.base_path / '.flowforge' / 'local').mkdir(exist_ok=True)

        self.mock_cache = Mock()
        # Mock required cache methods
        self.mock_cache.is_gh_available.return_value = True
        self.mock_cache.get.return_value = None
        self.mock_cache.get_long_term.return_value = None
        self.mock_cache.set.return_value = None
        self.mock_cache.set_long_term.return_value = None

        self.data_loader = StatusLineDataLoader(self.base_path, self.mock_cache)
        self.formatter = MilestoneModeFormatter(base_path=self.base_path)

    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        import time
        if self.base_path.exists():
            # Give a moment for any file handles to close
            time.sleep(0.1)
            try:
                shutil.rmtree(self.base_path)
            except OSError:
                # Force cleanup on second attempt
                import os
                for root, dirs, files in os.walk(self.base_path, topdown=False):
                    for name in files:
                        os.chmod(os.path.join(root, name), 0o777)
                        os.remove(os.path.join(root, name))
                    for name in dirs:
                        os.chmod(os.path.join(root, name), 0o777)
                        os.rmdir(os.path.join(root, name))
                os.rmdir(self.base_path)

    def test_fetch_live_milestone_data_from_github_api(self):
        """Test that milestone data is fetched from GitHub API, not stale local files."""
        # Arrange
        issue_num = "423"
        expected_milestone = "v2.1-statusline-milestone-mode"
        expected_closed = 5
        expected_open = 5
        expected_total = 10

        # Mock the GitHubMilestoneFetcher's get_milestone_progress_data method
        with patch.object(self.data_loader.milestone_fetcher, 'get_milestone_progress_data') as mock_fetch:
            # Return the expected data
            mock_fetch.return_value = (expected_milestone, expected_closed, expected_total, "2h")

            # Act
            milestone_name, tasks_completed, tasks_total, time_remaining = \
                self.data_loader.get_milestone_from_github(issue_num)

            # Assert
            self.assertEqual(milestone_name, expected_milestone)
            self.assertEqual(tasks_completed, expected_closed)
            self.assertEqual(tasks_total, expected_total)

    def test_format_enhanced_includes_clock_icon(self):
        """Test that format_enhanced method includes ⏱️ icon before time."""
        # Arrange
        data = MilestoneStatusLineData(
            milestone_name="v2.1-statusline-milestone-mode",
            tasks_completed=5,
            tasks_total=10,
            eta_remaining="2h 15m",
            git_branch="feature/423-work",
            model_name="Opus 4.1",
            context_usage=85.0,
            timer_active=True
        )

        # Act
        result = self.formatter.format_enhanced(data)

        # Assert
        self.assertIn("⏱️", result)
        # Should be in format: ⏱️ 135m (converted from 2h 15m)
        self.assertIn("⏱️ 135m", result)

    def test_session_elapsed_time_calculation(self):
        """Test that session elapsed time is properly calculated and displayed."""
        # Arrange
        session_start = datetime.now() - timedelta(hours=2, minutes=15)

        with patch('flowforge_time_integration.FlowForgeTimeIntegration') as mock_integration:
            mock_instance = Mock()
            mock_instance.get_session_time_data.return_value = Mock(
                elapsed_time="02:15"
            )
            mock_integration.return_value = mock_instance

            # Act
            session_time = self.formatter._get_current_session_time()

            # Assert
            self.assertEqual(session_time, "02:15")

    def test_context_percentage_display(self):
        """Test that context percentage is properly displayed with 📊 icon."""
        # Arrange
        data = MilestoneStatusLineData(
            milestone_name="v2.1-statusline-milestone-mode",
            tasks_completed=5,
            tasks_total=10,
            eta_remaining="30m",
            git_branch="feature/423-work",
            model_name="Opus 4.1",
            context_usage=85.0,
            timer_active=True
        )

        # Act
        result = self.formatter.format_enhanced(data)

        # Assert
        self.assertIn("📊 85%", result)

    def test_complete_enhanced_format_output(self):
        """Test complete enhanced format matches expected output."""
        # Arrange
        data = MilestoneStatusLineData(
            milestone_name="v2.1-statusline-milestone-mode",
            tasks_completed=5,
            tasks_total=10,
            eta_remaining="2h 15m",  # Will be converted to 135m
            git_branch="feature/423-work",
            model_name="Opus 4.1",
            context_usage=85.0,
            timer_active=True
        )

        # Act
        result = self.formatter.format_enhanced(data)

        # Expected format:
        # [FlowForge] 🎯 v2.1-statusline-milestone-mode (5/10) ⏱️ 135m | 🌿 feature/423-work | 📊 85% | Opus 4.1 | ● Active

        # Assert all components are present
        self.assertIn("[FlowForge]", result)
        self.assertIn("🎯 v2.1-statusline-milestone-mode", result)
        self.assertIn("(5/10)", result)
        self.assertIn("⏱️ 135m", result)
        self.assertIn("🌿 feature/423-work", result)
        self.assertIn("📊 85%", result)
        self.assertIn("Opus 4.1", result)
        self.assertIn("● Active", result)

    def test_milestone_data_uses_github_not_local_files(self):
        """Test that GitHub data takes precedence over local stale data."""
        # Arrange
        issue_num = "423"

        # Set up stale local data
        stale_local_data = {
            "current_milestone": {
                "name": "old-milestone",
                "completed": 3,
                "total": 4
            }
        }

        # Set up fresh GitHub data
        fresh_github_data = ("v2.1-statusline-milestone-mode", 5, 10, "2h")

        with patch.object(self.data_loader, 'load_json_file') as mock_load:
            mock_load.return_value = stale_local_data

            with patch.object(self.data_loader.milestone_fetcher, 'get_milestone_progress_data') as mock_fetch:
                # Return the fresh GitHub data
                mock_fetch.return_value = fresh_github_data

                # Act
                result = self.data_loader.get_milestone_from_github(issue_num)

                # Assert - should use GitHub data, not local
                self.assertEqual(result[0], "v2.1-statusline-milestone-mode")
                self.assertEqual(result[1], 5)  # GitHub closed issues
                self.assertEqual(result[2], 10)  # GitHub total
                self.assertNotEqual(result[1], 3)  # Not local stale data

    def test_github_api_error_fallback_to_cache(self):
        """Test fallback to cache when GitHub API fails."""
        # Arrange
        issue_num = "423"
        cached_data = ("cached-milestone", 4, 8, "1h")

        with patch.object(self.data_loader, 'run_command') as mock_run:
            mock_run.side_effect = subprocess.TimeoutExpired(['gh'], 5)

            with patch.object(self.data_loader.github_cache, 'get_issue_data') as mock_cache:
                mock_cache.return_value = cached_data

                # Act
                result = self.data_loader.get_milestone_from_github(issue_num)

                # Assert - should use cached data
                self.assertEqual(result, cached_data)

    def test_time_format_conversion(self):
        """Test time format conversion from hours to minutes."""
        # Arrange
        test_cases = [
            ("2h 15m", "135m"),
            ("4.5h", "270m"),
            ("30m", "30m"),
            ("1h", "60m"),
            ("0.5h", "30m"),
            ("00:45", "45m"),
            ("2:30", "150m"),
        ]

        for input_time, expected_output in test_cases:
            with self.subTest(input_time=input_time):
                # Act
                result = self.formatter._format_compact_time(input_time)

                # Assert
                self.assertEqual(result, expected_output)

    def test_context_percentage_hidden_when_zero(self):
        """Test that context percentage is hidden when 0."""
        # Arrange
        data = MilestoneStatusLineData(
            milestone_name="test-milestone",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining="30m",
            git_branch="main",
            model_name="Model",
            context_usage=0.0,
            timer_active=True
        )

        # Act
        result = self.formatter.format_enhanced(data)

        # Assert - should not include context when 0
        self.assertNotIn("📊 0%", result)

    def test_timer_status_inactive_display(self):
        """Test timer status shows as inactive when appropriate."""
        # Arrange
        data = MilestoneStatusLineData(
            milestone_name="test-milestone",
            tasks_completed=1,
            tasks_total=2,
            eta_remaining="30m",
            git_branch="main",
            model_name="Model",
            context_usage=50.0,
            timer_active=False
        )

        # Act
        result = self.formatter.format_enhanced(data)

        # Assert
        self.assertIn("○ Inactive", result)
        self.assertNotIn("● Active", result)


class TestGitHubMilestoneFetcher(unittest.TestCase):
    """Test the dedicated GitHub milestone fetcher."""

    def setUp(self):
        """Set up test fixtures."""
        self.base_path = Path('/tmp/test_project')
        # Create required directories
        self.base_path.mkdir(parents=True, exist_ok=True)
        (self.base_path / '.flowforge').mkdir(exist_ok=True)

        self.fetcher = GitHubMilestoneFetcher(self.base_path)

    def tearDown(self):
        """Clean up test fixtures."""
        import shutil
        import time
        if self.base_path.exists():
            # Give a moment for any file handles to close
            time.sleep(0.1)
            try:
                shutil.rmtree(self.base_path)
            except OSError:
                # Force cleanup on second attempt
                import os
                for root, dirs, files in os.walk(self.base_path, topdown=False):
                    for name in files:
                        os.chmod(os.path.join(root, name), 0o777)
                        os.remove(os.path.join(root, name))
                    for name in dirs:
                        os.chmod(os.path.join(root, name), 0o777)
                        os.rmdir(os.path.join(root, name))
                os.rmdir(self.base_path)

    def test_fetch_milestone_details_from_api(self):
        """Test fetching milestone details directly from GitHub API."""
        # This test will be implemented after creating GitHubMilestoneFetcher
        pass

    def test_parse_milestone_issues_count(self):
        """Test parsing closed and open issues from milestone data."""
        # This test will be implemented after creating GitHubMilestoneFetcher
        pass

    def test_calculate_real_progress_from_github(self):
        """Test calculating real progress from GitHub milestone data."""
        # This test will be implemented after creating GitHubMilestoneFetcher
        pass


class TestSessionTimerIntegration(unittest.TestCase):
    """Test session timer calculation and display."""

    def test_session_timer_from_start_time(self):
        """Test calculating elapsed time from session start."""
        # This test will verify proper session time calculation
        pass

    def test_session_timer_format_display(self):
        """Test session timer format in statusline."""
        # This test will verify the timer is displayed correctly
        pass


if __name__ == '__main__':
    unittest.main()