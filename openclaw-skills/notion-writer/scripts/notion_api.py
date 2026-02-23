#!/usr/bin/env python3
"""Notion API client for OpenClaw skill.

Usage:
    notion_api.py create --title TITLE [--db DATABASE_ID] [--description DESC] [--status STATUS] [--priority PRIORITY] [--content-file FILE]
    notion_api.py read PAGE_ID
    notion_api.py update PAGE_ID [--title TITLE] [--description DESC] [--status STATUS] [--content-file FILE] [--append]
    notion_api.py query [DATABASE_ID] [--filter-status STATUS] [--limit N]
    notion_api.py search KEYWORD [--limit N]
"""

import argparse
import json
import re
import sys
import requests

TOKEN = "REDACTED_NOTION_TOKEN"
DEFAULT_DB = "2f9871232f4580b6bf51e923c03cb30f"
API_VERSION = "2022-06-28"
BASE_URL = "https://api.notion.com/v1"

HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Notion-Version": API_VERSION,
    "Content-Type": "application/json",
}


def parse_notion_id(url_or_id: str) -> str:
    """Extract and format Notion ID from URL or raw ID."""
    # Remove query params
    url_or_id = url_or_id.split("?")[0].rstrip("/")
    # Extract last 32 hex chars
    match = re.search(r"([0-9a-f]{32})$", url_or_id.replace("-", ""))
    if match:
        raw = match.group(1)
        return f"{raw[:8]}-{raw[8:12]}-{raw[12:16]}-{raw[16:20]}-{raw[20:]}"
    return url_or_id


