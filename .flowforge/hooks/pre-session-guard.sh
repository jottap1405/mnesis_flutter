#!/bin/bash

# Pre-Session Guard Hook
# Validates session data before any session operation
# Prevents PR/Issue confusion and data corruption
# 
# Author: FlowForge Team
# Since: 2.0.0

# Source validation script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Validate task ID if provided
validate_before_session() {
    local task_id="$1"
    
    # Skip if no task ID
    if [ -z "$task_id" ]; then
        return 0
    fi
    
    # Use validation script
    if [ -f "$PROJECT_ROOT/scripts/validate-task-id.sh" ]; then
        if ! "$PROJECT_ROOT/scripts/validate-task-id.sh" "$task_id"; then
            echo "❌ Session start blocked: Invalid task ID"
            echo "Please use a valid GitHub Issue number, not a PR number"
            return 1
        fi
    fi
    
    return 0
}

# Check for session file corruption
check_session_integrity() {
    local session_file="$PROJECT_ROOT/.flowforge/sessions/current.json"
    
    if [ -f "$session_file" ]; then
        # Check if it's valid JSON
        if command -v jq &> /dev/null; then
            if ! jq empty "$session_file" 2>/dev/null; then
                echo "⚠️  Session file corrupted - running recovery..."
                if [ -f "$PROJECT_ROOT/scripts/recover-session.sh" ]; then
                    "$PROJECT_ROOT/scripts/recover-session.sh"
                else
                    # Emergency recovery
                    echo '{}' > "$session_file"
                fi
            fi
        fi
    fi
    
    return 0
}

# Main guard function
pre_session_guard() {
    local task_id="$1"
    
    # Step 1: Check session integrity
    check_session_integrity
    
    # Step 2: Validate task ID
    if ! validate_before_session "$task_id"; then
        return 1
    fi
    
    # Step 3: Check for ghost tasks in current session
    if [ -f "$PROJECT_ROOT/.flowforge/sessions/current.json" ] && command -v jq &> /dev/null; then
        local current_task=$(jq -r '.taskId // empty' "$PROJECT_ROOT/.flowforge/sessions/current.json" 2>/dev/null || true)
        
        if [ -n "$current_task" ]; then
            # Validate current task too
            if ! "$PROJECT_ROOT/scripts/validate-task-id.sh" "$current_task" 2>/dev/null; then
                echo "⚠️  Current session has invalid task ID: $current_task"
                echo "Clearing invalid session..."
                echo '{}' > "$PROJECT_ROOT/.flowforge/sessions/current.json"
            fi
        fi
    fi
    
    return 0
}

# Export for use in other scripts
export -f pre_session_guard
export -f validate_before_session
export -f check_session_integrity

# If sourced directly with argument
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    pre_session_guard "$1"
fi