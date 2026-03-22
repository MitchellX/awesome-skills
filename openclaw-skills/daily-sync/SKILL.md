---
name: daily-sync
description: Daily sync job that snapshots Notion tasks, collects Unity git logs and Claude sessions, backs up settings, and writes two weekly files (memory/weekly_memory/ for daily summaries, memory/weekly_codes_update/ for code-only details). Triggers on daily-sync cron or when user asks to run daily sync.
---

# Daily Sync

Nightly job (00:50 EST) that collects the day's activity and writes a weekly memory file. 4 phases: data collection → AI summary → git push → cleanup.

## Quick Start

```bash
# Prepare temp dir
rm -rf /tmp/daily-sync && mkdir -p /tmp/daily-sync

# Phase 1: Data collection (run all scripts)
source ~/.bashrc  # ensure NOTION_TOKEN is available
python3 SKILL_DIR/scripts/01_notion_snapshot.py
bash SKILL_DIR/scripts/02_unity_git_log.sh
bash SKILL_DIR/scripts/03_unity_sessions.sh
bash SKILL_DIR/scripts/04_agent_sessions.sh
bash SKILL_DIR/scripts/05_backup_settings.sh

# Phase 2: AI summarizes and writes weekly file
# Phase 3: git add + commit + push
```

## Phase 1: Data Collection

Run these 5 scripts. They are independent and write to `/tmp/daily-sync/`.

### 1a. Notion Tasks Snapshot + Diff

```bash
python3 SKILL_DIR/scripts/01_notion_snapshot.py
```

- Queries **ALL tasks** from Notion Task List 2026 (no status filter)
- Saves snapshot to `workspace/notion_snapshots/task_list_2026_YYYY-MM-DD.json`
- Diffs against yesterday's snapshot
- Output: `/tmp/daily-sync/notion_diff.md`

### 1b. Unity Git Log

```bash
bash SKILL_DIR/scripts/02_unity_git_log.sh
```

- SSH to unity, get `git log --since=yesterday` for `~/paper` and `~/LightningDiT`
- Output: `/tmp/daily-sync/git_log.md`

### 1c. Unity Claude Sessions

```bash
bash SKILL_DIR/scripts/03_unity_sessions.sh
```

- Finds today's modified `.jsonl` session files under `~/.claude/projects/`
- Fetches last 50KB of each via SSH
- Output: `/tmp/daily-sync/unity_sessions/` (one file per session)
- ⚠️ Read actual session JSONL files, not just history.jsonl

### 1d. Local Agent Sessions

```bash
bash SKILL_DIR/scripts/04_agent_sessions.sh
```

- Scans all agents: main, code1, code2, paper, reviewer, gpt, talk, gemini
- Finds today's modified `.jsonl` files (excludes `.deleted.`)
- Fetches last 50KB of each
- Output: `/tmp/daily-sync/agent_sessions/` (one file per session)

### 2+3. Backup Settings + Cron

```bash
bash SKILL_DIR/scripts/05_backup_settings.sh
```

- SCP from Unity: `settings.json`, `CLAUDE.md`, `skills/*/SKILL.md` → `workspace/Claude_settings/`
- Copy `~/.openclaw/cron/jobs.json` → `workspace/cron_backup/jobs.json`

## Phase 2: Write Two Weekly Files

After all scripts complete, write to TWO files:

### Determine file paths

```bash
WEEKLY_FILE=$(python3 SKILL_DIR/scripts/06_weekly_helper.py)
# e.g. memory/weekly_memory/W12-2026-03-16.md
# The codes file uses the same week naming:
CODES_FILE=$(echo $WEEKLY_FILE | sed 's|/weekly_memory/|/weekly_codes_update/|')
```

### File A: `memory/weekly_codes_update/W{nn}-YYYY-MM-DD.md` — 代码详情 ONLY

Code-only log. No tasks, no emails, no daily summary — those go in weekly_memory.

**Content sources:**
1. `/tmp/daily-sync/git_log.md` — Full commit hashes and messages
2. `/tmp/daily-sync/unity_sessions/*.jsonl` — What code was discussed/changed on Unity

**Format:** See `references/example-weekly-codes.md`
- Section: `## YYYY-MM-DD (DayName)`
- Include ONLY: 💻 Code (full git log + diff summary), 🤖 Claude on Unity (code-related session details)
- NO tasks, NO emails, NO daily summary, NO agent session summary
- Append daily, don't overwrite

