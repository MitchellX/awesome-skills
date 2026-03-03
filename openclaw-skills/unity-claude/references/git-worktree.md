# Git Worktree 隔离

## 何时使用

当 Mitchell 明确说要 "worktree 隔离" / "git worktree" / "并行隔离" 时才启用。

**默认不用** — 单任务直接在当前 branch 上工作就行。

## 使用场景

- 并行 dispatch 多个任务到同一个 repo，避免文件冲突
- 需要在独立分支上实验，完成后 merge 回来

## 工作流程

### 1. Dispatch 时加 `--worktree`

```bash
dispatch-to-unity.sh \
  -p "prompt" -n "task-name" -a "main" \
  -w "~/LightningDiT" --bypass \
  --worktree "task-name"
```

脚本自动：
- 在 repo 下创建 `.worktrees/<name>/`（`git worktree add`）
- 创建分支 `wt/<name>`
- 把 `-w` 重定向到 worktree 路径
- 在 prompt 末尾注入 merge + cleanup 指令

### 2. CC 完成后自动 merge

CC 在 prompt 指令下会：
1. 在 worktree 分支提交所有改动
2. 切回 base branch（dispatch 时记录的当前分支，不一定是 main）
3. `git merge wt/<name>`
4. 如有冲突，CC 自行解决（优先保留 worktree 的改动）
5. 删除 worktree + 分支

### 3. 如果 CC 没有自动 merge

Luke 可以 SSH 手动完成：

```bash
ssh unity "cd ~/LightningDiT && git checkout STA && git merge wt/task-name"
ssh unity "cd ~/LightningDiT && git worktree remove .worktrees/task-name && git branch -d wt/task-name"
```

## 路径约定

```
<repo>/
├── .worktrees/
│   ├── task-a/     # worktree for task-a (branch: wt/task-a)
│   └── task-b/     # worktree for task-b (branch: wt/task-b)
├── src/            # main branch files
└── ...
```

## 并行任务注意事项

- 多个 worktree 可以同时存在，互不影响
- 各自 merge 回 base branch 时，**后 merge 的可能有冲突**
- 冲突由 CC 或 Luke 解决
- 建议给每个 worktree 用有意义的名字（和 `-n` task name 一致）

## Active Task 元数据

`--worktree` 会在 `active-tasks/<name>.json` 中记录：

```json
{
  "worktree": {
    "name": "task-name",
    "base_branch": "STA",
    "repo": "~/LightningDiT"
  }
}
```

方便后续查看 worktree 状态或手动清理。
