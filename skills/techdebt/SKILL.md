---
name: techdebt
description: "Scan codebase for technical debt: duplicated code, code smells, architectural issues, and maintenance risks. Uses parallel subagents for fast analysis. Run at end of session to keep codebase clean."
allowed-tools: Bash, Glob, Grep, Read, Task
---

# Technical Debt Auditor

Scan the current codebase for technical debt and produce an actionable report with prioritized findings.

## Usage

```
/techdebt [--scope=<path>] [--category=<all|duplication|smells|architecture|maintenance>] [--top=<N>]
```

### Parameters

- `--scope` (optional): Directory or file path to limit analysis. Default: entire project root.
- `--category` (optional): Focus on a specific category. Default: `all`.
- `--top` (optional): Maximum number of findings to report. Default: `15`.

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
find $SCAN_PATH -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.rs" -o -name "*.java" \) | head -50
```

---

### Step 2: Launch Parallel Analysis

Use **4 subagents in parallel** (via Task tool with subagent_type=Explore), one per category. If `--category` is specified, only launch that single agent.

```
PARALLEL:
    Agent 1: Duplication Scanner
    Agent 2: Code Smell Detector
    Agent 3: Architecture Analyzer
    Agent 4: Maintenance Risk Finder
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
5. Check for reimplemented utility functions (e.g., custom helpers that duplicate stdlib)

For each finding, report:
- File paths and line numbers of all occurrences
- Similarity description
- Suggested shared abstraction

#### Agent 2 — Code Smell Detector

Scan for common code smells:

1. **Long functions**: Functions exceeding 50 lines (use line counting via Grep)
2. **Too many parameters**: Functions with more than 5 parameters
3. **Deep nesting**: Conditionals nested 3+ levels deep
4. **Dead code**: Unused imports, commented-out code blocks (>3 lines), unreachable branches
5. **Naming inconsistency**: Mixed naming conventions within the same module (e.g., camelCase and snake_case)
6. **God functions**: Single functions doing multiple unrelated things

For each finding, report:
- Exact file and line range
- Smell type
- Why it matters
- Refactoring suggestion

#### Agent 3 — Architecture Analyzer

Examine structural and design issues:

1. **Circular imports**: Check import chains for cycles (follow import statements)
2. **God modules**: Files with too many classes/functions (>15 top-level definitions) or too many lines (>500)
3. **Missing abstractions**: Repeated patterns across 3+ files that suggest a missing shared interface/base class
4. **Tight coupling**: Modules that import many internals from other modules
5. **Layer violations**: Direct database access from presentation layer, etc.

For each finding, report:
- Files involved
- Issue description
- Suggested architectural improvement

#### Agent 4 — Maintenance Risk Finder

Identify maintenance hazards:

1. **Stale TODOs**: Search for TODO, FIXME, HACK, XXX, TEMP comments
2. **Deprecated usage**: Patterns known to be deprecated in the language/framework
3. **Missing error handling**: Try/except with bare except, unchecked return values, missing null checks in critical paths
4. **Type safety gaps**: Functions without type hints in otherwise typed codebases
5. **Configuration debt**: Hardcoded paths, URLs, or environment-specific values not in config

For each finding, report:
- File and line number
- Risk description
- Recommended fix

---

### Step 4: Merge and Rank Results

After all agents complete, merge their findings:

1. **Deduplicate**: If multiple agents flagged the same location, merge into one finding
2. **Assign severity**:
   - **High**: Bugs waiting to happen, security risks, circular dependencies, duplicated business logic
   - **Medium**: Code smells affecting readability, missing abstractions, stale TODOs with implications
   - **Low**: Style issues, minor naming inconsistencies, cosmetic dead code
3. **Sort**: High severity first, then Medium, then Low
4. **Trim**: Keep only the top N findings (default 15)

---

### Step 5: Generate Report

Output the report in this format:

```
## Technical Debt Report

**Scope**: {SCAN_PATH}
**Files scanned**: {count}
**Findings**: {total} ({high} High, {medium} Medium, {low} Low)

---

### Summary

| Category       | High | Medium | Low | Total |
|----------------|------|--------|-----|-------|
| Duplication    |      |        |     |       |
| Code Smells    |      |        |     |       |
| Architecture   |      |        |     |       |
| Maintenance    |      |        |     |       |
| **Total**      |      |        |     |       |

---

### Findings

#### [HIGH] #1: {title}
- **Category**: {category}
- **Location**: `{file}:{line}`
- **Description**: {description}
- **Suggestion**: {suggestion}

... (repeat for each finding)

---

### Quick Wins (Top 3)

1. **{title}** — {one-line action item} ({estimated effort: trivial/small/medium})
2. **{title}** — {one-line action item} ({estimated effort})
3. **{title}** — {one-line action item} ({estimated effort})
```

---

## Fallback Handling

- If a subagent fails or times out, log a warning and continue with results from other agents
- If no issues found in a category, report "No issues found" for that category
- If the codebase is very large (>1000 files), automatically narrow scope to `src/` or the most recently modified directories
