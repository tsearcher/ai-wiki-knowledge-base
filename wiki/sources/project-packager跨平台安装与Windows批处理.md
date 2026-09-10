# project-packager 跨平台安装与 Windows 批处理工具

> 这页是原始资料摘要：为 `project-packager` Skill 补充的一键安装脚本与 Windows 原生批处理打包工具。

## 资料讲什么

`raw/跨平台一键安装脚本和Windows 原生批处理打包工具.md` 在 [[project-packager-Skill]] 基础上新增部署与无 Python 环境下的打包能力，是对 [[project-packager完整文件包]] 的补充。

## 新增文件

- `install.bat`：Windows 一键安装脚本，双击即可自动建目录、生成所有脚本文件、安装 `pyyaml` 依赖；用 PowerShell 从批处理自身内嵌的标记段（`===*_START===` … `===*_END===`）提取出 `pack.py`、`wiki-manager.py` 及各 `.bat`。
- `install.sh`：Linux/macOS 一键安装脚本，用 `awk` 提取内嵌 Python 脚本。
- `references/pack.py`：可直接运行的 Python 打包脚本（提取版）。
- `references/wiki-manager.py`：可直接运行的 Wiki 管理脚本（提取版）。
- `references/pack.bat`：Windows 原生打包脚本，**无需 Python**，基于系统自带 PowerShell 运行，自动排除开发目录，生成 `项目名_版本号_日期_release.zip` 规范文件名。
- `references/pack-with-wiki.bat`：打包 + [[本地AI-Wiki知识库]] 录入入口，封装 `pack.py` 并传入 `--wiki-root`。
- `references/wiki-manager.bat`：Wiki 管理批处理入口（`init` / `query`）。

## 使用建议（资料原文）

- 快速部署：下载 `install.bat` 放空文件夹，双击运行自动生成完整 Skill 包。
- 日常使用：推荐 `pack-with-wiki.bat`，打包同时沉淀版本记录。
- 无 Python 环境：用纯原生 `pack.bat`，仅打包不录入 Wiki。

---
**内容来源**：`raw/跨平台一键安装脚本和Windows 原生批处理打包工具.md`
