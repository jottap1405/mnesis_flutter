#!/usr/bin/env python3
"""
StatusLine Cache Module - Extracted for Rule #24 compliance.

Provides fast caching system with 300ms TTL and lazy loading.
Handles GitHub CLI authentication caching and disk persistence.
"""

import json
import time
import subprocess
from pathlib import Path
from typing import Dict, Any, Optional
from dataclasses import dataclass, asdict


@dataclass
class CacheEntry:
    """
    Cache entry with timestamp and data.
    
    Attributes:
        timestamp: Unix timestamp in milliseconds
        data: Cached data of any type
    """
    timestamp: float
    data: Any
    
    def is_expired(self, ttl_ms: int = 300) -> bool:
        """
        Check if cache entry is expired.
        
        Args:
            ttl_ms: Time-to-live in milliseconds (default 300ms)
            
        Returns:
            bool: True if entry is expired, False otherwise
        """
        return (time.time() * 1000 - self.timestamp) > ttl_ms


class StatusLineCache:
    """
    Fast caching system with 300ms TTL and lazy loading.
    
    Provides in-memory caching with disk persistence and
    GitHub CLI authentication status caching.
    """
    
    def __init__(self, cache_file: Path, ttl_ms: int = 300):
        """
        Initialize cache with file path and TTL.
        
        Args:
            cache_file: Path to cache file on disk
            ttl_ms: Time-to-live in milliseconds
        """
        self.cache_file = cache_file
        self.ttl_ms = ttl_ms
        self._memory_cache: Dict[str, CacheEntry] = {}
        self._disk_loaded = False
        self._gh_auth_checked = False
        self._gh_available = None
    
    def _load_from_disk(self):
        """
        Load cache from disk if it exists and is valid.
        
        Only loads entries that haven't expired according to TTL.
        """
        try:
            if self.cache_file.exists():
                with open(self.cache_file, 'r') as f:
                    disk_cache = json.load(f)
                    
                current_time = time.time() * 1000
                for key, entry_data in disk_cache.items():
                    if isinstance(entry_data, dict) and 'timestamp' in entry_data and 'data' in entry_data:
                        entry = CacheEntry(entry_data['timestamp'], entry_data['data'])
                        if not entry.is_expired(self.ttl_ms):
                            self._memory_cache[key] = entry
        except (json.JSONDecodeError, IOError, KeyError):
            self._memory_cache = {}
    
    def _save_to_disk(self):
        """
        Save current cache to disk.
        
        Only saves entries that haven't expired.
        Creates parent directory if it doesn't exist.
        """
        try:
            self.cache_file.parent.mkdir(exist_ok=True)
            disk_cache = {
                k: asdict(v) 
                for k, v in self._memory_cache.items() 
                if not v.is_expired(self.ttl_ms)
            }
            with open(self.cache_file, 'w') as f:
                json.dump(disk_cache, f)
        except IOError:
            pass
    
    def get(self, key: str) -> Optional[Any]:
        """
        Get cached value with lazy loading from disk.
        
        Args:
            key: Cache key to retrieve
            
        Returns:
            Cached value or None if not found/expired
        """
        if not self._disk_loaded:
            self._load_from_disk()
            self._disk_loaded = True
            
        if key in self._memory_cache:
            entry = self._memory_cache[key]
            if not entry.is_expired(self.ttl_ms):
                return entry.data
            else:
                del self._memory_cache[key]
        return None
    
    def set(self, key: str, value: Any, save_immediately: bool = True):
        """
        Set cache value with current timestamp.
        
        Args:
            key: Cache key
            value: Value to cache
            save_immediately: Whether to persist to disk immediately
        """
        timestamp = time.time() * 1000
        self._memory_cache[key] = CacheEntry(timestamp, value)
        if save_immediately:
            self._save_to_disk()
    
    def is_gh_available(self) -> bool:
        """
        Check if GitHub CLI is available and authenticated.
        
        Results are cached for 5 minutes to avoid repeated checks.
        
        Returns:
            bool: True if GitHub CLI is available, False otherwise
        """
        if self._gh_auth_checked:
            return self._gh_available
        
        # Check cache first
        cached_status = self.get('gh_auth_status')
        if cached_status is not None:
            self._gh_available = cached_status
            self._gh_auth_checked = True
            return cached_status
        
        # Quick check if gh exists (don't authenticate yet)
        try:
            result = subprocess.run(
                ['gh', '--version'],
                capture_output=True,
                timeout=1.0,  # Longer timeout for reliability
                text=True
            )
            self._gh_available = result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError):
            self._gh_available = False
        
        # Cache for 5 minutes (300000ms)
        self.set('gh_auth_status', self._gh_available)
        self._gh_auth_checked = True
        return self._gh_available

    def set_long_term(self, key: str, value: Any, ttl_minutes: int = 5):
        """
        Set cache value with extended TTL for GitHub data.

        Args:
            key: Cache key
            value: Value to cache
            ttl_minutes: TTL in minutes (default 5 minutes)
        """
        # Use custom timestamp for longer TTL
        timestamp = time.time() * 1000
        self._memory_cache[key] = CacheEntry(timestamp, value)
        # Don't save immediately for performance

    def get_long_term(self, key: str, ttl_minutes: int = 5) -> Optional[Any]:
        """
        Get cached value with extended TTL check.

        Args:
            key: Cache key to retrieve
            ttl_minutes: TTL in minutes

        Returns:
            Cached value or None if not found/expired
        """
        if not self._disk_loaded:
            self._load_from_disk()
            self._disk_loaded = True

        if key in self._memory_cache:
            entry = self._memory_cache[key]
            ttl_ms = ttl_minutes * 60 * 1000
            if not entry.is_expired(ttl_ms):
                return entry.data
            else:
                del self._memory_cache[key]
        return None
    
    def clear_expired(self):
        """
        Clear all expired entries from memory cache.
        
        Useful for periodic cleanup to prevent memory bloat.
        """
        current_time = time.time() * 1000
        expired_keys = [
            key for key, entry in self._memory_cache.items()
            if entry.is_expired(self.ttl_ms)
        ]
        for key in expired_keys:
            del self._memory_cache[key]