---
name: paper-polish
description: "Multi-agent LaTeX paper polishing using Gemini, Codex, and Claude in parallel worktrees. Round 1 (default): specialized roles, auto-merged. Round 2 (--full): all agents same task, comparison report. Claude-only (--claude): single agent, full checklist, auto-merged."
---

# Paper Polish — Multi-Agent LaTeX Paper Polishing

## Overview

Three modes for different needs:

- **Round 1** (default): Each agent has a specialized focus → auto-merge → `POLISH_REPORT.md`
- **Round 2** (`--full`): All agents apply the full checklist → no auto-merge → comparison report for human review
- **Claude-only** (`--claude`): Claude applies the full checklist solo → auto-merge → `POLISH_REPORT.md`

## Trigger

- **Round 1**: `/paper-polish`, "polish the paper", "润色论文"
- **Round 2**: `/paper-polish --full`, "deep polish", "全面润色", "paper polish round 2"
- **Claude-only**: `/paper-polish --claude`, "只用Claude", "claude only polish"

## Prerequisites

- **Round 1 & Round 2**: `gemini` CLI + `codex` CLI installed and authenticated
- **Claude-only**: No extra CLIs needed — Claude handles everything
- Git repo with LaTeX source files
- Paper must compile (or at least have parseable .tex files)

---

# Round 1 — Specialized Roles (Default)

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
ROLE=$(cat roles/gemini.md)

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

# Round 2 — Full Review (--full)

## Overview

All three agents apply the **same comprehensive checklist** (`roles/unified.md`). This maximizes coverage by leveraging each model's unique strengths and blind spots. The output is a **comparison report** for human review — no auto-merge.

## Workflow

### Phase 0–1: Same as Round 1

Orient and create worktrees identically.

### Phase 2: Dispatch Agents (Parallel — Same Task)

All three agents use `roles/unified.md` as their prompt. Each modifies files **in their own worktree**.

#### 🔵 Agent 1: Gemini

```bash
ROLE=$(cat roles/unified.md)

cd .worktrees/polish-gemini
for f in <content_files>; do
  cat "$f" | gemini -p "$ROLE

FILE: $f
EXPERIMENTS DATA: <paste key metrics from Phase 0>

Polish this LaTeX file. Output the COMPLETE improved file content (full LaTeX, no truncation). Do NOT add commentary — output ONLY the file content." > "${f}.improved"
  mv "${f}.improved" "$f"
done

git add -A && git commit -m "polish-full: comprehensive review (gemini)"
```

#### 🟢 Agent 2: Codex

```bash
cd .worktrees/polish-codex
codex exec --sandbox read-only --ephemeral \
  "$(cat roles/unified.md)

Working directory: $(pwd)
Content files to polish: <list content files>

For each file: read it, apply ALL improvements from the checklist, and write the improved version back.
Commit all changes with message: 'polish-full: comprehensive review (codex)'"
```

#### 🟣 Agent 3: Claude

Directly edit files in `.worktrees/polish-claude/` using Edit tool, applying all rules from `roles/unified.md`.

Commit: `"polish-full: comprehensive review (claude)"`

### Phase 3: Compare (NO Merge)

**Do NOT merge.** Instead, generate comparison materials.

```bash
cd <project_root>
mkdir -p .polish

# 1. Export each agent's diff as a patch file
git diff $BASE_BRANCH..wt/polish-gemini > .polish/gemini.patch
git diff $BASE_BRANCH..wt/polish-codex  > .polish/codex.patch
git diff $BASE_BRANCH..wt/polish-claude > .polish/claude.patch

# 2. Compute stats
echo "=== Gemini ===" && git diff --stat $BASE_BRANCH..wt/polish-gemini
echo "=== Codex ===" && git diff --stat $BASE_BRANCH..wt/polish-codex
echo "=== Claude ===" && git diff --stat $BASE_BRANCH..wt/polish-claude
```

### Phase 4: Generate Comparison Report

Create `.polish/COMPARISON_REPORT.md` using `templates/report-comparison.md` format.

**How to classify changes:**

1. For each content file, compare the three agent versions against the original
2. For each changed passage, check how many agents made the same or equivalent change:
   - **✅ Consensus (3/3)**: All three changed it the same way → high confidence
   - **🟡 Majority (2/3)**: Two agents agree → likely good
   - **🔴 Unique (1/3)**: Only one agent changed it → review carefully
   - **⚡ Conflict**: All three changed it, but differently → human picks best

**⚠️ All emoji in the report MUST be preserved in the final output.**

### Phase 5: Cleanup Worktrees (Keep Branches)

```bash
# Remove worktree directories (clean workspace)
git worktree remove .worktrees/polish-gemini
git worktree remove .worktrees/polish-codex
git worktree remove .worktrees/polish-claude

# KEEP branches — human needs them for cherry-picking
# Branches: wt/polish-gemini, wt/polish-codex, wt/polish-claude
```

