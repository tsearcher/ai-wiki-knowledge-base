# 本地 AI Wiki 知识库

> 这页讲一个概念：在本地用 Markdown 构建的结构化软件版本归档知识库，打包后自动录入版本信息，可供本地大模型 RAG 检索。

## 概念说明

本地 AI Wiki 指一套存放于本地的结构化 Markdown 知识库，用于记录软件版本打包归档信息。它由 [[project-packager-Skill]] 的 Wiki 管理脚本实现自动维护，打包动作完成后自动沉淀为知识库条目，无需手动记录，并可直接对接本地大模型 RAG 检索。

## 目录结构

```
wiki-root/
├── index.md          # 总索引页（自动生成，软件清单与最新版本）
├── software/         # 软件条目目录，每软件一个 .md
│   └── <英文名>.md
└── assets/           # 附件目录（可选）
```

## 页面与条目规范

- 软件页用 YAML frontmatter 存结构化元数据：`software_name`、`english_name`、`category`、`latest_version`、`last_pack_date`、`archive_root`、`maintainer` 等。
- 版本历史按时间倒序，标题格式 `### 版本号 | 日期 | 类型标识`。
- 必填字段：打包日期、归档文件路径、文件大小、变更摘要；可选字段：环境依赖变更、回滚说明、风险提示、打包人。
- 重复版本：同一版本二次打包时追加备注说明，不删除原记录。

## RAG 优化建议

保留结构化 YAML 元数据、统一版本标题格式、变更摘要条目化、关键路径与版本号加粗，以提升检索权重与语义匹配。

## 相关

- [[语义化版本号]]：版本号采用 `vX.Y.Z` 格式。
- 由 [[project-packager-Skill]] 的 `wiki-manager-script.py` 实现 init / add-software / add-version-record / query / 重建索引。

---
**内容来源**：`raw/可直接导入的完整 Skill 文件包.md`、`raw/项目打包归档并写入本地AI WIKI知识库.md`、`raw/跨平台一键安装脚本和Windows 原生批处理打包工具.md`
