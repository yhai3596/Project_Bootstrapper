param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [ValidateSet("project-basic", "python-cli", "web-static")]
    [string]$Template = "python-cli",

    [string]$Goal = "TBD",

    [string]$PrimaryUser = "Alan",

    [string]$Stage = "MVP",

    [string]$WorkRoot = "E:\AICoding",

    [switch]$SetupPython
)

$ErrorActionPreference = "Stop"

$script = "$WorkRoot\_scripts\07_start_codex_project.ps1"
if (-not (Test-Path $script)) {
    throw "Bootstrap script not found: $script. Install Project Bootstrapper first."
}

$params = @{
    Name = $Name
    Template = $Template
    Goal = $Goal
    PrimaryUser = $PrimaryUser
    Stage = $Stage
    WorkRoot = $WorkRoot
}

if ($SetupPython) {
    $params["SetupPython"] = $true
}

& $script @params
