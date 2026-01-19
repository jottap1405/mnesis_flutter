#!/bin/bash

# GitHub Project Board Setup Script
# Mnesis Flutter Development Roadmap
# Run this script after authenticating with: gh auth refresh -h github.com -s project

set -e  # Exit on error

OWNER="jottap1405"
REPO="mnesis_flutter"
PROJECT_TITLE="Mnesis Flutter Development Roadmap"

echo "=================================================="
echo "GitHub Project Board Setup"
echo "Project: $PROJECT_TITLE"
echo "Repository: $OWNER/$REPO"
echo "=================================================="
echo ""

# Step 1: Check authentication
echo "Step 1: Checking GitHub authentication..."
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated. Run: gh auth refresh -h github.com -s project"
    exit 1
fi
echo "✅ Authenticated"
echo ""

# Step 2: Create project board
echo "Step 2: Creating project board..."
PROJECT_DATA=$(gh project create \
  --owner "$OWNER" \
  --title "$PROJECT_TITLE" \
  --format json)

PROJECT_NUMBER=$(echo "$PROJECT_DATA" | jq -r '.number')
PROJECT_URL=$(echo "$PROJECT_DATA" | jq -r '.url')

if [ -z "$PROJECT_NUMBER" ] || [ "$PROJECT_NUMBER" == "null" ]; then
    echo "❌ Failed to create project board"
    exit 1
fi

echo "✅ Project created: #$PROJECT_NUMBER"
echo "   URL: $PROJECT_URL"
echo ""

# Save project info
echo "$PROJECT_DATA" > .github_project_info.json
echo "📝 Project info saved to: .github_project_info.json"
echo ""

# Step 3: Link repository
echo "Step 3: Linking repository to project..."
gh project link "$PROJECT_NUMBER" \
  --owner "$OWNER" \
  --repo "$REPO" || echo "⚠️  Repository link may already exist"
echo "✅ Repository linked"
echo ""

# Step 4: Get all issues
echo "Step 4: Fetching all issues..."
ISSUE_NUMBERS=$(gh issue list \
  --repo "$OWNER/$REPO" \
  --limit 100 \
  --state all \
  --json number \
  --jq '.[].number' | sort -n)

ISSUE_COUNT=$(echo "$ISSUE_NUMBERS" | wc -l | xargs)
echo "✅ Found $ISSUE_COUNT issues"
echo ""

# Step 5: Add issues to project
echo "Step 5: Adding issues to project board..."
ADDED_COUNT=0
FAILED_COUNT=0

while IFS= read -r issue_number; do
    if [ -n "$issue_number" ]; then
        ISSUE_URL="https://github.com/$OWNER/$REPO/issues/$issue_number"

        if gh project item-add "$PROJECT_NUMBER" \
           --owner "$OWNER" \
           --url "$ISSUE_URL" &> /dev/null; then
            ADDED_COUNT=$((ADDED_COUNT + 1))
            echo "  ✅ Added issue #$issue_number ($ADDED_COUNT/$ISSUE_COUNT)"
        else
            FAILED_COUNT=$((FAILED_COUNT + 1))
            echo "  ⚠️  Failed to add issue #$issue_number (may already exist)"
        fi
    fi
done <<< "$ISSUE_NUMBERS"

echo ""
echo "=================================================="
echo "Setup Complete!"
echo "=================================================="
echo ""
echo "Summary:"
echo "  Project Number: #$PROJECT_NUMBER"
echo "  Project URL: $PROJECT_URL"
echo "  Issues Added: $ADDED_COUNT"
echo "  Issues Failed: $FAILED_COUNT"
echo "  Total Issues: $ISSUE_COUNT"
echo ""
echo "Next Steps:"
echo "  1. Visit the project board: $PROJECT_URL"
echo "  2. Configure columns (see GITHUB_PROJECT_SETUP.md)"
echo "  3. Set up automation workflows"
echo "  4. Add custom fields (Priority, Milestone, etc.)"
echo "  5. Organize issues into appropriate columns"
echo ""
echo "=================================================="

# Create a summary file
cat > .github_project_summary.txt <<EOL
GitHub Project Board Setup Summary
=====================================

Project: $PROJECT_TITLE
Repository: $OWNER/$REPO
Created: $(date)

Project Details:
  - Project Number: #$PROJECT_NUMBER
  - Project URL: $PROJECT_URL
  - Repository: https://github.com/$OWNER/$REPO

Statistics:
  - Total Issues: $ISSUE_COUNT
  - Issues Added: $ADDED_COUNT
  - Issues Failed: $FAILED_COUNT

Columns to Configure:
  1. 📋 Backlog - Tasks not yet started
  2. 🔜 Ready - Tasks ready to begin
  3. 🏗️ In Progress - Currently working on
  4. 👀 Review - Code review/testing
  5. ✅ Done - Completed tasks

Recommended Custom Fields:
  - Priority (Single select: Critical, High, Medium, Low)
  - Milestone (Milestone field)
  - Assignee (Assignee field)
  - Effort (Number field for hours)

Automation to Enable:
  - Auto-add new issues to Backlog
  - Auto-move closed issues to Done
  - Auto-archive items when closed

Documentation:
  - Setup Guide: GITHUB_PROJECT_SETUP.md
  - Project Info: .github_project_info.json

Next Actions:
  1. Configure columns via web UI
  2. Enable automation workflows
  3. Add custom fields
  4. Prioritize backlog items
  5. Start working on Milestone 1 issues (#1-8)

=====================================
EOL

echo "📝 Summary saved to: .github_project_summary.txt"
echo ""
