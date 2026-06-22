# Changelog

## 0.1.0

Initial public version.

### Added

- Windows-first Codex project bootstrapper.
- `scripts/Install-CodexProjectBootstrapper.ps1`.
- `scripts/Start-CodexProject.ps1`.
- `scripts/Test-CodexProjectBootstrapper.ps1`.
- Project-level `AGENTS.md` template.
- Global AGENTS template for Alan.
- Common Codex task prompts.
- Daily Codex workflow reference.
- `codex-project-starter` Skill.
- Usage guide.
- Troubleshooting guide.

### Stabilized from field debugging

- Avoids PowerShell array splatting parameter misbinding.
- Avoids Chinese literals inside `.ps1` defaults.
- Avoids PowerShell here-string parser failure.
- Writes generated project files as UTF-8 without BOM.
- Generates valid `pyproject.toml` for Python CLI templates.
- Adds `src/app/__init__.py` and smoke tests.

### Verified behavior

A generated Python CLI project can pass:

```text
pip install -e ".[dev]"
python -m app hello --name Alan
python -m pytest
```
