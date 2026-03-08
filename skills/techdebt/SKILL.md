---
name: techdebt
description: "Scan codebase for technical debt: duplicated code, code smells, architectural issues, performance problems, security risks, and maintenance hazards. Uses parallel subagents for fast analysis. Supports auto-fix mode for quick wins. Run at end of session to keep codebase clean."
allowed-tools: Bash, Glob, Grep, Read, Write, Task
---

# Technical Debt Auditor

Scan the current codebase for technical debt and produce an actionable report with prioritized findings. Optionally auto-fix quick wins.

## Usage

```
/techdebt [--scope=<path>] [--category=<category>] [--top=<N>] [--fix] [--baseline=<path>]
```

### Parameters

- `--scope` (optional): Directory or file path to limit analysis. Default: entire project root.
- `--category` (optional): Focus on a specific category. One of: `all`, `duplication`, `smells`, `architecture`, `maintenance`, `performance`, `security`. Default: `all`.
- `--top` (optional): Maximum number of findings to report. Default: `15`.
- `--fix` (optional): Automatically apply safe fixes for Quick Wins (severity ≤ Medium, effort = trivial). Creates a git checkpoint first.
- `--baseline` (optional): Path to a previous debt report JSON for before/after comparison.

---

## Safety Guidelines

These rules apply to ALL analysis and especially to `--fix` mode:

- ❌ **NEVER** refactor without existing tests (or writing them first)
- ❌ **NEVER** make multiple unrelated changes in one commit
- ❌ **NEVER** refactor and add features simultaneously
- ✅ **ALWAYS** create a git checkpoint (`git stash` or commit) before any fix
- ✅ **ALWAYS** run tests after each change
- ✅ **ALWAYS** preserve external behavior (no functional changes)
- ✅ **ALWAYS** verify the fix compiles/passes lint before committing

### Escalation — Stop and Report If:

- Tests start failing unexpectedly
- Fix scope grows beyond the single finding
- A change would alter public API or external behavior
- You're unsure whether a fix is safe

---

## Workflow

### Step 1: Determine Scope

```
IF --scope is specified:
    Set SCAN_PATH = --scope
ELSE:
    Set SCAN_PATH = current working directory (project root)

Verify SCAN_PATH exists. If not, report error and stop.
```

Identify the primary language(s) by checking file extensions:
```bash
find $SCAN_PATH -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" -o -name "*.c" -o -name "*.cpp" -o -name "*.rb" \) | head -50
```

Collect baseline metrics (for before/after comparison):
```bash
# Lines of code
find $SCAN_PATH -type f -name "*.py" -o -name "*.ts" -o -name "*.js" | xargs wc -l 2>/dev/null | tail -1

# File count
find $SCAN_PATH -type f \( -name "*.py" -o -name "*.ts" -o -name "*.js" \) | wc -l

# TODO/FIXME count
grep -r "TODO\|FIXME\|HACK\|XXX" $SCAN_PATH --include="*.py" --include="*.ts" --include="*.js" -c 2>/dev/null | awk -F: '{s+=$2} END {print s}'
```

---

### Step 2: Launch Parallel Analysis

Use **6 subagents in parallel** (via Task tool), one per category. If `--category` is specified, only launch that single agent.

```
PARALLEL:
    Agent 1: Duplication Scanner
    Agent 2: Code Smell Detector
    Agent 3: Architecture Analyzer
    Agent 4: Maintenance Risk Finder
    Agent 5: Performance Auditor      ← NEW
    Agent 6: Security Scanner         ← NEW
END PARALLEL
```

---

### Step 3: Agent Instructions

#### Agent 1 — Duplication Scanner

Search for duplicated and near-duplicate code:

1. Use Grep to find functions/methods with identical signatures across files
2. Look for repeated code blocks (3+ lines appearing in multiple locations)
3. Find copy-pasted logic with minor variable name changes
4. Identify repeated magic numbers or hardcoded strings that should be constants
5. Check for reimplemented utility functions (e.g., custom helpers that duplicate stdlib or well-known libraries)
6. **Wheel reinvention**: Identify custom implementations that could be replaced by battle-tested open-source packages (e.g., hand-rolled CSV parser, custom retry logic, DIY argument parser)

For each finding, report:
- File paths and line numbers of all occurrences
- Similarity description
- Suggested shared abstraction (or existing library to use)

