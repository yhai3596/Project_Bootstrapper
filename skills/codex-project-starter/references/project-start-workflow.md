# Project Start Workflow Reference

## Templates

- `python-cli`: Python command-line tool, data processor, automation script, agent runner.
- `web-static`: Static HTML/CSS/JS prototype, demo page, dashboard mockup.
- `project-basic`: Consulting project, planning doc, research workflow, non-code project.

## Minimum success criteria

- Project directory exists.
- `AGENTS.md` exists and contains project-specific goal.
- `README.md` exists.
- `task_queue.md` exists.
- `FIRST_PROMPT_FOR_CODEX.txt` exists.
- Python project: `pip install -e ".[dev]"`, `python -m app hello --name Alan`, and `python -m pytest` pass.

## First Codex prompt pattern

```text
Please do not modify files yet.

Project: <name>
Goal: <goal>
Primary user: <user>
Stage: <stage>

Please read first:
1. AGENTS.md
2. README.md
3. task_queue.md
4. _docs/CODEX_START_HERE.md

Then output:
1. Your understanding of the project goal
2. Current tech stack and structure
3. Key entry files
4. How to run
5. How to test
6. Biggest current risk
7. Whether this is over-engineered
8. The minimum verifiable next step
```
