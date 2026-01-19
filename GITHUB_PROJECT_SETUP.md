# GitHub Project Board Setup Guide

## Overview
This guide provides instructions for creating the **Mnesis Flutter Development Roadmap** project board for tracking 56 tasks across 7 epics (148 hours of development).

---

## Option 1: CLI Setup (Recommended - After Auth)

### Step 1: Authenticate with Project Scope
```bash
gh auth refresh -h github.com -s project
```
Follow the browser prompts to authorize the project scope.

### Step 2: Create the Project Board
```bash
gh project create \
  --owner jottap1405 \
  --title "Mnesis Flutter Development Roadmap" \
  --format json > project_info.json
```

### Step 3: Extract Project Number
```bash
PROJECT_NUMBER=$(cat project_info.json | jq -r '.number')
echo "Project Number: $PROJECT_NUMBER"
```

### Step 4: Add Description (via web or API)
The description should be: "6-week development roadmap tracking 56 tasks across 7 epics (148 hours)"

### Step 5: Link Repository
```bash
gh project link $PROJECT_NUMBER \
  --owner jottap1405 \
  --repo mnesis_flutter
```

### Step 6: Add All Issues to Project
```bash
# Get all issue numbers
gh issue list --repo jottap1405/mnesis_flutter --limit 100 --json number --jq '.[].number' > issue_numbers.txt

# Add each issue to the project
while read -r issue_number; do
  gh project item-add $PROJECT_NUMBER \
    --owner jottap1405 \
    --url "https://github.com/jottap1405/mnesis_flutter/issues/$issue_number"
  echo "Added issue #$issue_number"
done < issue_numbers.txt
```

---

## Option 2: Manual Web UI Setup (Immediate)

### Step 1: Create Project Board
1. Go to: https://github.com/jottap1405/mnesis_flutter
2. Click on the **"Projects"** tab
3. Click **"Link a project"** → **"New project"**
4. Select **"Board"** template
5. Click **"Create project"**

### Step 2: Configure Project Details
1. **Title**: `Mnesis Flutter Development Roadmap`
2. **Description**: `6-week development roadmap tracking 56 tasks across 7 epics (148 hours)`
3. Click **"Create"**

### Step 3: Configure Columns
The default board template comes with "Todo", "In Progress", and "Done" columns.

**Modify the columns to match our workflow**:

1. **Rename "Todo" to "📋 Backlog"**
   - Click on the column header "⋯" menu
   - Select "Rename"
   - Enter: `📋 Backlog`

2. **Add "🔜 Ready" column**
   - Click "+ Add column" (between Backlog and In Progress)
   - Name: `🔜 Ready`
   - Description: "Tasks ready to begin"

3. **Rename "In Progress" to "🏗️ In Progress"**
   - Click on the column header "⋯" menu
   - Select "Rename"
   - Enter: `🏗️ In Progress`

4. **Add "👀 Review" column**
   - Click "+ Add column" (between In Progress and Done)
   - Name: `👀 Review`
   - Description: "Code review/testing"

5. **Rename "Done" to "✅ Done"**
   - Click on the column header "⋯" menu
   - Select "Rename"
   - Enter: `✅ Done`

**Final column order**:
```
📋 Backlog → 🔜 Ready → 🏗️ In Progress → 👀 Review → ✅ Done
```

### Step 4: Add Issues to Project
1. Click **"Add item"** (+ button in any column, preferably Backlog)
2. Type `#` to see a list of issues
3. Select issues one by one, or:
   - Use the **"⋯"** menu at the top right
   - Select **"Workflows"** → **"Auto-add to project"**
   - Configure: "When issues are opened in this repository, add them to Backlog"

**Bulk Add Method**:
1. Go to: https://github.com/jottap1405/mnesis_flutter/issues
2. Select multiple issues using checkboxes
3. Click **"Project"** at the top
4. Select your project board
5. All selected issues will be added to the Backlog column

### Step 5: Configure Automation (Workflows)
1. Click the **"⋯"** menu at the top right of the project
2. Select **"Workflows"**
3. Enable the following:

   **Auto-add to project**:
   - ✅ When issues or pull requests are **opened** → Add to **📋 Backlog**

   **Auto-archive**:
   - ✅ When issues or pull requests are **closed** → Move to **✅ Done**

   **Item closed**:
   - ✅ When item status is **Closed** → Move to **✅ Done**

