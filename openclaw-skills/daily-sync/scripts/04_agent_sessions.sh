#!/bin/bash
# Collect today's local OpenClaw agent session JSONL files
# Output: /tmp/daily-sync/agent_sessions/ (one file per session)

set -euo pipefail
OUTPUT_DIR="${1:-/tmp/daily-sync}/agent_sessions"
AGENTS_DIR="$HOME/.openclaw/agents"
mkdir -p "$OUTPUT_DIR"

echo "💬 Collecting local agent sessions..."

AGENTS=(main code1 code2 paper reviewer gpt talk gemini)
COUNT=0

for agent in "${AGENTS[@]}"; do
    agent_sessions_dir="$AGENTS_DIR/$agent/sessions"
    [ -d "$agent_sessions_dir" ] || continue

    # Find today's modified JSONL files (exclude deleted)
    while IFS= read -r filepath; do
        [ -z "$filepath" ] && continue
        basename=$(basename "$filepath")
        local_path="$OUTPUT_DIR/${agent}__${basename}"

        # Get last 50KB
        tail -c 50000 "$filepath" > "$local_path" 2>/dev/null || true
        COUNT=$((COUNT + 1))
    done < <(find "$agent_sessions_dir" -name "*.jsonl" -mtime 0 ! -name "*.deleted.*" 2>/dev/null)
done

if [ "$COUNT" -eq 0 ]; then
    echo "   No agent sessions modified today."
    echo "No agent sessions modified today." > "$OUTPUT_DIR/_empty.txt"
else
    echo "   Collected $COUNT session files → $OUTPUT_DIR"
fi
