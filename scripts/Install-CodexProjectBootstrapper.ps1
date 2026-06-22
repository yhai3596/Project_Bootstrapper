param(
    [string]$WorkRoot = "E:\AICoding",
    [switch]$InstallGlobalAgents,
    [switch]$MergeConfig,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) {
    Write-Host ""
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function Copy-FileSafe($Source, $Target, [switch]$Backup) {
    if (-not (Test-Path $Source)) {
        throw "Source not found: $Source"
    }

    New-Item -ItemType Directory -Force -Path (Split-Path $Target -Parent) | Out-Null

    if ((Test-Path $Target) -and $Backup) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Copy-Item $Target "$Target.backup_$stamp" -Force
        Write-Host "Backup: $Target.backup_$stamp" -ForegroundColor Yellow
    }

    Copy-Item $Source $Target -Force
    Write-Host "Copied: $Target" -ForegroundColor Green
}

$SourceRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$CodexHome = Join-Path $HOME ".codex"

Write-Step "Create folders"
@(
    $WorkRoot,
    "$WorkRoot\_scripts",
    "$WorkRoot\_templates",
    "$WorkRoot\_docs",
    "$WorkRoot\_docs\codex-starter-pack",
    "$WorkRoot\projects",
    $CodexHome,
    "$CodexHome\skills"
) | ForEach-Object {
    New-Item -ItemType Directory -Force -Path $_ | Out-Null
    Write-Host "OK: $_"
}

Write-Step "Install scripts"
Copy-FileSafe "$SourceRoot\scripts\Start-CodexProject.ps1" "$WorkRoot\_scripts\07_start_codex_project.ps1" -Backup
Copy-FileSafe "$SourceRoot\scripts\Test-CodexProjectBootstrapper.ps1" "$WorkRoot\_scripts\08_test_codex_project_bootstrapper.ps1" -Backup

Write-Step "Install assets"
Copy-FileSafe "$SourceRoot\assets\02_PROJECT_AGENTS_TEMPLATE.md" "$WorkRoot\_templates\project-agents-template.md" -Backup
Copy-FileSafe "$SourceRoot\assets\04_CODEX_COMMON_TASK_PROMPTS.md" "$WorkRoot\_docs\codex-starter-pack\04_CODEX_COMMON_TASK_PROMPTS.md" -Backup
Copy-FileSafe "$SourceRoot\assets\06_DAILY_CODEX_WORKFLOW.md" "$WorkRoot\_docs\codex-starter-pack\06_DAILY_CODEX_WORKFLOW.md" -Backup

Write-Step "Install Codex skill"
$SkillSource = "$SourceRoot\skills\codex-project-starter"
$SkillTarget = "$CodexHome\skills\codex-project-starter"
if (-not (Test-Path $SkillSource)) {
    throw "Skill source not found: $SkillSource"
}
if ((Test-Path $SkillTarget) -and $Force) {
    Remove-Item $SkillTarget -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $SkillTarget | Out-Null
Copy-Item "$SkillSource\*" $SkillTarget -Recurse -Force
Write-Host "Skill installed: $SkillTarget" -ForegroundColor Green

if ($InstallGlobalAgents) {
    Write-Step "Install global AGENTS.md"
    Copy-FileSafe "$SourceRoot\assets\01_GLOBAL_AGENTS_ALAN.md" "$CodexHome\AGENTS.md" -Backup
} else {
    Write-Host ""
    Write-Host "[SKIP] Global AGENTS.md not installed. Use -InstallGlobalAgents to enable." -ForegroundColor Yellow
}

if ($MergeConfig) {
    Write-Step "Conservative config merge"
    $ConfigPath = "$CodexHome\config.toml"

    if (Test-Path $ConfigPath) {
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Copy-Item $ConfigPath "$ConfigPath.backup_$stamp" -Force
        $config = Get-Content $ConfigPath -Raw -Encoding UTF8
    } else {
        $config = ""
    }

    $linesToAdd = @(
        'approval_policy = "on-request"',
        'project_doc_fallback_filenames = ["AGENTS.md", "README.md", "PROJECT.md", "CONTRIBUTING.md"]',
        'project_doc_max_bytes = 65536',
        'project_root_markers = [".git", "pyproject.toml", "package.json", "requirements.txt", "README.md"]'
    )

    foreach ($line in $linesToAdd) {
        $key = ($line -split "=")[0].Trim()
        if ($config -notmatch "(?m)^\s*$([regex]::Escape($key))\s*=") {
            $config += "`n$line"
            Write-Host "Add config: $line" -ForegroundColor Green
        } else {
            Write-Host "Skip existing config key: $key" -ForegroundColor Yellow
        }
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($ConfigPath, $config.Trim() + "`n", $utf8NoBom)
} else {
    Write-Host ""
    Write-Host "[SKIP] config.toml not merged. Use -MergeConfig if needed." -ForegroundColor Yellow
}

Write-Step "Done"
Write-Host "Bootstrapper installed." -ForegroundColor Green
Write-Host "Try:" -ForegroundColor Cyan
Write-Host "$WorkRoot\_scripts\07_start_codex_project.ps1 -Name \"codex-demo\" -Template \"python-cli\" -Goal \"Test Codex bootstrapper\" -SetupPython"
