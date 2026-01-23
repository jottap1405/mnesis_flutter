#!/bin/bash
# FlowForge File Size Enforcement Hook
# Enforces Rule #24: 700 line limit for non-test files
# Test files have NO limit

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check if file is a test file
is_test_file() {
    local file=$1
    if [[ "$file" =~ \.(test|spec)\.(ts|js|tsx|jsx)$ ]]; then
        return 0  # True - is a test file
    fi
    return 1  # False - not a test file
}

# Function to block file creation/save
block_file() {
    local file=$1
    local lines=$2
    
    echo -e "\n${RED}❌ BLOCKED BY RULE #24: File Size Limit Exceeded${NC}"
    echo -e "${RED}════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}📋 Rule: Code files must not exceed 700 lines${NC}"
    echo -e "${RED}📁 File: $file${NC}"
    echo -e "${RED}📏 Lines: $lines (max: 700)${NC}"
    echo -e "${RED}❗ Violation: File is $(($lines - 700)) lines over the limit!${NC}"
    echo -e "${RED}════════════════════════════════════════════════════════${NC}\n"
    
    echo -e "${YELLOW}💡 REQUIRED ACTION - Refactor into modules:${NC}"
    echo -e "${YELLOW}1. Split by responsibility:${NC}"
    echo -e "   - Separate business logic from utilities"
    echo -e "   - Extract helper functions to separate files"
    echo -e "   - Move types/interfaces to dedicated files"
    
    echo -e "${YELLOW}2. Create focused modules:${NC}"
    echo -e "   - Each file should have ONE clear purpose"
    echo -e "   - Use index files to re-export from modules"
    echo -e "   - Follow Single Responsibility Principle"
    
    echo -e "${YELLOW}3. Suggested structure:${NC}"
    echo -e "   📁 feature/"
    echo -e "   ├── index.ts         (public API)"
    echo -e "   ├── types.ts         (interfaces/types)"
    echo -e "   ├── service.ts       (business logic)"
    echo -e "   ├── utils.ts         (helper functions)"
    echo -e "   └── validators.ts    (validation logic)"
    
    echo -e "${YELLOW}4. Example refactoring:${NC}"
    echo -e "   ${file} → Split into:"
    
    # Suggest split based on file name
    local base_name=$(basename "$file" | sed 's/\.[^.]*$//')
    local dir_name=$(dirname "$file")
    
    echo -e "   - ${dir_name}/${base_name}/index.ts"
    echo -e "   - ${dir_name}/${base_name}/types.ts"
    echo -e "   - ${dir_name}/${base_name}/core.ts"
    echo -e "   - ${dir_name}/${base_name}/utils.ts"
    echo -e ""
    
    echo -e "${RED}⚠️  AGENTS: This is a CRITICAL violation!${NC}"
    echo -e "${RED}You MUST refactor IMMEDIATELY before proceeding.${NC}"
    echo -e "${RED}Check file size DURING creation, not after!${NC}\n"
    
    return 1
}

# Function to warn about approaching limit
warn_file_size() {
    local file=$1
    local lines=$2
    
    echo -e "\n${YELLOW}⚠️  WARNING: Approaching Rule #24 limit${NC}"
    echo -e "${YELLOW}📁 File: $file${NC}"
    echo -e "${YELLOW}📏 Lines: $lines (limit: 700)${NC}"
    echo -e "${YELLOW}💡 Consider refactoring soon - only $((700 - $lines)) lines remaining!${NC}\n"
}

# Main enforcement function
enforce_file_size() {
    local violations=0
    local warnings=0
    
    # Check all staged files
    local staged_files=$(git diff --cached --name-only --diff-filter=AM 2>/dev/null || echo "")
    
    # Also check files being edited (for real-time enforcement)
    if [ -z "$staged_files" ] && [ -n "$1" ]; then
        staged_files="$1"
    fi
    
    if [ -z "$staged_files" ]; then
        return 0
    fi
    
    echo -e "${BLUE}🔍 Checking file sizes (Rule #24)...${NC}"
    
    while IFS= read -r file; do
        # Skip if file doesn't exist
        if [ ! -f "$file" ]; then
            continue
        fi
        
        # Only check code files
        if [[ ! "$file" =~ \.(ts|tsx|js|jsx|py|go|java|rb|cs)$ ]]; then
            continue
        fi
        
        # Get line count
        local lines=$(wc -l < "$file" 2>/dev/null || echo 0)
        
        # Check if it's a test file
        if is_test_file "$file"; then
            # Test files have no limit - just info message for very large ones
            if [ "$lines" -gt 2000 ]; then
                echo -e "${GREEN}✓ Test file: $file (${lines} lines - no limit for tests)${NC}"
            fi
        else
            # Non-test files must respect 700 line limit
            if [ "$lines" -gt 700 ]; then
                block_file "$file" "$lines"
                violations=$((violations + 1))
            elif [ "$lines" -gt 600 ]; then
                warn_file_size "$file" "$lines"
                warnings=$((warnings + 1))
            fi
        fi
    done <<< "$staged_files"
    
    # Summary
    if [ "$violations" -gt 0 ]; then
        echo -e "${RED}❌ File size check FAILED: $violations file(s) exceed 700 lines${NC}"
        echo -e "${RED}📋 Fix required: Refactor large files into modules${NC}"
        exit 1
    elif [ "$warnings" -gt 0 ]; then
        echo -e "${YELLOW}⚠️  File size check: $warnings file(s) approaching limit${NC}"
    else
        echo -e "${GREEN}✅ File size check passed - all files within limits${NC}"
    fi
    
    return 0
}

# Handle different contexts
case "${1:-check}" in
    "pre-commit")
        # Git pre-commit hook context
        enforce_file_size
        ;;
    "pre-save")
        # Editor pre-save hook context (if integrated)
        enforce_file_size "$2"
        ;;
    "check")
        # Manual check
        enforce_file_size
        ;;
    "all")
        # Check all files in repository
        echo -e "${BLUE}🔍 Checking ALL repository files...${NC}"
        find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" \) \
            -not -path "*/node_modules/*" \
            -not -path "*/.git/*" \
            -not -path "*/dist/*" \
            -not -path "*/build/*" | while read -r file; do
            
            lines=$(wc -l < "$file" 2>/dev/null || echo 0)
            
            if is_test_file "$file"; then
                if [ "$lines" -gt 2000 ]; then
                    echo "TEST: $file - $lines lines (no limit)"
                fi
            else
                if [ "$lines" -gt 700 ]; then
                    echo -e "${RED}VIOLATION: $file - $lines lines (limit: 700)${NC}"
                elif [ "$lines" -gt 600 ]; then
                    echo -e "${YELLOW}WARNING: $file - $lines lines (approaching limit)${NC}"
                fi
            fi
        done
        ;;
    *)
        echo "Usage: $0 [pre-commit|pre-save|check|all] [file]"
        exit 1
        ;;
esac