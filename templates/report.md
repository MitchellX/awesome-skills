# Report Template

This template defines the output format for code review reports.

---

## Multi-Agent Report Template

```markdown
# 🔍 Multi-Agent Code Review Report

**Reviewed by:** 🔵 Gemini {{GEMINI_STATUS}} | 🟢 Codex {{CODEX_STATUS}} | 🟣 Claude {{CLAUDE_STATUS}}
**Files changed:** {{FILES_CHANGED}}
**Lines changed:** {{LINES_CHANGED}}
**Expertise detected:** {{EXPERTISE_DETECTED}}
**Review date:** {{DATE}}

---

## 📊 Summary

| Severity | Count | Found by Multiple |
|----------|-------|-------------------|
| 🚨 Critical | {{CRITICAL_COUNT}} | {{CRITICAL_MULTI}} |
| ⚠️ High | {{HIGH_COUNT}} | {{HIGH_MULTI}} |
| 📝 Medium | {{MEDIUM_COUNT}} | {{MEDIUM_MULTI}} |
| 💡 Low | {{LOW_COUNT}} | {{LOW_MULTI}} |

**Total issues:** {{TOTAL_ISSUES}} ({{UNIQUE_ISSUES}} unique, {{MERGED_ISSUES}} duplicates merged)

---

## 🚨 Critical Issues

{{CRITICAL_ISSUES}}

---

## ⚠️ High Priority Issues

{{HIGH_ISSUES}}

---

## 📝 Medium Priority Issues

{{MEDIUM_ISSUES}}

---

## 💡 Low Priority / Suggestions

{{LOW_ISSUES}}

---

## 📋 Reviewer Agreement Analysis

### Issues Found by All 3 Reviewers (High Confidence)
{{ALL_THREE_ISSUES}}

### Issues Found by 2 Reviewers
{{TWO_REVIEWER_ISSUES}}

### Unique Findings
- 🔵 Gemini only: {{GEMINI_UNIQUE_COUNT}} issues
- 🟢 Codex only: {{CODEX_UNIQUE_COUNT}} issues
- 🟣 Claude only: {{CLAUDE_UNIQUE_COUNT}} issues

---

## 📎 Raw Reviews

<details>
<summary>🔵 Gemini Raw Output</summary>

{{GEMINI_RAW}}

</details>

<details>
<summary>🟢 Codex Raw Output</summary>

{{CODEX_RAW}}

</details>

<details>
<summary>🟣 Claude Raw Output</summary>

{{CLAUDE_RAW}}

</details>
```

---

## Single Reviewer Report Template

```markdown
# 🔍 Code Review Report

**Reviewed by:** {{REVIEWER_ICON}} {{REVIEWER_NAME}}
**Files changed:** {{FILES_CHANGED}}
**Lines changed:** {{LINES_CHANGED}}
**Expertise detected:** {{EXPERTISE_DETECTED}}
**Review date:** {{DATE}}

---

## 📊 Summary

| Severity | Count |
|----------|-------|
| 🚨 Critical | {{CRITICAL_COUNT}} |
| ⚠️ High | {{HIGH_COUNT}} |
| 📝 Medium | {{MEDIUM_COUNT}} |
| 💡 Low | {{LOW_COUNT}} |

**Total issues:** {{TOTAL_ISSUES}}

---

## 🚨 Critical Issues

{{CRITICAL_ISSUES}}

---

## ⚠️ High Priority Issues

{{HIGH_ISSUES}}

---

## 📝 Medium Priority Issues

{{MEDIUM_ISSUES}}

---

## 💡 Low Priority / Suggestions

{{LOW_ISSUES}}
```

---

## Issue Format

Each issue should follow this format:

```markdown
### {{ISSUE_NUMBER}}. {{ISSUE_TITLE}}

- **Location:** `{{FILE}}:{{LINE}}`
- **Found by:** {{FOUND_BY_ICONS}}
- **Category:** {{CATEGORY}}
- **Severity:** {{SEVERITY}}
- **Description:** {{DESCRIPTION}}
- **Impact:** {{IMPACT}}
- **Suggestion:**
  {{SUGGESTION}}

  ```{{LANGUAGE}}
  {{CODE_SUGGESTION}}
  ```
```

---

## Placeholders Reference

| Placeholder | Description |
|-------------|-------------|
| `{{GEMINI_STATUS}}` | ✓ if completed, ✗ if failed, ⏳ if skipped |
| `{{FILES_CHANGED}}` | Number of files changed |
| `{{LINES_CHANGED}}` | Number of lines changed |
| `{{EXPERTISE_DETECTED}}` | Comma-separated list or "general" |
| `{{DATE}}` | ISO date string |
| `{{*_COUNT}}` | Count of issues by severity |
| `{{*_ISSUES}}` | Formatted issue list |
| `{{REVIEWER_ICON}}` | 🔵/🟢/🟣 based on reviewer |
| `{{FOUND_BY_ICONS}}` | Icons of reviewers who found this issue |
