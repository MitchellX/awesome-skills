# Auto-Select Reviewer Logic

This document defines the decision tree for automatically selecting the best reviewer when `--reviewer=auto` is specified.

## Decision Tree

Evaluate rules **top-to-bottom**, first match wins.

### Priority 1: Pattern-Based Rules (Hard Rules)

| Pattern | Select | Reason |
|---------|--------|--------|
| Security-sensitive files/code detected | **Codex** | Requires careful security analysis |
| Files > 20 OR lines > 500 | **Codex** | Large changeset needs thorough review |
| Database migrations or schema changes | **Codex** | Architectural risk |
| API/service layer modifications | **Codex** | Backend architectural changes |
| Changes span 3+ top-level directories | **Codex** | Multi-service impact |
| Complex TypeScript (generics, type utilities) | **Codex** | Type system complexity |
| Pure frontend only (jsx/tsx/vue/css/html) | **Gemini** | Simpler, visual-focused review |
| Python ecosystem (py, Django, FastAPI) | **Gemini** | Strong Python support |
| Documentation only (md/txt/rst) | **Gemini** | Simple text review |

### Priority 2: Complexity Score

If no pattern matched, calculate complexity score:

| Factor | Score | Detection |
|--------|-------|-----------|
| Files changed > 10 | +2 | `git diff --name-only \| wc -l` |
| Files changed > 20 | +3 | (additional, total +5) |
| Lines changed > 300 | +2 | `git diff --numstat` sum |
| Lines changed > 500 | +3 | (additional, total +5) |
| Multiple directories touched | +1 | Count unique top-level dirs |
| Test files included | +1 | Files matching `*test*`, `*spec*` |
| Config files changed | +1 | `*.config.*`, `*.json`, `*.yaml`, `*.yml`, `*.toml` |
| Database/schema changes | +2 | `*migration*`, `*schema*`, `*.sql`, `prisma/*` |
| API route changes | +2 | Files in `api/`, `routes/`, containing `endpoint`, `handler` |
| Service layer changes | +2 | Files in `services/`, `*service*`, `*provider*` |

**Routing by Score:**

| Score | Select | Reason |
|-------|--------|--------|
| ≥ 6 | **Codex** | High complexity warrants deeper analysis |
| < 6 | **Gemini** | Moderate complexity, prefer speed |

### Priority 3: Default

If nothing else matched:
→ **Gemini** (faster feedback loop for unclear cases)

---

## Detection Patterns

### Security-Sensitive Patterns

**File paths:**
```
**/auth/**
**/security/**
**/*authentication*
**/*authorization*
**/middleware/auth*
```

**Code patterns (in diff content):**
```
password\s*=
api_key\s*=
secret\s*=
Bearer\s+
JWT
\.env
credentials
private_key
access_token
```

**Config files:**
```
.env*
*credentials*
*secrets*
*.pem
*.key
```

### Language Detection

| Extension | Language |
|-----------|----------|
| .ts, .tsx | TypeScript |
| .js, .jsx | JavaScript |
| .py | Python |
| .go | Go |
| .rs | Rust |
| .java | Java |
| .rb | Ruby |
| .php | PHP |
| .cs | C# |
| .swift | Swift |
| .kt | Kotlin |

### Framework Detection

| Framework | Detection Patterns |
|-----------|-------------------|
| React/Next.js | `import React`, `from 'react'`, `next.config`, `pages/`, `app/` |
| Vue | `.vue` files, `import Vue`, `from 'vue'` |
| Angular | `angular.json`, `@angular/core` |
| Django | `django`, `models.py`, `views.py`, `urls.py` |
| FastAPI | `from fastapi`, `FastAPI(` |
| Express | `express()`, `from 'express'` |
| NestJS | `@nestjs/`, `*.module.ts`, `*.controller.ts` |
| Rails | `Gemfile` with rails, `app/controllers/` |
| Spring | `springframework`, `@RestController` |

---

## Implementation

```bash
# Step 1: Gather diff info
FILES_CHANGED=$(git diff --name-only HEAD 2>/dev/null | wc -l)
LINES_CHANGED=$(git diff --numstat HEAD 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+removed}')
DIFF_CONTENT=$(git diff HEAD 2>/dev/null)

# Step 2: Check hard rules
# [Apply pattern matching as defined above]

# Step 3: Calculate complexity score if no hard rule matched
# [Sum up scores based on factors]

# Step 4: Route based on score or default
```

---

## Output

After determining the reviewer, output:

```
## Auto-Select Decision

**Selected reviewer:** [Gemini/Codex/Claude]
**Reason:** [brief explanation]
**Complexity score:** [N]/10 (if calculated)

Proceeding with review...
```
