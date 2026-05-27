[English](README.md) | 中文

# My Claude Skills

[Claude Code](https://docs.anthropic.com/en/docs/claude-code) 自定义技能集合。

## 可用技能

| 技能 | 说明 | 支持平台 |
|------|------|----------|
| [claude-notify](skills/claude-notify/) | Claude Code 桌面通知，在等待确认、权限被拒、任务完成时弹出通知 | Windows 10/11、macOS |

## 安装

### 快速安装

```bash
# 克隆仓库
git clone https://github.com/<your-username>/my-claude-skills.git

# 安装技能
claude skill install ./my-claude-skills/skills/claude-notify
```

### 手动安装

详见 [安装指南](docs/installation-zh.md)。

## 文档

- [安装指南](docs/installation-zh.md) - 各技能的详细安装步骤

## 自建技能

每个技能的目录结构：

```
skill-name/
├── SKILL.md          # 必需：技能定义，包含 YAML frontmatter
└── scripts/          # 可选：可执行脚本
```

`SKILL.md` 必须包含 `name` 和 `description` 字段：

```markdown
---
name: my-skill
description: 描述这个技能做什么，以及什么时候触发。
---

# 具体指令...
```

## 许可证

[MIT](LICENSE)
