---
name: diff-review
description: Multi-agent code review using Gemini, Codex, and Claude in parallel. Auto-detects expertise and merges findings.
---

# Diff Review - Multi-Agent Code Review

Review code diffs using multiple AI reviewers in parallel, then merge findings into a unified report.

## Usage

```
/diff-review [<commit-hash>] [--reviewer=<gemini|codex|claude|auto|all>]
```

### Parameters

- `<commit-hash>` (optional): Review a specific commit instead of uncommitted changes. Accepts full or short hash.
- `--reviewer` (optional): Select reviewer mode
  - `gemini`: Use Gemini CLI only
  - `codex`: Use Codex CLI only
  - `claude`: Use Claude only (spawns new session)
  - `auto`: Auto-select best reviewer based on code (reads `reviewers/auto-select.md`)
  - `all` or omitted: **Multi-Agent Mode** - use all three reviewers in parallel

## When NOT to Use This Skill

- For non-code reviews (documentation proofreading, prose editing)
- When reviewing external/third-party code you don't control
- For commit message generation (use a dedicated commit skill)

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

### Step 1: Parse Parameters

```
IF <commit-hash> is provided:
    Set REVIEW_MODE = "commit"
    Set COMMIT_HASH = <commit-hash>
ELSE:
    Set REVIEW_MODE = "uncommitted"

IF --reviewer is specified:
    IF --reviewer=auto:
        Read reviewers/auto-select.md and follow its logic
    ELSE IF --reviewer=gemini|codex|claude:
        Set SINGLE_REVIEWER_MODE = true
        Set REVIEWER = specified value
    ELSE IF --reviewer=all:
        Set MULTI_AGENT_MODE = true
ELSE:
    Set MULTI_AGENT_MODE = true (default)
```

---

### Step 2: Get Git Diff

#### If REVIEW_MODE = "commit":

```bash
# Verify the commit exists
git rev-parse --verify $COMMIT_HASH

# Get commit metadata
git --no-pager log -1 --format="%H%n%s%n%an%n%ai" $COMMIT_HASH

# Get diff stats for the commit
git --no-pager diff --stat ${COMMIT_HASH}~1 $COMMIT_HASH

# Get full diff for analysis
git --no-pager diff ${COMMIT_HASH}~1 $COMMIT_HASH

# Count changed files
git --no-pager diff --name-only ${COMMIT_HASH}~1 $COMMIT_HASH | wc -l

# Count total changed lines
git --no-pager diff --numstat ${COMMIT_HASH}~1 $COMMIT_HASH | awk '{added+=$1; removed+=$2} END {print added+removed}'
```

**If commit hash is invalid:** Report "❌ Invalid commit hash: $COMMIT_HASH" and stop.

#### If REVIEW_MODE = "uncommitted":

```bash
# Get diff stats (staged + unstaged)
git --no-pager diff --stat HEAD 2>/dev/null || git --no-pager diff --stat

# Get full diff for analysis
git --no-pager diff HEAD 2>/dev/null || git --no-pager diff

# Count changed files
git --no-pager diff --name-only HEAD 2>/dev/null | wc -l

# Count total changed lines
git --no-pager diff --numstat HEAD 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+removed}'
```

**If no changes detected:** Report "Nothing to review - no uncommitted changes found." and stop.

---

### Step 3: Auto-detect Expertise

Read `expertise/_index.md` to get detection rules.

For each expertise defined:
1. Check if diff content matches `trigger_patterns`
2. Check if changed files match `file_patterns`
3. If matched, load the corresponding `expertise/*.md` file

**Store matched expertise prompts for injection into reviewer prompts.**

---

### Step 4: Execute Review

#### Multi-Agent Mode (default)

Execute all three reviewers **in parallel**:

