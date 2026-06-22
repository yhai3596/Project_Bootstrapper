# Project Bootstrapper

Windows-first Codex 项目启动器，用于把新开 Codex 项目的重复配置流程自动化。

本仓库沉淀了 Alan 在配置 Codex 工作区过程中的稳定方案：

- 一条命令创建标准项目目录
- 自动生成项目级 `AGENTS.md`
- 自动生成 `README.md`、`task_queue.md`、`CHANGELOG.md`
- 自动生成 `FIRST_PROMPT_FOR_CODEX.txt`
- 自动安装 Codex Skill：`codex-project-starter`
- Python CLI 项目可选自动创建虚拟环境、安装依赖、运行测试
- 避免 Windows PowerShell 编码、BOM、here-string、参数 splatting 等常见坑

## 适用对象

适合以下场景：

- Windows + PowerShell + Codex App/CLI
- 想用 Codex 辅助开发工具、脚本、小型系统、原型项目
- 希望每个新项目都有稳定的项目规则和启动流程
- 不希望每次手工复制 AGENTS、README、任务提示词

默认工作区：

```text
E:\AICoding
```

## 设计原则

这个项目不是复杂框架，而是项目启动自动化工具。

核心判断：

```text
PowerShell 脚本：负责真实创建文件和目录
AGENTS.md：约束 Codex 的工作方式
Skill：让 Codex 知道何时使用这套启动流程
FIRST_PROMPT_FOR_CODEX.txt：降低新对话启动成本
```

不要把它改成复杂平台。稳定、可验证、低维护成本优先。

## 仓库结构

```text
Project_Bootstrapper
├─ README.md
├─ CHANGELOG.md
├─ LICENSE
├─ docs
│  ├─ USAGE.md
│  └─ TROUBLESHOOTING.md
├─ scripts
│  ├─ Install-CodexProjectBootstrapper.ps1
│  ├─ Start-CodexProject.ps1
│  └─ Test-CodexProjectBootstrapper.ps1
├─ assets
│  ├─ 01_GLOBAL_AGENTS_ALAN.md
│  ├─ 02_PROJECT_AGENTS_TEMPLATE.md
│  ├─ 04_CODEX_COMMON_TASK_PROMPTS.md
│  └─ 06_DAILY_CODEX_WORKFLOW.md
└─ skills
   └─ codex-project-starter
      ├─ SKILL.md
      ├─ references
      │  └─ project-start-workflow.md
      └─ scripts
         └─ start-codex-project.ps1
```

## 快速安装

克隆或下载本仓库后，在 PowerShell 中执行：

```powershell
cd <Project_Bootstrapper 仓库目录>
Set-ExecutionPolicy -Scope Process Bypass -Force
.\scripts\Install-CodexProjectBootstrapper.ps1 -WorkRoot "E:\AICoding"
```

默认安装内容：

```text
E:\AICoding\_scripts\07_start_codex_project.ps1
E:\AICoding\_scripts\08_test_codex_project_bootstrapper.ps1
E:\AICoding\_templates\project-agents-template.md
E:\AICoding\_docs\codex-starter-pack\04_CODEX_COMMON_TASK_PROMPTS.md
E:\AICoding\_docs\codex-starter-pack\06_DAILY_CODEX_WORKFLOW.md
C:\Users\YH\.codex\skills\codex-project-starter\
```

默认不会覆盖：

```text
C:\Users\YH\.codex\config.toml
C:\Users\YH\.codex\AGENTS.md
```

需要安装全局 AGENTS 时显式执行：

```powershell
.\scripts\Install-CodexProjectBootstrapper.ps1 -WorkRoot "E:\AICoding" -InstallGlobalAgents
```

## 一条命令新建项目

### Python CLI 项目

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "customer-voc-tool" `
  -Template "python-cli" `
  -Goal "北美 HVAC 用户和安装工 VOC 信息整理工具" `
  -PrimaryUser "Alan" `
  -Stage "MVP" `
  -SetupPython
```

成功标准：

```text
Successfully built customer-voc-tool
Hello, Alan.
1 passed
Project ready: E:\AICoding\projects\customer-voc-tool
```

### 静态网页原型

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "voc-dashboard-demo" `
  -Template "web-static" `
  -Goal "VOC 分析结果的静态展示原型" `
  -PrimaryUser "Alan" `
  -Stage "MVP"
```

### 通用项目

```powershell
E:\AICoding\_scripts\07_start_codex_project.ps1 `
  -Name "ai-task-helper" `
  -Template "project-basic" `
  -Goal "个人 AI 任务起步助手" `
  -PrimaryUser "Alan" `
  -Stage "MVP"
```

## 新项目会生成什么

以 `customer-voc-tool` 为例：

```text
E:\AICoding\projects\customer-voc-tool
├─ AGENTS.md
├─ README.md
├─ task_queue.md
├─ CHANGELOG.md
├─ FIRST_PROMPT_FOR_CODEX.txt
├─ _docs
│  ├─ CODEX_START_HERE.md
│  └─ bootstrap_report.md
├─ src
├─ tests
└─ pyproject.toml
```

## Codex 中如何使用

打开 Codex，进入项目目录：

```text
E:\AICoding\projects\customer-voc-tool
```

然后打开：

```text
FIRST_PROMPT_FOR_CODEX.txt
```

把其中内容复制到 Codex 新对话。

这一步的目的不是让 Codex 直接开发，而是先做项目体检：

- 理解项目目标
- 判断技术栈和目录结构
- 找出入口文件
- 说明如何运行和测试
- 判断是否过度工程
- 给出最小可验证下一步

## 验证安装

```powershell
E:\AICoding\_scripts\08_test_codex_project_bootstrapper.ps1
```

成功标准：

```text
Logged in using ChatGPT
Project created: E:\AICoding\projects\codex-bootstrap-smoke-test
Hello, Alan.
1 passed
```

## 常见问题

详细见：

```text
docs/TROUBLESHOOTING.md
```

这个工具在 Windows PowerShell 下特别规避了以下问题：

- 中文字符串乱码
- UTF-8 BOM 导致 `pyproject.toml` 解析失败
- here-string 定界符损坏
- 数组 splatting 导致参数错位
- `pytest` 调到全局 Python 环境

## 推荐工作流

```text
1. 运行 07_start_codex_project.ps1 创建项目
2. 打开项目目录
3. 复制 FIRST_PROMPT_FOR_CODEX.txt 到 Codex 新对话
4. Codex 做项目体检
5. 生成任务队列
6. 执行第一个小任务
7. 运行验证
8. 更新 task_queue.md 和 CHANGELOG.md
```

## 不建议做什么

- 不要让这个工具自动改 `config.toml`
- 不要默认安装第三方 API provider
- 不要默认使用 `danger-full-access`
- 不要把新项目启动器改成复杂低代码平台
- 不要跳过项目体检直接让 Codex 写代码

## License

MIT License.
