# Godot MCP server source snapshot

This directory preserves the Node.js server source used by this project's local
Godot MCP setup. The matching Godot plugin is tracked under `addons/godot_mcp/`.
The upstream MIT license is included as `LICENSE`.

Generated dependencies, Godot binaries, and compiled server files under `.tools/`
are intentionally excluded from Git. To restore the server after cloning on the
original Windows machine:

```powershell
New-Item -ItemType Directory -Force .tools/godot-mcp-master/server
Copy-Item vendor/godot-mcp/server/* .tools/godot-mcp-master/server -Recurse -Force
Push-Location .tools/godot-mcp-master/server
npm ci
npm run build
Pop-Location
```

On another machine, also adapt `.codex/config.toml` and `tools/godot.ps1` to the
installed Node.js and Godot locations. These files currently record this Windows
development machine's absolute paths.
