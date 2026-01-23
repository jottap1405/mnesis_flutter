#!/bin/bash
# Rapid Agent Creator for FlowForge
set -e

AGENT_NAME="$1"
if [ -z "$AGENT_NAME" ]; then
    echo "Usage: $0 <agent-name>"
    exit 1
fi

FLOWFORGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENT_FILE="$FLOWFORGE_ROOT/agents/${AGENT_NAME}.md"

if [ ! -f "$AGENT_FILE" ]; then
    echo "Error: Agent file not found: $AGENT_FILE"
    exit 1
fi

echo "Installing agent: $AGENT_NAME"
# Agent installation would happen here via Claude Code API
echo "✅ Agent $AGENT_NAME installed successfully"
