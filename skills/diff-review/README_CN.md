# 🔍 Diff Review

> 使用 Gemini、Codex 和 Claude 并行进行多智能体代码审查

**多智能体审查** · **领域自动检测** · **统一报告** · **提交或差异**

![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet) ![OpenClaw](https://img.shields.io/badge/OpenClaw-Plugin-blue)

[English](README.md) | [简体中文](README_CN.md)

---

## ✨ 功能特性

- **并行多智能体审查** — 同时运行 Gemini、Codex 和 Claude 审查器，进行全面的代码分析
- **智能领域检测** — 自动识别代码领域（机器学习/AI、安全、性能）并应用专业审查提示
- **统一报告生成** — 合并所有审查器的发现，去重问题，按严重程度排序
- **灵活的审查目标** — 通过哈希值审查特定提交，或分析所有未提交的更改
- **容错机制** — 如果部分审查器失败，继续使用可用的审查器，不会因单个智能体错误而阻塞
- **来源标注** — 显示每个问题由哪个审查器发现，提高透明度和可信度

## 🚀 快速开始

### 前置要求

至少安装以下 CLI 工具之一：
- [Gemini CLI](https://github.com/google/generative-ai)（推荐）
- [Codex CLI](https://github.com/anthropics/anthropic-tools)
- Claude Code 会话（内置）

### 使用方法

使用所有智能体审查未提交的更改：
```bash
/diff-review
```

审查特定提交：
```bash
/diff-review abc123f
```

使用单个审查器：
```bash
/diff-review --reviewer=gemini
/diff-review --reviewer=codex
/diff-review --reviewer=claude
```

根据代码类型自动选择最佳审查器：
```bash
/diff-review --reviewer=auto
```

## 📖 文档

### 命令语法

```
/diff-review [<commit-hash>] [--reviewer=<mode>]
```

**参数说明：**
- `<commit-hash>`（可选）：要审查的完整或短提交哈希值。省略则审查未提交的更改。
- `--reviewer`（可选）： 
  - `all`（默认）：多智能体模式，并行执行
  - `auto`：根据代码模式自动选择最佳审查器
  - `gemini`、`codex`、`claude`：仅使用单个审查器

### 审查流程

1. **解析参数** — 确定审查目标（提交或差异）和审查器模式
2. **获取 Git Diff** — 提取更改及统计信息和元数据
3. **自动检测领域** — 将代码模式匹配到专业审查提示
4. **执行审查** — 并行运行审查器（多智能体）或单一模式
5. **协调与合并** — 去重问题并生成统一报告
6. **保存报告** — 输出到终端并写入带时间戳的文件

### 专业领域

该技能会自动检测并应用以下领域的专业审查逻辑：
- **机器学习 / AI** — 训练循环、模型架构、数据处理
- **安全** — 身份验证、输入验证、敏感数据暴露
- **性能** — 算法效率、资源管理、缓存

领域检测规则定义在 `expertise/_index.md` 中。

## 🏗️ 项目结构

```
diff-review/
├── SKILL.md              # 主技能文档
├── expertise/            # 领域专业审查提示
│   ├── _index.md         # 检测规则
│   └── training.md       # 机器学习/AI 训练专业知识
├── reviewers/            # 审查器角色定义
│   ├── gemini-role.md    # Gemini CLI 审查器
│   ├── codex-role.md     # Codex CLI 审查器
│   ├── claude-role.md    # Claude 审查器
│   └── coordinator.md    # 多智能体协调器
└── templates/
    └── report.md         # 报告格式模板
```

## 📋 输出格式

生成的报告包括：

- **审查摘要** — 目标（提交或未提交）、时间戳、审查器来源
- **严重程度分类** — 严重/高/中/低问题的数量统计
- **合并问题** — 按严重程度排序的去重发现，附带来源标注
- **原始输出** — 可折叠的各个审查器完整结果

报告保存为：
- 提交审查：`diff-review-<short-hash>-YYYYMMDD-HHMMSS.md`
- 未提交更改：`diff-review-YYYYMMDD-HHMMSS.md`

## ⚙️ 配置

### 自定义审查器

编辑审查器角色文件以调整关注领域：
- `reviewers/gemini-role.md` — Gemini 的审查指令
- `reviewers/codex-role.md` — Codex 的审查指令
- `reviewers/claude-role.md` — Claude 的审查指令

### 添加新领域

要添加领域特定的审查逻辑：

1. 在 `expertise/` 中创建新的专业文件（例如 `expertise/frontend.md`）
2. 更新 `expertise/_index.md` 添加检测模式：
   ```markdown
   ## 前端开发
   - 触发模式：`React`、`Vue`、`component`、`useState`
   - 文件模式：`*.tsx`、`*.jsx`、`*.vue`
   - 提示文件：`expertise/frontend.md`
   ```

## 🤝 贡献指南

此技能是 [awesome-skills](https://github.com/MitchellX/awesome-skills) 集合的一部分，欢迎贡献！

提出改进建议：
1. 查看 `SKILL.md` 中的技能结构
2. 在示例提交上使用 `/diff-review` 测试更改
3. 向主仓库提交 PR

## 📄 许可证

此技能是 awesome-skills 仓库的一部分。许可证信息请查看主仓库。

---

**所属项目：** [awesome-skills](https://github.com/MitchellX/awesome-skills)  
**仓库路径：** `skills/diff-review/`
