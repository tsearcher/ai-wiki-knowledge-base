# DeepSeek Harness 在 Windows 上的安装、磁盘布局与排错完全指南

## 一、这篇教程解决什么问题

**定位声明**：2026年8月13日，DeepSeek正式开源官方 Agent 框架 DeepSeek Harness （命令行工具为 dsh ，核心是"Everything is a Plugin"）。本教程记录在 Windows 10/11 上从零安装到可用的完整流程——包含磁盘占用控制（官方测试 1GB+ 的安装数据都跑到哪、持续使用产生的数据文件会不会卡 C 盘）和 5 个官方测试的完整排查。

**跳读指南**：如果你已经装好 Node.js 和 pnpm，直接跳到 三、安装步骤 。只想快速体验不想装完整环境，跳到 3.1 路线选择 。如果你最关心" C 盘会不会被搞垮 "，务必看 四、磁盘不缓存机制 ——不安装数据，持续使用生成的插件也会默认落在 C 盘。

**阅读前提**：  
- 有一台能联网的 Windows 10/11 电脑（本教程全部命令在 PowerShell 中执行）  
- 会打开终端、粘贴命令（不需要任何 Node.js 基础）  
- 能访问 GitHub 不 npm 源（国内网络下访问 GitHub 有替代方案，见 Debug #4 ）  

**读完能得到什么**：  
- 一个跑在本机 http://127.0.0.1:3080 的 DeepSeek Harness Web UI，配好 API Key 即可开工  
- 掌握安装区域 1GB 数据的生成，并让所有缓存跑在指定盘符  
- 一个开箱即用的 Windows 环境，以及 5 个真实报错的定位方法  

## 二、环境准备

### 2.1 依赖清单

| 组件 | 最佳版本 | 说明 |
|------|----------|------|
| Node.js | ^22.19.0 或 ≥24.0.0 | 硬性要求，来自项目 package.json 的 engines 字段，版本直拒安装 |
| pnpm | 11.7.0 | 项目 packageManager 字段锁定，版本不符可能导致依赖解析行为不一致 |
| git | 任意较新版 | 暂无硬性版本要求 |
| **Node.js 版本是硬门框**： ^22.19.0 || >=24.0.0 意味着 22.x 至少要 22.19，24 及以上任意版本。装 20.x 或 18.x 会在安装依赖时报 engines 错误。 |

### 2.2 逐条验证

```bash
node -v
git --version
```

**如果缺少某个组件**：  
- Node.js：前往 https://nodejs.org 下载 LTS（24.x）或 22.x 安装包，一路下一步即可；装完重启终端再验证  
- git：前往 https://git-scm.com/download/win 下载安装  
- pnpm 的安装放在 3.3 安装 pnpm ，因为有俩选择方式，并和磁盘布局有关。  

## 三、安装步骤

### 3.1 路线选择

| 路线 | 命令 | 适合 | 磁盘占用 |
|------|------|------|----------|
| A. npx 临时运行 | `npx @deepseek-ai/dsh web` | 只想体验一下，不保留环境 | 仅 npx 缓存（数百 MB） |
| B. npm 全局安装 | `npm install -g @deepseek-ai/dsh` | 日常使用、不想管源码 | 全局目录 |
| C. 源码安装 | 下文全流程 | 开发者、需要最新功能、想研究插件体系 | 安装区域约 1GB+ |

**本教程基于路线 C（源码安装）**。路线 A 和 B 不需要拉取私有仓库，也不适合持续插件开发和源码级调试；此外官方明确标注当前是 developer preview（开发者预览版），频发破坏性变更，只源码安装才方便 git pull 跟上更新。

### 3.2 拉取私有仓库

```bash
cd D:\Agents
git clone https://github.com/deepseek-ai/deepseek-harness.git DeepSeek-Harness
cd D:\Agents\DeepSeek-Harness
```

**预期输出（可选）**：  
```bash
Cloning into 'DeepSeek-Harness'...
remote: Enumerating objects: ...
Resolving deltas: 100% (...), done.
```

