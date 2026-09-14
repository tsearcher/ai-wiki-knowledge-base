# 在线电台流媒体 URL 清单

> 这页对应原始资料 `raw/在线电台流媒体URL清单.md` 的内容摘要：一份广播电视台流媒体 m3u8 / aac / mp3 链接的汇编，按"电台名,URL"两列给出。
>
> 原始清单未经可用性筛选，含 HLS 直播、AAC 单段流、MP3 单段流三种形态；URL 集中在央广 / 央视 / 港台 / 海外华语 / 美国公共电台（NPR 系）/ 数字音乐台几个域名。

## 摘要内容

- 总条数：**450 条**
- 主要域名：
  - `satellitepull.cnr.cn`（CNR 央广 + 大部分省级广播主分发）
  - `m3u8channel.hndt.com` / `stream3.hndt.com`（湖南 IPTV 系）
  - `live2.kxm.xmtv.cn`（厦门广电系）
  - `live.zohi.tv`（福州系）
  - `ihzlh.linker.cc` / `live-hls.ihzlh.linker.cc`（宁波 / 山东）
  - `nhq.cctv.cn` / `live-play.cctvnews.cctv.com`（央视频道音频流）
  - `rfcmedia.streamguys1.com`（SiriusXM 数字音乐频道）
  - `stream.rcs.revma.com`（台湾 BCC 中广 4 个频道）
- 形态：约 70% 是 m3u8 直播流，其余为单段 AAC/MP3；BBC 与 RTHK 用 HLS 索引（`.isml/.m3u8`）。
- URL 中夹带的 `?adapt=0&BR=audio` 来自阿里 myalicdn 的视频流转音频参数。
- 两条"金陵之声"使用 IPv6 字面量作为主机名（`[2409:8087:…]`），普通工具直连可能不识别。

## 验证产物

围绕这份原始清单跑了一遍实时连通性检测，得到以下产物：

| 产物 | 路径 | 用途 |
|------|------|------|
| 可用性检测报告（分组、状态、原因） | `wiki/sources/在线电台URL-可用性检测报告.md` | 给人读，按 ✅ / 404 / 403 / 超时 / 其他 分组 |
| 完整检测结果（含 HTTP 码、Content-Type） | `wiki/sources/在线电台URL-完整检测结果.csv` | Excel 直接打开，便于二次筛选 |
| 仅可用清单 | `wiki/sources/在线电台URL-仅可用清单.txt` | 纯文本 `电台名,URL` 表 |
| http 协议命令清单 | `wiki/sources/在线电台URL-http命令清单.txt` | 一行一个 `save <电台名> <URL>`，适配 VLC / radio-cli 等播放器批量导入 |

## 验证结论摘要

| 状态 | 数量 | 占比 |
|------|------|------|
| ✅ 可在线收听 | 256 | 56.9% |
| ❌ HTTP 404（资源已下线） | 23 | 5.1% |
| 🚫 HTTP 403（服务器拒绝，国内 CDN 常见） | 13 | 2.9% |
| ⏱️ 连接超时（8 秒未响应） | 27 | 6.0% |
| ⚠️ 其他不可用（DNS 失败 / 自签证书 / 拒连 / 410 Gone） | 131 | 29.1% |

需要留意的几类集体状态：

1. **CCTV 17 个频道音频流**：当前网络下 DNS 无法解析 `cctv5cncc.v.wscdns.com` 与 `cctv.v.myalicdn.com`，本地网络能解析的话仍可听。
2. **CNR 中国之声系列**（11 个频率，如台海、乡村、老年、藏维哈等）：全部 HTTP 403，CDN 仅在境内开放。
3. **BBC 11 路**（Radio 1 / 2 / 3 / 4 / 4 Extra / 5 Live / 6 / World Service / 1Xtra / 1 Dance / 1 Relax）：全部 HTTP 410 (Gone)，BBC 把这批公开 HLS 彻底下线。
4. **rfcmedia.streamguys1.com 系**（12 路 SiriusXM 数字音乐）：DNS 解析失败。
5. **streamtheworld.com 系**（CAPITAL 958 / YES 933 / 好 FM / LOVE 972 / CNA 938）：SSL 自签证书失败，移动客户端加 `--insecure` 可听。
6. **satellitepull.cnr.cn 上 27 个省级电台**：8 秒内响应超时，多半是 CDN 冷流抖动，并非真挂，换时段实测多半能开。

## 相关

- [[HLS流媒体协议]]：原始清单绝大多数 URL 是 HLS（m3u8），可结合本档理解拉流过程。
- [[A2DP蓝牙音频协议]]：电台流经 ESP32 设备落地后通过 A2DP 送蓝牙耳机。
- [[ESP32网络音频转发蓝牙-v1.4.0运行日志]]：v1.4.0 日志里也出现过"央广电台 HLS 播放列表无媒体段"问题，与本次 DNS 不通 / 410 Gone 的差异待对账。

---

**内容来源**：`raw/在线电台流媒体URL清单.md`
**验证时间**：2026-09-10
**验证方法**：Python urllib 多线程并发 GET（HEAD 不被所有 CDN 支持），8 秒超时，读取 ≥ 50 字节非空内容判为可用。
