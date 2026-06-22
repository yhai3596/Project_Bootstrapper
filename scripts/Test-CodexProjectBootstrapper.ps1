param(
    [string]$WorkRoot = "E:\AICoding"
)

$ErrorActionPreference = "Continue"

function Section($Title) {
    Write-Host ""
    Write-Host "=== $Title ===" -ForegroundColor Cyan
}

Section "Bootstrapper files"
$files = @(
    "$WorkRoot\_scripts\07_start_codex_project.ps1",
    "$WorkRoot\_scripts\08_test_codex_project_bootstrapper.ps1",
    "$WorkRoot\_templates\project-agents-template.md",
    "$WorkRoot\_docs\codex-starter-pack\04_CODEX_COMMON_TASK_PROMPTS.md",
    "$HOME\.codex\skills\codex-project-starter\SKILL.md"
)

foreach ($file in $files) {
    Write-Host "$file : $(Test-Path $file)"
}

Section "Codex login"
$codex = Get-Command codex -ErrorAction SilentlyContinue
if ($codex) {
    codex login status
} else {
    $candidate = "$env:LOCALAPPDATA\OpenAI\Codex\bin\8e55c2dd143b6354\codex.exe"
    if (Test-Path $candidate) {
        & $candidate login status
    } else {
        Write-Host "Codex CLI not found. This does not block project bootstrap tests." -ForegroundColor Yellow
    }
}

Section "Create smoke test project"
$script = "$WorkRoot\_scripts\07_start_codex_project.ps1"
if (Test-Path $script) {
    & $script -Name "codex-bootstrap-smoke-test" -Template "python-cli" -Goal "Verify Codex Project Bootstrapper" -Stage "MVP" -SetupPython -Force
} else {
    Write-Host "Bootstrap script not found: $script" -ForegroundColor Red
}

Section "Done"
Write-Host "If Python install and pytest passed, bootstrapper is working."
