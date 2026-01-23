#!/usr/bin/env python3
"""
FlowForge Milestone Detector Component

Detects and parses milestone mode configuration from .milestone-context file
and optional .flowforge/worktree.json configuration file.

This component follows FlowForge development standards:
- Rule #3: TDD-driven implementation with comprehensive tests
- Rule #8: Robust error handling for all failure scenarios  
- Rule #24: Modular design under 500 lines
- Rule #26: Complete function documentation
- Rule #32: Secure file handling with validation
- Rule #33: Professional implementation

Author: FlowForge Team
Since: v2.1.0
"""

import json
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, Any, Optional
import logging

# Configure logging for error tracking
logger = logging.getLogger(__name__)


@dataclass
class MilestoneData:
    """
    Data structure representing milestone mode configuration.
    
    Contains all milestone-related information extracted from configuration files.
    
    Attributes:
        name (str): The milestone name (e.g., "v2.0-launch")
        branch (Optional[str]): The milestone base branch
        branch_pattern (str): Pattern for issue branches (e.g., "milestone/{name}/issue/{issue}")
        merge_strategy (Optional[str]): Git merge strategy for milestone branches
        worktree_path (Optional[str]): Path to the worktree directory
        parent_repo (Optional[str]): Path to the parent repository
        created (Optional[str]): ISO timestamp when milestone was created
        created_by (Optional[str]): Username who created the milestone
        purpose (Optional[str]): Human-readable description of milestone purpose
        source (str): Source of milestone data ("context-file" or "worktree-config")
    """
    name: str
    branch_pattern: str
    source: str
    branch: Optional[str] = None
    merge_strategy: Optional[str] = None
    worktree_path: Optional[str] = None
    parent_repo: Optional[str] = None
    created: Optional[str] = None
    created_by: Optional[str] = None
    purpose: Optional[str] = None

    def to_dict(self) -> Dict[str, Any]:
        """
        Convert MilestoneData to dictionary format.
        
        Returns:
            Dict[str, Any]: Dictionary representation of milestone data
        """
        return {
            'name': self.name,
            'branch': self.branch,
            'branch_pattern': self.branch_pattern,
            'merge_strategy': self.merge_strategy,
            'worktree_path': self.worktree_path,
            'parent_repo': self.parent_repo,
            'created': self.created,
            'created_by': self.created_by,
            'purpose': self.purpose,
            'source': self.source
        }

    def __str__(self) -> str:
        """String representation for debugging purposes."""
        return f"MilestoneData(name='{self.name}', source='{self.source}')"


