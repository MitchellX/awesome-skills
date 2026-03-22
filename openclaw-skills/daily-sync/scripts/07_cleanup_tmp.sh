#!/bin/bash
# Scan /tmp for stale files and generate cleanup candidates
# Does NOT delete anything — outputs a candidate list for AI review
#
# Output: /tmp/daily-sync/cleanup_tmp_candidates.md

set -euo pipefail
OUTPUT="${1:-/tmp/daily-sync}/cleanup_tmp_candidates.md"
mkdir -p "$(dirname "$OUTPUT")"

cat > "$OUTPUT" << 'HEADER'
# /tmp Cleanup Candidates

Review each section. For each item, decide: DELETE or KEEP.
After review, run the delete commands.

HEADER

# 1. Known stale directories
echo "## Stale Directories" >> "$OUTPUT"
FOUND=0
for dir in /tmp/add-skill-* /tmp/weasy-env /tmp/node_modules /tmp/paper-review /tmp/chromium-*; do
    if [ -d "$dir" ]; then
        SIZE=$(du -sh "$dir" 2>/dev/null | cut -f1)
        NEWEST=$(find "$dir" -type f -printf '%T+\n' 2>/dev/null | sort -r | head -1)
        echo "- [ ] \`$dir\` — $SIZE, newest file: ${NEWEST:-unknown}" >> "$OUTPUT"
        FOUND=$((FOUND + 1))
    fi
done
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 2. Stale temp files older than 7 days (known patterns)
echo "## Stale Files (>7 days)" >> "$OUTPUT"
FOUND=0
PATTERNS=(
    "notion_*.json" "notion_*.txt"
    "unity_*.json" "unity_*.txt" "unity_*.md"
    "linstat*.json" "linstat*.png" "linstat*.tex" "linstat*.py"
    "*-skill.md" "updated-skill.md" "awesome-skills-readme.md"
    "codex-*.log"
    "voice_msg.wav" "*.m4a" "yt_*.m4a"
    "package-lock.json"
)
for pattern in "${PATTERNS[@]}"; do
    while IFS= read -r f; do
        [ -z "$f" ] && continue
        SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
        DATE=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
        NAME=$(basename "$f")
        echo "- [ ] \`$NAME\` — $SIZE, last modified $DATE" >> "$OUTPUT"
        FOUND=$((FOUND + 1))
    done < <(find /tmp -maxdepth 1 -name "$pattern" -mtime +7 2>/dev/null)
done
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 3. Old notion-content temp files (>1 day)
echo "## Notion Content Temp Files (>1 day)" >> "$OUTPUT"
FOUND=0
for f in /tmp/notion-content.json /tmp/notion-content-*.json; do
    if [ -f "$f" ] && [ "$(find "$f" -mtime +1 2>/dev/null)" ]; then
        SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
        DATE=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
        echo "- [ ] \`$(basename "$f")\` — $SIZE, last modified $DATE" >> "$OUTPUT"
        FOUND=$((FOUND + 1))
    fi
done
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# 4. Other unrecognized large files (>1MB, >7 days, not in protected dirs)
echo "## Other Large Files (>1MB, >7 days)" >> "$OUTPUT"
FOUND=0
while IFS= read -r f; do
    [ -z "$f" ] && continue
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    DATE=$(stat -c '%y' "$f" 2>/dev/null | cut -d' ' -f1)
    NAME=$(basename "$f")
    echo "- [ ] \`$NAME\` — $SIZE, last modified $DATE" >> "$OUTPUT"
    FOUND=$((FOUND + 1))
done < <(find /tmp -maxdepth 1 -type f -size +1M -mtime +7 2>/dev/null | sort)
[ "$FOUND" -eq 0 ] && echo "_None_" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# Summary
TOTAL=$(grep -c '^\- \[ \]' "$OUTPUT" 2>/dev/null || echo 0)
echo "---" >> "$OUTPUT"
echo "**Total candidates: $TOTAL**" >> "$OUTPUT"
echo "" >> "$OUTPUT"
echo "⚠️ Protected (never delete): \`openclaw*/\`, \`jiti/\`, \`tmux-*/\`, \`systemd-*/\`, \`vscode-*/\`, \`claude-*/\`, \`daily-sync/\`" >> "$OUTPUT"

echo "📋 Scan complete: $TOTAL candidates → $OUTPUT"
cat "$OUTPUT"
