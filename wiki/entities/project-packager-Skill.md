# project-packager Skill

> 这页讲一个工具：`project-packager` 是一个用于软件项目打包归档并维护本地 AI Wiki 知识库的 Skill。

## 它是什么

`project-packager` 用于软件版本发布、归档备份与知识库管理，核心能力两部分：①智能打包归档（自动识别项目版本、按规范命名生成压缩包、排除开发依赖文件）；②[[本地AI-Wiki知识库]] 维护（创建结构化本地 Markdown 知识库，打包后自动录入版本信息，支持历史版本查询、索引维护，可对接本地大模型 RAG 检索）。

## 组成

- `SKILL.md`：主控引导文件，定义使用场景与核心流程。
- `references/packager-naming-rules.md`：打包命名规范与排除规则。
- `references/packager-script-python.md`：Python 打包脚本（跨平台，集成 Wiki 录入）。
- `references/packager-script-shell.md`：Shell 打包脚本（纯打包）。
- `references/wiki-structure.md`：本地 AI Wiki 结构规范与页面模板。
- `references/wiki-manager-script.py`：Wiki 管理核心脚本（init / add-software / add-version-record / query / 重建索引）。
- 补充件：`install.bat`/`install.sh` 一键安装脚本，`pack.bat`/`pack-with-wiki.bat`/`wiki-manager.bat` Windows 批处理工具。

## 核心流程

- **流程A 打包 + 自动录入 Wiki**：确认参数 → 读命名规范 → 打包 → 读 Wiki 规范 → 录入版本信息 → 更新索引 → 输出结果。
- **流程B Wiki 独立维护**：确认操作类型（初始化 / 新增软件 / 录入版本 / 查询历史 / 重建索引）→ 读 Wiki 规范 → 调用管理脚本 → 返回结果。

## 关键约定

- 打包命名：`{项目名}_{版本号}_{日期}_{类型标识}.{扩展名}`，版本号采用 [[语义化版本号]] `vX.Y.Z`。
- 版本号来源优先级：命令行指定 > VERSION 文件 > 配置文件（package.json / pyproject.toml 等）> Git 标签 > 默认 `unknown`。
- 默认排除：`.git/`、`node_modules/`、`__pycache__/`、`.venv/`/`venv/`、`dist/`/`build/`、`*.log`、`.DS_Store`、`.idea/`/`.vscode/` 等。
- 低耦合：不加 `--wiki-root` 时与原打包功能完全一致。

## 资料来源

本工具由三份资料从不同角度描述，互为补充、无冲突：
- [[project-packager完整文件包]]：合并后的完整可导入文件包。
- [[project-packager增强版-本地AIWiki]]：增强版能力说明（新增 Wiki 录入）。
- [[project-packager跨平台安装与Windows批处理]]：一键安装脚本与 Windows 原生批处理工具。

---
**内容来源**：`raw/可直接导入的完整 Skill 文件包.md`、`raw/项目打包归档并写入本地AI WIKI知识库.md`、`raw/跨平台一键安装脚本和Windows 原生批处理打包工具.md`
