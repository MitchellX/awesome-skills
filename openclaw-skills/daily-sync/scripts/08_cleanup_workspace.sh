#!/bin/bash
# Scan workspace for stale/temp files and generate cleanup candidates
# Does NOT delete anything — outputs a candidate list for AI review
#
# Output: /tmp/daily-sync/cleanup_candidates.md

set -euo pipefail
WORKSPACE="$HOME/.openclaw/workspace"
OUTPUT="${1:-/tmp/daily-sync}/cleanup_candidates.md"
mkdir -p "$(dirname "$OUTPUT")"

cd "$WORKSPACE"

cat > "$OUTPUT" << 'HEADER'
# Workspace Cleanup Candidates

Review each section. For each file/dir, decide: DELETE or KEEP.
After review, run the delete commands.

HEADER

# 1. Root-level PDFs older than 14 days
echo "## Root PDFs (>14 days)" >> "$OUTPUT"
FOUND=0
while IFS= read -r f; do
    [ -z "$f" ] && continue
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    DATE=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
    NAME=$(basename "$f")
    echo "- [ ] \`$NAME\` — $SIZE, last modified $DATE" >> "$OUTPUT"
    FOUND=$((FOUND + 1))
done < <(find . -maxdepth 1 -name "*.pdf" -mtime +14 2>/dev/null)
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 2. Root-level images older than 14 days
echo "## Root Images (>14 days)" >> "$OUTPUT"
FOUND=0
while IFS= read -r f; do
    [ -z "$f" ] && continue
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    DATE=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
    NAME=$(basename "$f")
    echo "- [ ] \`$NAME\` — $SIZE, last modified $DATE" >> "$OUTPUT"
    FOUND=$((FOUND + 1))
done < <(find . -maxdepth 1 \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" \) -mtime +14 2>/dev/null | sort)
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 3. Root-level scripts/misc older than 14 days
echo "## Root Scripts & Misc (>14 days)" >> "$OUTPUT"
FOUND=0
while IFS= read -r f; do
    [ -z "$f" ] && continue
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    DATE=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
    NAME=$(basename "$f")
    echo "- [ ] \`$NAME\` — $SIZE, last modified $DATE" >> "$OUTPUT"
    FOUND=$((FOUND + 1))
done < <(find . -maxdepth 1 \( -name "*.py" -o -name "*.skill" -o -name "*.html" -o -name "*.tex" \) -mtime +14 2>/dev/null | sort)
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 4. Stale directories
echo "## Potentially Stale Directories" >> "$OUTPUT"
for d in temp skills-for-unity data/codex-search-results; do
    if [ -d "$WORKSPACE/$d" ]; then
        SIZE=$(du -sh "$WORKSPACE/$d" 2>/dev/null | cut -f1)
        NEWEST=$(find "$WORKSPACE/$d" -type f -printf '%T+\n' 2>/dev/null | sort -r | head -1)
        FILE_COUNT=$(find "$WORKSPACE/$d" -type f 2>/dev/null | wc -l)
        echo "- [ ] \`$d/\` — $SIZE, $FILE_COUNT files, newest: ${NEWEST:-unknown}" >> "$OUTPUT"
    fi
done
echo "" >> "$OUTPUT"

# 5. weekly_codes_update older than 7 days
echo "## weekly_codes_update (>7 days, superseded by memory/weekly/)" >> "$OUTPUT"
FOUND=0
while IFS= read -r f; do
    [ -z "$f" ] && continue
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    NAME=$(basename "$f")
    echo "- [ ] \`$NAME\` — $SIZE" >> "$OUTPUT"
    FOUND=$((FOUND + 1))
done < <(find "$WORKSPACE/weekly_codes_update" -name "*.md" -mtime +7 2>/dev/null | sort)
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 6. media/ originals with optimized versions
echo "## media/ Originals (optimized version exists)" >> "$OUTPUT"
FOUND=0
for opt in "$WORKSPACE"/media/*-optimized.png; do
    [ -f "$opt" ] || continue
    original="${opt%-optimized.png}.png"
    if [ -f "$original" ]; then
        ORIG_SIZE=$(du -sh "$original" 2>/dev/null | cut -f1)
        OPT_SIZE=$(du -sh "$opt" 2>/dev/null | cut -f1)
        NAME=$(basename "$original")
        echo "- [ ] \`$NAME\` ($ORIG_SIZE) → optimized: $OPT_SIZE" >> "$OUTPUT"
        FOUND=$((FOUND + 1))
    fi
done
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Summary
TOTAL=$(grep -c '^\- \[ \]' "$OUTPUT" 2>/dev/null || echo 0)
echo "---" >> "$OUTPUT"
echo "**Total candidates: $TOTAL**" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "⚠️ Protected (never delete): memory/, skills/, scripts/, gmail/, Claude_settings/, cron_backup/, notion_snapshots/, *.md in root (MEMORY.md, SOUL.md, etc.)" >> "$OUTPUT"

echo "📋 Scan complete: $TOTAL candidates → $OUTPUT"
cat "$OUTPUT"
