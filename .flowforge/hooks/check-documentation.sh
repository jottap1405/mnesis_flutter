#!/bin/bash
# FlowForge Documentation Pattern Enforcement Hook

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Function to print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check file exists
check_file_exists() {
    local file=$1
    local required=${2:-true}
    
    if [ -f "$file" ]; then
        return 0
    elif [ "$required" = "true" ]; then
        print_color "$RED" "❌ Required file missing: $file"
        
        # Provide specific guidance for critical FlowForge files
        case "$file" in
            "documentation/development/.flowforge/sessions/current.json")
                print_color "$YELLOW" "   💡 This file is REQUIRED for FlowForge session management"
                print_color "$YELLOW" "   To create it: mkdir -p documentation/development && touch $file"
                print_color "$YELLOW" "   Then add the required sections shown below"
                ;;
            "CLAUDE.md")
                print_color "$YELLOW" "   💡 This file helps AI assistants understand your project"
                print_color "$YELLOW" "   To create it: Use command /flowforge:project:setup or create manually"
                ;;
            ".flowforge/RULES.md")
                print_color "$YELLOW" "   💡 This file contains FlowForge development rules"
                print_color "$YELLOW" "   Run: /flowforge:version:update to restore it"
                ;;
        esac
        
        return 1
    fi
    return 0
}

# Function to check file pattern
check_file_pattern() {
    local file=$1
    local pattern=$2
    local description=$3
    
    if ! grep -q "$pattern" "$file" 2>/dev/null; then
        print_color "$RED" "❌ $file missing required section: $description"
        return 1
    fi
    return 0
}

