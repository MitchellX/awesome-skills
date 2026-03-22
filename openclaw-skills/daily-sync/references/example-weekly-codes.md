# Weekly Code Update: 2026-03-16 ~ 03-22

## 2026-03-16 (Monday)

### 💻 Git Log

**LightningDiT** — 2 commits

```
5f626be fix: STA buffer allocation bottleneck analysis report
a3d1c2f feat: QKV weight pre-permutation optimization
```

**paper** — 无新 commit

### 🤖 Claude on Unity

**Session 1: 显存优化 profiling (37f11373)**
- 分析了 MixedHeadAttention 的 VRAM 开销
- 发现三因素复合：理论 2.2x × 非编译 1.5x × compile 碎片化 1.5x
- 实施 QKV 权重预排列优化 → 测试 18/18 通过

**Session 2: Block-level compile (a2280a0f)**
- 尝试 enable_block_compile → 无改善
- 结论：瓶颈在 operator 内部，需要 Triton kernel fusion

## 2026-03-17 (Tuesday)

### 💻 Git Log

**LightningDiT** — 无新 commit
**paper** — 无新 commit

### 🤖 Claude on Unity

无活跃 session

## 2026-03-18 (Wednesday)

### 💻 Git Log

无新 commit

### 🤖 Claude on Unity

无活跃 session
