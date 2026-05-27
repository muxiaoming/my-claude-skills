# 安装指南

## 前置条件

- 已安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- 已安装 Git

---

## 方式一：Claude Code 自动安装（推荐）

只需两步，剩下的 Claude 全部搞定。

### 第 1 步：克隆仓库

```bash
git clone https://github.com/muxiaoming/my-claude-skills.git
```

### 第 2 步：告诉 Claude Code 安装技能

在 Claude Code 中输入：

```
帮我安装 my-claude-skills 仓库里的 claude-notify 技能，仓库在当前目录下
```

Claude 会自动完成：
- 复制脚本到 `~/.claude/`
- 检测你的操作系统
- 安装依赖（如 Windows 的 BurntToast）
- 配置 `settings.json` 中的 hooks
- 验证配置是否正确

### 第 3 步：重启 Claude Code

安装完成后重启 Claude Code，通知功能即可生效。

---

## 方式二：对话式配置（已有技能）

如果你已经通过 `claude skill install` 安装了技能，直接告诉 Claude：

```
帮我配置桌面通知
```

或者：

```
我要设置 toast notification
```

Claude 会读取技能定义，自动执行所有配置步骤。

---

## 方式三：手动安装（备选）

如果自动方式不可用，可以手动操作。

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

---

## 常见问题

**Q: Windows 上通知不显示？**
A: 确认 BurntToast 已安装（`Get-Module -ListAvailable BurntToast`），并检查 PowerShell 执行策略是否允许运行脚本。

**Q: 如何卸载通知功能？**
A: 从 `~/.claude/settings.json` 中删除对应的 hooks 配置，然后删除 `~/.claude/` 下的脚本文件。

**Q: 安装技能后 Claude 没有自动配置？**
A: 确认在 Claude Code 中明确说了"帮我配置桌面通知"，Claude 需要这个指令才会执行配置流程。
