#!/usr/bin/env python3
"""
Test suite for MilestoneDetector component.
Rule #3: Write tests BEFORE implementation - TDD mandatory.
Rule #25: Comprehensive test coverage with edge cases, failures, and expected usage.
"""

import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock
import os
import sys
from datetime import datetime, timezone

# Add the .claude directory to Python path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

# Import the component we're testing (will be created after tests)
try:
    from milestone_detector import MilestoneDetector, MilestoneData
except ImportError:
    # Skip import during development - tests will fail until implementation exists
    pass


class TestMilestoneDetector(unittest.TestCase):
    """
    Comprehensive test suite for MilestoneDetector component.
    Rule #25: Tests cover expected usage, edge cases, and failure scenarios.
    """

    def setUp(self):
        """Set up test environment with temporary directory."""
        self.temp_dir = tempfile.TemporaryDirectory()
        self.test_path = Path(self.temp_dir.name)
        
        # Create test files
        self.milestone_context_file = self.test_path / ".milestone-context"
        self.worktree_config_file = self.test_path / ".flowforge" / "worktree.json"
        self.worktree_config_file.parent.mkdir(exist_ok=True)

    def tearDown(self):
        """Clean up test environment."""
        self.temp_dir.cleanup()

    def test_create_milestone_detector_with_default_path(self):
        """Test MilestoneDetector creation with default current working directory."""
        detector = MilestoneDetector()
        self.assertIsInstance(detector, MilestoneDetector)
        self.assertEqual(detector.base_path, Path.cwd())

    def test_create_milestone_detector_with_custom_path(self):
        """Test MilestoneDetector creation with custom base path."""
        detector = MilestoneDetector(self.test_path)
        self.assertIsInstance(detector, MilestoneDetector)
        self.assertEqual(detector.base_path, self.test_path)

    def test_detect_milestone_mode_disabled_no_files(self):
        """Test detection when no milestone files exist (normal mode)."""
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Rule #5: Handle gracefully when not in milestone mode
        self.assertIsNone(result)

    def test_detect_milestone_context_file_only(self):
        """Test detection with only .milestone-context file present."""
        # Create simple milestone context file
        milestone_name = "v2.1-statusline-milestone-mode"
        self.milestone_context_file.write_text(milestone_name.strip())
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        self.assertIsNotNone(result)
        self.assertIsInstance(result, MilestoneData)
        self.assertEqual(result.name, milestone_name)
        self.assertEqual(result.branch_pattern, f"milestone/{milestone_name}/issue/{{issue}}")
        self.assertEqual(result.source, "context-file")
        self.assertIsNone(result.worktree_path)
        self.assertIsNone(result.created)
        self.assertIsNone(result.created_by)

    def test_detect_milestone_with_full_worktree_config(self):
        """Test detection with complete .flowforge/worktree.json configuration."""
        # Create milestone context file
        milestone_name = "v2.0-launch"
        self.milestone_context_file.write_text(milestone_name)
        
        # Create comprehensive worktree.json
        worktree_data = {
            "milestone": milestone_name,
            "branch": f"milestone/{milestone_name}",
            "branch_pattern": f"milestone/{milestone_name}/issue/{{issue}}",
            "merge_strategy": "milestone_first",
            "worktree_path": str(self.test_path),
            "parent_repo": "/path/to/parent/repo",
            "created": "2024-01-15T10:30:00Z",
            "created_by": "testuser",
            "purpose": f"Parallel development for {milestone_name} milestone"
        }
        
        with open(self.worktree_config_file, 'w') as f:
            json.dump(worktree_data, f, indent=2)
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        self.assertIsNotNone(result)
        self.assertEqual(result.name, milestone_name)
        self.assertEqual(result.branch, f"milestone/{milestone_name}")
        self.assertEqual(result.branch_pattern, f"milestone/{milestone_name}/issue/{{issue}}")
        self.assertEqual(result.merge_strategy, "milestone_first")
        self.assertEqual(result.worktree_path, str(self.test_path))
        self.assertEqual(result.parent_repo, "/path/to/parent/repo")
        self.assertEqual(result.created, "2024-01-15T10:30:00Z")
        self.assertEqual(result.created_by, "testuser")
        self.assertEqual(result.purpose, f"Parallel development for {milestone_name} milestone")
        self.assertEqual(result.source, "worktree-config")

    def test_detect_milestone_with_multiline_context_file(self):
        """Test detection with .milestone-context file containing extra whitespace."""
        milestone_name = "v3.0-planning"
        # Add extra whitespace and newlines to test trimming
        self.milestone_context_file.write_text(f"\n  {milestone_name}  \n\n")
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        self.assertIsNotNone(result)
        self.assertEqual(result.name, milestone_name)

    def test_detect_milestone_with_empty_context_file(self):
        """Test detection with empty .milestone-context file."""
        self.milestone_context_file.write_text("")
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Empty file should be treated as no milestone mode
        self.assertIsNone(result)

    def test_detect_milestone_with_unicode_characters(self):
        """Edge case: Test detection with Unicode characters in milestone name."""
        milestone_name = "v2.0-测试-milestone"
        self.milestone_context_file.write_text(milestone_name, encoding='utf-8')
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        self.assertIsNotNone(result)
        self.assertEqual(result.name, milestone_name)

    def test_detect_milestone_with_long_name(self):
        """Edge case: Test detection with extremely long milestone name."""
        # Rule #8: Validate input to prevent resource exhaustion
        milestone_name = "a" * 500  # Very long milestone name
        self.milestone_context_file.write_text(milestone_name)
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Should handle long names gracefully (truncate if necessary)
        self.assertIsNotNone(result)
        self.assertTrue(len(result.name) <= 255)  # Reasonable limit

    def test_detect_milestone_context_file_read_permission_error(self):
        """Failure case: Test handling of file permission errors."""
        milestone_name = "permission-test"
        self.milestone_context_file.write_text(milestone_name)
        
        # Make file unreadable (if running as root, this might not work)
        self.milestone_context_file.chmod(0o000)
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Should handle permission errors gracefully
        self.assertIsNone(result)
        
        # Restore permissions for cleanup
        self.milestone_context_file.chmod(0o644)

    def test_detect_milestone_corrupted_worktree_json(self):
        """Failure case: Test handling of corrupted JSON in worktree.json."""
        milestone_name = "json-error-test"
        self.milestone_context_file.write_text(milestone_name)
        
        # Create invalid JSON
        self.worktree_config_file.write_text('{"milestone": "incomplete json"')
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Should fall back to context-file only
        self.assertIsNotNone(result)
        self.assertEqual(result.name, milestone_name)
        self.assertEqual(result.source, "context-file")

    def test_detect_milestone_worktree_json_wrong_schema(self):
        """Failure case: Test handling of worktree.json with wrong schema."""
        milestone_name = "schema-error-test"
        self.milestone_context_file.write_text(milestone_name)
        
        # Create JSON with unexpected structure
        wrong_data = {
            "unexpected_field": "value",
            "not_milestone": "wrong"
        }
        
        with open(self.worktree_config_file, 'w') as f:
            json.dump(wrong_data, f)
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Should fall back to context-file only
        self.assertIsNotNone(result)
        self.assertEqual(result.name, milestone_name)
        self.assertEqual(result.source, "context-file")

    def test_detect_milestone_mismatch_between_files(self):
        """Edge case: Test when context file and worktree.json have different milestone names."""
        context_milestone = "context-milestone"
        worktree_milestone = "worktree-milestone"
        
        self.milestone_context_file.write_text(context_milestone)
        
        worktree_data = {
            "milestone": worktree_milestone,
            "branch": f"milestone/{worktree_milestone}",
            "branch_pattern": f"milestone/{worktree_milestone}/issue/{{issue}}"
        }
        
        with open(self.worktree_config_file, 'w') as f:
            json.dump(worktree_data, f)
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Should prefer context file for milestone name but use worktree config for other data
        self.assertIsNotNone(result)
        self.assertEqual(result.name, context_milestone)
        # But branch info should come from worktree config
        self.assertEqual(result.branch, f"milestone/{worktree_milestone}")

    def test_milestone_data_string_representation(self):
        """Test MilestoneData string representation for debugging."""
        milestone_name = "debug-test"
        self.milestone_context_file.write_text(milestone_name)
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        str_repr = str(result)
        self.assertIn(milestone_name, str_repr)
        self.assertIn("MilestoneData", str_repr)

    def test_milestone_data_dictionary_conversion(self):
        """Test MilestoneData conversion to dictionary format."""
        milestone_name = "dict-test"
        self.milestone_context_file.write_text(milestone_name)
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        data_dict = result.to_dict()
        self.assertIsInstance(data_dict, dict)
        self.assertEqual(data_dict['name'], milestone_name)
        self.assertEqual(data_dict['source'], 'context-file')

    def test_performance_with_large_worktree_json(self):
        """Performance test: Ensure detection is fast even with large JSON files."""
        milestone_name = "performance-test"
        self.milestone_context_file.write_text(milestone_name)
        
        # Create large worktree.json with many fields
        large_data = {
            "milestone": milestone_name,
            "branch": f"milestone/{milestone_name}",
            "branch_pattern": f"milestone/{milestone_name}/issue/{{issue}}",
            "large_metadata": ["item"] * 1000,  # Large list
            "large_text": "x" * 10000  # Large string
        }
        
        with open(self.worktree_config_file, 'w') as f:
            json.dump(large_data, f)
        
        detector = MilestoneDetector(self.test_path)
        
        import time
        start_time = time.time()
        result = detector.detect_milestone_mode()
        elapsed = time.time() - start_time
        
        # Should complete quickly (under 50ms even with large files)
        self.assertLess(elapsed, 0.05)
        self.assertIsNotNone(result)

    @patch('pathlib.Path.exists')
    def test_file_system_errors_handling(self, mock_exists):
        """Test handling of file system errors during detection."""
        # Mock file system errors
        mock_exists.side_effect = OSError("File system error")
        
        detector = MilestoneDetector(self.test_path)
        result = detector.detect_milestone_mode()
        
        # Should handle file system errors gracefully
        self.assertIsNone(result)

    def test_security_path_traversal_prevention(self):
        """Security test: Ensure no path traversal vulnerabilities."""
        # Try to create detector with path traversal attempt
        malicious_path = Path("/tmp/../etc/passwd")
        detector = MilestoneDetector(malicious_path)
        
        # Should not allow access outside intended directory
        result = detector.detect_milestone_mode()
        self.assertIsNone(result)


