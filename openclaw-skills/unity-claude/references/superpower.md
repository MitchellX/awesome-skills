# Superpower / Agent Teams

## 何时使用

**只有** Mitchell 明确提到 "superpower" / "agent teams" 时才启用。
默认走 Ralph Loop，不用 Superpower。

两者互斥 — 用 Superpower 时**不加** `--ralph`，用 Ralph 时**不加** Superpower prompt。

## 何时用哪个

| 场景 | 用什么 |
|---|---|
| 默认 / 没特别说明 | Ralph Loop (`--ralph N`) |
| Mitchell prompt 提到 superpower / agent teams | Superpower（无 `--ralph`） |
| 创意决策、多专家协作 | Superpower |
| 机械迭代、有 plan 逐步执行 | Ralph Loop |

## Autonomous Prompt Template

When dispatching with Superpower, prepend this to the prompt (do NOT use `--ralph`).

**Step 1**: Pick the `TASK TYPE` that best matches the task:

| TASK TYPE | Superpower Skill to Load |
|---|---|
| `code-review` | `Skill(superpowers:requesting-code-review)` — dispatch code-reviewer subagent |
| `review-feedback` | `Skill(superpowers:receiving-code-review)` — verify feedback before implementing |
| `brainstorm` | `Skill(superpowers:brainstorm)` — explore requirements/design before coding |
| `plan` | `Skill(superpowers:write-plan)` — create detailed implementation plan |
| `execute-plan` | `Skill(superpowers:execute-plan)` — execute plan in batches |
| `implement` | `Skill(superpowers:brainstorm)` first, then implement |

**Step 2**: Use this template (fill in `{task_type}` and `{actual_prompt}`):

```
AUTONOMOUS MODE: You are running without a human in the loop.

TASK TYPE: {task_type}

SKILL ROUTING — You MUST load the correct superpower skill FIRST based on TASK TYPE:
- code-review → Load Skill(superpowers:requesting-code-review), dispatch code-reviewer subagent
- review-feedback → Load Skill(superpowers:receiving-code-review) before implementing changes
- brainstorm / implement → Load Skill(superpowers:brainstorm) before any creative work
- plan → Load Skill(superpowers:write-plan) to create detailed plan
- execute-plan → Load Skill(superpowers:execute-plan) to execute in batches

AUTONOMY RULES:
- Skip ALL human confirmation gates in skills
- Approve your own proposals and proceed to implementation
- Execute ALL batches without stopping for feedback
- Only stop on genuine errors/blockers
- Use Agent Teams when the skill suggests it (worker teammates for parallel tasks + reviewer for internal review)

TASK:
{actual_prompt}
```

## Example

```bash
dispatch -p "AUTONOMOUS MODE: ...
TASK TYPE: code-review
SKILL ROUTING — ...
TASK:
Review commit abc1234 for correctness and safety.
" -n "review-task" -a "code2" -w "~/LightningDiT" --bypass --new
```
