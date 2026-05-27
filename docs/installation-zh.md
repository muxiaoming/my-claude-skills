# 安装指南

## 前置条件

- 已安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- 已安装 Git

## claude-notify

Claude Code 桌面通知，在等待确认、权限被拒、任务完成时弹出系统通知。

### Windows

1. 安装 BurntToast PowerShell 模块：

```powershell
Install-Module BurntToast -Scope CurrentUser -Force
```

2. 复制脚本到 Claude 配置目录：

```powershell
Copy-Item "skills/claude-notify/scripts/toast.ps1" "$env:USERPROFILE\.claude\toast.ps1"
```

3. 在 `~/.claude/settings.json` 中添加 hooks：

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<你的用户名>\\.claude\\toast.ps1' -Type Notification",
            "type": "command"
          }
        ]
      }
    ],
    "PermissionDenied": [
      {
        "hooks": [
          {
            "command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<你的用户名>\\.claude\\toast.ps1' -Type PermissionDenied",
            "type": "command"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "command": "powershell -ExecutionPolicy Bypass -File 'C:\\Users\\<你的用户名>\\.claude\\toast.ps1' -Type Stop",
            "type": "command"
          }
        ]
      }
    ]
  }
}
```

将 `<你的用户名>` 替换为你的 Windows 用户名。

4. 重启 Claude Code 使通知生效。

### macOS

1. 复制脚本并添加执行权限：

```bash
cp skills/claude-notify/scripts/notify.sh ~/.claude/notify.sh
chmod +x ~/.claude/notify.sh
```

2. 在 `~/.claude/settings.json` 中添加 hooks：

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

3. 重启 Claude Code 使通知生效。

## 常见问题

**Q: Windows 上通知不显示？**
A: 确认 BurntToast 已安装（`Get-Module -ListAvailable BurntToast`），并检查 PowerShell 执行策略是否允许运行脚本。

**Q: 如何卸载通知功能？**
A: 从 `~/.claude/settings.json` 中删除对应的 hooks 配置，然后删除 `~/.claude/` 下的脚本文件。
