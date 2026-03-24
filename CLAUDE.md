# AI Skills Sync

## What This Repo Is

A central repository for AI coding skills (SKILL.md files). Skills are symlinked from here to multiple AI tools (Claude Code, Cursor, Codex, OpenClaw, Conductor).

## Repo Structure

- `skills/` - Each subfolder is a skill containing a SKILL.md file
- `config.yaml` - User configuration: which tools are enabled and their paths
- `setup.sh` - Creates symlinks from skills/ to each enabled tool's directory
- `add-skill.sh` - Scaffolds a new skill folder and runs setup.sh
- `remove-skill.sh` - Removes a skill and cleans up its symlinks
- `list-skills.sh` - Lists all skills with descriptions (supports --json and tag filtering)
- `status.sh` - Health check: shows enabled tools, skill count, broken symlinks
- `import-skill.sh` - Imports a skill from a local path or URL

## Key Rules

- Never overwrite existing skill folders in tool directories
- Symlinks always point FROM the tool directory TO this repo
- Folders starting with `_` in skills/ are templates, not real skills — skip them
- config.yaml contains user-specific paths
- SKILL.md frontmatter can include `tags:` (for filtering) and `tools:` (for selective sync)

## Skill Format

Every skill is a folder containing a SKILL.md with YAML frontmatter:

```
---
name: skill-name
description: One-line description
tags: coding, security
tools: claude-code, cursor
---

(Markdown instructions for the AI)
```

## Commands

- `./setup.sh` - Sync all skills to all enabled tools
- `./setup.sh --dry-run` - Preview what would happen
- `./setup.sh --prune` - Clean up broken symlinks
- `./add-skill.sh <name> "<description>" [tags]` - Create a new skill and sync it
- `./remove-skill.sh <name>` - Remove a skill and clean symlinks
- `./list-skills.sh [tag]` - List skills (filter by tag)
- `./status.sh` - Show health check
