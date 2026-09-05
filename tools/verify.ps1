param(
    [string]$Godot = "godot",
    [switch]$Graphics
)
$ErrorActionPreference = "Stop"
$projectPath = Split-Path -Parent $PSScriptRoot
function Invoke-GodotCheck([string[]]$CheckArgs) {
    $output = & $Godot --path $projectPath @CheckArgs 2>&1
    $exitCode = $LASTEXITCODE
    $output | Write-Output
    if ($exitCode -ne 0 -or ($output -match "SCRIPT ERROR|Parse Error|^ERROR:")) {
        throw "Godot validation failed."
    }
}
Invoke-GodotCheck @("--headless", "--editor", "--import", "--quit")
foreach ($test in @("test_chess", "test_chess_oracle", "test_session", "test_draw_claims", "test_pgn")) {
    Invoke-GodotCheck @("--headless", "--script", "res://tests/$test.gd")
}
if ($Graphics) {
    foreach ($test in @("test_board", "test_app", "test_controls")) {
        Invoke-GodotCheck @("--rendering-method", "gl_compatibility", "--script", "res://tests/$test.gd")
    }
}
Invoke-GodotCheck @("--headless", "--script", "res://games/ninth_gate/test_ninth_gate.gd")
Invoke-GodotCheck @("--headless", "--script", "res://tests/test_ninth_gate_app.gd")
