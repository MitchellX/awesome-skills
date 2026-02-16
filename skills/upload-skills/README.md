# upload-skills

[![Skills.sh](https://img.shields.io/badge/skills.sh-available-blue)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A one-command workflow to publish a local Claude Code skill from `~/.claude/skills/` to the GitHub repo `MitchellX/awesome-skills`. Automatically generates README, updates repo README, commits and pushes.

## Features

- **One-Command Upload**: Publish any local skill with a single `/upload-skills` command
- **Auto README Generation**: Generates a formatted README.md from the skill's SKILL.md
- **Repo README Update**: Automatically adds the skill to the Available Skills table, installation section, and repository structure
- **Interactive Validation**: Lists available skills if none specified, confirms before overwriting existing skills
- **Git Integration**: Handles git pull, commit, and push in one workflow

## Architecture

```
/upload-skills <skill-name>

     ┌──────────────────────────────────────────────────────┐
     │           Step 1: Validate Skill Exists               │
     │   Check ~/.claude/skills/<skill-name>/SKILL.md        │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │           Step 2: Prepare the Repo                    │
     │   Clone or pull ~/awesome-skills                      │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │           Step 3: Copy Skill to Repo                  │
     │   cp -r skill → skills/<skill-name>                   │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │         Step 4: Generate Skill README                 │
     │   Extract info from SKILL.md → README.md              │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │         Step 5: Update Repo Root README               │
     │   Add to table, install section, and tree             │
     └──────────────────────────────────────────────────────┘
                              │
                              ▼
     ┌──────────────────────────────────────────────────────┐
     │         Step 6: Commit and Push                       │
     │   git add → commit → push origin main                 │
     └──────────────────────────────────────────────────────┘
```

## Installation

### Via skills.sh (Recommended)

```bash
npx skills add https://github.com/mitchellx/awesome-skills --skill upload-skills
```

### Manual Installation

```bash
git clone https://github.com/MitchellX/awesome-skills.git /tmp/awesome-skills
cp -r /tmp/awesome-skills/skills/upload-skills ~/.claude/skills/upload-skills
```

## Usage

```bash
# Upload a specific skill
/upload-skills <skill-name>

# If no skill name provided, lists available skills and prompts for selection
/upload-skills
```

### Parameters

- `<skill-name>` (required): Name of the skill directory under `~/.claude/skills/`. If omitted or invalid, lists all available local skills and asks you to pick one.

### Example

```bash
# Upload the techdebt skill
/upload-skills techdebt

# Upload the diff-review skill
/upload-skills diff-review
```

## Directory Structure

```
upload-skills/
├── README.md          # This file
└── SKILL.md           # Skill definition and workflow
```

## License

MIT License - see [LICENSE](../../LICENSE) for details.
