---
name: paper-polish
description: "Multi-agent LaTeX paper polishing using Gemini, Codex, and Claude in parallel worktrees. Each agent polishes with a different focus, then merges into a unified improved version with a change report."
---

# Paper Polish — Multi-Agent LaTeX Paper Polishing

## Overview

Three AI agents (Gemini, Codex, Claude) each polish the paper independently in isolated git worktrees, focusing on different aspects. The coordinator (you, Claude Code) merges all changes, resolves conflicts by choosing the best expression, and generates a detailed change report.

## Trigger

Activated when the user says: `/paper-polish`, "polish the paper", "润色论文", "paper polish", or similar.

## Prerequisites

- `gemini` CLI installed and authenticated
- `codex` CLI installed and authenticated
- Git repo with LaTeX source files
- Paper must compile (or at least have parseable .tex files)

## Workflow

### Phase 0: Orient

1. **Identify paper structure**: Find all `.tex` files in the project
2. **Classify files**:
   - **Content files** (to polish): main text, sections, abstract, appendix
   - **Skip**: `.bib`, `.sty`, `.cls`, preamble-only files, auto-generated files
3. **Read the experiments/results section FIRST** — this is ground truth for all claims
4. **Read the current branch name** — all merges go back here (NOT necessarily `main`)
5. **Note key metrics**: speedup numbers, accuracy figures, comparison baselines — these must be consistent everywhere

### Phase 1: Create Worktrees

```bash
BASE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
mkdir -p .worktrees

git worktree add .worktrees/polish-gemini -b wt/polish-gemini
git worktree add .worktrees/polish-codex -b wt/polish-codex
git worktree add .worktrees/polish-claude -b wt/polish-claude
```

### Phase 2: Dispatch Agents (Parallel)

Run all three agents **in parallel**. Each agent modifies files **in their own worktree**.

#### 🔵 Agent 1: Gemini — Consistency & Accuracy

**Focus**: Make sure the paper tells ONE coherent story backed by data.

**Execution**: For each content .tex file:
```bash
# Read the role prompt
ROLE=$(cat roles/gemini.md)

# For each content file, pipe through gemini
cd .worktrees/polish-gemini
for f in <content_files>; do
  cat "$f" | gemini -p "$ROLE

FILE: $f
EXPERIMENTS DATA: <paste key metrics from Phase 0>

Polish this LaTeX file. Output the COMPLETE improved file content (full LaTeX, no truncation). Do NOT add commentary — output ONLY the file content." > "${f}.improved"
  mv "${f}.improved" "$f"
done

git add -A && git commit -m "polish: consistency & accuracy (gemini)"
```

#### 🟢 Agent 2: Codex — Writing Quality & De-LLM

**Focus**: Make every sentence tight, clear, and free of AI writing artifacts.

**Execution**:
```bash
cd .worktrees/polish-codex
codex exec --sandbox read-only --ephemeral \
  "$(cat roles/codex.md)

Working directory: $(pwd)
Content files to polish: <list content files>

For each file: read it, improve the writing quality, and write the improved version back.
Focus on de-LLM, conciseness, and sentence structure.
Commit all changes with message: 'polish: writing quality & de-LLM (codex)'"
```

**If codex exec is unavailable**, fall back to piping each file:
```bash
for f in <content_files>; do
  cat "$f" | codex -p "$(cat roles/codex.md) ... output only improved file" > "${f}.improved"
  mv "${f}.improved" "$f"
done
git add -A && git commit -m "polish: writing quality & de-LLM (codex)"
```

#### 🟣 Agent 3: Claude — Structure & Flow

**Focus**: Logical coherence, smooth transitions, argument strength.

**Execution**: Use Task tool (subagent) or directly edit in the worktree:
```
For each content file in .worktrees/polish-claude/:
  1. Read the file
  2. Apply improvements per roles/claude.md
  3. Write improved version back
  4. Commit: "polish: structure & flow (claude)"
```

Since YOU are Claude, you can directly edit these files using your Edit tool.

### Phase 3: Merge

**Sequential merge with intelligent conflict resolution.**

```bash
cd <project_root>
git checkout $BASE_BRANCH

# Merge 1: Gemini (usually clean — first to merge)
git merge wt/polish-gemini -m "merge: gemini polish (consistency & accuracy)"

# Merge 2: Codex (may conflict with gemini's changes)
git merge wt/polish-codex -m "merge: codex polish (writing quality)"
# → If conflicts: resolve by reading both versions, choose better writing

# Merge 3: Claude (may conflict with gemini+codex changes)
git merge wt/polish-claude -m "merge: claude polish (structure & flow)"
# → If conflicts: resolve by reading both versions, choose better writing
```

**Conflict Resolution Rules:**
1. **Accuracy wins**: If one version has correct numbers and the other doesn't → pick accurate one
2. **Concise wins**: If both are accurate, pick the more concise version
3. **Synthesize**: If both versions have merit, write a new version combining the best of each
4. **Record every conflict resolution** in the change report (Phase 4)

### Phase 4: Cleanup

