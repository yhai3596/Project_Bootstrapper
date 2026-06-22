# 使用说明

## 1. 安装

克隆或下载仓库后执行：

```powershell
cd <Project_Bootstrapper 仓库目录>
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\Install-CodexProjectBootstrapper.ps1 -WorkRoot "E:\AICoding"
```

安装后会复制：

```text
E:\AICoding\_scripts\07_start_codex_project.ps1
E:\AICoding\_scripts\08_test_codex_project_bootstrapper.ps1
E:\AICoding\_templates\project-agents-template.md
E:\AICoding\_docs\codex-starter-pack\04_CODEX_COMMON_TASK_PROMPTS.md
E:\AICoding\_docs\codex-starter-pack\06_DAILY_CODEX_WORKFLOW.md
C:\Users\YH\.codex\skills\codex-project-starter\
```

## 2. 可选安装全局 AGENTS

```powershell
.\scripts\Install-CodexProjectBootstrapper.ps1 -WorkRoot "E:\AICoding" -InstallGlobalAgents
```

这会写入：

```text
C:\Users\YH\.codex\AGENTS.md
```

如果原文件已存在，会自动备份。

## 3. 可选合并 config

```powershell
.\scripts\Install-CodexProjectBootstrapper.ps1 -WorkRoot "E:\AICoding" -MergeConfig
```

只会追加保守配置，不会覆盖已有 `config.toml`。

不建议在 Codex 认证刚恢复时执行该选项。主配置稳定优先。

## 4. 创建 Python CLI 项目

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "customer-voc-tool" `
  -Template "python-cli" `
  -Goal "北美 HVAC 用户和安装工 VOC 信息整理工具" `
  -PrimaryUser "Alan" `
  -Stage "MVP" `
  -SetupPython
```

如果目录已存在，使用：

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "customer-voc-tool" `
  -Template "python-cli" `
  -Goal "北美 HVAC 用户和安装工 VOC 信息整理工具" `
  -PrimaryUser "Alan" `
  -Stage "MVP" `
  -SetupPython `
  -Force
```

## 5. 创建静态 Web 项目

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "voc-dashboard-demo" `
  -Template "web-static" `
  -Goal "VOC 分析结果的静态展示原型" `
  -PrimaryUser "Alan" `
  -Stage "MVP"
```

## 6. 创建通用项目

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "ai-task-helper" `
  -Template "project-basic" `
  -Goal "个人 AI 任务起步助手" `
  -PrimaryUser "Alan" `
  -Stage "MVP"
```

## 7. 验证安装

```powershell
E:\AICoding\_scripts\08_test_codex_project_bootstrapper.ps1
```

成功标准：

```text
Hello, Alan.
1 passed
```

## 8. 在 Codex 中继续

打开项目目录，例如：

```text
E:\AICoding\projects\customer-voc-tool
```

复制：

```text
FIRST_PROMPT_FOR_CODEX.txt
```

粘贴到 Codex 新对话。

不要一开始就让 Codex 开发功能。先做项目体检。

## 9. 推荐首轮流程

```text
1. Codex 阅读 AGENTS.md、README.md、task_queue.md
2. Codex 输出项目体检
3. 人工确认第一个最小任务
4. Codex 执行单任务
5. 运行验证
6. 更新 task_queue.md 和 CHANGELOG.md
```

## 10. 推荐模板选择

| 场景 | Template |
|---|---|
| Python 脚本、CLI 工具、数据处理 | `python-cli` |
| HTML 原型、静态看板、演示页面 | `web-static` |
| 咨询项目、文档项目、早期方案 | `project-basic` |

## 11. 不建议做法

- 不要把 `PrimaryUser` 写成复杂长中文句子，推荐先用 `Alan`。
- 不要让脚本自动修改 OpenAI / Codex 认证配置。
- 不要把第三方 API key 写进任何模板。
- 不要跳过 `FIRST_PROMPT_FOR_CODEX.txt`。
- 不要用 `-Force` 覆盖有重要内容的项目，除非已备份。
