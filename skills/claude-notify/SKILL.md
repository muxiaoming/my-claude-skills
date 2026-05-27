---
name: claude-notify
description: Configure desktop toast notifications for Claude Code hooks on Windows and macOS. Triggers when user asks to setup notifications, enable toast, configure alerts, or mentions "桌面通知", "通知配置", "toast notification setup".
---

# Claude Notify

Configure desktop notifications for Claude Code events (Notification, PermissionDenied, Stop).

## Supported Platforms

| Platform | Method | Dependencies |
|----------|--------|-------------|
| Windows 10/11 | BurntToast PowerShell module | `Install-Module BurntToast -Scope CurrentUser` |
| macOS | osascript (built-in) | None |

## Setup Steps

### 1. Detect Platform

```bash
# Check OS
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
  PLATFORM="windows"
elif [[ "$(uname)" == "Darwin" ]]; then
  PLATFORM="macos"
fi
```

### 2. Install Dependencies (Windows only)

```powershell
Install-Module BurntToast -Scope CurrentUser -Force
```

### 3. Deploy Scripts

Copy the scripts from this skill's `scripts/` directory to `~/.claude/`:

- **Windows**: `scripts/toast.ps1` → `~/.claude/toast.ps1`
- **macOS**: `scripts/notify.sh` → `~/.claude/notify.sh` (chmod +x)

### 4. Configure Hooks

Update `~/.claude/settings.json` with the appropriate hooks for the detected platform.

**Windows hooks:**
```json
"hooks": {
  "Notification": [{"hooks": [{"command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<USER>\\.claude\\toast.ps1' -Type Notification", "type": "command"}]}],
  "PermissionDenied": [{"hooks": [{"command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<USER>\\.claude\\toast.ps1' -Type PermissionDenied", "type": "command"}]}],
  "Stop": [{"hooks": [{"command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<USER>\\.claude\\toast.ps1' -Type Stop", "type": "command"}]}]
}
```

**macOS hooks:**
```json
"hooks": {
  "Notification": [{"hooks": [{"command": "bash ~/.claude/notify.sh Notification", "type": "command"}]}],
  "PermissionDenied": [{"hooks": [{"command": "bash ~/.claude/notify.sh PermissionDenied", "type": "command"}]}],
  "Stop": [{"hooks": [{"command": "bash ~/.claude/notify.sh Stop", "type": "command"}]}]
}
```

### 5. Verify

Ask the user to restart Claude Code, then trigger a notification to confirm it works.

## Post-Setup

After successful configuration, inform the user:

> Notification setup complete!
>
> You can optionally delete this skill to save ~30 tokens of context. It will NOT affect your notifications.
> Delete this skill?

If user confirms deletion, remove the `~/.claude/skills/claude-notify/` directory.

## Notification Content

All platforms show the same info:
- **Title**: `[ProjectName] Claude Waiting / Permission Needed / Claude Done`
- **Body**: Dir, Branch, Model (3 lines)
