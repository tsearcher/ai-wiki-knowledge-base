# ESP32-WROVER-IE 网络音频转发蓝牙固件

## 软件说明书

**固件版本**：v1.4.1  
**发布日期**：2026-08-23  
**软件作者**：陈志明（电话: 13654132703，微信: tsearcher）  
**适用硬件**：ESP32-WROVER-IE（4MB Flash + 8MB PSRAM）

---

## 一、系统概述

本固件将 ESP32-WROVER-IE 变为一台**网络电台转发器**：通过 WiFi 接收互联网 MP3 音频流，实时解码后经蓝牙 A2DP 协议转发到蓝牙耳机或音箱播放。

### 核心功能

- ✅ 332 个预设电台（蜻蜓FM 70 + 音乐 65 + 喜马拉雅 64 + 省级 120 + 央广 2 + 国广 5 + 国际 6）
- ✅ 串口命令控制（播放/切台/音量/暂停/存储/测试等命令）
- ✅ **CLI 客户端（v1.4.1）**：Python CLI 工具（esp32_cli.py），支持交互/单命令/JSON/监控四种模式
- ✅ **GUI 客户端（v1.4.1）**：PyQt5 图形界面（main.py），串口选择/状态监控/播放控制
- ✅ **定点 Q16 重采样（v1.4.1）**：替代浮点，减少量化噪声 + 提速
- ✅ **IIR 抗混叠低通滤波（v1.4.1）**：DC 增益=1.0，减少上采样镜像
- ✅ **段边界丢帧补偿（v1.4.1）**：ConsumeLastGood 渐弱衰减，避免静音
- ✅ **48000Hz 直发（v1.4.1）**：不重采样，无音质损失
- ✅ **NET ringbuf 水位监控（v1.4.1）**：低于 10% 让出 CPU 给 fetchTask
- ✅ **WiFi 重连限流（v1.4.1）**：10s 间隔，去掉 delay(2000) 阻塞
- ✅ **TsDemux ADTS 帧完整性检查（v1.4.1）**：减少段边界 -15 错误
- ✅ **TsDemux 段切换不 reset（v1.4.1）**：保留 PID，减少段间空窗
- ✅ **playlist 刷新自适应（v1.4.1）**：targetDur≤3 时刷新 1s
- ✅ **verbose 命令（v1.4.1）**：事件日志开关，NVS 持久化
- ✅ **status 增强（v1.4.1）**：新增解码类型/采样率/蓝牙设备名/事件日志状态
- ✅ **play 命令支持 URL 参数（v1.4.0）**：直接播放自定义 URL 音频流
- ✅ **TsDemux 手写解复用（v1.4.0）**：~120 行 PAT/PMT/PES 解复用 → ADTS 提取，支持 CNR/CRI TS 容器 HLS 流
- ✅ **AAC 解码支持（v1.4.0）**：取代纯 MP3，兼容喜马拉雅 HLS AAC 及国际 AAC 流
- ✅ **AVRCP 蓝牙按键控制（v1.1.0）**：耳机/音箱/车机的媒体键（上一曲/下一曲/播放/暂停/停止）
- ✅ **蓝牙记忆直连（v1.1.0）**：首次配对后记住设备，开机自动回连，无需再进配对模式
- ✅ **蓝牙连接退避（v1.4.0）**：3s/5s/10s/20s/30s 指数退避，连续失败切台
- ✅ **断流重连加强 + TWDT 看门狗（v1.1.0）**：指数退避重连、连续失败切台、任务卡死 15s 触发重启
- ✅ **音量修复（v1.1.0）**：修复 v1.0.0 起 vol 命令无效的 bug（根因：ConsumeSample 未调用 Amplify）
- ✅ **串口日志精简（v1.1.2）**：删除冗余诊断提示（[heap] 等），仅保留必要信息
- ✅ **A2DP 熔断机制（v1.2.0）**：连续连接失败 5 次停止自动重连，避免死循环 page 导致 heap 耗尽
- ✅ **HTTPS 诊断（v1.4.0）**：setHandshakeTimeout 15s + TCP/TLS 层诊断；支持 https://（`WiFiClientSecure` + `setInsecure()` 跳过证书验证，端口 443）
- ✅ **HTTP/1.0（v1.4.0）**：强制使用 HTTP/1.0，避免 chunked encoding 污染
- ✅ **物理按键（v1.2.0）**：GPIO13=next, GPIO14=prev, GPIO15=clear(长按3s防误触)
- ✅ **License 授权模块（v1.2.0）**：IP 保护第一阶段，ECDSA-P256 签名 + eFuse MAC 绑定，播放闸门单点管控（详见 License_授权激活说明书.md）
- ✅ **resolveUrl 双斜杠修复（v1.4.0）**
- ✅ **processCommand 跳前导空白/Tab（v1.4.0）**
- ✅ **decoder->loop() 超时 12s + false 宽限期（v1.4.0）**
- ✅ 自定义电台存储（最多 50 个，NVS 持久化，数组放 PSRAM）
- ✅ 切台 5 分钟后自动存储当前电台和音量
- ✅ 开机自动恢复上次播放状态
- ✅ WiFi 凭证可运行时修改
- ✅ 电台可访问性测试

### 支持的音频格式

| 格式 | 支持 | 说明 |
|------|------|------|
| HTTP MP3 | ✅ | 蜻蜓 FM 等在线 MP3 流 |
| HTTP AAC | ✅ | 喜马拉雅 HLS AAC、国际 AAC 流（v1.4.0） |
| HTTP m3u8/HLS | ✅ | CNR/CRI TS 容器 HLS 流（v1.4.0，TsDemux 解复用） |
| HTTPS | ✅ | 支持（v1.4.0：`WiFiClientSecure` + `setInsecure()` 跳过证书验证，端口 443，握手超时 15s） |

---

## 二、硬件架构

### 2.1 主控芯片

| 参数 | 规格 |
|------|------|
| 芯片 | ESP32-WROVER-IE |
| CPU | 双核 Xtensa LX6 @ 240MHz |
| Flash | 4MB |
| PSRAM | 8MB |
| WiFi | 802.11 b/g/n |
| 蓝牙 | BT 4.2 BR/EDR + BLE（本固件仅用 BR/EDR Classic） |
| 天线 | IPEX 外置天线 |

### 2.2 外围设备

- **蓝牙耳机/音箱**：支持 A2DP Sink 协议的设备
- **串口**：USB-TTL（115200bps），用于命令交互和日志输出

### 2.3 引脚使用

- **GPIO13**：next 按键（内部 pullup，接 GND，去抖 50ms）
- **GPIO14**：prev 按键（内部 pullup，接 GND，去抖 50ms）
- **GPIO15**：clear 按键（内部 pullup，接 GND，去抖 50ms，长按 3s 触发清配对）
- **UART0（GPIO1/3）**：串口通信（命令交互 + 日志）
- 内置 WiFi/蓝牙射频