**安装目录思考**：  
D:\Agents 是本文选定的安装父目录，只是一个示例路径，读者可换成任意有空间的目录（如 D:\dev 、 E:\tools ）。三点说明：  
1️⃣ 不要放 C 盘——结合 四、磁盘不缓存机制 ，安装本体 1GB+ 且使用期还会持续增长；  
2️⃣ 持续教程所有路径引用（storeDir 配置、可移动本、速查锚）都基于 D:\Agents ，换成别目录要全局同步改换；  
3️⃣ DeepSeek-Harness 是 git clone 命令的第二个参数（目标目录名），同样可以自定义。  

默认分支名为 master（不是 main ），持续 git pull 时注意。  
国内网络拉取失败或卡顿时，见 Debug #4。

### 3.3 安装 pnpm

**方式一：npm 全局安装（推荐，最省事）**  
```bash
npm install -g pnpm@11.7.0
```
装完 重启终端 使 PATH 生效，验证：
```bash
pnpm -v
```

**方式二：corepack（Node.js 自带，版本随项目）**  
```bash
corepack --version
cd D:\Agents\DeepSeek-Harness
corepack use pnpm@11.7.0
corepack pnpm -v
```
两种方式二选一即可。全局方式工具本体约 18MB 装在系统目录；corepack 方式把 pnpm 本体放在 corepack 缓存目录（可用 COREPACK_HOME 环境变量改到项目内）。二者下载依赖用的 pnpm store 是同一份（见 四、磁盘不缓存机制 ）。

### 3.4 安装依赖

```bash
cd D:\Agents\DeepSeek-Harness
pnpm install
```

**预期输出（可选）**：  
```bash
native/landlock-run/packages/linux-arm64 | [WARN] Unsupported platform: wanted: {"cpu":["arm64"],"os":["linux"],"libc":["any"]} (current: {"os":"win32","cpu":"x64","libc":"unknown"})
native/landlock-run/packages/linux-x64   | [WARN] Unsupported platform: ...
Scope: all 238 workspace projects
...
Done in 1m 24s using pnpm v11.7.0
```

两个 [WARN] Unsupported platform 是 无伤告警 ：landlock-run 是 Linux 专用的沙箱组件（Landlock 是 Linux 内核安全机制），pnpm 检测到当前是 Windows 跳过它。Scope: all 238 workspace projects 也正常——这是一个 pnpm monorepo，一个仓库管理 238 个子包。

### 3.5 构建

```bash
pnpm run build
```
这一步编译 TypeScript 源码并打包 Web 前端资源。  
**必须执行**，否则 dsh web 会因找不到构建产物而启动失败。

### 3.6 启动验证

```bash
pnpm dsh web
```

**预期输出（可选）**：  
```bash
...
Web UI listening on http://127.0.0.1:3080
```
浏览器打开 http://127.0.0.1:3080 ，能看到 DeepSeek Harness 界面即安装成功。

**验证端口监听**：  
```bash
netstat -ano | findstr :3080
TCP    127.0.0.1:3080         0.0.0.0:0              LISTENING       35360
```
首次启动需要约 分钟级 是 正常现象（冷启动：加载 238 个 workspace 的模式、初始化数据库、扫描插件）。判断方法见 Debug #5。停止服务：在启动窗口按 Ctrl+C 或直接关窗口。

### 3.7 配置 API Key

官方推荐的配置位是 Web UI，也支持环境变量，三种方式按需选择：

**方式一：Web UI 填写（官方推荐）**  
打开 http://127.0.0.1:3080 → 设置 → 模型 → DeepSeek 模块输入 API Key（格式 sk-... ）→ 保存。  
Key 是 只读 的：保存页仅显示脱敏符号，不回显原文  
存储位置为 $DSH_HOME\.credentials.yaml （默认 C:\Users\<用户名>\.dsh\.credentials.yaml ），settings 里仅保留键引用

