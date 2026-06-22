# Troubleshooting

本项目主要面向 Windows PowerShell，因此重点记录 Windows 下最容易踩的坑。

## 1. Codex 401 Unauthorized

错误示例：

```text
unexpected status 401 Unauthorized: Incorrect API key provided
```

常见原因：

- Codex 仍在使用旧的 API Key 登录状态。
- `OPENAI_API_KEY` 或 `CODEX_API_KEY` 环境变量残留。
- `~/.codex/auth.json` 或 Windows 凭据管理器里有旧凭据。

建议处理：

```powershell
codex logout
Get-ChildItem Env: | Where-Object { $_.Name -match "OPENAI|CODEX|API" }
[Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $null, "User")
[Environment]::SetEnvironmentVariable("CODEX_API_KEY", $null, "User")
```

重新登录：

```powershell
codex login
codex login status
```

目标结果：

```text
Logged in using ChatGPT
```

## 2. PowerShell 当前目录脚本无法执行

错误示例：

```text
无法将“02_new_project.ps1”项识别为 cmdlet
```

原因：PowerShell 默认不会从当前目录执行脚本。

错误写法：

```powershell
02_new_project.ps1
```

正确写法：

```powershell
.\02_new_project.ps1
```

或使用完整路径：

```powershell
E:\AICoding\_scripts\02_new_project.ps1
```

## 3. 参数错位：Template 收到项目名

错误示例：

```text
参数“customer-voc-tool”不属于 ValidateSet “project-basic,python-cli,web-static”
```

原因：旧脚本中使用了数组 splatting，导致命名参数变成位置参数。

修复方式：使用当前仓库中的 `scripts/Start-CodexProject.ps1` 重新安装：

```powershell
.\scripts\Install-CodexProjectBootstrapper.ps1 -WorkRoot "E:\AICoding"
```

## 4. 中文乱码导致脚本解析失败

错误示例：

```text
Alan 鑷敤
函数参数列表中缺少“)”
```

原因：PowerShell 脚本中包含中文默认值或 here-string，保存/读取编码不一致。

当前策略：

- PowerShell 脚本本体使用 ASCII-only。
- 中文内容通过参数或 Markdown 模板进入生成文件。
- 写文件统一使用 UTF-8 without BOM。

## 5. pyproject.toml: Invalid statement

错误示例：

```text
TOMLDecodeError: Invalid statement (at line 1, column 1)
```

常见原因：

- `pyproject.toml` 被写入 UTF-8 BOM。
- 文件首字符被写成乱码 BOM。
- 文件内容被 PowerShell here-string 破坏。

当前启动脚本会直接重写干净的 `pyproject.toml`。

如需手动检查：

```powershell
cd E:\AICoding\projects\your-project
python -m pip install -e ".[dev]"
```

## 6. No module named app

错误示例：

```text
No module named app
```

原因：

- `pip install -e ".[dev]"` 没成功。
- `pyproject.toml` 无效。
- `src/app/__init__.py` 缺失。

修复：

```powershell
cd E:\AICoding\projects\your-project
pip install -e ".[dev]"
python -m app hello --name Alan
```

## 7. pytest 调用了全局 Python

现象：

```text
C:\Users\YH\AppData\Roaming\Python\Python310\site-packages\_pytest
```

原因：当前虚拟环境没有安装 pytest，PowerShell 找到了全局 pytest。

建议永远使用：

```powershell
python -m pytest
```

不要直接用：

```powershell
pytest
```

## 8. 项目已存在

错误示例：

```text
Project already exists
```

谨慎使用：

```powershell
-Force
```

例如：

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

`-Force` 会复用/覆盖部分文件。对已有重要内容的项目，先备份。

## 9. API Key 暴露

如果截图、日志、仓库或对话中暴露过 API Key：

1. 立即去对应平台吊销旧 key。
2. 重新生成新 key。
3. 不要把 key 写进脚本、README、AGENTS 或日志。
4. 使用环境变量或密钥管理。

## 10. 推荐排查顺序

遇到问题按这个顺序看：

```text
1. Codex login status
2. E:\AICoding\_scripts\07_start_codex_project.ps1 是否为最新版本
3. 项目目录是否已存在
4. pyproject.toml 是否有效
5. pip install 是否成功
6. python -m app 是否成功
7. python -m pytest 是否成功
```
