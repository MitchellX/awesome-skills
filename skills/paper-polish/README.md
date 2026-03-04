# paper-polish

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Multi-agent LaTeX paper polishing using Gemini, Codex, and Claude in parallel git worktrees. Three modes for different needs.

## Modes

### Round 1 — Specialized Roles (Default)

Each agent focuses on a different aspect → auto-merge → single polished output.

```
/paper-polish
  ├── Create 3 git worktrees
  │   ├── 🔵 Gemini → Consistency & Accuracy
  │   ├── 🟢 Codex  → Writing Quality & De-LLM
  │   └── 🟣 Claude → Structure & Flow
  ├── Each agent polishes .tex files in their worktree
  ├── Sequential auto-merge back to current branch
  │   └── Conflicts resolved by choosing best expression
  └── Generate POLISH_REPORT.md
```

**Best for:** Quick iteration, minimal conflicts, automated output.

### Round 2 — Full Review (`--full`)

All agents apply the **same comprehensive checklist** → no auto-merge → comparison report for human review.

```
/paper-polish --full
  ├── Create 3 git worktrees
  │   ├── 🔵 Gemini → ALL checklist items
  │   ├── 🟢 Codex  → ALL checklist items
  │   └── 🟣 Claude → ALL checklist items
  ├── Each agent polishes .tex files independently
  ├── NO auto-merge — export diffs as .patch files
  ├── Generate .polish/COMPARISON_REPORT.md
  │   ├── ✅ Consensus (3/3) — safe to adopt
  │   ├── 🟡 Majority (2/3) — quick review
  │   ├── 🔴 Unique (1/3) — review carefully
  │   └── ⚡ Conflicts — human picks best
  └── Keep branches for cherry-picking
```

**Best for:** Final polish before submission, leveraging each model's unique strengths.

### Claude-Only (`--claude`)

Claude applies the **full comprehensive checklist** solo. No Gemini/Codex CLIs needed.

```
/paper-polish --claude
  ├── Create 1 git worktree
  │   └── 🟣 Claude → ALL checklist items (unified.md)
  ├── Claude polishes all .tex files
  ├── Auto-merge back to current branch
  └── Generate POLISH_REPORT.md
```

**Best for:** When you have ample Claude credits (Max subscription) and want thorough single-agent polish without extra CLI dependencies.

## Agent Roles (Round 1)

| Agent | Focus | What They Fix |
|-------|-------|---------------|
| 🔵 Gemini | Consistency & Accuracy | Numbers match experiments, terminology unified, claims backed by data, table aesthetics |
| 🟢 Codex | Writing Quality & De-LLM | Remove AI writing patterns, shorten sentences, cut filler, fix tense |
| 🟣 Claude | Structure & Flow | Logical transitions, abstract↔conclusion alignment, argument strength |

## De-LLM Checklist (Highlights)

- **Vocabulary**: Replace AI-tell words (leverage→use, pivotal→key, landscape→field, paradigm→approach, etc.)
- **Dashes**: Remove em dash (—) parenthetical overuse (max 1-2 per paper)
- **Parentheses**: Long parentheticals (>8 words) become their own clause
- **Bold**: Remove `\textbf{}` emphasis in running text
- **Rule of Three**: Don't default to triplet patterns; vary list lengths
- **Puffery**: Delete "stands as a testament to", "paving the way for future research"
- **Pseudo-authority**: "Studies have shown" must have `\cite{}` or be rewritten
- **Meta-narration**: "In this section we examine..." → just start; max 1 per section
- **Generic conclusions**: "As deep learning continues to evolve..." → delete
- **Filler**: "It is worth noting that" → delete
- **Transitions**: Max 2 "Furthermore/Moreover/Additionally" per section
- **Hedging**: Replace vague qualifiers with actual numbers
- **Tense**: Past for experiments, present for established facts

## Usage

```bash
# Round 1 (default — specialized roles, auto-merge):
/paper-polish

# Round 2 (full review — same task, human merge):
/paper-polish --full

# Claude-only (full checklist, single agent, auto-merge):
/paper-polish --claude
```

## Output

### Round 1
- Polished paper (merged on current branch)
- `POLISH_REPORT.md` — change log with before/after examples

### Round 2
- `.polish/gemini.patch` — Gemini's full diff
- `.polish/codex.patch` — Codex's full diff
- `.polish/claude.patch` — Claude's full diff
- `.polish/COMPARISON_REPORT.md` — three-way comparison grouped by consensus level
- Branches kept: `wt/polish-gemini`, `wt/polish-codex`, `wt/polish-claude`

```bash
# Round 2: cherry-pick changes
git checkout wt/polish-codex -- path/to/file.tex   # adopt agent's version
git diff wt/polish-gemini..wt/polish-codex          # compare two agents

# Cleanup when done
git branch -d wt/polish-gemini wt/polish-codex wt/polish-claude
rm -rf .polish/
```

## Directory Structure

```
paper-polish/
├── SKILL.md                        # Main skill definition (Round 1 + Round 2 workflows)
├── README.md                       # This file
├── roles/
│   ├── gemini.md                   # Round 1: Consistency & Accuracy
│   ├── codex.md                    # Round 1: Writing Quality & De-LLM
│   ├── claude.md                   # Round 1: Structure & Flow
│   └── unified.md                  # Round 2: All tasks combined (shared by all agents)
└── templates/
    ├── report.md                   # Round 1: Change report template
    └── report-comparison.md        # Round 2: Three-way comparison report template
```

## License

MIT License