#### Agent 2 — Code Smell Detector

Scan for common code smells:

1. **Long functions**: Functions exceeding 50 lines
2. **Too many parameters**: Functions with more than 5 parameters
3. **Deep nesting**: Conditionals nested 3+ levels deep
4. **Dead code**: Unused imports, commented-out code blocks (>3 lines), unreachable branches
5. **Naming inconsistency**: Mixed naming conventions within the same module
6. **God functions**: Single functions doing multiple unrelated things
7. **Type safety gaps** (language-specific):
   - Python: missing type hints in otherwise typed codebase
   - TypeScript: `any` abuse, missing null checks, type assertions (`as Type`) instead of type guards
   - Go: unchecked error returns

For each finding, report:
- Exact file and line range
- Smell type
- Why it matters
- Refactoring suggestion

#### Agent 3 — Architecture Analyzer

Examine structural and design issues:

1. **Circular imports**: Check import chains for cycles
2. **God modules**: Files with >15 top-level definitions or >500 lines
3. **Missing abstractions**: Repeated patterns across 3+ files suggesting a missing shared interface/base class
4. **Tight coupling**: Modules that import many internals from other modules. Estimate coupling metrics where possible:
   - Ca (Afferent Coupling): how many modules depend on this one
   - Ce (Efferent Coupling): how many modules this one depends on
   - I (Instability): Ce / (Ca + Ce) — closer to 1.0 = more unstable
5. **Layer violations**: Direct database access from presentation layer, business logic in controllers, etc.

For each finding, report:
- Files involved
- Issue description with coupling metrics (if applicable)
- Suggested architectural improvement

#### Agent 4 — Maintenance Risk Finder

Identify maintenance hazards:

1. **Stale TODOs**: Search for TODO, FIXME, HACK, XXX, TEMP comments
2. **Deprecated usage**: Patterns known to be deprecated in the language/framework
3. **Missing error handling**: Bare except/catch, unchecked return values, missing null checks in critical paths
4. **Configuration debt**: Hardcoded paths, URLs, ports, or environment-specific values not in config files
5. **Documentation debt**: Public APIs without docstrings, outdated README sections, mismatched comments

For each finding, report:
- File and line number
- Risk description
- Recommended fix

#### Agent 5 — Performance Auditor ← NEW

Identify performance issues and inefficiencies:

1. **N+1 queries**: Database calls inside loops (ORM patterns like `for item in items: item.related`)
2. **Unnecessary full scans**: Linear searches on large collections where indexing/hashing is possible
3. **Blocking I/O in async code**: Synchronous file/network calls in async functions
4. **Missing caching**: Repeated expensive computations with same inputs (no memoization/cache)
5. **Wasteful allocations**: Creating objects/lists in tight loops, string concatenation in loops
6. **Over-fetching**: Querying all columns/fields when only a few are needed (`SELECT *`)

For each finding, report:
- File and line number
- Performance impact (estimated: minor/moderate/severe)
- Suggested optimization with code example

#### Agent 6 — Security Scanner ← NEW

Identify security vulnerabilities and risks:

1. **Hardcoded secrets**: API keys, passwords, tokens in source code (check for common patterns: `password=`, `secret=`, `api_key=`, `token=`, base64-encoded credentials)
2. **SQL injection**: String concatenation/f-strings in SQL queries instead of parameterized queries
3. **Path traversal**: User input used directly in file paths without sanitization
4. **Insecure dependencies**: Known patterns of outdated/vulnerable package usage
5. **Missing input validation**: User input passed directly to system commands, eval(), or exec()
6. **Exposed debug info**: Debug mode enabled in production configs, verbose error messages with stack traces

For each finding, report:
- File and line number
- Vulnerability type and severity (Critical/High/Medium)
- Recommended fix

---

### Step 4: Merge and Rank Results

After all agents complete, merge their findings:

1. **Deduplicate**: If multiple agents flagged the same location, merge into one finding
2. **Score each finding** using the prioritization formula:

