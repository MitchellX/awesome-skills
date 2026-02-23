---
name: unity-claude
description: Dispatch Claude Code tasks to Unity HPC via SSH. Use when user asks to run Claude Code on Unity, dispatch a coding task to Unity, or asks Unity's Claude to do something (read/analyze/modify code on Unity). Also triggers on "dispatch to unity", "ask unity claude", "在unity上跑". Tasks run in background via sessions_spawn, auto-notify on completion via Discord.
---

# Unity Claude Code Dispatcher

## ⚠️ Always use sessions_spawn!

ALL dispatch operations MUST run via `sessions_spawn`. Never block the main session.

## Scripts

All at `/home/ubuntu/.openclaw/workspace/scripts/claude-code/`

- `dispatch-to-unity.sh` — Main dispatcher (auto-resume + per-agent routing)

## Dispatch Parameters

| Flag | Description |
|------|-------------|
| `-p "prompt"` | Task prompt (required) |
| `-n name` | Task name (**key for session tracking + notification routing**) |
| `-a agent` | Agent to notify on completion (default: `"main"`) |
| `-w /path` | Workdir on Unity |
| `--new` | Force fresh session (clears saved session for this task name) |
| `--resume UUID` | Resume explicit session (overrides auto) |
| `--session-id UUID` | Start with explicit UUID (overrides auto) |
| `--bypass` | bypassPermissions mode |
| `--plan` | **Plan Mode**: CC creates IMPLEMENTATION_PLAN.md before coding |
| `--progress` | **PROGRESS.md**: CC logs lessons learned after task completion |
| `--ralph N` | **Ralph Loop**: Run N iterations, each with fresh context |
| `--clean` | Clear saved session for this task name |
| `--clean-all` | Clear all saved sessions |

## Notification Flow (Instant — No Watcher)

```
dispatch -n "task" -a "code1" -p "prompt"
  → Unity tmux session starts
    → Claude Code executes
      → Completes → notify-agi.sh (hook) fires instantly
        → Reads agent_id from task-meta-{task}.json
        → POST /hooks/agent with:
            agentId: "code1"
            sessionKey: "hook:unity:task"
            deliver: true, channel: "discord"
          → code1 agent gets notified → Discord
```

**Key:** The `-a` flag determines which agent receives the completion notification.

**⚠️ Always report to Mitchell after dispatch:**
- Session ID: `claude --resume <uuid>` (from active-tasks/{name}.json)
- Working directory on Unity
- Example: "Session: `claude --resume 26e4bad5-...` | 工作目录: `~/VSA/`"

## Session Management (Auto-Resume)

**The dispatch script automatically manages sessions by task name.**

- Same `-n name` → **auto-resumes** the previous session (keeps context, saves tokens)
- Different `-n name` → completely isolated session
- `--new` → force fresh session even if one exists for this name
- Session state stored in `scripts/claude-code/active-tasks/{name}.json`

**You do NOT need to manually track session IDs anymore.**

### Examples

```bash
# First dispatch — creates new session, agent code1 will be notified
dispatch -p "Optimize the attention module" -n "optimize-attn" -a "code1" -w "/path" --bypass

# Follow-up — auto-resumes same session (CC has full context from round 1)
dispatch -p "Now add benchmarks" -n "optimize-attn" -a "code1" -w "/path" --bypass

# Different agent dispatches a different task
dispatch -p "Review the paper" -n "paper-review" -a "paper" -w "/path" --bypass

# Main agent dispatch (default, no -a needed)
dispatch -p "Fix the bug" -n "fix-bug" -w "/path" --bypass
```

## Enhanced Modes

### 🧠 Plan Mode (`--plan`)

Prepends a structured planning phase to the prompt. CC will:
1. **Orient** — Study codebase + existing plan + PROGRESS.md
2. **Plan** — Create/update `IMPLEMENTATION_PLAN.md` with gap analysis and prioritized tasks
3. **Execute** — Pick the most important task, implement, commit, update plan

Best for complex or multi-step tasks where direction matters.

```bash
dispatch -p "Optimize the training pipeline for multi-GPU" -n "train-opt" -a "main" \
  -w "~/SLA" --bypass --plan
```

### 📝 PROGRESS.md (`--progress`)

Appends instructions for CC to write lessons learned to `PROGRESS.md` after task completion:
- Errors encountered and resolutions
- Key decisions and reasoning
- Useful patterns discovered
- Warnings for future sessions

Persists across sessions — next time CC resumes in the same project, it reads PROGRESS.md
and avoids repeating past mistakes.

```bash
dispatch -p "Fix the SIGBUS crash" -n "fix-crash" -a "code1" \
  -w "~/SLA" --bypass --progress
```

### 🔄 Ralph Loop (`--ralph N`)

