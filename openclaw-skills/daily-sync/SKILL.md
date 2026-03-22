---
name: daily-sync
description: Daily sync job that snapshots Notion tasks, collects Unity git logs and Claude sessions, backs up settings, and writes weekly memory files. Triggers on daily-sync cron or when user asks to run daily sync. Covers 5 tasks - Notion snapshot+diff, Unity git log, Unity Claude sessions, local agent sessions, settings backup, weekly file update, and git push.
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

## Phase 2: Write Weekly File

After all scripts complete, summarize the collected data into the weekly memory file.

### Determine the correct file

```bash
WEEKLY_FILE=$(python3 SKILL_DIR/scripts/06_weekly_helper.py)
```

### Content sources to read and summarize

1. `/tmp/daily-sync/notion_diff.md` — Task changes (new, status changes, completed)
2. `/tmp/daily-sync/git_log.md` — Code commits
3. `/tmp/daily-sync/unity_sessions/*.jsonl` — What Mitchell and Claude discussed on Unity
4. `/tmp/daily-sync/agent_sessions/*.jsonl` — What Mitchell did across all agents

### Writing format

- Append to the weekly file (do NOT overwrite)
- Section header: `## YYYY-MM-DD (DayName)`
- Write in bullet points, concise but detailed
- Group by topic, not by source
- Focus on: what was done, decisions made, problems found, things learned
- See `references/example-weekly.md` for format reference

### If no activity

If all sources are empty (no commits, no sessions, no task changes), write:
```
## YYYY-MM-DD (DayName)

- 安静的一天，没有代码/研究活动
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

### 4a. Clean /tmp

```bash
bash SKILL_DIR/scripts/07_cleanup_tmp.sh
```

- Removes known stale dirs: `add-skill-*`, `weasy-env`, `node_modules`, `paper-review`, `chromium-*`
- Removes stale temp files older than 7 days matching known patterns (notion_*, unity_*, linstat*, etc.)
- Cleans up old notion-content JSON files (>1 day)
- ⚠️ Never touches: `openclaw/`, `jiti/`, `tmux-*`, `systemd-*`, `vscode-*`, `claude-*`

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
- `weekly_codes_update/*.md` >7 days → superseded by `memory/weekly/`, safe to delete
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