# Function to check documentation standards
check_documentation() {
    local errors=0
    
    print_color "$BLUE" "🔍 Checking documentation standards..."
    
    # Check if this is an existing project with established documentation
    local is_existing_project=false
    local integration_mode="standard"
    
    # Check integration mode from config
    if [ -f ".flowforge/config.json" ]; then
        integration_mode=$(jq -r '.project.integrationMode // "standard"' .flowforge/config.json 2>/dev/null || echo "standard")
    fi
    
    # Check if README indicates an established project
    if [ -f "README.md" ]; then
        # If README has more than 100 lines, it's likely an established project
        local readme_lines=$(wc -l < "README.md" 2>/dev/null || echo "0")
        if [ "$readme_lines" -gt 100 ] || [ "$integration_mode" = "simple" ]; then
            is_existing_project=true
            print_color "$BLUE" "ℹ️  Detected existing project (integration mode: $integration_mode, README: $readme_lines lines)"
            print_color "$BLUE" "ℹ️  Using relaxed validation for existing project structure"
        fi
    fi
    
    # Check required files
    local required_files=(
        "README.md"
        "CLAUDE.md"
        "documentation/development/.flowforge/sessions/current.json"
        ".flowforge/RULES.md"
    )
    
    for file in "${required_files[@]}"; do
        if ! check_file_exists "$file"; then
            ((errors++)) || true
        fi
    done
    
    # Check README.md structure (flexible for existing projects)
    if [ -f "README.md" ]; then
        check_file_pattern "README.md" "^# " "Project title" || ((errors++)) || true
        
        # Quick Start - flexible pattern for existing projects
        if ! grep -E "## .*(Quick Start|Getting Started|Installation|Setup|Usage)" "README.md" >/dev/null 2>&1; then
            print_color "$RED" "❌ README.md missing required section: Quick Start, Getting Started, Installation, or Usage section"
            ((errors++)) || true
        fi
        
        # Project Structure/Architecture - flexible pattern for existing projects  
        if ! grep -E "## .*(Project Structure|Architecture|Directory Structure|File Structure|Structure|Organization)" "README.md" >/dev/null 2>&1; then
            # For existing projects, just warn instead of error
            if [ "$is_existing_project" = true ]; then
                print_color "$YELLOW" "⚠️  README.md missing recommended section: Project Structure or Architecture section"
                print_color "$YELLOW" "   Consider adding a structure section in future updates"
            else
                print_color "$RED" "❌ README.md missing required section: Project Structure, Architecture, or similar section"
                ((errors++)) || true
            fi
        fi
        
        # Testing - flexible pattern with common variations
        if ! grep -E "## .*(Testing|Tests|Test Suite|Running Tests|Test|Development)" "README.md" >/dev/null 2>&1; then
            print_color "$YELLOW" "⚠️  README.md missing recommended section: Testing or Tests section"
            # Only warning, not error for testing section
        fi
    fi
    
    # Check CLAUDE.md structure
    if [ -f "CLAUDE.md" ]; then
        check_file_pattern "CLAUDE.md" "## 🚨 Current Priority" "Current Priority section" || ((errors++)) || true
        check_file_pattern "CLAUDE.md" "## 🚀 Session Management" "Session Management section" || ((errors++)) || true
        check_file_pattern "CLAUDE.md" "## 📋 Project Overview" "Project Overview section" || ((errors++)) || true
        check_file_pattern "CLAUDE.md" "## 🎯 Core Rules" "Core Rules section" || ((errors++)) || true
    fi
    
    # Check .flowforge/sessions/current.json structure - REQUIRED for FlowForge automation
    if [ -f "documentation/development/.flowforge/sessions/current.json" ]; then
        if ! grep -q "## 📊 Last Session Summary" "documentation/development/.flowforge/sessions/current.json"; then
            print_color "$RED" "❌ .flowforge/sessions/current.json missing REQUIRED section for FlowForge automation:"
            print_color "$RED" "   Missing: ## 📊 Last Session Summary"
            print_color "$YELLOW" ""
            print_color "$YELLOW" "   💡 To fix, add this section to documentation/development/.flowforge/sessions/current.json:"
            print_color "$YELLOW" "   ────────────────────────────────────────────────────────────"
            print_color "$YELLOW" "   ## 📊 Last Session Summary"
            print_color "$YELLOW" "   "
            print_color "$YELLOW" "   ### What was completed:"
            print_color "$YELLOW" "   - [Brief summary of completed work]"
            print_color "$YELLOW" "   "
            print_color "$YELLOW" "   ### Key decisions:"
            print_color "$YELLOW" "   - [Any important decisions made]"
            print_color "$YELLOW" "   ────────────────────────────────────────────────────────────"
            ((errors++)) || true
        fi
        
        if ! grep -q "## 🎯 Next Session Tasks" "documentation/development/.flowforge/sessions/current.json"; then
            print_color "$RED" "❌ .flowforge/sessions/current.json missing REQUIRED section for FlowForge automation:"
            print_color "$RED" "   Missing: ## 🎯 Next Session Tasks"
            print_color "$YELLOW" ""
            print_color "$YELLOW" "   💡 To fix, add this section to documentation/development/.flowforge/sessions/current.json:"
            print_color "$YELLOW" "   ────────────────────────────────────────────────────────────"
            print_color "$YELLOW" "   ## 🎯 Next Session Tasks"
            print_color "$YELLOW" "   "
            print_color "$YELLOW" "   1. [ ] First task to complete"
            print_color "$YELLOW" "   2. [ ] Second task to complete"
            print_color "$YELLOW" "   3. [ ] Continue with..."
            print_color "$YELLOW" "   ────────────────────────────────────────────────────────────"
            ((errors++)) || true
        fi
    fi
    
    # Check for Architecture Decision Records
    if [ -d "documentation/architecture" ]; then
        local adr_count=$(find documentation/architecture -name "ADR-*.md" | wc -l)
        if [ $adr_count -eq 0 ]; then
            print_color "$YELLOW" "⚠️  No Architecture Decision Records found"
        fi
    fi
    
    # Check API documentation
    if [ -d "src" ] && [ -d "documentation/api" ]; then
        local api_files=$(find src -name "*.routes.*" -o -name "*.controller.*" | wc -l)
        local api_docs=$(find documentation/api -name "*.md" | wc -l)
        
        if [ $api_files -gt 0 ] && [ $api_docs -eq 0 ]; then
            print_color "$YELLOW" "⚠️  API routes found but no API documentation"
        fi
    fi
    
    return $errors
}