```
PARALLEL:
    Task 1: Run Gemini Review
        - Load reviewers/gemini-role.md
        - Inject matched expertise prompts
        - Execute: see CLI Commands below
        - Store result as GEMINI_RESULT

    Task 2: Run Codex Review
        - Load reviewers/codex-role.md
        - Inject matched expertise prompts
        - Execute: see CLI Commands below
        - Store result as CODEX_RESULT

    Task 3: Run Claude Review
        - Load reviewers/claude-role.md
        - Inject matched expertise prompts
        - Spawn new Claude session with diff and prompt
        - Store result as CLAUDE_RESULT
END PARALLEL
```

Then proceed to **Step 5: Coordinate & Merge**.

#### Single Reviewer Mode

Execute only the selected reviewer:

```
Load reviewers/{REVIEWER}-role.md
Inject matched expertise prompts
Execute the reviewer
Output result directly to terminal
STOP (skip Step 5)
```

**CLI Commands:**

For Gemini:
```bash
# Pipe diff to Gemini with review prompt
# For uncommitted changes:
git --no-pager diff HEAD | gemini -p "[FULL_PROMPT]"
# For specific commit:
git --no-pager diff ${COMMIT_HASH}~1 $COMMIT_HASH | gemini -p "[FULL_PROMPT]"
```

For Codex:
```bash
# ⚠️ codex CLI does NOT accept piped input or -p flag for prompts!
# Use the dedicated 'review' subcommand with native flags:

# For uncommitted changes:
codex review --uncommitted "[REVIEW_PROMPT]"

# For specific commit:
codex review --commit $COMMIT_HASH "[REVIEW_PROMPT]"

# For changes against a branch:
codex review --base main "[REVIEW_PROMPT]"
```

For Claude:
```bash
# Spawn new Claude session (implementation depends on environment)
# In Claude Code: use Task tool to spawn subagent
# In Antigravity: use appropriate agent spawning mechanism
```

---

### Step 5: Coordinate & Merge (Multi-Agent Mode Only)

Load `reviewers/coordinator.md` and provide it with:
- GEMINI_RESULT
- CODEX_RESULT
- CLAUDE_RESULT

The Coordinator will:

1. **Parse all three reviews** into structured format
2. **Identify similar issues** across reviewers
3. **Merge similar issues** while preserving source attribution
4. **Preserve unique issues** found by only one reviewer
5. **Sort by severity**: Critical > High > Medium > Low
6. **Generate unified report** using `templates/report.md`

---

### Step 6: Save Report (MANDATORY)

**⚠️ This step is NOT optional. You MUST save the report to a file.**

```bash
# Generate filename
# For commit review:
REPORT_FILE="diff-review-$(echo $COMMIT_HASH | cut -c1-7)-$(date +%Y%m%d-%H%M%S).md"
# For uncommitted changes:
REPORT_FILE="diff-review-$(date +%Y%m%d-%H%M%S).md"
```

**You MUST do BOTH of the following:**

1. **Output the full report to terminal**
2. **Write the report to `$REPORT_FILE` in the current working directory**

```bash
# Write report to file — THIS IS REQUIRED, DO NOT SKIP
cat << 'EOF' > "$REPORT_FILE"
[full report content here]
EOF

# Confirm to user
echo "📄 Report saved to: $REPORT_FILE"
```

Report includes:
- Review target (commit hash + message, or "uncommitted changes")
- Summary table (severity counts)
- Merged issues with source attribution
- Raw outputs in collapsible sections

**File naming convention:**
- Commit review: `diff-review-<short-hash>-YYYYMMDD-HHMMSS.md`
- Uncommitted: `diff-review-YYYYMMDD-HHMMSS.md`

---

## General Review Guidelines

These guidelines apply to all reviewers:

### Code Quality
- Logic correctness
- Error handling completeness
- Edge case coverage
- Code readability

### Security
- Input validation
- Authentication/authorization issues
- Sensitive data exposure
- Injection vulnerabilities

### Performance
- Algorithmic efficiency
- Resource management (memory, connections)
- Unnecessary computations
- Caching opportunities

### Best Practices
- DRY principle adherence
- SOLID principles
- Proper abstractions
- Documentation completeness

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
    Provide installation links
```

### If only one reviewer succeeds:

Output that reviewer's result directly without coordination step.

### If two reviewers succeed:

Proceed with coordination using available results.
