# Skill 创建指南

本文档以 `claude-notify`（桌面通知 skill）为例，手把手教你如何从零创建、优化、修改一个 Claude Code skill。

---

## 什么是 Skill？

Skill 就是一个"指令包"——你把一组操作写成文档，Claude 读取后就知道该怎么帮你完成特定任务。比如：
- `claude-notify`：帮用户配置桌面通知
- `frontend-design`：帮你设计前端界面
- `firecrawl`：帮你爬取网页内容

Skill 不是代码插件，而是**给 Claude 看的说明书**。

---

## 三种创建方式

| 方式 | 适合谁 | 优点 | 缺点 |
|------|--------|------|------|
| **AI Agent 对话式** | 所有人（推荐） | 最快、最直观，边聊边改 | 需要 Claude Code 环境 |
| **命令行手动** | 有经验的开发者 | 完全掌控，可批量操作 | 需要手动写所有内容 |
| **混合方式** | 进阶用户 | AI 生成初稿 + 手动微调 | 需要了解两者 |

**推荐新手用方式一（AI Agent），有经验的用方式三（混合）。**

---

## 方式一：AI Agent 对话式创建（推荐）

这是 AI 时代最高效的方式——你只需要**告诉 Claude 你想要什么**，它会帮你完成所有工作。

### 实战案例：用 Claude Code 创建 claude-notify

以下是我们创建 `claude-notify` 的真实对话流程：

#### 第 1 步：描述需求

在 Claude Code 中输入：

```
帮我创建一个 skill，功能是配置 Claude Code 的桌面通知。
当 Claude 等待确认、权限被拒、任务完成时弹出系统通知。
要支持 Windows 和 macOS。
```

Claude 会：
- 自动创建目录结构
- 生成 SKILL.md
- 编写跨平台脚本
- 配置 hooks

#### 第 2 步：迭代优化

对话过程中你可以随时提出修改：

```
把中文通知改成英文，中文有乱码
```

```
通知正文太长了，去掉时间，只保留 3 行
```

```
能显示 git 分支吗？
```

Claude 会实时修改代码并告诉你改了什么。

#### 第 3 步：测试验证

```
重启 Claude Code，测试一下通知有没有弹出来
```

Claude 会帮你检查配置是否正确，必要时自动修复。

#### 第 4 步：打包发布

```
把这个 skill 整理成可以分享的格式，放到 my-claude-skills 仓库
```

Claude 会生成安装文档、README、LICENSE 等。

### AI Agent 方式的关键技巧

**1. 需求描述越具体越好**

```
差：帮我做个通知功能
好：帮我创建一个 Claude Code skill，在 Windows 10/11 上用 BurntToast 模块弹桌面通知，
    macOS 用 osascript，通知内容包含项目名、git 分支、模型信息
```

**2. 随时纠正方向**

```
不要用环境变量传路径，直接用参数
```

```
hook 命令里的 $ 符号被 bash 吃掉了，换个方案
```

**3. 要求解释原理**

```
为什么要用 -File 而不是 -Command？
```

```
hook 里的 $ 符号为什么会被 bash 展开？
```

这样你能学到东西，下次遇到类似问题就知道怎么解决。

**4. 让 Claude 记住你的偏好**

```
以后创建 skill 都用英文写通知内容，避免编码问题
```

Claude 会记住这个偏好，后续创建 skill 时自动应用。

---

## 方式二：命令行手动创建

适合有经验的开发者，想完全掌控每个细节。

### 第 1 步：确定 Skill 要解决什么问题

先想清楚：
- 这个 skill 要做什么？
- 用户会怎么触发它？
- 需要什么依赖？

### 第 2 步：创建目录结构

```bash
mkdir -p ~/.claude/skills/claude-notify/scripts
```

Skill 的目录结构：

```
skill-name/
├── SKILL.md              # 必须有！这是 skill 的核心
└── scripts/              # 可选，放执行脚本
    ├── script.ps1        # Windows 脚本
    └── script.sh         # macOS/Linux 脚本
```

### 第 3 步：编写 SKILL.md

这是最重要的文件。它分两部分：**YAML 头部**（元数据）和 **Markdown 正文**（说明文档）。

#### YAML 头部

```yaml
---
name: claude-notify
description: Configure desktop toast notifications for Claude Code hooks on Windows and macOS. Triggers when user asks to setup notifications, enable toast, configure alerts, or mentions "桌面通知", "通知配置", "toast notification setup".
---
```

**字段说明**：

| 字段 | 必须 | 说明 |
|------|------|------|
| `name` | 是 | skill 名称，小写+连字符 |
| `description` | 是 | **最重要的字段**！Claude 靠它判断什么时候该用这个 skill |
| `allowed-tools` | 否 | 限制 skill 能用哪些工具 |

**description 写法技巧**：
- 写清楚"做什么"和"什么时候触发"
- 包含多种触发词（中英文都写上）
- 写得"积极"一点，避免漏触发

#### Markdown 正文

正文就是给 Claude 看的"操作手册"。写清楚：

1. **支持哪些平台**
2. **每一步怎么做**（越具体越好，写完整命令）
3. **执行后要做什么**（比如提示用户）

