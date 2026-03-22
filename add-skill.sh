#!/bin/bash
# add-skill.sh - Create a new skill and symlink it to all enabled tools
# Usage: ./add-skill.sh <skill-name> "<description>"
# Example: ./add-skill.sh code-review "Review code for quality and security issues"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/skills"

if [ $# -lt 1 ]; then
    echo "Usage: add-skill.sh <skill-name> [description]"
    echo "Example: add-skill.sh code-review \"Review code for quality and security\""
    exit 1
fi

SKILL_NAME="$1"
DESCRIPTION="${2:-A new skill.}"
SKILL_DIR="$SKILLS_DIR/$SKILL_NAME"

# Validate skill name: lowercase letters, numbers, and hyphens only
if [[ ! "$SKILL_NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    echo "Error: Skill name must use only lowercase letters, numbers, and hyphens."
    echo "Example: code-review, git-safety, my-skill-1"
    exit 1
fi

# Check if skill already exists
if [ -d "$SKILL_DIR" ]; then
    echo "Error: Skill '$SKILL_NAME' already exists at $SKILL_DIR"
    exit 1
fi

# Create skill folder and SKILL.md
mkdir -p "$SKILL_DIR"
# Escape description for safe YAML (wrap in quotes if it contains special chars)
SAFE_DESC="$DESCRIPTION"
if echo "$DESCRIPTION" | grep -qE '[:"{}[\]|>&*!%@#]'; then
    SAFE_DESC="\"$(echo "$DESCRIPTION" | sed 's/"/\\"/g')\""
fi

cat > "$SKILL_DIR/SKILL.md" << EOF
---
name: $SKILL_NAME
description: $SAFE_DESC
---

# $SKILL_NAME

## When to Use

(Describe when this skill should be activated)

## Instructions

(Add the skill instructions here)
EOF

echo "Created: $SKILL_DIR/SKILL.md"
echo ""

# Run setup.sh to create symlinks
"$SCRIPT_DIR/setup.sh"
