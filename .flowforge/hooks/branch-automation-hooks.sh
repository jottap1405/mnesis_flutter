#!/bin/bash
# FlowForge Branch Automation Git Hooks
# Issue #206: Context restoration and branch automation
# 
# Integrates with Git hooks to provide automated context preservation,
# conflict prevention, and stash management during branch operations.

set -euo pipefail

# Configuration
HOOKS_DIR="$(dirname "$0")"
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
FLOWFORGE_DIR="$PROJECT_ROOT/.flowforge"
CONFIG_FILE="$FLOWFORGE_DIR/branch-automation.conf"
LOG_FILE="$FLOWFORGE_DIR/logs/branch-automation.log"

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
    else
        # Default configuration
        AUTO_STASH_ENABLED=${AUTO_STASH_ENABLED:-true}
        CONFLICT_PREVENTION_ENABLED=${CONFLICT_PREVENTION_ENABLED:-true}
        CONTEXT_PRESERVATION_ENABLED=${CONTEXT_PRESERVATION_ENABLED:-true}
        SMART_BRANCH_NAMING_ENABLED=${SMART_BRANCH_NAMING_ENABLED:-true}
        AUTO_CLEANUP_ENABLED=${AUTO_CLEANUP_ENABLED:-true}
    fi
}

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    if [ "$level" = "ERROR" ]; then
        echo "❌ $message" >&2
    elif [ "$level" = "WARNING" ]; then
        echo "⚠️  $message" >&2
    elif [ "$level" = "INFO" ] && [ "${VERBOSE:-false}" = "true" ]; then
        echo "ℹ️  $message"
    fi
}

# Pre-checkout hook
# Called before switching branches
pre_checkout_hook() {
    local from_branch="$1"
    local to_branch="$2"
    local checkout_type="$3"  # 0 = file checkout, 1 = branch checkout
    
    # Only process branch checkouts
    if [ "$checkout_type" != "1" ]; then
        return 0
    fi
    
    log_message "INFO" "Pre-checkout: $from_branch -> $to_branch"
    
    # Preserve context before switch
    if [ "$CONTEXT_PRESERVATION_ENABLED" = "true" ]; then
        preserve_context "$from_branch"
    fi
    
    # Auto-stash if needed
    if [ "$AUTO_STASH_ENABLED" = "true" ]; then
        auto_stash_changes "$from_branch" "$to_branch"
    fi
    
    # Check for potential conflicts
    if [ "$CONFLICT_PREVENTION_ENABLED" = "true" ]; then
        check_conflicts "$from_branch" "$to_branch"
    fi
    
    return 0
}

# Post-checkout hook
# Called after switching branches
post_checkout_hook() {
    local from_branch="$1"
    local to_branch="$2"
    local checkout_type="$3"
    
    # Only process branch checkouts
    if [ "$checkout_type" != "1" ]; then
        return 0
    fi
    
    log_message "INFO" "Post-checkout: Now on $to_branch"
    
    # Restore context for new branch
    if [ "$CONTEXT_PRESERVATION_ENABLED" = "true" ]; then
        restore_context "$to_branch"
    fi
    
    # Apply relevant stashes
    if [ "$AUTO_STASH_ENABLED" = "true" ]; then
        apply_branch_stashes "$to_branch"
    fi
    
    # Clean up old data if enabled
    if [ "$AUTO_CLEANUP_ENABLED" = "true" ]; then
        cleanup_old_data
    fi
    
    return 0
}

# Pre-merge hook
# Called before a merge operation
pre_merge_hook() {
    local merge_head="$1"
    
    log_message "INFO" "Pre-merge: Preparing to merge $merge_head"
    
    # Analyze conflicts before merge
    if [ "$CONFLICT_PREVENTION_ENABLED" = "true" ]; then
        if ! analyze_merge_conflicts "$merge_head"; then
            echo "⚠️  Potential conflicts detected!"
            echo "Run 'flowforge:conflict:analyze' for details"
            
            # Ask for confirmation in interactive mode
            if [ -t 0 ]; then
                read -p "Continue with merge? [y/N] " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    log_message "WARNING" "Merge aborted by user"
                    exit 1
                fi
            fi
        fi
    fi
    
    # Create safety backup
    create_merge_backup
    
    return 0
}

# Post-merge hook
# Called after a successful merge
post_merge_hook() {
    local squash_merge="$1"
    
    log_message "INFO" "Post-merge: Merge completed (squash=$squash_merge)"
    
    # Clean up merge backup if successful
    cleanup_merge_backup
    
    # Update context after merge
    if [ "$CONTEXT_PRESERVATION_ENABLED" = "true" ]; then
        update_merged_context
    fi
    
    return 0
}

# Pre-rebase hook
# Called before a rebase operation
pre_rebase_hook() {
    local upstream="$1"
    local branch="${2:-HEAD}"
    
    log_message "INFO" "Pre-rebase: Rebasing $branch onto $upstream"
    
    # Save current state
    if [ "$CONTEXT_PRESERVATION_ENABLED" = "true" ]; then
        save_rebase_context "$branch"
    fi
    
    # Check for conflicts
    if [ "$CONFLICT_PREVENTION_ENABLED" = "true" ]; then
        analyze_rebase_conflicts "$upstream" "$branch"
    fi
    
    return 0
}

