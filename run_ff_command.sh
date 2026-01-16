#!/bin/bash
# FlowForge Command Runner - CRITICAL FOR CLAUDE CODE

# Usage: ./run_ff_command.sh <command-path> [arguments]
# Example: ./run_ff_command.sh flowforge:session:start 14

# CRITICAL: This script assumes it's located in the FlowForge project root
# All commands will be executed from the directory containing this script

# Get the directory where this script is located (FlowForge root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify this is a FlowForge project
if [ ! -f "$SCRIPT_DIR/.flowforge/version" ] && [ ! -d "$SCRIPT_DIR/.flowforge/commands/flowforge" ]; then
    echo "❌ Error: run_ff_command.sh must be in FlowForge project root"
    echo "   Current location: $SCRIPT_DIR"
    echo "   Missing: .flowforge/version or .flowforge/commands/flowforge/"
    echo ""
    echo "💡 Solutions:"
    echo "   1. Run from the FlowForge project directory"
    echo "   2. Use: cd /path/to/flowforge && ./run_ff_command.sh ..."
    echo "   3. Create an alias: alias ff='/path/to/flowforge/run_ff_command.sh'"
    exit 1
fi

# Change to the FlowForge root directory
# This ensures all relative paths in commands work correctly
cd "$SCRIPT_DIR" || exit 1

# Convert command format to path
COMMAND="$1"
shift
export ARGUMENTS="$*"

# Convert flowforge:session:start to .flowforge/commands/flowforge/session/start.md
COMMAND_PATH=".flowforge/commands/${COMMAND//:///}.md"

# Check for command existence, with helpful error messages
if [ ! -f "$COMMAND_PATH" ]; then
    # Check for common aliases and provide helpful suggestions
    case "$COMMAND" in
        "startsession"|"flowforge:startsession")
            echo "❌ Command '$COMMAND' has been replaced"
            echo "💡 Use: ./run_ff_command.sh flowforge:session:start $ARGUMENTS"
            exit 1
            ;;
        "endday"|"flowforge:endday")
            echo "❌ Command '$COMMAND' has been replaced"
            echo "💡 Use: ./run_ff_command.sh flowforge:session:end $ARGUMENTS"
            exit 1
            ;;
        *)
            echo "❌ Command file not found: $COMMAND_PATH"
            echo "💡 Run: ./run_ff_command.sh flowforge:help"
            exit 1
            ;;
    esac
fi

echo "Running FlowForge command: $COMMAND with arguments: $ARGUMENTS"

# Extract and run bash code blocks
INSIDE_BASH=0
TEMP_SCRIPT="/tmp/flowforge_command_$$.sh"
> "$TEMP_SCRIPT"

while IFS= read -r line; do
    if [[ "$line" == '```bash' ]]; then
        INSIDE_BASH=1
    elif [[ "$line" == '```' ]] && [ $INSIDE_BASH -eq 1 ]; then
        INSIDE_BASH=0
    elif [ $INSIDE_BASH -eq 1 ]; then
        echo "$line" >> "$TEMP_SCRIPT"
    fi
done < "$COMMAND_PATH"

# Execute the extracted script
if [ -s "$TEMP_SCRIPT" ]; then
    bash "$TEMP_SCRIPT"
    EXIT_CODE=$?
    rm -f "$TEMP_SCRIPT"
    exit $EXIT_CODE
else
    echo "Error: No bash code found in command file"
    exit 1
fi