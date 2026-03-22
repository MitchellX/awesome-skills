# 周记：2026-03-16 ~ 03-22

## 2026-03-16 (Monday)

### 🛠️ 工程 & 研究
- **LinStat 显存优化深入分析** — Mitchell 用 Unity Claude Code 做了大量工作：
  - 完成 MixedHeadAttention 显存 profiling 报告
  - 发现 6.5x VRAM 开销的三因素复合：理论 2.2x × 非编译 1.5x × compile 碎片化 1.5x
  - 实施了 QKV 权重预排列优化（测试全通过 18/18），但 max_batch 未改善
- 💻 代码：2 commits on LightningDiT（详见 `memory/weekly_codes_update/`）

### 📋 Notion 任务
- ✅ 完成: supplementary title 任务
- 新增 3 个任务（个人网站、继续研究、定期清理 session）
- 总数 72 (+3)

### 📬 邮件 & 其他
- USCIS 案件有新动态 — 需要登录查看
- OpenClaw reviewer agent 同步了 paper-polish-skill
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
- 和 reviewer agent 深入研究 UMass OBRA 退休金计划（扣 7.5%，管理平台 Empower）
- 🎉 Fidelity Visa Signature 信用卡获批，$27,000 额度

### 🧠 系统改进
- memory-lancedb-pro v1.1.0-beta.9 安装完成（Jina embedding + Gemini extraction）

### 📋 Notion 任务
- 新增 7 个任务（YouTube、Telegram bridge、dispatch 通用化等）

### 💻 代码
- 无新 commit（详见 `memory/weekly_codes_update/`）
