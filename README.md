# Awesome Skills

[![Skills.sh](https://img.shields.io/badge/skills.sh-compatible-blue)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A curated collection of custom skills for [Claude Code](https://claude.ai/code). Each skill extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.

## Available Skills

| Skill | Description |
|-------|-------------|
| [diff-reviewer-multi-agent](./skills/diff-reviewer-multi-agent/) | Multi-agent code review using Gemini, Codex, and Claude in parallel |
| [techdebt](./skills/techdebt/) | Technical debt auditor with parallel subagents for duplication, code smells, architecture, and maintenance risks |
| [git-commit](https://github.com/github/awesome-copilot) | Conventional commit message generation (GitHub official) |

## Installation

Install any skill using the skills.sh CLI:

```bash
# Install diff-reviewer-multi-agent
npx skills add https://github.com/mitchellx/awesome-skills --skill diff-review

# Install techdebt
npx skills add https://github.com/mitchellx/awesome-skills --skill techdebt

# Install git-commit from GitHub official repo
npx skills add https://github.com/github/awesome-copilot --skill git-commit
```

Or manually copy the skill folder to your Claude Code skills directory.

## Repository Structure

```
awesome-skills/
├── README.md                              # This file
├── LICENSE
└── skills/
    ├── diff-reviewer-multi-agent/         # Multi-agent code review skill
    │   ├── SKILL.md                       # Skill definition
    │   ├── README.md                      # Skill documentation
    │   ├── expertise/                     # Domain-specific prompts
    │   ├── reviewers/                     # Reviewer role definitions
    │   └── templates/                     # Output templates
    └── techdebt/                          # Technical debt auditor skill
        └── SKILL.md                       # Skill definition
```

## Creating New Skills

To add a new skill to this collection:

1. Create a new folder under `skills/`
2. Add a `SKILL.md` with YAML frontmatter defining the skill
3. Add a `README.md` documenting the skill
4. Include any supporting files (prompts, templates, etc.)

See [skill-creator](https://skills.sh/docs/creating-skills) for detailed guidance.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