### Step 6: Configure Status Field
1. Click on any item in the project
2. Click **"+ Add field"** → **"Status"**
3. Configure status options to match columns:
   - Backlog
   - Ready
   - In Progress
   - Review
   - Done

### Step 7: Add Milestone Field (Optional)
1. Click **"+ Add field"** → **"Milestone"**
2. This will automatically pull milestone data from issues

### Step 8: Add Priority Field (Optional)
1. Click **"+ Add field"** → **"Single select"**
2. Name: `Priority`
3. Add options:
   - 🔴 Critical
   - 🟠 High
   - 🟡 Medium
   - 🟢 Low

---

## Project Board Structure

### Columns & Workflow

| Column | Purpose | Automation |
|--------|---------|------------|
| 📋 **Backlog** | Tasks not yet started, awaiting prioritization | New issues auto-added here |
| 🔜 **Ready** | Tasks ready to begin, dependencies met | Manual move from Backlog |
| 🏗️ **In Progress** | Currently working on | Manual move when work starts |
| 👀 **Review** | Code review/testing phase | Manual move when PR is created |
| ✅ **Done** | Completed tasks | Auto-moved when issue closed |

### Board Views (Optional)

Create additional views for better organization:

1. **By Milestone**
   - Click **"View"** → **"New view"** → **"Table"**
   - Group by: **Milestone**
   - Name: "By Milestone"

2. **By Priority**
   - Click **"View"** → **"New view"** → **"Board"**
   - Group by: **Priority**
   - Name: "By Priority"

3. **By Assignee**
   - Click **"View"** → **"New view"** → **"Table"**
   - Group by: **Assignee**
   - Name: "By Assignee"

---

## Issue Distribution Across Milestones

| Milestone | Issues | Hours | Duration |
|-----------|--------|-------|----------|
| M1: Foundation & Architecture | #1-8 | 18h | Week 1 |
| M2: Authentication System | #9-17 | 20h | Week 2 |
| M3: Database & Core Features | #18-29 | 28h | Week 3 |
| M4: UI/UX & Navigation | #30-38 | 22h | Week 4 |
| M5: Advanced Features | #39-46 | 24h | Week 5 |
| M6: Testing & Quality | #47-52 | 18h | Week 6 |
| M7: Deployment & Launch | #53-56 | 18h | Week 6 |
| **TOTAL** | **56 issues** | **148h** | **6 weeks** |

---

## Expected Initial State

After setup, your project board should show:
- **📋 Backlog**: All 56 issues (#1-56)
- **🔜 Ready**: Empty (manual prioritization needed)
- **🏗️ In Progress**: Empty
- **👀 Review**: Empty
- **✅ Done**: Empty

---

## Next Steps After Setup

1. **Prioritize Backlog**: Move Week 1 tasks (#1-8) to "🔜 Ready"
2. **Start Work**: Begin with issue #1 (FlowForge session setup)
3. **Track Progress**: Move issues through workflow as you work
4. **Review Regularly**: Check board daily for status updates

---

## Troubleshooting

### Issues Not Showing
- Ensure the project is linked to the repository
- Check that automation workflows are enabled
- Manually add missing issues using `#` syntax

### Columns Not Mapping to Status
- Ensure Status field is configured
- Map column names to status values
- Save changes and refresh

### Automation Not Working
- Check workflow settings under "⋯" → "Workflows"
- Ensure you have admin permissions on the repository
- Re-enable workflows if needed

---

## CLI Commands Reference

```bash
# List projects
gh project list --owner jottap1405

# View project
gh project view <NUMBER> --owner jottap1405

# Add issue to project
gh project item-add <PROJECT_NUMBER> \
  --owner jottap1405 \
  --url https://github.com/jottap1405/mnesis_flutter/issues/<ISSUE_NUMBER>

# List project items
gh project item-list <PROJECT_NUMBER> --owner jottap1405

# Link project to repo
gh project link <PROJECT_NUMBER> \
  --owner jottap1405 \
  --repo mnesis_flutter
```

---

## Resources

- [GitHub Projects Documentation](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [GitHub CLI Projects Documentation](https://cli.github.com/manual/gh_project)
- [Project Board Best Practices](https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/best-practices-for-projects)

---

**Created**: 2026-01-19
**Project**: Mnesis Flutter Development
**Repository**: jottap1405/mnesis_flutter
**Total Issues**: 56
**Total Effort**: 148 hours
**Timeline**: 6 weeks
