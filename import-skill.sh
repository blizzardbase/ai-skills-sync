#!/bin/bash
# import-skill.sh - Import a skill from a path or URL
# Usage: ./import-skill.sh <source-path-or-url> [skill-name]
# Example: ./import-skill.sh ~/my-skills/code-review
# Example: ./import-skill.sh https://github.com/user/repo/blob/main/skills/code-review/SKILL.md code-review
# Example: ./import-skill.sh https://raw.githubusercontent.com/user/repo/main/skills/code-review/SKILL.md

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

if [ $# -lt 1 ]; then
    echo "Usage: import-skill.sh <source-path-or-url> [skill-name]"
    echo ""
    echo "Arguments:"
    echo "  source-path-or-url  - Local path, GitHub raw URL, or GitHub repo URL"
    echo "  skill-name          - Optional name for the skill (default: derived from URL/path)"
    echo ""
    echo "Examples:"
    echo "  ./import-skill.sh ~/my-skills/code-review"
    echo "  ./import-skill.sh https://raw.githubusercontent.com/user/repo/main/skills/code-review/SKILL.md"
    echo "  ./import-skill.sh github:user/repo/path/to/skills/code-review"
    exit 1
fi

SOURCE="$1"
SKILL_NAME="$2"

# Determine the skill name
if [ -z "$SKILL_NAME" ]; then
    if [[ "$SOURCE" =~ github\.com ]]; then
        # Extract repo and path from GitHub URL
        if [[ "$SOURCE" =~ github\.com/([^/]+)/([^/]+)/blob/([^/]+)/skills/([^/]+) ]]; then
            SKILL_NAME="${BASH_REMATCH[4]}"
        elif [[ "$SOURCE" =~ github\.com/([^/]+)/([^/]+)/raw/([^/]+)/skills/([^/]+) ]]; then
            SKILL_NAME="${BASH_REMATCH[4]}"
        else
            echo "Error: Could not determine skill name from GitHub URL"
            echo "Please provide skill name as second argument"
            exit 1
        fi
    else
        # Use basename of the path
        SKILL_NAME=$(basename "$SOURCE")
        [[ "$SKILL_NAME" == "SKILL.md" ]] && SKILL_NAME=$(basename "$(dirname "$SOURCE")")
    fi
fi

# Validate skill name
if [[ ! "$SKILL_NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    echo "Error: Invalid skill name '$SKILL_NAME'"
    echo "Use only lowercase letters, numbers, and hyphens"
    exit 1
fi

SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

if [ -d "$SKILL_DIR" ]; then
    echo "Error: Skill '$SKILL_NAME' already exists at $SKILL_DIR"
    exit 1
fi

echo "Importing skill: $SKILL_NAME"
echo "  From: $SOURCE"
echo ""

# Create skill directory
mkdir -p "$SKILL_DIR"

# Handle different source types
if [[ "$SOURCE" =~ ^https?:// ]]; then
    # Web URL
    if [[ "$SOURCE" =~ raw\.githubusercontent\.com ]] || [[ "$SOURCE" =~ gist\.github\.com ]]; then
        # Direct raw file URL
        curl -sfL "$SOURCE" > "$SKILL_DIR/SKILL.md"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to download from URL"
            rm -rf "$SKILL_DIR"
            exit 1
        fi
    else
        echo "Error: Only raw URLs are supported directly"
        echo "Use raw.githubusercontent.com or gist.github.com URLs"
        rm -rf "$SKILL_DIR"
        exit 1
    fi
elif [ -f "$SOURCE" ]; then
    # Local file
    cp "$SOURCE" "$SKILL_DIR/SKILL.md"
elif [ -d "$SOURCE" ]; then
    # Local folder - copy all contents
    if [ -f "$SOURCE/SKILL.md" ]; then
        cp -R "$SOURCE"/. "$SKILL_DIR/"
    else
        echo "Error: No SKILL.md found in $SOURCE"
        rm -rf "$SKILL_DIR"
        exit 1
    fi
else
    echo "Error: Source not found: $SOURCE"
    exit 1
fi

echo "Created: $SKILL_DIR/SKILL.md"
echo ""

# Run setup.sh to create symlinks
"$SCRIPT_DIR/setup.sh"