# 📤 upload-skills

> 一键发布本地 Claude Code 技能到 GitHub 仓库，自动生成 README、更新索引、提交推送

**一键上传** · **自动生成文档** · **智能验证** · **Git 集成**

[![Skills.sh](https://img.shields.io/badge/skills.sh-available-blue)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | [简体中文](README_CN.md)

---

## ✨ 功能特性

- **一键上传** — 用单条 `/upload-skills` 命令发布本地技能到 GitHub
- **自动生成 README** — 从 SKILL.md 提取信息，生成格式化的 README.md
- **仓库 README 更新** — 自动将技能添加到技能表格、安装说明和目录结构
- **交互验证** — 未指定技能时列出可用技能，覆盖前确认
- **Git 集成** — 一次性完成 git pull、commit 和 push

## 🔄 工作流程

```
/upload-skills <skill-name>

     ┌──────────────────────────────────────────────────────┐
     │           步骤 1: 验证技能存在                          │
     │   检查 ~/.claude/skills/<skill-name>/SKILL.md         │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │           步骤 2: 准备仓库                             │
     │   Clone 或 pull ~/awesome-skills                      │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │           步骤 3: 复制技能到仓库                        │
     │   cp -r skill → skills/<skill-name>                   │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │         步骤 4: 生成技能 README                         │
     │   从 SKILL.md 提取信息 → README.md                     │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │         步骤 5: 更新仓库根 README                       │
     │   添加到表格、安装说明和目录树                           │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │         步骤 6: 提交并推送                             │
     │   git add → commit → push origin main                 │
     └──────────────────────────────────────────────────────┘
```

## 🚀 安装

### 通过 skills.sh（推荐）

```bash
npx skills add https://github.com/mitchellx/awesome-skills --skill upload-skills
```

### 手动安装

```bash
git clone https://github.com/MitchellX/awesome-skills.git /tmp/awesome-skills
cp -r /tmp/awesome-skills/skills/upload-skills ~/.claude/skills/upload-skills
```

## 📖 使用方法

```bash
# 上传指定技能
/upload-skills <skill-name>

# 不提供技能名时，列出可用技能并提示选择
/upload-skills
```

### 参数

- `<skill-name>`（必需）：`~/.claude/skills/` 下的技能目录名。如果省略或无效，会列出所有本地技能供选择。

### 示例

```bash
# 上传 techdebt 技能
/upload-skills techdebt

# 上传 diff-review 技能
/upload-skills diff-review
```

## 🏗️ 项目结构

```
upload-skills/
├── README.md          # 英文文档
├── README_CN.md       # 本文件
└── SKILL.md           # 技能定义与工作流程
```

## 📄 许可证

MIT License - 详见 [LICENSE](../../LICENSE)
