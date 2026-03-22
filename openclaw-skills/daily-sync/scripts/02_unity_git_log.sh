#!/bin/bash
# Collect git logs from Unity repos (paper + LightningDiT)
# Output: /tmp/daily-sync/git_log.md

set -euo pipefail
OUTPUT_DIR="${1:-/tmp/daily-sync}"
mkdir -p "$OUTPUT_DIR"
OUTPUT="$OUTPUT_DIR/git_log.md"

echo "# Unity Git Log" > "$OUTPUT"
echo "" >> "$OUTPUT"

for repo in paper LightningDiT; do
    echo "💻 Fetching git log for ~/$repo..."
    echo "## $repo" >> "$OUTPUT"
    echo '```' >> "$OUTPUT"
    log=$(ssh unity "cd ~/$repo 2>/dev/null && git log --since='yesterday' --oneline --no-decorate 2>/dev/null" 2>/dev/null || echo "(no recent commits or repo not found)")
    if [ -z "$log" ]; then
        echo "(no commits since yesterday)" >> "$OUTPUT"
    else
        echo "$log" >> "$OUTPUT"
    fi
    echo '```' >> "$OUTPUT"
    echo "" >> "$OUTPUT"
done

echo "   Output: $OUTPUT"
cat "$OUTPUT"
