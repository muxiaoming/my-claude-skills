# Installation Guide

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- Git installed

## claude-notify

Desktop toast notifications for Claude Code events on Windows and macOS.

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

## FAQ

**Q: Notifications not showing on Windows?**
A: Make sure BurntToast is installed (`Get-Module -ListAvailable BurntToast`) and PowerShell execution policy allows running scripts.

**Q: How do I uninstall a skill's notifications?**
A: Remove the hooks from `~/.claude/settings.json` and delete the script file from `~/.claude/`.
