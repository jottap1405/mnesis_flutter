#!/bin/bash
# FlowForge Installation Script v2.0
# Installs FlowForge with agents, unified commands, and enhanced features
# Version: 2.0.0
# Release: Monday Deployment Ready

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Setup logging
LOG_DIR="/tmp/flowforge-install-logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/install-$(date +%Y%m%d_%H%M%S).log"
ERROR_LOG="$LOG_DIR/errors-$(date +%Y%m%d_%H%M%S).log"
TRANSACTION_LOG="$LOG_DIR/transaction-$(date +%Y%m%d_%H%M%S).log"
ROLLBACK_LOG="$LOG_DIR/rollback-$(date +%Y%m%d_%H%M%S).log"
VERIFICATION_LOG="$LOG_DIR/verification-$(date +%Y%m%d_%H%M%S).log"

# Installation tracking
INSTALLED_FILES=()
INSTALLED_DIRS=()
ROLLBACK_REQUIRED=false
INSTALLATION_STATE="NOT_STARTED"
BACKUP_DIR="/tmp/flowforge-backup-$(date +%Y%m%d_%H%M%S)"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Function to log errors
log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$ERROR_LOG" >&2
}

# Function to log transactions
log_transaction() {
    local action="$1"
    local target="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $action: $target" >> "$TRANSACTION_LOG"
    if [ "$action" = "FILE_CREATED" ]; then
        INSTALLED_FILES+=("$target")
    elif [ "$action" = "DIR_CREATED" ]; then
        INSTALLED_DIRS+=("$target")
    fi
}

# Function to log verification
log_verification() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$VERIFICATION_LOG"
}

# Function to print and log
print_log() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
    log "$*"
}

# Trap errors and signals
trap 'handle_error $? $LINENO' ERR
trap 'handle_interrupt' INT TERM

handle_error() {
    local exit_code=$1
    local line_no=$2
    log_error "Script failed with exit code $exit_code at line $line_no"
    log_error "Installation state: $INSTALLATION_STATE"
    log_error "Environment: $(env | grep FLOWFORGE || true)"

    print_log "$RED" "❌ Installation failed! Initiating rollback..."

    # Perform rollback
    if [ "$ROLLBACK_REQUIRED" = true ]; then
        perform_rollback
    fi

    # Create recovery instructions
    create_recovery_instructions "$exit_code" "$line_no"

    print_log "$YELLOW" "📝 Logs saved at:"
    print_log "$YELLOW" "   Log: $LOG_FILE"
    print_log "$YELLOW" "   Errors: $ERROR_LOG"
    print_log "$YELLOW" "   Transaction: $TRANSACTION_LOG"
    if [ -f "$ROLLBACK_LOG" ]; then
        print_log "$YELLOW" "   Rollback: $ROLLBACK_LOG"
    fi
    print_log "$YELLOW" "   Recovery: .flowforge-recovery.md"

    print_log "$BLUE" "💡 Common fixes:"
    print_log "$BLUE" "   - Ensure you have write permissions"
    print_log "$BLUE" "   - Check if git is installed"
    print_log "$BLUE" "   - Verify FlowForge source is complete"
    print_log "$BLUE" "   - Try running with sudo if permission denied"
    print_log "$BLUE" "   - Review recovery instructions in .flowforge-recovery.md"

    exit $exit_code
}

handle_interrupt() {
    log_error "Installation interrupted by user"
    print_log "$YELLOW" "⚠️  Installation interrupted. Performing rollback..."
    if [ "$ROLLBACK_REQUIRED" = true ]; then
        perform_rollback
    fi
    exit 130
}

# Function to find FlowForge root dynamically
find_flowforge_root() {
    local current_dir="$1"

    # Method 1: Check if we're in a FlowForge installation
    if [ -f "$current_dir/package.json" ] && grep -q '"name": "@justcode-cruzalex/flowforge"' "$current_dir/package.json" 2>/dev/null; then
        echo "$current_dir"
        return 0
    fi

    # Method 2: Check parent directories
    local check_dir="$current_dir"
    while [ "$check_dir" != "/" ]; do
        if [ -f "$check_dir/package.json" ] && grep -q '"name": "@justcode-cruzalex/flowforge"' "$check_dir/package.json" 2>/dev/null; then
            echo "$check_dir"
            return 0
        fi
        check_dir="$(dirname "$check_dir")"
    done

    # Method 3: Check node_modules
    if [ -d "$current_dir/node_modules/@justcode-cruzalex/flowforge" ]; then
        echo "$current_dir/node_modules/@justcode-cruzalex/flowforge"
        return 0
    fi

    # Method 4: Global npm installation
    local global_path="$(npm root -g 2>/dev/null)/@justcode-cruzalex/flowforge"
    if [ -d "$global_path" ]; then
        echo "$global_path"
        return 0
    fi

    return 1
}

# Get script directory with error checking
SCRIPT_PATH="${BASH_SOURCE[0]}"
if [ ! -f "$SCRIPT_PATH" ]; then
    log_error "Cannot determine script path"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# Try to find FlowForge root dynamically
if FLOWFORGE_ROOT=$(find_flowforge_root "$SCRIPT_DIR"); then
    log "FlowForge root found: $FLOWFORGE_ROOT"
else
    # Fallback to original method if dynamic resolution fails
    FLOWFORGE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    log "FlowForge root (fallback): $FLOWFORGE_ROOT"
fi

