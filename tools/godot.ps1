[CmdletBinding()]
param(
	[Parameter(Position = 0, ValueFromRemainingArguments = $true)]
	[string[]]$GodotArguments
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$godotExe = Join-Path $projectRoot ".tools\godot-4.7.1\Godot_v4.7.1-stable_win64.exe"

if (-not (Test-Path -LiteralPath $godotExe)) {
	throw "Godot 4.7.1 was not found at $godotExe"
}

& $godotExe --path $projectRoot @GodotArguments
exit $LASTEXITCODE