---

## 三、软件架构

### 3.1 双核任务分配

```
┌─────────────────────────────────────────────────┐
│                  ESP32 双核                      │
├──────────────────────┬──────────────────────────┤
│      Core 0          │       Core 1              │
├──────────────────────┼──────────────────────────┤
│ A2DP 蓝牙协议栈       │ audioTask (优先级 10)     │
│ (Bluedroid, 系统管理) │  ├─ MP3 解码循环          │
│                      │  ├─ 命令队列处理           │
│ loop() (优先级 1)     │  └─ TWDT 喂狗             │
│  ├─ 串口命令解析      │                          │
│  ├─ WiFi 重连         │ HTTPFetch (优先级 1)      │
│  ├─ 自动存储检查      │  └─ 异步 HTTP 数据读取    │
│  └─ 周期状态打印      │                          │
└──────────────────────┴──────────────────────────┘
```

### 3.2 异步管线数据流

```
WiFi (HTTP/HTTPS MP3/AAC 流)
    │
    ▼
┌─────────────────────────────────────────┐
│ AsyncHTTPSource                         │
│  ├─ 后台 fetchTask 异步读取             │
│  └─ 384KB 环形缓冲 (NET_BUF_SIZE)       │
└─────────────────────────────────────────┘
    │ read() 不阻塞
    ▼
┌─────────────────────────────────────────┐
│ AudioGeneratorMP3/AAC (ESP8266Audio)    │
│  ├─ MP3 30KB / AAC 128KB 预分配 (PSRAM) │
│  └─ ConsumeSample() 写入 PCM 缓冲       │
│     ★ 调用 Amplify() 应用音量           │
│     ★ 调用 MakeSampleStereo16() 转立体声│
└─────────────────────────────────────────┘
    │ xRingbufferSend 非阻塞
    ▼
┌─────────────────────────────────────────┐
│ PCM 环形缓冲 128KB (PCM_BUF_SIZE, PSRAM)│
│  ≈ 1.45 秒立体声 @44.1kHz               │
└─────────────────────────────────────────┘
    │ xRingbufferReceiveUpTo
    ▼
┌─────────────────────────────────────────┐
│ A2DP 数据回调 → SBC 编码 → 蓝牙耳机     │
└─────────────────────────────────────────┘
```

### 3.3 关键设计决策

| 决策 | 原因 |
|------|------|
| 异步 HTTP 读取 | 网络 I/O 不阻塞 MP3 解码，避免卡顿 |
| 环形缓冲替代队列 | FreeRTOS ringbuf 更高效，支持字节流 |
| ConsumeSample 调 Amplify/MakeSampleStereo16 | ESP8266Audio 基类 SetGain 只存 gainF2P6，派生类必须自调 Amplify 才生效（v1.0.0 此处遗漏导致音量无效） |
| ConsumeSample 返回 false 背压 | ESP8266Audio 内置机制，缓冲满时停止解码 |
| A2DP/AVRCP 回调 0 超时 | 不阻塞蓝牙栈上下文，只入队命令 |
| 所有缓冲放 PSRAM | 内部 RAM 紧张（蓝牙栈占 20KB+） |
| BT Classic only | 释放 BLE 栈 10KB 内部 RAM |
| 蓝牙就绪后才解码 | 避免 MP3 全速解码丢样本导致快进 |
| startURL 期间退订 TWDT | client.connect 到慢服务器阻塞可达 ~30s（lwIP 默认），远超 TWDT 15s，退订避免误触发 |
| client.connect 传 5s 超时 | 限制单次连接阻塞，提升重连速度 |
| ringbuf 在内部 RAM | `xRingbufferCreate` 走内部 heap（诊断日志确认地址 `0x3fffxxxx`），NET 384KB + PCM 128KB = 512KB 实测可用（内部 RAM heap ~412KB，剩 ~28KB） |
| 重采样 32k→44.1k | A2DP SBC 协商 44.1k（Bluedroid 协商时按 Sink 能力，48k 流自动协商 48k 直发无损）；32k SBC 耳机不支持，必须升采样 |
| 起播预缓冲 32KB | `open()` 等 NET ringbuf 攒到 32KB 再放行（3s 超时），避免起播 read 立即返回 0 误判流结束反复重连 |
| 重采样背压 | ConsumeSample 重采样时 send 失败返回 false 停解码，避免 ESP8266Audio 全速清空 NET ringbuf |

---

## 四、重要参数设定

### 4.1 缓冲参数

| 参数 | 值 | 说明 |
|------|-----|------|
| `NET_BUF_SIZE` | 384KB | 网络环形缓冲（64kbps 约 48 秒，抗弱网滴灌） |
| `PCM_BUF_SIZE` | 128KB | PCM 环形缓冲（约 1.36s@48k / 1.45s@44.1k，吸收 A2DP 消费抖动减少跳帧） |
| `g_mp3PreallocSize` | 30KB | MP3 解码器预分配（PSRAM） |
| `g_aacPreallocSize` | 128KB | AAC 解码器预分配（PSRAM） |
| 起播预缓冲 | 32KB | `open()` 等 NET ringbuf 攒到 32KB 再放行（3s 超时兜底），避免起播 read 立即返回 0 误判流结束 |
| ringbuf 位置 | 内部 RAM | `xRingbufferCreate` 走内部 RAM（诊断日志打印地址 `0x3fffxxxx` 确认），NET 384KB + PCM 128KB = 512KB 实测可用（heap 剩 ~28KB） |

### 4.2 可靠性参数（v1.1.0）

| 参数 | 值 | 说明 |
|------|-----|------|
| `WDT_TIMEOUT_MS` | 15000 | TWDT 超时 15s，audioTask 卡死触发 panic 重启 |
| `STALL_TIMEOUT_MS` | 30000 | playing 标志为真但 mp3 异常空 30s → 重启播放 |
| `RECONNECT_MAX_FAIL` | 3 | 连续重连失败 3 次后切到下一台 |
| `reconnectBackoff[]` | 3/5/10/20/30s | 指数退避重连表 |
| `BT_AUTO_RECONNECT_RETRIES` | 8 | 蓝牙记忆直连重试次数，失败后回退扫描 |
| HTTP connect 超时 | 5000ms | `client.connect(host, port, 5000)` 限制单次阻塞 |
| startURL TWDT 退订 | 是 | startURL 进入前 `esp_task_wdt_delete`，退出后 `esp_task_wdt_add` |
| 重采样策略 | 44.1k/48k 直发 | 32k 升采样到 44.1k（SBC 32k 耳机不支持）；SetRate 不设基类 hertz 避免 A2DP 协商错采样率崩溃 |
| 重采样算法 | 线性插值+背压 | int32 计算+饱和±32767+guard=8 限次；send 失败返回 false 停解码（避免全速清空 NET ringbuf 致流结束） |

