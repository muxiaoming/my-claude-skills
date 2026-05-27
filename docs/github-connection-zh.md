# Claude Code 连接 GitHub 操作指南

本文档介绍如何在 Claude Code 环境中配置 GitHub，实现仓库创建、代码推送、PR 管理等操作。

---

## 前置条件

- 已安装 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- 已安装 Git（`git --version` 验证）
- 拥有 GitHub 账号

---

## 第 1 步：安装 GitHub CLI

GitHub CLI（`gh`）是 GitHub 官方命令行工具，可以在终端中完成仓库创建、推送、PR 等操作。

### Windows

```bash
winget install GitHub.cli
```

安装后**重启终端**使 `gh` 命令生效。

### macOS

```bash
brew install gh
```

### Linux (Debian/Ubuntu)

```bash
sudo apt install gh
```

### 验证安装

```bash
gh --version
```

输出版本号即表示安装成功。

---

## 第 2 步：登录 GitHub

```bash
gh auth login
```

按提示选择：

| 选项 | 选择 |
|------|------|
| 账号类型 | `GitHub.com` |
| 协议 | `HTTPS` |
| 登录方式 | `Login with a web browser` |

终端会显示一个一次性验证码，在浏览器中输入即可完成授权。

### 验证登录

```bash
gh auth status
```

显示 `Logged in to github.com` 即表示登录成功。

---

## 第 3 步：配置 Git 用户信息

如果还没配置过 Git 用户名和邮箱：

```bash
git config --global user.name "你的用户名"
git config --global user.email "你的邮箱"
```

---

## 第 4 步：创建仓库并推送代码

### 方式一：用 gh 一键创建（推荐）

```bash
cd "你的项目目录"
git init
git add .
git commit -m "Initial commit"
gh repo create 仓库名 --public --source=. --push
```

这一条命令完成：创建远程仓库 → 关联本地仓库 → 推送代码。

### 方式二：先在 GitHub 网页创建，再关联推送

```bash
cd "你的项目目录"
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/仓库名.git
git push -u origin master
```

---

## 常用操作

### 查看仓库信息

```bash
gh repo view
```

### 在浏览器中打开仓库

```bash
gh repo view --web
```

### 查看远程地址

```bash
git remote -v
```

### 推送代码

```bash
git add .
git commit -m "提交说明"
git push
```

### 拉取最新代码

```bash
git pull
```

---

## 在 Claude Code 中使用 Git

Claude Code 内置了 Git 支持，你可以直接用自然语言操作：

```
帮我提交当前修改
```

```
推送到远程仓库
```

```
查看最近的提交记录
```

```
创建一个新分支叫 feature-xxx
```

Claude Code 会自动执行对应的 Git 命令。

---

## 常见问题

**Q: `gh` 命令找不到？**
A: 确认安装后重启了终端。Windows 用户可以尝试在 PowerShell 中运行 `refreshenv`。

**Q: 推送时提示 `Failed to connect to github.com`？**
A: 网络问题，可能需要代理。如果使用代理：
```bash
git config --global http.proxy http://127.0.0.1:端口号
git config --global https.proxy http://127.0.0.1:端口号
```

**Q: 如何取消代理？**
A: 
```bash
git config --global --unset http.proxy
git config --global --unset https.proxy
```

**Q: 提示 `Permission denied (publickey)`？**
A: 使用 HTTPS 方式而非 SSH。确认 `git remote -v` 显示的是 `https://` 开头的地址。

**Q: 如何切换 GitHub 账号？**
A: 
```bash
gh auth logout
gh auth login
```
