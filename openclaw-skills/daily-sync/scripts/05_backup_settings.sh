#!/bin/bash
# Backup Claude settings from Unity + cron jobs definition
# Output: workspace/Claude_settings/ + workspace/cron_backup/

set -euo pipefail
WORKSPACE="$HOME/.openclaw/workspace"

echo "📦 Backing up Claude settings from Unity..."
mkdir -p "$WORKSPACE/Claude_settings/skills"

# settings.json
scp unity:~/.claude/settings.json "$WORKSPACE/Claude_settings/settings.json" 2>/dev/null && \
    echo "   ✅ settings.json" || echo "   ⚠️ settings.json not found"

# CLAUDE.md
scp unity:~/.claude/CLAUDE.md "$WORKSPACE/Claude_settings/CLAUDE.md" 2>/dev/null && \
    echo "   ✅ CLAUDE.md" || echo "   ⚠️ CLAUDE.md not found"

# Skills SKILL.md files
SKILL_DIRS=$(ssh unity 'ls -d ~/.claude/skills/*/ 2>/dev/null' 2>/dev/null || true)
if [ -n "$SKILL_DIRS" ]; then
    while IFS= read -r skill_dir; do
        skill_name=$(basename "$skill_dir")
        mkdir -p "$WORKSPACE/Claude_settings/skills/$skill_name"
        scp "unity:${skill_dir}SKILL.md" "$WORKSPACE/Claude_settings/skills/$skill_name/SKILL.md" 2>/dev/null && \
            echo "   ✅ skills/$skill_name/SKILL.md" || true
    done <<< "$SKILL_DIRS"
fi

echo ""
echo "📦 Backing up cron jobs definition..."
mkdir -p "$WORKSPACE/cron_backup"
cp "$HOME/.openclaw/cron/jobs.json" "$WORKSPACE/cron_backup/jobs.json"
echo "   ✅ cron_backup/jobs.json"