### 4.3 存储参数

| 参数 | 值 | 说明 |
|------|-----|------|
| `MAX_CUSTOM_STATIONS` | 50 | 自定义电台最大数量（数组放 PSRAM） |
| `AUTO_SAVE_DELAY_MS` | 300000 (5分钟) | 切台后自动存储延迟 |
| `URL_MAX_LEN` | 256 | URL 最大长度 |
| `NAME_MAX_LEN` | 40 | 电台名最大长度 |
| `CAT_MAX_LEN` | 16 | 分类名最大长度 |

### 4.4 蓝牙参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 蓝牙模式 | `ESP_BT_MODE_CLASSIC_BT` | 仅 Classic，释放 BLE |
| IO Capability | `ESP_BT_IO_CAP_NONE` | Just Works 配对 |
| SSP | 启用 | 安全简单配对 |
| 目标设备过滤 | `BT_TARGET_NAME` | secrets.h 配置，nullptr=接受所有 |
| 记忆直连 | `set_auto_reconnect(true, 8)` | 上次设备 MAC 存库 NVS(key=src_bda)，失败 8 次回退扫描 |
| AVRCP 按键 | `set_avrc_passthru_command_callback` | 上下曲/播放/暂停/停止/音量± → 切台/暂停/音量 |
| clear 清记忆 | `forgetLastPeer()` | NVS 直删 connected_bda/src_bda + set_auto_reconnect(false)（库 reset_last_connection 是 protected） |
| cmdOut | Serial | 命令回复输出到 USB 串口（v1.4.0 删除 SPP，改为 Serial 单输出） |

### 4.5 WiFi 参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 模式 | STA | 仅连接，不 AP |
| TX 功率 | 19.5dBm | 最大功率 |
| 省电模式 | 关闭 | `WiFi.setSleep(false)` 音频实时性 |
| 连接超时 | 30 秒 | 超时后继续启动 |

### 4.6 系统参数

| 参数 | 值 | 说明 |
|------|-----|------|
| CPU 频率 | 240MHz | 超频提升解码性能 |
| 串口波特率 | 115200 | 命令交互和日志 |
| ESP-IDF 日志级别 | WARN | 减少 GAP 事件刷屏 |
| audioTask 栈大小 | 6144 | 音频解码任务栈（Core 1，优先级 10） |
| audioTask 优先级 | 10 | 高于 loop(1) 和 HTTPFetch(1) |
| TWDT idle_core_mask | 0 | 不监控 idle，避免 CPU1 空闲误触发 |

### 4.7 Flash 分区表

| 分区 | 大小 | 偏移 | 说明 |
|------|------|------|------|
| bootloader | 32KB | 0x0000 | 系统自动 |
| partition_table | 4KB | 0x8000 | 系统自动 |
| nvs | 20KB | 0x9000 | WiFi/电台/音量 + 蓝牙记忆地址存储 |
| otadata | 8KB | 0xE000 | OTA 数据（保留未用，必须 0x2000） |
| app0 | 3MB | 0x10000 | 主应用（固件约 1.8MB） |
| spiffs | 960KB | 0x310000 | 文件系统（预留） |

---

## 五、用户使用说明

### 5.1 首次使用

#### 步骤 1：配置 WiFi

编辑 `secrets.h`，修改 WiFi 凭证：

```cpp
constexpr const char* WIFI_SSID     = "你的WiFi名";
constexpr const char* WIFI_PASSWORD = "你的WiFi密码";
```

#### 步骤 2：Arduino IDE 配置

| 菜单选项 | 设置值 |
|----------|--------|
| Board | ESP32 Wrover |
| Flash Size | 4MB |
| Partition Scheme | Default 4MB with spiffs |
| PSRAM | Enabled |
| CPU Frequency | 240MHz (WiFi/BT) |
| Upload Speed | 921600 |

#### 步骤 3：安装库

- ESP8266Audio (Earle Philhower) — MP3 解码
- ESP32-A2DP (pschatzmann) — 蓝牙 A2DP Source（本地 1.8.11 定制版）

#### 步骤 4：编译烧录

编译并烧录固件。**升级固件时建议先擦除 NVS**（清除旧版本遗留的蓝牙记忆地址，避免直连无效旧设备）：

```
工具 → Erase Flash → All
```

#### 步骤 5：连接蓝牙耳机

1. 上电后串口会显示启动信息
2. 首次：固件扫描蓝牙设备，将耳机置于配对模式，自动连接（60 秒超时）
3. 之后开机：固件自动回连上次设备（无需配对模式）
4. 连接成功后自动播放默认电台（北京交通广播 FM103.9，序号 0）

### 5.2 串口命令

通过串口终端（115200bps）输入命令控制：

#### 播放控制

| 命令 | 格式 | 说明 |
|------|------|------|
| `play` | `play [序号]` | 播放指定序号电台 |
| `next` | `next` | 播放下一个电台 |
| `prev` | `prev` | 播放前一个电台 |
| `pause` | `pause` | 播放/暂停切换（v1.1.0 新增，同耳机 AVRCP 键） |
| `stop` | `stop` | 停止播放 |
| `vol` | `vol [0-100]` | 设置音量（0-100） |

#### 电台管理

| 命令 | 格式 | 说明 |
|------|------|------|
| `list` | `list [分类]` | 显示电台列表（可选分类过滤） |
| `save` | `save [名称] [URL] [分类]` | 保存自定义电台 |
| `del` | `del [序号]` | 删除自定义电台（只能删自定义） |
| `test` | `test [序号]` | 测试电台可访问性 |

#### 系统命令

| 命令 | 格式 | 说明 |
|------|------|------|
| `status` | `status` | 显示当前状态（含 License 授权状态） |
| `wif` | `wif [SSID] [密码]` | 修改 WiFi 凭证（重启生效） |
| `scan` | `scan` | 重新扫描蓝牙设备 |
| `clear` | `clear` | 清除蓝牙配对 + 记忆直连地址 |
| `pair` | `pair` | 进入蓝牙配对模式（暂停 A2DP，可被手机/PC 搜索发现） |
| `normal` | `normal` | 恢复 A2DP 正常模式（配对完成后用） |
| `avrcdiag` | `avrcdiag` | AVRCP 诊断模式：注册原始回调检测耳机按键发什么事件（需 IDF 含 esp_avrc_api.h） |
| `lic` | `lic [激活码]` | 查看授权状态（无参）或激活授权（有参）v1.2.0 |
| `clearlic` | `clearlic` | 清除授权（播放将锁定）v1.2.0 |
| `restart` | `restart` | 重启设备 v1.2.0 |
| `help` | `help` | 显示命令帮助 |

#### 命令示例

