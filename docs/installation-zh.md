# 安装指南

## 快速安装（推荐）

最快的方式是复制提示词给 Claude Code。**无需 git** —— Claude 会自动检测你的环境并自适应处理。

### 安装 claude-notify

复制以下内容给 Claude Code：

```
从 https://github.com/muxiaoming/my-claude-skills.git 安装 claude-notify 技能
```

### 安装 spring-ai-langfuse3

复制以下内容给 Claude Code：

```
从 https://github.com/muxiaoming/my-claude-skills.git 安装 spring-ai-langfuse3 技能
```

Claude 会自动完成：
1. 下载技能所需的所有文件
2. 安装技能到 `~/.claude/skills/`
3. 配置依赖和 hooks
4. 验证安装结果

**无需克隆仓库、无需手动配置** —— Claude 会透明地处理所有细节。

---

## 底层原理

Claude 会自动下载每个技能所需的特定文件 —— 无需克隆整个仓库。

**Claude 为每个技能下载的内容：**
- `SKILL.md` — 技能定义文件
- 必要的脚本（如果有的话）
- 配置文件

**安装位置：**
```bash
~/.claude/skills/<技能名称>/
```

整个过程是自动的 —— 你只需要提供仓库 URL，Claude 处理其他所有事情。

---

## 如果自动安装不成功？

如果自动安装失败，请参考以下故障排查步骤：

### 检查 Claude Code 版本

确保你使用的是最新版本的 Claude Code。更新方法：

```bash
claude update
```

### 手动克隆并安装（如果有 git）

```bash
git clone https://github.com/muxiaoming/my-claude-skills.git
cd my-claude-skills
claude skill install ./skills/claude-notify
# 或
claude skill install ./skills/spring-ai-langfuse3
```

### 手动配置（备选方案）

如果自动方式不可用，请参阅技能的 `SKILL.md` 文件中的详细手动安装步骤。

---

## 各技能的故障排查

### claude-notify

**Q: Windows 上通知不显示？**
A: 确保已安装 BurntToast PowerShell 模块：
```powershell
Install-Module BurntToast -Scope CurrentUser -Force
```

**Q: macOS 上通知不显示？**
A: 确保通知脚本有执行权限：
```bash
chmod +x ~/.claude/notify.sh
```

**Q: 安装技能后 Claude 没有自动配置？**
A: 明确告诉 Claude："set up desktop notifications"。Claude 需要这个指令才会执行配置流程。

### spring-ai-langfuse3

**Q: Langfuse 需要什么版本？**
A: 需要 Langfuse >= v3.22.0 才支持 OTEL 端点。

**Q: 遇到 OpenTelemetry 版本冲突怎么办？**
A: 按照技能 SKILL.md 中的 JDBC + OTel 版本冲突故障排查进行操作。技能中包含了详细的 Maven exclusion 配置。

**Q: 如何验证配置是否成功？**
A: 配置完成后，按照技能 SKILL.md 第 7 节（验证）中的命令进行测试。

---

## 卸载技能

要卸载已安装的技能：

```bash
claude skill uninstall claude-notify
# 或
claude skill uninstall spring-ai-langfuse3
```

或者手动删除技能目录：
```bash
rm -rf ~/.claude/skills/claude-notify
rm -rf ~/.claude/skills/spring-ai-langfuse3
```

如果技能配置了 hooks，还需要从 `~/.claude/settings.json` 中删除对应配置。
