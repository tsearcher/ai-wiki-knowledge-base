# project-packager 增强版：打包归档与本地 AI Wiki

> 这页是原始资料摘要：`project-packager` Skill 的"增强版"说明，重点描述新增的本地 AI Wiki 创建与版本信息自动录入能力。

## 资料讲什么

`raw/项目打包归档并写入本地AI WIKI知识库.md` 描述在原有打包归档能力上新增 [[本地AI-Wiki知识库]] 维护能力的增强版 Skill，打包完成后自动将版本信息结构化写入本地 Markdown 知识库，可供本地大模型 RAG 检索。

## 内容要点

- 更新后结构：`SKILL.md`（全量更新）+ `references/`（packager-script-python.md、packager-script-shell.md、packager-naming-rules.md、wiki-structure.md、wiki-manager-script.py）。
- 打包脚本关键更新：新增 `--wiki-root`（指定 Wiki 根目录）、`--changelog`（变更摘要，可多次添加）、`--pack-type`（release/hotfix/snapshot/debug）参数；打包完成后调用 `LocalWikiManager` 自动录入版本信息并自动初始化 Wiki。
- 命名规范：`{项目名}_{版本号}_{日期}_{类型标识}.{扩展名}`，版本号 [[语义化版本号]] `vX.Y.Z`。
- 能力说明：双向打通（打包自动沉淀为知识库条目）、RAG 友好（结构化 YAML + 标准化条目）、独立可用（Wiki 管理可单独使用）、低耦合（不加 `--wiki-root` 时与原打包功能一致）。

## 与同库其他资料的关系

本文与 [[project-packager完整文件包]] 描述的是同一套增强能力（完整文件包中已含 wiki-structure.md 与 wiki-manager-script.py），可视为增强版的先期描述；[[project-packager跨平台安装与Windows批处理]] 在其上再补安装与批处理工具。三者互补、无冲突。

---
**内容来源**：`raw/项目打包归档并写入本地AI WIKI知识库.md`
