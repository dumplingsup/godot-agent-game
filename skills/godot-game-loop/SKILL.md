---
name: godot-game-loop
description: Build and verify Godot games through file edits, Godot MCP, runtime inspection, and headless checks.
---

# Godot game loop

## Before editing

- Read `AGENTS.md` and inspect `project.godot` plus the active scene.
- Prefer the existing project architecture and avoid adding a dependency for a one-off helper.
- Use MCP read tools first when a live editor is connected.

## After editing

- Validate changed scripts and resources with Headless Godot.
- Run `tools/verify.ps1`.
- Start the scene when the change affects gameplay or presentation.
- Use Runtime Bridge state, simulated input, screenshots, or assertions as evidence.
- Fix the first reported error before adding more changes.

## Runtime contract

Gameplay scenes should expose a small `_mcp_state() -> Dictionary` method when practical. Return stable, human-readable state such as player position, health, score, current scene, and major mode flags. Keep the MCP bridge disabled in release builds if a shipped project does not need agent playtesting.
