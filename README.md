# Codex Godot MCP Lab

This is a Godot 4.7.1 project configured for an editor MCP bridge, a file-first workflow, a runtime bridge, and headless acceptance checks.

## Commands

Run the deterministic checks after project changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\verify.ps1
```

With the project open in the Godot editor, run the live MCP check:

```powershell
D:\node\node.exe .\tools\mcp_live_smoke.mjs
```

Codex starts the project-scoped MCP server from `.codex/config.toml`. The Godot editor plugin connects to its local WebSocket endpoint at `127.0.0.1:6505` and exposes the editor scene tree, nodes, resources, runtime control, input, screenshots, and assertions.

Project rules live in `AGENTS.md`; the detailed game-loop skill is in `skills/godot-game-loop/SKILL.md`.
