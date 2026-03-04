# Comparison Report Template (Round 2)

## Format

```markdown
# 🔍 Paper Polish — Round 2 Comparison Report

**Date:** {{DATE}}
**Paper:** {{PAPER_NAME}}
**Branch:** {{BRANCH}}
**Mode:** Round 2 (Full — all agents, same task)
**Agents:** 🔵 Gemini | 🟢 Codex | 🟣 Claude

---

## 📊 Overview

| Agent | Files Modified | Lines Changed | Branch |
|-------|---------------|---------------|--------|
| 🔵 Gemini | {{GEMINI_FILES}} | +{{GEMINI_ADD}}/-{{GEMINI_DEL}} | `wt/polish-gemini` |
| 🟢 Codex | {{CODEX_FILES}} | +{{CODEX_ADD}}/-{{CODEX_DEL}} | `wt/polish-codex` |
| 🟣 Claude | {{CLAUDE_FILES}} | +{{CLAUDE_ADD}}/-{{CLAUDE_DEL}} | `wt/polish-claude` |

**Patch files:** `.polish/gemini.patch`, `.polish/codex.patch`, `.polish/claude.patch`

---

## ✅ Consensus Changes (3/3 agents agree)

High confidence — all three agents made the same or equivalent change. Safe to adopt directly.

### {{FILE}}:{{LINES}}

**Original:**
> {{ORIGINAL_TEXT}}

**All agents changed to (or equivalent):**
> {{AGREED_TEXT}}

**Category:** {{CATEGORY — e.g., De-LLM vocabulary, data consistency, etc.}}

---

## 🟡 Majority Changes (2/3 agents agree)

Two agents made the same change; one either kept the original or changed differently. Likely good — quick review.

### {{FILE}}:{{LINES}}

**Original:**
> {{ORIGINAL_TEXT}}

**🔵 Gemini:**
> {{GEMINI_TEXT}}

**🟢 Codex:**
> {{CODEX_TEXT}}

**🟣 Claude:**
> {{CLAUDE_TEXT}}

**Majority:** {{WHICH_TWO}} | **Category:** {{CATEGORY}}

---

## 🔴 Unique Changes (1/3 only)

Only one agent spotted this. Could be a valuable unique insight or a false positive — review carefully.

### {{FILE}}:{{LINES}}

**Original:**
> {{ORIGINAL_TEXT}}

**Changed by {{AGENT}}:**
> {{CHANGED_TEXT}}

**Other agents:** kept original

**Category:** {{CATEGORY}} | **Assessment:** {{VALUABLE_INSIGHT / OVER_EDIT / FALSE_POSITIVE}}

---

## ⚡ Conflicts (agents disagree on same text)

All agents changed the same passage differently. Human picks the best version.

### {{FILE}}:{{LINES}}

**Original:**
> {{ORIGINAL_TEXT}}

**🔵 Gemini version:**
> {{GEMINI_TEXT}}

**🟢 Codex version:**
> {{CODEX_TEXT}}

**🟣 Claude version:**
> {{CLAUDE_TEXT}}

**Recommendation:** {{WHICH_IS_BEST_AND_WHY}}

---

## 📈 Statistics

| Metric | Count |
|--------|-------|
| ✅ Consensus (3/3) | {{COUNT}} |
| 🟡 Majority (2/3) | {{COUNT}} |
| 🔴 Unique (1/3) | {{COUNT}} |
| ⚡ Conflicts | {{COUNT}} |
| Total changes | {{COUNT}} |

### Per-Category Breakdown

| Category | Consensus | Majority | Unique | Conflict |
|----------|-----------|----------|--------|----------|
| Data Consistency | {{N}} | {{N}} | {{N}} | {{N}} |
| De-LLM Vocabulary | {{N}} | {{N}} | {{N}} | {{N}} |
| Sentence Structure | {{N}} | {{N}} | {{N}} | {{N}} |
| Puffery / Filler | {{N}} | {{N}} | {{N}} | {{N}} |
| Logical Flow | {{N}} | {{N}} | {{N}} | {{N}} |
| Table Aesthetics | {{N}} | {{N}} | {{N}} | {{N}} |
| LaTeX Hygiene | {{N}} | {{N}} | {{N}} | {{N}} |
| Other | {{N}} | {{N}} | {{N}} | {{N}} |

---

## 🛠️ How to Apply Changes

```bash
# View a specific agent's full diff:
git diff {{BRANCH}}..wt/polish-gemini
git diff {{BRANCH}}..wt/polish-codex
git diff {{BRANCH}}..wt/polish-claude

# Adopt a specific agent's version of a file:
git checkout wt/polish-codex -- path/to/file.tex

# Compare two agents on a specific file:
git diff wt/polish-gemini..wt/polish-codex -- path/to/file.tex

# Apply a patch file:
git apply .polish/gemini.patch

# When done reviewing, clean up:
git branch -d wt/polish-gemini wt/polish-codex wt/polish-claude
rm -rf .polish/
```

---

## ⚠️ Items Needing Human Review

{{LIST_OF_ITEMS_AGENTS_COULDNT_RESOLVE}}
```

## Notes

- Replace all `{{PLACEHOLDER}}` with actual values
- Group changes by file, then by location within file
- For consensus/majority, show the agreed-upon version prominently
- For conflicts, include a recommendation but make clear it's the coordinator's suggestion, not final
- All emoji MUST be preserved in the final output
- Include at least the top 5-10 most impactful changes as examples in each category
