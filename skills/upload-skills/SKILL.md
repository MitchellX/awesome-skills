---
name: upload-skills
description: "Upload a local skill from ~/.claude/skills/ to the GitHub repo MitchellX/awesome-skills. Automatically generates README, updates repo README, commits and pushes."
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# Upload Skills to GitHub

One-command workflow to publish a local Claude Code skill to the `MitchellX/awesome-skills` GitHub repository.

## Usage

```
/upload-skills <skill-name>
```

### Parameters

- `<skill-name>` (required): Name of the skill directory under `~/.claude/skills/`. If omitted or invalid, list all available local skills and ask the user to pick one.

---

## Workflow

### Step 1: Validate Skill Exists

```
SET SKILL_NAME = argument provided by user
SET SKILL_PATH = ~/.claude/skills/<SKILL_NAME>

IF SKILL_PATH/SKILL.md does not exist:
    List all directories in ~/.claude/skills/
    Show them to the user
    Ask: "Which skill do you want to upload?"
    STOP and wait for user response
```

---

### Step 2: Prepare the Repo

```
SET REPO_PATH = ~/awesome-skills

IF REPO_PATH/.git exists:
    cd REPO_PATH && git pull origin main
ELSE:
    gh repo clone MitchellX/awesome-skills REPO_PATH
```

---

### Step 3: Copy Skill to Repo

```
SET DEST = REPO_PATH/skills/<SKILL_NAME>

IF DEST already exists:
    Warn user: "Skill '<SKILL_NAME>' already exists in the repo."
    Ask: "Overwrite?"
    IF user says no: STOP

Copy entire skill directory:
    cp -r SKILL_PATH DEST
```

---

### Step 4: Generate README for the Skill

Read `DEST/SKILL.md` to extract:
- Frontmatter: name, description
- Workflow steps, agent descriptions, parameters

If `DEST/README.md` already exists, skip this step.

Otherwise, generate `DEST/README.md` with the following structure:

```markdown
# <skill-name>

[![Skills.sh](https://img.shields.io/badge/skills.sh-available-blue)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<one-paragraph description from SKILL.md>

## Features
<bullet list of key capabilities extracted from SKILL.md>

## Architecture
<ASCII diagram showing the workflow from SKILL.md>

## Installation

### Via skills.sh (Recommended)
npx skills add https://github.com/mitchellx/awesome-skills --skill <skill-name>

### Manual Installation
git clone https://github.com/MitchellX/awesome-skills.git /tmp/awesome-skills
cp -r /tmp/awesome-skills/skills/<skill-name> ~/.claude/skills/<skill-name>

## Usage
<usage examples with all supported parameters from SKILL.md>

## Directory Structure
<tree of files in the skill directory>

## License
MIT License - see [LICENSE](../../LICENSE) for details.
```

Use `REPO_PATH/skills/diff-reviewer-multi-agent/README.md` as the style reference for tone, formatting, and badge placement.

---

### Step 5: Update Repo Root README

Edit `REPO_PATH/README.md` to add three things:

1. **Available Skills table**: Add a new row:
   ```
   | [<skill-name>](./skills/<skill-name>/) | <description from SKILL.md frontmatter> |
   ```
   Insert before the `git-commit` row (keep git-commit as the last external skill).

2. **Installation section**: Add install command:
   ```bash
   # Install <skill-name>
   npx skills add https://github.com/mitchellx/awesome-skills --skill <skill-name>
   ```
   Insert before the git-commit install command.

3. **Repository Structure tree**: Add the skill directory entry under `skills/`.

---

### Step 6: Commit and Push

```bash
cd REPO_PATH
git add skills/<SKILL_NAME>/
git add README.md
git commit -m "feat(<SKILL_NAME>): add <SKILL_NAME> skill with README"
git push origin main
```

If commit or push fails, show the error and do NOT retry destructive operations.

---

### Step 7: Confirm

Output to the user:
- The GitHub URL: `https://github.com/MitchellX/awesome-skills/tree/main/skills/<SKILL_NAME>`
- Summary of what was added (files count, README generated or not, root README updated or not)
