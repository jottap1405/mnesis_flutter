#!/bin/bash

# FlowForge Task Completion Detection Hooks Installer
# 
# This script installs or uninstalls the git hooks for automatic
# task completion detection. It backs up existing hooks and provides
# options for safe installation and removal.
#
# @author FlowForge Team
# @since 2.0.0

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLOWFORGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_SOURCE_DIR="${FLOWFORGE_ROOT}/hooks"
GIT_HOOKS_DIR="${FLOWFORGE_ROOT}/.git/hooks"
BACKUP_DIR="${FLOWFORGE_ROOT}/.flowforge/backups/hooks"
LOG_FILE="${FLOWFORGE_ROOT}/.flowforge/logs/installer.log"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Hooks to install
HOOKS=("post-commit" "pre-push")

# Ensure directories exist
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$BACKUP_DIR"

# Logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Print colored message
print_message() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Print header
print_header() {
    echo
    print_message "$CYAN" "╔════════════════════════════════════════════════════════╗"
    print_message "$CYAN" "║     FlowForge Task Completion Detection Installer     ║"
    print_message "$CYAN" "╚════════════════════════════════════════════════════════╝"
    echo
}

# Check if running in a git repository
check_git_repo() {
    if [ ! -d "$GIT_HOOKS_DIR" ]; then
        print_message "$RED" "❌ Error: Not in a git repository or .git/hooks directory not found"
        print_message "$YELLOW" "Please run this script from the FlowForge project root"
        exit 1
    fi
}

# Backup existing hook
backup_hook() {
    local hook_name="$1"
    local existing_hook="${GIT_HOOKS_DIR}/${hook_name}"
    
    if [ -f "$existing_hook" ]; then
        local backup_name="${hook_name}.backup.$(date +%Y%m%d_%H%M%S)"
        local backup_path="${BACKUP_DIR}/${backup_name}"
        
        cp "$existing_hook" "$backup_path"
        print_message "$YELLOW" "  📁 Backed up existing ${hook_name} to ${backup_path}"
        log_message "INFO" "Backed up ${hook_name} to ${backup_path}"
        return 0
    fi
    return 1
}

# Install a single hook
install_hook() {
    local hook_name="$1"
    local source_file="${HOOKS_SOURCE_DIR}/${hook_name}"
    local target_file="${GIT_HOOKS_DIR}/${hook_name}"
    
    if [ ! -f "$source_file" ]; then
        print_message "$RED" "  ❌ Source hook not found: ${source_file}"
        log_message "ERROR" "Source hook not found: ${source_file}"
        return 1
    fi
    
    # Backup existing hook if present
    backup_hook "$hook_name"
    
    # Copy hook
    cp "$source_file" "$target_file"
    chmod +x "$target_file"
    
    print_message "$GREEN" "  ✅ Installed ${hook_name} hook"
    log_message "INFO" "Installed ${hook_name} hook"
    return 0
}

# Uninstall a single hook
uninstall_hook() {
    local hook_name="$1"
    local hook_file="${GIT_HOOKS_DIR}/${hook_name}"
    
    if [ -f "$hook_file" ]; then
        # Check if it's our hook by looking for FlowForge marker
        if grep -q "FlowForge" "$hook_file" 2>/dev/null; then
            # Backup before removing
            backup_hook "$hook_name"
            rm -f "$hook_file"
            print_message "$GREEN" "  ✅ Removed ${hook_name} hook"
            log_message "INFO" "Removed ${hook_name} hook"
            
            # Check for backup to restore
            local latest_backup=$(ls -t "${BACKUP_DIR}/${hook_name}.backup."* 2>/dev/null | grep -v "$(date +%Y%m%d)" | head -1)
            if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
                print_message "$YELLOW" "  📁 Found older backup: $(basename "$latest_backup")"
                read -p "      Restore this backup? (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    cp "$latest_backup" "$hook_file"
                    chmod +x "$hook_file"
                    print_message "$GREEN" "  ✅ Restored previous hook"
                    log_message "INFO" "Restored previous ${hook_name} hook from backup"
                fi
            fi
        else
            print_message "$YELLOW" "  ⚠️  ${hook_name} is not a FlowForge hook, skipping"
            log_message "WARNING" "${hook_name} is not a FlowForge hook"
        fi
    else
        print_message "$YELLOW" "  ℹ️  ${hook_name} hook not installed"
    fi
}

