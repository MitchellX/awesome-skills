# techdebt

[![Skills.sh](https://img.shields.io/badge/skills.sh-available-blue)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A technical debt auditor skill that uses **4 parallel subagents** to scan your codebase for duplicated code, code smells, architectural issues, and maintenance risks. Inspired by [Boris Cherny's tip](https://x.com/bcherny/status/2017742748984742078): "Build a /techdebt slash command and run it at the end of every session to find and kill duplicated code."

## Features

- **Parallel Analysis**: 4 specialized subagents scan simultaneously for maximum speed
- **Categorized Findings**: Duplication, Code Smells, Architecture, Maintenance Risks
- **Severity Ranking**: Issues ranked High / Medium / Low with actionable suggestions
- **Scoped Scanning**: Target specific directories or categories
- **Quick Wins**: Top 3 easy fixes highlighted at the end of every report

## Architecture

```
/techdebt

     ┌──────────────────────────────────────────────────────┐
     │          Step 1: Determine Scope & Languages          │
     └──────────────────────────────────────────────────────┘
                              │
          ┌───────────┬───────┴───────┬───────────┐
          │           │               │           │
          ▼           ▼               ▼           ▼
    ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐
    │ Duplication│ │Code Smells│ │Architecture│ │Maintenance│
    │  Scanner  │ │ Detector  │ │  Analyzer  │ │Risk Finder│
    │(subagent) │ │(subagent) │ │(subagent)  │ │(subagent) │
    └─────┬─────┘ └─────┬─────┘ └─────┬─────┘ └─────┬─────┘
          │             │               │             │
          └─────────────┴───────┬───────┴─────────────┘
                                │
                                ▼
     ┌──────────────────────────────────────────────────────┐
     │              Merge, Dedupe & Rank                     │
     │                                                       │
     │   • Deduplicate cross-agent findings                  │
     │   • Assign severity (High > Medium > Low)             │
     │   • Trim to top N findings                            │
     │   • Generate summary table + quick wins               │
     └──────────────────────────────────────────────────────┘
```

## What Each Agent Scans

| Agent | Focus Areas |
|-------|-------------|
| **Duplication Scanner** | Copy-pasted logic, near-duplicate functions, repeated magic numbers, reimplemented stdlib utilities |
| **Code Smell Detector** | Long functions (>50 lines), too many params (>5), deep nesting (>3 levels), dead code, naming inconsistency |
| **Architecture Analyzer** | Circular imports, god modules (>500 lines), missing abstractions, tight coupling, layer violations |
| **Maintenance Risk Finder** | Stale TODO/FIXME/HACK comments, deprecated API usage, missing error handling, type safety gaps, hardcoded config |

## Installation

### Via skills.sh (Recommended)

```bash
npx skills add https://github.com/mitchellx/awesome-skills --skill techdebt
```

### Manual Installation

```bash
# Clone and symlink
git clone https://github.com/MitchellX/awesome-skills.git /tmp/awesome-skills
cp -r /tmp/awesome-skills/skills/techdebt ~/.claude/skills/techdebt
```

## Usage

```bash
# Full codebase scan (default: top 15 findings)
/techdebt

# Scan specific directory
/techdebt --scope=src/models/

# Focus on a single category
/techdebt --category=duplication
/techdebt --category=smells
/techdebt --category=architecture
/techdebt --category=maintenance

# Limit number of findings
/techdebt --top=5

# Combine options
/techdebt --scope=src/ --category=duplication --top=10
```

## Report Example

```markdown
## Technical Debt Report

**Scope**: src/
**Files scanned**: 42
**Findings**: 12 (3 High, 5 Medium, 4 Low)

---

### Summary

| Category       | High | Medium | Low | Total |
|----------------|------|--------|-----|-------|
| Duplication    | 1    | 2      | 1   | 4     |
| Code Smells    | 1    | 1      | 2   | 4     |
| Architecture   | 1    | 1      | 0   | 2     |
| Maintenance    | 0    | 1      | 1   | 2     |
| **Total**      | 3    | 5      | 4   | 12    |

---

### Findings

#### [HIGH] #1: Duplicated attention mask logic
- **Category**: Duplication
- **Location**: `models/attention.py:45`, `models/cross_attention.py:62`
- **Description**: Nearly identical 15-line mask computation in two files
- **Suggestion**: Extract to shared `build_attention_mask()` utility

...

### Quick Wins (Top 3)

1. **Remove 8 unused imports** — delete dead imports across 4 files (trivial)
2. **Extract duplicated mask logic** — one shared function replaces 2 copies (small)
3. **Add constants for magic numbers** — replace 5 hardcoded values in config (small)
```

## Directory Structure

```
techdebt/
├── README.md          # This file
└── SKILL.md           # Skill definition & workflow
```

## License

MIT License - see [LICENSE](../../LICENSE) for details.

## Acknowledgments

- Inspired by Boris Cherny's Claude Code team tip: "Build a /techdebt slash command and run it at the end of every session"
- [10 Tips from Inside the Claude Code Team](https://paddo.dev/blog/claude-code-team-tips/)
