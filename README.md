[中文](README-zh.md) | English

# My Claude Skills

A collection of custom skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code), ready to use.

---

## Repository Structure

```
my-claude-skills/
│
├── README.md                        # English
├── README-zh.md                     # Chinese
├── LICENSE                          # MIT License
│
├── skills/                          # Skills directory
│   └── claude-notify/               # Desktop notification skill
│       ├── SKILL.md                 # Skill definition
│       └── scripts/
│           ├── toast.ps1            # Windows notification script
│           └── notify.sh            # macOS notification script
│
└── docs/                            # Documentation
    ├── installation.md              # Installation guide (English)
    ├── installation-zh.md           # Installation guide (Chinese)
    ├── github-connection-zh.md      # Claude Code + GitHub setup (Chinese)
    └── skill-creation-zh.md         # Skill creation guide (Chinese)
```

---

## Available Skills

| Skill | Description | Platforms |
|-------|-------------|-----------|
| [claude-notify](skills/claude-notify/) | Desktop toast notifications for Claude Code events (Notification, PermissionDenied, Stop) | Windows 10/11, macOS |

---

## Quick Install

### Option 1: Ask Claude Code (Easiest)

Clone the repo, then just say:

```
Install the claude-notify skill from the my-claude-skills repo
```

Claude handles everything automatically.

### Option 2: Command Line

```bash
git clone https://github.com/muxiaoming/my-claude-skills.git
claude skill install ./my-claude-skills/skills/claude-notify
```

Then tell Claude "set up desktop notifications" to auto-configure.

### Option 3: Manual Install

See [Installation Guide](docs/installation.md).

---

## Documentation

| Document | Description |
|----------|-------------|
| [Installation Guide](docs/installation.md) | Step-by-step setup for each skill (Windows & macOS) |
| [Claude Code + GitHub](docs/github-connection-zh.md) | How to set up GitHub CLI, create repos, and push code |
| [Skill Creation Guide](docs/skill-creation-zh.md) | How to create your own Claude Code skills |

---

## Creating Your Own Skills

Each skill is a directory with at minimum a `SKILL.md` file:

```
my-skill/
├── SKILL.md              # Required: skill definition
└── scripts/              # Optional: executable scripts
```

Basic `SKILL.md` format:

```markdown
---
name: my-skill
description: What this skill does and when to trigger it.
---

# Instructions

Detailed steps...
```

For a full tutorial, see [Skill Creation Guide](docs/skill-creation-zh.md).

---

## License

[MIT](LICENSE) - Free to use, modify, and distribute.
