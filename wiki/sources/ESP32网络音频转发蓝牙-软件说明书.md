# ESP32 网络音频转发蓝牙 — 软件说明书（v1.4.1）

> 这页是原始资料摘要：[[ESP32网络音频转发蓝牙设备]] v1.4.1 固件的技术说明书（README），覆盖架构、参数、引脚、版本历史与故障排除。

## 资料讲什么

`raw/README_软件说明书.md` 是 v1.4.1 固件（2026-08-23 发布）面向开发者的技术文档，作者陈志明（电话 13654132703，微信 tsearcher）。系统以 ESP32-WROVER-IE 为核心，通过 WiFi 接收网络 MP3/AAC 音频流（含 HLS/TS），解码后经蓝牙 [[A2DP蓝牙音频协议]] 转发给耳机/音箱。

## 核心功能（v1.4.1 累计汇总）

- **电台库**：332 个预设（蜻蜓 FM 70 + 音乐 65 + 喜马拉雅 64 + 省级 120 + 央广 2 + 国广 5 + 国际 6）。
- **控制方式**：串口命令（USB）/ Python CLI（v1.4.1 新增）/ PyQt5 GUI（v1.4.1 新增）/ AVRCP 耳机按键四种。
- **音频管线（异步）**：WiFi 拉流 → AsyncHTTPSource → 384KB NET ringbuf → MP3/AAC 解码（PSRAM 预分配）→ ConsumeSample（v1.4.1 调 Amplify + MakeSampleStereo16）→ 128KB PCM ringbuf → A2DP → SBC 编码 → 耳机。
- **可靠性机制**：TWDT 15s 看门狗、断流指数退避 [3/5/10/20/30]s、连续失败 3 次切台、起播预缓冲 32KB、NET/PCM ringbuf 水位监控、WiFi 重连限流 10s。
- **采样率处理**：44.1k/48k 流直发（SBC 协商）；32k 流升采样到 44.1k（线性插值 + 背压；v1.4.1 改定点 Q16 + 一阶 IIR 抗混叠）。
- **存储**：自定义电台最多 50 个（NVS，数组放 PSRAM），切台 5 分钟后自动存储，WiFi 凭证可运行时修改。
- **授权**：ECDSA-P256 + eFuse MAC 绑定的 License 模块（v1.2.0 引入）。

## 双核任务分配

| 核心 | 任务 |
|------|------|
| Core 0 | A2DP Bluedroid 协议栈 + 系统管理；loop()（优先级 1）跑串口命令、WiFi 重连、自动存储检查、周期状态打印 |
| Core 1 | audioTask（优先级 10）跑 MP3/AAC 解码循环 + TWDT 喂狗；HTTPFetch（优先级 1）跑异步 HTTP 读取 |

## 关键参数表

### 缓冲与起播
| 参数 | 值 | 说明 |
|------|-----|------|
| `NET_BUF_SIZE` | 384KB | 网络环形缓冲（64kbps 约 48s 抗弱网；v1.1.0 从 128→256，v1.4.1 进一步加大） |
| `PCM_BUF_SIZE` | 128KB | PCM 环形缓冲（约 1.36s@48k / 1.45s@44.1k；v1.1.0 从 64→128） |
| `g_mp3PreallocSize` | 30KB | MP3 解码器预分配（PSRAM） |
| `g_aacPreallocSize` | 128KB | AAC 解码器预分配（PSRAM） |
| 起播预缓冲 | 32KB | open() 等 NET 攒到 32KB 才放行（3s 超时） |
| ringbuf 位置 | 内部 RAM | 诊断日志显示 0x3fffxxxx，实测 512KB 可用，剩 ~28KB |

### 可靠性
| 参数 | 值 | 说明 |
|------|-----|------|
| `WDT_TIMEOUT_MS` | 15000 | TWDT 超时 15s |
| `STALL_TIMEOUT_MS` | 30000 | playing=真但 mp3 异常空 30s → 重启 |
| `RECONNECT_MAX_FAIL` | 3 | 连续重连失败 3 次切下一台（v1.4.1 从 5 改 3） |
| `reconnectBackoff[]` | 3/5/10/20/30s | 指数退避 |

### 蓝牙
- 模式：`ESP_BT_MODE_CLASSIC_BT`（释放 BLE 栈 10KB）
- 记忆直连：`set_auto_reconnect(true, 8)`，失败 8 次回退扫描
- AVRCP pass-through：支持 play/pause/next/prev/stop/volume±

### Flash 分区（4MB）
| 分区 | 大小 | 偏移 |
|------|------|------|
| bootloader | 32KB | 0x0000 |
| partition_table | 4KB | 0x8000 |
| nvs | 20KB | 0x9000 |
| otadata | 8KB | 0xE000 |
| app0 | 3MB | 0x10000 |
| spiffs | 960KB | 0x310000 |

## 版本历史

