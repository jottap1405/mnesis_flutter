#!/usr/bin/env bash

###############################################################################
# FlowForge Auto-Migration Script
# Automatically migrates changed files to maintain compatibility
# Version: 2.0.0
###############################################################################

set -euo pipefail

# Constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKUP_DIR="$PROJECT_ROOT/.flowforge/backups/auto-migration-$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$HOME/.flowforge/logs/auto-migration.log"

# File to migrate (passed as argument)
FILE_TO_MIGRATE="${1:-}"

# Helper functions
log() {
    local level="$1"
    shift
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$LOG_FILE"
}

backup_file() {
    local file="$1"
    local backup_path="$BACKUP_DIR/$(dirname "$file")"
    
    mkdir -p "$backup_path"
    cp "$file" "$backup_path/"
    log "INFO" "Backed up: $file"
}

# Migration functions for different file types
migrate_json_file() {
    local file="$1"
    
    case "$(basename "$file")" in
        "tasks.json")
            log "INFO" "Migrating tasks.json structure..."
            # Add any new required fields
            python3 -c "
import json
import sys

with open('$file', 'r') as f:
    data = json.load(f)

# Ensure all tasks have required v2.0 fields
if isinstance(data, dict) and 'tasks' in data:
    for task in data['tasks']:
        if 'version' not in task:
            task['version'] = '2.0.0'
        if 'migrated' not in task:
            task['migrated'] = True
        if 'metadata' not in task:
            task['metadata'] = {}

with open('$file', 'w') as f:
    json.dump(data, f, indent=2)
"
            ;;
            
        "current.json")
            log "INFO" "Migrating session file..."
            # Ensure session has v2.0 structure
            python3 -c "
import json
import sys

with open('$file', 'r') as f:
    data = json.load(f)

# Add v2.0 session fields
if 'version' not in data:
    data['version'] = '2.0.0'
if 'daemon' not in data:
    data['daemon'] = {
        'enabled': True,
        'lastCheck': None
    }

with open('$file', 'w') as f:
    json.dump(data, f, indent=2)
"
            ;;
            
        "config.json"|"daemon.json")
            log "INFO" "Validating configuration file..."
            # Validate JSON structure
            python3 -m json.tool "$file" > /dev/null 2>&1 || {
                log "ERROR" "Invalid JSON in $file"
                return 1
            }
            ;;
    esac
}

migrate_command_file() {
    local file="$1"
    
    log "INFO" "Checking command file format: $file"
    
    # Ensure command files have proper header
    if ! grep -q "^# Command:" "$file"; then
        log "INFO" "Adding v2.0 command header to $file"
        
        # Extract command name from path
        local cmd_name=$(basename "$(dirname "$file")")
        local cmd_action=$(basename "$file" .md)
        
        # Create temp file with header
        cat > "$file.tmp" <<EOF
# Command: flowforge:${cmd_name}:${cmd_action}
# Version: 2.0.0
# Description: FlowForge ${cmd_name} ${cmd_action} command

EOF
        cat "$file" >> "$file.tmp"
        mv "$file.tmp" "$file"
    fi
}

# Main migration logic
main() {
    # Create log directory if needed
    mkdir -p "$(dirname "$LOG_FILE")"
    
    if [[ -z "$FILE_TO_MIGRATE" ]]; then
        log "ERROR" "No file specified for migration"
        exit 1
    fi
    
    if [[ ! -f "$PROJECT_ROOT/$FILE_TO_MIGRATE" ]]; then
        log "ERROR" "File not found: $FILE_TO_MIGRATE"
        exit 1
    fi
    
    local full_path="$PROJECT_ROOT/$FILE_TO_MIGRATE"
    
    log "INFO" "Starting auto-migration for: $FILE_TO_MIGRATE"
    
    # Backup original file
    backup_file "$full_path"
    
    # Determine file type and migrate
    case "$FILE_TO_MIGRATE" in
        *.json)
            migrate_json_file "$full_path"
            ;;
        commands/flowforge/*.md)
            migrate_command_file "$full_path"
            ;;
        *)
            log "INFO" "No migration needed for: $FILE_TO_MIGRATE"
            ;;
    esac
    
    log "INFO" "Migration completed for: $FILE_TO_MIGRATE"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi