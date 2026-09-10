# project-packager 完整文件包

> 这页是原始资料摘要：一份可直接导入的 `project-packager` Skill 完整文件包，含主控文件与 5 个资源文件。

## 资料讲什么

`raw/可直接导入的完整 Skill 文件包.md` 给出了 [[project-packager-Skill]] 的全部文件内容，按目录结构保存即可导入使用。Skill 用于软件版本发布、归档备份与知识库管理，核心能力两部分：①智能打包归档（自动识别版本、规范命名、排除开发依赖）；②[[本地AI-Wiki知识库]] 维护（结构化 Markdown 知识库、打包后自动录入版本信息、可对接本地大模型 RAG 检索）。

## 文件清单

- `SKILL.md`：主控引导文件，定义使用场景与核心流程（流程A 打包+自动录入Wiki；流程B Wiki 独立维护）。
- `references/packager-naming-rules.md`：打包命名规范与排除规则。文件名格式 `{项目名}_{版本号}_{日期}_{类型标识}.{扩展名}`，版本号用 [[语义化版本号]] `vX.Y.Z`；版本号来源优先级为命令行 > VERSION 文件 > 配置文件 > Git 标签 > 默认 unknown。
- `references/packager-script-python.md`：Python 打包脚本（跨平台，集成 Wiki 自动录入，含 `--wiki-root`/`--changelog`/`--pack-type` 参数）。
- `references/packager-script-shell.md`：Shell 打包脚本（Linux/macOS，纯打包，不集成 Wiki）。
- `references/wiki-structure.md`：[[本地AI-Wiki知识库]] 目录结构与页面模板（软件页 YAML frontmatter、版本条目书写规范、总索引模板、RAG 优化建议）。
- `references/wiki-manager-script.py`：Wiki 管理核心脚本，支持 init / add-software / add-version-record / query / 重建索引。

## 关键约定

- 默认排除：`.git/`、`node_modules/`、`__pycache__/`、`.venv/`/`venv/`、`dist/`/`build/`、`*.log`、`.DS_Store`、`.idea/`/`.vscode/` 等。
- Wiki 目录：`wiki-root/index.md`（总索引）+ `software/*.md`（每软件一页）+ `assets/`（附件）。
- 软件页用 YAML frontmatter 存 `software_name / english_name / category / latest_version / last_pack_date / archive_path` 等元数据，便于 RAG 检索。

## 与同库其他资料的关系

本文与 [[project-packager增强版-本地AIWiki]]、[[project-packager跨平台安装与Windows批处理]] 同属一个 Skill 的不同切片：本文是合并后的完整文件包，增强版侧重能力描述，跨平台安装篇补充一键部署与批处理工具。三者互补、无冲突。

---
**内容来源**：`raw/可直接导入的完整 Skill 文件包.md`