| 版本 | 日期 | 主要变更 |
|------|------|---------|
| v1.0.0 | 2026-08-17 | 首个稳定版：71 电台 + 异步管线 + 完整命令系统 |
| v1.1.0 | 2026-08-18 | AVRCP 蓝牙按键、记忆直连、断流退避 + TWDT、修复 vol 无效、采样率重采样、起播预缓冲 |
| v1.1.1 | 2026-08-19 | SPP 蓝牙串口、pair/normal 模式、双输出 |
| v1.1.2 | 2026-08-19 | 串口日志精简 |
| v1.2.0 | 2026-08-20 | A2DP 熔断、HTTPS 支持、物理按键、License 授权模块 |
| v1.3.0 ~ v1.3.2 | 2026-08-20 | AAC 解码器、ADTS 校验等 |
| **v1.4.0** | **2026-08-22** | **删除 SPP 省 RAM/Flash、TsDemux 手写解复用、HTTP/1.0、蓝牙退避、play 支持 URL、TsDemux 不 reset、双斜杠修复** |
| **v1.4.1** | **2026-08-23** | **定点 Q16 重采样 + IIR 抗混叠 + 丢帧补偿 + TsDemux 优化 + CLI/GUI 客户端 + verbose 命令 + status 增强** |

> ⚠️ **版本说明**：v1.4.1 在 README_软件说明书.md 中描述为最新版。但 [[本地AI-Wiki知识库]] 中关于此项目的近期决策（如 [[ESP32网络音频转发蓝牙设备]] v1.4.0 运行日志）将 v1.4.0 作为稳定基线、v1.4.1 视为引入回归后回滚的目标。wiki 维护按事实录入两份并存，新旧两说同时披露，等用户裁断。

## v1.4.1 详细变更（16 项）

定点 Q16 重采样 / 一阶 IIR 抗混叠低通（DC gain=1.0）/ ConsumeLastGood 段边界丢帧补偿 / 48000Hz 直发 / 段失败跳过 5→2 次 / 重连失败切台 5→3 次 / NET ringbuf 水位监控让出 CPU / WiFi 重连限流 10s / TsDemux ADTS 完整性检查 / TsDemux 段切换不 reset（保留 PID）/ playlist 刷新自适应（targetDur≤3 时 1s）/ TS 读取缓冲 512→752 字节 / status 新增解码类型/采样率/蓝牙名/事件日志 / verbose 命令（NVS 持久化）/ CLI 客户端（22 个方法 + JSON 输出）/ GUI 客户端（PyQt5 状态监控 + 日志窗口）。

## 主要已知问题（故障排除）

| 现象 | 根因 | 解决 |
|------|------|------|
| 蓝牙反复 Connecting→Disconnected stat=260 | NVS 有旧版本遗留的无效记忆地址 | `clear` 清记忆后 `scan` |
| TWDT 触发 AudioTask 重启 | startURL 重连 client.connect 到慢服务器阻塞 >15s | v1.1.0 已修（退订 TWDT + 5s 超时） |
| AVRCP 音量键无效 | 耳机音量键硬件直控（不发 AVRCP） | `avrcdiag` 诊断，无事件则是硬件直控 |
| 音量恒为 100% | v1.0.0 ConsumeSample 未调 Amplify | v1.1.0 已修 |
| 32k 台速度快 1.378x | 32k 流未升采样 | v1.1.0 已修（重采样 + 背压） |
| 48k 台崩溃 | SetRate 误设 hertz | v1.1.0 已修 |
| 起播"流结束反复重连" | NET ringbuf 空时 read 返回 0 | v1.1.0 已修（32KB 预缓冲） |

## 库与工具链

| 库 | 作者 | 实际版本 | 用途 |
|----|------|---------|------|
| ESP8266Audio | Earle Philhower | 2.4.1 | MP3/AAC 解码 |
| ESP32-A2DP | pschatzmann | 1.8.11 | A2DP Source + AVRCP |

Arduino IDE 配置：ESP32 Arduino Core 3.3.11+（实测 v5.5.5 SDK）、Board=ESP32 Wrover、Flash=4MB、Partition=Default 4MB with spiffs、PSRAM=Enabled、CPU=240MHz、上传 921600bps。

## 项目文件结构（关键部分）

```
NetworkRadio_BT_ESP32Worver_IE/
├── ESP32_WROVER_IE_Dev_W_NetworkAudio_To_BT_v2.0.0_aac_low.ino ← 主程序（约 1700 行）
├── secrets.h                                                   ← WiFi + 蓝牙过滤配置
├── stations.h                                                  ← 332 个预设电台
├── partitions.csv                                              ← Flash 分区表
├── README_软件说明书.md                                        ← 本文档（技术）
├── 用户使用说明书.md                                           ← 用户操作手册
└── tools/                                                      ← License 签发 + CLI/GUI 客户端
```

## 与同库其他资料的关系

- [[ESP32网络音频转发蓝牙设备]]：v1.4.0 运行实体描述（基线版本，与 v1.4.1 并存）。
- [[ESP32网络音频转发蓝牙-v1.4.0运行日志]]：v1.4.0 串口日志，反映 `AAC decode error -15` 与央广 HLS "播放列表无媒体段" 已知问题。
- [[ESP32网络音频转发蓝牙-用户使用说明书]]：v1.4.1 用户命令大全与 A2DP/AVRCP 操作流程。
- [[A2DP蓝牙音频协议]]：蓝牙音频传输协议概念。
- [[HLS流媒体协议]]：m3u8 + TS 分片流媒体协议，本设备用 TsDemux 手写解复用。

---
**内容来源**：`raw/README_软件说明书.md`