**方式二：环境变量**  
源码确认默认读取的环境变量名为 DEEPSEEK_API_KEY ：  
```bash
setx DEEPSEEK_API_KEY "sk-你的Key"
```
或仅当前终端临时生效：  
```bash
$env:DEEPSEEK_API_KEY = "sk-你的Key"
pnpm dsh web
```

**方式三：.env 文件**  
在 C:\Users\<用户名>\.dsh\.env 中写入：  
```bash
DEEPSEEK_API_KEY=sk-你的Key
```

**配置优先级**（源码中 credentials-local 的层级定义）：  
进程环境变量（最高，只读）  
> $DSH_HOME\.credentials.yaml（Web UI 管理的存储）  
> <可执行目录>\.env  
> $DSH_HOME\.env  
这个 Key 是 DeepSeek 开放平台 的 API Key，不是 DeepSeek Harness 自身签发的。Harness 也支持接入 Anthropic、OpenAI 及任意 OpenAI 兼容端点（公司官网、自建服务），在"添加自定义提供商"中配。

### 3.8 让 dsh 命令全局可用（源码安装必读）

源码路径下，dsh 不是独立命令——它只是仓库内的 npm script，出了仓库目录 dsh 会报 "无法将"dsh"识别为 cmdlet..."。路线 B（npm 全局安装）会自动生成这一层入口，源码路线需要自己补一个 80 字节的转发器（shim）：

