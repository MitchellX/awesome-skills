# 🚀 unity-claude

> 将 Claude Code 任务通过 SSH 分发到远程 HPC 集群（Unity），即发即忘，完成后即时 webhook 通知

**即发即忘** · **自动会话恢复** · **计划模式** · **进度日志** · **Ralph 循环** · **Git 工作树隔离** · **即时通知**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | [简体中文](README_CN.md)

---

## ✨ 功能特性

- **即发即忘** — 通过 tmux SSH 分发，走开即可，完成后自动通知
- **自动会话恢复** — 相同任务名自动恢复之前的会话（节省 token，保留上下文）
- **计划模式**（`--plan`）— CC 先创建 `IMPLEMENTATION_PLAN.md` 再编码
- **进度日志**（`--progress`）— CC 将经验教训写入 `PROGRESS.md`
- **Ralph 循环**（`--ralph N`）— N 次迭代，每次新上下文，计划文件作为共享状态
- **Git 工作树隔离**（`--worktree`）— 同一仓库的并行任务互不冲突
- **Superpower / 智能体团队** — 通过 CC 原生子智能体系统实现多智能体协作
- **即时通知** — Tailscale Funnel webhook → OpenClaw `/hooks/agent`（零轮询）
- **按智能体路由** — `-a` 标志将完成通知路由到正确的 OpenClaw 智能体

## 🔄 架构

```
dispatch-to-unity.sh -p "prompt" -n "task" -a "agent"
  → SSH: 在 Unity 上写入 task-meta + prompt 文件
  → SSH: tmux new-session → run-task.sh → Claude Code
    → CC 完成 → Stop Hook 触发 → notify-agi.sh
      → POST /hooks/agent (agentId, sessionKey)
        → OpenClaw 路由到正确的智能体 → Discord 通知
```

## 🎯 参数

| 标志 | 说明 |
|------|------|
| `-p "prompt"` | 任务提示（必需） |
| `-n name` | 任务名（会话跟踪和通知路由的键） |
| `-a agent` | 完成后通知的智能体（必需） |
| `-w /path` | 远程主机上的工作目录 |
| `--bypass` | 绕过权限模式 |
| `--plan` | 计划模式：先创建 `IMPLEMENTATION_PLAN.md` |
| `--progress` | 将经验教训记录到 `PROGRESS.md` |
| `--ralph N` | 循环 N 次迭代，每轮新上下文 |
| `--worktree NAME` | Git 工作树隔离，用于并行任务 |
| `--new` | 强制新会话 |
| `--resume UUID` | 恢复显式会话 |
| `--clean` | 清除此任务名的已保存会话 |

## 📖 使用方法

### 简单分发

```bash
bash dispatch-to-unity.sh \
  -p "优化注意力模块" \
  -n "optimize-attn" -a "main" \
  -w "~/LightningDiT" --bypass
```

### 完整 Ralph 工作流（计划 + 循环 + 进度）

```bash
bash dispatch-to-unity.sh \
  -p "实现 VSA 训练流程" \
  -n "vsa-train" -a "main" \
  -w "~/VSA" --bypass --plan --progress --ralph 5
```

### 并行任务与工作树隔离

```bash
# 任务 A 在 .worktrees/task-a/ 工作
bash dispatch-to-unity.sh \
  -p "重构线性注意力" \
  -n "refactor-attn" -a "code1" \
  -w "~/LightningDiT" --bypass --worktree "refactor-attn"

# 任务 B 在 .worktrees/task-b/ 工作（同一仓库，无冲突）
bash dispatch-to-unity.sh \
  -p "添加新基准测试" \
  -n "add-bench" -a "code2" \
  -w "~/LightningDiT" --bypass --worktree "add-bench"
```

### 多轮审查（裁判模式）

```bash
# 第 1 轮：带计划分发
bash dispatch-to-unity.sh \
  -p "实现功能 X" -n "feature-x" -a "code1" \
  -w "~/Project" --bypass --plan --ralph 5

# 智能体通过 SSH 审查完成后...
# 第 2 轮：自动恢复同一会话并提供反馈
bash dispatch-to-unity.sh \
  -p "修复 handler.py 中的边界情况" -n "feature-x" -a "code1" \
  -w "~/Project" --bypass
```

## 🏗️ 项目结构

```
unity-claude/
├── README.md
├── README_CN.md                  # 本文件
├── SKILL.md                      # 主技能定义
└── references/
    ├── architecture.md           # 系统架构细节
    ├── git-worktree.md           # Git 工作树隔离指南
    └── superpower.md             # 智能体团队 / Superpower 模式
```

## 🔧 前置要求

- 已安装并配置 [OpenClaw](https://github.com/openclaw/openclaw)
- 能够 SSH 访问远程 HPC 集群
- 远程主机上已安装 [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- 已配置 Tailscale Funnel 用于 webhook 通知（或其他回调方法）

## 📄 许可证

MIT License
