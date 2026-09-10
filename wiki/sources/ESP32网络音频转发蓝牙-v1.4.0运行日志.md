# ESP32 网络音频转发蓝牙 v1.4.0 运行日志

> 这页是原始资料摘要：一台 ESP32 网络音频转发蓝牙设备 v1.4.0 固件的串口运行日志。

## 资料讲什么

`raw/v1.4.0版本输出内容.txt` 是 [[ESP32网络音频转发蓝牙设备]]（ESP32-WROVER-IE）固件 v1.4.0 的串口输出日志，记录开机自检、WiFi/蓝牙连接、网络电台 [[HLS流媒体协议]] 拉流与 [[A2DP蓝牙音频协议]] 转发全过程。作者陈志明，编译时间 2026-08-22。

## 日志要点

- **设备信息**：MAC `28:05:A5:35:54:78`；PSRAM 4096KB；MP3 预分配 30KB、AAC 预分配 128KB、电台数组 50×312B 均在 PSRAM；PCM ringbuf 131072B 在内部 RAM；按键 next=GPIO13、prev=GPIO14、clear=GPIO15（长按 3s）。
- **授权**：开机"未授权"，随后"已从 NVS 恢复授权"；License 未授权时播放锁定（`lic` 激活 / `clearlic` 清除）。
- **联网**：连 `home_wifi_5G`，IP 192.168.124.18；NTP 对时。
- **看门狗**：TWDT 配置 15s（panic），audioTask 卡死 15s 触发重启。
- **蓝牙**：A2DP 启动，设备名 `ESP32-Radio`，可发现模式；音频解码与音频任务运行于 Core 1；支持记忆直连（开机自动连上次设备，失败回退扫描）与配对模式（`pair`/`normal`）；AVRCP 耳机 play/pause/next/prev/stop 可用。
- **命令集**：play/list/save/next/prev/pause/del/vol/stop/wif/status/test/help/scan/restart/clear/pair/normal/lic/clearlic。
- **连接过程**：A2DP 多次连接尝试，状态机在 CONNECTING/CONNECTED/Disconnected 间切换，退避重连（5000ms、10000ms），最终连接成功（heap 稳定后约 37192）。
- **播放**：自定义 URL 播放央广西湖之声 HLS 直播，master → variant（选最低码率），预缓冲后启动；直发 48000Hz 不重采样。
- **电台切换**：逐个切央广 CNR 电台（中国交通广播、乡村之声、经典音乐、中华之声、维语、文艺、神州、中国之声、哈语、经济、华夏等），多数报"HLS 播放列表无媒体段"打开失败；广东音乐之声 FM99.3 可播放，但多次 `AAC decode error -15`；流结束后自动重连（退避 3000ms）。

## 备注

日志中反复出现 AAC 解码错误（code=-15），且大量央广电台 HLS 列表无媒体段，是本次日志反映的主要问题点。

---
**内容来源**：`raw/v1.4.0版本输出内容.txt`
