[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$godotExe = Join-Path $projectRoot ".tools\godot-4.7.1\Godot_v4.7.1-stable_win64.exe"

if (-not (Test-Path -LiteralPath $godotExe)) {
	throw "Godot 4.7.1 was not found at $godotExe"
}

function Invoke-GodotChecked {
	param(
		[string]$Label,
		[string[]]$Arguments
	)

	$process = Start-Process -FilePath $godotExe -ArgumentList $Arguments -Wait -PassThru -NoNewWindow
	if ($process.ExitCode -ne 0) {
		throw "$Label failed with exit code $($process.ExitCode)"
	}
}

Write-Host "[1/4] Import and parse check"
Invoke-GodotChecked -Label "Godot editor import check" -Arguments @("--headless", "--path", $projectRoot, "--editor", "--quit")

Write-Host "[2/4] Runtime smoke check"
Invoke-GodotChecked -Label "Runtime smoke check" -Arguments @("--headless", "--path", $projectRoot, "--script", "res://scripts/qa_smoke.gd")

Write-Host "[3/4] Gameplay smoke check"
Invoke-GodotChecked -Label "Gameplay smoke check" -Arguments @("--headless", "--path", $projectRoot, "--script", "res://scripts/gameplay_smoke.gd")

Write-Host "[4/4] Windows export check"
$templateDir = Join-Path $env:APPDATA "Godot\export_templates\4.7.1.stable"
if (-not (Test-Path -LiteralPath $templateDir)) {
	Write-Warning "Export templates are not installed yet; skipping export check."
	exit 0
}

$buildDir = Join-Path $projectRoot "builds"
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
$output = Join-Path $buildDir "codex_mcp_lab.exe"
Invoke-GodotChecked -Label "Windows export check" -Arguments @("--headless", "--path", $projectRoot, "--export-debug", '"Windows Desktop"', $output)
if (-not (Test-Path -LiteralPath $output)) { throw "Expected export was not created at $output" }
Write-Host "Verified export: $output"
