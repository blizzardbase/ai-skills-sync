# AI Skills Sync

## What This Repo Is

A central repository for AI coding skills (SKILL.md files). Skills are symlinked from here to multiple AI tools (Claude Code, Cursor, Codex, OpenClaw, Conductor).

## Repo Structure

- `skills/` - Each subfolder is a skill containing a SKILL.md file
- `config.yaml` - User configuration: which tools are enabled and their paths
- `setup.sh` - Creates symlinks from skills/ to each enabled tool's directory
- `add-skill.sh` - Scaffolds a new skill folder and runs setup.sh

## Key Rules

- Never overwrite existing skill folders in tool directories
- Symlinks always point FROM the tool directory TO this repo
- Folders starting with `_` in skills/ are templates, not real skills — skip them
- config.yaml contains user-specific paths

## Skill Format

Every skill is a folder containing a SKILL.md with YAML frontmatter:

```
---
name: skill-name
description: One-line description
---

(Markdown instructions for the AI)
```

## Commands

- `./setup.sh` - Sync all skills to all enabled tools
- `./add-skill.sh <name> "<description>"` - Create a new skill and sync it