class MilestoneDetector:
    """
    Detects FlowForge milestone mode configuration from file system.
    
    This component checks for .milestone-context file in the current working
    directory to determine if milestone mode is active. If found, it also
    attempts to load extended configuration from .flowforge/worktree.json.
    
    The detector handles all error conditions gracefully, returning None
    when milestone mode is not active or configuration is invalid.
    
    Usage:
        detector = MilestoneDetector()
        milestone_data = detector.detect_milestone_mode()
        if milestone_data:
            print(f"Active milestone: {milestone_data.name}")
        else:
            print("Normal mode - no milestone active")
    """

    # Security constants to prevent resource exhaustion
    MAX_MILESTONE_NAME_LENGTH = 255
    MAX_FILE_SIZE_BYTES = 1024 * 1024  # 1MB limit for config files
    
    def __init__(self, base_path: Optional[Path] = None):
        """
        Initialize MilestoneDetector with optional base path.
        
        Args:
            base_path (Optional[Path]): Directory to search for milestone files.
                                       Defaults to current working directory.
        
        Raises:
            ValueError: If base_path is not a valid directory
        """
        if base_path is None:
            self.base_path = Path.cwd()
        else:
            self.base_path = Path(base_path)
            
        # Validate base path for security
        if not self._is_safe_path(self.base_path):
            logger.warning(f"Unsafe path detected: {self.base_path}")
            self.base_path = Path.cwd()
        
        # Pre-compute file paths for performance
        self._milestone_context_file = self.base_path / ".milestone-context"
        self._worktree_config_file = self.base_path / ".flowforge" / "worktree.json"

    def _is_safe_path(self, path: Path) -> bool:
        """
        Validate path for security to prevent path traversal attacks.
        
        Args:
            path (Path): Path to validate
            
        Returns:
            bool: True if path is safe to use
        """
        try:
            # Convert to absolute path and resolve any symlinks
            abs_path = path.resolve()
            
            # Basic validation - path should exist or be creatable
            if abs_path.exists() and not abs_path.is_dir():
                return False
                
            # Prevent access to system directories
            str_path = str(abs_path).lower()
            dangerous_paths = ['/etc', '/proc', '/sys', '/dev', '/var/log']
            if any(str_path.startswith(danger) for danger in dangerous_paths):
                return False
                
            return True
            
        except (OSError, ValueError):
            return False

    def _read_milestone_context_file(self) -> Optional[str]:
        """
        Read and validate milestone name from .milestone-context file.
        
        Returns:
            Optional[str]: Milestone name if file exists and is valid, None otherwise
            
        Note:
            Handles file system errors gracefully and validates input length
            for security purposes.
        """
        try:
            if not self._milestone_context_file.exists():
                return None
            
            # Security: Check file size before reading
            file_size = self._milestone_context_file.stat().st_size
            if file_size > self.MAX_FILE_SIZE_BYTES:
                logger.warning(f"Milestone context file too large: {file_size} bytes")
                return None
            
            # Read and validate milestone name
            with open(self._milestone_context_file, 'r', encoding='utf-8') as f:
                milestone_name = f.read().strip()
            
            # Validate milestone name
            if not milestone_name:
                return None
                
            # Security: Limit milestone name length
            if len(milestone_name) > self.MAX_MILESTONE_NAME_LENGTH:
                logger.warning(f"Milestone name too long: {len(milestone_name)} chars")
                milestone_name = milestone_name[:self.MAX_MILESTONE_NAME_LENGTH]
            
            # Basic validation - ensure it's not just whitespace
            if not milestone_name or milestone_name.isspace():
                return None
                
            return milestone_name
            
        except (IOError, OSError, UnicodeDecodeError) as e:
            logger.debug(f"Failed to read milestone context file: {e}")
            return None

    def _read_worktree_config_file(self) -> Optional[Dict[str, Any]]:
        """
        Read and parse worktree configuration from .flowforge/worktree.json.
        
        Returns:
            Optional[Dict[str, Any]]: Parsed JSON data if file exists and is valid,
                                     None otherwise
            
        Note:
            Handles JSON parsing errors gracefully and validates file size
            for security purposes.
        """
        try:
            if not self._worktree_config_file.exists():
                return None
            
            # Security: Check file size before reading
            file_size = self._worktree_config_file.stat().st_size
            if file_size > self.MAX_FILE_SIZE_BYTES:
                logger.warning(f"Worktree config file too large: {file_size} bytes")
                return None
            
            # Read and parse JSON
            with open(self._worktree_config_file, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
            
            # Validate that it's a dictionary
            if not isinstance(config_data, dict):
                logger.warning("Worktree config is not a JSON object")
                return None
                
            return config_data
            
        except (IOError, OSError, json.JSONDecodeError, UnicodeDecodeError) as e:
            logger.debug(f"Failed to read worktree config file: {e}")
            return None

    def _create_milestone_data_from_context(self, milestone_name: str) -> MilestoneData:
        """
        Create MilestoneData from milestone name only (minimal configuration).
        
        Args:
            milestone_name (str): The milestone name from .milestone-context file
            
        Returns:
            MilestoneData: Milestone data with generated branch pattern
        """
        return MilestoneData(
            name=milestone_name,
            branch_pattern=f"milestone/{milestone_name}/issue/{{issue}}",
            source="context-file"
        )

    def _create_milestone_data_from_worktree(
        self, 
        milestone_name: str, 
        worktree_config: Dict[str, Any]
    ) -> MilestoneData:
        """
        Create MilestoneData from worktree configuration with full metadata.
        
        Args:
            milestone_name (str): The milestone name (prioritized from context file)
            worktree_config (Dict[str, Any]): Parsed worktree.json data
            
        Returns:
            MilestoneData: Complete milestone data from worktree configuration
            
        Note:
            If worktree_config doesn't contain expected milestone fields,
            falls back to context-file-only mode for consistency.
        """
        # Validate that worktree config has milestone-related fields
        if not any(key in worktree_config for key in ["milestone", "branch", "branch_pattern"]):
            # Invalid schema - fall back to context-file mode
            return self._create_milestone_data_from_context(milestone_name)
            
        return MilestoneData(
            name=milestone_name,
            branch=worktree_config.get("branch"),
            branch_pattern=worktree_config.get(
                "branch_pattern", 
                f"milestone/{milestone_name}/issue/{{issue}}"
            ),
            merge_strategy=worktree_config.get("merge_strategy"),
            worktree_path=worktree_config.get("worktree_path"),
            parent_repo=worktree_config.get("parent_repo"),
            created=worktree_config.get("created"),
            created_by=worktree_config.get("created_by"),
            purpose=worktree_config.get("purpose"),
            source="worktree-config"
        )

    def detect_milestone_mode(self) -> Optional[MilestoneData]:
        """
        Detect milestone mode configuration from file system.
        
        Checks for .milestone-context file to determine if milestone mode is active.
        If found, attempts to load extended configuration from .flowforge/worktree.json
        for complete milestone metadata.
        
        Returns:
            Optional[MilestoneData]: Milestone configuration data if milestone mode
                                   is active, None if in normal mode or on error
        
        Raises:
            None: All exceptions are caught and handled gracefully
            
        Example:
            >>> detector = MilestoneDetector()
            >>> milestone = detector.detect_milestone_mode()
            >>> if milestone:
            ...     print(f"Working on milestone: {milestone.name}")
            ...     print(f"Branch pattern: {milestone.branch_pattern}")
            ... else:
            ...     print("Normal development mode")
        """
        try:
            # Step 1: Check for milestone context file (primary indicator)
            milestone_name = self._read_milestone_context_file()
            if not milestone_name:
                # No milestone context file found - normal mode
                return None
            
            # Step 2: Try to load extended configuration from worktree.json
            worktree_config = self._read_worktree_config_file()
            
            if worktree_config:
                # We have extended configuration - use it with context file name taking priority
                return self._create_milestone_data_from_worktree(milestone_name, worktree_config)
            else:
                # Only context file available - create minimal configuration
                return self._create_milestone_data_from_context(milestone_name)
                
        except Exception as e:
            # Final safety net - log error and return None for normal mode
            logger.error(f"Unexpected error in milestone detection: {e}")
            return None

    def is_milestone_mode_active(self) -> bool:
        """
        Quick check if milestone mode is currently active.
        
        Returns:
            bool: True if milestone mode is active, False otherwise
            
        Note:
            This is a lightweight alternative to detect_milestone_mode()
            when you only need to know if milestone mode is active.
        """
        try:
            return self._milestone_context_file.exists() and bool(
                self._read_milestone_context_file()
            )
        except Exception:
            return False

    def get_milestone_name(self) -> Optional[str]:
        """
        Get just the milestone name without full configuration.
        
        Returns:
            Optional[str]: Milestone name if active, None otherwise
            
        Note:
            Lightweight method for quick milestone name lookup.
        """
        try:
            return self._read_milestone_context_file()
        except Exception:
            return None


def main():
    """
    Command-line interface for milestone detection.
    
    Outputs milestone information in JSON format for integration with
    other FlowForge components.
    """
    import sys
    
    try:
        detector = MilestoneDetector()
        milestone_data = detector.detect_milestone_mode()
        
        if milestone_data:
            # Output milestone data as JSON for integration
            output = {
                'milestone_mode': True,
                'milestone': milestone_data.to_dict()
            }
            print(json.dumps(output, indent=2))
        else:
            # Output normal mode indication
            output = {
                'milestone_mode': False,
                'milestone': None
            }
            print(json.dumps(output, indent=2))
            
    except Exception as e:
        # Error output for debugging
        error_output = {
            'milestone_mode': False,
            'milestone': None,
            'error': str(e)
        }
        print(json.dumps(error_output, indent=2), file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()