```
> list              ← 显示所有电台
> list 音乐         ← 只显示音乐分类
> play 0            ← 播放序号 0（北京交通广播 FM103.9）
> next              ← 下一个
> pause             ← 暂停/恢复切换
> vol 80            ← 音量调到 80%
> save 我的电台 http://example.com/stream.mp3 自定义
> test 5            ← 测试序号 5 电台是否可访问
> status            ← 查看当前状态
> clear             ← 清除配对 + 记忆地址（换耳机时用）
> pair              ← 进入蓝牙配对模式（可被手机/PC 搜索发现）
> normal            ← 恢复 A2DP 正常模式（配对完用）
> avrcdiag          ← AVRCP 诊断模式（检测耳机按键发什么事件）
> lic               ← 查看授权状态
> lic TElDMSg...    ← 激活授权（激活码由 PC 签发工具生成）
> clearlic          ← 清除授权（播放将锁定）
> restart           ← 重启设备
> verbose           ← 事件日志开关（NVS 持久化）
> wif myWiFi myPass ← 修改 WiFi（重启生效）
```

### 5.3 蓝牙按键控制（AVRCP）

蓝牙耳机/音箱/车机的媒体按键通过 AVRCP pass-through 协议控制固件：

| 蓝牙按键 | opid | 固件动作 |
|---------|------|---------|
| 播放 ▶ | 0x44 | 恢复播放（暂停后） |
| 暂停 ⏸ | 0x46 | 暂停播放（软暂停：停解码+flush，保持蓝牙连接） |
| 下一曲 ▶▶ | 0x4B / 0x29 | 切换下一个电台 |
| 上一曲 ◀◀ | 0x4C / 0x28 | 切换上一个电台 |
| 停止 ■ | 0x40 | 停止播放 |
| 音量+ | 0x41 | 音量 +10%（仅当耳机走 AVRCP 时） |
| 音量- | 0x42 | 音量 -10%（仅当耳机走 AVRCP 时） |

> ⚠️ **重要**：按键转发行为取决于耳机/车机固件。
> - **已验证可用**：播放/暂停、上一曲/下一曲（多数支持 AVRCP 的设备都有）
> - **常见限制**：很多耳机的音量键是**硬件直控**（直接调耳机 DAC 增益），不发 AVRCP pass-through 命令，ESP32 收不到事件、无法响应。这类耳机的音量请用串口 `vol` 命令调整。
> - 暂停为"软暂停"：停止解码并清空 PCM 缓冲，但保持 A2DP 连接；恢复时重新拉流（有几秒延迟）。

### 5.4 蓝牙记忆直连

- **首次使用**：耳机/音箱进入配对模式，固件扫描并连接（原有流程）
- **之后开机**：固件自动回连上次连接的设备（双方已保存 link key，**无需再进配对模式**，只要设备开机且未被其他设备占用）
- 回连失败重试 8 次后自动回退到扫描模式
- `clear` 命令 = 清除所有配对 + 清除记忆直连地址（`forgetLastPeer()`：NVS 直删 connected_bda/src_bda + set_auto_reconnect(false)）
- 连接成功后自动重武装记忆直连（onConnectionStateChanged 回调里 set_auto_reconnect(true)）

### 5.5 蓝牙配对模式（pair/normal）

> ⚠️ **v1.4.0 已删除 SPP（蓝牙串口）功能**，命令回复统一经 USB 串口（`#define cmdOut Serial`）。
> `pair`/`normal` 命令保留，但用途改为纯 A2DP 配对场景：`pair` 暂停 A2DP 主动 page 并开放可发现，
> 便于手机/PC 搜索到设备；`normal` 恢复 A2DP 正常连接耳机。

#### pair/normal 命令说明

| 命令 | 作用 | A2DP | 可发现 | 适用场景 |
|------|------|------|--------|---------|
| `pair` | 进入配对模式 | 暂停（不连耳机） | 是（inquiry scan 开） | 需被手机/PC 搜索时 |
| `normal` | 恢复正常模式 | 恢复（连耳机） | 否（靠 bond 直连） | 配对完成后 |

> ⚠️ `pair`/`normal` 是 USB 串口命令。`pair` 模式下 A2DP 暂停不发音频，配对完必须 `normal` 恢复。

### 5.6 自动存储机制

- 切台或调音量后启动 5 分钟计时器
- 5 分钟内再次操作则重置计时器
- 5 分钟后自动将当前电台和音量存入 NVS
- 下次开机会自动恢复并播放

### 5.7 预设电台列表

共 332 个预设电台，按分类（分类名与 `stations.h` 的 `category` 字段一致）：

| 分类 | 数量 | 容器/格式 | 示例 |
|------|------|----------|------|
| 蜻蜓FM | 70 | 蜻蜓 HLS AAC（ls.qingting.fm） | 北京交通广播 FM103.9、北京好音乐 FM95.9 等 |
| 音乐 | 65 | 蜻蜓 MP3 直连 + 喜马拉雅 HLS AAC | 上海LoveRadio、动感101、经典947 等 |
| 喜马拉雅 | 64 | 喜马拉雅 HLS AAC（live.xmcdn.com） | 重庆音乐广播、中国相声等 |
| 省级 | 120 | HTTP TS 容器（satellitepull.cnr.cn） | 各省广播 |
| 央广 | 2 | HTTP TS 容器（ngcdn*.cnr.cn） | 中国之声、经济之声等 |
| 国广 | 5 | HTTP TS 容器（sk.cri.cn） | 环球资讯、南海之声等 |
| 国际 | 6 | AAC/MP3 | NPR、Radio Caroline、CNA938 等 |

序号 0 = 北京交通广播 FM103.9（蜻蜓FM 分类），即默认播放电台（`DEFAULT_STATION_IDX = 0`）。

### 5.8 状态信息

`status` 命令显示：

```
========== 当前状态 ==========
固件: v1.4.1 (2026-08-23)
播放: 播放中                ← 播放中/已停止，[暂停] 表示软暂停
序号: 0/331                 ← 当前序号/最大序号
电台: 北京交通广播 FM103.9
分类: 蜻蜓FM
URL: http://ls.qingting.fm/live/336.m3u8
解码: AAC-HLS               ← 无/MP3/AAC-HLS/AAC-直连
采样率: 44100Hz             ← 或 48000Hz 直发，其他显示 xxxHz→44100Hz
音量: 50%
蓝牙: 已连接 (ESP32-Radio)  ← A2DP 连接状态 + 设备名
音频流: 已启动              ← A2DP 音频流是否启动
网络缓冲: 45%               ← NET ringbuf 水位
PCM缓冲: 30%                ← PCM ringbuf 水位
heap: 29000                 ← 剩余内部 RAM
PSRAM: 4082148              ← 剩余 PSRAM
WiFi: home_wifi_5G
事件日志: 关                ← verbose 开关状态
本机 MAC: 28:05:A5:35:54:78
License: 已授权（永久）     ← 授权状态
==============================
```

