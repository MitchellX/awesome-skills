#!/bin/bash
# Clean up /tmp: remove daily-sync working dir and stale temp files
# Safe: only deletes known patterns, never touches openclaw/jiti/systemd/tmux/vscode

set -euo pipefail

echo "🧹 Cleaning up /tmp..."

FREED=0

# /tmp/daily-sync/ 不清理 — 只有 ~300KB，下次 Phase 1 会自动覆盖

# 1. Remove known stale temp dirs (skill packaging, pip venvs, node_modules)
for dir in /tmp/add-skill-* /tmp/weasy-env /tmp/node_modules /tmp/paper-review /tmp/chromium-*; do
    if [ -d "$dir" ]; then
        SIZE=$(du -sm "$dir" 2>/dev/null | cut -f1)
        rm -rf "$dir"
        echo "   ✅ $dir (${SIZE}MB)"
        FREED=$((FREED + SIZE))
    fi
done

# 3. Remove stale temp files older than 7 days (known safe patterns)
STALE_PATTERNS=(
    "notion_*.json"
    "notion_*.txt"
    "unity_*.json"
    "unity_*.txt"
    "unity_*.md"
    "linstat*.json"
    "linstat*.png"
    "linstat*.tex"
    "linstat*.py"
    "*-skill.md"
    "updated-skill.md"
    "awesome-skills-readme.md"
    "codex-*.log"
    "voice_msg.wav"
    "*.m4a"
    "yt_*.m4a"
    "package-lock.json"
)

STALE_COUNT=0
for pattern in "${STALE_PATTERNS[@]}"; do
    while IFS= read -r file; do
        [ -z "$file" ] && continue
        SIZE_KB=$(du -sk "$file" 2>/dev/null | cut -f1)
        rm -f "$file"
        echo "   ✅ $file (${SIZE_KB}KB)"
        STALE_COUNT=$((STALE_COUNT + 1))
    done < <(find /tmp -maxdepth 1 -name "$pattern" -mtime +7 2>/dev/null)
done

# 4. Remove Notion content temp files (created by notion-writer skill)
for file in /tmp/notion-content.json /tmp/notion-content-*.json; do
    if [ -f "$file" ] && [ "$(find "$file" -mtime +1 2>/dev/null)" ]; then
        rm -f "$file"
        echo "   ✅ $file (stale >1 day)"
        STALE_COUNT=$((STALE_COUNT + 1))
    fi
done

echo ""
echo "   Freed ~${FREED}MB from dirs, removed $STALE_COUNT stale files."
echo "   ⚠️ Preserved: openclaw/, jiti/, tmux/, systemd/, vscode/ (runtime dirs)"