### File B: `memory/weekly_memory/W{nn}-YYYY-MM-DD.md` — 每日综合总结

High-level daily summary covering ALL aspects of Mitchell's day.

**Content sources:** ALL of `/tmp/daily-sync/` + File A as reference

**Format:** See `references/example-weekly.md`
- Section: `## YYYY-MM-DD (DayName)`
- Subsections by topic (use ### headers):
  - 🛠️ 工程 & 研究 — what was built, experimented, discovered
  - 💻 代码 — **brief summary only** + "详见 `memory/weekly_codes_update/`"
  - 📋 Notion 任务 — changes (completed/new/status changes), totals
  - 🔍 调研 — papers read, tools researched, conclusions
  - 💰 生活 & 个人 — non-work events (meals, travel, finance, etc.)
  - 🧠 系统改进 — OpenClaw/bot/skill changes
  - 📬 邮件 & 其他 — important emails, misc
- Skip empty subsections
- Be detailed! This is the main daily record Mitchell will read
- Append daily, don't overwrite

### Key difference

| | weekly_memory/ | weekly_codes_update/ |
|-|---------|---------------------|
| 范围 | Mitchell 的一天（全面） | 只有代码/session 技术细节 |
| 代码 | 一句话总结 + 索引 | 完整 git log + session 内容 |
| 受众 | Mitchell 快速浏览 | 需要查代码细节时参考 |

### If no activity

weekly_memory/:
```
## YYYY-MM-DD (DayName)

- 安静的一天，没有代码/研究活动
```

weekly_codes_update/:
```
## YYYY-MM-DD (DayName)

- 无新 commit，无活跃 session
```

## Phase 3: Git Sync

```bash
cd ~/.openclaw/workspace
git add -A
git commit -m "daily sync: YYYY-MM-DD"
git push
```

## Cron Integration

The cron job message should simply be:

```
执行 daily-sync skill。读取 skill 的 SKILL.md 并按流程执行所有 Phase。
```

## Phase 4: Cleanup

### 4a. Clean /tmp (AI-reviewed)

**Step 1: Scan**

```bash
bash SKILL_DIR/scripts/07_cleanup_tmp.sh
```

Output: `/tmp/daily-sync/cleanup_tmp_candidates.md` — checklist of stale dirs/files.

**Step 2: AI Review** — read the candidate list and decide for each item:
- `add-skill-*`, `weasy-env`, `node_modules` → one-off installs, safe to delete
- `notion_*`, `unity_*`, `linstat*` >7 days → old temp data, usually safe
- Large files >1MB >7 days → check name/extension, delete if clearly temp
- When in doubt, KEEP

**Step 3: Delete** — run `rm` commands only for confirmed items

- ⚠️ Never touches: `openclaw/`, `jiti/`, `tmux-*`, `systemd-*`, `vscode-*`, `claude-*`, `daily-sync/`

### 4b. Clean workspace (AI-reviewed)

**Step 1: Scan** — generate candidate list

```bash
bash SKILL_DIR/scripts/08_cleanup_workspace.sh
```

Output: `/tmp/daily-sync/cleanup_candidates.md` — checklist of files/dirs that may be stale.

**Step 2: AI Review** — read the candidate list and decide for each item:
- Consider: is this file still referenced? Was it a one-off or ongoing?
- PDFs older than 14 days with paper-like names → likely reviewed, safe to delete
- Root images (linstat_*, training_curves_*, ppt_*) → temp visualizations, safe to delete
- Legacy .py/.skill files superseded by skills → safe to delete
- `weekly_codes_update/*.md` with daily naming (YYYY-MM-DD.md) → old format, should have been merged into weekly files
- `media/` originals when optimized exists → keep optimized, delete original
- When in doubt, KEEP

**Step 3: Delete** — run `rm` commands only for items you decided to delete

```bash
# Example (only after AI review):
rm -f ~/.openclaw/workspace/some_old_file.pdf
rm -rf ~/.openclaw/workspace/temp/
```

- ⚠️ Never touches: `memory/`, `skills/`, `scripts/`, `gmail/`, `Claude_settings/`, `cron_backup/`, `notion_snapshots/`, core .md files

## Troubleshooting

- **SSH to Unity fails**: Unity may be down or session expired. Log the error, skip Unity steps (1b, 1c, backup), continue with local steps.
- **Notion API fails**: Check NOTION_TOKEN env var. Fallback: `source ~/.bashrc` before running.
- **No yesterday snapshot**: First run or missed day. Diff will show all tasks as "new". This is fine.
