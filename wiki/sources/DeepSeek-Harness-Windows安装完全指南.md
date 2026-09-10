# DeepSeek Harness Windows 安装完全指南

> 这页是一份原始资料的摘要：DeepSeek 官方 Agent 框架在 Windows 上的源码安装、磁盘布局与排错教程。

## 资料概述

2026 年 8 月 13 日 DeepSeek 开源官方 Agent 框架 [[DeepSeek-Harness]]（命令行工具 `dsh`，核心理念"Everything is a Plugin"）。本文档为 Windows 10/11 用户提供从零安装到可用的完整流程，涵盖磁盘占用控制（安装区域 1GB+ 的数据分布）与 5 个官方踩坑的完整排查。

## 核心内容

### 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| Node.js | ^22.19.0 或 ≥24.0.0 | 硬性要求，低版本会被 engines 字段直拒 |
| pnpm | 11.7.0 | packageManager 字段锁定 |
| git | 较新版 | 无硬性版本要求 |

### 安装路线

- **A. npx 临时运行**：`npx @deepseek-ai/dsh web`，仅体验不保留环境
- **B. npm 全局安装**：`npm install -g @deepseek-ai/dsh`，日常使用
- **C. 源码安装**（本文重点）：开发者、需最新功能、研究插件体系；monorepo 含 238 个子包

### 磁盘布局关键点

| 数据类型 | 默认位置 | 大小 | 迁移方式 |
|----------|----------|------|----------|
| 项目依赖 | 安装目录/node_modules | ~1GB | 安装时即在此 |
| pnpm store | C:\Users\<用户>\AppData\Local\pnpm\store | 数百 MB | config.yaml 改 storeDir |
| 使用期数据 $DSH_HOME | C:\Users\<用户>\.dsh | 持续增长 | DSH_HOME 环境变量 |

**重要**：pnpm 11 重置配置系统，`.npmrc` 中 `store-dir` 完全失效，必须改用 `%LOCALAPPDATA%\pnpm\config\config.yaml` 配置 `storeDir`。

### 五个 Debug 场景

1. **pnpm 命令找不到** → 装完未重启终端，PATH 未刷新
2. **.npmrc 挪缓存无效** → pnpm 11 不读 `.npmrc` 的 store-dir，改 config.yaml
3. **bat 启动本中文乱码** → cmd 按 GBK 读 UTF-8 中文会拆命令行，改用纯英文注释
4. **GitHub 克隆超时** → raw.githubusercontent.com 国内连接受限，换 gitclone.com 等镜像
5. **启动需几分钟** → 冷启动加载 238 个 workspace 模式 + 初始化数据库 + 扫描插件，属正常

### 速查锚

- Web UI 地址：`http://127.0.0.1:3080`
- API Key 配置优先级：进程环境变量 > `$DSH_HOME\.credentials.yaml` > `<执行目录>\.env` > `$DSH_HOME\.env`
- 全局 shim：`dsh.cmd`（80 字节转发器）+ 用户 PATH
- 更新流程：`git pull → pnpm install → pnpm run build → pnpm dsh web`

---

**内容来源**：`raw/DeepSeek Harness 在 Windows 上的安装、磁盘布局与排错完全指南.md`
