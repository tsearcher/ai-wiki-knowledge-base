# DeepSeek Harness

> 这页讲一个工具：DeepSeek 官方开源的 Agent 框架，命令行工具为 `dsh`，核心理念是"Everything is a Plugin"。

## 它是什么

由深度求索（DeepSeek）于 2026 年 8 月 13 日正式开源的 Agent 框架。用户可通过插件体系扩展能力，本地运行 Web UI（默认 `http://127.0.0.1:3080`）并接入 DeepSeek、Anthropic、OpenAI 等模型端点。

当前阶段为 **developer preview**（开发者预览版），官方明确标注会有频发破坏性变更。

## 技术栈

- **运行时**：Node.js ^22.19.0 或 ≥24.0.0（硬性门槛）
- **包管理器**：pnpm 11.7.0（packageManager 字段锁定）
- **仓库结构**：pnpm monorepo，含 238 个子包/workspace
- **构建输出**：TypeScript 编译 + Web 前端打包

## 核心机制

### "Everything is a Plugin"

框架能力全部通过插件提供，插件以 profile 为单位管理依赖配置，存于 `$DSH_HOME/profiles/`。

### 磁盘布局

| 内容 | 位置 | 说明 |
|------|------|------|
| 源码与依赖 | 安装目录 | ~1GB，node_modules 含 238 子包 |
| 构建产物 | 项目内 lib/、dist/ | 每次 build 覆盖 |
| pnpm store | 默认 C 盘，可迁 | 内容寻址缓存，只增不减 |
| 运行数据 $DSH_HOME | 默认 `~/.dsh`，可迁 | 会话、插件、配置、附件 |

### 配置优先级（API Key）

进程环境变量 `DEEPSEEK_API_KEY`（最高，只读）> `$DSH_HOME\.credentials.yaml`（Web UI 管理）> `<执行目录>\.env` > `$DSH_HOME\.env`

## 与 DeepSeek-R1 的关系

- [[DeepSeek-R1]]：DeepSeek 开发的对话模型（文本 AI 助手）
- **DeepSeek Harness**：基于插件的 Agent 框架，可接入 R1 等模型作为后端

两者同属 DeepSeek 生态，但定位不同：R1 是"大脑"，Harness 是"骨架+手脚"。

## 相关

- [[DeepSeek-Harness-Windows安装完全指南]]：Windows 源码安装、磁盘控制与 5 个 Debug 场景详解
- [[DeepSeek-R1]]：DeepSeek 对话模型
- [[HLS流媒体协议]]：Harness 可处理的流媒体协议之一
- [[A2DP蓝牙音频协议]]：蓝牙音频传输协议

---

**内容来源**：`raw/DeepSeek Harness 在 Windows 上的安装、磁盘布局与排错完全指南.md`