def api_request(method, endpoint, json_data=None):
    """Make API request and handle errors."""
    url = f"{BASE_URL}/{endpoint}"
    resp = requests.request(method, url, headers=HEADERS, json=json_data)
    if resp.status_code not in (200, 202):
        print(f"❌ Error {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)
    return resp.json()


def cmd_create(args):
    """Create a new page in a database."""
    db_id = parse_notion_id(args.db or DEFAULT_DB)

    properties = {
        "Task name": {"title": [{"text": {"content": args.title}}]},
    }
    if args.description:
        properties["Description"] = {
            "rich_text": [{"text": {"content": args.description}}]
        }
    if args.status:
        properties["Status"] = {"status": {"name": args.status}}
    if args.priority:
        properties["Priority"] = {"select": {"name": args.priority}}

    page_data = {"parent": {"database_id": db_id}, "properties": properties}

    # Add content blocks
    if args.content_file:
        with open(args.content_file) as f:
            page_data["children"] = json.load(f)

    result = api_request("POST", "pages", page_data)
    page_id = result["id"]
    clean_id = page_id.replace("-", "")
    print(f"✅ Page created: https://notion.so/{clean_id}")
    print(json.dumps({"id": page_id, "url": f"https://notion.so/{clean_id}"}, indent=2))


def cmd_read(args):
    """Read a page's properties and content."""
    page_id = parse_notion_id(args.page_id)

    # Get properties
    page = api_request("GET", f"pages/{page_id}")
    print("## Properties")
    props = page.get("properties", {})
    for name, prop in props.items():
        ptype = prop["type"]
        if ptype == "title":
            texts = prop.get("title", [])
            val = "".join(t.get("plain_text", "") for t in texts)
        elif ptype == "rich_text":
            texts = prop.get("rich_text", [])
            val = "".join(t.get("plain_text", "") for t in texts)
        elif ptype == "status":
            val = (prop.get("status") or {}).get("name", "")
        elif ptype == "select":
            val = (prop.get("select") or {}).get("name", "")
        elif ptype == "date":
            val = (prop.get("date") or {}).get("start", "")
        else:
            val = f"[{ptype}]"
        if val:
            print(f"  {name}: {val}")

    # Get content blocks
    blocks = api_request("GET", f"blocks/{page_id}/children")
    print("\n## Content")
    for block in blocks.get("results", []):
        btype = block["type"]
        data = block.get(btype, {})
        texts = data.get("rich_text", [])
        text = "".join(t.get("plain_text", "") for t in texts)
        if btype.startswith("heading"):
            level = btype[-1]
            print(f"{'#' * int(level)} {text}")
        elif btype == "bulleted_list_item":
            print(f"  • {text}")
        elif btype == "numbered_list_item":
            print(f"  1. {text}")
        elif btype == "code":
            lang = data.get("language", "")
            print(f"```{lang}\n{text}\n```")
        elif btype == "table":
            # Fetch table children (rows)
            table_blocks = api_request("GET", f"blocks/{block['id']}/children")
            for row in table_blocks.get("results", []):
                if row["type"] == "table_row":
                    cells = row["table_row"]["cells"]
                    row_text = " | ".join(
                        "".join(t.get("plain_text", "") for t in cell)
                        for cell in cells
                    )
                    print(f"  | {row_text} |")
        elif btype == "divider":
            print("---")
        else:
            print(text)


def cmd_update(args):
    """Update a page's properties or append content."""
    page_id = parse_notion_id(args.page_id)

    # Update properties
    properties = {}
    if args.title:
        properties["Task name"] = {"title": [{"text": {"content": args.title}}]}
    if args.description:
        properties["Description"] = {
            "rich_text": [{"text": {"content": args.description}}]
        }
    if args.status:
        properties["Status"] = {"status": {"name": args.status}}

    if properties:
        api_request("PATCH", f"pages/{page_id}", {"properties": properties})
        print("✅ Properties updated")

    # Append content
    if args.content_file:
        with open(args.content_file) as f:
            children = json.load(f)
        api_request("PATCH", f"blocks/{page_id}/children", {"children": children})
        print("✅ Content appended")


def cmd_query(args):
    """Query a database."""
    db_id = parse_notion_id(args.database_id or DEFAULT_DB)

    query = {"page_size": args.limit or 10}
    if args.filter_status:
        query["filter"] = {
            "property": "Status",
            "status": {"equals": args.filter_status},
        }

    result = api_request("POST", f"databases/{db_id}/query", query)
    for page in result.get("results", []):
        props = page.get("properties", {})
        title_prop = props.get("Task name", {}).get("title", [])
        title = "".join(t.get("plain_text", "") for t in title_prop)
        status = (props.get("Status", {}).get("status") or {}).get("name", "")
        pid = page["id"].replace("-", "")
        print(f"  [{status}] {title} — https://notion.so/{pid}")


def cmd_search(args):
    """Search across all pages."""
    result = api_request(
        "POST", "search", {"query": args.keyword, "page_size": args.limit or 10}
    )
    for page in result.get("results", []):
        props = page.get("properties", {})
        title_prop = props.get("Task name", props.get("title", {}))
        if isinstance(title_prop, dict):
            texts = title_prop.get("title", [])
        else:
            texts = []
        title = "".join(t.get("plain_text", "") for t in texts) or "[untitled]"
        pid = page["id"].replace("-", "")
        print(f"  {title} — https://notion.so/{pid}")


def main():
    parser = argparse.ArgumentParser(description="Notion API client")
    sub = parser.add_subparsers(dest="command", required=True)

    # create
    p = sub.add_parser("create")
    p.add_argument("--title", required=True)
    p.add_argument("--db")
    p.add_argument("--description")
    p.add_argument("--status", default="Not Started")
    p.add_argument("--priority")
    p.add_argument("--content-file")

    # read
    p = sub.add_parser("read")
    p.add_argument("page_id")

    # update
    p = sub.add_parser("update")
    p.add_argument("page_id")
    p.add_argument("--title")
    p.add_argument("--description")
    p.add_argument("--status")
    p.add_argument("--content-file")
    p.add_argument("--append", action="store_true")

    # query
    p = sub.add_parser("query")
    p.add_argument("database_id", nargs="?")
    p.add_argument("--filter-status")
    p.add_argument("--limit", type=int)

    # search
    p = sub.add_parser("search")
    p.add_argument("keyword")
    p.add_argument("--limit", type=int)

    args = parser.parse_args()
    {"create": cmd_create, "read": cmd_read, "update": cmd_update, "query": cmd_query, "search": cmd_search}[args.command](args)


if __name__ == "__main__":
    main()
