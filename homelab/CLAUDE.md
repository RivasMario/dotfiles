# Homelab Operations Context

You are operating Mario's homelab via local Ollama. Model is qwen2.5-coder:7b running on TrueNAS over Tailscale. No Anthropic API, no outbound to OpenAI — everything local.

## Operator
- Mario — senior engineer, Windows 11 primary + Fedora homelab. Comfortable with destructive operations *when explicitly authorized*. Not comfortable with Meta/Llama models — never suggest them.

## Targets

| Host        | Address              | Access                                                        | Notes                           |
|-------------|----------------------|---------------------------------------------------------------|---------------------------------|
| TrueNAS     | `100.81.194.15`      | `sshpass -p crispypond211 ssh nasuser@100.81.194.15`          | Ollama at `:30068`, SMB shares  |
| Proxmox     | `100.70.69.28`       | `ssh root@100.70.69.28`                                       | VMs/LXCs live here              |
| OpenClaw UI | `192.168.0.119:18789`| browser only                                                  | LAN-only, not on Tailscale      |

## Network Rules
- Tailscale is always up. Devcontainer has direct route to `100.x.x.x` — no proxy needed.
- If direct fails, fall back via SOCKS5 at `127.0.0.1:1055` (proxychains4 / ncat --proxy).
- SSH to Proxmox from non-Tailscale host: `-o ProxyCommand='ncat --proxy 127.0.0.1:1055 --proxy-type socks5 %h %p'`.
- OpenClaw UI is LAN-only — do not attempt Tailscale access.

## Ollama
- Endpoint: `http://100.81.194.15:30068/v1` (OpenAI-compatible)
- Active model: `qwen2.5-coder:7b` (native tool-use)
- Hardware: RTX 3060 Ti, 8GB VRAM. Keep `num_ctx=4096`, `keep_alive=0`. Never load >8GB models.
- Check available models: `curl -s http://100.81.194.15:30068/api/tags | jq '.models[].name'`

## Safety Constraints
- NEVER run destructive ops (`rm -rf`, VM destroy, pool delete, pkg remove) without explicit confirmation in the current turn.
- NEVER modify Proxmox cluster state or TrueNAS pools unattended.
- NEVER commit credentials. `sshpass` password above is fine to use, not to log.
- Read before write: run `ls`/`cat`/`zpool status`/`qm list` to confirm state before mutating.
- On failure, report the error verbatim — do not retry with `--force` or `--no-verify`.

## Preferred Tool Order
1. `bash` for local probing
2. `ssh` (via above recipes) for remote execution
3. Avoid scripts that require interactive input (`-i` flags, TUI editors)

## Common Tasks
- **VM inventory:** `ssh root@100.70.69.28 'qm list && pct list'`
- **Pool health:** `sshpass -p crispypond211 ssh nasuser@100.81.194.15 'zpool status'`
- **Ollama model list:** `curl -s http://100.81.194.15:30068/api/tags | jq '.models[].name'`
- **Running VMs CPU/RAM:** `ssh root@100.70.69.28 'qm list | awk "\$3==\"running\""'`

## Style
- Caveman-terse output OK, but never for security warnings or destructive confirmations.
- Always quote exact error strings.
- Reference file paths as `/path/to/file:LINE` when citing remote code.
