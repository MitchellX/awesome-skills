---
name: paper-review
description: Multi-agent LaTeX paper review using Gemini, Codex, and Claude in parallel. Reviews writing, logic, structure, formatting, and generates a merged report.
---

# Paper Review - Multi-Agent LaTeX Paper Review

Review and polish LaTeX papers using multiple AI reviewers in parallel, then merge findings into a unified report.

## Usage

```
/paper-review [<file-or-dir>] [--reviewer=<gemini|codex|claude|auto|all>] [--focus=<writing|logic|structure|formatting|all>]
```

### Parameters

- `<file-or-dir>` (optional): Path to the main `.tex` file or paper directory. If omitted, auto-detects `*.tex` files in the current directory.
- `--reviewer` (optional): Select reviewer mode
  - `gemini`: Use Gemini CLI only
  - `codex`: Use Codex CLI only
  - `claude`: Use Claude only (spawns new session)
  - `all` or omitted: **Multi-Agent Mode** - use all three reviewers in parallel
- `--focus` (optional): Narrow the review scope
  - `writing`: Grammar, clarity, flow, conciseness
  - `logic`: Technical correctness, argument soundness, missing citations
  - `structure`: Section organization, balance, narrative arc
  - `formatting`: LaTeX best practices, table/figure quality, bibliography
  - `all` or omitted: Full review (default)

## When NOT to Use This Skill

- For code review (use `/diff-review` instead)
- For non-LaTeX documents (plain text, Word, etc.)
- For proofreading a final camera-ready version (use a dedicated grammar tool)

---

## Workflow

### Step 0: Check Prerequisites

Verify CLI availability:

```bash
# Check Gemini CLI
which gemini || echo "GEMINI_NOT_FOUND"

# Check Codex CLI
which codex || echo "CODEX_NOT_FOUND"
```

**If neither CLI is found for multi-agent mode:** Warn user and suggest installation.

**If only some CLIs available:** Proceed with available reviewers only.

---

### Step 1: Parse Parameters & Locate Paper

```
IF <file-or-dir> is provided:
    IF it's a .tex file:
        Set MAIN_TEX = <file-or-dir>
        Set PAPER_DIR = dirname(MAIN_TEX)
    ELSE IF it's a directory:
        Set PAPER_DIR = <file-or-dir>
        Find main .tex file (look for \documentclass or largest .tex file)
        Set MAIN_TEX = found file
ELSE:
    Auto-detect in current directory
    Find main .tex file
    Set MAIN_TEX, PAPER_DIR

IF --focus is specified:
    Set FOCUS_AREAS = specified value(s)
ELSE:
    Set FOCUS_AREAS = "all"
```

---

### Step 2: Gather Paper Content

```bash
# Get the main tex file content
cat $MAIN_TEX

# Find and read all included/input tex files
grep -rh '\\input{\|\\include{' $MAIN_TEX | sed 's/.*{\(.*\)}.*/\1/' | while read f; do
    # Add .tex extension if missing
    [ -f "${PAPER_DIR}/${f}.tex" ] && cat "${PAPER_DIR}/${f}.tex"
    [ -f "${PAPER_DIR}/${f}" ] && cat "${PAPER_DIR}/${f}"
done

# Get bibliography if exists
ls ${PAPER_DIR}/*.bib 2>/dev/null && cat ${PAPER_DIR}/*.bib

# Paper stats
wc -l $MAIN_TEX
find $PAPER_DIR -name '*.tex' | xargs wc -l | tail -1
grep -c '\\section\|\\subsection' $MAIN_TEX
grep -c '\\cite' $MAIN_TEX
grep -c '\\begin{table}\|\\begin{figure}' $MAIN_TEX
```

**Store the full paper content as PAPER_CONTENT for injection into reviewer prompts.**

---

### Step 3: Auto-detect Paper Domain

Analyze the paper content to detect domain expertise:

```
IF paper contains keywords like "attention", "transformer", "training", "GPU", "model":
    DOMAIN = "machine-learning"
    Load expertise/ml.md
ELSE IF paper contains "theorem", "proof", "lemma":
    DOMAIN = "theoretical"
    Load expertise/theory.md
ELSE:
    DOMAIN = "general"
    Use general review guidelines only
```

---

### Step 4: Execute Review

#### Multi-Agent Mode (default)

Execute all three reviewers **in parallel** using the exact commands below.

**⚠️ CRITICAL: Each CLI has different syntax. Do NOT mix them up!**
- **Gemini**: `cat paper.tex | gemini -p "prompt"` (accepts stdin pipe ✅)
- **Codex**: `codex exec --sandbox read-only --ephemeral "prompt"` (reads files directly ✅)
- **Claude**: Spawn subagent via Task tool

**Construct [FULL_PROMPT] for each reviewer by combining:**
1. The reviewer's role file (e.g., `reviewers/gemini-role.md`)
2. Any matched domain expertise prompts from Step 3
3. The focus area filter (if specified)
4. The paper content (for Gemini via stdin; Codex reads files directly)

All three reviewers MUST receive the same review instructions — only the delivery mechanism differs.