Runs CC in a loop for N iterations. Each iteration gets a **fresh context window**:
1. Read `IMPLEMENTATION_PLAN.md` from disk → pick next task
2. Execute → commit → git push
3. Exit → next iteration starts fresh (avoids context degradation)

**Key insight**: Each iteration operates in the context "smart zone" (40-60% utilization).
The plan file on disk acts as shared state between otherwise isolated iterations.

**Combine with `--plan`** for the full Ralph workflow:
- First iteration creates the plan
- Subsequent iterations pick tasks from it

```bash
# Full Ralph: plan + loop 5 iterations + log progress
dispatch -p "Implement VSA training pipeline with gate compression" -n "vsa-train" -a "main" \
  -w "~/VSA" --bypass --plan --progress --ralph 5
```

**Ralph Loop behavior:**
- Iteration 1: Uses provided session flags (resume/session-id)
- Iterations 2+: Fresh sessions (no session flag → clean context)
- Each iteration pushes to git after completion
- If an iteration fails, it logs the error and continues to the next

### Combining Flags

| Combination | Use Case |
|---|---|
| `--plan` | Complex task, needs structure before coding |
| `--progress` | Any task, builds institutional memory |
| `--plan --progress` | Complex task + memory logging |
| `--plan --progress --ralph 5` | Full autonomous workflow (plan → execute N tasks → log) |
| `--ralph 3` | Simple iterative task (no planning phase) |

## Simple Dispatch (single task)

```
sessions_spawn task: |
  bash /home/ubuntu/.openclaw/workspace/scripts/claude-code/dispatch-to-unity.sh \
    -p "YOUR PROMPT" -n "task-name" -a "main" -w "/home/mingcanxiang_umass_edu/LightningDiT" --bypass
```

## Multi-Round Autonomous Workflow (裁判模式)

For complex tasks where the agent acts as judge, iterating with CC until satisfied.

### Architecture

```
Agent (裁判) → dispatch -n "task-A" -a "code1" --bypass --plan --progress --ralph 5
  CC on Unity → reads IMPLEMENTATION_PLAN.md → picks task → implements → commits
    → Ralph loop iterates (same session, plugin handles iterations)
      → All tasks done → <promise>ALL_TASKS_COMPLETE</promise>
        → hook notifies code1 instantly via /hooks/agent
Agent review (SSH read code on Unity)
  ├─ Not satisfied → dispatch -n "task-A" -a "code1" -p "feedback" (auto-resumes!)
  └─ Satisfied → notify Mitchell ✅
```

### Multi-Round Context Preservation

Each task gets a fixed `sessionKey: "hook:unity:{task_name}"`. All completion notifications
for the same task accumulate in the same hook session, preserving review context across rounds.

### Review Process

After each CC round completes, review by SSH reading files on Unity:

```bash
ssh unity "cd /path/to/workdir && git diff HEAD~1"
ssh unity "cat /path/to/file"
ssh unity "cd /path && python -m pytest 2>&1 | tail -20"
```

**Code review criteria**: Runs without errors + tests pass + clean style
**Paper review criteria**: Logic sound + no gaps + format correct

## Common Workdirs

- `/home/mingcanxiang_umass_edu/LightningDiT` — Main research project
- `/home/mingcanxiang_umass_edu` — Home directory

---

## Superpower / Agent Teams (按需启用)

> **默认**: Ralph Loop（机械迭代任务，有明确完成条件）
> **Superpower**: 当 Mitchell 的 prompt 里明确提到 "superpower" / "agent teams" 时启用
> 两者互斥 — 用 Superpower 时不加 `--ralph`，用 Ralph 时不加 Superpower prompt

### 何时用哪个

| 场景 | 用什么 |
|---|---|
| 默认 / 没特别说明 | Ralph Loop (`--ralph N`) |
| Mitchell prompt 提到 superpower / agent teams | Superpower（无 `--ralph`） |
| 创意决策、多专家协作 | Superpower |
| 机械迭代、有 plan 逐步执行 | Ralph Loop |

### Autonomous Prompt Template (Superpower)

When dispatching with Superpower, prepend this to the prompt (do NOT use `--ralph`):

```
AUTONOMOUS MODE: You are running without a human in the loop.
- For brainstorming: Propose your recommended approach, approve it yourself, proceed to implementation. Do NOT wait for user approval.
- For executing-plans: Execute ALL batches without stopping for feedback. Only stop on genuine errors/blockers.
- For all /superpower skills: Treat "ask the user" steps as "make your best judgment and proceed".
- Use /superpower skills as normal but skip all human confirmation gates.
- Use Agent Teams: create worker teammates for parallel tasks + 1 reviewer teammate for internal review.

TASK:
{actual prompt here}
```
