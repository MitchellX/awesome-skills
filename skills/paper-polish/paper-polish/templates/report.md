# Polish Report Template

## Format

```markdown
# 📝 Paper Polish Report

**Date:** {{DATE}}
**Paper:** {{PAPER_NAME}}
**Branch:** {{BRANCH}}
**Agents:** 🔵 Gemini (Consistency) | 🟢 Codex (Writing) | 🟣 Claude (Structure)

---

## 📊 Summary

| Agent | Files Modified | Lines Changed | Key Focus |
|-------|---------------|---------------|-----------|
| 🔵 Gemini | {{GEMINI_FILES}} | +{{GEMINI_ADD}}/-{{GEMINI_DEL}} | {{GEMINI_FOCUS}} |
| 🟢 Codex | {{CODEX_FILES}} | +{{CODEX_ADD}}/-{{CODEX_DEL}} | {{CODEX_FOCUS}} |
| 🟣 Claude | {{CLAUDE_FILES}} | +{{CLAUDE_ADD}}/-{{CLAUDE_DEL}} | {{CLAUDE_FOCUS}} |
| **Merged** | {{TOTAL_FILES}} | +{{TOTAL_ADD}}/-{{TOTAL_DEL}} | — |

**Conflicts resolved:** {{CONFLICT_COUNT}}

---

## 🔀 Conflict Resolutions

For each merge conflict, document:

### Conflict {{N}}: {{FILE}}:{{LINES}}

**🔵 Gemini version:**
> {{GEMINI_TEXT}}

**🟢 Codex version:**
> {{CODEX_TEXT}}

**🟣 Claude version:**
> {{CLAUDE_TEXT}}

**✅ Chosen / Synthesized:**
> {{FINAL_TEXT}}

**Reason:** {{WHY_THIS_VERSION}}

---

## 📋 Notable Changes

### 🔵 Gemini — Consistency & Accuracy
{{LIST_OF_GEMINI_CHANGES}}
- Example: "Abstract claimed 2.2× speedup → corrected to 1.33× to match Table 1"

### 🟢 Codex — Writing Quality & De-LLM
{{LIST_OF_CODEX_CHANGES}}
- Example: "Replaced 12 instances of 'leveraging' with 'using'"
- Example: "Split 8 sentences exceeding 40 words"

### 🟣 Claude — Structure & Flow
{{LIST_OF_CLAUDE_CHANGES}}
- Example: "Added transition paragraph between §3.2 and §3.3"
- Example: "Moved baseline description from §4.3 to §4.1 (setup)"

---

## ✏️ Before / After Examples

### Example {{N}}: {{DESCRIPTION}}

**Before:**
> {{ORIGINAL_TEXT}}

**After:**
> {{IMPROVED_TEXT}}

**Changed by:** {{AGENT}} | **Why:** {{REASON}}

---

## ⚠️ Items Needing Human Review

List anything the agents flagged but couldn't resolve:
- {{ITEM}}: {{REASON_NEEDS_HUMAN}}

---

## ✅ Checklist Status

| Check | Status |
|-------|--------|
| Numbers match experiments | {{STATUS}} |
| No orphan claims | {{STATUS}} |
| Terminology consistent | {{STATUS}} |
| De-LLM complete | {{STATUS}} |
| Tense consistent | {{STATUS}} |
| Abstract ↔ Conclusion aligned | {{STATUS}} |
| Transitions smooth | {{STATUS}} |
| LaTeX compiles | {{STATUS}} |
```

## Notes

- Replace all `{{PLACEHOLDER}}` with actual values
- Include at least 3-5 before/after examples
- List ALL conflicts, even if trivially resolved
- The "Items Needing Human Review" section is important — don't skip it
- All emoji MUST be preserved in the final output