---

## 六、项目文件结构

### 6.1 目录树

```
NetworkRadio_BT_ESP32Worver_IE/
├── ESP32_WROVER_IE_Dev_W_NetworkAudio_To_BT_v2.0.0_aac_low.ino  ← 主程序（编译必需，含 License 模块，约 1700 行）
├── secrets.h                                              ← WiFi + 蓝牙配置（编译必需）
├── stations.h                                             ← 预设电台表（332 个，编译必需）
├── partitions.csv                                         ← Flash 分区表（烧录必需）
├── platformio.ini                                         ← PlatformIO 编译配置（PIO 用）
├── .gitignore                                             ← Git 排除规则
├── README_软件说明书.md                                   ← 技术说明书（本文档）
├── 用户使用说明书.md                                      ← 用户操作手册
├── overview.md                                            ← 实现总结
├── ESP32开发踩坑录.md                                     ← 开发踩坑记录
├── License_授权激活说明书.md                              ← License 授权与激活详细说明书
├── License_模块设计方案.md                                ← License 设计方案 + 可行性审查记录
├── License_测试说明书.md                                  ← License 手动测试步骤 + 故障排查
├── 可用直播源列表.md                                      ← 固件预设电台清单（332 条，与 stations.h 一致）
├── 可用直播源详细列表.md                                  ← 直播源候选全集（829 条，含 HTTPS/重复）
├── 库补丁安装说明.md                                      ← ESP8266Audio 库补丁说明
├── tools/
│   ├── sign_license.py                                    ← License 签发工具（keygen/sign/verify/mac/info）
│   ├── test_license.py                                    ← License 自动化测试脚本（10 用例）
│   ├── license_key.pem                                    ← 签发私钥（🔴 绝密，.gitignore）
│   ├── gen_stations.py                                    ← 电台列表生成器
│   ├── test_stations.py / pc_test_stations.py             ← 电台测试脚本
│   ├── cli/
│   │   ├── esp32_api.py                                   ← 纯 Python API 层（24 个方法）
│   │   ├── esp32_cli.py                                   ← CLI 控制器（交互/单命令/JSON/监控）
│   │   ├── CLI使用说明.md                                 ← CLI 使用说明
│   │   └── requirements.txt                               ← 依赖：pyserial>=3.5
│   └── gui/
│       ├── esp32_api.py                                   ← GUI 用 API 层
│       ├── main.py                                        ← PyQt5 GUI 客户端
│       └── requirements.txt                               ← 依赖：PyQt5>=5.15 + pyserial>=3.5
└── Arduino/libraries/                                     ← 第三方库（ESP8266Audio 2.4.1 + ESP32-A2DP 1.8.11）
```

### 6.2 项目必要文件（编译/运行必需）

| 文件 | 类型 | 必需性 | 说明 | 配置要点 |
|------|------|--------|------|---------|
| `ESP32_WROVER_IE_Dev_W_NetworkAudio_To_BT_v2.0.0_aac_low.ino` | Arduino 源码 | **必需** | 主程序，约 1700 行。含 WiFi 连接、MP3/AAC 解码、A2DP Source、AVRCP、HLS/TsDemux、License、命令系统全部逻辑 | 无需配置，直接编译。文件名须与文件夹名一致（Arduino IDE 要求） |
| `secrets.h` | 配置头文件 | **必需** | WiFi 凭证 + 蓝牙目标设备过滤。已被 `.gitignore` 排除 | 首次使用必须修改：`WIFI_SSID` / `WIFI_PASSWORD` 改为你自己的；`BT_TARGET_NAME` 设为 `nullptr`（接受所有设备）或具体耳机名 |
| `stations.h` | 电台表头文件 | **必需** | 332 个预设电台（`presetStations[]` + `presetCount` + `DEFAULT_STATION_IDX`） | 直接编辑可改电台列表，重新编译烧录 |
| `partitions.csv` | 分区表 | **必需** | 4MB Flash 分区：nvs 20KB / otadata 8KB(0x2000) / app0 3MB / spiffs 960KB | Arduino IDE 用菜单选"Default 4MB with spiffs"时忽略此文件（用内置分区）；自定义分区或 PIO 编译时用此文件 |

### 6.3 编译配置文件

| 文件 | 类型 | 必需性 | 说明 | 配置要点 |
|------|------|--------|------|---------|
| `platformio.ini` | PIO 配置 | PIO 编译用 | PlatformIO 编译配置：espressif32@6.5.0、esp-wrover-kit、flash_mode=dio、monitor 115200、upload 921600 | Arduino IDE 编译**不需要**此文件。`lib_deps` 写 `ESP32-A2DP @ ^1.8.0` / `ESP8266Audio @ ^1.9.5`，但 `Arduino/libraries/` 内实际为 ESP32-A2DP 1.8.11 / ESP8266Audio 2.4.11，PIO 编译需匹配本地库版本 |
| `.gitignore` | Git 规则 | 版本管理用 | 排除 `secrets.h`（含密码）、`tools/license_key.pem`（私钥）、编译产物 | 提交前确认 `secrets.h` 与 `license_key.pem` 已被排除 |

### 6.4 文档文件

| 文件 | 说明 |
|------|------|
| `README_软件说明书.md` | 技术说明书（本文档）：架构、参数、引脚、故障排除、版本历史。面向开发者 |
| `用户使用说明书.md` | 用户操作手册：命令大全、A2DP 操作流程、常见问题。面向最终用户 |
| `overview.md` | v1.4.1 实现总结：音质优化、网络稳定性、TsDemux 改进、CLI 客户端 |
| `License_授权激活说明书.md` | License 授权模块说明（`ENABLE_LICENSE=1` 已启用） |
| `License_模块设计方案.md` | License 设计方案 + 可行性审查记录 |
| `License_测试说明书.md` | License 手动测试步骤 + 故障排查 |
| `可用直播源列表.md` | 固件预设电台逐条清单（332 条，与 `stations.h` 一致） |
| `可用直播源详细列表.md` | 直播源候选全集（829 条，含 HTTPS/重复，非固件预设） |
| `ESP32开发踩坑录.md` | 开发过程踩坑记录 |
| `库补丁安装说明.md` | ESP8266Audio 库补丁安装说明 |

### 6.5 文件依赖关系

```
编译流程：
  secrets.h ──被 include──┐
  stations.h ──被 include──┼→ ESP32_..._v2.0.0_aac_low.ino ──编译──→ 固件.bin
  partitions.csv ──────────────────────────────────────────────→ 烧录时分区

库依赖（Arduino/libraries/ 内本地副本）：
  ESP8266Audio (Earle Philhower) 2.4.1  ← MP3/AAC 解码
  ESP32-A2DP (pschatzmann) 1.8.11       ← A2DP Source + AVRCP
```

### 6.6 获取项目后的操作步骤

