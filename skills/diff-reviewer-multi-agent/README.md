# diff-reviewer-multi-agent

[![Skills.sh](https://img.shields.io/badge/skills.sh-available-blue)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A multi-agent code review skill that leverages **Gemini**, **Codex**, and **Claude** to provide comprehensive code reviews. All three AI reviewers work in parallel, and a Coordinator agent merges their findings into a unified report.

## Features

- **Multi-Agent Review**: Three AI reviewers analyze your code simultaneously
- **Parallel Execution**: All reviewers run in parallel for faster results
- **Smart Merging**: Coordinator merges similar issues while preserving unique findings
- **Auto-Expertise Detection**: Automatically detects code type (training, inference, etc.) and injects relevant prompts
- **Extensible**: Add new expertise by simply dropping markdown files
- **Single Reviewer Mode**: Use `--reviewer` flag to select a specific reviewer

## Architecture

```
/diff-review (default = Multi-Agent Mode)

     ┌──────────────────────────────────────────────────────┐
     │                    Step 1: Get Diff                   │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │              Step 2: Auto-detect Expertise            │
     └──────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
    ┌───────────┐       ┌───────────┐       ┌───────────┐
    │  Gemini   │       │   Codex   │       │  Claude   │
    │ (parallel)│       │ (parallel)│       │ (parallel)│
    │           │       │           │       │           │
    │Full Review│       │Full Review│       │Full Review│
    └─────┬─────┘       └─────┬─────┘       └─────┬─────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │           Step 3: Claude Coordinator                  │
     │                                                       │
     │   • Merge similar issues (dedupe with source tags)    │
     │   • Sort by severity                                  │
     │   • Ensure no issues are missed                       │
     │   • Output unified report                             │
     └──────────────────────────────────────────────────────┘
```

### Single Reviewer Mode

```
/diff-review --reviewer=gemini

     ┌──────────────────────────────────────────────────────┐
     │                    Step 1: Get Diff                   │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │              Step 2: Auto-detect Expertise            │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │              Step 3: Run Selected Reviewer            │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │              Step 4: Output Review Result             │
     └──────────────────────────────────────────────────────┘
```

## Directory Structure

```
diff-reviewer-multi-agent/
├── README.md                     # This file
├── SKILL.md                      # Main skill definition
├── reviewers/
│   ├── auto-select.md            # Logic for --reviewer=auto
│   ├── gemini-role.md            # Gemini reviewer prompts
│   ├── codex-role.md             # Codex reviewer prompts
│   ├── claude-role.md            # Claude reviewer prompts
│   └── coordinator.md            # Coordinator merge prompts
├── expertise/
│   ├── _index.md                 # Auto-detection rules (extensible)
│   ├── training.md               # ML training code expertise
│   └── inference.md              # ML inference code expertise
└── templates/
    └── report.md                 # Report output template
```

## Installation

### Via skills.sh (Recommended)

```bash
npx skills add https://github.com/mitchellx/diff-reviewer-multi-agent --skill diff-review
```

### Manual Installation

```bash
git clone https://github.com/mitchellx/diff-reviewer-multi-agent.git ~/.claude/skills/diff-reviewer-multi-agent
```

## Usage

### Multi-Agent Review (Default)

```bash
# Review all uncommitted changes with all 3 reviewers
/diff-review

# Or explicitly
/diff-review --reviewer=all
```

### Single Reviewer

```bash
# Use specific reviewer
/diff-review --reviewer=gemini
/diff-review --reviewer=codex
/diff-review --reviewer=claude

# Auto-select based on code characteristics
/diff-review --reviewer=auto
```

## Prerequisites

Make sure you have the following CLI tools installed:

| Reviewer | Installation |
|----------|--------------|
| Gemini CLI | [Google Gemini CLI Docs](https://github.com/google-gemini/gemini-cli) |
| Codex CLI | [OpenAI Codex CLI Docs](https://github.com/openai/codex) |
| Claude | Built-in (spawns new session) |

## Extending Expertise

To add new expertise (e.g., for distributed training code):

1. Create `expertise/distributed.md`:

```markdown
# Distributed Training Code Review Expertise

## Focus Areas
- DDP/FSDP configuration correctness
- Gradient synchronization
- Communication overhead
- Checkpoint sharding
- ...
```

2. Update `expertise/_index.md` to add detection rules:

```markdown
| expertise | trigger_patterns | file_patterns |
|-----------|------------------|---------------|
| distributed | `DistributedDataParallel`, `FSDP`, `torch.distributed` | `*distributed*.py` |
```

3. Done! The skill will auto-detect and apply your new expertise.

## Report Example

```markdown
# 🔍 Multi-Agent Code Review Report

**Reviewed by:** Gemini ✓ | Codex ✓ | Claude ✓
**Files changed:** 5 | **Lines changed:** 127
**Expertise detected:** training

---

## 📊 Summary

| Severity | Count |
|----------|-------|
| Critical | 0     |
| High     | 2     |
| Medium   | 3     |
| Low      | 1     |

## ⚠️ High Priority Issues

### 1. Potential memory leak in DataLoader
- **Location:** `src/train.py:42`
- **Found by:** 🔵 Gemini, 🟢 Codex
- **Issue:** DataLoader workers not properly terminated
- **Suggestion:** Add `del dataloader` or use context manager
...
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Acknowledgments

- Inspired by [agent-skills-code-review-router](https://github.com/win4r/agent-skills-code-review-router)
- Multi-agent pattern from [multi-agent-brainstorming](https://skills.sh/sickn33/antigravity-awesome-skills/multi-agent-brainstorming)
