#!/bin/bash
# remove-skill.sh - Remove a skill and clean up its symlinks
# Usage: ./remove-skill.sh <skill-name>
# Example: ./remove-skill.sh code-review

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

if [ $# -lt 1 ]; then
    echo "Usage: remove-skill.sh <skill-name>"
    echo "Example: remove-skill.sh code-review"
    exit 1
fi

SKILL_NAME="$1"
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

if [ ! -d "$SKILL_DIR" ]; then
    echo "Error: Skill '$SKILL_NAME' not found at $SKILL_DIR"
    exit 1
fi

echo "Removing skill: $SKILL_NAME"
echo ""

TARGETS=()
TOOL_NAMES=()

current_tool=""
current_enabled=""
current_path=""

while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if echo "$line" | grep -qE '^  [a-z].*:$'; then
        if [ -n "$current_path" ]; then
            expanded_path="${current_path/#\~/$HOME}"
            TARGETS+=("$expanded_path")
            TOOL_NAMES+=("$current_tool")
        fi
        current_tool=$(echo "$line" | sed 's/^  //' | sed 's/:$//')
        current_enabled=""
        current_path=""
    fi
    if echo "$line" | grep -qE '^\s+enabled:'; then
        current_enabled=$(echo "$line" | awk '{print $2}')
    fi
    if echo "$line" | grep -qE '^\s+path:'; then
        current_path=$(echo "$line" | awk '{print $2}')
    fi
done < "$CONFIG_FILE"

# Include all tools with a path (enabled or disabled) for thorough cleanup
if [ -n "$current_path" ]; then
    expanded_path="${current_path/#\~/$HOME}"
    TARGETS+=("$expanded_path")
    TOOL_NAMES+=("$current_tool")
fi

removed=0
for i in "${!TARGETS[@]}"; do
    target_dir="${TARGETS[$i]}"
    tool_name="${TOOL_NAMES[$i]}"
    link_path="$target_dir/$SKILL_NAME"
    
    if [ -L "$link_path" ]; then
        rm "$link_path"
        echo "  Removed symlink from $tool_name"
        removed=$((removed + 1))
    fi
done

rm -rf "$SKILL_DIR"
echo "  Removed skill folder: $SKILL_DIR"

echo ""
echo "Done! Removed $removed symlink(s)."