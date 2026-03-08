# unity-claude

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | [简体中文](README_CN.md)

Dispatch Claude Code tasks to a remote HPC cluster (Unity) via SSH. Fire-and-forget with instant webhook notifications on completion. An [OpenClaw](https://github.com/openclaw/openclaw) skill.

## Features

- **Fire & Forget** — SSH dispatch via tmux, walk away, get notified when done
- **Auto Session Resume** — Same task name auto-resumes the previous session (saves tokens, keeps context)
- **Plan Mode** (`--plan`) — CC creates `IMPLEMENTATION_PLAN.md` before coding
- **Progress Logging** (`--progress`) — CC writes lessons learned to `PROGRESS.md`
- **Ralph Loop** (`--ralph N`) — N iterations with fresh context, plan file as shared state
- **Git Worktree Isolation** (`--worktree`) — Parallel tasks on the same repo without conflicts
- **Superpower / Agent Teams** — Multi-agent collaboration via CC's native subagent system
- **Instant Notifications** — Tailscale Funnel webhook → OpenClaw `/hooks/agent` (zero polling)
- **Per-Agent Routing** — `-a` flag routes completion to the correct OpenClaw agent

## Architecture

```
dispatch-to-unity.sh -p "prompt" -n "task" -a "agent"
  → SSH: write task-meta + prompt file on Unity
  → SSH: tmux new-session → run-task.sh → Claude Code
    → CC completes → Stop Hook fires → notify-agi.sh
      → POST /hooks/agent (agentId, sessionKey)
        → OpenClaw routes to correct agent → Discord notification
```

## Parameters

| Flag | Description |
|------|-------------|
| `-p "prompt"` | Task prompt (required) |
| `-n name` | Task name (key for session tracking + notification routing) |
| `-a agent` | Agent to notify on completion (required) |
| `-w /path` | Working directory on remote host |
| `--bypass` | Bypass permissions mode |
| `--plan` | Plan Mode: create `IMPLEMENTATION_PLAN.md` first |
| `--progress` | Log lessons learned to `PROGRESS.md` |
| `--ralph N` | Loop N iterations with fresh context each round |
| `--worktree NAME` | Git worktree isolation for parallel tasks |
| `--new` | Force fresh session |
| `--resume UUID` | Resume explicit session |
| `--clean` | Clear saved session for this task name |

## Usage

### Simple Dispatch

```bash
bash dispatch-to-unity.sh \
  -p "Optimize the attention module" \
  -n "optimize-attn" -a "main" \
  -w "~/LightningDiT" --bypass
```

### Full Ralph Workflow (Plan + Loop + Progress)

```bash
bash dispatch-to-unity.sh \
  -p "Implement VSA training pipeline" \
  -n "vsa-train" -a "main" \
  -w "~/VSA" --bypass --plan --progress --ralph 5
```

### Parallel Tasks with Worktree Isolation

```bash
# Task A works in .worktrees/task-a/
bash dispatch-to-unity.sh \
  -p "Refactor linear attention" \
  -n "refactor-attn" -a "code1" \
  -w "~/LightningDiT" --bypass --worktree "refactor-attn"

# Task B works in .worktrees/task-b/ (same repo, no conflicts)
bash dispatch-to-unity.sh \
  -p "Add new benchmarks" \
  -n "add-bench" -a "code2" \
  -w "~/LightningDiT" --bypass --worktree "add-bench"
```

### Multi-Round Review (Judge Mode)

```bash
# Round 1: dispatch with plan
bash dispatch-to-unity.sh \
  -p "Implement feature X" -n "feature-x" -a "code1" \
  -w "~/Project" --bypass --plan --ralph 5

# Agent reviews via SSH after completion...
# Round 2: auto-resumes same session with feedback
bash dispatch-to-unity.sh \
  -p "Fix the edge case in handler.py" -n "feature-x" -a "code1" \
  -w "~/Project" --bypass
```

## Directory Structure

```
unity-claude/
├── README.md
├── SKILL.md                      # Main skill definition
└── references/
    ├── architecture.md           # System architecture details
    ├── git-worktree.md           # Git worktree isolation guide
    └── superpower.md             # Agent Teams / Superpower mode
```

## Prerequisites

- [OpenClaw](https://github.com/openclaw/openclaw) installed and configured
- SSH access to remote HPC cluster
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed on the remote host
- Tailscale Funnel configured for webhook notifications (or alternative callback method)

## License

MIT License
