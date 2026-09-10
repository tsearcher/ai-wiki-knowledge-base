# A2DP 蓝牙音频协议

> 这页讲一个概念：A2DP（Advanced Audio Distribution Profile），蓝牙立体声音频传输协议。

## 概念说明

A2DP 用于在蓝牙设备间传输立体声音频。在 [[ESP32网络音频转发蓝牙设备]] 上，设备使用 Bluedroid 协议栈实现 A2DP，将解码后的音频转发给蓝牙耳机/音箱，蓝牙设备名 `ESP32-Radio`。

## 在 ESP32 设备上的表现

据 [[ESP32网络音频转发蓝牙-v1.4.0运行日志]]：

- 支持**记忆直连**：开机自动连上次设备，失败回退扫描。
- 支持**配对模式**：`pair` 暂停 A2DP 使设备可被手机/PC 搜索，`normal` 恢复正常模式。
- 连接状态机在 CONNECTING / CONNECTED / Disconnected 间切换，连接失败时退避重连（日志中见 5000ms、10000ms 退避）。
- 配合 **AVRCP** 实现耳机 play/pause/next/prev/stop 控制。
- 音频任务运行于 Core 1；日志中有"直发 48000Hz（不重采样，测试 Bluedroid 是否协商 48k SBC）"。

## 相关

- [[HLS流媒体协议]]：HLS 拉流解码后的音频经 A2DP 转发。
- [[ESP32网络音频转发蓝牙设备]]

---
**内容来源**：`raw/v1.4.0版本输出内容.txt`
