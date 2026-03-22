# Weekly Code Update: 2026-03-16 (Monday)

## Tracked Repos
- **Code Repos**: unity:paper, unity:LightningDiT
- **Unity Claude Sessions**: ~/.claude/projects/
- **OpenClaw Sessions**: agents/main, code1, code2, paper, reviewer, gpt, talk, gemini

---

## 💻 Code

**LightningDiT** — 2 commits

```
5f626be fix: STA buffer allocation bottleneck analysis report
a3d1c2f feat: QKV weight pre-permutation optimization
```

**paper** — 无新 commit

---

## 🤖 Claude on Unity

### LightningDiT session (2 sessions)

**Session 1: 显存优化 profiling**
- 分析了 MixedHeadAttention 的 VRAM 开销
- 发现三因素复合：理论 2.2x × 非编译 1.5x × compile 碎片化 1.5x
- 实施 QKV 权重预排列优化 → 测试 18/18 通过

**Session 2: Block-level compile 尝试**
- 尝试 enable_block_compile → 无改善
- 结论：瓶颈在 operator 内部，需要 Triton kernel fusion

---

## 💬 OpenClaw Agent Sessions

| Agent | Sessions | 主要内容 |
|-------|----------|---------|
| main | 3 | 日常对话、cron 同步 |
| code1 | 1 | 头像生成 |
| reviewer | 1 | OBRA 退休金讨论 |

---

## 📊 Stats

| 指标 | 数据 |
|------|------|
| 新 commits | 2 (LightningDiT) |
| Unity Claude sessions | 2 |
| OpenClaw 活跃 sessions | main×3, code1×1, reviewer×1 |

*更新：2026-03-17 04:50 UTC (daily-sync cron)*