# Function to perform rollback
perform_rollback() {
    print_log "$YELLOW" "🔄 Starting rollback..."
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Rollback initiated" > "$ROLLBACK_LOG"

    local rollback_success=true

    # Remove installed files in reverse order
    for ((i=${#INSTALLED_FILES[@]}-1; i>=0; i--)); do
        local file="${INSTALLED_FILES[$i]}"
        if [ -f "$file" ]; then
            rm -f "$file" 2>/dev/null || {
                log_error "Failed to remove file during rollback: $file"
                rollback_success=false
            }
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Removed file: $file" >> "$ROLLBACK_LOG"
        fi
    done

    # Remove installed directories in reverse order
    for ((i=${#INSTALLED_DIRS[@]}-1; i>=0; i--)); do
        local dir="${INSTALLED_DIRS[$i]}"
        if [ -d "$dir" ]; then
            # Only remove if empty
            rmdir "$dir" 2>/dev/null || {
                log_error "Failed to remove directory during rollback: $dir (may not be empty)"
                rollback_success=false
            }
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Removed directory: $dir" >> "$ROLLBACK_LOG"
        fi
    done

    # Restore backups
    if [ -d "$BACKUP_DIR" ]; then
        for backup in "$BACKUP_DIR"/*; do
            if [ -f "$backup" ]; then
                local original_name=$(basename "$backup" | sed 's/\.[0-9]*$//')
                local original_path="$TARGET_DIR/$original_name"
                cp "$backup" "$original_path" 2>/dev/null || true
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restored: $original_path" >> "$ROLLBACK_LOG"
            fi
        done
        rm -rf "$BACKUP_DIR"
    fi

    # Create rollback manifest
    cat > ".flowforge-rollback.json" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "reason": "Installation failed",
  "filesRemoved": ${#INSTALLED_FILES[@]},
  "directoriesRemoved": ${#INSTALLED_DIRS[@]},
  "rollbackSuccess": $rollback_success,
  "installedPaths": [
$(printf '    "%s"' "${INSTALLED_FILES[@]}" | sed 's/" "/",\n    "/g')
  ]
}
EOF

    if [ "$rollback_success" = true ]; then
        print_log "$GREEN" "✅ Rollback completed successfully"
    else
        print_log "$YELLOW" "⚠️  Rollback completed with warnings (see $ROLLBACK_LOG)"
    fi

    ROLLBACK_REQUIRED=false
}

# Function to create recovery instructions
create_recovery_instructions() {
    local exit_code="$1"
    local line_no="$2"

    cat > ".flowforge-recovery.md" << 'EOF'
# FlowForge Installation Recovery Instructions

## Installation Failed

The FlowForge installation encountered an error and has been rolled back.

### Error Details
EOF

    echo "- Exit Code: $exit_code" >> ".flowforge-recovery.md"
    echo "- Failed at Line: $line_no" >> ".flowforge-recovery.md"
    echo "- Timestamp: $(date)" >> ".flowforge-recovery.md"
    echo "- Installation State: $INSTALLATION_STATE" >> ".flowforge-recovery.md"

    cat >> ".flowforge-recovery.md" << 'EOF'

### Manual Recovery Steps

1. **Check Prerequisites**
   - Ensure git is installed: `git --version`
   - Verify Node.js: `node --version`
   - Check disk space: `df -h .`
   - Verify permissions: `ls -la`

2. **Clean Previous Installation**
   ```bash
   rm -rf .flowforge
   rm -f run_ff_command.sh
   rm -rf commands/flowforge
   ```

3. **Retry Installation**
   ```bash
   # With verbose logging
   bash install-flowforge.sh --verbose

   # Or in dry-run mode first
   bash install-flowforge.sh --dry-run
   ```

4. **Alternative Installation Methods**
   - Use simple mode: `bash install-flowforge.sh --mode=simple`
   - Skip optional components: `bash install-flowforge.sh --skip-optional`
   - Force reinstall: `bash install-flowforge.sh --force`

### Getting Help

- Check logs in `/tmp/flowforge-install-logs/`
- Visit: https://flowforge.dev/docs/troubleshooting
- Contact Support: support@flowforge.dev

### Rollback Information

A rollback has been performed. Check `.flowforge-rollback.json` for details.
EOF

    log "Recovery instructions created: .flowforge-recovery.md"
}

# Start installation
print_log "$BLUE" "🔥 FlowForge Installation System v2.0"
print_log "$BLUE" "📝 Logging to: $LOG_FILE"
echo "================================"

# Begin transaction
log_transaction "BEGIN_TRANSACTION" "$(date)"
INSTALLATION_STATE="STARTED"
ROLLBACK_REQUIRED=true

# Detect where we're installing
TARGET_DIR="$(pwd)"
log "Target directory: $TARGET_DIR"

# Check if we're installing FlowForge on itself
IS_FF_ON_FF=false
if [ "$TARGET_DIR" = "$FLOWFORGE_ROOT" ]; then
    IS_FF_ON_FF=true
    print_log "$YELLOW" "🔧 FF-on-FF Mode: Installing FlowForge on itself"
    log "FF-on-FF mode detected"
fi

# Check for dry run mode
DRY_RUN=false
INSTALLATION_MODE=""
ENFORCEMENT_LEVEL=""
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            print_log "$YELLOW" "🔍 DRY RUN MODE - No changes will be made"
            log "Dry run mode: enabled"
            ;;
        --mode=*)
            INSTALLATION_MODE="${arg#*=}"
            log "Installation mode specified: $INSTALLATION_MODE"
            ;;
        --enforcement=*)
            ENFORCEMENT_LEVEL="${arg#*=}"
            log "Enforcement level specified: $ENFORCEMENT_LEVEL"
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --dry-run           Show what would be installed without making changes"
            echo "  --mode=MODE         Installation mode (simple|standard|complete)"
            echo "  --enforcement=LEVEL Enforcement level (immediate|gradual)"
            echo "  --help              Show this help message"
            exit 0
            ;;
    esac
done

# Validation function with logging
validate_flowforge() {
    print_log "$BLUE" "🔍 Validating FlowForge source..."
    
    local required=(
        ".flowforge/RULES.md"
        "VERSION"
        "hooks/enforce-all-rules.sh"
        "templates/CLAUDE_WORKFLOW.md"
        "scripts/task-time.sh"
        "commands/flowforge"
        "templates/hooks"
        "agents"
        "run_ff_command.sh"
    )
    
    # v2.0 required components
    local v2_components=(
        "scripts/provider-bridge.js"
        "scripts/install-detection-hooks.sh"
        "scripts/migration/md-parser.js"
        "scripts/migration/validator.js"
        "scripts/migrate-md-to-json.sh"
    )
    
    local missing=0
    for item in "${required[@]}"; do
        if [ ! -e "$FLOWFORGE_ROOT/$item" ]; then
            print_log "$RED" "   ❌ Missing: $item"
            log_error "Missing required file: $item"
            ((missing++)) || true
        else
            log "Found required: $item"
        fi
    done
    
    if [ $missing -gt 0 ]; then
        print_log "$RED" "❌ FlowForge source is incomplete!"
        print_log "$YELLOW" "💡 Please ensure FlowForge is properly cloned:"
        print_log "$YELLOW" "   git clone https://github.com/YourOrg/FlowForge.git"
        return 1
    fi
    
    # Check v2.0 components (non-fatal if missing)
    local v2_missing=0
    for item in "${v2_components[@]}"; do
        if [ ! -e "$FLOWFORGE_ROOT/$item" ]; then
            print_log "$YELLOW" "   ⚠️  v2.0 component missing: $item"
            log "Missing v2.0 component: $item"
            ((v2_missing++)) || true
        else
            log "Found v2.0 component: $item"
        fi
    done
    
    if [ $v2_missing -gt 0 ]; then
        print_log "$YELLOW" "⚠️  Some v2.0 components missing (non-critical)"
        print_log "$YELLOW" "   Will install what's available"
    fi
    
    print_log "$GREEN" "✅ FlowForge validation passed"
    return 0
}

# Pre-installation validation
print_log "$BLUE" "🔍 Running pre-installation checks..."

# Function to validate disk space (moved here for proper ordering)
validate_disk_space() {
    local required_mb=${FLOWFORGE_MIN_DISK_SPACE_MB:-50}
    local available_kb=$(df "$TARGET_DIR" 2>/dev/null | awk 'NR==2 {print $4}')
    local available_mb=$((available_kb / 1024))

    if [ "$available_mb" -lt "$required_mb" ]; then
        log_error "Insufficient disk space: ${available_mb}MB available, ${required_mb}MB required"
        return 1
    fi

    log "Disk space check passed: ${available_mb}MB available"
    return 0
}

# Function to validate write permissions (moved here for proper ordering)
validate_permissions() {
    local test_file="$TARGET_DIR/.flowforge-permission-test-$$"

    if ! touch "$test_file" 2>/dev/null; then
        log_error "No write permission in $TARGET_DIR"
        return 1
    fi

    rm -f "$test_file"
    log "Write permission check passed"
    return 0
}

# Check disk space
if ! validate_disk_space; then
    print_log "$RED" "❌ Insufficient disk space"
    exit 1
fi

# Check write permissions
if ! validate_permissions; then
    print_log "$RED" "❌ No write permissions in target directory"
    exit 1
fi

# Validate FlowForge source
validate_flowforge || exit 1

print_log "$GREEN" "✅ Pre-installation checks passed"

# FlowForge ASCII Art
show_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║     ███████╗██╗      ██████╗ ██╗    ██╗                ║"
    echo "║     ██╔════╝██║     ██╔═══██╗██║    ██║                ║"
    echo "║     █████╗  ██║     ██║   ██║██║ █╗ ██║                ║"
    echo "║     ██╔══╝  ██║     ██║   ██║██║███╗██║                ║"
    echo "║     ██║     ███████╗╚██████╔╝╚███╔███╔╝                ║"
    echo "║     ╚═╝     ╚══════╝ ╚═════╝  ╚══╝╚══╝                 ║"
    echo "║                                                          ║"
    echo "║     ███████╗ ██████╗ ██████╗  ██████╗ ███████╗         ║"
    echo "║     ██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝         ║"
    echo "║     █████╗  ██║   ██║██████╔╝██║  ███╗█████╗           ║"
    echo "║     ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝           ║"
    echo "║     ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗         ║"
    echo "║     ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝         ║"
    echo "║                                                          ║"
    echo "║          Developer Productivity Framework                ║"
    echo "║               Version 2.0.0                              ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_banner

# Function to detect project type
detect_project_type() {
    if [ -f "package.json" ]; then
        echo "node"
    elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "composer.json" ]; then
        echo "php"
    else
        echo "general"
    fi
}

# Function to check if project is a git repository
check_git() {
    if [ ! -d ".git" ]; then
        print_log "$YELLOW" "⚠️  Not a git repository. Initializing git..."
        if [ "$DRY_RUN" = false ]; then
            git init || {
                log_error "Failed to initialize git"
                return 1
            }
            print_log "$GREEN" "✅ Git initialized"
        else
            print_log "$BLUE" "[DRY RUN] Would initialize git"
        fi
    else
        print_log "$GREEN" "✅ Git repository detected"
    fi
}

# Functions moved earlier in script for proper ordering

# Function to create directory with error handling and tracking
create_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_log "$BLUE" "   [DRY RUN] Would create: $dir"
        else
            # Find the first existing parent directory in the path
            local check_dir="$dir"
            local existing_parent=""

            while [ -z "$existing_parent" ]; do
                check_dir=$(dirname "$check_dir")
                if [ -d "$check_dir" ]; then
                    existing_parent="$check_dir"
                    break
                fi
                # Prevent infinite loop at root
                if [ "$check_dir" = "/" ] || [ "$check_dir" = "." ]; then
                    existing_parent="$check_dir"
                    break
                fi
            done

            # Check if we have write permission in the first existing parent
            if [ ! -w "$existing_parent" ]; then
                log_error "No write permission in directory: $existing_parent"
                log_error "Cannot create: $dir"

                # Provide helpful guidance for common scenarios
                if [[ "$existing_parent" == "/usr/local/"* ]] || [[ "$existing_parent" == "/usr/lib/"* ]]; then
                    print_log "$YELLOW" "   This appears to be a global npm installation directory."
                    print_log "$YELLOW" "   Please run 'flowforge init' from your project directory instead."
                fi

                return 1
            fi

            mkdir -p "$dir" || {
                log_error "Failed to create directory: $dir"
                return 1
            }
            log "Created directory: $dir"
            log_transaction "DIR_CREATED" "$dir"
        fi
    fi
}

# Function to get file size (cross-platform)
get_file_size() {
    local file="$1"

    # Try macOS stat first
    local size=$(stat -f%z "$file" 2>/dev/null)
    if [ -z "$size" ]; then
        # Fall back to Linux/GNU stat
        size=$(stat -c%s "$file" 2>/dev/null)
    fi

    # If still no size, try wc -c as last resort
    if [ -z "$size" ]; then
        size=$(wc -c < "$file" 2>/dev/null | tr -d ' ')
    fi

    echo "$size"
}

# Function to copy file with error handling and security validation
copy_file() {
    local source="$1"
    local dest="$2"
    local description="$3"

    # Security: Validate source file exists and is readable
    if [ ! -f "$source" ]; then
        log_error "Source file not found: $source"
        return 1
    fi

    if [ ! -r "$source" ]; then
        log_error "Source file is not readable: $source"
        return 1
    fi

    # Security: Check for symlink attacks
    if [ -L "$source" ]; then
        local real_source="$(readlink -f "$source")"
        if [ -z "$real_source" ] || [ ! -f "$real_source" ]; then
            log_error "Invalid symlink source: $source"
            return 1
        fi
        # Security: Prevent directory traversal via symlinks
        if [[ "$real_source" == *".."* ]]; then
            log_error "Potential directory traversal detected in symlink: $source"
            return 1
        fi
    fi

    # Create destination directory
    local dest_dir="$(dirname "$dest")"
    create_directory "$dest_dir"

    if [ "$DRY_RUN" = true ]; then
        print_log "$BLUE" "   [DRY RUN] Would copy: $description"
    else
        # Backup existing file if it exists
        if [ -f "$dest" ]; then
            backup_file "$dest"
        fi

        # Security: Use cp with preserve flag for integrity
        cp -p "$source" "$dest" 2>/dev/null || {
            log_error "Failed to copy $source to $dest"
            # Try to restore backup if copy failed
            restore_backup "$dest"
            return 1
        }

        # Security: Verify file was copied successfully
        if [ ! -f "$dest" ]; then
            log_error "Destination file was not created: $dest"
            restore_backup "$dest"
            return 1
        fi

        # Security: Verify file integrity (size check)
        local source_size="$(get_file_size "$source")"
        local dest_size="$(get_file_size "$dest")"
        if [ "$source_size" != "$dest_size" ]; then
            log_error "File size mismatch after copy: $source ($source_size) != $dest ($dest_size)"
            rm -f "$dest" 2>/dev/null
            restore_backup "$dest"
            return 1
        fi

        log "Copied: $description"
        log_transaction "FILE_CREATED" "$dest"
    fi
}

# Function to backup existing files
backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$file").$(date +%s)"
        cp "$file" "$backup_path" 2>/dev/null || true
        log "Backed up: $file to $backup_path"
    fi
}

# Function to restore backup
restore_backup() {
    local file="$1"
    local backup_path="$BACKUP_DIR/$(basename "$file").*"
    local latest_backup=$(ls -t $backup_path 2>/dev/null | head -n1)

    if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
        cp "$latest_backup" "$file" 2>/dev/null || true
        log "Restored backup: $file from $latest_backup"
    fi
}

# Function to create FlowForge directory structure
create_flowforge_structure() {
    print_log "$BLUE" "\n📁 Creating FlowForge directory structure..."
    
    local dirs=(
        ".flowforge/commands"
        ".flowforge/hooks"  
        ".flowforge/templates"
        ".flowforge/config"
        ".flowforge/docs"
        ".flowforge/scripts"
        ".flowforge/assets"
        ".flowforge/documentation/wisdom"
        ".flowforge/agents"
        ".flowforge/.agent-auth"
        ".flowforge/auth/tokens"
        ".flowforge/logs"
        # v2.0 directories for user-isolated storage
        ".flowforge/users"
        ".flowforge/teams"
        ".flowforge/sessions"
        ".flowforge/aggregated"
        ".flowforge/aggregated/pending"
        ".flowforge/aggregated/failed"
        ".flowforge/aggregated/processed"
        # v2.0 migration support
        ".flowforge/migration"
        ".flowforge/migration/backups"
        ".flowforge/migration/status"
        # v2.0 provider system
        ".flowforge/providers"
        ".flowforge/providers/config"
        ".flowforge/providers/cache"
        # v2.0 detection system
        ".flowforge/detection"
        ".flowforge/detection/logs"
        ".flowforge/detection/cache"
        # v2.0 aggregation system
        ".flowforge/aggregation"
        ".flowforge/aggregation/batches"
        ".flowforge/aggregation/metrics"
        # v2.0 recovery system
        ".flowforge/recovery"
        ".flowforge/recovery/snapshots"
        ".flowforge/recovery/history"
        "commands/flowforge"
        "documentation/api"
        "documentation/architecture"
        "documentation/database"
        "documentation/development"
        "documentation/project"
        "documentation/testing"
        "documentation/2.0/api"
        "documentation/2.0/architecture"
        "documentation/2.0/migration"
        "tests/unit"
        "tests/integration"
        "tests/e2e"
        "ffReports/daily"
        "ffReports/weekly"
        "ffReports/monthly"
        "ffReports/milestones"
        "ffReports/sprints"
        "ffReports/adhoc"
        # v2.0 daemon and service directories
        ".flowforge/daemon"
        ".flowforge/daemon/pid"
        ".flowforge/daemon/logs"
        ".flowforge/services"
        ".flowforge/services/status"
    )

    local created_count=0
    local failed_count=0

    for dir in "${dirs[@]}"; do
        if create_directory "$dir"; then
            ((created_count++))
        else
            ((failed_count++))
            log_error "Failed to create: $dir"
        fi
    done

    if [ $failed_count -gt 0 ]; then
        print_log "$YELLOW" "⚠️  Directory structure partially created ($created_count succeeded, $failed_count failed)"
        print_log "$YELLOW" "   Run recovery: bash scripts/hotfix-installation.sh"
        return 1
    else
        print_log "$GREEN" "✅ Directory structure created ($created_count directories)"
    fi
}

# Function to recover from partial installation
recover_partial_installation() {
    print_log "$BLUE" "\n🔧 Checking for partial installation..."

    local missing_dirs=()
    local dirs=(
        ".flowforge/commands"
        ".flowforge/hooks"
        ".flowforge/templates"
        ".flowforge/config"
        ".flowforge/docs"
        ".flowforge/scripts"
        ".flowforge/assets"
        ".flowforge/agents"
        ".flowforge/logs"
        ".flowforge/providers"
        ".flowforge/providers/config"
        ".flowforge/providers/cache"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            missing_dirs+=("$dir")
        fi
    done

    if [ ${#missing_dirs[@]} -gt 0 ]; then
        print_log "$YELLOW" "   Found ${#missing_dirs[@]} missing directories"
        print_log "$BLUE" "   Attempting recovery..."

        for dir in "${missing_dirs[@]}"; do
            if create_directory "$dir"; then
                print_log "$GREEN" "   ✓ Recovered: $dir"
            else
                print_log "$RED" "   ✗ Failed to recover: $dir"
            fi
        done
    else
        print_log "$GREEN" "   No missing directories detected"
    fi
}

# Function to create FlowForge configuration
create_config() {
    local mode="${1:-standard}"
    local enforcement="${2:-immediate}"
    local project_name=$(basename "$PWD")
    local project_type=$(detect_project_type)
    
    print_log "$BLUE" "\n⚙️  Creating FlowForge configuration..."
    
    # Calculate enforcement transition date (30 days from now)
    local transition_date=""
    if [ "$enforcement" = "gradual" ]; then
        transition_date=$(date -u -d "+30 days" +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -v +30d +"%Y-%m-%dT%H:%M:%SZ")
    fi
    
    if [ "$DRY_RUN" = true ]; then
        print_log "$BLUE" "   [DRY RUN] Would create config.json"
    else
        cat > .flowforge/config.json << EOF
{
  "version": "2.0.0",
  "project": {
    "name": "$project_name",
    "type": "$project_type",
    "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "integrationMode": "$mode"
  },
  "enforcement": {
    "level": "$enforcement",
    "startDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "transitionDate": "$transition_date",
    "currentPhase": "initial"
  },
  "rules": {
    "enforceTests": true,
    "requireIssues": true,
    "documentationRequired": true,
    "gitFlow": true,
    "noAIReferences": true
  },
  "automation": {
    "preCommitChecks": true,
    "autoFormat": true,
    "updateDocs": true,
    "timeTracking": true,
    "completionDetection": true,
    "smartAggregation": true
  },
  "standards": {
    "testCoverage": 80,
    "maxFileLength": 500,
    "commitFormat": "conventional"
  },
  "providers": {
    "active": "json",
    "available": ["json", "github", "notion"]
  },
  "v2Features": {
    "userIsolation": true,
    "taskMigration": true,
    "completionDetection": true,
    "smartAggregation": true,
    "providerBridge": true
  }
}
EOF
        log "Created configuration file"
    fi
    
    # Create provider configuration
    if [ "$DRY_RUN" = false ]; then
        cat > .flowforge/providers/config/config.json << EOF
{
  "providers": [
    {
      "name": "json",
      "type": "json",
      "enabled": true,
      "default": true,
      "settings": {
        "filePath": ".flowforge/tasks.json",
        "autoSave": true,
        "saveInterval": 5000
      }
    }
  ]
}
EOF
        log "Created provider configuration"
    fi
    
    # Create daemon configuration  
    if [ "$DRY_RUN" = false ]; then
        cat > .flowforge/daemon/daemon.json << EOF
{
  "services": {
    "aggregation": {
      "enabled": true,
      "interval": 300000,
      "batchSize": 50
    },
    "detection": {
      "enabled": true,
      "interval": 30000,
      "confidenceThreshold": 0.7
    },
    "recovery": {
      "enabled": true,
      "interval": 3600000,
      "maxRetries": 3
    }
  }
}
EOF
        log "Created daemon configuration"
    fi
    
    print_log "$GREEN" "✅ Configuration created"
}

# Function to copy essential files
copy_essential_files() {
    print_log "$BLUE" "\n📋 Copying essential FlowForge files..."
    
    local files_copied=0
    local files_failed=0
    
    # Copy RULES.md (now includes Rule #35 - mandatory agent usage)
    if copy_file "$FLOWFORGE_ROOT/.flowforge/RULES.md" ".flowforge/RULES.md" "FlowForge Rules (35 rules)"; then
        ((files_copied++)) || true
    else
        ((files_failed++)) || true
    fi
    
    # Copy VERSION
    if copy_file "$FLOWFORGE_ROOT/VERSION" ".flowforge/VERSION" "Version file"; then
        ((files_copied++)) || true
    else
        ((files_failed++)) || true
    fi
    
    # Copy CHANGELOG.md
    if copy_file "$FLOWFORGE_ROOT/CHANGELOG.md" ".flowforge/CHANGELOG.md" "Changelog"; then
        ((files_copied++)) || true
    else
        ((files_failed++)) || true
    fi
    
    # Copy assets
    if [ -d "$FLOWFORGE_ROOT/assets" ]; then
        for asset in "$FLOWFORGE_ROOT/assets"/*; do
            if [ -f "$asset" ]; then
                local asset_name=$(basename "$asset")
                if copy_file "$asset" ".flowforge/assets/$asset_name" "Asset: $asset_name"; then
                    ((files_copied++)) || true
                else
                    ((files_failed++)) || true
                fi
            fi
        done
    fi

    # Copy FLOWFORGE_AWARENESS.md to project root (CRITICAL INFECTION FILE)
    if [ -f "$FLOWFORGE_ROOT/FLOWFORGE_AWARENESS.md" ]; then
        if copy_file "$FLOWFORGE_ROOT/FLOWFORGE_AWARENESS.md" "FLOWFORGE_AWARENESS.md" "FlowForge Awareness (CRITICAL)"; then
            ((files_copied++)) || true
            print_log "$GREEN" "   🔥 FlowForge awareness file installed in project root"
        fi
    fi

    # Copy all v2.0 documentation to documentation/ffdocs/
    if [ -d "$FLOWFORGE_ROOT/documentation/2.0" ]; then
        print_log "$BLUE" "   📚 Installing comprehensive v2.0 documentation to documentation/ffdocs/..."
        if [ "$DRY_RUN" = false ]; then
            # Create the documentation/ffdocs directory structure
            mkdir -p documentation/ffdocs

            # Copy all v2.0 documentation to ffdocs
            cp -r "$FLOWFORGE_ROOT/documentation/2.0"/* "documentation/ffdocs/" 2>/dev/null || true

            # Count the files that were copied
            local doc_count=$(find documentation/ffdocs -type f -name "*.md" 2>/dev/null | wc -l)
            if [ "$doc_count" -gt 0 ]; then
                print_log "$GREEN" "   ✓ Successfully installed $doc_count documentation files to documentation/ffdocs/"
                ((files_copied++)) || true
            else
                print_log "$YELLOW" "   ⚠️ No documentation files were copied to documentation/ffdocs/"
            fi
        else
            print_log "$BLUE" "   [DRY RUN] Would copy v2.0 documentation to documentation/ffdocs/"
        fi
    else
        print_log "$YELLOW" "   ⚠️ FlowForge documentation source not found at $FLOWFORGE_ROOT/documentation/2.0"
    fi

    print_log "$GREEN" "✅ Copied $files_copied essential files"
    if [ $files_failed -gt 0 ]; then
        print_log "$YELLOW" "⚠️  Failed to copy $files_failed files"
    fi
}

# Function to install hooks
install_hooks() {
    print_log "$BLUE" "\n🪝 Installing FlowForge hooks..."
    
    local hooks_installed=0
    
    # Copy FlowForge hooks
    if [ -d "$FLOWFORGE_ROOT/hooks" ]; then
        for hook in "$FLOWFORGE_ROOT/hooks"/*.sh; do
            if [ -f "$hook" ]; then
                local hook_name=$(basename "$hook")
                if copy_file "$hook" ".flowforge/hooks/$hook_name" "Hook: $hook_name"; then
                    if [ "$DRY_RUN" = false ]; then
                        chmod +x ".flowforge/hooks/$hook_name"
                    fi
                    ((hooks_installed++)) || true
                fi
            fi
        done
    fi
    
    # Install Git hooks
    if [ -d "$FLOWFORGE_ROOT/templates/hooks" ]; then
        for hook in "$FLOWFORGE_ROOT/templates/hooks"/*; do
            if [ -f "$hook" ]; then
                local hook_name=$(basename "$hook")
                if copy_file "$hook" ".git/hooks/$hook_name" "Git hook: $hook_name"; then
                    if [ "$DRY_RUN" = false ]; then
                        chmod +x ".git/hooks/$hook_name"
                    fi
                    ((hooks_installed++)) || true
                fi
            fi
        done
    fi
    
    print_log "$GREEN" "✅ Installed $hooks_installed hooks"
}

# Function to update project .gitignore
update_gitignore() {
    print_log "$BLUE" "\n📝 Updating .gitignore..."
    
    # Ensure .gitignore exists
    if [ ! -f ".gitignore" ] && [ "$DRY_RUN" = false ]; then
        touch .gitignore
        print_log "$YELLOW" "   Created .gitignore"
    fi
    
    # Patterns to add
    local patterns=(
        "# FlowForge"
        ".flowforge/logs/"
        ".flowforge/cache/"
        "TASK_REPORT_*.md"
        "*.flowforge.tmp"
        ".task-times.json"
    )
    
    local added=0
    for pattern in "${patterns[@]}"; do
        if [ "$DRY_RUN" = false ]; then
            if ! grep -qF "$pattern" .gitignore 2>/dev/null; then
                echo "$pattern" >> .gitignore
                ((added++)) || true
            fi
        else
            print_log "$YELLOW" "   Would add: $pattern"
        fi
    done
    
    if [ $added -gt 0 ]; then
        print_log "$GREEN" "✅ Added $added patterns to .gitignore"
    else
        print_log "$GREEN" "✅ .gitignore already up to date"
    fi
}

# Function to install scripts
install_scripts() {
    print_log "$BLUE" "\n🔧 Installing FlowForge scripts..."
    
    local scripts_installed=0
    
    if [ -d "$FLOWFORGE_ROOT/scripts" ]; then
        for script in "$FLOWFORGE_ROOT/scripts"/*.sh "$FLOWFORGE_ROOT/scripts"/*.js; do
            if [ -f "$script" ]; then
                local script_name=$(basename "$script")
                # Skip the enhanced versions and this script itself
                if [[ "$script_name" != *"-enhanced.sh" && "$script_name" != "install-flowforge-enhanced.sh" ]]; then
                    if copy_file "$script" ".flowforge/scripts/$script_name" "Script: $script_name"; then
                        if [ "$DRY_RUN" = false ]; then
                            chmod +x ".flowforge/scripts/$script_name"
                        fi
                        ((scripts_installed++)) || true
                    fi
                fi
            fi
        done
        
        # Install migration scripts
        if [ -d "$FLOWFORGE_ROOT/scripts/migration" ]; then
            create_directory ".flowforge/scripts/migration"
            for script in "$FLOWFORGE_ROOT/scripts/migration"/*.sh "$FLOWFORGE_ROOT/scripts/migration"/*.js; do
                if [ -f "$script" ]; then
                    local script_name=$(basename "$script")
                    if copy_file "$script" ".flowforge/scripts/migration/$script_name" "Migration script: $script_name"; then
                        if [ "$DRY_RUN" = false ]; then
                            chmod +x ".flowforge/scripts/migration/$script_name"
                        fi
                        ((scripts_installed++)) || true
                    fi
                fi
            done
        fi
    fi
    
    # Install provider bridge
    if [ -f "$FLOWFORGE_ROOT/scripts/provider-bridge.js" ]; then
        if copy_file "$FLOWFORGE_ROOT/scripts/provider-bridge.js" ".flowforge/scripts/provider-bridge.js" "Provider Bridge"; then
            if [ "$DRY_RUN" = false ]; then
                chmod +x ".flowforge/scripts/provider-bridge.js"
            fi
            ((scripts_installed++)) || true
        fi
    fi
    
    print_log "$GREEN" "✅ Installed $scripts_installed scripts"
}

# Function to verify Python installation
verify_python() {
    local python_cmd=""

    # Try python3 first
    if command -v python3 &>/dev/null; then
        python_cmd="python3"
    elif command -v python &>/dev/null; then
        # Check if python points to Python 3
        if python --version 2>&1 | grep -q "Python 3"; then
            python_cmd="python"
        fi
    fi

    if [ -z "$python_cmd" ]; then
        print_log "$YELLOW" "   ⚠️  Python 3 not found. Statusline requires Python 3."
        print_log "$YELLOW" "   Please install Python 3 to use statusline features."
        return 1
    fi

    echo "$python_cmd"
    return 0
}

# Function to recover incomplete statusline installation
recover_statusline_installation() {
    print_log "$BLUE" "   🔧 Checking statusline installation..."

    local needs_recovery=false
    local missing_components=0

    # Check for essential statusline files
    local essential_files=(
        ".flowforge/bin/statusline.py"
        ".flowforge/bin/statusline_cache.py"
        ".flowforge/bin/statusline_data_loader.py"
        ".flowforge/bin/statusline_helpers.py"
    )

    for file in "${essential_files[@]}"; do
        if [ ! -f "$file" ]; then
            needs_recovery=true
            ((missing_components++))
        fi
    done

    # Check for core modules directory
    if [ ! -d ".flowforge/bin/core" ] || [ -z "$(ls -A .flowforge/bin/core 2>/dev/null)" ]; then
        needs_recovery=true
        ((missing_components++))
    fi

    if [ "$needs_recovery" = true ]; then
        print_log "$YELLOW" "   ⚠️  Incomplete statusline installation detected ($missing_components missing components)"
        print_log "$BLUE" "   🔄 Attempting automatic recovery..."
        return 1
    fi

    return 0
}

# Function to install statusline
install_statusline() {
    print_log "$BLUE" "\n🎯 Installing FlowForge statusline..."

    # Check Python availability
    local python_cmd=$(verify_python)
    if [ $? -ne 0 ]; then
        print_log "$YELLOW" "   Continuing installation without Python verification"
    else
        print_log "$GREEN" "   ✓ Python verified: $python_cmd"
    fi

    # Check for and recover from incomplete installation
    if ! recover_statusline_installation; then
        print_log "$BLUE" "   Performing full statusline installation..."
    fi

    # Create bin directory
    create_directory ".flowforge/bin"
    create_directory ".flowforge/bin/core"

    # COMPREHENSIVE INSTALLATION - Copy ALL Python modules from templates/statusline/
    if [ -d "$FLOWFORGE_ROOT/templates/statusline" ]; then
        print_log "$BLUE" "   Installing ALL statusline Python modules..."

        local module_count=0

        # Copy all .py files from main statusline directory
        for py_file in "$FLOWFORGE_ROOT/templates/statusline"/*.py; do
            if [ -f "$py_file" ]; then
                local py_name=$(basename "$py_file")
                # Skip test files for production installation
                if [[ "$py_name" != test_* ]]; then
                    if [ "$DRY_RUN" = false ]; then
                        if copy_file "$py_file" ".flowforge/bin/$py_name" "Module: $py_name"; then
                            chmod +x ".flowforge/bin/$py_name" 2>/dev/null || true
                            ((module_count++))
                        fi
                    else
                        print_log "$BLUE" "   [DRY RUN] Would install: $py_name"
                    fi
                fi
            fi
        done

        print_log "$GREEN" "   ✓ Installed $module_count Python modules to .flowforge/bin/"
    else
        print_log "$YELLOW" "   ⚠️  Statusline templates directory not found"
    fi

    # Copy binary files from templates/statusline/bin/
    if [ -d "$FLOWFORGE_ROOT/templates/statusline/bin" ]; then
        print_log "$BLUE" "   Installing statusline binary files..."

        local bin_count=0

        # Copy ALL files from bin directory (including non-Python files)
        for bin_file in "$FLOWFORGE_ROOT/templates/statusline/bin"/*; do
            if [ -f "$bin_file" ]; then
                local bin_name=$(basename "$bin_file")
                if [ "$DRY_RUN" = false ]; then
                    if copy_file "$bin_file" ".flowforge/bin/$bin_name" "Binary: $bin_name"; then
                        chmod +x ".flowforge/bin/$bin_name" 2>/dev/null || true
                        ((bin_count++))
                    fi
                else
                    print_log "$BLUE" "   [DRY RUN] Would install binary: $bin_name"
                fi
            fi
        done

        print_log "$GREEN" "   ✓ Installed $bin_count binary files"
    fi

    # Copy core modules from templates/statusline/core/
    if [ -d "$FLOWFORGE_ROOT/templates/statusline/core" ]; then
        print_log "$BLUE" "   Installing statusline core modules..."

        local core_count=0

        # Copy ALL Python files from core directory
        for core_file in "$FLOWFORGE_ROOT/templates/statusline/core"/*.py; do
            if [ -f "$core_file" ]; then
                local core_name=$(basename "$core_file")
                # Skip test files and demo files
                if [[ "$core_name" != test_* ]] && [[ "$core_name" != demo_* ]] && [[ "$core_name" != debug_* ]]; then
                    if [ "$DRY_RUN" = false ]; then
                        if copy_file "$core_file" ".flowforge/bin/core/$core_name" "Core: $core_name"; then
                            chmod +x ".flowforge/bin/core/$core_name" 2>/dev/null || true
                            ((core_count++))
                        fi
                    else
                        print_log "$BLUE" "   [DRY RUN] Would install core: $core_name"
                    fi
                fi
            fi
        done

        print_log "$GREEN" "   ✓ Installed $core_count core modules to .flowforge/bin/core/"
    fi

    # Create Python __init__.py files for proper package structure
    if [ "$DRY_RUN" = false ]; then
        print_log "$BLUE" "   Creating Python package structure..."

        # Create __init__.py in bin directory
        cat > ".flowforge/bin/__init__.py" << 'EOF'
"""FlowForge Statusline Package."""
__version__ = "2.0.0"
EOF

        # Create __init__.py in core directory
        cat > ".flowforge/bin/core/__init__.py" << 'EOF'
"""FlowForge Statusline Core Modules."""
from .context_usage_calculator import *
from .flowforge_time_integration import *
from .formatter_utils import *
from .milestone_adapter import *
from .milestone_detector import *
from .milestone_mode_formatter import *
from .normal_mode_formatter import *
from .performance_profiler import *
from .progress_bar_renderer import *
from .status_formatter_interface import *
from .statusline_cache import *
EOF

        print_log "$GREEN" "   ✓ Created Python package structure"
    fi

    # Create executable wrapper if main statusline doesn't exist
    if [ "$DRY_RUN" = false ] && [ ! -f ".flowforge/bin/statusline" ]; then
        print_log "$BLUE" "   Creating statusline executable wrapper..."
        cat > ".flowforge/bin/statusline" << 'EOF'
#!/usr/bin/env bash
# FlowForge Statusline Wrapper
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if command -v python3 &>/dev/null; then
    python3 "$DIR/statusline.py" "$@"
elif command -v python &>/dev/null; then
    python "$DIR/statusline.py" "$@"
else
    echo "Error: Python not found. Please install Python 3."
    exit 1
fi
EOF
        chmod +x ".flowforge/bin/statusline"
        print_log "$GREEN" "   ✓ Created statusline executable wrapper"
    fi

    # Create cache directory for statusline
    if [ "$DRY_RUN" = false ]; then
        mkdir -p .flowforge/.statusline-cache
        # Create initial cache file with proper permissions
        echo "{}" > .flowforge/.statusline-cache.json
        # Security: Set secure permissions (owner read/write, group/others read only)
        chmod 644 .flowforge/.statusline-cache.json 2>/dev/null || true
    fi

    # Test statusline import if Python is available
    if [ "$DRY_RUN" = false ] && [ -n "$python_cmd" ]; then
        print_log "$BLUE" "   Testing statusline module import..."

        # Test basic import
        if $python_cmd -c "import sys; sys.path.insert(0, '.flowforge/bin'); import statusline" 2>/dev/null; then
            print_log "$GREEN" "   ✓ Statusline module imports successfully"
        else
            print_log "$YELLOW" "   ⚠️  Statusline module import test failed (non-critical)"
            print_log "$YELLOW" "   Some advanced features may not work until Python dependencies are installed"
        fi
    fi

    # Final verification
    if [ "$DRY_RUN" = false ]; then
        local installed_modules=$(find .flowforge/bin -name "*.py" -type f 2>/dev/null | wc -l)
        local installed_core=$(find .flowforge/bin/core -name "*.py" -type f 2>/dev/null | wc -l)

        print_log "$GREEN" "✅ Statusline installation complete:"
        print_log "$GREEN" "   - Main modules: $installed_modules"
        print_log "$GREEN" "   - Core modules: $installed_core"
        print_log "$GREEN" "   - Package structure: Ready"
    else
        print_log "$GREEN" "✅ Statusline installation complete (DRY RUN)"
    fi
}

# Function to install statusline to .claude directory for Claude Code integration
install_claude_statusline() {
    print_log "$BLUE" "\n🎯 Installing statusline to .claude directory..."

    # Create .claude directory if it doesn't exist
    if [ "$DRY_RUN" = false ]; then
        mkdir -p .claude
    fi

    # Copy ALL statusline Python files to .claude
    if [ -d "$FLOWFORGE_ROOT/templates/statusline" ]; then
        print_log "$BLUE" "   Copying enhanced statusline modules to .claude..."

        local claude_count=0

        # Copy all Python modules from templates/statusline to .claude
        for py_file in "$FLOWFORGE_ROOT/templates/statusline"/*.py; do
            if [ -f "$py_file" ]; then
                local py_name=$(basename "$py_file")
                # Include all files, even test files, for full functionality
                if [ "$DRY_RUN" = false ]; then
                    if copy_file "$py_file" ".claude/$py_name" "Claude statusline: $py_name"; then
                        chmod +x ".claude/$py_name" 2>/dev/null || true
                        ((claude_count++))
                    fi
                else
                    print_log "$BLUE" "   [DRY RUN] Would copy to .claude: $py_name"
                fi
            fi
        done

        # Also copy core modules if they exist
        if [ -d "$FLOWFORGE_ROOT/templates/statusline/core" ]; then
            print_log "$BLUE" "   Copying core modules to .claude..."

            # Note: We're intentionally NOT creating a core subdirectory in .claude
            # All modules go directly into .claude for simpler imports
            for core_file in "$FLOWFORGE_ROOT/templates/statusline/core"/*.py; do
                if [ -f "$core_file" ]; then
                    local core_name=$(basename "$core_file")
                    if [ "$DRY_RUN" = false ]; then
                        # Copy to .claude directly (not .claude/core)
                        if copy_file "$core_file" ".claude/$core_name" "Claude core: $core_name"; then
                            chmod +x ".claude/$core_name" 2>/dev/null || true
                            ((claude_count++))
                        fi
                    else
                        print_log "$BLUE" "   [DRY RUN] Would copy core to .claude: $core_name"
                    fi
                fi
            done
        fi

        print_log "$GREEN" "   ✓ Installed $claude_count modules to .claude/"

        # Create __init__.py for .claude to make it a proper Python package
        if [ "$DRY_RUN" = false ]; then
            cat > ".claude/__init__.py" << 'EOF'
"""FlowForge Claude Code Integration Package."""
__version__ = "2.0.6"

# Import all statusline components for easy access
try:
    from .statusline import *
    from .context_usage_calculator import *
    from .statusline_cache import *
    from .statusline_data_loader import *
    from .statusline_helpers import *
except ImportError:
    # Graceful degradation if some modules are missing
    pass
EOF
            print_log "$GREEN" "   ✓ Created .claude Python package structure"
        fi

        # Create a milestone context file for the statusline
        if [ "$DRY_RUN" = false ]; then
            echo "normal" > .claude/.milestone-context
            print_log "$GREEN" "   ✓ Created milestone context file"
        fi

        # Test the Claude statusline installation
        if [ "$DRY_RUN" = false ]; then
            local python_cmd=$(verify_python)
            if [ -n "$python_cmd" ]; then
                if $python_cmd -c "import sys; sys.path.insert(0, '.'); from claude import statusline" 2>/dev/null; then
                    print_log "$GREEN" "   ✓ Claude statusline module imports successfully"
                else
                    print_log "$YELLOW" "   ⚠️  Claude statusline import test failed (will retry after dependencies)"
                fi
            fi
        fi

        # Initialize data files needed by statusline for proper context calculation
        print_log "$BLUE" "   Initializing statusline data files..."

        # Create initial session.json file if it doesn't exist
        if [ "$DRY_RUN" = false ]; then
            if [ ! -f ".flowforge/session.json" ]; then
                echo '{"active": false, "issue": null, "branch": null}' > .flowforge/session.json
                print_log "$GREEN" "   ✓ Created initial session.json"
            else
                print_log "$CYAN" "   ℹ️  session.json already exists"
            fi
        else
            print_log "$BLUE" "   [DRY RUN] Would create .flowforge/session.json"
        fi

        # Create initial task-times.json if it doesn't exist
        if [ "$DRY_RUN" = false ]; then
            if [ ! -f ".task-times.json" ]; then
                echo '{}' > .task-times.json
                print_log "$GREEN" "   ✓ Created initial task-times.json"
            else
                print_log "$CYAN" "   ℹ️  task-times.json already exists"
            fi
        else
            print_log "$BLUE" "   [DRY RUN] Would create .task-times.json"
        fi

        # Ensure .milestone-context file exists with 'normal' mode
        # (This is already created above but we'll ensure it's correct)
        if [ "$DRY_RUN" = false ]; then
            if [ ! -f ".claude/.milestone-context" ]; then
                echo 'normal' > .claude/.milestone-context
                print_log "$GREEN" "   ✓ Created milestone context file"
            else
                print_log "$CYAN" "   ℹ️  milestone-context already exists"
            fi
        else
            print_log "$BLUE" "   [DRY RUN] Would ensure .claude/.milestone-context exists"
        fi

        print_log "$GREEN" "✅ Claude statusline installation complete"
    else
        print_log "$YELLOW" "   ⚠️  Statusline templates not found in package"
    fi
}

# Function to install FlowForge commands (v2.0 unified structure)
install_flowforge_commands() {
    print_log "$BLUE" "\n📚 Installing FlowForge v2.0 commands..."
    
    local commands_installed=0
    
    # Copy commands to project location (single source of truth)
    if [ -d "$FLOWFORGE_ROOT/commands/flowforge" ]; then
        print_log "$BLUE" "   Installing unified command structure..."
        
        # Create target directories
        if [ "$DRY_RUN" = false ]; then
            mkdir -p commands
            mkdir -p .claude/commands
        fi
        
        # Copy entire flowforge command structure
        if [ "$DRY_RUN" = true ]; then
            print_log "$BLUE" "   [DRY RUN] Would copy flowforge v2.0 commands"
            ((commands_installed++)) || true
        else
            # Security: Validate source directory before copying
            if [ ! -d "$FLOWFORGE_ROOT/commands/flowforge" ]; then
                log_error "Source command directory does not exist"
                return 1
            fi

            # Security: Use cp with preserve and no-dereference for safety
            if cp -rp "$FLOWFORGE_ROOT/commands/flowforge" "commands/" 2>/dev/null; then
                # Count installed commands
                commands_installed=$(find commands/flowforge -name "*.md" -type f | wc -l)
                print_log "$GREEN" "   ✓ Installed $commands_installed v2.0 commands to commands/"
                
                # Now copy and flatten for Claude Code
                print_log "$BLUE" "   Installing commands for Claude Code..."
                local claude_installed=0
                
                # Find all .md files and copy with flowforge: prefix
                while IFS= read -r cmd_file; do
                    # Get relative path from commands/flowforge/
                    local rel_path="${cmd_file#commands/flowforge/}"
                    # Convert path to command name (e.g., session/start.md -> flowforge:session:start.md)
                    local cmd_name="flowforge:${rel_path//\//:}"
                    # Remove .md and add it back to ensure proper naming
                    cmd_name="${cmd_name%.md}.md"
                    
                    # Security: Validate command file before copying
                    if [ -f "$cmd_file" ] && [ -r "$cmd_file" ] && [ ! -L "$cmd_file" ]; then
                        if cp -p "$cmd_file" ".claude/commands/$cmd_name" 2>/dev/null; then
                            ((claude_installed++)) || true
                        fi
                    fi
                done < <(find commands/flowforge -name "*.md" -type f)
                
                print_log "$GREEN" "   ✓ Installed $claude_installed commands for Claude Code"
            else
                print_log "$RED" "   ❌ Failed to copy command structure"
            fi
        fi
    else
        print_log "$RED" "   ❌ FlowForge v2.0 commands not found"
    fi
    
    # Copy the command runner helper
    if [ -f "$FLOWFORGE_ROOT/run_ff_command.sh" ]; then
        if copy_file "$FLOWFORGE_ROOT/run_ff_command.sh" "run_ff_command.sh" "Command runner"; then
            if [ "$DRY_RUN" = false ]; then
                chmod +x run_ff_command.sh
            fi
            print_log "$GREEN" "   ✓ Installed command runner helper"
        fi
    fi
    
    # Clean up old non-namespaced FlowForge commands
    if [ "$DRY_RUN" = false ]; then
        # List of old command names to remove
        local old_commands=(
            "startsession.md" "endday.md" "pause.md" "status.md"
            "tdd.md" "checkrules.md" "setupproject.md" "plan.md"
            "tasks.md" "ffa.md" "create-agent.md" "flowforgeVersion.md"
            "update.md" "enableVersioning.md" "disableVersioning.md"
            "enforcement.md" "addrule.md" "icebox.md" "setup-flowforge.md"
            "postUpdateWizard.md" "read_from_wisdom.md" "update-wisdom-docs.md"
            "StartWorkOnNextProgrammedTask.md"
        )
        
        for old_cmd in "${old_commands[@]}"; do
            if [ -f ".claude/commands/$old_cmd" ]; then
                rm -f ".claude/commands/$old_cmd"
                print_log "$YELLOW" "   Removed old command: $old_cmd"
            fi
        done
    fi
    
    # Copy startsession alias for backwards compatibility
    if [ -f "$FLOWFORGE_ROOT/commands/startsession.md" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_log "$BLUE" "   [DRY RUN] Would add /flowforge:session:start alias"
        else
            # Security: Validate source file exists and is safe
            if [ -f "$FLOWFORGE_ROOT/commands/startsession.md" ] && [ -r "$FLOWFORGE_ROOT/commands/startsession.md" ] && [ ! -L "$FLOWFORGE_ROOT/commands/startsession.md" ]; then
                if cp -p "$FLOWFORGE_ROOT/commands/startsession.md" ".claude/commands/startsession.md" 2>/dev/null; then
                    print_log "$GREEN" "   ✓ Added /flowforge:session:start (legacy /startsession) for backwards compatibility"
                else
                    print_log "$YELLOW" "   ⚠ Could not add legacy startsession command"
                fi
            else
                print_log "$RED" "   ❌ Failed to copy startsession alias"
            fi
        fi
    fi
    
    print_log "$GREEN" "✅ FlowForge v2.0 commands installed"
}

# Function to install FlowForge agents (new in v2.0)
install_flowforge_agents() {
    print_log "$BLUE" "\n🤖 Installing FlowForge agents..."
    
    local agents_installed=0
    
    # Copy agents directory
    if [ -d "$FLOWFORGE_ROOT/agents" ]; then
        print_log "$BLUE" "   Installing agent system..."
        
        # Create target directory for Claude Code agents (v2.0)
        if [ "$DRY_RUN" = false ]; then
            mkdir -p .claude/agents
            # Also maintain .flowforge/agents for backward compatibility
            mkdir -p .flowforge/agents
        fi
        
        # Copy all agents to BOTH locations (v2.0 dual install)
        if [ "$DRY_RUN" = true ]; then
            print_log "$BLUE" "   [DRY RUN] Would copy FlowForge agents to .claude/agents"
        else
            for agent in "$FLOWFORGE_ROOT/agents"/*; do
                if [ -f "$agent" ]; then
                    local agent_name=$(basename "$agent")
                    # Install to .claude/agents (primary location for Claude Code)
                    if copy_file "$agent" ".claude/agents/$agent_name" "Agent: $agent_name"; then
                        ((agents_installed++)) || true
                    fi
                    # Also copy to .flowforge/agents for backward compatibility
                    copy_file "$agent" ".flowforge/agents/$agent_name" "Agent (compat): $agent_name" >/dev/null 2>&1
                fi
            done
        fi
        
        print_log "$GREEN" "   ✓ Installed $agents_installed agents to .claude/agents/"
        
        # Run the comprehensive agent installer
        if [ -f "$FLOWFORGE_ROOT/scripts/install-all-agents.sh" ]; then
            print_log "$BLUE" "   Running comprehensive agent installation..."
            if [ "$DRY_RUN" = true ]; then
                print_log "$BLUE" "   [DRY RUN] Would run agent installer"
            else
                if "$FLOWFORGE_ROOT/scripts/install-all-agents.sh" 2>&1 | tee -a "$LOG_FILE"; then
                    print_log "$GREEN" "   ✓ All agents installed successfully"
                else
                    print_log "$YELLOW" "   ⚠️  Some agents may need manual installation"
                    print_log "$YELLOW" "   Run: ./scripts/install-all-agents.sh after installation"
                fi
            fi
        fi
        
        print_log "$BLUE" "   Available agents:"
        print_log "$BLUE" "     • fft-testing - Test creation and strategy"
        print_log "$BLUE" "     • fft-documentation - Technical documentation"
        print_log "$BLUE" "     • fft-project-manager - Planning and tasks"
        print_log "$BLUE" "     • fft-database - Database design"
        print_log "$BLUE" "     • fft-architecture - System design"
        print_log "$BLUE" "     • fft-api-designer - API contracts"
        print_log "$BLUE" "     • fft-code-reviewer - Code review"
        print_log "$BLUE" "     • fft-devops-agent - DevOps and CI/CD"
        print_log "$BLUE" "     • fft-frontend - Frontend development"
        print_log "$BLUE" "     • fft-github - GitHub integration"
        print_log "$BLUE" "     • fft-performance - Performance optimization"
        print_log "$BLUE" "     • fft-security - Security analysis"
    else
        print_log "$YELLOW" "   ⚠️  Agents directory not found (non-critical)"
    fi
    
    print_log "$GREEN" "✅ Agent system ready (Rule #35 enforced)"
}

# Install Notion MCP (optional)
install_notion_mcp() {
    print_log "$BLUE" "\n🔗 Notion MCP Setup (Optional)..."
    
    if [ -f "$FLOWFORGE_ROOT/scripts/setup-notion-mcp.sh" ]; then
        echo -e "\n${BOLD}${BLUE}Would you like to set up Notion integration via MCP?${NC}"
        echo "This provides seamless Notion database integration for task management."
        read -p "Setup Notion MCP? [y/N]: " setup_notion
        
        if [[ "$setup_notion" =~ ^[Yy]$ ]]; then
            if [ "$DRY_RUN" = true ]; then
                print_log "$BLUE" "   [DRY RUN] Would run Notion MCP setup"
            else
                print_log "$BLUE" "   Starting Notion MCP setup..."
                if "$FLOWFORGE_ROOT/scripts/setup-notion-mcp.sh"; then
                    print_log "$GREEN" "   ✓ Notion MCP configured successfully"
                else
                    print_log "$YELLOW" "   ⚠️  Notion MCP setup incomplete"
                    print_log "$YELLOW" "   You can run it later: ./scripts/setup-notion-mcp.sh"
                fi
            fi
        else
            print_log "$BLUE" "   Skipping Notion MCP setup (can be done later)"
        fi
    fi
}

# Function to setup Claude settings
setup_claude_settings() {
    print_log "$BLUE" "\n🤖 Setting up Claude Code integration..."
    
    if [ "$IS_FF_ON_FF" = true ]; then
        print_log "$YELLOW" "   Skipping Claude settings (FF-on-FF mode)"
        return
    fi
    
    if [ -f "$FLOWFORGE_ROOT/templates/claude/settings.json" ]; then
        if [ "$DRY_RUN" = true ]; then
            print_log "$BLUE" "   [DRY RUN] Would create Claude settings"
        else
            copy_file "$FLOWFORGE_ROOT/templates/claude/settings.json" ".claude/settings.json" "Claude settings"
        fi
    fi
}

# Function to install or update Claude.md
install_claude_md() {
    print_log "$BLUE" "\n🤖 Setting up Claude.md context file..."

    if [ "$DRY_RUN" = true ]; then
        print_log "$BLUE" "   [DRY RUN] Would create/update Claude.md"
        return
    fi

    # Check if Node.js is available for Claude.md installer
    if command -v node &>/dev/null; then
        # Use the Node.js Claude.md installer if available
        if [ -f "$FLOWFORGE_ROOT/lib/claude-md-installer.js" ]; then
            print_log "$BLUE" "   Using advanced Claude.md installer with customer content..."

            # Create enhanced Node.js script with customer content support
            cat > /tmp/install-claude-md.js << 'EOF'
const { ClaudeMdInstaller } = require(process.argv[2]);
const targetDir = process.argv[3];
const projectName = process.argv[4] || 'Project';
const flowforgeRoot = process.argv[5];

const installer = new ClaudeMdInstaller();

// Enhanced installation with customer content and duplication prevention
installer.runInstallationFlow(targetDir, {
    interactive: false,
    mode: 'auto', // Smart detection of create/append/update
    backup: true,
    validate: true,
    restoreOnError: true,
    defaults: {
        projectName: projectName,
        projectType: installer.detectProjectType(targetDir),
        version: '2.0.0',
        flowforgeRoot: flowforgeRoot
    }
}).then(result => {
    if (result.result.success) {
        console.log('SUCCESS:' + result.result.mode);
        if (result.result.backupPath) {
            console.log('BACKUP:' + result.result.backupPath);
        }
        process.exit(0);
    } else {
        console.error('FAILED:' + (result.result.error || 'Unknown error'));
        if (result.result.restoredFromBackup) {
            console.error('RESTORED_FROM_BACKUP');
        }
        process.exit(1);
    }
}).catch(error => {
    console.error('ERROR:' + error.message);
    process.exit(1);
});
EOF

            local project_name=$(basename "$TARGET_DIR")
            local project_type=$(detect_project_type)
            local install_result=$(node /tmp/install-claude-md.js "$FLOWFORGE_ROOT/lib/claude-md-installer.js" "$TARGET_DIR" "$project_name" "$FLOWFORGE_ROOT" 2>&1)

            if echo "$install_result" | grep -q "SUCCESS:"; then
                local mode=$(echo "$install_result" | grep "SUCCESS:" | cut -d':' -f2)
                local backup_info=""
                if echo "$install_result" | grep -q "BACKUP:"; then
                    backup_info=" (backup created)"
                fi
                print_log "$GREEN" "   ✓ Claude.md ${mode} successfully${backup_info}"

                # Validate the installation
                if [ -f "Claude.md" ] || [ -f "CLAUDE.md" ]; then
                    print_log "$GREEN" "   ✓ Claude.md context verified"
                else
                    print_log "$YELLOW" "   ⚠️  Claude.md not found after installation"
                fi
            else
                print_log "$YELLOW" "   ⚠️  Advanced installer failed, using fallback method"
                print_log "$YELLOW" "   Error: $install_result"
                install_claude_md_fallback
            fi

            rm -f /tmp/install-claude-md.js
        else
            print_log "$YELLOW" "   Advanced installer not found, using fallback method"
            install_claude_md_fallback
        fi
    else
        print_log "$YELLOW" "   Node.js not available, using fallback method"
        install_claude_md_fallback
    fi
}

# Fallback function to create Claude.md using bash with customer content
install_claude_md_fallback() {
    local project_name=$(basename "$TARGET_DIR")
    local project_type=$(detect_project_type)
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    print_log "$BLUE" "   Using bash fallback with CUSTOMER_CLAUDE.md content..."

    # Try to load customer content from CUSTOMER_CLAUDE.md
    local customer_content=""
    if [ -f "$FLOWFORGE_ROOT/CUSTOMER_CLAUDE.md" ]; then
        customer_content=$(cat "$FLOWFORGE_ROOT/CUSTOMER_CLAUDE.md")
        print_log "$GREEN" "   ✓ Loaded revolutionary customer Claude.md content"
    else
        print_log "$YELLOW" "   ⚠️  CUSTOMER_CLAUDE.md not found, using minimal fallback"
        # Create minimal fallback content
        customer_content="# FlowForge Development Context

## 🚨 CRITICAL: MANDATORY WORKFLOW - NO EXCEPTIONS!

### ⏰ BEFORE ANY WORK:
1. **RUN SESSION START FIRST**: \`/flowforge:session:start [ticket-id]\`
2. **NEVER SKIP RULES**: Rule #5 (tickets), Rule #18 (branches), Rule #3 (TDD)

## 🤖 MANDATORY AGENT USAGE (Rule #35):
- fft-documentation, fft-testing, fft-project-manager
- fft-database, fft-architecture, fft-api-designer

## 🔧 Commands:
\`\`\`bash
/flowforge:session:start [ticket]  # MUST RUN FIRST!
/flowforge:help                   # Get help
\`\`\`

**TIME = MONEY - Always track your work!**"
    fi

    # Check if Claude.md exists
    if [ -f "Claude.md" ] || [ -f "CLAUDE.md" ]; then
        local claude_file="Claude.md"
        [ -f "CLAUDE.md" ] && claude_file="CLAUDE.md"

        # Check if FlowForge context already exists to prevent duplication
        if grep -q "FLOWFORGE_CONTEXT_START\|FlowForge Development Context" "$claude_file" 2>/dev/null; then
            print_log "$YELLOW" "   ⚠️  FlowForge context already exists in Claude.md"
            print_log "$YELLOW" "   Skipping to prevent duplication (manual update if needed)"
            return
        else
            print_log "$BLUE" "   Appending revolutionary FlowForge context to existing Claude.md..."

            # Create backup with timestamp
            local backup_file="${claude_file}.flowforge-backup.$(date +%s)"
            cp "$claude_file" "$backup_file"
            print_log "$GREEN" "   ✓ Backup created: $backup_file"

            # Append customer content with clear markers
            cat >> "$claude_file" << EOF


<!-- FLOWFORGE_CONTEXT_START -->
<!-- Added by FlowForge installer on $timestamp -->
<!-- Project: $project_name | Type: $project_type -->

$customer_content

<!-- FLOWFORGE_CONTEXT_END -->
EOF
            print_log "$GREEN" "   ✓ Revolutionary FlowForge context appended to Claude.md"
        fi
    else
        print_log "$BLUE" "   Creating new Claude.md with revolutionary FlowForge context..."

        # Create new Claude.md with customer content and project info
        cat > Claude.md << EOF
<!-- FLOWFORGE_CONTEXT_START -->
<!-- Created by FlowForge installer on $timestamp -->
<!-- Project: $project_name | Type: $project_type | Version: 2.0.0 -->

$customer_content

<!-- FLOWFORGE_CONTEXT_END -->
EOF
        print_log "$GREEN" "   ✓ Revolutionary Claude.md created with complete FlowForge context"
    fi

    # Validate the installation
    if [ -f "Claude.md" ] || [ -f "CLAUDE.md" ]; then
        local validation_file="Claude.md"
        [ -f "CLAUDE.md" ] && validation_file="CLAUDE.md"

        # Check for key elements
        local has_session_start=$(grep -c "/flowforge:session:start" "$validation_file" 2>/dev/null || echo 0)
        local has_rules=$(grep -c "Rule #35\|Rule #5\|Rule #3" "$validation_file" 2>/dev/null || echo 0)
        local has_agents=$(grep -c "fft-" "$validation_file" 2>/dev/null || echo 0)

        if [ "$has_session_start" -gt 0 ] && [ "$has_rules" -gt 0 ] && [ "$has_agents" -gt 0 ]; then
            print_log "$GREEN" "   ✓ Claude.md validation passed (critical elements present)"
        else
            print_log "$YELLOW" "   ⚠️  Claude.md validation warning (some elements may be missing)"
            print_log "$YELLOW" "   Session commands: $has_session_start, Rules: $has_rules, Agents: $has_agents"
        fi
    else
        print_log "$RED" "   ❌ Claude.md installation failed - file not found"
    fi
}

# Function to create initial documentation
create_initial_docs() {
    print_log "$BLUE" "\n📝 Creating initial documentation..."

    if [ "$DRY_RUN" = true ]; then
        print_log "$BLUE" "   [DRY RUN] Would create documentation files"
        return
    fi

    # Install or update Claude.md FIRST
    install_claude_md

    # Create initial tasks.json (v2.0 format)
    if [ ! -f ".flowforge/tasks.json" ]; then
        cat > .flowforge/tasks.json << 'EOF'
{
  "version": "2.0.0",
  "tasks": [],
  "metadata": {
    "created": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
    "lastModified": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
    "migratedFrom": null,
    "activeMilestone": null,
    "v2_2_0_implementation_order": [],
    "v2_2_0_completed": [],
    "v2_2_0_phases": {}
  },
  "milestones": [],
  "history": []
}
EOF
        log "Created tasks.json"
    fi
    
    # Create initial sessions/current.json (v2.0 format)
    if [ ! -f ".flowforge/sessions/current.json" ]; then
        cat > .flowforge/sessions/current.json << 'EOF'
{
  "version": "2.0.0",
  "currentSession": null,
  "lastSession": null,
  "sessions": [],
  "metadata": {
    "created": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
    "totalSessions": 0,
    "totalTimeTracked": 0
  }
}
EOF
        log "Created sessions/current.json"
    fi
    
    # Create initial .current-session (v2.0 format)
    if [ ! -f ".flowforge/.current-session" ]; then
        cat > .flowforge/.current-session << 'EOF'
{
  "status": "ready",
  "activeSession": null,
  "lastActivity": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'"
}
EOF
        log "Created .current-session"
    fi
    
    print_log "$GREEN" "✅ Documentation and data files created"
}

# Function to install v2.0 components
install_v2_components() {
    print_log "$BLUE" "\n🆕 Installing v2.0 components..."
    
    local components_installed=0
    
    # Install completion detection hooks
    if [ -f "$FLOWFORGE_ROOT/scripts/install-detection-hooks.sh" ]; then
        print_log "$BLUE" "   Installing completion detection hooks..."
        if [ "$DRY_RUN" = true ]; then
            print_log "$BLUE" "   [DRY RUN] Would install detection hooks"
        else
            if "$FLOWFORGE_ROOT/scripts/install-detection-hooks.sh" install --force >/dev/null 2>&1; then
                print_log "$GREEN" "   ✓ Detection hooks installed"
                ((components_installed++)) || true
            else
                print_log "$YELLOW" "   ⚠️  Detection hooks installation failed (non-critical)"
            fi
        fi
    fi
    
    # Check for MD files that need migration
    local needs_migration=false
    if [ -f ".flowforge/tasks.json" ] || [ -f ".flowforge/sessions/current.json" ] || [ -f ".flowforge/sessions/current.json" ]; then
        needs_migration=true
    fi
    
    if [ "$needs_migration" = true ]; then
        print_log "$YELLOW" "   🔄 MD files detected - migration available"
        if [ -f "$FLOWFORGE_ROOT/scripts/migrate-md-to-json.sh" ]; then
            if [ "$DRY_RUN" = true ]; then
                print_log "$BLUE" "   [DRY RUN] Would offer MD to JSON migration"
            else
                echo -e "\n${BOLD}${BLUE}Would you like to migrate MD files to JSON format?${NC}"
                echo "This will convert .flowforge/tasks.json, .flowforge/sessions/current.json, and .flowforge/sessions/current.json to v2.0 format."
                read -p "Migrate now? [Y/n]: " migrate_choice
                
                if [[ ! "$migrate_choice" =~ ^[Nn]$ ]]; then
                    print_log "$BLUE" "   Running migration..."
                    if "$FLOWFORGE_ROOT/scripts/migrate-md-to-json.sh" --auto >/dev/null 2>&1; then
                        print_log "$GREEN" "   ✓ MD files migrated to JSON"
                        ((components_installed++)) || true
                    else
                        print_log "$YELLOW" "   ⚠️  Migration failed - manual migration may be needed"
                    fi
                else
                    print_log "$YELLOW" "   Migration skipped - run scripts/migrate-md-to-json.sh later"
                fi
            fi
        fi
    fi
    
    # Initialize provider system
    if [ -f "$FLOWFORGE_ROOT/scripts/provider-bridge.js" ]; then
        print_log "$BLUE" "   Initializing provider system..."
        if [ "$DRY_RUN" = true ]; then
            print_log "$BLUE" "   [DRY RUN] Would initialize providers"
        else
            # Test provider bridge
            if node "$FLOWFORGE_ROOT/scripts/provider-bridge.js" get-provider --format=simple >/dev/null 2>&1; then
                print_log "$GREEN" "   ✓ Provider system initialized"
                ((components_installed++)) || true
            else
                print_log "$YELLOW" "   ⚠️  Provider system needs manual setup"
            fi
        fi
    fi
    
    print_log "$GREEN" "✅ Installed $components_installed v2.0 components"
}

# Function to validate v2.0 installation
validate_v2_installation() {
    print_log "$BLUE" "\n🧪 Validating v2.0 installation..."
    
    local validation_passes=0
    local validation_warnings=0
    
    # Check JSON files
    if [ -f ".flowforge/tasks.json" ]; then
        print_log "$GREEN" "   ✓ tasks.json exists"
        ((validation_passes++)) || true
    else
        print_log "$YELLOW" "   ⚠️  tasks.json missing"
        ((validation_warnings++)) || true
    fi
    
    if [ -f ".flowforge/sessions/current.json" ]; then
        print_log "$GREEN" "   ✓ sessions/current.json exists"
        ((validation_passes++)) || true
    else
        print_log "$YELLOW" "   ⚠️  sessions/current.json missing"
        ((validation_warnings++)) || true
    fi
    
    # Check provider bridge
    if [ -f ".flowforge/scripts/provider-bridge.js" ]; then
        print_log "$GREEN" "   ✓ Provider bridge installed"
        ((validation_passes++)) || true
    else
        print_log "$YELLOW" "   ⚠️  Provider bridge missing"
        ((validation_warnings++)) || true
    fi
    
    # Check detection hooks
    if [ -f ".git/hooks/post-commit" ] && grep -q "FlowForge" ".git/hooks/post-commit" 2>/dev/null; then
        print_log "$GREEN" "   ✓ Detection hooks installed"
        ((validation_passes++)) || true
    else
        print_log "$YELLOW" "   ⚠️  Detection hooks not installed"
        ((validation_warnings++)) || true
    fi
    
    # Check v2.0 directories
    if [ -d ".flowforge/users" ] && [ -d ".flowforge/aggregated" ]; then
        print_log "$GREEN" "   ✓ v2.0 directories created"
        ((validation_passes++)) || true
    else
        print_log "$YELLOW" "   ⚠️  Some v2.0 directories missing"
        ((validation_warnings++)) || true
    fi
    
    if [ $validation_warnings -eq 0 ]; then
        print_log "$GREEN" "✅ v2.0 validation: All checks passed!"
    else
        print_log "$YELLOW" "⚠️  v2.0 validation: $validation_passes passed, $validation_warnings warnings"
        print_log "$YELLOW" "   Some features may require manual setup"
    fi
}

# Function to perform post-installation verification
verify_installation() {
    print_log "$BLUE" "\n🧪 Verifying installation..."

    local verification_passed=true
    local components_verified=0
    local components_failed=0

    log_verification "Starting post-installation verification"

    # Critical files to verify
    local critical_files=(
        ".flowforge/config.json"
        ".flowforge/RULES.md"
        "run_ff_command.sh"
        ".flowforge/VERSION"
    )

    for file in "${critical_files[@]}"; do
        if [ -f "$file" ]; then
            log_verification "✓ Found: $file"
            ((components_verified++))
        else
            log_verification "✗ Missing: $file"
            log_error "Critical file missing: $file"
            verification_passed=false
            ((components_failed++))
        fi
    done

    # Critical directories to verify
    local critical_dirs=(
        "commands/flowforge"
        ".flowforge/scripts"
        ".flowforge/config"
        ".flowforge/logs"
    )

    for dir in "${critical_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_verification "✓ Found: $dir"
            ((components_verified++))
        else
            log_verification "✗ Missing: $dir"
            log_error "Critical directory missing: $dir"
            verification_passed=false
            ((components_failed++))
        fi
    done

    # Verify executable permissions
    if [ -f "run_ff_command.sh" ]; then
        if [ -x "run_ff_command.sh" ]; then
            log_verification "✓ run_ff_command.sh is executable"
            ((components_verified++))
        else
            log_verification "✗ run_ff_command.sh is not executable"
            verification_passed=false
            ((components_failed++))
        fi
    fi

    # Create verification report
    cat > ".flowforge/install-verification.json" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "verificationPassed": $verification_passed,
  "componentsVerified": $components_verified,
  "componentsFailed": $components_failed,
  "installationMode": "${INSTALLATION_MODE:-standard}",
  "enforcementLevel": "${ENFORCEMENT_LEVEL:-immediate}",
  "version": "2.0.0"
}
EOF

    if [ "$verification_passed" = true ]; then
        print_log "$GREEN" "✅ Installation verification passed ($components_verified components)"
    else
        print_log "$RED" "❌ Installation verification failed ($components_failed components missing)"
        print_log "$YELLOW" "   Review: $VERIFICATION_LOG"
        return 1
    fi

    return 0
}

# Main installation function
main() {
    # Check git
    check_git || exit 1

    # Check for partial installation and attempt recovery
    if [ -d ".flowforge" ]; then
        recover_partial_installation
    fi

    # Create directory structure
    create_flowforge_structure
    
    # Get installation preferences if not provided
    if [ -z "$INSTALLATION_MODE" ] && [ "$DRY_RUN" = false ]; then
        echo -e "\n${BOLD}${BLUE}Select installation type:${NC}"
        echo "1) Standard - Full FlowForge integration (recommended)"
        echo "2) Simple - Basic integration for existing projects"  
        echo "3) Complete - Full setup with migration guide"
        read -p "Choice [1-3]: " mode_choice
        
        case $mode_choice in
            1) INSTALLATION_MODE="standard" ;;
            2) INSTALLATION_MODE="simple" ;;
            3) INSTALLATION_MODE="complete" ;;
            *) INSTALLATION_MODE="standard" ;;
        esac
    fi
    
    if [ -z "$ENFORCEMENT_LEVEL" ] && [ "$DRY_RUN" = false ]; then
        echo -e "\n${BOLD}${BLUE}Select enforcement level:${NC}"
        echo "1) Immediate - All rules enforced now (recommended for new projects)"
        echo "2) Gradual - 30-day transition period (for existing projects)"
        read -p "Choice [1-2]: " enforcement_choice
        
        case $enforcement_choice in
            1) ENFORCEMENT_LEVEL="immediate" ;;
            2) ENFORCEMENT_LEVEL="gradual" ;;
            *) ENFORCEMENT_LEVEL="immediate" ;;
        esac
    fi
    
    # Set defaults for dry run
    INSTALLATION_MODE="${INSTALLATION_MODE:-standard}"
    ENFORCEMENT_LEVEL="${ENFORCEMENT_LEVEL:-immediate}"
    
    log "Installation mode: $INSTALLATION_MODE"
    log "Enforcement level: $ENFORCEMENT_LEVEL"
    
    # Create configuration
    create_config "$INSTALLATION_MODE" "$ENFORCEMENT_LEVEL"
    
    # Copy essential files
    copy_essential_files
    
    # Install components (v2.0 flow)
    install_hooks
    install_scripts
    install_statusline           # Install statusline to .flowforge/bin
    install_claude_statusline    # Install statusline to .claude directory
    install_flowforge_commands  # New v2.0 unified commands
    install_flowforge_agents     # New v2.0 agent system
    install_v2_components        # v2.0 specific components
    setup_claude_settings
    install_notion_mcp           # Optional Notion MCP setup
    
    # Create initial documentation and data files
    create_initial_docs
    
    # Update .gitignore
    update_gitignore
    
    # Validate v2.0 installation
    validate_v2_installation
    
    # Post-installation verification
    if [ "$DRY_RUN" = false ]; then
        if ! verify_installation; then
            log_error "Post-installation verification failed"
            # Don't exit here, just warn
            print_log "$YELLOW" "⚠️  Some components may need manual configuration"
        fi
    fi

    # Mark installation as complete
    INSTALLATION_STATE="COMPLETED"
    ROLLBACK_REQUIRED=false
    log_transaction "COMMIT_TRANSACTION" "$(date)"
    
    # Summary
    echo -e "\n================================"
    if [ "$DRY_RUN" = true ]; then
        print_log "$BLUE" "🔍 DRY RUN COMPLETE"
        print_log "$YELLOW" "No changes were made. Run without --dry-run to install."
    else
        print_log "$GREEN" "✅ FlowForge v2.0 Installation Complete!"
        print_log "$BLUE" "\n📋 Quick Start Commands:"
        print_log "$BLUE" "1. ${BOLD}./run_ff_command.sh flowforge:session:start${NC} - Begin work"
        print_log "$BLUE" "2. ${BOLD}./run_ff_command.sh flowforge:help${NC} - View all commands"
        print_log "$BLUE" "3. ${BOLD}./run_ff_command.sh flowforge:project:setup${NC} - Complete setup"
        print_log "$BLUE" "4. ${BOLD}./run_ff_command.sh flowforge:agent:manage list${NC} - View agents"
        
        print_log "$YELLOW" "\n🚀 What's New in v2.0:"
        print_log "$YELLOW" "- Unified command structure (/commands/flowforge/)"
        print_log "$YELLOW" "- 12+ specialized AI agents (Rule #35 enforced)"
        print_log "$YELLOW" "- Enhanced time tracking & context preservation"
        print_log "$YELLOW" "- Single source of truth for all commands"
        
        print_log "$BOLD$RED" "\n⚠️  IMPORTANT: Restart Claude Code to activate agents!"
        print_log "$YELLOW" "   Agents installed to: .claude/agents/"
        print_log "$YELLOW" "   After restart, use /agents to see available agents"
        
        print_log "$PURPLE" "\n⚡ Key Features:"
        print_log "$PURPLE" "- 35 development rules (including mandatory agent usage)"
        print_log "$PURPLE" "- Zero-friction workflow with ff:next"
        print_log "$PURPLE" "- Automatic context preservation between sessions"
        print_log "$PURPLE" "- Professional project management built-in"
    fi
    
    # Generate project metrics report
    print_log "$CYAN" "\n📊 Generating project metrics..."
    if [ -f "commands/flowforge/analytics/metrics.md" ]; then
        # Extract and run the metrics generation code
        bash -c "$(awk '/^```bash$/,/^```$/' commands/flowforge/analytics/metrics.md | sed '1d;$d')" >/dev/null 2>&1 || true
        if [ -f "reports/PROJECT_METRICS.md" ]; then
            print_log "$GREEN" "✅ Project metrics report generated: reports/PROJECT_METRICS.md"
        fi
    fi
    
    # Show logs location
    print_log "$BLUE" "\n📝 Logs saved to:"
    print_log "$BLUE" "   Full log: $LOG_FILE"
    if [ -f "$ERROR_LOG" ] && [ -s "$ERROR_LOG" ]; then
        print_log "$RED" "   Errors: $ERROR_LOG"
    fi
}

# Run main installation
main

# Cleanup old logs (keep last 10)
log "Cleaning up old logs"
ls -t "$LOG_DIR"/install-*.log 2>/dev/null | tail -n +11 | xargs -r rm
ls -t "$LOG_DIR"/errors-*.log 2>/dev/null | tail -n +11 | xargs -r rm

# Create installation success marker
if [ "$DRY_RUN" = false ] && [ "$INSTALLATION_STATE" = "COMPLETED" ]; then
    cat > ".flowforge/.installation-complete" << EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "version": "2.0.0",
  "mode": "${INSTALLATION_MODE:-standard}",
  "enforcement": "${ENFORCEMENT_LEVEL:-immediate}",
  "success": true
}
EOF
fi

# Exit successfully
exit 0