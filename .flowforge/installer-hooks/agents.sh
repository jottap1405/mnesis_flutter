#!/bin/bash
# Agent installation hook for main installer

install_agents() {
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local AGENTS_INSTALLER="$SCRIPT_DIR/../../scripts/install-all-agents.sh"
    
    if [ -f "$AGENTS_INSTALLER" ]; then
        echo "Installing FlowForge agents..."
        "$AGENTS_INSTALLER"
    else
        echo "⚠️  Agent installer not found"
        return 1
    fi
}

# Run if sourced or executed
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    install_agents
fi
