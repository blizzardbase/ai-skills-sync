# AI Skills Sync

Keep your AI coding skills in one place. Use them everywhere.

## The Problem

You use multiple AI coding tools — Claude Code, Cursor, Codex, OpenClaw, Conductor. Each one supports "skills" (a folder with a `SKILL.md` file). But you end up with copies scattered across your machine:

```
~/.claude/skills/code-review/SKILL.md
~/.cursor/skills/code-review/SKILL.md
~/.codex/skills/code-review/SKILL.md
~/clawd/skills/code-review/SKILL.md
```

Same skill, four copies. Update one, forget the others. They drift apart.

## The Solution

Store all your skills in this one repo. Symlink them to every tool.

```
~/ai-skills-sync/skills/code-review/SKILL.md   (the real file)
        |
        ├── symlink → ~/.claude/skills/code-review
        ├── symlink → ~/.cursor/skills/code-review
        ├── symlink → ~/.codex/skills/code-review
        └── symlink → ~/clawd/skills/code-review
```

Edit once, every tool sees the change instantly. No sync script to run after edits — symlinks mean every tool reads the same file.

## How It Works

Every AI coding tool that supports skills uses the same format:

```
skills/
  my-skill/
    SKILL.md        ← YAML frontmatter + instructions
```

The `SKILL.md` file looks like this:

```markdown
---
name: my-skill
description: What this skill does, in one sentence.
---

# My Skill

## When to Use

Describe when the AI should activate this skill.

## Instructions

The actual instructions for the AI.
```

Because the format is the same across tools, a symlink is all you need. No conversion, no adapters, no build step.

## Setup

### 1. Fork and clone this repo

Fork this repo (keep it private if your skills contain sensitive instructions), then clone it:

```bash
git clone https://github.com/YOUR-USERNAME/ai-skills-sync.git ~/ai-skills-sync
cd ~/ai-skills-sync
```

### 2. Edit the config

Open `config.yaml` and enable the tools you use. Set the correct paths for your machine.

```yaml
tools:
  claude-code:
    enabled: true
    path: ~/.claude/skills

  cursor:
    enabled: true
    path: ~/.cursor/skills

  codex:
    enabled: false
    path: ~/.codex/skills

  openclaw:
    enabled: false
    path: ~/clawd/skills
```

Only enable the tools you actually have installed.

### 3. Run setup

```bash
./setup.sh
```

This will:
- Read your `config.yaml`
- Create the skills directories for each enabled tool (if they don't exist)
- Symlink every skill folder to every enabled tool
- Never overwrite existing folders or files

Safe to run multiple times. It only creates new links.

### 4. Verify

Check that your tools can see the skills:

```bash
ls -la ~/.claude/skills/
```

You should see symlinks pointing back to this repo.

## Adding a New Skill

```bash
./add-skill.sh my-skill-name "Short description of what it does" "coding,security"
```

This will:
1. Create `skills/my-skill-name/SKILL.md` with a template
2. Symlink it to all your enabled tools
3. You then edit the `SKILL.md` to add your actual instructions

The optional third argument adds tags for filtering.

## Managing Skills

### List all skills

```bash
./list-skills.sh
./list-skills.sh coding        # filter by tag
./list-skills.sh --json        # JSON output
```

### Check health

```bash
./status.sh
```

Shows enabled tools, skill count, symlinks, and any broken links.

### Remove a skill

```bash
./remove-skill.sh my-skill-name
```

Removes the skill folder and cleans up symlinks from all tools.

### Import a skill

```bash
./import-skill.sh ~/path/to/skill          # local folder
./import-skill.sh https://raw.githubusercontent.com/user/repo/main/skills/code-review/SKILL.md code-review
```

### Dry run

```bash
./setup.sh --dry-run
```

Preview what setup would do without making changes.

## Selective Sync

By default, each skill syncs to all enabled tools. To restrict a skill to specific tools, add a `tools` field in the skill's frontmatter:

```yaml
---
name: cursor-only-skill
description: Something for Cursor only
tools: cursor
---
```

The skill will only be linked to Cursor, even if Claude Code is enabled in config.yaml.

## SKILL.md Frontmatter

```yaml
---
name: my-skill
description: What this skill does in one sentence
tags: coding, security        # optional: for filtering
tools: claude-code, cursor    # optional: restrict which tools get this skill
---
```

## Multi-Machine Workflow

Since this is a Git repo, you can sync skills across machines:

**On your main machine:**
```bash
# Edit or add skills, then push
cd ~/ai-skills-sync
git add -A && git commit -m "Add new skill" && git push
```

**On another machine:**
```bash
# Pull the latest and create any new symlinks
cd ~/ai-skills-sync
git pull
./setup.sh
```

**On the go (no machine at all):**
1. Edit skills directly on GitHub
2. When you're back, `git pull` and `./setup.sh`

## Writing Good Skills

A skill is just a markdown file with instructions for the AI. Some tips:

- **Be specific.** "Review code for SQL injection vulnerabilities" is better than "Review code."
- **Include examples.** Show the AI what good output looks like.
- **Set boundaries.** Tell the AI what NOT to do, not just what to do.
- **One job per skill.** A skill that does five things will do none of them well.

## Supported Tools

| Tool | Default Skills Path | Notes |
|------|-------------------|-------|
| Claude Code | `~/.claude/skills/` | Also used by Conductor |
| Cursor | `~/.cursor/skills/` | Separate from Cursor's built-in plugins |
| Codex | `~/.codex/skills/` | Avoid the `.system/` subfolder |
| OpenClaw / Clawd | `~/clawd/skills/` | Path varies by setup |

All of these use the same `SKILL.md` format with YAML frontmatter.

## Repo Structure

```
ai-skills-sync/
├── README.md          ← You're reading it
├── CLAUDE.md          ← Context for Claude Code sessions
├── config.yaml        ← Which tools you use and their paths
├── setup.sh           ← Creates symlinks to all tools
├── add-skill.sh       ← Scaffolds a new skill + symlinks it
├── remove-skill.sh    ← Removes a skill and cleans symlinks
├── list-skills.sh     ← Lists all skills with descriptions
├── status.sh         ← Shows health check
├── import-skill.sh   ← Imports skill from path or URL
├── .gitignore
└── skills/
    └── _example/      ← Template skill (not linked to tools)
        └── SKILL.md
```

## FAQ

**Will this break my existing skills?**
No. The setup script never overwrites existing folders. If a skill folder already exists in a tool's directory, it is skipped.

**What if I remove a skill from this repo?**
The symlinks in your tool directories will become "broken" (point to nothing). The tools will ignore them. To clean up broken symlinks, run `./setup.sh --prune`.

**Can I have tool-specific skills that aren't synced?**
Yes. Just put them directly in the tool's skills folder (not as symlinks). The setup script will see the real folder and skip it.

**Does this work on Linux?**
Yes. Symlinks work the same way. Just update the paths in `config.yaml`.

**Does this work on Windows?**
Not out of the box. Windows symlinks require administrator privileges and work differently. WSL (Windows Subsystem for Linux) would work.

**What about plugin-managed skills?**
Tools like Cursor and Claude Code have their own plugin systems with managed skills. Those live in separate directories (like `~/.cursor/plugins/`). This repo doesn't touch those — it only writes to the skills directories listed in your config.

## License

MIT