**关键原则**：
- 把所有命令写完整，Claude 会直接复制执行
- JSON 配置要写完整，别让 Claude 自己猜
- 写上验证步骤，确保配置生效

### 第 4 步：编写执行脚本

脚本放在 `scripts/` 目录下。Claude 会调用这些脚本，但**不会把脚本内容读进上下文**（节省 token）。

#### Windows 脚本（toast.ps1）

```powershell
param([string]$Type)
Import-Module BurntToast -ErrorAction SilentlyContinue

$d = $env:CLAUDE_PROJECT_DIR
$n = Split-Path $d -Leaf
$m = $env:ANTHROPIC_MODEL

switch ($Type) {
    "Notification" { $Title = "[$n] Claude Waiting" }
    "PermissionDenied" { $Title = "[$n] Permission Needed" }
    "Stop" { $Title = "[$n] Claude Done" }
    default { exit 0 }
}

New-BurntToastNotification -Text $Title, "Dir: $d`nModel: $m"
```

#### macOS 脚本（notify.sh）

```bash
#!/bin/bash
TYPE="${1:-Stop}"
DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
NAME="$(basename "$DIR" 2>/dev/null || echo "unknown")"
MODEL="${ANTHROPIC_MODEL:-unknown}"

case "$TYPE" in
  Notification) TITLE="[$NAME] Claude Waiting" ;;
  PermissionDenied) TITLE="[$NAME] Permission Needed" ;;
  Stop) TITLE="[$NAME] Claude Done" ;;
  *) exit 0 ;;
esac

osascript -e "display notification \"Dir: $DIR\nModel: $MODEL\" with title \"$TITLE\" sound name \"Glass\""
```

### 第 5 步：测试和优化

1. 安装依赖（如 Windows 的 BurntToast）
2. 复制脚本到 `~/.claude/`
3. 写入 hooks 配置到 `~/.claude/settings.json`
4. 重启 Claude Code
5. 触发事件，看通知是否弹出

### 第 6 步：编写安装文档

在 `docs/` 目录下创建安装指南，方便其他用户使用。

---

## 方式三：混合方式（AI 生成 + 手动微调）

1. 先用 AI Agent 生成初稿
2. 手动调整细节
3. 用 AI Agent 测试和修复

```
# 第 1 步：让 AI 生成初稿
帮我创建一个 claude-notify skill，参考已有 skill 的格式

# 第 2 步：手动打开 SKILL.md 修改 description
# （用编辑器打开文件，直接改）

# 第 3 步：让 AI 测试
测试一下这个 skill 能不能正常触发
```

---

## Skill 优化技巧

### 1. description 写好能大幅提高触发率

**差的 description**：
```yaml
description: A notification tool
```

**好的 description**：
```yaml
description: Configure desktop toast notifications for Claude Code hooks on Windows and macOS. Triggers when user asks to setup notifications, enable toast, configure alerts, or mentions "桌面通知", "通知配置", "toast notification setup".
```

### 2. 利用"执行后提示"减少上下文占用

如果 skill 执行完就不需要了，可以在 SKILL.md 里写：

```markdown
## Post-Setup

After successful configuration, inform the user:
> Notification setup complete! You can optionally delete this skill to save ~30 tokens.
> Delete this skill?
```

用户确认后删除 skill 目录即可，不影响已配置的功能。

### 3. 用表格整理信息

Claude 很擅长读表格，用表格比用大段文字更清晰：

```markdown
| Platform | Method | Dependencies |
|----------|--------|-------------|
| Windows | BurntToast | Install-Module |
| macOS | osascript | None |
```

### 4. 脚本放进 scripts/ 目录

脚本文件不会被读进上下文，只在执行时调用。这样：
- 节省 token
- 保持 SKILL.md 简洁
- 脚本可以独立更新

---

## 完整 Skill 检查清单

- [ ] `SKILL.md` 有 YAML 头部（name + description）
- [ ] description 包含多种触发词（中英文）
- [ ] 正文写清楚了每一步操作
- [ ] 所有命令可直接复制执行
- [ ] JSON 配置完整，不需要 Claude 自己补全
- [ ] 脚本放在 `scripts/` 目录
- [ ] 跨平台兼容（或明确只支持特定平台）
- [ ] 有验证/测试步骤
- [ ] `docs/` 下有安装文档

---

## 从我们的实战中总结的经验

在创建 `claude-notify` 的过程中，我们踩了这些坑：

1. **PowerShell 变量被 bash 吃掉**：`$dir` 在 bash 中被展开为空。解决：把逻辑放进 `.ps1` 文件，hook 只调用 `-File`。

2. **换行符 `` `n `` 被 bash 当命令执行**：PowerShell 的换行符在 bash 中有特殊含义。解决：避免在内联命令中使用，全部放到脚本文件里。

3. **中文乱码**：PowerShell 默认编码不支持中文。解决：改成英文，或设置编码。

4. **通知内容太长被截断**：Windows toast 正文限制约 3-4 行。解决：精简到 3 行以内。

5. **路径含空格导致解析失败**：`/d/Program Files/...` 中的空格破坏命令解析。解决：用引号包裹路径，或使用 `-File` 参数。

**核心教训**：能放到脚本文件里的逻辑，就不要内联到 hook 命令中。内联命令要经过 JSON → bash → PowerShell 三层转义，极其容易出错。