```
Priority Score = (Impact × Risk) / Effort

Impact (1-5):  How much does this hurt the codebase?
    5 = Security vulnerability, data loss risk
    4 = Causes bugs or major performance issues
    3 = Significantly reduces maintainability
    2 = Minor readability/style issue
    1 = Cosmetic only

Risk (1-5):    How likely is this to cause problems?
    5 = Already causing issues or will very soon
    4 = High probability in normal development
    3 = Moderate probability
    2 = Low probability, edge case
    1 = Theoretical only

Effort (1-5):  How hard is it to fix?
    1 = Trivial (< 5 min, single line change)
    2 = Small (< 30 min, localized change)
    3 = Medium (1-2 hours, multiple files)
    4 = Large (half day+, architectural change)
    5 = Major (multi-day refactor)
```

3. **Assign severity label** based on score:
   - **Critical** (score ≥ 10): Security vulns, data loss risks, production bugs
   - **High** (score 5-9.9): Bugs waiting to happen, circular deps, duplicated business logic
   - **Medium** (score 2-4.9): Code smells, missing abstractions, stale TODOs
   - **Low** (score < 2): Style issues, naming, cosmetic dead code
4. **Sort** by Priority Score (descending)
5. **Trim** to top N findings (default 15)

---

### Step 5: Generate Report

Output the report in this format:

```markdown
## 🔧 Technical Debt Report

**Scope**: {SCAN_PATH}
**Scanned**: {file_count} files, {loc} lines of code
**Findings**: {total} ({critical} Critical, {high} High, {medium} Medium, {low} Low)
**Health Score**: {score}/100  ← (100 - penalty points from findings)

---

### 📊 Summary

| Category       | Critical | High | Medium | Low | Total |
|----------------|----------|------|--------|-----|-------|
| Duplication    |          |      |        |     |       |
| Code Smells    |          |      |        |     |       |
| Architecture   |          |      |        |     |       |
| Maintenance    |          |      |        |     |       |
| Performance    |          |      |        |     |       |
| Security       |          |      |        |     |       |
| **Total**      |          |      |        |     |       |

---

### 📋 Findings

#### [CRITICAL] #1: {title}  (Score: {score})
- **Category**: {category}
- **Location**: `{file}:{line}`
- **Impact**: {impact}/5 | **Risk**: {risk}/5 | **Effort**: {effort}/5
- **Description**: {description}
- **Suggestion**: {suggestion}
- **Auto-fixable**: Yes/No

... (repeat for each finding)

---

### ⚡ Quick Wins (Top 5)

These can be fixed immediately with minimal risk:

1. **{title}** — {one-line action item} (effort: trivial, score: {score})
2. ...

---

### 📈 Before/After Metrics (if --baseline provided)

| Metric          | Before | After  | Change |
|-----------------|--------|--------|--------|
| Total Findings  | X      | Y      | -Z     |
| Critical Issues | X      | Y      | -Z     |
| Lines of Code   | X      | Y      | -Z%    |
| TODO/FIXME      | X      | Y      | -Z     |
| Health Score    | X/100  | Y/100  | +Z     |

---

### 🗺️ Recommended Action Plan

**This week** (Quick Wins):
1. {action item}

**This sprint** (High priority):
1. {action item}

**Backlog** (Plan when capacity allows):
1. {action item}
```

---

### Step 6: Auto-Fix Mode (if --fix)

When `--fix` is specified:

1. **Create checkpoint**: `git stash` or `git commit -m "checkpoint: before techdebt auto-fix"`
2. **Filter fixable items**: Only fix findings where:
   - Effort = 1 (trivial) or 2 (small)
   - Auto-fixable = Yes
   - Severity ≤ Medium (don't auto-fix critical/high without human review)
3. **Apply fixes one at a time**:
   - Make the change
   - Run tests/lint if available
   - If tests pass: commit with message `fix(techdebt): {finding title}`
   - If tests fail: revert and mark as "attempted, needs manual fix"
4. **Report what was fixed**:

```markdown
### 🔨 Auto-Fix Results

| # | Finding | Status | Commit |
|---|---------|--------|--------|
| 1 | Remove unused import X | ✅ Fixed | abc1234 |
| 2 | Extract magic number Y | ✅ Fixed | def5678 |
| 3 | Remove dead code block | ❌ Tests failed, reverted | — |
```

---

## Fallback Handling

- If a subagent fails or times out, log a warning and continue with results from other agents
- If no issues found in a category, report "✅ Clean" for that category
- If the codebase is very large (>1000 files), automatically narrow scope to `src/` or the most recently modified directories
- If `--fix` encounters test failures, immediately stop fixing and report remaining items for manual review
