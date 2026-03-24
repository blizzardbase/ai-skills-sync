#!/bin/bash
# list-skills.sh - List all skills with their descriptions
# Usage: ./list-skills.sh
# Usage: ./list-skills.sh --json        (JSON output)
# Usage: ./list-skills.sh <tag>         (filter by tag)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"
JSON_OUTPUT=false
FILTER_TAG=""

for arg in "$@"; do
    [ "$arg" = "--json" ] && JSON_OUTPUT=true
    [ "$arg" != "--json" ] && FILTER_TAG="$arg"
done

if [ -d "$SKILLS_DIR" ]; then
    :
else
    echo "Error: Skills folder not found at $SKILLS_DIR"
    exit 1
fi

get_description() {
    local skill_path="$1"
    if [ -f "$skill_path/SKILL.md" ]; then
        sed -n 's/^description: *//p' "$skill_path/SKILL.md" | head -1 | tr -d '"'
    fi
}

get_tags() {
    local skill_path="$1"
    if [ -f "$skill_path/SKILL.md" ]; then
        sed -n 's/^tags: *//p' "$skill_path/SKILL.md" | head -1
    fi
}

get_tools() {
    local skill_path="$1"
    if [ -f "$skill_path/SKILL.md" ]; then
        sed -n 's/^tools: *//p' "$skill_path/SKILL.md" | head -1
    fi
}

skills=()
for dir in "$SKILLS_DIR"/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    [[ "$name" == _* ]] && continue
    [ -f "$dir/SKILL.md" ] || continue
    
    tags=$(get_tags "$dir")
    
    if [ -n "$FILTER_TAG" ]; then
        if ! echo ",$tags," | tr -d ' ' | grep -q ",$FILTER_TAG,"; then
            continue
        fi
    fi
    
    desc=$(get_description "$dir")
    tools=$(get_tools "$dir")
    
    skills+=("$name|$desc|$tags|$tools")
done

if [ "$JSON_OUTPUT" = true ]; then
    echo "{"
    echo "  \"skills\": ["
    # Escape special characters for JSON
    json_escape() {
        echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
    }

    first=true
    for s in "${skills[@]}"; do
        name="${s%%|*}"
        rest="${s#*|}"
        desc="${rest%%|*}"
        rest="${rest#*|}"
        tags="${rest%%|*}"
        tools="${rest##*|}"

        [ "$first" = false ] && echo "    ,"
        echo "    {"
        echo "      \"name\": \"$(json_escape "$name")\","
        echo "      \"description\": \"$(json_escape "$desc")\","
        echo "      \"tags\": \"$(json_escape "$tags")\","
        echo "      \"tools\": \"$(json_escape "$tools")\""
        echo -n "    }"
        first=false
    done
    echo ""
    echo "  ]"
    echo "}"
else
    if [ -n "$FILTER_TAG" ]; then
        echo "Filtering by tag: $FILTER_TAG"
        echo ""
    fi
    printf "%-25s %-40s %-20s %s\n" "SKILL NAME" "DESCRIPTION" "TAGS" "TOOLS"
    printf "%s\n" "-----------------------------------------------------------------------------------------------------------"
    for s in "${skills[@]}"; do
        name="${s%%|*}"
        rest="${s#*|}"
        desc="${rest%%|*}"
        rest="${rest#*|}"
        tags="${rest%%|*}"
        tools="${rest##*|}"
        printf "%-25s %-40s %-20s %s\n" "$name" "$desc" "$tags" "$tools"
    done
    echo ""
    echo "Total: ${#skills[@]} skills"
    [ -n "$FILTER_TAG" ] && echo "(filtered from all skills)"
fi