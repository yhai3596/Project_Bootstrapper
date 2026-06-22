param(
    [Parameter(Mandatory=$true)]
    [string]$Name,

    [ValidateSet("project-basic", "python-cli", "web-static")]
    [string]$Template = "project-basic",

    [string]$WorkRoot = "E:\AICoding",

    [string]$Goal = "TBD",

    [string]$PrimaryUser = "Alan",

    [ValidateSet("MVP", "internal-test", "customer-delivery", "production", "research")]
    [string]$Stage = "MVP",

    [switch]$SetupPython,

    [switch]$InitGit,

    [switch]$OpenVSCode,

    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Step($Message) {
    Write-Host ""
    Write-Host "[STEP] $Message" -ForegroundColor Cyan
}

function To-Slug($text) {
    $slug = $text.ToLowerInvariant()
    $slug = $slug -replace "\s+", "-"
    $slug = $slug -replace "[^a-z0-9_-]", "-"
    $slug = $slug -replace "-+", "-"
    $slug = $slug.Trim("-")
    if ([string]::IsNullOrWhiteSpace($slug)) {
        $slug = "project-" + (Get-Date -Format "yyyyMMdd-HHmmss")
    }
    return $slug
}

function Write-Utf8NoBom($Path, $Lines) {
    New-Item -ItemType Directory -Force -Path (Split-Path $Path -Parent) | Out-Null
    if ($Lines -is [array]) {
        $Content = [string]::Join([Environment]::NewLine, $Lines)
    } else {
        $Content = [string]$Lines
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content + [Environment]::NewLine, $utf8NoBom)
}

function Replace-Tokens($Text, $Slug) {
    $Text = $Text.Replace("{{PROJECT_NAME}}", $Name)
    $Text = $Text.Replace("{{PROJECT_SLUG}}", $Slug)
    $Text = $Text.Replace("{{PROJECT_GOAL}}", $Goal)
    $Text = $Text.Replace("{{PRIMARY_USER}}", $PrimaryUser)
    $Text = $Text.Replace("{{PROJECT_STAGE}}", $Stage)
    $Text = $Text.Replace("{{PROJECT_TEMPLATE}}", $Template)
    return $Text
}

function Ensure-PythonCliProject($ProjectRoot, $Slug) {
    $tomlLines = @(
        "[build-system]",
        'requires = ["setuptools>=68"]',
        'build-backend = "setuptools.build_meta"',
        "",
        "[project]",
        "name = `"$Slug`"",
        'version = "0.1.0"',
        'description = "Python CLI project scaffold"',
        'requires-python = ">=3.10"',
        "dependencies = []",
        "",
        "[project.optional-dependencies]",
        'dev = ["pytest>=8.0"]',
        "",
        "[tool.setuptools]",
        'package-dir = {"" = "src"}',
        "",
        "[tool.setuptools.packages.find]",
        'where = ["src"]',
        "",
        "[tool.pytest.ini_options]",
        'testpaths = ["tests"]',
        'pythonpath = ["src"]'
    )
    Write-Utf8NoBom "$ProjectRoot\pyproject.toml" $tomlLines

    if (-not (Test-Path "$ProjectRoot\src\app\__main__.py")) {
        $mainLines = @(
            "from __future__ import annotations",
            "",
            "import argparse",
            "",
            "",
            "def build_parser() -> argparse.ArgumentParser:",
            '    parser = argparse.ArgumentParser(description="Python CLI scaffold")',
            '    subparsers = parser.add_subparsers(dest="command", required=True)',
            "",
            '    hello = subparsers.add_parser("hello", help="Print a greeting")',
            '    hello.add_argument("--name", default="Alan", help="Name to greet")',
            "",
            "    return parser",
            "",
            "",
            "def run_hello(name: str) -> str:",
            '    return f"Hello, {name}."',
            "",
            "",
            "def main() -> int:",
            "    parser = build_parser()",
            "    args = parser.parse_args()",
            "",
            '    if args.command == "hello":',
            "        print(run_hello(args.name))",
            "        return 0",
            "",
            '    parser.error(f"Unknown command: {args.command}")',
            "    return 2",
            "",
            "",
            'if __name__ == "__main__":',
            "    raise SystemExit(main())"
        )
        Write-Utf8NoBom "$ProjectRoot\src\app\__main__.py" $mainLines
    }

    Write-Utf8NoBom "$ProjectRoot\src\app\__init__.py" @('__version__ = "0.1.0"')

    if (-not (Test-Path "$ProjectRoot\tests\test_main.py")) {
        $testLines = @(
            "from app.__main__ import run_hello",
            "",
            "",
            "def test_run_hello():",
            '    assert run_hello("Alan") == "Hello, Alan."'
        )
        Write-Utf8NoBom "$ProjectRoot\tests\test_main.py" $testLines
    }
}

$Slug = To-Slug $Name
$ProjectRoot = Join-Path $WorkRoot "projects\$Slug"
$AgentsTemplate = Join-Path $WorkRoot "_templates\project-agents-template.md"
$NewProjectScript = Join-Path $WorkRoot "_scripts\02_new_project.ps1"

Write-Step "Preflight"
Write-Host "Name: $Name"
Write-Host "Slug: $Slug"
Write-Host "Template: $Template"
Write-Host "WorkRoot: $WorkRoot"
Write-Host "ProjectRoot: $ProjectRoot"

New-Item -ItemType Directory -Force -Path $WorkRoot, "$WorkRoot\projects", "$WorkRoot\_logs" | Out-Null

Write-Step "Create project"
if ((Test-Path $ProjectRoot) -and (-not $Force)) {
    throw "Project already exists: $ProjectRoot. Use -Force to overwrite/reuse cautiously."
}

if (Test-Path $NewProjectScript) {
    $newProjectParams = @{
        Name = $Name
        Template = $Template
        WorkRoot = $WorkRoot
    }
    if ($Force) {
        $newProjectParams["Force"] = $true
    }
    & $NewProjectScript @newProjectParams
} else {
    New-Item -ItemType Directory -Force -Path $ProjectRoot | Out-Null
    @("_docs", "_logs", "_data", "src", "tests", "_backups") | ForEach-Object {
        New-Item -ItemType Directory -Force -Path (Join-Path $ProjectRoot $_) | Out-Null
    }
}

if (-not (Test-Path $ProjectRoot)) {
    throw "Project creation failed: $ProjectRoot"
}

Write-Step "Install project AGENTS.md"
if (Test-Path $AgentsTemplate) {
    $agentsContent = Get-Content $AgentsTemplate -Raw -Encoding UTF8
} else {
    $agentsContent = "# AGENTS.md - {{PROJECT_NAME}}`n`nProject goal: {{PROJECT_GOAL}}`nStage: {{PROJECT_STAGE}}`nPrimary user: {{PRIMARY_USER}}`nTemplate: {{PROJECT_TEMPLATE}}`n`nWorkflow: diagnose first, then modify, then verify."
}
$agentsContent = Replace-Tokens $agentsContent $Slug
Write-Utf8NoBom "$ProjectRoot\AGENTS.md" $agentsContent

Write-Step "Generate project docs"
if (-not (Test-Path "$ProjectRoot\README.md")) {
    Write-Utf8NoBom "$ProjectRoot\README.md" @(
        "# $Name",
        "",
        "## Goal",
        "",
        $Goal,
        "",
        "## Primary user",
        "",
        $PrimaryUser,
        "",
        "## Stage",
        "",
        $Stage,
        "",
        "## Template",
        "",
        $Template,
        "",
        "## Start",
        "",
        "Read these files first:",
        "",
        "- AGENTS.md",
        "- _docs/CODEX_START_HERE.md",
        "- task_queue.md"
    )
}

Write-Utf8NoBom "$ProjectRoot\task_queue.md" @(
    "# Task Queue - $Name",
    "",
    "## Backlog",
    "",
    "- [ ] Project health check",
    "- [ ] Run the minimum executable path",
    "- [ ] Update README with real run commands",
    "- [ ] Define the first verifiable feature task",
    "",
    "## Doing",
    "",
    "## Done"
)

if (-not (Test-Path "$ProjectRoot\CHANGELOG.md")) {
    Write-Utf8NoBom "$ProjectRoot\CHANGELOG.md" @(
        "# Changelog",
        "",
        "## 0.1.0",
        "",
        "- Initialized Codex project: $Name"
    )
}

$firstPromptLines = @(
    "Please do not modify files yet.",
    "",
    "Project: $Name",
    "Goal: $Goal",
    "Primary user: $PrimaryUser",
    "Stage: $Stage",
    "",
    "Please read first:",
    "1. AGENTS.md",
    "2. README.md",
    "3. task_queue.md",
    "4. _docs/CODEX_START_HERE.md",
    "",
    "Then output:",
    "1. Your understanding of the project goal",
    "2. Current tech stack and structure",
    "3. Key entry files",
    "4. How to run",
    "5. How to test",
    "6. Biggest current risk",
    "7. Whether this is over-engineered",
    "8. The minimum verifiable next step",
    "",
    "Rules:",
    "- Do not modify files directly.",
    "- Do not add dependencies.",
    "- Prefer Windows PowerShell commands.",
    "- Judge first, then suggest."
)
Write-Utf8NoBom "$ProjectRoot\FIRST_PROMPT_FOR_CODEX.txt" $firstPromptLines

Write-Utf8NoBom "$ProjectRoot\_docs\CODEX_START_HERE.md" @(
    "# Codex Start Here - $Name",
    "",
    "## Goal",
    "",
    $Goal,
    "",
    "## Primary user",
    "",
    $PrimaryUser,
    "",
    "## Stage",
    "",
    $Stage,
    "",
    "## First prompt",
    "",
    "Copy the content of FIRST_PROMPT_FOR_CODEX.txt into a new Codex conversation.",
    "",
    "## Recommended first round",
    "",
    "1. Project health check",
    "2. Run minimum tests",
    "3. Fix README run commands",
    "4. Define the first minimum feature task",
    "",
    "## Do not",
    "",
    "- Do not do large refactors",
    "- Do not add dependencies before justification",
    "- Do not skip verification"
)

if ($Template -eq "python-cli") {
    Write-Step "Repair Python CLI template"
    Ensure-PythonCliProject $ProjectRoot $Slug
}

if ($InitGit) {
    Write-Step "Initialize Git"
    if (-not (Test-Path "$ProjectRoot\.git")) {
        git -C $ProjectRoot init
    }
    git -C $ProjectRoot status --short
}

if ($SetupPython -and $Template -eq "python-cli") {
    Write-Step "Setup Python environment"
    Push-Location $ProjectRoot
    try {
        if (-not (Test-Path ".venv")) {
            python -m venv .venv
        }
        & ".\.venv\Scripts\python.exe" -m pip install -U pip
        & ".\.venv\Scripts\pip.exe" install -e ".[dev]"
        & ".\.venv\Scripts\python.exe" -m app hello --name Alan
        & ".\.venv\Scripts\python.exe" -m pytest
    } finally {
        Pop-Location
    }
} elseif ($SetupPython) {
    Write-Host "-SetupPython only applies to python-cli template. Skipped." -ForegroundColor Yellow
}

Write-Utf8NoBom "$ProjectRoot\_docs\bootstrap_report.md" @(
    "# Bootstrap Report - $Name",
    "",
    "- Time: $(Get-Date -Format s)",
    "- ProjectRoot: $ProjectRoot",
    "- Template: $Template",
    "- Goal: $Goal",
    "- PrimaryUser: $PrimaryUser",
    "- Stage: $Stage",
    "- SetupPython: $SetupPython",
    "- InitGit: $InitGit",
    "",
    "## Generated files",
    "",
    "- AGENTS.md",
    "- README.md",
    "- task_queue.md",
    "- CHANGELOG.md",
    "- _docs/CODEX_START_HERE.md",
    "- FIRST_PROMPT_FOR_CODEX.txt",
    "",
    "## Next step",
    "",
    "Open Codex at:",
    "",
    $ProjectRoot,
    "",
    "Then paste:",
    "",
    "FIRST_PROMPT_FOR_CODEX.txt"
)

if ($OpenVSCode) {
    $code = Get-Command code -ErrorAction SilentlyContinue
    if ($code) {
        code $ProjectRoot
    } else {
        Write-Host "VS Code command 'code' not found. Skipped." -ForegroundColor Yellow
    }
}

Write-Step "Done"
Write-Host "Project ready: $ProjectRoot" -ForegroundColor Green
Write-Host ""
Write-Host "First Codex prompt:" -ForegroundColor Cyan
Write-Host "$ProjectRoot\FIRST_PROMPT_FOR_CODEX.txt"
Write-Host ""
Write-Host "Open project:" -ForegroundColor Cyan
Write-Host "cd $ProjectRoot"
