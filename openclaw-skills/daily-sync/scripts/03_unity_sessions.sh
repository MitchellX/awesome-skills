#!/bin/bash
# Collect today's Unity Claude Code session JSONL files
# Output: /tmp/daily-sync/unity_sessions/ (one file per session)

set -euo pipefail
OUTPUT_DIR="${1:-/tmp/daily-sync}/unity_sessions"
mkdir -p "$OUTPUT_DIR"

echo "🤖 Collecting Unity Claude sessions..."

# Find today's modified session files
SESSION_FILES=$(ssh unity 'find ~/.claude/projects/ -name "*.jsonl" -mtime 0 2>/dev/null' 2>/dev/null || true)

if [ -z "$SESSION_FILES" ]; then
    echo "   No Unity Claude sessions modified today."
    echo "No Unity Claude sessions modified today." > "$OUTPUT_DIR/_empty.txt"
    exit 0
fi

COUNT=0
while IFS= read -r remote_path; do
    # Create safe local filename from path
    safe_name=$(echo "$remote_path" | sed 's|/|__|g' | sed 's|^__||')
    local_path="$OUTPUT_DIR/$safe_name"

    echo "   Fetching: $remote_path"
    # Get last 50KB of each session file
    ssh unity "tail -c 50000 '$remote_path' 2>/dev/null" > "$local_path" 2>/dev/null || true
    COUNT=$((COUNT + 1))
done <<< "$SESSION_FILES"

echo "   Collected $COUNT session files → $OUTPUT_DIR"
