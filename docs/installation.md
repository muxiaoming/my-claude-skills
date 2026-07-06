# Installation Guide

## Quick Install (Recommended)

The fastest way to install any skill is to copy and paste a prompt to Claude Code. **No git required** — Claude automatically detects your setup and adapts.

### Install claude-notify

Copy and paste this to Claude Code:

```
Install the claude-notify skill from https://github.com/muxiaoming/my-claude-skills.git
```

### Install spring-ai-langfuse3

Copy and paste this to Claude Code:

```
Install the spring-ai-langfuse3 skill from https://github.com/muxiaoming/my-claude-skills.git
```

Claude automatically:
1. Downloads all files needed for the skill
2. Installs the skill to `~/.claude/skills/`
3. Configures any dependencies or hooks
4. Verifies the installation

**No repo cloning, no manual setup** — Claude handles everything transparently.

---

## How It Works Under the Hood

Claude automatically downloads only the specific files needed for each skill — no need to clone the entire repository.

**What Claude downloads for each skill:**
- `SKILL.md` — the skill definition
- Required scripts (if any)
- Configuration files

**Installation location:**
```bash
~/.claude/skills/<skill-name>/
```

The entire process is automatic — you just provide the repository URL and Claude handles the rest.

---

## What If Automatic Installation Fails?

If the automatic installation doesn't work, here are common troubleshooting steps:

### Check Your Claude Code Version

Ensure you're running a recent version of Claude Code. Update with:

```bash
claude update
```

### Manually Clone and Install (if you have git)

```bash
git clone https://github.com/muxiaoming/my-claude-skills.git
cd my-claude-skills
claude skill install ./skills/claude-notify
# or
claude skill install ./skills/spring-ai-langfuse3
```

### Manual Configuration (Fallback)

If automatic methods don't work, see the detailed manual installation steps in the skill's `SKILL.md` file.

---

## Skill-Specific Troubleshooting

### claude-notify

**Q: Notifications not showing on Windows?**
A: Ensure BurntToast PowerShell module is installed:
```powershell
Install-Module BurntToast -Scope CurrentUser -Force
```

**Q: Notifications not showing on macOS?**
A: Ensure the notification script is executable:
```bash
chmod +x ~/.claude/notify.sh
```

**Q: Claude didn't auto-configure after installing the skill?**
A: Tell Claude explicitly: "set up desktop notifications". Claude needs this instruction to run the configuration flow.

### spring-ai-langfuse3

**Q: What Langfuse version is required?**
A: Langfuse >= v3.22.0 is required for OTEL endpoint support.

**Q: Getting version conflicts with OpenTelemetry?**
A: Follow the JDBC + OTel version conflict troubleshooting in the skill's SKILL.md. The skill includes detailed Maven exclusion configurations.

**Q: How do I verify the setup works?**
A: After configuration, run the verification commands in the skill's SKILL.md section 7 (Verification).

---

## Uninstalling a Skill

To remove an installed skill:

```bash
claude skill uninstall claude-notify
# or
claude skill uninstall spring-ai-langfuse3
```

Or manually delete the skill directory:
```bash
rm -rf ~/.claude/skills/claude-notify
rm -rf ~/.claude/skills/spring-ai-langfuse3
```

If the skill configured hooks, remove them from `~/.claude/settings.json` as well.
