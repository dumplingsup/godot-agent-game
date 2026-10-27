import path from "node:path";
import { fileURLToPath } from "node:url";
import { Client } from "../.tools/godot-mcp-master/server/node_modules/@modelcontextprotocol/sdk/dist/esm/client/index.js";
import { StdioClientTransport } from "../.tools/godot-mcp-master/server/node_modules/@modelcontextprotocol/sdk/dist/esm/client/stdio.js";

const projectRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const serverRoot = path.join(projectRoot, ".tools", "godot-mcp-master", "server");
const serverEntry = path.join(serverRoot, "build", "index.js");
const mcpPort = process.env.GODOT_MCP_PORT ?? "6505";

const client = new Client({ name: "codex-godot-live-smoke", version: "1.0.0" });
const transport = new StdioClientTransport({
	command: process.execPath,
	args: [serverEntry],
	cwd: projectRoot,
	env: { ...process.env, GODOT_MCP_PORT: mcpPort },
	stderr: "pipe",
});

let started = false;

function resultJson(label, result) {
	if (result.isError) {
		throw new Error(`${label} returned an MCP error: ${JSON.stringify(result)}`);
	}
	const text = result.content?.find((item) => item.type === "text")?.text ?? "{}";
	try {
		return JSON.parse(text);
	} catch {
		return text;
	}
}

function wait(ms) {
	return new Promise((resolve) => setTimeout(resolve, ms));
}

async function callJsonWithRetry(label, request, attempts = 20) {
	let lastError;
	for (let attempt = 0; attempt < attempts; attempt += 1) {
		try {
			return resultJson(label, await request());
		} catch (error) {
			lastError = error;
			await wait(300);
		}
	}
	throw lastError ?? new Error(`${label} did not complete`);
}

try {
	await client.connect(transport);
	started = true;
	console.log(`MCP_PORT=${mcpPort}`);
	const listed = await client.listTools();
	console.log(`MCP_TOOLS=${listed.tools.length}`);
	if (listed.tools.length < 100) {
		throw new Error(`Expected the Godot MCP tool catalog, got ${listed.tools.length} tools`);
	}

	const projectInfo = await callJsonWithRetry(
		"get_project_info",
		() => client.callTool({ name: "get_project_info", arguments: {} }),
	);
	console.log(`MCP_PROJECT=${JSON.stringify(projectInfo)}`);

	const sceneTree = await callJsonWithRetry(
		"get_scene_tree",
		() => client.callTool({ name: "get_scene_tree", arguments: {} }),
	);
	console.log(`MCP_EDITOR_SCENE=${JSON.stringify(sceneTree)}`);

	await callJsonWithRetry(
		"play_scene",
		() => client.callTool({ name: "play_scene", arguments: { mode: "main" } }),
	);

	let gameTree;
	let lastError;
	for (let attempt = 0; attempt < 10; attempt += 1) {
		await wait(300);
		try {
			gameTree = resultJson(
				"get_game_scene_tree",
				await client.callTool({ name: "get_game_scene_tree", arguments: {} }),
			);
			break;
		} catch (error) {
			lastError = error;
		}
	}
	if (!gameTree) throw lastError ?? new Error("Game scene did not become available");
	console.log(`MCP_RUNTIME_TREE=${JSON.stringify(gameTree)}`);

	const state = await callJsonWithRetry(
		"execute_game_script",
		() => client.callTool({ name: "execute_game_script", arguments: { code: "_mcp_state()" } }),
	);
	console.log(`MCP_RUNTIME_STATE=${JSON.stringify(state)}`);
	const initialX = Number(
		await callJsonWithRetry(
			"read player x",
			() => client.callTool({ name: "execute_game_script", arguments: { code: "player.position.x" } }),
		),
	);

	await callJsonWithRetry(
		"simulate_action",
		() => client.callTool({ name: "simulate_action", arguments: { action: "ui_right", pressed: true } }),
	);
	await wait(500);
	const movedX = Number(
		await callJsonWithRetry(
			"read moved player x",
			() => client.callTool({ name: "execute_game_script", arguments: { code: "player.position.x" } }),
		),
	);
	await wait(2200);
	const score = Number(
		await callJsonWithRetry(
			"read score",
			() => client.callTool({ name: "execute_game_script", arguments: { code: "score" } }),
		),
	);
	const gameWon = await callJsonWithRetry(
		"read game won",
		() => client.callTool({ name: "execute_game_script", arguments: { code: "game_won" } }),
	);
	await callJsonWithRetry(
		"simulate_action release",
		() => client.callTool({ name: "simulate_action", arguments: { action: "ui_right", pressed: false } }),
	);
	if (!Number.isFinite(initialX) || !Number.isFinite(movedX) || movedX <= initialX) {
		throw new Error(`Runtime input was not observed: initialX=${initialX}, movedX=${movedX}`);
	}
	console.log(`MCP_INPUT_MOVED=true initialX=${initialX} movedX=${movedX}`);
	const gameWonValue = gameWon === true || gameWon === "true";
	if (score < 1 || !gameWonValue) {
		throw new Error(`MVP gameplay did not complete: score=${score}, gameWon=${gameWon}`);
	}
	console.log(`MCP_GAMEPLAY_WIN=true score=${score}`);

	const screenshot = await callJsonWithRetry(
		"get_game_screenshot",
		() => client.callTool({ name: "get_game_screenshot", arguments: {} }),
	);
	console.log(`MCP_RUNTIME_SCREENSHOT=${JSON.stringify({ width: screenshot.width, height: screenshot.height })}`);

	console.log("MCP_LIVE_SMOKE=true");
} finally {
	if (started) {
		try {
			await client.callTool({ name: "stop_scene", arguments: {} });
		} catch {
			// The editor may already have stopped the scene during cleanup.
		}
	}
	await client.close();
}