1. **复制项目文件夹**到 Arduino IDE 的 sketchbook 目录
2. **编辑 `secrets.h`**：修改 WiFi SSID 和密码
3. **安装库**：ESP8266Audio 2.4.1 + ESP32-A2DP 1.8.11（含库补丁，见 `库补丁安装说明.md`）
4. **Arduino IDE 配置**：Board = ESP32 Wrover，Flash Size = 4MB，Partition = Default 4MB with spiffs，PSRAM = Enabled，CPU = 240MHz
5. **编译烧录**
6. 首次烧录建议先 `工具 → Erase Flash → All`（清除旧 NVS 遗留的蓝牙记忆地址）

---

## 七、库依赖

| 库 | 作者 | 实际版本 | 用途 |
|----|------|---------|------|
| ESP8266Audio | Earle Philhower | 2.4.1 | MP3/AAC 解码（AudioGeneratorMP3/AudioGeneratorAAC） |
| ESP32-A2DP | pschatzmann | 1.8.11 | 蓝牙 A2DP Source + AVRCP |

> 版本来源：`Arduino/libraries/ESP8266Audio/library.properties`（version=2.4.1）与 `Arduino/libraries/ESP32-A2DP/library.properties`（version=1.8.11）。
> 库副本随项目提供在 `Arduino/libraries/` 下，含库补丁（见 `库补丁安装说明.md`）。

### Arduino IDE 配置

- ESP32 Arduino Core: 3.3.11+（实测 v5.5.5 SDK）
- 库位置：项目内 `Arduino/libraries/`（ESP8266Audio 2.4.1 + ESP32-A2DP 1.8.11）

> 注意：`platformio.ini` 的 `lib_deps` 写 `ESP32-A2DP @ ^1.8.0` / `ESP8266Audio @ ^1.9.5`，
> 与本地库实际版本（1.8.11 / 2.4.1）不完全匹配。PlatformIO 编译时需调整版本号或使用本地库副本。

---

## 八、故障排除

### 8.1 编译错误

| 错误 | 解决方案 |
|------|---------|
| `esp_avrc_common.h: No such file or directory` | 该版本 IDF 无此头文件；v1.1.0 已改用 AVRCP spec 数值常量 AVC_PT_* 规避 |
| `ESP_BT_MODE_CLASSIC was not declared` | 改用 `ESP_BT_MODE_CLASSIC_BT`（3.x 新宏名） |
| `Partitions overlap` | otadata 必须 8KB（0x2000） |
| `Image length doesn't fit` | 用单 app 3MB 分区，去掉 OTA 双分区 |

### 8.2 运行问题

| 问题 | 可能原因 | 解决方案 |
|------|---------|---------|
| 蓝牙连不上（反复 Connecting→Disconnected stat=260 BUSY） | NVS 有旧版本遗留的无效记忆地址 | 串口发 `clear` 清除记忆+配对，确保耳机开机可发现，再 `scan` |
| TWDT 触发重启（`Task watchdog got triggered - AudioTask`） | startURL 重连时 client.connect 到慢服务器阻塞 >15s | v1.1.0 已修复：startURL 退订 TWDT + connect 5s 超时 |
| AVRCP 音量键无效 | 耳机音量键可能是硬件直控（DAC 增益），不发 AVRCP | 先发 `avrcdiag` 诊断：按音量键看日志有无 `[AVRCP诊断]` 事件。无事件=硬件直控，用 `vol` 命令或物理按键调音量 |
| 音量恒为 100% 不随 vol 变化 | v1.0.0 bug：ConsumeSample 未调 Amplify | v1.1.0 已修复（ConsumeSample 调 Amplify/MakeSampleStereo16） |
| 32k 台播放速度快 1.378x | 该流 32kHz，A2DP 固定 44.1k 导致 | v1.1.0 已修复：ConsumeSample 重采样 32k→44.1k（线性插值+背压） |
| 48k 台崩溃重启 | SetRate 误设基类 hertz 致 A2DP 协商错采样率 | v1.1.0 已修复：SetRate 不设 hertz + ConsumeSample 稳健版（int32 饱和+guard） |
| 起播"流结束反复重连" | fetchTask 刚启动 NET ringbuf 空，read 返回 0 误判 | v1.1.0 已修复：open() 预缓冲 32KB 再放行（3s 超时） |
| 48k 台偶发跳帧 | A2DP 消费与解码生产在满水位拉锯 | v1.1.0 已改善：PCM 缓冲 64→128KB 吸收抖动 |
| 无声 | 蓝牙未连接 / 电台源断供 | 检查耳机配对，输入 `scan` 重新扫描；换台测试 |
| 卡顿 | 网络不稳定 | 已有 256KB 网络缓冲，若仍卡顿检查 WiFi 信号 |
| heap 不足 | 内存泄漏 / PSRAM 未初始化 | 重启设备，检查 `[PSRAM]` 日志 |
| WiFi 连不上 | 凭证错误 | 用 `wif` 命令修改，重启生效 |
| 手机/PC 搜不到 ESP32-Radio（v1.1.1） | A2DP 主动 page 耳机抑制 inquiry scan | USB 串口发 `pair` 暂停 A2DP，再搜索配对 SPP，配对后发 `normal` |
| SPP 配对后连不上（v1.1.1） | 端配对被删 / bond 丢失 | 重新 `pair` 配对；日常靠 bond 直连不需搜索 |
| A2DP 连耳机失败死循环（v1.1.1） | AIGOD 等设备 stale bond 认证失败 | USB 串口发 `clear` 清配对，再 `normal` 重新配对耳机 |
| `ESP_BT_SCAN_MODE_CONNECTABLE_DISCOVERABLE` 未声明（v1.1.1） | IDF 5.x API 改双参数 | 用 `esp_bt_gap_set_scan_mode(ESP_BT_CONNECTABLE, ESP_BT_GENERAL_DISCOVERABLE)` |

### 8.3 串口日志解读

```
[WDT] TWDT 已配置 15s (panic)        ← 看门狗启动（"already initialized" 噪音无害）
[PCM] ringbuf=0x3fffxxxx size=131072 (内部RAM)  ← PCM 缓冲创建诊断（启动时）
[NET] ringbuf=0x3fffxxxx size=262144 (内部RAM)  ← NET 缓冲创建诊断（每次切台出现）
[A2DP] 启动（记忆直连已开启）...      ← 蓝牙启动
[A2DP连接] Connected                   ← 连接成功
[A2DP] 连接成功 heap=...（地址已记忆，下次开机自动直连）  ← 地址已存 NVS
[A2DP音频] Started                     ← 蓝牙音频流启动
[HTTP] 连接成功                        ← 电台连接 OK
[HTTP] 预缓冲 32KB                     ← 起播预缓冲完成（避免 read 立即返回 0）
[播放] 启动成功                        ← MP3 解码器启动
[直发] 48000Hz（不重采样，测试 Bluedroid 是否协商 48k SBC）  ← 48k 流直发无损
[重采样] 32000Hz → 44100Hz (rsStep=0.7256)  ← 32k 流升采样到 44.1k
[AVRCP] 按键 PAUSE (0x46)             ← 收到耳机暂停键
[状态] 上海LoveRadio | 播放 | vol=50% heap=29000  ← 正常运行
```

