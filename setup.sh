#!/bin/bash
# setup.sh - Create symlinks from this repo to all enabled AI coding tools
# Reads tool paths from config.yaml. Safe to run multiple times.
# Never deletes or overwrites existing skills.
# Usage: ./setup.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

echo ""
echo "AI Skills Setup"
echo "==============="
echo "Source: $SKILLS_DIR"
echo ""

# Check source exists
if [ ! -d "$SKILLS_DIR" ]; then
    echo "Error: Skills folder not found at $SKILLS_DIR"
    exit 1
fi

# Check config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config.yaml not found. Copy config.yaml.example and edit it."
    exit 1
fi

# Parse config.yaml for enabled tools
# Reads tool name, enabled status, and path
TARGETS=()
TOOL_NAMES=()

current_tool=""
current_enabled=""
current_path=""

while IFS= read -r line; do
    # Match tool name (indented, ends with colon, under tools:)
    if echo "$line" | grep -qE '^  [a-z].*:$'; then
        # Save previous tool if it was enabled
        if [ "$current_enabled" = "true" ] && [ -n "$current_path" ]; then
            expanded_path="${current_path/#\~/$HOME}"
            TARGETS+=("$expanded_path")
            TOOL_NAMES+=("$current_tool")
        fi
        current_tool=$(echo "$line" | sed 's/^  //' | sed 's/:$//')
        current_enabled=""
        current_path=""
    fi

    # Match enabled field
    if echo "$line" | grep -qE '^\s+enabled:'; then
        current_enabled=$(echo "$line" | awk '{print $2}')
    fi

    # Match path field
    if echo "$line" | grep -qE '^\s+path:'; then
        current_path=$(echo "$line" | awk '{print $2}')
    fi
done < "$CONFIG_FILE"

# Don't forget the last tool
if [ "$current_enabled" = "true" ] && [ -n "$current_path" ]; then
    expanded_path="${current_path/#\~/$HOME}"
    TARGETS+=("$expanded_path")
    TOOL_NAMES+=("$current_tool")
fi

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo "No tools enabled in config.yaml. Enable at least one tool."
    exit 1
fi

echo "Enabled tools:"
for i in "${!TOOL_NAMES[@]}"; do
    echo "  - ${TOOL_NAMES[$i]} (${TARGETS[$i]})"
done
echo ""

# Count skills (exclude _ prefixed folders)
skill_count=0
for d in "$SKILLS_DIR"/*/; do
    name=$(basename "$d")
    [[ "$name" == _* ]] && continue
    skill_count=$((skill_count + 1))
done
echo "Found $skill_count skills to sync"
echo ""

linked=0
skipped=0
errors=0

for skill_dir in "$SKILLS_DIR"/*/; do
    [ -d "$skill_dir" ] || continue
    skill_name=$(basename "$skill_dir")

    # Skip template/internal folders (prefixed with _)
    [[ "$skill_name" == _* ]] && continue

    for i in "${!TARGETS[@]}"; do
        target_dir="${TARGETS[$i]}"
        tool_name="${TOOL_NAMES[$i]}"
        dest="$target_dir/$skill_name"

        # Create target directory if it doesn't exist
        if [ ! -d "$target_dir" ]; then
            mkdir -p "$target_dir"
            echo "  Created: $target_dir"
        fi

        # If symlink already points to the right place, skip silently
        if [ -L "$dest" ]; then
            current_target=$(readlink "$dest")
            if [ "$current_target" = "$skill_dir" ] || [ "$current_target" = "${skill_dir%/}" ]; then
                skipped=$((skipped + 1))
                continue
            else
                echo "  SKIP: $skill_name in $tool_name (symlink exists pointing elsewhere)"
                skipped=$((skipped + 1))
                continue
            fi
        fi

        # If real folder exists, never touch it
        if [ -d "$dest" ]; then
            echo "  SKIP: $skill_name in $tool_name (real folder exists, not overwriting)"
            skipped=$((skipped + 1))
            continue
        fi

        # Create symlink
        if ln -s "${skill_dir%/}" "$dest" 2>/dev/null; then
            echo "  OK: $skill_name → $tool_name"
            linked=$((linked + 1))
        else
            echo "  FAIL: $skill_name → $tool_name"
            errors=$((errors + 1))
        fi
    done
done

echo ""
echo "Done!"
echo "  Linked: $linked"
echo "  Skipped: $skipped (already exist)"
if [ $errors -gt 0 ]; then
    echo "  Errors: $errors"
fi
echo ""
