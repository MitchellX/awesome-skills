# 周记：2026-03-16 ~ 03-22

## 2026-03-16 (Monday)

### 🛠️ 工程 & 研究
- **LinStat 显存优化深入分析** — Mitchell 用 Unity Claude Code 做了大量工作：
  - 完成 MixedHeadAttention 显存 profiling 报告
  - 发现 6.5x VRAM 开销的三因素复合
- 💻 代码：2 commits on LightningDiT（详见 `memory/weekly_codes_update/`）

### 📋 Notion 任务

**状态变化**

| 任务 | 变化 |
|------|------|
| 回去主要是先看YouTube 视频 | Reminders → Done |
| 测试一下Claude桌面端端 dispatch | Reminders → Done |
| 整理我的两个cron job | Reminders → Done |

**新增任务 (+4)**

| 状态 | 任务 |
|------|------|
| Reminders | 把每个agents赋予/match到unity对应的repo上 |
| Doing | 多做成: skills |
| Reminders | 研究小红书的 auto research 实例们 |
| Reminders | 把 claude code 官方discord plugin也装在 unity CC上面 |

**删除任务 (-1)**

- ~~AliceLJY/telegram-ai-bridge 也研究一下~~ [Reminders]

### 📬 邮件 & 其他
- USCIS 案件有新动态 — 需要登录查看
- Weekly cleanup cron 清理 42 个过期文件

## 2026-03-17 (Tuesday)

### 🛠️ 工程 & 研究
- **LinStat 内存优化迭代完成** — 两轮优化尝试均未改善 max_batch
  - 最终发现瓶颈在 STA buffer allocation 和 dispatch overhead
- 💻 代码：1 commit `5f626be`（详见 `memory/weekly_codes_update/`）

### 🔍 调研
- 研究 Codex Deep Search — 如何用 OpenAI Codex CLI 做多来源综合报告

### 📋 Notion 任务
- 无变化

## 2026-03-18 (Wednesday)

### 💰 生活 & 个人
- 和 reviewer agent 深入研究 UMass OBRA 退休金计划
- 🎉 Fidelity Visa Signature 信用卡获批，$27,000 额度

### 🧠 系统改进
- memory-lancedb-pro v1.1.0-beta.9 安装完成

### 📋 Notion 任务

**新增任务 (+7)**

| 状态 | 任务 |
|------|------|
| Not Started | 回去主要是先看YouTube 视频 |
| Not Started | AliceLJY/telegram-ai-bridge 也研究一下 |
| Not Started | 测试一下Claude桌面端端 dispatch |
| Not Started | 可以定时cron job 清理30天内没有信息的 session |
| Not Started | 参考这个人更新一下我的 readme |
| Not Started | Claude for chrome 有什么可以研究的吗? |
| Not Started | 研究一下: Ruflo |

### 💻 代码
- 无新 commit（详见 `memory/weekly_codes_update/`）
