# Notion MCP API Patterns

## Tool Loading Sequence

Load tools via ToolSearch before use:

```
ToolSearch: "+notion block children"    → get-block-children, patch-block-children
ToolSearch: "+notion delete block"      → delete-a-block
ToolSearch: "+notion retrieve block"    → retrieve-a-block
ToolSearch: "+notion retrieve page"     → retrieve-a-page
ToolSearch: "+notion patch page"        → patch-page (for updating properties)
```

## Page ID Extraction

Notion URLs follow these patterns:
```
https://www.notion.so/PAGE-TITLE-{page_id}
https://www.notion.so/PAGE-TITLE-{page_id}?v={view_id}
```

The page_id is the last 32 hex characters in the URL path (before any query params).
Insert hyphens to form UUID: `30387123-2f45-801b-9c2f-ff33838fb130`

## Block Types That Work

The MCP schema only defines `paragraph` and `bulleted_list_item` in `blockObjectRequest`,
but the server forwards requests to the Notion API transparently. These types all work:

### code block (VERIFIED)
```json
{
  "type": "code",
  "code": {
    "rich_text": [{"type": "text", "text": {"content": "code content here"}}],
    "language": "plain text"
  }
}
```

### heading_2 block
```json
{
  "type": "heading_2",
  "heading_2": {
    "rich_text": [{"type": "text", "text": {"content": "Section Title"}}]
  }
}
```

### heading_3 block
```json
{
  "type": "heading_3",
  "heading_3": {
    "rich_text": [{"type": "text", "text": {"content": "Subsection Title"}}]
  }
}
```

### paragraph block
```json
{
  "type": "paragraph",
  "paragraph": {
    "rich_text": [{"type": "text", "text": {"content": "text content"}}]
  }
}
```

### bulleted_list_item block
```json
{
  "type": "bulleted_list_item",
  "bulleted_list_item": {
    "rich_text": [{"type": "text", "text": {"content": "bullet text"}}]
  }
}
```

## Key API Operations

### Read all blocks
```
mcp__notion__API-get-block-children(block_id=page_id, page_size=100)
```
If `has_more=true`, use `start_cursor` for pagination.

### Insert blocks at position
```
mcp__notion__API-patch-block-children(
  block_id=page_id,
  after=anchor_block_id,   # insert after this block
  children=[...]            # array of block objects
)
```
Multiple children in one call are inserted in order after the anchor.

### Delete a block
```
mcp__notion__API-delete-a-block(block_id=block_id)
```

### Update page properties (e.g., summary)
```
mcp__notion__API-patch-page(page_id=page_id, properties={...})
```

## Parallel Operations

- Multiple `delete-a-block` calls can run in parallel safely
- Multiple `patch-block-children` calls with DIFFERENT `after` anchors can run in parallel
- Multiple `patch-block-children` calls with the SAME `after` anchor will race — run sequentially

## Notion rich_text Character Limit

Each rich_text content string has a 2000 character limit. For longer content,
split into multiple rich_text objects within the same block:

```json
{
  "rich_text": [
    {"type": "text", "text": {"content": "first 2000 chars..."}},
    {"type": "text", "text": {"content": "next 2000 chars..."}}
  ]
}
```
