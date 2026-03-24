---
name: _example
description: Template skill. Copy this folder to create a new skill, or use add-skill.sh.
tags: coding, template
tools: claude-code, cursor, codex, openclaw
---

# Example Skill

This is a template. It is not linked to any tool (the underscore prefix tells setup.sh to skip it).

## Frontmatter Fields

- **name**: Skill identifier (lowercase, hyphens allowed)
- **description**: One-line summary of what the skill does
- **tags**: Comma-separated categories (optional). Use `./list-skills.sh <tag>` to filter.
- **tools**: Comma-separated list of tools to sync to (optional). If omitted, syncs to all enabled tools.

## When to Use

Describe the situation where the AI should activate this skill. Be specific:
- "When the user asks to review a pull request"
- "When working with Python files that import Django"
- "Before any git push command"

## Instructions

Write clear instructions for the AI. Good instructions:

1. **State the goal.** What should the AI accomplish?
2. **List the steps.** What should it do, in order?
3. **Show examples.** What does good output look like?
4. **Set limits.** What should it NOT do?

### Example

> When reviewing code, check for:
> - SQL injection vulnerabilities
> - Hardcoded credentials
> - Missing input validation
>
> Format findings as a numbered list with severity (HIGH / MEDIUM / LOW).
> Do not rewrite the code. Only identify issues.
