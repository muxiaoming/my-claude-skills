[中文](README-zh.md) | English

# My Claude Skills

A collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Available Skills

| Skill | Description | Platforms |
|-------|-------------|-----------|
| [claude-notify](skills/claude-notify/) | Desktop toast notifications for Claude Code events (Notification, PermissionDenied, Stop) | Windows 10/11, macOS |

## Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/<your-username>/my-claude-skills.git

# Install a skill
claude skill install ./my-claude-skills/skills/claude-notify
```

### Manual Install

See [Installation Guide](docs/installation.md) for detailed setup instructions.

## Documentation

- [Installation Guide](docs/installation.md) - Step-by-step setup for each skill

## Creating Your Own Skills

Each skill follows this structure:

```
skill-name/
├── SKILL.md          # Required: skill definition with YAML frontmatter
└── scripts/          # Optional: executable scripts
```

The `SKILL.md` file must include frontmatter with `name` and `description` fields:

```markdown
---
name: my-skill
description: What this skill does and when to trigger it.
---

# Instructions here...
```

## License

[MIT](LICENSE)