# Post-rewrite hook
# Called after commits are rewritten (rebase, amend)
post_rewrite_hook() {
    local command="$1"  # rebase or amend
    
    log_message "INFO" "Post-rewrite: Commits rewritten via $command"
    
    # Update stash references if needed
    update_stash_references
    
    return 0
}

# Helper Functions

preserve_context() {
    local branch="$1"
    
    log_message "INFO" "Preserving context for branch $branch"
    
    # Save open files and positions
    local context_file="$FLOWFORGE_DIR/contexts/$branch.json"
    mkdir -p "$(dirname "$context_file")"
    
    # Create context JSON
    cat > "$context_file" << EOF
{
    "branch": "$branch",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "workingDirectory": "$(pwd)",
    "modifiedFiles": $(git diff --name-only | jq -R . | jq -s .),
    "stagedFiles": $(git diff --cached --name-only | jq -R . | jq -s .),
    "untrackedFiles": $(git ls-files --others --exclude-standard | jq -R . | jq -s .),
    "lastCommit": "$(git rev-parse HEAD)",
    "stashCount": $(git stash list | wc -l)
}
EOF
    
    log_message "INFO" "Context saved to $context_file"
}

restore_context() {
    local branch="$1"
    local context_file="$FLOWFORGE_DIR/contexts/$branch.json"
    
    if [ ! -f "$context_file" ]; then
        log_message "INFO" "No saved context for branch $branch"
        return 0
    fi
    
    log_message "INFO" "Restoring context for branch $branch"
    
    # Parse context file
    local working_dir=$(jq -r '.workingDirectory' "$context_file")
    local last_commit=$(jq -r '.lastCommit' "$context_file")
    
    # Change to saved working directory if different
    if [ "$working_dir" != "$(pwd)" ] && [ -d "$working_dir" ]; then
        cd "$working_dir"
        log_message "INFO" "Restored working directory: $working_dir"
    fi
    
    # Display context information
    echo "📍 Restored context for branch $branch:"
    echo "   Last commit: $(git log -1 --format='%h %s' "$last_commit" 2>/dev/null || echo 'unknown')"
    echo "   Modified files: $(jq -r '.modifiedFiles | length' "$context_file") files"
    echo "   Stashes available: $(jq -r '.stashCount' "$context_file")"
}

auto_stash_changes() {
    local from_branch="$1"
    local to_branch="$2"
    
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        log_message "INFO" "Auto-stashing changes from $from_branch"
        
        local stash_message="[AUTO] Branch switch: $from_branch -> $to_branch at $(date '+%Y-%m-%d %H:%M:%S')"
        
        if git stash push -m "$stash_message"; then
            # Save stash reference for this branch
            local stash_ref=$(git stash list -1 --format="%gd")
            echo "$stash_ref" > "$FLOWFORGE_DIR/stashes/$from_branch.ref"
            
            log_message "INFO" "Changes stashed: $stash_ref"
            echo "✅ Changes auto-stashed (will be restored when returning to $from_branch)"
        else
            log_message "ERROR" "Failed to auto-stash changes"
        fi
    fi
}

apply_branch_stashes() {
    local branch="$1"
    local stash_file="$FLOWFORGE_DIR/stashes/$branch.ref"
    
    if [ ! -f "$stash_file" ]; then
        return 0
    fi
    
    local stash_ref=$(cat "$stash_file")
    
    log_message "INFO" "Checking for stashes to apply for $branch"
    
    # Verify stash still exists
    if git stash list | grep -q "$stash_ref"; then
        echo "📦 Found auto-stashed changes for this branch"
        
        if [ -t 0 ]; then
            read -p "Apply stashed changes? [Y/n] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                log_message "INFO" "Skipped stash application"
                return 0
            fi
        fi
        
        if git stash apply "$stash_ref"; then
            log_message "INFO" "Applied stash $stash_ref"
            echo "✅ Stashed changes restored"
            
            # Remove stash reference file
            rm -f "$stash_file"
            
            # Drop the stash
            git stash drop "$stash_ref"
        else
            log_message "WARNING" "Could not apply stash $stash_ref"
            echo "⚠️  Could not apply stash automatically (conflicts?)"
            echo "   Run: git stash apply $stash_ref"
        fi
    else
        # Stash no longer exists, clean up reference
        rm -f "$stash_file"
    fi
}

check_conflicts() {
    local from_branch="$1"
    local to_branch="$2"
    
    # Find merge base
    local merge_base=$(git merge-base "$from_branch" "$to_branch" 2>/dev/null || echo "")
    
    if [ -z "$merge_base" ]; then
        log_message "WARNING" "No common ancestor between $from_branch and $to_branch"
        return 0
    fi
    
    # Check for files modified in both branches
    local from_files=$(git diff --name-only "$merge_base..$from_branch" 2>/dev/null || echo "")
    local to_files=$(git diff --name-only "$merge_base..$to_branch" 2>/dev/null || echo "")
    
    local conflicts=""
    for file in $from_files; do
        if echo "$to_files" | grep -q "^$file$"; then
            conflicts="$conflicts $file"
        fi
    done
    
    if [ -n "$conflicts" ]; then
        log_message "WARNING" "Potential conflicts detected in:$conflicts"
        echo "⚠️  Potential conflicts in:$conflicts"
    fi
}