**Tell the user:**
```
Round 2 complete. Review .polish/COMPARISON_REPORT.md

Useful commands:
  git diff main..wt/polish-codex -- file.tex     # view agent's changes
  git checkout wt/polish-gemini -- file.tex       # adopt agent's version
  git diff wt/polish-gemini..wt/polish-codex      # compare two agents

When done:
  git branch -d wt/polish-gemini wt/polish-codex wt/polish-claude
  rm -rf .polish/
```

---

# Claude-Only Mode (--claude)

## Overview

Claude applies the **full comprehensive checklist** (`roles/unified.md`) solo. No Gemini or Codex CLIs needed. Useful when you have ample Claude credits (e.g., Max subscription) and want a thorough single-agent polish with auto-merge.

## Workflow

### Phase 0: Orient (Same as Round 1)

1. Identify and classify `.tex` files
2. Read experiments section for ground truth metrics
3. Read current branch name
4. Note key metrics for consistency checking

### Phase 1: Create Worktree

Only one worktree needed:

```bash
BASE_BRANCH=$(git rev-parse --abbrev-ref HEAD)
mkdir -p .worktrees

git worktree add .worktrees/polish-claude -b wt/polish-claude
```

### Phase 2: Polish (Claude Solo)

Apply ALL rules from `roles/unified.md` to every content file.

Since YOU are Claude, directly edit files in `.worktrees/polish-claude/`:
```
For each content .tex file:
  1. Read the file
  2. Apply ALL improvements from roles/unified.md:
     - Consistency & Accuracy (data, terminology, claims, references, tables)
     - Writing Quality & De-LLM (filler, dashes, parentheses, bold, vocabulary, rule-of-three, puffery, pseudo-authority, meta-narration, transitions, hedging, tense)
     - Structure & Flow (alignment, paragraph flow, logic, argument strength, conclusions, redundancy)
     - Table Aesthetics (width, font size, style, alignment)
     - LaTeX Hygiene (notation, references, formatting)
  3. Write improved version back
```

Commit: `"polish: comprehensive review (claude)"`

### Phase 3: Merge

Single merge — no conflicts possible:

```bash
cd <project_root>
git checkout $BASE_BRANCH
git merge wt/polish-claude -m "merge: claude comprehensive polish"
```

### Phase 4: Cleanup

```bash
git worktree remove .worktrees/polish-claude
git branch -d wt/polish-claude
```

### Phase 5: Generate Report

Create `POLISH_REPORT.md` in the project root using `templates/report.md` format.

Adapt the template for single-agent mode:
- Only one agent column in the summary table
- No conflict resolutions section (single agent = no conflicts)
- Include before/after examples and checklist status as normal

---

# Polishing Checklist

All three agents share this checklist. In Round 1, each focuses on their assigned items. In Round 2, every agent covers everything.

### 📊 Consistency & Accuracy (Round 1: Gemini primary)
- [ ] All numbers in abstract/intro/conclusion match experiments section
- [ ] Speedup claims cite the correct baseline and conditions
- [ ] Table captions accurately describe content
- [ ] Figure references point to correct figures
- [ ] Terminology is consistent (same term for same concept, throughout)
- [ ] Abbreviations defined on first use, then used consistently
- [ ] Related work comparisons are factually accurate
- [ ] No claims without supporting evidence in the paper

### ✍️ Writing Quality & De-LLM (Round 1: Codex primary)
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

### 🏗️ Structure & Flow (Round 1: Claude primary)
- [ ] Abstract ↔ Introduction ↔ Conclusion alignment
- [ ] Every abstract claim backed by results in the paper
- [ ] Conclusion doesn't introduce new information
- [ ] Smooth transitions between paragraphs and sections
- [ ] Logical argument progression within each section
- [ ] Related work positions this paper fairly (not dismissive)
- [ ] Method section motivation is clear before technical details
- [ ] Each section has a clear purpose and takeaway

### 📐 Table Aesthetics (All agents, both rounds)
- [ ] Table width fits column/page width (use `\resizebox{\columnwidth}{!}{...}` or `\adjustbox` if needed)
- [ ] Font size appropriate — use `\small` or `\footnotesize` for dense tables, never smaller than `\scriptsize`
- [ ] Font size consistent across ALL tables in the paper
- [ ] Table style matches the conference/journal template (booktabs `\toprule/\midrule/\bottomrule`, no vertical lines unless template requires)
- [ ] Column alignment sensible: numbers right-aligned, text left-aligned, headers centered
- [ ] No tables overflowing into margins
- [ ] Cell padding sufficient — not cramped, not too sparse
- [ ] Bold used only for best results or column headers, not random emphasis

### 🔧 LaTeX Hygiene (All agents, both rounds)
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
