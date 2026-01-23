#!/bin/bash
# FlowForge Stop Hook - Validate Agent Usage in Session
# Checks if appropriate agents were used for the work done

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if any files were modified
MODIFIED_FILES=$(git diff --name-only 2>/dev/null || true)

if [ -z "$MODIFIED_FILES" ]; then
    exit 0  # No files modified
fi

# Cross-shell compatible implementation (works in both bash and zsh)
# Use simple variables instead of associative arrays
required_agents=""
agent_files_testing=""
agent_files_documentation=""
agent_files_frontend=""
agent_files_api=""
agent_files_database=""

while IFS= read -r file; do
    case "$file" in
        *.test.*|*.spec.*|*/tests/*)
            if [[ ! "$required_agents" =~ "fft-testing" ]]; then
                required_agents="$required_agents fft-testing"
            fi
            agent_files_testing="${agent_files_testing}  - $file\n"
            ;;
        *.md|*/documentation/*)
            if [[ ! "$required_agents" =~ "fft-documentation" ]]; then
                required_agents="$required_agents fft-documentation"
            fi
            agent_files_documentation="${agent_files_documentation}  - $file\n"
            ;;
        *.tsx|*.jsx|*.vue|*/components/*)
            if [[ ! "$required_agents" =~ "fft-frontend" ]]; then
                required_agents="$required_agents fft-frontend"
            fi
            agent_files_frontend="${agent_files_frontend}  - $file\n"
            ;;
        */api/*|*.graphql|*.proto)
            if [[ ! "$required_agents" =~ "fft-api-designer" ]]; then
                required_agents="$required_agents fft-api-designer"
            fi
            agent_files_api="${agent_files_api}  - $file\n"
            ;;
        */migrations/*|*/schema/*|*.sql)
            if [[ ! "$required_agents" =~ "fft-database" ]]; then
                required_agents="$required_agents fft-database"
            fi
            agent_files_database="${agent_files_database}  - $file\n"
            ;;
    esac
done <<< "$MODIFIED_FILES"

# Check agent usage log
LOG_FILE=".flowforge/logs/agent-usage.log"
used_agents=""

if [ -f "$LOG_FILE" ]; then
    # Get agents used in last hour
    one_hour_ago=$(date -d '1 hour ago' '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -v-1H '+%Y-%m-%d %H:%M:%S')
    while IFS='|' read -r timestamp agent agent_status; do
        if [[ "$timestamp" > "$one_hour_ago" ]]; then
            if [[ ! "$used_agents" =~ "$agent" ]]; then
                used_agents="$used_agents $agent"
            fi
        fi
    done < "$LOG_FILE"
fi

# Check for violations
missing_agents=""
for agent in $required_agents; do
    if [[ ! "$used_agents" =~ "$agent" ]]; then
        missing_agents="$missing_agents $agent"
    fi
done

# Helper function to get agent files
get_agent_files() {
    local agent="$1"
    case "$agent" in
        fft-testing) echo -e "$agent_files_testing" ;;
        fft-documentation) echo -e "$agent_files_documentation" ;;
        fft-frontend) echo -e "$agent_files_frontend" ;;
        fft-api-designer) echo -e "$agent_files_api" ;;
        fft-database) echo -e "$agent_files_database" ;;
    esac
}

# Report results
if [ -n "$missing_agents" ]; then
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠️  FlowForge Rule #35 Warning${NC}"
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}The following agents should have been used:${NC}"
    echo ""

    for agent in $missing_agents; do
        echo -e "${RED}❌ $agent${NC}"
        echo -e "${BLUE}Files that needed this agent:${NC}"
        get_agent_files "$agent"
    done

    echo -e "${BLUE}💡 Next time, use these agents BEFORE modifying files${NC}"
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
else
    if [ -n "$required_agents" ]; then
        echo -e "${GREEN}✅ FlowForge Rule #35: All required agents were used!${NC}"
    fi
fi

exit 0  # Don't block, just warn