```powershell
Set-Content "D:\Agents\DeepSeek-Harness\dsh.cmd" -Value "@echo off`nnode "" ""%~dp0apps\cli\lib\bin.js"" "" %*" -Encoding ascii
& "D:\Agents\DeepSeek-Harness\dsh.cmd" --version
```

然后把 D:\Agents\DeepSeek-Harness 加入 用户 PATH （设置 → 系统 → 高级系统设置 → 环境变量 → 用户变量 Path → 新建 → 粘贴路径 → 确定）， 新开一个终端 即可在任意目录使用：

```bash
dsh --version
dsh web
dsh plugin --profile install add <插件包名>
```

几点说明：  
- dsh.cmd 就是 npm 全局安装时自动生成的同类转发器（cmd 里两行：@echo off + node "入口" %* ），80 字节，无内存/磁盘负载；  
- %~dp0 展开为"这个 shim 所在的目录"（即 checkout 根），仓库目录将搬迁也不会失效；  
- %* 把 dsh 后的所有参数原样传给入口；  
- 不想改 PATH 的话，也可以在 $PROFILE 里加一行函数：  
```powershell
function dsh { node "D:\Agents\DeepSeek-Harness\apps\cli\lib\bin.js" @args }
```
仅 PowerShell 可用；  
- 为什么不能把 checkout 目录直接放进 PATH 就让 dsh 生效：Windows 按 PATH+PATHEXT 找 dsh.exe/.cmd/.bat ，而仓库入口含 bin.js ，找不到；必须有一个含 dsh.cmd 的转发器。将改用路线 B，删除这个文件即可生效。

## 四、磁盘不缓存机制

源码安装完成后，安装区域数据总量约 1GB+ 。这一节解释这些数据跑到哪，以及两个关键问题： pnpm 11 的默认缓存位置在 C 盘 ；更随心的是， 持续使用生成的数据（会话、插件、配置）默认也全在 C 盘 ——这才是会随使用持续膨胀的大头。

### 4.1 数据构成全景

| 内容 | 位置 | 大小级别 | 增长性 |
|------|------|----------|--------|
| 项目依赖 node_modules | D:\Agents\DeepSeek-Harness\node_modules | ~1GB（238 个子包） | 安装时一次性 |
| pnpm store（内容镜像缓存） | 默认 C:\Users\<用户名>\AppData\Local\pnpm\store | 数百 MB | 随安装缓存增长 |
| pnpm 工具本体 | 全局目录或 corepack 缓存 | ~18MB | 固定 |
| 构建产物 | 项目内 lib/ 、Web 前端 dist | 数十 MB | 每次 build 覆盖 |
| 使用期数据（$DSH_HOME） | 默认 C:\Users\<用户名>\.dsh | 初始几 MB，随使用持续增长 | 会话、插件、索引越多越大 |
| node_modules 本体必须在项目目录（D 盘）；两类数据会"悄悄跑 C 盘"： pnpm store （默认在 %LOCALAPPDATA% ，且不会自动清理，只增不减）和 $DSH_HOME 使用期数据 （默认 ~\.dsh ，会话和插件直接往里写）。

### 4.2 使用期数据：$DSH_HOME 才是持续膨胀的头目

服务启动以来，Harness 会把所有运行数据写进 $DSH_HOME （默认 C:\Users\<用户名>\.dsh ）。测试使用几小时的目录结构：

```
C:\Users\<用户名>\.dsh\
├── profiles\            # 插件 profile（每个 profile 的依赖配置）
├── sessions\            # 会话记录（跑一个任务点一下）
├── storages\            # 持久化存储
├── attachments\v1\      # 会话附件（截屏、文件，源码确认的存储根）
├── settings.yaml        # 全局设置
├── .credentials.yaml    # API Key 存储（Web UI 生成）
└── .anonymous-user-id   # 匿名用户标识
```

移动方法（源码 util/home-paths 的 resolveDshHome 确认）：优先级为 显式配置 > 环境变量 DSH_HOME > 默认 ~\.dsh ，且支持 ~ 展开。用环境变量把整个目录指向 D 盘：

```bash
setx DSH_HOME "D:\Agents\.dsh"
```

移动已有数据的完整流程：

```bash
Move-Item "C:\Users\<用户名>\.dsh" "D:\Agents\.dsh"
```

注意两点：① 凭据 .credentials.yaml 也在 $DSH_HOME 里，随目录一起移动，不用重新配置 Key；② DSH_HOME 是 运行时环境变量 ， setx 后必须重启终端（或重启启动本窗口）才生效。

### 4.3 pnpm 11 的配置重置： .npmrc 里的 store-dir 失效了

这是本次安装踩到的最随心的坑。教程会声称"在 C:\Users\<用户名>\.npmrc 写一行 store-dir=D:\xxx 就能把缓存挪走"—— 在 pnpm 11 上这么做完全无效 ：

```powershell
PS> pnpm store path
D:\.pnpm-store\v11        ← 根本没读你的 .npmrc
PS> pnpm config list
{ "@jsr:registry": ..., "registry": ..., "userAgent": ... }   ← store-dir 配置空缺
```

根因：pnpm 11 重置了配置系统， .npmrc 现在 仅负责 registry 和认证类设置 ，其余配置（含 store-dir ）一概忽略。全文排查过流程见 Debug #2。

### 4.4 正确的 storeDir 配置方式

pnpm 11 的全局配置正确位置是 config.yaml ：

```powershell
Set-Content "$env:LOCALAPPDATA\pnpm\config\config.yaml" "storeDir: D:/Agents/.pnpm-store"
```

注意两点：  
- 这是 YAML 格式 ，值里用正斜杠 D:/Agents/.pnpm-store 最稳妥（在 YAML 中是转义符）  
- 这是 用户级全局配置 ，对所有 pnpm 项目生效；也可写进单个项目的 pnpm-workspace.yaml （字段名 storeDir ），仅对该项目生效  

验证：

```bash
pnpm store path
D:\Agents\.pnpm-store
```

如果你在配置 storeDir 之前已经执行过 pnpm install ，旧 store 已落在默认位置。两种处理：① 直接删除旧 store 目录（纯净缓存，删了安全，代价是下次安装重下依赖）；② 把旧 store 整个 Move-Item 到新位置复用（store 是内容镜像结构，移动后 pnpm 能继续用）。

### 4.5 store 的日常清理

store 没有自动清理机制 ，只增不减。手动清理：

```bash
pnpm store prune
```

prune 清不出太多空间——只要项目还装着依赖，大部分缓存就是"活跃"的。想彻底瘦身只能删除不用的项目，或清空整个 store（代价是重下依赖）。

不要用 360、CCleaner 等通用清理软件胡乱 store ：它们不识别这个目录，也不会按 pnpm 的引用关系清理。

### 4.6 corepack 还是全局 pnpm？

对比维度 | 全局 pnpm（npm install -g） | corepack
---|---|---
安装 | 一条命令 | 需要 corepack 可用（Node 22+ 自带）
版本管理 | 全局一版，换版本需手动卸载 | 版本随项目 packageManager 字段，自动切换
磁盘占用 | 系统全局目录 ~18MB | corepack 缓存目录（可用 COREPACK_HOME 指到任意盘）
适用 | 单项目、图省事 | 多项目多版本场景才体现价值

结论：只有单台机器装几个项目的场景， 全局 pnpm + 4.4 的 storeDir 配置 就是最简方案；corepack 的价值在多项目多版本场景才体现。

## 五、Windows 一键启动本

把下面的本存为 D:\Agents\__可动DeepSeek-Harness.bat ，双击即可启动（自动切换目录 → 检查 pnpm → 缺依赖自动装 → 延迟 5 秒打开浏览器）：

```bat
@echo off
chcp 65001 >nul
title DeepSeek Harness

