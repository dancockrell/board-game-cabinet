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
foreach ($test in @("test_sprite_clip", "test_chess", "test_chess_oracle", "test_session", "test_draw_claims", "test_pgn", "test_olympus_audio", "test_olympus_hud_fx")) {
    Invoke-GodotCheck @("--headless", "--script", "res://tests/$test.gd")
}
if ($Graphics) {
    foreach ($test in @("test_sprite_clip", "test_pixel_motion_continuity", "test_hydra_lateral", "test_hydra_south_walk", "test_hydra_north_walk", "test_harpy_south_flight", "test_harpy_north_flight", "test_atalanta_lateral_walk", "test_atalanta_east_board", "test_atalanta_west_walk", "test_atalanta_west_board", "test_olympus_combat_fx", "test_olympus_board", "test_olympus_stage", "test_olympus_models", "test_olympus_app", "test_olympus_2d_only")) {
        Invoke-GodotCheck @("--rendering-method", "gl_compatibility", "--script", "res://tests/$test.gd")
    }
}
Invoke-GodotCheck @("--headless", "--script", "res://games/ninth_gate/test_ninth_gate.gd")
Invoke-GodotCheck @("--headless", "--script", "res://games/olympus_arena/test_arena.gd")