# Check hook status
check_status() {
    print_message "$BLUE" "${BOLD}Hook Installation Status:${NC}"
    echo
    
    local installed_count=0
    local total_count=${#HOOKS[@]}
    
    for hook in "${HOOKS[@]}"; do
        local hook_file="${GIT_HOOKS_DIR}/${hook}"
        if [ -f "$hook_file" ]; then
            if grep -q "FlowForge" "$hook_file" 2>/dev/null; then
                print_message "$GREEN" "  ✅ ${hook}: Installed (FlowForge)"
                ((installed_count++))
            else
                print_message "$YELLOW" "  ⚠️  ${hook}: Different hook installed"
            fi
        else
            print_message "$RED" "  ❌ ${hook}: Not installed"
        fi
    done
    
    echo
    if [ $installed_count -eq $total_count ]; then
        print_message "$GREEN" "All FlowForge detection hooks are installed!"
    elif [ $installed_count -eq 0 ]; then
        print_message "$YELLOW" "No FlowForge detection hooks are installed."
    else
        print_message "$YELLOW" "${installed_count}/${total_count} FlowForge detection hooks are installed."
    fi
}

# Test hooks functionality
test_hooks() {
    print_message "$BLUE" "${BOLD}Testing Hook Functionality:${NC}"
    echo
    
    # Test detection script
    if [ -f "${FLOWFORGE_ROOT}/scripts/detect-completion.js" ]; then
        print_message "$GREEN" "  ✅ Detection script found"
        
        # Try running it with --help
        if node "${FLOWFORGE_ROOT}/scripts/detect-completion.js" --help > /dev/null 2>&1; then
            print_message "$GREEN" "  ✅ Detection script is executable"
        else
            print_message "$RED" "  ❌ Detection script failed to run"
        fi
    else
        print_message "$RED" "  ❌ Detection script not found"
    fi
    
    # Check for required Node.js modules
    if [ -f "${FLOWFORGE_ROOT}/src/core/detection/EnhancedTaskCompletionDetector.js" ]; then
        print_message "$GREEN" "  ✅ EnhancedTaskCompletionDetector found"
    else
        print_message "$RED" "  ❌ EnhancedTaskCompletionDetector not found"
    fi
    
    # Check log directory
    if [ -d "${FLOWFORGE_ROOT}/.flowforge/logs" ]; then
        print_message "$GREEN" "  ✅ Log directory exists"
    else
        print_message "$YELLOW" "  ⚠️  Log directory will be created on first use"
    fi
}

# Show usage
show_usage() {
    print_header
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  install    Install the detection hooks (default)"
    echo "  uninstall  Remove the detection hooks"
    echo "  status     Check installation status"
    echo "  test       Test hook functionality"
    echo "  help       Show this help message"
    echo
    echo "Options:"
    echo "  --force    Force installation without prompts"
    echo "  --backup   Create backups only (no installation)"
    echo
    echo "Examples:"
    echo "  $0 install         # Install hooks with prompts"
    echo "  $0 install --force # Install without confirmation"
    echo "  $0 uninstall       # Remove hooks"
    echo "  $0 status          # Check current status"
    echo
}

# Main installation process
install_all() {
    local force="${1:-false}"
    
    print_message "$BLUE" "${BOLD}Installing FlowForge Detection Hooks${NC}"
    echo
    
    # Check current status
    local existing_hooks=()
    for hook in "${HOOKS[@]}"; do
        if [ -f "${GIT_HOOKS_DIR}/${hook}" ]; then
            existing_hooks+=("$hook")
        fi
    done
    
    if [ ${#existing_hooks[@]} -gt 0 ] && [ "$force" != "true" ]; then
        print_message "$YELLOW" "⚠️  Found existing hooks: ${existing_hooks[*]}"
        print_message "$YELLOW" "These will be backed up before installation."
        echo
        read -p "Continue with installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_message "$YELLOW" "Installation cancelled."
            exit 0
        fi
    fi
    
    # Install each hook
    echo
    local success_count=0
    for hook in "${HOOKS[@]}"; do
        if install_hook "$hook"; then
            ((success_count++))
        fi
    done
    
    echo
    if [ $success_count -eq ${#HOOKS[@]} ]; then
        print_message "$GREEN" "🎉 Successfully installed all detection hooks!"
        print_message "$CYAN" "The hooks will automatically detect task completions from your commits."
        echo
        print_message "$BLUE" "Features enabled:"
        print_message "$BLUE" "  • Automatic task completion detection on commit"
        print_message "$BLUE" "  • Pre-push validation of task status"
        print_message "$BLUE" "  • Background processing (non-blocking)"
        print_message "$BLUE" "  • Comprehensive logging to .flowforge/logs/"
        echo
        print_message "$YELLOW" "💡 Tip: Use 'git commit --no-verify' to skip hooks if needed"
    else
        print_message "$YELLOW" "⚠️  Some hooks failed to install. Check the logs for details."
    fi
    
    log_message "INFO" "Installation completed. Success: ${success_count}/${#HOOKS[@]}"
}

# Main uninstallation process
uninstall_all() {
    print_message "$BLUE" "${BOLD}Uninstalling FlowForge Detection Hooks${NC}"
    echo
    
    read -p "Are you sure you want to uninstall the detection hooks? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_message "$YELLOW" "Uninstallation cancelled."
        exit 0
    fi
    
    echo
    for hook in "${HOOKS[@]}"; do
        uninstall_hook "$hook"
    done
    
    echo
    print_message "$GREEN" "✅ Uninstallation complete!"
    print_message "$CYAN" "Backup files are preserved in: ${BACKUP_DIR}"
    
    log_message "INFO" "Uninstallation completed"
}

# Main script logic
main() {
    local command="${1:-install}"
    local force="false"
    
    # Parse arguments
    for arg in "$@"; do
        case $arg in
            --force)
                force="true"
                ;;
            --backup)
                command="backup"
                ;;
        esac
    done
    
    # Check prerequisites
    check_git_repo
    
    # Execute command
    case "$command" in
        install)
            print_header
            install_all "$force"
            ;;
        uninstall)
            print_header
            uninstall_all
            ;;
        status)
            print_header
            check_status
            ;;
        test)
            print_header
            test_hooks
            ;;
        backup)
            print_header
            print_message "$BLUE" "${BOLD}Creating backups only${NC}"
            echo
            for hook in "${HOOKS[@]}"; do
                if backup_hook "$hook"; then
                    print_message "$GREEN" "  ✅ Backed up ${hook}"
                else
                    print_message "$YELLOW" "  ℹ️  No existing ${hook} to backup"
                fi
            done
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_message "$RED" "Unknown command: $command"
            echo
            show_usage
            exit 1
            ;;
    esac
    
    echo
}

# Run main function
main "$@"