# ESP32 网络音频转发蓝牙设备

> 这页讲一个工具：基于 ESP32-WROVER-IE 的网络音频转发蓝牙设备，抓取网络电台流再经蓝牙转发给耳机/音箱。覆盖 v1.4.0（运行日志基线）与 v1.4.1（技术/用户说明书最新文档版本）。

## 它是什么

一台以 ESP32-WROVER-IE 为核心的嵌入式设备，作者陈志明（电话 13654132703，微信 tsearcher）。设备通过 WiFi 拉取网络电台 [[HLS流媒体协议]] 直播流，解码后经 [[A2DP蓝牙音频协议]] 转发给蓝牙耳机/音箱。蓝牙设备名 `ESP32-Radio`。

固件版本：v1.4.0（基线，运行日志 2026-08-22 编译）→ v1.4.1（最新，文档 2026-08-23 发布，含定点 Q16 重采样 + CLI/GUI 客户端等 16 项改进）。

## 硬件与资源

- Flash 4MB；PSRAM 4MB（用户手册）/ 8MB（软件说明书）— 见 PSRAM 分歧说明。
- MP3 预分配 30KB、AAC 预分配 128KB、电台数组 50×312B 均在 PSRAM；PCM ringbuf 131072B 在内部 RAM（v1.4.1 加大 NET → 384KB）。
- 按键：next=GPIO13、prev=GPIO14、clear=GPIO15（长按 3s，v1.2.0 引入）。
- 引脚：UART0（GPIO1/3）115200bps 串口。
- NVS 存储音量、电台序号、自定义电台与授权信息；NTP 对时。
- TWDT 看门狗 15s（panic），audioTask 卡死 15s 触发重启。
- 音频解码与音频任务运行于 Core 1。

## 功能特性

- **控制方式（v1.4.1 累计）**：串口命令 / Python CLI / PyQt5 GUI / AVRCP 耳机按键四种。
- **命令行控制**：play / list / save / next / prev / pause / del / vol / stop / wif / status / test / help / scan / restart / clear / pair / normal / lic / clearlic / verbose（v1.4.1 新增）。
- **AVRCP**：耳机 play/pause/next/prev/stop/音量 键可用。
- **记忆直连**：开机自动连上次设备，失败 8 次回退扫描。
- **配对模式**：`pair` 暂停 A2DP 可被手机/PC 搜索，`normal` 恢复。
- **License 授权机制**（v1.2.0 起）：未授权时播放锁定（`lic` 激活 / `clearlic` 清除），ECDSA-P256 + eFuse MAC 绑定。
- **物理按键**（v1.2.0 起）：GPIO 切台/清配对。

## 双核任务分配（v1.4.1）

| 核心 | 任务 |
|------|------|
| Core 0 | A2DP Bluedroid + 系统管理；loop()（优先级 1）跑串口命令、WiFi 重连、自动存储检查、状态打印 |
| Core 1 | audioTask（优先级 10）MP3/AAC 解码 + TWDT 喂狗；HTTPFetch（优先级 1）异步 HTTP 读取 |

## 异步管线数据流（v1.4.1）

```
WiFi (HTTP/HTTPS MP3/AAC 流)
    │
    ▼
AsyncHTTPSource
    ├─ fetchTask 后台异步读取
    └─ 384KB 环形缓冲 (NET_BUF_SIZE, 内部 RAM)
    │ read() 不阻塞
    ▼
AudioGeneratorMP3/AAC (ESP8266Audio 2.4.1)
    ├─ MP3 30KB / AAC 128KB 预分配 (PSRAM)
    └─ ConsumeSample() 写入 PCM 缓冲（★ 调 Amplify 应用音量；★ 调 MakeSampleStereo16 转立体声）
    │ xRingbufferSend 非阻塞
    ▼
PCM 环形缓冲 128KB (PCM_BUF_SIZE, 内部 RAM) ≈ 1.45s 立体声 @44.1kHz
    │ xRingbufferReceiveUpTo
    ▼
A2DP 数据回调 → SBC 编码 → 蓝牙耳机
```

> ⚠️ **PCM 缓冲时长算术分歧**：上图标注"128KB ≈ 1.45s 立体声 @44.1kHz"。验算：128KB = 131072B ÷ 44100Hz = 2.97s（单声道 16-bit）；若立体声（每帧 4B：L16+R16），则 131072 ÷ 176400 ≈ 0.74s。1.45s 恰好是单声道数值（2B/样本）。疑为将单声道时长误标为"立体声"，或缓冲在 MakeSampleStereo16 之前按单声道计。两说并存，等用户裁断。

## 关键设计决策（v1.4.1 节选）

