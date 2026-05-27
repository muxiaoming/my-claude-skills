# Installation Guide

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- Git installed

---

## Option 1: Claude Code Auto Install (Recommended)

Just two steps — Claude handles the rest.

### Step 1: Clone the repository

```bash
git clone https://github.com/muxiaoming/my-claude-skills.git
```

### Step 2: Ask Claude Code to install the skill

In Claude Code, type:

```
Install the claude-notify skill from the my-claude-skills repo in the current directory
```

Claude will automatically:
- Copy scripts to `~/.claude/`
- Detect your operating system
- Install dependencies (e.g., BurntToast on Windows)
- Configure hooks in `settings.json`
- Verify the configuration

### Step 3: Restart Claude Code

Restart Claude Code to activate notifications.

---

## Option 2: Conversational Setup (Pre-installed Skills)

If you already installed a skill via `claude skill install`, just tell Claude:

```
Set up desktop notifications for me
```

Claude reads the skill definition and runs all configuration steps automatically.

---

## Option 3: Manual Install (Fallback)

If automatic methods are not available, follow the manual steps below.

### Windows

1. Install the BurntToast PowerShell module:

```powershell
Install-Module BurntToast -Scope CurrentUser -Force
```

2. Copy the script to your Claude config directory:

```powershell
Copy-Item "skills/claude-notify/scripts/toast.ps1" "$env:USERPROFILE\.claude\toast.ps1"
```

3. Add hooks to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<YOUR_USERNAME>\\.claude\\toast.ps1' -Type Notification",
            "type": "command"
          }
        ]
      }
    ],
    "PermissionDenied": [
      {
        "hooks": [
          {
            "command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<YOUR_USERNAME>\\.claude\\toast.ps1' -Type PermissionDenied",
            "type": "command"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<YOUR_USERNAME>\\.claude\\toast.ps1' -Type Stop",
            "type": "command"
          }
        ]
      }
    ]
  }
}
```

Replace `<YOUR_USERNAME>` with your Windows username.

4. Restart Claude Code to activate notifications.

### macOS

1. Copy the script and make it executable:

```bash
cp skills/claude-notify/scripts/notify.sh ~/.claude/notify.sh
chmod +x ~/.claude/notify.sh
```

2. Add hooks to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "command": "bash ~/.claude/notify.sh Notification",
            "type": "command"
          }
        ]
      }
    ],
    "PermissionDenied": [
      {
        "hooks": [
          {
            "command": "bash ~/.claude/notify.sh PermissionDenied",
            "type": "command"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "command": "bash ~/.claude/notify.sh Stop",
            "type": "command"
          }
        ]
      }
    ]
  }
}
```

3. Restart Claude Code to activate notifications.

---

## FAQ

**Q: Notifications not showing on Windows?**
A: Make sure BurntToast is installed (`Get-Module -ListAvailable BurntToast`) and PowerShell execution policy allows running scripts.

**Q: How do I uninstall notifications?**
A: Remove the hooks from `~/.claude/settings.json` and delete the script file from `~/.claude/`.

**Q: Claude didn't auto-configure after installing the skill?**
A: Make sure you explicitly told Claude "set up desktop notifications" — Claude needs this prompt to run the configuration flow.
