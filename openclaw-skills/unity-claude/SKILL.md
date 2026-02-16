---
name: unity-claude
description: Dispatch Claude Code tasks to Unity HPC via SSH. Use when user asks to run Claude Code on Unity, dispatch a coding task to Unity, or asks Unity's Claude to do something (read/analyze/modify code on Unity). Also triggers on "dispatch to unity", "ask unity claude", "在unity上跑". Tasks run in background via sessions_spawn, auto-notify on completion via Discord.
---

# Unity Claude Code Dispatcher

## ⚠️ Always use sessions_spawn!

ALL dispatch operations MUST run via `sessions_spawn`. Never block the main session.

## Scripts

All at `/home/ubuntu/.openclaw/workspace/scripts/claude-code/`

- `dispatch-to-unity.sh` — Main dispatcher (auto-resume support)
- `watch-unity-results.sh` — Polls completion, notifies via /hooks/agent
- `check-unity-results.sh` — One-shot manual check

## Dispatch Parameters

| Flag | Description |
|------|-------------|
| `-p "prompt"` | Task prompt (required) |
| `-n name` | Task name (**key for session tracking**) |
| `-w /path` | Workdir on Unity |
| `--new` | Force fresh session (clears saved session for this task name) |
| `--resume UUID` | Resume explicit session (overrides auto) |
| `--session-id UUID` | Start with explicit UUID (overrides auto) |
| `--bypass` | bypassPermissions mode |
| `--clean` | Clear saved session for this task name |
| `--clean-all` | Clear all saved sessions |

## Session Management (Auto-Resume)

**The dispatch script automatically manages sessions by task name.**

- Same `-n name` → **auto-resumes** the previous session (keeps context, saves tokens)
- Different `-n name` → completely isolated session
- `--new` → force fresh session even if one exists for this name
- Session state stored in `scripts/claude-code/active-tasks/{name}.json`

**You do NOT need to manually track session IDs anymore.**

### Examples

```bash
# First dispatch — auto-creates new session, saves to active-tasks/optimize-attn.json
dispatch -p "Optimize the attention module" -n "optimize-attn" -w "/path" --bypass

# Follow-up — auto-resumes same session (CC has full context from round 1)
dispatch -p "Now add benchmarks for the changes you made" -n "optimize-attn" -w "/path" --bypass

# Unrelated task — different name, separate session
dispatch -p "Fix the data loader bug" -n "fix-dataloader" -w "/path" --bypass

# Force fresh start on existing task
dispatch -p "Start over with a different approach" -n "optimize-attn" -w "/path" --new --bypass
```

## Simple Dispatch (single task)

```
sessions_spawn task: |
  bash /home/ubuntu/.openclaw/workspace/scripts/claude-code/dispatch-to-unity.sh \
    -p "YOUR PROMPT" -n "task-name" -w "/home/mingcanxiang_umass_edu/LightningDiT" --bypass
```

Note: No need for `--new` or `--session-id` — auto-session handles it.
For follow-ups on the same task, just use the same `-n` name.

## Multi-Round Autonomous Workflow

For complex tasks where Luke acts as judge, iterating until satisfied.

### Architecture

```
Luke (裁判) → dispatch -n "task-A" --bypass
  CC Lead → /superpower skills → Workers + Reviewer teammates
    → Workers execute → Reviewer internal review → complete
      → hook notifies Luke
Luke review (SSH read code on Unity)
  ├─ Not satisfied → dispatch -n "task-A" -p "feedback" (auto-resumes!)
  └─ Satisfied → dispatch -n "task-A-review" --new (diff reviewer)
      └─ Pass → notify Mitchell ✅
```

### Autonomous Prompt Template

When dispatching with /superpower + Agent Teams, prepend this to the prompt:

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

### Luke Review Process

After each CC round completes, review by SSH reading files on Unity:

```bash
ssh unity "cd /path/to/workdir && git diff HEAD~1"
ssh unity "cat /path/to/file"
ssh unity "cd /path && python -m pytest 2>&1 | tail -20"
```

**Code review criteria**: Runs without errors + tests pass + clean style
**Paper review criteria**: Logic sound + no gaps + format correct

### Diff Reviewer (Final Step)

Dispatch a **separate** session to review the cumulative git diff:

```
dispatch -p "Review git diff for this branch..." \
  -n "diff-review" -w "/path" --new --bypass
```

## Common Workdirs

- `/home/mingcanxiang_umass_edu/LightningDiT` — Main research project
- `/home/mingcanxiang_umass_edu` — Home directory