rem Switch to project dir (DeepSeek-Harness next to this script)
cd /d "%~dp0DeepSeek-Harness"

echo ============================================
echo   DeepSeek Harness - Web UI Launcher
echo   URL: http://127.0.0.1:3080
echo ============================================
echo.

where pnpm >nul 2>&1
if errorlevel 1 (
    echo [ERROR] pnpm not found.
    echo         Install it first: npm install -g pnpm
    echo.
    pause
    exit /b 1
)

if not exist "node_modules" (
    echo [INFO] Dependencies missing, running pnpm install...
    call pnpm install
    if errorlevel 1 goto :fail
)

echo [OK] Starting service...
echo [INFO] Close this window or press Ctrl+C to stop
echo.

rem Auto-open browser after 5s (remove next line if unwanted)
start "" powershell -NoProfile -Command "Start-Sleep 5; Start-Process 'http://127.0.0.1:3080'"

call pnpm dsh web
if errorlevel 1 goto :fail
exit /b 0

:fail
echo.
echo [ERROR] Failed to start. If related to dependencies, try:
echo        pnpm install
echo        pnpm run build
echo.
pause
exit /b 1
```

这个本的注释和提示全是英文是有缘由的：bat 文件里放中文，cmd 会按系统 ANSI 代码页（中文系统是 GBK）解码文件字符，UTF-8 保存的中文会变乱码，乱码字符中混入 | 、 \ 等特殊字符还会把命令行拆开（官方测试报错 'ho.' 不是内部或外部命令 ）。UTF-8、GBK 两种编码都踩过坑，纯 ASCII 是唯一无坑方案。完整排查见 Debug #3。

## 六、Debug

### Debug #1 — 'pnpm' 不是内部或外部命令

**报错日志**：

```bash
pnpm -v
pnpm : 无法将"pnpm"识别为 cmdlet、函数、脚本文件或可执行程序的名称。请检查名称的拼写，包括路径，确保路径正确，然后再试一次。
+ CategoryInfo          : ObjectNotFound: (pnpm:String) [], CommandNotFoundException
+ FullyQualifiedErrorId : CommandNotFoundException
```

**根因**：pnpm 没有安装，或安装了但当前终端的 PATH 环境变量未更新。npm install -g 装完包，npm 的全局 bin 目录已加入 PATH，但 已打开的终端窗口不会自动更新 PATH ，必须重启。

**一目了然对比表**：

| 对比维度 | 修复前 | 修复后 |
|----------|--------|--------|
| pnpm -v CommandNotFoundException | 输出 11.7.0 |
| pnpm 命令位置 | 不存在 npm 全局目录（ %APPDATA%\npm ） | 当前终端能复用 |
| 修复方式 | 重启终端窗口才可用 | 代码修复： npm install -g pnpm@11.7.0 |
| 验证方式 | pnpm -v |

### Debug #2 — .npmrc 里写 store-dir 完全无效，缓存仍在 C 盘

**报错日志**：

```bash
PS> pnpm store path
D:\.pnpm-store\v11