analyze_merge_conflicts() {
    local merge_head="$1"
    
    # Use git merge-tree to analyze conflicts without actually merging
    local conflicts=$(git merge-tree $(git merge-base HEAD "$merge_head") HEAD "$merge_head" | grep "<<<<<<< " | wc -l)
    
    if [ "$conflicts" -gt 0 ]; then
        log_message "WARNING" "Detected $conflicts potential conflict regions"
        return 1
    fi
    
    return 0
}

create_merge_backup() {
    local backup_dir="$FLOWFORGE_DIR/merge-backups"
    mkdir -p "$backup_dir"
    
    local timestamp=$(date '+%Y%m%d-%H%M%S')
    local backup_file="$backup_dir/pre-merge-$timestamp.bundle"
    
    # Create bundle of current state
    if git bundle create "$backup_file" HEAD; then
        log_message "INFO" "Created merge backup: $backup_file"
        echo "$backup_file" > "$FLOWFORGE_DIR/.current-merge-backup"
    fi
}

cleanup_merge_backup() {
    local backup_file_ref="$FLOWFORGE_DIR/.current-merge-backup"
    
    if [ -f "$backup_file_ref" ]; then
        local backup_file=$(cat "$backup_file_ref")
        if [ -f "$backup_file" ]; then
            log_message "INFO" "Cleaning up merge backup: $backup_file"
            rm -f "$backup_file"
        fi
        rm -f "$backup_file_ref"
    fi
}

update_merged_context() {
    local current_branch=$(git branch --show-current)
    preserve_context "$current_branch"
}

save_rebase_context() {
    local branch="$1"
    
    # Save current state before rebase
    local rebase_dir="$FLOWFORGE_DIR/rebase-contexts"
    mkdir -p "$rebase_dir"
    
    git rev-parse HEAD > "$rebase_dir/$branch.head"
    git diff > "$rebase_dir/$branch.diff"
    
    log_message "INFO" "Saved rebase context for $branch"
}

analyze_rebase_conflicts() {
    local upstream="$1"
    local branch="$2"
    
    # Count commits to be rebased
    local commit_count=$(git rev-list --count "$upstream..$branch")
    
    if [ "$commit_count" -gt 20 ]; then
        log_message "WARNING" "Large rebase: $commit_count commits"
        echo "⚠️  Large rebase operation: $commit_count commits will be rebased"
    fi
}

update_stash_references() {
    # Stash references might change after rewrite
    log_message "INFO" "Updating stash references after rewrite"
    
    # Re-index stashes
    local stash_dir="$FLOWFORGE_DIR/stashes"
    if [ -d "$stash_dir" ]; then
        for ref_file in "$stash_dir"/*.ref; do
            [ -f "$ref_file" ] || continue
            
            local old_ref=$(cat "$ref_file")
            # Verify stash still exists
            if ! git stash list | grep -q "$old_ref"; then
                log_message "WARNING" "Stash $old_ref no longer valid"
                rm -f "$ref_file"
            fi
        done
    fi
}

cleanup_old_data() {
    # Clean up old context files (older than 30 days)
    find "$FLOWFORGE_DIR/contexts" -type f -mtime +30 -delete 2>/dev/null || true
    
    # Clean up old merge backups (older than 7 days)
    find "$FLOWFORGE_DIR/merge-backups" -type f -mtime +7 -delete 2>/dev/null || true
    
    # Clean up orphaned stash references
    local stash_dir="$FLOWFORGE_DIR/stashes"
    if [ -d "$stash_dir" ]; then
        for ref_file in "$stash_dir"/*.ref; do
            [ -f "$ref_file" ] || continue
            
            local branch=$(basename "$ref_file" .ref)
            # Remove references for non-existent branches
            if ! git show-ref --verify --quiet "refs/heads/$branch"; then
                log_message "INFO" "Removing stash reference for deleted branch: $branch"
                rm -f "$ref_file"
            fi
        done
    fi
    
    log_message "INFO" "Cleanup completed"
}

# Main hook dispatcher
main() {
    local hook_name="${1:-}"
    shift || true
    
    # Load configuration
    load_config
    
    case "$hook_name" in
        pre-checkout)
            pre_checkout_hook "$@"
            ;;
        post-checkout)
            post_checkout_hook "$@"
            ;;
        pre-merge)
            pre_merge_hook "$@"
            ;;
        post-merge)
            post_merge_hook "$@"
            ;;
        pre-rebase)
            pre_rebase_hook "$@"
            ;;
        post-rewrite)
            post_rewrite_hook "$@"
            ;;
        *)
            echo "Usage: $0 {pre-checkout|post-checkout|pre-merge|post-merge|pre-rebase|post-rewrite} [args...]"
            exit 1
            ;;
    esac
}

# Execute main function if not sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi