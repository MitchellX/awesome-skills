---
name: notion-writer
description: Create, read, update, and query Notion pages. Triggers on /notion command or when user asks to write/create something in Notion. Default database is AI tool (2f9871232f4580b6bf51e923c03cb30f). Supports creating pages with rich content blocks, querying databases, and updating existing pages.
---

# Notion Writer

## Config

- **Token**: `REDACTED_NOTION_TOKEN`
- **Default Database**: `2f9871232f4580b6bf51e923c03cb30f` (AI tool)
- **API Version**: `2022-06-28`
- **Base URL**: `https://api.notion.com/v1`

## ⚠️ Always use sessions_spawn!

ALL Notion operations MUST run in a background sub-agent via `sessions_spawn`. Never block the main session.

Example spawn task:
```
Run the Notion API script to create a page.
Script: /home/ubuntu/.openclaw/workspace/skills/notion-writer/scripts/notion_api.py
Command: python3 <script> create --title "Page Title" --description "desc" --content-file /tmp/notion-content.json
First write the content JSON to /tmp/notion-content.json, then run the script.
```

Before spawning: write any content JSON to /tmp/ first (the sub-agent can also do this).

## Default Action: Create Page

When user asks to create/write something in Notion, spawn a sub-agent to create the page.

## /notion Commands

When user uses `/notion` prefix, spawn a sub-agent for the subcommand:

- `/notion create ...` — Create page
- `/notion read <page-id-or-url>` — Read page content
- `/notion update <page-id-or-url>` — Update page properties or content
- `/notion query [database-id-or-url]` — Query database, list pages
- `/notion search <keyword>` — Search across all pages

Script path: `SKILL_DIR/scripts/notion_api.py`

## Database Properties (AI tool)

The default database has these properties:

| Property | Type | Notes |
|----------|------|-------|
| Task name | title | Required |
| Description | rich_text | Optional |
| Status | status | "Not Started", "In progress", "Done" |
| Priority | select | Optional |
| Due | date | Optional |
| Assignee | people | Optional |

## Content Blocks

When creating rich content, build a JSON array of Notion blocks. Common types:

- `heading_2`, `heading_3` — Section headers
- `paragraph` — Text paragraphs
- `bulleted_list_item`, `numbered_list_item` — Lists
- `code` — Code blocks (set `language` field)
- `quote` — Blockquotes
- `divider` — Horizontal divider
- `toggle` — Collapsible sections
- `table` — Tables with rows and cells (use `has_column_header: true` for header row)

**⚠️ Tables for experiment results:** Always prefer `table` blocks over bullet lists for showing experiment data, benchmarks, comparisons, and metrics.

See `references/block-examples.json` for templates (includes table example).

## URL Parsing

Extract database/page ID from Notion URLs:
- `https://notion.so/<id>` → use `<id>`
- `https://notion.so/<title>-<id>` → extract last 32 hex chars as ID
- `https://notion.so/<workspace>/<id>?v=...` → extract `<id>`

Insert hyphens to format as UUID: `8-4-4-4-12` pattern.
