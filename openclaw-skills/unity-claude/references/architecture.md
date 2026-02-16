# Architecture

## Network Constraints
- Unity cannot reach AWS (firewall blocks ping/curl/ssh outbound to AWS IP)
- Unity SSH server disables AllowTcpForwarding (no reverse tunnels)
- Only AWS → Unity SSH works (one-way)

## Components

### AWS Side (OpenClaw server)
- `scripts/claude-code/dispatch-to-unity.sh` — Dispatcher
- `scripts/claude-code/watch-unity-results.sh` — Watcher (SSH poll every 30s)
- `scripts/claude-code/results/` — Local results cache
- OpenClaw webhook: `/hooks/agent` for Discord delivery

### Unity Side
- `~/.claude/hooks/notify-agi.sh` — Stop/SessionEnd hook, writes latest.json + pending-wake.json
- `~/.claude/hooks/run-task.sh` — Runner wrapper (sets PATH, accepts --continue flag)
- `~/.claude/claude-code-results/` — Results directory
- `~/.claude/settings.json` — Hook registration (Stop + SessionEnd events)

## Flow
```
dispatch-to-unity.sh
  ├─ SSH: write prompt + task-meta.json
  ├─ SSH: clean .hook-lock + pending-wake.json
  ├─ SSH: tmux new-session → run-task.sh → claude [--continue] -p "prompt"
  └─ nohup: watch-unity-results.sh (background)
       └─ loop every 30s:
            SSH: test -f pending-wake.json?
            ├─ no → continue polling
            └─ yes → fetch latest.json → curl /hooks/agent → exit
```
