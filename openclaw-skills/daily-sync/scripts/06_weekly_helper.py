#!/usr/bin/env python3
"""Helper to determine the correct weekly file path and ensure it exists.

Usage:
    06_weekly_helper.py [--date YYYY-MM-DD]

Prints the weekly file path to stdout. Creates the file with header if it doesn't exist.
"""

import argparse
import os
from datetime import datetime, timedelta

WEEKLY_DIR = os.path.expanduser("~/.openclaw/workspace/memory/weekly_memory")
CODES_DIR = os.path.expanduser("~/.openclaw/workspace/memory/weekly_codes_update")


def get_weekly_info(date: datetime) -> tuple[str, int, datetime, datetime]:
    """Return (filename, week_number, monday_date, sunday_date)."""
    # Monday = 0, Sunday = 6
    days_since_monday = date.weekday()
    monday = date - timedelta(days=days_since_monday)
    sunday = monday + timedelta(days=6)
    week_num = int(monday.strftime("%V"))
    filename = f"W{week_num:02d}-{monday.strftime('%Y-%m-%d')}.md"
    return filename, week_num, monday, sunday


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--date", help="Date to use (YYYY-MM-DD), default today")
    args = parser.parse_args()

    if args.date:
        date = datetime.strptime(args.date, "%Y-%m-%d")
    else:
        date = datetime.now()

    filename, week_num, monday, sunday = get_weekly_info(date)
    filepath = os.path.join(WEEKLY_DIR, filename)

    os.makedirs(WEEKLY_DIR, exist_ok=True)
    os.makedirs(CODES_DIR, exist_ok=True)

    codes_filepath = os.path.join(CODES_DIR, filename)

    if not os.path.exists(filepath):
        header = f"# 周记：{monday.strftime('%Y-%m-%d')} ~ {sunday.strftime('%m-%d')}\n"
        with open(filepath, "w") as f:
            f.write(header)
        print(f"Created: {filepath}", file=__import__("sys").stderr)

    if not os.path.exists(codes_filepath):
        header = f"# Weekly Code Update: {monday.strftime('%Y-%m-%d')} ~ {sunday.strftime('%m-%d')}\n"
        with open(codes_filepath, "w") as f:
            f.write(header)
        print(f"Created: {codes_filepath}", file=__import__("sys").stderr)

    # Print both paths for callers (line 1: weekly, line 2: codes)
    print(filepath)
    print(codes_filepath)

    # Also print today's section header for convenience
    day_names = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    day_name = day_names[date.weekday()]
    section = f"\n## {date.strftime('%Y-%m-%d')} ({day_name})\n"
    print(section, file=__import__("sys").stderr)


if __name__ == "__main__":
    main()