### 8.4 关键日志告警

| 日志 | 含义 | 处理 |
|------|------|------|
| `esp_task_wdt_init: TWDT already initialized` | 系统已初始化 TWDT，reconfigure 重配 | 无害，正常运行 |
| `esp_task_wdt_reset: task not found` | reconfigure 后 loop task 旧订阅失效 | 无害，一次性噪音，audioTask 监控不受影响 |
| `[A2DP连接] Disconnected` 后反复 Connecting | 记忆直连地址无效或设备不可达 | `clear` 清记忆后 `scan` |
| `Task watchdog got triggered - AudioTask` | audioTask 卡死 15s | v1.1.0 已修复（startURL 退订+connect 5s），若仍出现贴日志 |
| `[NET]/[PCM] ringbuf=... (内部RAM)` | ringbuf 实际位置诊断 | 正常，384KB 在内部 RAM 实测可用；若显示 `创建失败` 则内存不足需减小缓冲 |
| `[重采样] xxxxHz → 44100Hz` | 32k 流升采样启用 | 正常，SBC 32k 耳机不支持必须重采样 |
| `[直发] 48000Hz` | 48k 流直发（Bluedroid 协商 48k SBC） | 正常无损；若 48k 台慢/音调低则 Bluedroid 未协商 48k，需回退 `resampling = (hz != 44100)` 降采样 |
| `[HTTP] 预缓冲 32KB` | 起播预缓冲完成 | 正常；若持续 <32KB 说明服务器供数慢，可能后续断流 |

---

## 九、版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| v1.0.0 | 2026-08-17 | 首个稳定版：71 电台 + 异步管线 + 完整命令系统 |
| v1.1.0 | 2026-08-18 | AVRCP 蓝牙按键、记忆直连、断流退避+TWDT 看门狗、修复 vol 音量无效 |
| v1.1.1 | 2026-08-19 | SPP 蓝牙串口命令、pair/normal 模式切换、双输出、修复 A2DP 抑制 SPP 配对 |
| v1.1.2 | 2026-08-19 | 串口日志精简（删冗余提示）、加作者信息、文档修订 |
| v1.2.0 | 2026-08-20 | A2DP熔断、HTTPS支持、物理按键、SPP配对提示、License授权模块(IP保护) |
| v1.3.0 ~ v1.3.2 | 2026-08-20 | AAC解码器集成、SBR clamp修复、outSample 8KB、errMsg诊断、isAacUrl识别、0KB预缓冲、FlushCodec、ADTS验证 |
| v1.4.0 | 2026-08-22 | 删除SPP省RAM/Flash、TsDemux手写解复用、HTTP/1.0、蓝牙退避、play支持URL、decoder超时12s、双斜杠修复、跳前导空白/Tab |
| v1.4.1 | 2026-08-23 | 定点Q16重采样+IIR抗混叠+丢帧补偿+TsDemux优化+CLI/GUI客户端+verbose命令+status增强 |

### v1.4.1 详细变更

1. **定点 Q16 重采样**：替代 `double` 浮点线性插值，全 32 位整数运算，减少量化噪声 + 提速。
2. **一阶 IIR 抗混叠低通**：`y[n] = y[n-1] + alpha/256 * (x[n] - y[n-1])`，DC 增益=1.0，减少上采样高频镜像。
3. **段边界丢帧补偿**：`ConsumeLastGood()` 用前一帧数据渐弱填充（最多 5 帧，每次衰减 6dB），避免段边界静音。
4. **48000Hz 直发保留**：48k 不重采样直接发给 SBC 编码器，无音质损失。
5. **段失败跳过 5→2 次**：减少卡顿时间从 ~15s 降到 ~4s。
6. **重连失败切台 5→3 次**：减少等待时间从 ~30s 降到 ~18s。
7. **NET ringbuf 水位监控**：低于 10% 时 `vTaskDelay(5ms)` 让出 CPU 给 fetchTask 灌数据。
8. **WiFi 重连限流**：10s 间隔检查，去掉 `delay(2000)` 阻塞 loop()。
9. **TsDemux ADTS 帧完整性检查**：processPes 按 ADTS 同步字+帧长度逐帧输出，不完整帧丢弃，减少 -15 错误。
10. **TsDemux 段切换不 reset**：保留 pmtPid/audioPid + TS 对齐，减少段间空窗。
11. **playlist 刷新自适应**：targetDur≤3 时刷新间隔 1s（原 targetDur/2）。
12. **TS 读取缓冲扩大**：512→752 字节（4 个 TS 包），减少残包处理。
13. **status 新增字段**：解码类型(MP3/AAC-HLS/AAC-直连)、采样率、蓝牙设备名、事件日志状态。
14. **verbose 命令**：事件日志开关，NVS 持久化，默认关闭减少串口噪声。
15. **CLI 客户端**：`tools/cli/esp32_api.py`（纯 Python API，22 个方法）+ `esp32_cli.py`（交互/单命令/JSON/监控四种模式）。
16. **GUI 客户端**：`tools/gui/main.py`（PyQt5，串口选择/状态监控/播放控制/日志窗口）。

### v1.2.0 详细变更

1. **A2DP 熔断机制**：onConnectionStateChanged(DISCONNECTED) 连续失败计数，超 A2DP_FAIL_MAX(5) 后 set_auto_reconnect(false) 停止自动重连，避免死循环 page 导致 heap 耗尽。scan/clear/normal 命令重置计数。status 显示熔断状态。
2. **HTTPS 支持**：AsyncHTTPSource 加 WiFiClientSecure 成员 + activeClient 指针动态切换。https:// 用 secureClient.setInsecure() 跳过证书验证，端口 443。WiFiClientSecure 继承 WiFiClient，用基类指针统一访问。
3. **物理按键**：GPIO13=next, GPIO14=prev, GPIO15=clear。内部 pullup，按键接 GND。消抖 50ms。clear 长按 3 秒触发（防误触清配对），镜像 clear 命令逻辑。checkButtons() 在 loop 轮询。
4. **SPP 配对提示**：loop 周期检测 sppConnected，未连接且启动 30 秒后，每 60 秒提示"发 pair 配对手机/PC"。连上后不再提示。
5. **License 授权模块（IP 保护第一阶段）**：
   - ECDSA P-256 签名 + eFuse MAC 绑定，防止固件被随意烧录到其他板运行
   - 激活码 = Base64("LIC1" + MAC + 到期LE + ECDSA DER签名)，112-116 字符
   - mbedtls 验签用 ECP 层（`MBEDTLS_ALLOW_PRIVATE_ACCESS` + `mbedtls_ecdsa_read_signature`）
   - 播放闸门在 `startURLCore` 顶部，覆盖全部 11 个播放入口（单点管控）
   - NVS 命名空间 "lic"（键 "blob"，`putBytes`/`getBytes` 二进制安全）
   - NTP 到期复查：无网络跳过到期检查（签名+MAC 仍强制），避免离线变砖
   - 命令：`lic [激活码]`（激活/查看）、`clearlic`（清除）、`restart`（重启）
   - PC 工具：`tools/sign_license.py`（签发）+ `tools/test_license.py`（自动化测试 10 用例）
   - 详见 `License_授权激活说明书.md` 和 `License_模块设计方案.md`

