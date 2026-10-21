# Claude Code - Dotfiles Workspace Guide

@AGENTS.md

## Claude Code Specifics
- Settings: `.claude/settings.json` (linked to `~/.claude/settings.json`; default model, plugins, permissions).
- Skills: shared ones in `skills/`; Claude-only or Claude-specific overrides in `.claude/skills/`.
- Plugins: caveman and karpathy-skills via marketplaces in `settings.json`; graphify bundle from `plugins/graphify`.
- Antigravity (`agy`) and Gemini CLI share this repo. Put shared rules in `AGENTS.md`, not here.
