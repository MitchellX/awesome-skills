# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Claude Code **skill** (plugin) that provides multi-agent code review capabilities. It orchestrates Gemini CLI, Codex CLI, and Claude to review git diffs in parallel, then merges findings into a unified report.

## Architecture

The skill follows a pipeline architecture:

1. **Diff Collection**: Get git diff from uncommitted changes
2. **Expertise Detection**: Auto-detect code type (training/inference ML code) using pattern matching rules in `expertise/_index.md`
3. **Parallel Review**: Execute selected reviewers simultaneously
4. **Coordination**: Merge findings from all reviewers into a unified report

### Key Files

- `SKILL.md` - Main skill definition with YAML frontmatter (required format for skills.sh compatibility)
- `reviewers/*.md` - Role prompts for each reviewer (gemini, codex, claude) plus coordinator logic
- `expertise/*.md` - Domain-specific review prompts auto-injected based on code patterns
- `expertise/_index.md` - Pattern matching rules that map trigger patterns → expertise files
- `templates/report.md` - Output format template

### Extension Points

**Adding new expertise**: Create `expertise/<name>.md` with domain prompts, then add detection rules to `expertise/_index.md` table. The skill auto-detects and injects matching expertise into reviewer prompts.

**Adding new reviewers**: Create `reviewers/<name>-role.md` with the reviewer's system prompt.

## Skill Invocation

```bash
/diff-review                    # Multi-agent mode (all reviewers)
/diff-review --reviewer=gemini  # Single reviewer
/diff-review --reviewer=auto    # Auto-select based on code characteristics
```

## Prerequisites for Testing

The skill requires external CLI tools:
- Gemini CLI (`gemini`)
- Codex CLI (`codex`)
