# Codex Godot MCP project rules

This repository is a Godot 4.7.1 Standard project using a local Godot MCP bridge.

## Development loop

Use this order for game changes:

1. Inspect the project and current scene before mutating it.
2. Edit `.gd`, `.tscn`, `.tres`, and `project.godot` with file tools when the change is textual.
3. Use Godot MCP for live editor state, scene-tree operations, undoable node/property changes, screenshots, and runtime control.
4. Run `powershell -ExecutionPolicy Bypass -File tools/verify.ps1` after any gameplay, scene, resource, or project-setting change.
5. For interactive changes, start the game and verify at least one observable state or input path through the Runtime Bridge.
6. Do not edit `.godot/` by hand; it is generated cache/import data.

For a live editor/runtime MCP check, keep this project open in Godot and run `D:\node\node.exe tools\mcp_live_smoke.mjs`. It verifies the MCP catalog, editor scene tree, runtime scene tree, `_mcp_state()`, input consumption, and a game screenshot.

## Acceptance criteria

- Godot headless editor import exits successfully.
- `scripts/qa_smoke.gd` loads the main scene and finds `MCPRuntimeBridge`.
- The main scene exposes `_mcp_state()` for structured runtime inspection.
- `scripts/gameplay_smoke.gd` proves the MVP collect-target flow reaches score 1 and `game_won=true`.
- Windows export passes when the local 4.7.1 export templates are present.
- New gameplay behavior has a reproducible smoke check or an explicit reason why it cannot be automated.

Read `skills/godot-game-loop/SKILL.md` for the detailed agent workflow before implementing a non-trivial game feature.
