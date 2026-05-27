[English](README.md) | 中文

# My Claude Skills

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) 自定义技能集合，开箱即用。

---

## 仓库结构

```
my-claude-skills/
│
├── README.md                        # 英文版说明
├── README-zh.md                     # 中文版说明（本文件）
├── LICENSE                          # MIT 许可证
│
├── skills/                          # 技能目录
│   └── claude-notify/               # 桌面通知技能
│       ├── SKILL.md                 # 技能定义
│       └── scripts/
│           ├── toast.ps1            # Windows 通知脚本
│           └── notify.sh            # macOS 通知脚本
│
└── docs/                            # 文档目录
    ├── installation.md              # 安装指南（英文）
    ├── installation-zh.md           # 安装指南（中文）
    ├── github-connection-zh.md      # Claude Code 连接 GitHub（中文）
    └── skill-creation-zh.md         # Skill 创建指南（中文）
```

---

## 可用技能

| 技能 | 说明 | 平台 |
|------|------|------|
| [claude-notify](skills/claude-notify/) | Claude Code 桌面通知：等待确认、权限被拒、任务完成时弹出系统通知 | Windows 10/11、macOS |

---

## 快速安装

### 安装单个技能

```bash
# 克隆仓库
git clone https://github.com/muxiaoming/my-claude-skills.git

# 安装 claude-notify
claude skill install ./my-claude-skills/skills/claude-notify
```

### 手动安装

如果你不想用 `claude skill install`，可以手动复制文件。详见 [安装指南](docs/installation-zh.md)。

---

## 文档索引

| 文档 | 说明 |
|------|------|
| [安装指南](docs/installation-zh.md) | 各技能的详细安装步骤，包含 Windows 和 macOS |
| [Claude Code 连接 GitHub](docs/github-connection-zh.md) | 如何配置 GitHub CLI、创建仓库、推送代码 |
| [Skill 创建指南](docs/skill-creation-zh.md) | 从零创建自己的 Claude Code Skill |

---

## 创建自己的 Skill

每个 Skill 由一个目录组成，最少只需一个 `SKILL.md` 文件：

```
my-skill/
├── SKILL.md              # 必需：技能定义
└── scripts/              # 可选：执行脚本
```

`SKILL.md` 的基本格式：

```markdown
---
name: my-skill
description: 描述这个技能做什么，以及什么时候触发。
---

# 技能说明

具体的操作指令...
```

详细的创建教程请参考 [Skill 创建指南](docs/skill-creation-zh.md)。

---

## 许可证

[MIT](LICENSE) - 可自由使用、修改和分发。
