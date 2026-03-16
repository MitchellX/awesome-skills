# 📝 Notion Writer

> OpenClaw 技能：创建、读取和管理 Notion 页面与数据库

**富文本内容块** · **数据库操作** · **后台执行** · **完整 CRUD 支持**

![Python](https://img.shields.io/badge/Python-3.8+-blue.svg) ![OpenClaw](https://img.shields.io/badge/OpenClaw-Plugin-blue)

[English](README.md) | [简体中文](README_CN.md)

---

## ✨ 功能特性

- **创建页面** — 在 Notion 数据库中添加页面，支持富文本内容（表格、代码块、列表、引用）
- **读取与查询** — 获取页面内容、搜索工作区、按条件筛选数据库条目
- **更新页面** — 修改页面属性，向现有页面追加新内容块
- **数据库集成** — 默认连接 AI tool 数据库，支持状态、优先级、负责人跟踪
- **后台执行** — 所有操作通过 `sessions_spawn` 在子 agent 中运行，不阻塞主会话
- **丰富格式** — 支持标题、表格、代码块、折叠区、分隔线等多种内容类型

## 🚀 快速开始

### 前置要求

- Python 3.8+
- OpenClaw 平台
- Notion integration token（已在技能中预配置）

### 使用方式

通过 `/notion` 命令或自然语言触发：

```bash
# 创建页面
"在 Notion 创建一个标题为'项目更新'的页面，附带总结表格"

# 读取页面
/notion read https://notion.so/My-Page-abc123...

# 查询数据库
/notion query

# 搜索工作区
/notion search "会议记录"
```

技能会自动启动子 agent 处理请求，完成后返回结果。

## 📖 文档

本技能使用 Notion API v2022-06-28。详细的 block 类型和属性结构参见 [Notion API 文档](https://developers.notion.com/reference/intro)。

Block 示例见 [`references/block-examples.json`](references/block-examples.json)。

## ⚙️ 配置

默认配置（在 `SKILL.md` 中设置）：

| 配置项 | 值 | 说明 |
|--------|-----|------|
| **Token** | `NOTION_TOKEN` 环境变量 | 在 `~/.bashrc` 中设置 |
| **默认数据库** | `YOUR_DATABASE_ID` | AI tool 数据库 |
| **API 版本** | `2022-06-28` | Notion API 版本 |
| **Base URL** | `https://api.notion.com/v1` | API 端点 |

### 数据库属性（AI tool）

| 属性 | 类型 | 选项 |
|------|------|------|
| Task name | title | 必填 |
| Description | rich_text | 可选 |
| Status | status | "Not Started", "In progress", "Done" |
| Priority | select | 自定义值 |
| Due | date | 可选 |
| Assignee | people | 可选 |

## 📋 API 参考

### CLI 脚本

位于 `scripts/notion_api.py`：

```bash
# 创建页面
python3 notion_api.py create --title "标题" --description "描述" \
  --status "In progress" --content-file /tmp/content.json

# 读取页面
python3 notion_api.py read <page-id-or-url>

# 更新页面
python3 notion_api.py update <page-id-or-url> --status "Done" \
  --content-file /tmp/new-content.json

# 查询数据库
python3 notion_api.py query [database-id] --filter-status "In progress" --limit 10

# 搜索工作区
python3 notion_api.py search "关键词" --limit 5
```

### 内容块（Content Blocks）

以 JSON 数组形式构建内容。常用 block 类型：

- `heading_2`、`heading_3` — 章节标题
- `paragraph` — 文本段落
- `bulleted_list_item`、`numbered_list_item` — 列表
- `code` — 代码块（需指定 `language`）
- `table` — 表格，支持表头（⚠️ 实验数据、benchmark 等建议用表格而非列表）
- `quote`、`divider`、`toggle` — 富格式元素

模板参见 [`references/block-examples.json`](references/block-examples.json)。

## 🏗️ 项目结构

```
notion-writer/
├── SKILL.md                      # 技能配置与使用指南
├── scripts/
│   └── notion_api.py             # Notion API Python CLI
└── references/
    └── block-examples.json       # 内容块模板
```

## 📄 许可证

项目中未包含 LICENSE 文件。使用前请联系仓库所有者确认授权条款。

## 🙏 致谢

- 为 [OpenClaw](https://github.com/MitchellX/openclaw-luke) 平台构建
- 使用 [Notion API](https://developers.notion.com) v2022-06-28
