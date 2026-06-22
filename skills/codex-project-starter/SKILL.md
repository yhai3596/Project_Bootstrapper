---
name: codex-project-starter
description: Use when starting, bootstrapping, or standardizing a new Codex project for Alan; creates or checks AGENTS.md, README, task_queue, startup prompts, Windows PowerShell commands, and minimal verification plan. Do not use for normal feature work after the project is already configured.
---

# Codex Project Starter Skill

Use this skill when the user says:

- 新开 Codex 项目
- 初始化项目
- 项目启动
- 配置 AGENTS.md
- 生成项目体检
- 新建 Python CLI / Web 原型 / 通用项目
- 把 Codex 工作流自动化

## Core workflow

1. Confirm the project path, project name, template type, primary user, and goal.
2. Prefer a script-based bootstrap instead of asking the user to manually copy many files.
3. If the user is on Windows, use PowerShell commands.
4. Generate or update:
   - `AGENTS.md`
   - `README.md`
   - `task_queue.md`
   - `CHANGELOG.md`
   - `_docs/CODEX_START_HERE.md`
   - `FIRST_PROMPT_FOR_CODEX.txt`
5. For Python CLI projects, verify:
   - `pyproject.toml` is valid TOML
   - `src/app/__init__.py` exists
   - `python -m app hello --name Alan` works
   - `python -m pytest` passes
6. Always end with a first prompt the user can paste into Codex.

## Preferred command

For Alan's default workspace:

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "<project-name>" `
  -Template "python-cli" `
  -Goal "<one sentence goal>" `
  -PrimaryUser "Alan" `
  -Stage "MVP" `
  -SetupPython
```

Use `web-static` for a static prototype and `project-basic` for non-code or early planning projects.

## Guardrails

- Do not overwrite `~/.codex/config.toml` automatically.
- Do not install global dependencies unless the user asks.
- Do not create API keys or write secrets.
- Do not use `danger-full-access` as default.
- Do not start feature development until project bootstrap and project health check are complete.

## Output format

When this skill is used, output:

一、结论  
二、推荐模板  
三、一条命令  
四、会生成什么  
五、如何验证  
六、复制给 Codex 的第一条提示词
