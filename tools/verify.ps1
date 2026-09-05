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
foreach ($test in @("test_chess", "test_chess_oracle", "test_session", "test_draw_claims", "test_pgn", "test_olympus_audio", "test_olympus_hud_fx")) {
    Invoke-GodotCheck @("--headless", "--script", "res://tests/$test.gd")
}
if ($Graphics) {
    foreach ($test in @("test_board", "test_app", "test_controls", "test_ninth_gate_board", "test_ninth_gate_app", "test_olympus_combat_fx", "test_olympus_board", "test_olympus_stage", "test_olympus_models", "test_olympus_creatures", "test_olympus_app")) {
        Invoke-GodotCheck @("--rendering-method", "gl_compatibility", "--script", "res://tests/$test.gd")
    }
}
Invoke-GodotCheck @("--headless", "--script", "res://games/ninth_gate/test_ninth_gate.gd")
Invoke-GodotCheck @("--headless", "--script", "res://games/olympus_arena/test_arena.gd")
