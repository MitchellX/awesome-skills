# Badge Inference Rules

## Detection → Badge Mapping

Scan project files and infer badges automatically. Max 6 badges per README.

### Language / Runtime

| Detected File | Badge |
|---------------|-------|
| `*.py`, `setup.py`, `pyproject.toml` | `![Python](https://img.shields.io/badge/Python-3.x+-blue.svg)` |
| `package.json` | `![Node.js](https://img.shields.io/badge/Node.js-18+-green.svg)` |
| `Cargo.toml` | `![Rust](https://img.shields.io/badge/Rust-stable-orange.svg)` |
| `go.mod` | `![Go](https://img.shields.io/badge/Go-1.21+-00ADD8.svg)` |
| `*.ts`, `tsconfig.json` | `![TypeScript](https://img.shields.io/badge/TypeScript-5+-3178C6.svg)` |
| `*.java`, `pom.xml`, `build.gradle` | `![Java](https://img.shields.io/badge/Java-17+-red.svg)` |
| `*.swift`, `Package.swift` | `![Swift](https://img.shields.io/badge/Swift-5.9+-FA7343.svg)` |
| `*.rb`, `Gemfile` | `![Ruby](https://img.shields.io/badge/Ruby-3+-CC342D.svg)` |
| `CMakeLists.txt`, `*.cpp`, `*.c` | `![C/C++](https://img.shields.io/badge/C%2FC%2B%2B-17+-00599C.svg)` |

Version: extract from `python_requires`, `engines.node`, `rust-version`, `go` directive, etc. Fall back to `3.x+` style if unknown.

### Framework

| Detected Pattern | Badge |
|-----------------|-------|
| `react` in dependencies | `![React](https://img.shields.io/badge/React-18+-61DAFB.svg)` |
| `next` in dependencies | `![Next.js](https://img.shields.io/badge/Next.js-14+-black.svg)` |
| `fastapi` in requirements | `![FastAPI](https://img.shields.io/badge/FastAPI-0.100+-009688.svg)` |
| `flask` in requirements | `![Flask](https://img.shields.io/badge/Flask-3+-lightgrey.svg)` |
| `django` in requirements | `![Django](https://img.shields.io/badge/Django-5+-092E20.svg)` |
| `torch` in requirements | `![PyTorch](https://img.shields.io/badge/PyTorch-2+-EE4C2C.svg)` |
| `tensorflow` in requirements | `![TensorFlow](https://img.shields.io/badge/TensorFlow-2+-FF6F00.svg)` |
| `vue` in dependencies | `![Vue.js](https://img.shields.io/badge/Vue.js-3+-4FC08D.svg)` |
| `express` in dependencies | `![Express](https://img.shields.io/badge/Express-4+-lightgrey.svg)` |

### License

| Detected | Badge |
|----------|-------|
| `MIT` in LICENSE | `[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)` |
| `Apache` in LICENSE | `[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)` |
| `GPL` in LICENSE | `[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)` |
| `BSD` in LICENSE | `[![License: BSD](https://img.shields.io/badge/License-BSD-orange.svg)](LICENSE)` |
| No LICENSE file | Omit badge |

### CI / CD

| Detected | Badge |
|----------|-------|
| `.github/workflows/*.yml` | `[![CI](https://img.shields.io/github/actions/workflow/status/{owner}/{repo}/{workflow}.yml?label=CI)](...)` |
| `.travis.yml` | `[![Build](https://img.shields.io/travis/{owner}/{repo}.svg)](...)` |
| `.circleci/` | `[![CircleCI](https://img.shields.io/circleci/build/github/{owner}/{repo}.svg)](...)` |

Note: `{owner}/{repo}` must be provided by user or inferred from `git remote -v`.

### Package Registry

| Detected | Badge |
|----------|-------|
| `"name"` in package.json + `"version"` | `[![npm](https://img.shields.io/npm/v/{pkg}.svg)](https://www.npmjs.com/package/{pkg})` |
| `[project] name` in pyproject.toml | `[![PyPI](https://img.shields.io/pypi/v/{pkg}.svg)](https://pypi.org/project/{pkg}/)` |
| `[package] name` in Cargo.toml | `[![crates.io](https://img.shields.io/crates/v/{pkg}.svg)](https://crates.io/crates/{pkg})` |

### Domain-Specific

| Detected Pattern | Badge |
|-----------------|-------|
| `SKILL.md` present | `![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blueviolet)` |
| `SKILL.md` + OpenClaw paths | `![OpenClaw](https://img.shields.io/badge/OpenClaw-Plugin-blue)` |
| `plugin.json` present | `![Plugin](https://img.shields.io/badge/Type-Plugin-green)` |
| `Dockerfile` present | `![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg)` |
| MCP server patterns | `![MCP](https://img.shields.io/badge/MCP-Server-purple)` |

## Priority Order

When >6 badges are inferred, pick by priority:
1. Language/runtime (always include)
2. License (always include if present)
3. Domain-specific (high signal)
4. Framework (if notable)
5. CI status
6. Package registry

## Badge Style

Use flat style (default). All badges on one line separated by single space.
Link badges to relevant URLs when possible (LICENSE file, CI page, npm page).