PS> pnpm config get store-dir
undefined （ C:\Users\<用户名>\.npmrc 中明明写着 store-dir=D:\Agents\.pnpm-store ，pnpm 视而不见；而 npm 读到了并报 Unknown user config "store-dir" 警告）
```

**根因**：pnpm 11 重置了配置系统—— .npmrc 仅"全局配置入口"限级为"仅负责 registry/auth 的入口"，其余所有配置（含 store-dir ）必须写在 pnpm-workspace.yaml （项目级）或 config.yaml （用户级）。旧教程、旧帖、AI 生成的旧答案都会让你改 .npmrc ，全部失效。

**一目了然对比表**：

| 对比维度 | pnpm 10 及之前 | pnpm 11 |
|----------|----------------|---------|
| .npmrc 的 store-dir 生效 | 被忽略 |
| 用户级全局配置文件 | ~/.npmrc | %LOCALAPPDATA%\pnpm\config\config.yaml |
| 项目级配置文件 | .npmrc | pnpm-workspace.yaml |
| pnpm config list 中 store-dir 显示 | 不显示（配置未读入） |
| 代码修复 | Set-Content "$env:LOCALAPPDATA\pnpm\config\config.yaml" "storeDir: D:/Agents/.pnpm-store" Set-Content "$env:USERPROFILE\.npmrc" "" |
| 验证方式 | PS> pnpm store path D:\Agents\.pnpm-store |

### Debug #3 — 可动本中中文乱码，命令被拆开

**报错日志**（同可动本）：

```
'ho.' 不是内部或外部命令，也不是可执行的程序或批处理文件。
'pm' 不是内部或外部命令，也不是可执行的程序或批处理文件。
'…' 不是内部或外部命令，也不是可执行的程序或批处理文件。
'rlevel' 不是内部或外部命令，也不是可执行的程序或批处理文件。
（换成 GBK 编码保存后仍出现 '~dp0DeepSeek-Harness"' 不是内部或外部命令 等错误）
```

**根因**：两层问题。第一层：cmd 按系统 ANSI 代码页（中文系统为 GBK）读取 bat 文件字符，UTF-8 保存的中文全变乱码；乱码字符序列中恰好包含 | 、 \ 等 ASCII 特殊字符，被 cmd 当作管道符等语法符号，把一行命令拆成多段。第二层：即使转成 GBK，cmd 批处理解析器对多字节字符的解析仍不可靠（尤其在带引号、%~dp0 变量展开、括号括住的场合）。

**结论**：bat 文件中的中文本身就不安全，编码无关。**代码修复**：把可动本中的全部注释和 echo 提示改为英文（完整可动本见 五、Windows 一键启动本 ）。

**验证方式**：同可动本，终端正常显示 [OK] Starting service... ，浏览器 5 秒自动打开 http://127.0.0.1:3080。

### Debug #4 — 克隆仓库 / raw.githubusercontent.com 运行超时

**报错日志**：

```bash
curl -s https://raw.githubusercontent.com/deepseek-ai/deepseek-harness/master/README.md
curl: (28) Operation timed out after 20001 milliseconds
```

或

```bash
git clone 长时间卡在 Receiving objects 无进展。
```

**根因**：raw.githubusercontent.com GitHub 主站在部分国内网络下 DNS 污染/运行被重置，墙网可通性问题，与工具本身无关。但注意： api.github.com 等 GitHub 服务域名的可达性通常 raw 域名不同，往往 raw 被挡 API 通。

**一目了然对比表**：

| 对比维度 | 直连 raw.githubusercontent.com | GitHub API（api.github.com） |
|----------|----------------------------------|------------------------------|
| 镜像/加速 | 国内直连成功率低（超时/重置） | 中高 | 高 |
| 使用途 | 拉取仓库元文件 | 获取仓库元数据、README、文件内容 |
| git clone 加速 | 需要认证 | 无认证（有速限） | 无认证 |
| 代码修复 | git clone https://gitclone.com/github.com/deepseek-ai/deepseek-harness.git DeepSeek-Harness git remote set-url origin https://gitclone.com/github.com/deepseek-ai/deepseek-harness.git git pull |
| 也可先通过 GitHub API 拉取 README 判断仓库结构： curl -H "Accept: application/vnd.github.raw" https://api.github.com/repos/deepseek-ai/deepseek-harness/readme 。镜像域名（gitclone.com、ghproxy 等）可用性随时间变化，失效时换一个即可。 |

**验证方式**： Cloning into 'DeepSeek-Harness'...  
remote: Enumerating objects: 58321, done.

### Debug #5 — 启动需要几分钟，是不是卡死了？

**报错日志**（启动本后台浏览器打不开）：

```bash
[OK] Starting service...
（窗口挂起约 30 秒无输出，浏览器提示"无法访问此网站"）
```

**根因**： dsh web 的冷启动需要完成三重加载：加载 238 个 workspace 的依赖模式（monorepo 的模式图通常很大）、初始化本地数据库索引、扫描并加载插件。首次启动（或每次开机后的第一次）全部要跑一遍，约几分钟；之后系统文件缓存生效，热启动会明显变快。这不是卡死，是框架规模决定的固定成本。

**一目了然对比表**：

| 对比维度 | 冷启动 | 热启动 |
|----------|--------|--------|
| 耗时 | ~30 秒 | 数秒 |
| 无响应 | 等待即可 | 等待即可 |
| 看启动本日志，对照 Debug #2 等 | 代码修复：无需修复。验证方法——先关服务端窗口，重新启动一次对比耗时： netstat -ano | findstr :3080 |

**验证方式**：第二次启动在数秒内 LISTENING ，浏览器正常打开界面。

## 七、日常维护

### 7.1 可停命令

```bash
cd D:\Agents\DeepSeek-Harness
pnpm dsh web
```

### 7.2 更新不重建

```bash
cd D:\Agents\DeepSeek-Harness
git pull
pnpm install
pnpm run build
pnpm dsh web
```

官方明确标注 developer preview 阶段 会有破坏性变更，每次 git pull 都要跑一遍"install → build → 启动"最稳妥；生产使用建议固定到某个 commit。

### 7.3 store 清理

```bash
pnpm store path
pnpm store prune
```

### 7.4 日志无诊断位置

| 内容 | 位置 |
|------|------|
| API Key 存储 | C:\Users\<用户名>\.dsh\.credentials.yaml（只写存储，不存明文） |
| Harness 主目录 | C:\Users\<用户名>\.dsh\（profiles、settings、.env 等） |
| pnpm store | 按 pnpm store path 输出 |
| 启动日志 | 启动本 stdout（无独立日志文件时以此为准） |

## 八、速查锚

### 8.1 文件路径汇总

| 文件/目录 | 经对路径 |
|----------|----------|
| 项目根目录 | D:\Agents\DeepSeek-Harness |
| pnpm store（自定义） | D:\Agents\.pnpm-store |
| pnpm 11 全局配置 | C:\Users\<用户名>\AppData\Local\pnpm\config\config.yaml |
| Harness 主目录（$DSH_HOME，默认） | C:\Users\<用户名>\.dsh（可用 DSH_HOME 环境变量移动到 D 盘，见 4.2） |
| 凭据存储 | C:\Users\<用户名>\.dsh\.credentials.yaml |
| 启动本 | D:\Agents\__可动DeepSeek-Harness.bat |
| dsh 全局入口（shim） | D:\Agents\DeepSeek-Harness\dsh.cmd（配合用户 PATH，见 3.8） |

### 8.2 版本/配置字段

| 字段 | 值 |
|------|----|
| Node.js 版本要求 | ^22.19.0 || >=24.0.0 |
| pnpm 版本 | 11.7.0 |
| storeDir（YAML） | storeDir: D:/Agents/.pnpm-store |
| Harness 主目录环境变量 | DSH_HOME（如 D:\Agents\.dsh） |
| 源码 util/home-paths 解析，支持 ~ 展开 |
| API Key