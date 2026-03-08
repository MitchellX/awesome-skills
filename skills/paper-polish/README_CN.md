# 📝 paper-polish

> 多智能体并行润色 LaTeX 论文：Gemini、Codex 和 Claude 在独立工作树中同时工作，每个专注于不同写作维度

**并行润色** · **智能冲突解决** · **完整变更报告** · **三维度优化**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.md) | [简体中文](README_CN.md)

---

## ✨ 功能特性

- **三智能体并行工作** — Gemini、Codex、Claude 在隔离的 git 工作树中独立润色
- **专注维度分工** — 一致性/写作质量/结构流畅性，三个方向同时优化
- **智能冲突解决** — 合并时自动选择最佳表述，准确性优先
- **完整变更报告** — 生成 POLISH_REPORT.md 记录所有修改和冲突解决过程

## 🔄 工作流程

```
paper-polish
  ├── 创建 3 个 git 工作树
  │   ├── 🔵 Gemini → 一致性与准确性
  │   ├── 🟢 Codex  → 写作质量与去 AI 痕迹
  │   └── 🟣 Claude → 结构与逻辑流畅性
  ├── 每个智能体在各自工作树中润色所有 .tex 文件
  ├── 顺序合并回当前分支
  │   └── 冲突时选择最佳表述
  └── 生成 POLISH_REPORT.md 记录所有变更
```

三个智能体独立工作，最终由协调者（Claude Code）合并所有改进，生成统一的润色版本。

## 🎯 智能体分工

| 智能体 | 关注点 | 优化内容 |
|-------|-------|----------|
| 🔵 Gemini | 一致性与准确性 | 数字与实验结果一致、术语统一、声明有数据支撑 |
| 🟢 Codex | 写作质量 | 去 AI 痕迹（移除"leveraging/utilizing"等）、精简句子、删除冗余表述 |
| 🟣 Claude | 结构与流畅性 | 逻辑过渡、摘要↔结论对齐、论证强度 |

## 📋 润色检查清单

- **数据一致性**：摘要/引言/结论中的所有数字与实验结果匹配
- **去 AI 痕迹**：移除 "leveraging/utilizing/Furthermore" 等 AI 常用词，缩短长句
- **术语统一**：同一概念全文使用同一术语
- **时态规范**：实验用过去时，已知事实用现在时
- **逻辑流畅**：平滑过渡，没有孤立段落
- **LaTeX 规范**：统一 \cref/\ref、数学符号、数字格式

## 🚀 使用方法

```bash
# 在论文的 git 仓库中：
/paper-polish
```

## 📦 输出内容

- 润色后的论文（在当前分支合并所有改进）
- `POLISH_REPORT.md` — 详细变更日志，包含修改前后对比和冲突解决记录

## 🏗️ 项目结构

```
paper-polish/
├── SKILL.md              # 主技能定义与工作流程
├── README.md             # 英文文档
├── README_CN.md          # 本文件
├── roles/
│   ├── gemini.md         # Gemini 的润色指令
│   ├── codex.md          # Codex 的润色指令
│   └── claude.md         # Claude 的润色指令
└── templates/
    └── report.md         # 变更报告模板
```

## 📄 许可证

MIT License
