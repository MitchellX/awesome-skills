# Awesome Skills

[![Skills.sh](https://img.shields.io/badge/skills.sh-compatible-blue)](https://skills.sh)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A curated collection of custom skills for [Claude Code](https://claude.ai/code). Each skill extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.

## Available Skills

| Skill | Description |
|-------|-------------|
| [anthropics-skills](./skills/anthropics-skills/) | Anthropic's official skills collection (pptx, docx, xlsx, pdf, canvas-design, mcp-builder, skill-creator, and more) |
| [diff-review](./skills/diff-review/) | Multi-agent code review using Gemini, Codex, and Claude in parallel. Auto-detects expertise and merges findings |
| [paper-polish](./skills/paper-polish/) | Multi-agent paper polishing: Gemini (accuracy), Codex (de-LLM), Claude (flow) in parallel worktrees with merge |
| [paper-review](./skills/paper-review/) | Multi-agent LaTeX paper review using Gemini, Codex, and Claude. Reviews writing, logic, structure, formatting |
| [notion-organizer](./skills/notion-organizer/) | Automatically organize and optimize Notion page content given a URL |
| [techdebt](./skills/techdebt/) | Technical debt auditor with parallel subagents for duplication, code smells, architecture, and maintenance risks |
| [upload-skills](./skills/upload-skills/) | Upload a local skill to the awesome-skills GitHub repo with auto-generated README |
| [git-commit](https://github.com/github/awesome-copilot) | Conventional commit message generation (GitHub official) |

### Anthropic Official Skills (bundled in `anthropics-skills/`)

| Sub-Skill | Description |
|-----------|-------------|
| algorithmic-art | Generate algorithmic art with JavaScript templates |
| brand-guidelines | Create and apply brand guidelines |
| canvas-design | Design with Canvas using custom fonts |
| doc-coauthoring | Collaborative document co-authoring |
| docx | Read, write, and edit Word documents |
| frontend-design | Frontend UI/UX design |
| internal-comms | Internal communications templates |
| mcp-builder | Build MCP servers (Python/Node) |
| pdf | PDF generation, form filling, and extraction |
| pptx | Create and edit PowerPoint presentations |
| skill-creator | Create, test, and benchmark new skills |
| slack-gif-creator | Create animated GIFs for Slack |
| theme-factory | Design and apply visual themes |
| web-artifacts-builder | Build web artifacts with bundling |
| webapp-testing | Web application testing automation |
| xlsx | Read, write, and edit Excel spreadsheets |

## Claude Plugins Backup

Installed plugins from [claude-plugins-official](https://github.com/anthropics/claude-plugins) registry:

| Plugin | Version | Source | Description |
|--------|---------|--------|-------------|
| context7 | latest | claude-plugins-official | Context management for large codebases |
| feature-dev | latest | claude-plugins-official | Feature development workflow |
| ralph-loop | latest | claude-plugins-official | Iterative development loop |
| superpowers | v4.3.1 | claude-plugins-official | Extended Claude capabilities |
| commit-commands | latest | claude-plugins-official | Git commit helpers |
| claude-md-management | v1.0.0 | claude-plugins-official | CLAUDE.md file management |
| code-review | latest | claude-plugins-official | Code review workflow |
| claude-mem | v10.4.0 | thedotmack | Persistent memory management for Claude |

See [claude-plugins/](./claude-plugins/) for backup files.

## OpenClaw Workspace Skills

Skills running on the [OpenClaw](https://openclaw.com) agent platform:

| Skill | Description |
|-------|-------------|
| [notion-writer](./openclaw-skills/notion-writer/) | Create, read, update, and query Notion pages with rich content blocks |
| [unity-claude](./openclaw-skills/unity-claude/) | Fire-and-forget dispatch to remote HPC with Ralph Loop, git worktree isolation, and Agent Teams |

See [openclaw-skills/](./openclaw-skills/) for skill files.

*Last updated: 2026-03-07*

## Installation

Install any skill using the skills.sh CLI:

```bash
# Install diff-review (multi-agent code review)
npx skills add https://github.com/mitchellx/awesome-skills --skill diff-review

# Install paper-review (multi-agent LaTeX paper review)
npx skills add https://github.com/mitchellx/awesome-skills --skill paper-review

# Install paper-polish (multi-agent paper polishing)
npx skills add https://github.com/mitchellx/awesome-skills --skill paper-polish

# Install techdebt
npx skills add https://github.com/mitchellx/awesome-skills --skill techdebt

# Install upload-skills
npx skills add https://github.com/mitchellx/awesome-skills --skill upload-skills

# Install git-commit from GitHub official repo
npx skills add https://github.com/github/awesome-copilot --skill git-commit
```

Or manually copy the skill folder to your Claude Code skills directory.

## Repository Structure

```
awesome-skills/
├── README.md
├── LICENSE
├── skills/                                # Claude Code skills
│   ├── anthropics-skills/                 # Official Anthropic skills collection
│   │   └── skills/                        # 16 sub-skills (pptx, docx, pdf, etc.)
│   ├── diff-review/
│   ├── paper-polish/
│   ├── paper-review/
│   ├── notion-organizer/
│   ├── techdebt/
│   └── upload-skills/
├── openclaw-skills/                       # OpenClaw platform skills
│   ├── notion-writer/
│   │   ├── SKILL.md
│   │   └── scripts/notion_api.py
│   └── unity-claude/
│       ├── SKILL.md
│       ├── README.md
│       └── references/
│           ├── architecture.md
│           ├── git-worktree.md
│           └── superpower.md
└── claude-plugins/                        # Plugin backups
    ├── installed_plugins.json
    └── known_marketplaces.json
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