```bash
git worktree remove .worktrees/polish-gemini
git worktree remove .worktrees/polish-codex
git worktree remove .worktrees/polish-claude
git branch -d wt/polish-gemini wt/polish-codex wt/polish-claude
```

### Phase 5: Generate Report

Create `POLISH_REPORT.md` in the project root using `templates/report.md` format.

**⚠️ All emoji in the report MUST be preserved in the final output.**

The report must include:
- Summary of changes by each agent
- List of conflicts and how they were resolved
- Before/after examples for significant changes
- Statistics (files modified, lines changed per agent)

---

## Polishing Checklist

All three agents share this checklist. Each focuses on their assigned items, but all should be aware of the full list.

### 📊 Consistency & Accuracy (Gemini primary)
- [ ] All numbers in abstract/intro/conclusion match experiments section
- [ ] Speedup claims cite the correct baseline and conditions
- [ ] Table captions accurately describe content
- [ ] Figure references point to correct figures
- [ ] Terminology is consistent (same term for same concept, throughout)
- [ ] Abbreviations defined on first use, then used consistently
- [ ] Related work comparisons are factually accurate
- [ ] No claims without supporting evidence in the paper

### ✍️ Writing Quality & De-LLM (Codex primary)
- [ ] Sentences under 30 words (split long ones)
- [ ] Remove filler: "It is worth noting that" → delete, "In order to" → "To"
- [ ] Remove parenthetical dashes (— / –) → rewrite with commas, subordinate clauses, or split sentences (max 1-2 per paper)
- [ ] Reduce parenthetical overuse — long parentheticals (>8 words) become their own clause/sentence, max 2-3 per paragraph
- [ ] Remove unnecessary `\textbf{}` emphasis in running text (bold only for definitions, table headers, conventions)
- [ ] Remove LLM favorites: "leveraging"→"using", "utilize"→"use", "facilitate"→"enable", "pivotal"→"key", "landscape"→"field", "paradigm"→"approach", "multifaceted"→"complex", "myriad"→"many", "realm"→"area", "holistic"→"overall", "meticulous"→"careful", "plethora"→"many"
- [ ] Break Rule of Three — don't default to triplet lists/adjectives; vary list lengths (max 1 triplet per paragraph)
- [ ] Remove puffery: "stands as a testament to", "plays a pivotal role", "paving the way for", "opening exciting avenues"
- [ ] Authority claims ("studies have shown", "it is widely accepted") must have \cite{} or be rewritten
- [ ] Limit meta-narration: "In this section we examine..." → just start; max 1 signpost per section
- [ ] No generic conclusion filler: "As deep learning continues to evolve..." → delete
- [ ] Reduce "Furthermore/Moreover/Additionally" — max 2 per section
- [ ] Reduce subordinate clauses (especially nested ones)
- [ ] Vary sentence openings (not every sentence starts with "We")
- [ ] Remove redundant hedging: "somewhat", "relatively", "to some extent"
- [ ] Replace vague quantifiers with data: "significant" → actual numbers
- [ ] Consistent tense: past for experiments, present for established facts
- [ ] No dangling modifiers or unclear antecedents

### 🏗️ Structure & Flow (Claude primary)
- [ ] Abstract ↔ Introduction ↔ Conclusion alignment
- [ ] Every abstract claim backed by results in the paper
- [ ] Conclusion doesn't introduce new information
- [ ] Smooth transitions between paragraphs and sections
- [ ] Logical argument progression within each section
- [ ] Related work positions this paper fairly (not dismissive)
- [ ] Method section motivation is clear before technical details
- [ ] Each section has a clear purpose and takeaway

### 📐 Table Aesthetics (All agents)
- [ ] Table width fits column/page width (use `\resizebox{\columnwidth}{!}{...}` or `\adjustbox` if needed)
- [ ] Font size appropriate — use `\small` or `\footnotesize` for dense tables, never smaller than `\scriptsize`
- [ ] Font size consistent across ALL tables in the paper
- [ ] Table style matches the conference/journal template (booktabs `\toprule/\midrule/\bottomrule`, no vertical lines unless template requires)
- [ ] Column alignment sensible: numbers right-aligned, text left-aligned, headers centered
- [ ] No tables overflowing into margins
- [ ] Cell padding sufficient — not cramped, not too sparse
- [ ] Bold used only for best results or column headers, not random emphasis

### 🔧 LaTeX Hygiene (All agents)
- [ ] Math notation consistent: \mathbf vs \bm, \mathcal, etc.
- [ ] Reference format consistent: \cref vs \ref vs Section~\ref
- [ ] Number formatting: consistent commas (1,000 vs 1000)
- [ ] Units spacing: 1.33× (no space before ×)
- [ ] Table/figure placement near first reference
- [ ] No orphaned \label without \ref (or vice versa)

---

## Notes

- **Do NOT change the paper's core claims or methodology** — only improve how they're expressed
- **Do NOT add new content** — only improve existing content
- **Do NOT change notation or variable names** unless inconsistent
- **Preserve all \cite, \ref, \label commands** — don't break references
- **If a file is generated or auto-formatted**, skip it
- **Test compilation after merge** if possible (`latexmk` or `pdflatex`)