| 决策 | 原因 |
|------|------|
| 异步 HTTP 读取 | 网络 I/O 不阻塞 MP3 解码 |
| 环形缓冲替代队列 | FreeRTOS ringbuf 更高效，支持字节流 |
| ConsumeSample 调 Amplify/MakeSampleStereo16 | ESP8266Audio 基类 SetGain 只存 gainF2P6，派生类必须自调 Amplify 才生效（v1.0.0 此处遗漏，v1.1.0 修复） |
| ConsumeSample 返回 false 背压 | ESP8266Audio 内置机制，缓冲满时停止解码 |
| 32k 升采样到 44.1k | A2DP SBC 32k 耳机不支持，必须升采样 |
| 44.1k/48k 直发 | Bluedroid 协商 SBC 采样率，48k 自动协商 48k 直发无损（v1.4.1 测试并保留） |
| 起播预缓冲 32KB | open() 等 NET 攒到 32KB 再放行（3s 超时），避免起播 read 立即返回 0 误判 |
| 定点 Q16 重采样（v1.4.1） | 替代浮点线性插值，减少量化噪声 + 提速 |
| ConsumeLastGood 丢帧补偿（v1.4.1） | 段边界用前一帧数据渐弱填充，最多 5 帧，每次衰减 6dB |
| 一阶 IIR 抗混叠（v1.4.1） | DC gain=1.0，减少上采样高频镜像 |
| NET ringbuf 水位监控（v1.4.1） | 低于 10% 让出 CPU 给 fetchTask 灌数据 |
| WiFi 重连限流 10s（v1.4.1） | 去掉 delay(2000) 阻塞 loop() |
| TsDemux 段切换不 reset（v1.4.1） | 保留 pmtPid/audioPid + TS 对齐，减少段间空窗 |
| playlist 刷新自适应（v1.4.1） | targetDur≤3 时刷新间隔 1s（原 targetDur/2） |
| TS 读取缓冲 512→752 字节（v1.4.1） | 4 个 TS 包，减少残包处理 |
| 段失败跳过 5→2 次（v1.4.1） | 减少卡顿从 ~15s 到 ~4s |
| 重连失败切台 5→3 次（v1.4.1） | 减少等待从 ~30s 到 ~18s |

## 支持的音频格式

| 格式 | 支持 | 说明 |
|------|------|------|
| HTTP MP3 | ✅ | 蜻蜓 FM 等在线 MP3 流 |
| HTTP AAC | ✅ | 喜马拉雅 HLS AAC、国际 AAC 流（v1.4.0 起） |
| HTTP m3u8/HLS | ✅ | CNR/CRI TS 容器 HLS 流（v1.4.0 起 TsDemux 解复用） |
| HTTPS | ⚠️ | 软件说明书称 v1.4.0 起支持（`WiFiClientSecure` + `setInsecure()`，端口 443，握手 15s），用户手册写"暂不支持（mbedTLS in buffer 5120B 硬限制）"— 详见 [[ESP32网络音频转发蓝牙-用户使用说明书]] 内部分歧标注 |

## 预设电台（v1.4.1 增至 332 个）

| 分类 | 数量 | 容器/格式 |
|------|------|----------|
| 蜻蜓FM | 70 | 蜻蜓 HLS AAC（ls.qingting.fm） |
| 音乐 | 65 | 蜻蜓 MP3 直连 + 喜马拉雅 HLS AAC |
| 喜马拉雅 | 64 | 喜马拉雅 HLS AAC（live.xmcdn.com） |
| 省级 | 120 | HTTP TS 容器（satellitepull.cnr.cn） |
| 央广 | 2 | HTTP TS 容器（ngcdn*.cnr.cn） |
| 国广 | 5 | HTTP TS 容器（sk.cri.cn） |
| 国际 | 6 | AAC/MP3 |

序号 0 = 默认电台（`DEFAULT_STATION_IDX = 0`，北京交通广播 FM103.9）。

## 运行日志反映的问题（v1.4.0 基线）

据 [[ESP32网络音频转发蓝牙-v1.4.0运行日志]]：A2DP 多次退避重连后成功；央广多路电台 HLS"播放列表无媒体段"打开失败；可播放的广东音乐之声频发 `AAC decode error -15`；流结束后自动重连。

## v1.4.1 已知改进（新文档视角）

据 [[ESP32网络音频转发蓝牙-软件说明书]]，v1.4.1 引入 16 项变更（见上文"关键设计决策"末 13 项）。CLI/GUI 客户端新增给自动化与图形操作提供入口。

## 版本分歧与回滚说明

按用户决策：v1.4.0 是稳定基线，v1.4.1/v1.4.2 视为引入回归后回滚的目标。本 wiki 页面同时披露 v1.4.0（运行日志）与 v1.4.1（说明书）的事实记录，不裁决谁更优，并保留两套对应摘要页：

- v1.4.0 → [[ESP32网络音频转发蓝牙-v1.4.0运行日志]]
- v1.4.1 → [[ESP32网络音频转发蓝牙-软件说明书]] / [[ESP32网络音频转发蓝牙-用户使用说明书]]

> ⚠️ **这里有分歧，等我来裁**：v1.4.0 与 v1.4.1 的取舍——特别是 TsDemux 段边界、CLI/GUI 客户端、A2DP 熔断等改进是否能在 v1.4.0 基线上 backport，待用户拍板。

## 同库相关页面

- [[HLS流媒体协议]]：m3u8 + TS 分片流协议
- [[A2DP蓝牙音频协议]]：蓝牙音频传输协议
- [[ESP32网络音频转发蓝牙-v1.4.0运行日志]]
- [[ESP32网络音频转发蓝牙-软件说明书]]
- [[ESP32网络音频转发蓝牙-用户使用说明书]]

---
**内容来源**：`raw/v1.4.0版本输出内容.txt`、`raw/README_软件说明书.md`、`raw/用户使用说明书.md`
