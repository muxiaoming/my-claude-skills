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
│   ├── claude-notify/               # Desktop notification skill
│   │   ├── SKILL.md                 # Skill definition
│   │   └── scripts/
│   │       ├── toast.ps1            # Windows notification script
│   │       └── notify.sh            # macOS notification script
│   │
│   └── spring-ai-langfuse3/         # Spring AI + Langfuse 3 集成
│       └── SKILL.md                 # 集成指南（依赖配置、OTel 最佳实践、常见问题排查）
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
| [spring-ai-langfuse3](skills/spring-ai-langfuse3/) | Spring AI + Langfuse 3 observability integration with automatic version discovery, OTel best practices, and JDBC conflict resolution. Based on [official Langfuse docs](https://langfuse.com/integrations/frameworks/spring-ai) | Cross-platform (JVM) |

---

## Quick Install

Just copy and paste the prompt below to Claude Code, and it will handle everything automatically — **no manual steps, no git required**.

**For claude-notify:**

```
Install the claude-notify skill from https://github.com/muxiaoming/my-claude-skills.git
```

**For spring-ai-langfuse3:**

```
Install the spring-ai-langfuse3 skill from https://github.com/muxiaoming/my-claude-skills.git
```

Claude automatically:
- Downloads all files needed for the skill
- Installs the skill to `~/.claude/skills/`
- Configures any dependencies or hooks
- Verifies the installation

**No repo cloning, no manual setup — just provide the URL and Claude handles everything.**

---

## Documentation

| Document | Description |
|----------|-------------|
| [Installation Guide](docs/installation.md) | Detailed troubleshooting and manual fallback |
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