```
PARALLEL:
    Task 1: Run Gemini Review
        - Load reviewers/gemini-role.md
        - Inject matched domain expertise prompts
        - Execute:
            # Pipe the full paper content to Gemini:
            cat $MAIN_TEX [+ included files] | gemini -p "[FULL_PROMPT]"
        - Store result as GEMINI_RESULT

    Task 2: Run Codex Review
        - Load reviewers/codex-role.md
        - Inject matched domain expertise prompts
        - Execute using `codex exec` (NOT `codex review` or `codex -p`):
            codex exec --sandbox read-only --ephemeral "Review the LaTeX paper at ${MAIN_TEX}. [FULL_PROMPT]"
        - `codex exec` reads the paper files directly — no need to pipe content
        - `--sandbox read-only` = safe, `--ephemeral` = don't save session
        - Store result as CODEX_RESULT

    Task 3: Run Claude Review
        - Load reviewers/claude-role.md
        - Inject matched domain expertise prompts
        - In Claude Code: use Task tool to spawn a subagent with paper content + prompt
        - Store result as CLAUDE_RESULT
END PARALLEL
```

Then proceed to **Step 5: Coordinate & Merge**.

#### Single Reviewer Mode

Execute only the selected reviewer using the commands above for the chosen reviewer.
Output result directly to terminal, then STOP (skip Step 5).

---

### Step 5: Coordinate & Merge (Multi-Agent Mode Only)

Load `reviewers/coordinator.md` and provide it with:
- GEMINI_RESULT
- CODEX_RESULT
- CLAUDE_RESULT

The Coordinator will:

1. **Parse all three reviews** into structured format
2. **Identify similar issues** across reviewers (same section/paragraph)
3. **Merge similar issues** while preserving source attribution
4. **Preserve unique issues** found by only one reviewer
5. **Sort by severity**: Critical > High > Medium > Low
6. **Generate unified report** using `templates/report.md`

---

### Step 6: Save Report (MANDATORY)

**⚠️ This step is NOT optional. You MUST save the report to a file.**

```bash
# Generate filename
PAPER_NAME=$(basename $MAIN_TEX .tex)
REPORT_FILE="paper-review-${PAPER_NAME}-$(date +%Y%m%d-%H%M%S).md"
```

**You MUST do BOTH of the following:**

1. **Output the full report to terminal**
2. **Write the report to `$REPORT_FILE` in the paper directory**

```bash
cat << 'EOF' > "${PAPER_DIR}/${REPORT_FILE}"
[full report content here]
EOF

echo "📄 Report saved to: ${PAPER_DIR}/${REPORT_FILE}"
```

---

## Review Focus Areas

### Writing Quality
- Grammar and spelling errors
- Awkward or unclear phrasing
- Passive voice overuse
- Sentence length and readability
- Consistent terminology throughout
- Vague claims without evidence ("significantly improves", "state-of-the-art")
- Provide specific rewritten sentences for each issue

### Technical Logic
- Mathematical correctness (equations, proofs)
- Experimental methodology soundness
- Statistical significance of reported results
- Fairness of baseline comparisons
- Missing ablation studies or controls
- Overclaiming / unsupported conclusions
- Logical gaps in argumentation

### Paper Structure
- Abstract completeness (motivation, method, result, impact)
- Introduction flow (problem → gap → contribution)
- Related work coverage and positioning
- Method section clarity and reproducibility
- Experiment section completeness
- Conclusion vs. introduction consistency
- Section length balance

### LaTeX Formatting
- Table and figure quality (captions, labels, references)
- Consistent notation (math symbols, abbreviations)
- Bibliography completeness and format
- Cross-reference correctness (\ref, \cite)
- Orphan/widow lines
- Margin and spacing issues
- TODO/FIXME comments left in

---

## General Review Guidelines

These guidelines apply to all reviewers:

### As a Reviewer
- Be constructive — suggest fixes, not just problems
- Be specific — cite exact sections, paragraphs, or line numbers
- Be actionable — every issue should have a clear resolution
- Prioritize — separate critical flaws from polish suggestions

### Severity Levels for Papers
- **CRITICAL**: Factual errors, logical flaws, missing key experiments, reproducibility blockers
- **HIGH**: Unclear methodology, unsupported claims, significant writing issues, missing related work
- **MEDIUM**: Minor writing improvements, formatting inconsistencies, additional experiments suggested
- **LOW**: Style preferences, minor LaTeX tweaks, optional polish

---

## Fallback Handling

### If a reviewer fails:

```
IF GEMINI fails:
    Log: "⚠️ Gemini review failed: [error]"
    Continue with other reviewers

IF CODEX fails:
    Log: "⚠️ Codex review failed: [error]"
    Continue with other reviewers

IF CLAUDE fails:
    Log: "⚠️ Claude review failed: [error]"
    Continue with other reviewers

IF ALL reviewers fail:
    Output: "❌ All reviewers failed. Please check CLI installations."
```

### If only one reviewer succeeds:

Output that reviewer's result directly without coordination step.

### If two reviewers succeed:

Proceed with coordination using available results.
