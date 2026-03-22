#!/bin/bash
# Clean up stale/temp files in ~/.openclaw/workspace
# Run as Phase 4b after /tmp cleanup
# Safe: only deletes known stale patterns, preserves core files

set -euo pipefail
WORKSPACE="$HOME/.openclaw/workspace"
cd "$WORKSPACE"

echo "🧹 Cleaning up workspace stale files..."

FREED_KB=0
REMOVED=0

# Helper: remove file and track
remove_file() {
    local f="$1"
    if [ -f "$f" ]; then
        local sz
        sz=$(du -sk "$f" 2>/dev/null | cut -f1)
        rm -f "$f"
        echo "   ✅ $f (${sz}KB)"
        FREED_KB=$((FREED_KB + sz))
        REMOVED=$((REMOVED + 1))
    fi
}

# Helper: remove dir and track
remove_dir() {
    local d="$1"
    if [ -d "$d" ]; then
        local sz
        sz=$(du -sm "$d" 2>/dev/null | cut -f1)
        rm -rf "$d"
        echo "   ✅ $d/ (${sz}MB)"
        FREED_KB=$((FREED_KB + sz * 1024))
        REMOVED=$((REMOVED + 1))
    fi
}

# 1. Old root-level PDFs (ICLR papers, already reviewed)
for f in "$WORKSPACE"/*.pdf; do
    [ -f "$f" ] || continue
    # Only delete PDFs older than 14 days
    if [ "$(find "$f" -mtime +14 2>/dev/null)" ]; then
        remove_file "$f"
    fi
done

# 2. Old root-level PNGs that are clearly temp (linstat_*, training_curves_*, model_complexity_*, ppt_*, sparsity_*)
STALE_IMG_PATTERNS=(
    "linstat_*.png"
    "linstat_*.pdf"
    "linstat_avatar*.png"
    "training_curves_*.png"
    "training_curves_*.pdf"
    "model_complexity_*.png"
    "ppt_*.png"
    "sparsity_*.png"
    "ai_everywhere.png"
)
for pattern in "${STALE_IMG_PATTERNS[@]}"; do
    for f in $WORKSPACE/$pattern; do
        [ -f "$f" ] || continue
        if [ "$(find "$f" -mtime +14 2>/dev/null)" ]; then
            remove_file "$f"
        fi
    done
done

# 3. Old markdown files that were one-off analysis
for f in "$WORKSPACE"/linstat_eccv_review.md "$WORKSPACE"/linstat_overview_prompt.md; do
    if [ -f "$f" ] && [ "$(find "$f" -mtime +14 2>/dev/null)" ]; then
        remove_file "$f"
    fi
done

# 4. Legacy Python scripts (replaced by notion-writer skill)
for f in "$WORKSPACE"/notion_append.py "$WORKSPACE"/notion_todo.py "$WORKSPACE"/update_notion.py; do
    if [ -f "$f" ] && [ "$(find "$f" -mtime +14 2>/dev/null)" ]; then
        remove_file "$f"
    fi
done

# 5. Old .skill packaging files
for f in "$WORKSPACE"/*.skill; do
    [ -f "$f" ] || continue
    if [ "$(find "$f" -mtime +14 2>/dev/null)" ]; then
        remove_file "$f"
    fi
done

# 6. Stale directories
#    temp/ — one-off file generation (fax, pptx, etc.)
if [ -d "$WORKSPACE/temp" ]; then
    # Only if all contents are >14 days old
    FRESH=$(find "$WORKSPACE/temp" -type f -mtime -14 2>/dev/null | head -1)
    if [ -z "$FRESH" ]; then
        remove_dir "$WORKSPACE/temp"
    fi
fi

#    skills-for-unity/ — old skill transfer dir, replaced by awesome-skills
remove_dir "$WORKSPACE/skills-for-unity"

#    data/codex-search-results/ — one-off deep search output
if [ -d "$WORKSPACE/data/codex-search-results" ]; then
    FRESH=$(find "$WORKSPACE/data/codex-search-results" -type f -mtime -14 2>/dev/null | head -1)
    if [ -z "$FRESH" ]; then
        remove_dir "$WORKSPACE/data/codex-search-results"
        # Remove data/ if now empty
        rmdir "$WORKSPACE/data" 2>/dev/null || true
    fi
fi

# 7. weekly_codes_update/ — legacy daily files, superseded by memory/weekly/
#    Keep last 7 days, delete older files
if [ -d "$WORKSPACE/weekly_codes_update" ]; then
    OLD_COUNT=0
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        rm -f "$f"
        OLD_COUNT=$((OLD_COUNT + 1))
    done < <(find "$WORKSPACE/weekly_codes_update" -name "*.md" -mtime +7 2>/dev/null)
    if [ "$OLD_COUNT" -gt 0 ]; then
        echo "   ✅ weekly_codes_update/: removed $OLD_COUNT old files (kept last 7 days)"
        REMOVED=$((REMOVED + OLD_COUNT))
    fi
fi

# 8. media/ — keep optimized versions, remove originals if optimized exists
if [ -d "$WORKSPACE/media" ]; then
    MEDIA_CLEANED=0
    for opt in "$WORKSPACE"/media/*-optimized.png; do
        [ -f "$opt" ] || continue
        original="${opt%-optimized.png}.png"
        if [ -f "$original" ]; then
            sz=$(du -sk "$original" 2>/dev/null | cut -f1)
            rm -f "$original"
            echo "   ✅ $(basename "$original") → kept optimized (saved ${sz}KB)"
            FREED_KB=$((FREED_KB + sz))
            MEDIA_CLEANED=$((MEDIA_CLEANED + 1))
        fi
    done
    if [ "$MEDIA_CLEANED" -gt 0 ]; then
        REMOVED=$((REMOVED + MEDIA_CLEANED))
    fi
fi

echo ""
FREED_MB=$((FREED_KB / 1024))
echo "   Removed $REMOVED items, freed ~${FREED_MB}MB"
echo "   ⚠️ Preserved: memory/, skills/, scripts/, gmail/, Claude_settings/, cron_backup/, notion_snapshots/"
