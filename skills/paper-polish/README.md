# paper-polish

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | [简体中文](README_CN.md)

Multi-agent LaTeX paper polishing using Gemini, Codex, and Claude in parallel git worktrees. Each agent focuses on a different aspect of writing quality, then changes are merged with intelligent conflict resolution.

## How It Works

```
paper-polish
  ├── Create 3 git worktrees
  │   ├── 🔵 Gemini → Consistency & Accuracy
  │   ├── 🟢 Codex  → Writing Quality & De-LLM
  │   └── 🟣 Claude → Structure & Flow
  ├── Each agent polishes all .tex files in their worktree
  ├── Sequential merge back to current branch
  │   └── Conflicts resolved by choosing best expression
  └── Generate POLISH_REPORT.md with all changes
```

## Agent Roles

| Agent | Focus | What They Fix |
|-------|-------|---------------|
| 🔵 Gemini | Consistency & Accuracy | Numbers match experiments, terminology unified, claims backed by data |
| 🟢 Codex | Writing Quality | De-LLM (remove AI writing patterns), shorten sentences, cut filler phrases |
| 🟣 Claude | Structure & Flow | Logical transitions, abstract↔conclusion alignment, argument strength |

## Polishing Checklist

- **Data consistency**: All numbers in abstract/intro/conclusion match experiments
- **De-LLM**: Remove "leveraging/utilizing/Furthermore" spam, shorten long sentences
- **Terminology**: Same concept = same term throughout
- **Tense**: Past for experiments, present for established facts
- **Flow**: Smooth transitions, no orphan paragraphs
- **LaTeX**: Consistent \cref/\ref, math notation, number formatting

## Usage

```bash
# In a paper's git repo:
/paper-polish
```

## Output

- Polished paper (merged changes on current branch)
- `POLISH_REPORT.md` — detailed change log with before/after examples and conflict resolutions

## Directory Structure

```
paper-polish/
├── SKILL.md              # Main skill definition & workflow
├── README.md             # This file
├── roles/
│   ├── gemini.md         # Gemini's polishing instructions
│   ├── codex.md          # Codex's polishing instructions
│   └── claude.md         # Claude's polishing instructions
└── templates/
    └── report.md         # Change report template
```

## License

MIT License