### v1.1.2 详细变更

1. **串口日志精简**：删除项目代码的 `[heap]` 调试行等冗余提示。保留 `esp_log_level_set("*", ESP_LOG_WARN)` 降 esp_log 系列。ESP32-A2DP 1.8.11 定制版用 `Serial.printf` 硬编码 `[GAP]`/`[A2DP] 事件=`/`connecting_hdlr` 诊断日志，无 API 开关（`set_log_level` 不存在），如需彻底屏蔽需改库源码（见 8.3 节）。
2. **作者信息**：文件头 + FW_AUTHOR 宏 + showVersion/banner 显示作者（陈志明 13654132703 微信 tsearcher）。
3. **文档修订**：README 加项目文件结构章节、用户使用说明书、版本历史同步到 v1.1.2。

### v1.1.1 详细变更

1. **SPP 蓝牙串口命令**：`BluetoothSerial SerialBT`，`begin("ESP32-Radio", false, true)` 第三参 disableBLE=true 保持 Classic-only。回调 `onSppCallback` 照抄 AVRCP 极简原则（只设 bool + 日志，不阻塞）。`checkSppInput` 镜像 `checkSerialInput` 复用 `processCommand`。setup 中 `SerialBT.begin` 必须先于 `a2dp_source.start()`（GAP 回调后注册者生效）。
2. **双输出**：`class DualPrint : Print` + `static DualPrint cmdOut(&Serial, &SerialBT)`，showVersion/Help/List/Status/processCommand/parseSave/testStation/sendCmdPlay/forgetLastPeer 体内 `Serial.print*` → `cmdOut.print*`；诊断日志（A2DP/HTTP/任务）保持 USB-only。
3. **设备名覆盖修复**：A2DP 库 `start()` 会把 GAP device name 覆盖成库默认 "ESP-A2DP-SBC"，导致 SPP 服务对外显示名也变。`start()` 之后立即 `esp_bt_dev_set_device_name(BT_SPP_NAME)` 改回。
4. **可发现模式**：A2DP Source 默认不保持 discoverable（DISCOVERING 短暂、UNCONNECTED 不可发现）。setup + loop 每 2s 周期重设 + onConnectionStateChanged(DISCONNECTED) 兜底重设 `esp_bt_gap_set_scan_mode(ESP_BT_CONNECTABLE, ESP_BT_GENERAL_DISCOVERABLE)`。IDF 5.x 双参数 API。
5. **pair/normal 模式切换**：根本解决"A2DP 主动 page 抑制 inquiry scan"问题。`pair` 命令设 `sppPairOnly=true`（ssidCallback 返回 false 不连任何 A2DP 设备）+ `set_auto_reconnect(false)` + discoverable；`normal` 恢复。SPP 首次配对需 `pair`（暂停 A2DP），配对后靠 bond 直连（page scan 不被 page 抑制）可与 A2DP 共存。
6. **clear 后自动重新扫描**：`clear` 命令末尾加 `a2dp_source.start()`，清除配对后自动进入 DISCOVERING（可被发现状态），否则停在 UNCONNECTED 手机/PC 搜不到。
7. **FW_VERSION** v1.1.0 → v1.1.1（对齐文件名，修现存不一致）。

### v1.1.0 详细变更

1. **AVRCP 蓝牙按键控制**：`set_avrc_passthru_command_callback`，耳机播放/暂停/上下曲/停止/音量键 → 切台/暂停/音量。回调在蓝牙栈线程只入队不阻塞。串口新增 `pause` 命令。
2. **蓝牙记忆直连**：`set_auto_reconnect(true, 8)`，库自动把地址存 NVS(connected_bda/src_bda)，开机自动直连，失败 8 次回退扫描。`clear` 命令调 `forgetLastPeer()` 清除（库 reset_last_connection 是 protected，用 NVS 直删等效替代）。
3. **断流重连加强 + TWDT**：指数退避 [3,5,10,20,30]s，连续失败 5 次切下一台；stall 30s 保险。TWDT `esp_task_wdt` 15s panic 监控 audioTask，`idle_core_mask=0` 不监控 idle。startURL 期间退订 TWDT（避免 client.connect 到慢服务器阻塞误触发）。
4. **修复 vol 音量无效**：`ConsumeSample` 调用 `Amplify()` + `MakeSampleStereo16()`（ESP8266Audio 基类 `SetGain` 只存 `gainF2P6`，派生类必须自调 Amplify 才生效）。
5. **HTTP connect 超时**：`client.connect(host, port, 5000)` 限制单次连接阻塞 5s（lwIP 默认 ~30s 会卡死 audioTask）。
6. **采样率重采样**：44.1k/48k 流直发（Bluedroid 协商 SBC 采样率，48k 自动协商 48k 无损直发）；32k 流升采样到 44.1k（SBC 32k 耳机不支持）。线性插值 + 背压（send 失败返回 false 停解码，避免全速清空 NET ringbuf）。SetRate 不设基类 hertz 避免 A2DP 协商错采样率崩溃。解决湖北经典音乐(32k)速度快 1.378x、内蒙古音乐之声(48k)崩溃。
7. **起播预缓冲**：`open()` 等 NET ringbuf 攒到 32KB 再放行（3s 超时兜底），避免起播 read 立即返回 0 误判流结束反复重连（蜻蜓某些流服务器启动供数慢）。
8. **缓冲加大**：NET 128→256KB，PCM 64→128KB（在内部 RAM，实测 384KB 可用，heap 剩 ~28KB）。48k 跳帧明显减少。
9. **ringbuf 创建诊断**：构造函数打印 `ringbuf=地址 (PSRAM/内部RAM)`，启动日志确认实际内存位置（实测落内部 RAM `0x3fffxxxx`）。

### v2.0.0 规划（未发布）

- 用 arduino-audio-tools 替换 ESP8266Audio
- 支持 HTTPS（需解决 mbedTLS buffer 限制或升级硬件）
- IP 保护二期：Flash Encryption + Secure Boot v2
