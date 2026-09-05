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
foreach ($test in @("test_chess", "test_chess_oracle", "test_session")) {
    Invoke-GodotCheck @("--headless", "--script", "res://tests/$test.gd")
}
if ($Graphics) {
    foreach ($test in @("test_board", "test_app")) {
        Invoke-GodotCheck @("--rendering-method", "gl_compatibility", "--script", "res://tests/$test.gd")
    }
}
