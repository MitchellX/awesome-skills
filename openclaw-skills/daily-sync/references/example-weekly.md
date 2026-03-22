# 周记：2026-03-16 ~ 03-22

## 2026-03-16 (Monday)

- **LinStat 显存优化深入分析** — Mitchell 用 Unity Claude Code 做了大量工作：
  - 完成 MixedHeadAttention 显存 profiling 报告
  - 发现 6.5x VRAM 开销的三因素复合
- **Notion 任务更新**: 完成 supplementary title 任务；新增 3 个任务
- OpenClaw reviewer agent 同步了 paper-polish-skill

## 2026-03-17 (Tuesday)

- **LinStat 内存优化迭代完成** — 两轮优化尝试：
  - Round 1：QKV 权重预排列，测试通过但 max_batch 无改善
  - Round 2：Block-level compile，仍无改善
- 安静的一天，没有其他大事
