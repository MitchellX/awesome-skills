---
name: notion-organizer
description: >
  Automatically organize and optimize Notion page content given a Notion URL.
  Use when user shares a Notion page link and wants to clean up, reorganize,
  or improve the page. Triggers on: "organize my Notion page", "clean up this
  Notion", "format this Notion link", sharing a notion.so URL with request to
  improve/restructure/整理 content. Performs: format correction (code blocks
  for code/diagrams/formulas), structure reorganization (headings, sections),
  and content quality improvements. Does NOT read local code — only works with
  Notion page content.
---

# Notion Organizer

Automatically analyze and optimize a Notion page's content, formatting, and structure.

## Workflow

### 1. Extract Page ID and Load Tools

Extract the 32-char hex page ID from the Notion URL (last segment before query params).
Format as UUID with hyphens: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`.

Load Notion MCP tools via ToolSearch — see [references/notion-api-patterns.md](references/notion-api-patterns.md) for tool names and loading sequence.

### 2. Read Current Page Content

Fetch all blocks with `get-block-children` (paginate if `has_more=true`).
For each block, record: `id`, `type`, `plain_text` content.

### 3. Analyze and Plan

Evaluate each block against these criteria:

**Format issues** (must fix):
- Code, flow diagrams, formulas, shape transforms, or ASCII art in `paragraph` blocks → convert to `code` blocks
- Section titles in `paragraph` blocks → convert to `heading_2` or `heading_3`
- List items in `paragraph` blocks → convert to `bulleted_list_item`
- Empty paragraph blocks used as spacers between sections → remove (headings provide spacing)

**Structure issues** (reorganize):
- Flat structure without headings → add hierarchical headings
- Content in wrong order → reorder logically
- Missing context or transitions → add brief connecting text
- Overly long blocks → split into focused sub-sections

**Content quality** (improve):
- Redundant or repeated text → consolidate
- Vague descriptions → make precise
- Inconsistent terminology → unify
- Missing key information that can be inferred from surrounding context → supplement

### 4. Execute Changes

**Strategy: targeted replacement, not full rewrite.**

For blocks that only need type changes (paragraph → code):
1. Delete the old block
2. Insert a new block of the correct type at the same position using `after` parameter

For structural reorganization:
1. Delete blocks that need to move or merge
2. Insert new blocks in the correct order using `after` anchors

**Maximize parallel operations:**
- Delete multiple blocks in parallel (one API call per block)
- Insert at different `after` anchors in parallel
- Never insert at the same `after` anchor in parallel (race condition)

### 5. Verify

After all changes, fetch blocks again with `get-block-children` to confirm structure.
Report a summary of changes made.

## Block Type Decision Guide

| Content Type | Block Type | Example |
|---|---|---|
| Code snippets, API calls | `code` | `self.qkv = nn.Linear(dim, dim*3)` |
| Flow diagrams with box-drawing chars | `code` | `├─ step1 → step2` |
| Math formulas, tensor shapes | `code` | `φ(x) = elu(x) + 1` |
| ASCII tables, parameter listings | `code` | Structured param comparison |
| Section titles (level 2) | `heading_2` | `═══ Section Name ═══` |
| Sub-section titles (level 3) | `heading_3` | `--- Subsection ---` |
| Enumerated points, options | `bulleted_list_item` | Feature list, pros/cons |
| Explanatory text, descriptions | `paragraph` | Normal prose |

## Key Constraints

- All Notion content should be written in Chinese (中文), following user's global preference
- Code block `language` field: use `"plain text"` for diagrams/formulas, actual language name for code
- The MCP schema only lists paragraph/bulleted_list_item, but code/heading blocks work — see [references/notion-api-patterns.md](references/notion-api-patterns.md)
- Each rich_text content string: max 2000 characters; split into multiple rich_text objects if needed
- Do NOT read local files or codebase — the skill only works with Notion page content