class TestMilestoneData(unittest.TestCase):
    """Test suite for MilestoneData dataclass."""

    def test_milestone_data_creation_minimal(self):
        """Test MilestoneData creation with minimal required fields."""
        data = MilestoneData(
            name="test-milestone",
            branch_pattern="milestone/test-milestone/issue/{issue}",
            source="test"
        )
        
        self.assertEqual(data.name, "test-milestone")
        self.assertEqual(data.branch_pattern, "milestone/test-milestone/issue/{issue}")
        self.assertEqual(data.source, "test")
        self.assertIsNone(data.branch)
        self.assertIsNone(data.worktree_path)

    def test_milestone_data_creation_complete(self):
        """Test MilestoneData creation with all fields."""
        data = MilestoneData(
            name="complete-milestone",
            branch="milestone/complete-milestone",
            branch_pattern="milestone/complete-milestone/issue/{issue}",
            merge_strategy="milestone_first",
            worktree_path="/path/to/worktree",
            parent_repo="/path/to/parent",
            created="2024-01-15T10:30:00Z",
            created_by="testuser",
            purpose="Test milestone",
            source="worktree-config"
        )
        
        self.assertEqual(data.name, "complete-milestone")
        self.assertEqual(data.branch, "milestone/complete-milestone")
        self.assertEqual(data.merge_strategy, "milestone_first")
        self.assertEqual(data.worktree_path, "/path/to/worktree")
        self.assertEqual(data.created_by, "testuser")

    def test_milestone_data_equality(self):
        """Test MilestoneData equality comparison."""
        data1 = MilestoneData(
            name="same-milestone",
            branch_pattern="milestone/same-milestone/issue/{issue}",
            source="test"
        )
        
        data2 = MilestoneData(
            name="same-milestone",
            branch_pattern="milestone/same-milestone/issue/{issue}",
            source="test"
        )
        
        data3 = MilestoneData(
            name="different-milestone",
            branch_pattern="milestone/different-milestone/issue/{issue}",
            source="test"
        )
        
        self.assertEqual(data1, data2)
        self.assertNotEqual(data1, data3)


if __name__ == '__main__':
    # Rule #25: Comprehensive test execution with coverage reporting
    unittest.main(verbosity=2)