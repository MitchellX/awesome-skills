#!/usr/bin/env python3
"""Snapshot Notion Task List 2026 and diff against yesterday's snapshot.

Usage:
    01_notion_snapshot.py [--db DATABASE_ID] [--snapshot-dir DIR] [--output DIR]

Output:
    - Saves snapshot to <snapshot-dir>/task_list_2026_YYYY-MM-DD.json
    - Writes diff summary to <output>/notion_diff.md
"""

import argparse
import json
import os
import sys
from datetime import datetime, timedelta

import requests

TOKEN = os.environ.get("NOTION_TOKEN", "")
if not TOKEN:
    # Fallback: read from ~/.notion_token
    token_file = os.path.expanduser("~/.notion_token")
    if os.path.exists(token_file):
        TOKEN = open(token_file).read().strip()
if not TOKEN:
    print("❌ NOTION_TOKEN not set and ~/.notion_token not found", file=sys.stderr)
    sys.exit(1)

DEFAULT_DB = "2fe871232f45808997d1d770add2f215"  # Task List 2026
API_VERSION = "2022-06-28"
BASE_URL = "https://api.notion.com/v1"
HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Notion-Version": API_VERSION,
    "Content-Type": "application/json",
}


def query_all_tasks(db_id: str) -> list[dict]:
    """Query ALL tasks from the database (no status filter), handling pagination."""
    all_results = []
    has_more = True
    start_cursor = None

    while has_more:
        body = {"page_size": 100}
        if start_cursor:
            body["start_cursor"] = start_cursor

        resp = requests.post(
            f"{BASE_URL}/databases/{db_id}/query",
            headers=HEADERS,
            json=body,
        )
        resp.raise_for_status()
        data = resp.json()
        all_results.extend(data.get("results", []))
        has_more = data.get("has_more", False)
        start_cursor = data.get("next_cursor")

    return all_results


def extract_task_info(page: dict) -> dict:
    """Extract simplified task info from a Notion page object."""
    props = page.get("properties", {})

    # Title
    title = ""
    for key in ("Name", "Task name", "Title", "title"):
        if key in props:
            title_prop = props[key]
            if title_prop.get("type") == "title":
                parts = title_prop.get("title", [])
                title = "".join(p.get("plain_text", "") for p in parts)
                break

    # Status (can be 'status' or 'select' type)
    status = ""
    for key in ("Status", "Status 1"):
        if key in props:
            status_prop = props[key]
            stype = status_prop.get("type", "")
            if stype == "status" and status_prop.get("status"):
                status = status_prop["status"].get("name", "")
            elif stype == "select" and status_prop.get("select"):
                status = status_prop["select"].get("name", "")
            if status:
                break

    return {
        "id": page.get("id", ""),
        "title": title,
        "status": status,
    }


def load_snapshot(path: str) -> dict[str, dict]:
    """Load a snapshot file, return {id: task_info}."""
    if not os.path.exists(path):
        return {}
    with open(path) as f:
        tasks = json.load(f)
    return {t["id"]: t for t in tasks}


def compute_diff(old: dict[str, dict], new: dict[str, dict]) -> str:
    """Compute diff between two snapshots, return markdown summary."""
    old_ids = set(old.keys())
    new_ids = set(new.keys())

    added = new_ids - old_ids
    removed = old_ids - new_ids
    common = old_ids & new_ids

    lines = ["# Notion Tasks Diff\n"]

    # Status changes
    status_changes = []
    for tid in common:
        old_status = old[tid].get("status", "")
        new_status = new[tid].get("status", "")
        if old_status != new_status:
            status_changes.append((new[tid]["title"], old_status, new_status))

    if status_changes:
        lines.append("## Status Changes\n")
        for title, old_s, new_s in status_changes:
            lines.append(f"- **{title}**: {old_s or '(none)'} → {new_s or '(none)'}")
        lines.append("")

    if added:
        lines.append("## New Tasks\n")
        for tid in added:
            t = new[tid]
            lines.append(f"- **{t['title']}** [{t.get('status', '')}]")
        lines.append("")

    if removed:
        lines.append("## Removed Tasks\n")
        for tid in removed:
            t = old[tid]
            lines.append(f"- ~~{t['title']}~~ [{t.get('status', '')}]")
        lines.append("")

    # Summary by status
    status_counts: dict[str, int] = {}
    for t in new.values():
        s = t.get("status", "(none)") or "(none)"
        status_counts[s] = status_counts.get(s, 0) + 1

    lines.append("## Current Status Summary\n")
    for s, count in sorted(status_counts.items()):
        lines.append(f"- **{s}**: {count}")
    lines.append("")

    if not added and not removed and not status_changes:
        lines.append("_No changes since yesterday._\n")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Notion Task List snapshot + diff")
    parser.add_argument("--db", default=DEFAULT_DB, help="Database ID")
    parser.add_argument(
        "--snapshot-dir",
        default=os.path.expanduser("~/.openclaw/workspace/notion_snapshots"),
        help="Directory to save snapshots",
    )
    parser.add_argument(
        "--output",
        default="/tmp/daily-sync",
        help="Output directory for diff",
    )
    args = parser.parse_args()

    os.makedirs(args.snapshot_dir, exist_ok=True)
    os.makedirs(args.output, exist_ok=True)

    today = datetime.now().strftime("%Y-%m-%d")
    yesterday = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")

    print(f"📋 Querying Notion database {args.db} (all statuses)...")
    raw_results = query_all_tasks(args.db)
    tasks = [extract_task_info(page) for page in raw_results]
    print(f"   Found {len(tasks)} tasks")

    # Save today's snapshot
    snapshot_path = os.path.join(args.snapshot_dir, f"task_list_2026_{today}.json")
    with open(snapshot_path, "w") as f:
        json.dump(tasks, f, indent=2, ensure_ascii=False)
    print(f"   Snapshot saved: {snapshot_path}")

    # Load yesterday's snapshot and diff
    yesterday_path = os.path.join(args.snapshot_dir, f"task_list_2026_{yesterday}.json")
    old_tasks = load_snapshot(yesterday_path)
    new_tasks = {t["id"]: t for t in tasks}

    diff_md = compute_diff(old_tasks, new_tasks)
    diff_path = os.path.join(args.output, "notion_diff.md")
    with open(diff_path, "w") as f:
        f.write(diff_md)
    print(f"   Diff written: {diff_path}")

    # Print diff to stdout too
    print("\n" + diff_md)


if __name__ == "__main__":
    main()