# Function to check markdown quality
check_markdown_quality() {
    local file=$1
    local warnings=0
    
    # Check for proper headers hierarchy
    if grep -E "^####+ " "$file" | grep -vE "^#{1,6} " >/dev/null 2>&1; then
        print_color "$YELLOW" "⚠️  $file: Invalid header hierarchy"
        ((warnings++)) || true
    fi
    
    # Check for broken links
    if grep -E "\[.*\]\(\s*\)" "$file" >/dev/null 2>&1; then
        print_color "$YELLOW" "⚠️  $file: Empty link found"
        ((warnings++)) || true
    fi
    
    # Check for TODO items (smart check - only for actual TODOs, not documentation about TODOs)
    # Skip this check for documentation files that might legitimately discuss TODOs
    local is_doc_about_todos=false
    
    # Check if this is documentation that might discuss TODOs
    if [[ "$file" =~ (EMERGENCY|TESTING|DEVELOPMENT|CONTRIBUTING|WORKFLOW) ]] || \
       [[ "$file" =~ (templates/|examples/|docs/) ]]; then
        is_doc_about_todos=true
    fi
    
    # Only check for actual TODO items (with - [ ] or at start of line with colon)
    if [ "$is_doc_about_todos" = false ]; then
        # Look for actual TODO items like "TODO:" or "- [ ] TODO" but not "how to handle TODOs"
        if grep -E "^[[:space:]]*(TODO|FIXME|XXX):|^[[:space:]]*-[[:space:]]\[[[:space:]]\][[:space:]]*(TODO|FIXME)" "$file" >/dev/null 2>&1; then
            print_color "$YELLOW" "⚠️  $file: Unresolved TODO/FIXME task found"
            ((warnings++)) || true
        fi
    fi
    
    return $warnings
}

# Function to check documentation currency
check_documentation_currency() {
    local warnings=0
    
    # Check if documentation is up to date with code
    if [ -f ".flowforge/config.json" ]; then
        local project_version=$(jq -r '.version' .flowforge/config.json 2>/dev/null || echo "unknown")
        
        # Check if README mentions current version
        if [ -f "README.md" ] && ! grep -q "$project_version" README.md; then
            print_color "$YELLOW" "⚠️  README.md may be outdated (version mismatch)" >&2
            ((warnings++)) || true
        fi
    fi
    
    # Check last modified dates
    local doc_files=(
        "README.md"
        "CLAUDE.md"
        "documentation/development/.flowforge/sessions/current.json"
    )
    
    for file in "${doc_files[@]}"; do
        if [ -f "$file" ]; then
            local last_modified=$(git log -1 --format="%ar" -- "$file" 2>/dev/null || echo "unknown")
            if [[ "$last_modified" =~ "months ago" ]] || [[ "$last_modified" =~ "years ago" ]]; then
                print_color "$YELLOW" "⚠️  $file last updated: $last_modified" >&2
                ((warnings++)) || true
            fi
        fi
    done
    
    # Echo the warning count for capture
    echo "$warnings"
}

# Main execution
main() {
    local total_errors=0
    local total_warnings=0
    
    # Colors need to be defined here too for local scope
    local BLUE='\033[0;34m'
    
    print_color "$BLUE" "📚 FlowForge Documentation Check"
    echo "================================"
    
    # Check documentation standards
    check_documentation
    total_errors=$?
    
    # Check markdown quality for staged .md files only
    print_color "$BLUE" "\n🔍 Checking markdown quality..."
    local staged_md_files=$(git diff --cached --name-only | grep -E "\.(md|MD)$" || true)
    if [ -n "$staged_md_files" ]; then
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                check_markdown_quality "$file"
                total_warnings=$((total_warnings + $?))
            fi
        done <<< "$staged_md_files"
    else
        print_color "$BLUE" "   No markdown files staged for commit"
    fi
    
    # Check documentation currency
    print_color "$BLUE" "\n🔍 Checking documentation currency..."
    local currency_warnings=$(check_documentation_currency)
    total_warnings=$((total_warnings + currency_warnings))
    
    # Summary
    echo ""
    echo "================================"
    if [ $total_errors -eq 0 ] && [ $total_warnings -eq 0 ]; then
        print_color "$GREEN" "✅ All documentation checks passed!"
        return 0
    else
        if [ $total_errors -gt 0 ]; then
            print_color "$RED" "❌ Found $total_errors error(s) that must be fixed"
        fi
        if [ $total_warnings -gt 0 ]; then
            print_color "$YELLOW" "⚠️  Found $total_warnings warning(s) to consider"
        fi
        
        if [ $total_errors -gt 0 ]; then
            return 1
        fi
        return 0
    fi
}

# Run checks if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi