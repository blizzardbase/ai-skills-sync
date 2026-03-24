#!/bin/bash
# status.sh - Show health at a glance
# Usage: ./status.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

echo ""
echo "AI Skills Sync - Status"
echo "======================="
echo ""

echo "=== Config ==="
enabled_tools=()
tool_paths=()

current_tool=""
current_enabled=""
current_path=""

while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if echo "$line" | grep -qE '^  [a-z].*:$'; then
        if [ "$current_enabled" = "true" ] && [ -n "$current_path" ]; then
            expanded_path="${current_path/#\~/$HOME}"
            enabled_tools+=("$current_tool")
            tool_paths+=("$expanded_path")
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

if [ "$current_enabled" = "true" ] && [ -n "$current_path" ]; then
    expanded_path="${current_path/#\~/$HOME}"
    enabled_tools+=("$current_tool")
    tool_paths+=("$expanded_path")
fi

if [ ${#enabled_tools[@]} -eq 0 ]; then
    echo "  No tools enabled. Edit config.yaml and run setup.sh"
else
    echo "  Enabled tools: ${enabled_tools[*]}"
fi
echo ""

echo "=== Skills ==="
skill_count=0
invalid_count=0
for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    [[ "$name" == _* ]] && continue
    
    if [ -f "$dir/SKILL.md" ]; then
        skill_count=$((skill_count + 1))
    else
        echo "  WARNING: $name has no SKILL.md"
        invalid_count=$((invalid_count + 1))
    fi
done

echo "  Total skills: $skill_count"
[ $invalid_count -gt 0 ] && echo "  Invalid (no SKILL.md): $invalid_count"
echo ""

echo "=== Symlinks ==="
total_links=0
broken_links=0

for i in "${!tool_paths[@]}"; do
    tool_path="${tool_paths[$i]}"
    tool_name="${enabled_tools[$i]}"
    
    if [ ! -d "$tool_path" ]; then
        echo "  $tool_name: directory not found (run setup.sh)"
        continue
    fi
    
    link_count=0
    broken_count=0
    for entry in "$tool_path"/*; do
        [ -e "$entry" ] || [ -L "$entry" ] || continue
        if [ -L "$entry" ]; then
            link_count=$((link_count + 1))
            if [ ! -e "$entry" ]; then
                broken_count=$((broken_count + 1))
                echo "  BROKEN: $tool_name/$(basename "$entry")"
            fi
        fi
    done
    
    total_links=$((total_links + link_count))
    broken_links=$((broken_links + broken_count))
    
    echo "  $tool_name: $link_count symlinks"
    [ $broken_count -gt 0 ] && echo "    (broken: $broken_count)"
done

echo ""
echo "Summary"
echo "-------"
echo "  Skills: $skill_count"
echo "  Tools: ${#enabled_tools[@]}"
echo "  Symlinks: $total_links"
[ $broken_links -gt 0 ] && echo "  Broken: $broken_links" || echo "  Broken: 0"
echo ""

if [ $broken_links -gt 0 ]; then
    echo "Run ./setup.sh --prune to clean up broken symlinks"
fi