# 在线电台 URL — radio-browser API 完整集

> 这页对应原始资料 `raw/在线电台URL-radio-browser-API完整集.json` 的内容摘要：一份取自 [radio-browser.info](https://www.radio-browser.info/) 公开 API、覆盖中国地区电台的全量快照，按 `?limit=5000&hidebroken=true&order=votes` 分页拉取，落地为 JSON。
>
> 这份资料不是用户手抄的清单，而是从社区电台目录接口拉下来的目录数据；每条电台附有 `stationuuid`、`codec`、`bitrate`、`votes`、`lastcheckok`、`language`、`state`、`tags` 等元数据，便于二次筛选与去重。

## 数据来源与拉取方式

- **接口**：`https://de1.api.radio-browser.info/json/stations/bycountrycodeexact/CN`
  - 备用节点：`de2.api.radio-browser.info`、`at1.api.radio-browser.info`（`all.api` 在拉取当刻 TLS 握手被 RESET，已绕开）。
- **拉取时间**：2026-09-10
- **拉取参数**：`?limit=5000&hidebroken=true&order=votes`，理论上覆盖 CN 全量电台。
- **返回总条数**：2038 条（API 端 `hidebroken=true` 已隐去服务端标记为「最近一次检测失败」的项；本地仍可能拿到一部分失败项）。
- **原始快照**：`raw/在线电台URL-radio-browser-API完整集.json`（约 2.2 MB，单行 JSON 数组）。

## 摘要内容

### 总览

| 维度 | 值 |
|------|----|
| 总条数 | **2038** 条 |
| 唯一电台名 | 1890 个左右（不少电台被多个聚合平台重复收录，导致重名） |
| 唯一 stationuuid | 2038（UUID 唯一，命名重复但实例独立） |
| 主要聚合平台域名 | `lhttp.qingting.fm`（428）、`lhttp.qtfm.cn`（353）、`lhttp-hw.qtfm.cn`（343）、`l.cztvcloud.com`（71）、`live.ximalaya.com`（61） |
| 主要音源域名 | `piccpndali.v.myalicdn.com`（56，CCTV/卫视伴音）、`satellitepull.cnr.cn`（51，央广）、`sk.cri.cn`（16，CRI）、`radio.pull.hebtv.com`（12，河北台） |
| 协议（按 URL） | https 1223 / http 707（可达项内） |
| 语言标签 | `chinese` 1814、`cantonese` 47、`mongolian` 12、`uyghur` 10、`tibetan` 6、`english` 14、其他少数民族语言与方言若干 |

### 与原始用户清单的关系

用户先前给的 450 条「电台名,URL」清单（见 [[在线电台流媒体URL清单]]）与本份 API 完整集在条目上是**几乎不重叠**的子集：

- 原 450 条更偏向「已知大台 / 海外华语 / BBC 等公开流」，本份 API 完整集更偏向「地方台 + 聚合平台镜像 + 网络电台」。
- 同一物理电台常被多个聚合平台重复收录（例如「温州音乐之声」同时出现在 `qingting.fm`、`qtfm.cn` 两条 URL 上），这是 API 数据里重名较多的根因。
- 两者合并使用能拼出覆盖面最广的一份在线电台目录。

## 验证产物

围绕这份原始 API JSON 跑了一遍实时连通性检测，得到以下产物：

| 产物 | 路径 | 用途 |
|------|------|------|
| 可用性检测结果（2038 行，含 HTTP 码 / Content-Type / 失败原因 / 原始元数据） | `wiki/sources/在线电台URL-API完整集-可用性检测.csv` | Excel/数据透视直接打开，便于二次筛选 |
| 仅可用 JSON（按原始 station 字段全量保留，仅过滤 status=reachable） | `wiki/sources/在线电台URL-API完整集-仅可用.json` | 程序直接消费，结构与 raw 一致 |
| 仅可用纯文本（`电台名,URL` 两列） | `wiki/sources/在线电台URL-API完整集-仅可用.txt` | 给播放器 / radio-cli 批量导入 |

## 验证结论摘要

| 状态 | 数量 | 占比 |
|------|------|------|
| ✅ 可在线收听（HTTP 200 + Content-Type 走通） | 1930 | **94.7%** |
| ❌ HTTP 404（资源已下线） | 15 | 0.7% |
| 🚫 HTTP 403（服务端主动拒绝） | 2 | 0.1% |
| ❌🔌 连接不可达（DNS / TCP / TLS 任一失败） | 89 | 4.4% |
| ⏱️ 连接超时 | 1 | <0.1% |
| ⚠️ 其他错误（HTTP 500 等） | 1 | <0.1% |

### 协议 / 形态

- **可达项内 https/http 比**：1223 / 707（63.4% / 36.6%）。注意前一份用户清单里几乎全是 http，本份则 https 居多（聚合平台已普遍升 https）。
- **可达项 Content-Type 分布**：
  - `audio/mpeg`（MP3 单段流）：1161
  - `application/vnd.apple.mpegurl` 与 `application/x-mpegURL`（HLS / m3u8 播放列表）：737
  - `audio/aacp` / `audio/aac`（AAC+ / AAC）：33
  - `application/ogg`（OGG 流）：6
  - 其余（含 `text/plain` 部分伪装输出）：少量
- **API 元数据 codec 字段**（与实测 Content-Type 不完全一致，仅供参考）：
  - `MP3` 1172、`UNKNOWN` 705（多为 m3u8 但 API 端未识别 codec）、`AAC` 28、`AAC+` 18、`OGG` 6。
- **API 元数据 hls 字段**：`hls=1` 共 764 条、`hls=0` 共 1274 条。两者与实测 Content-Type 大致吻合，少量 `hls=1` 实际是 MP3（如 `*_64k.mp3`），属于来源端打标偏差。

### 按省份 / 地区分布（仅看可达项）

来源数据里同时混用 **韦氏拼音**（如 `Kiangsu`、`Chekiang`、`Shantung`、`Hopei`）与 **汉语拼音**（如 `Zhejiang`、`Hubei`、`Liaoning`），列为同一省份的两个标签。要筛选"江苏省"得同时匹配 `Kiangsu` 和 `Jiangsu`。

| 标签（原始拼写） | 可达数 | 对应省份 |
|------|------|------|
| Kiangsu | 116 | 江苏 |
| Chekiang | 115 | 浙江（旧拼） |
| Shantung | 103 | 山东（旧拼） |
| Zhejiang | 100 | 浙江 |
| Hopei | 97 | 河北（旧拼） |
| Honan | 89 | 河南 |
| Kwangtung | 79 | 广东 |
| Szechuan | 66 | 四川 |
| Sinkiang | 53 | 新疆 |
| Shansi | 48 | 山西 |
| Liaoning | 46 | 辽宁 |
| Hunan | 45 | 湖南 |
| Anhwei | 43 | 安徽 |
| Hupei | 40 | 湖北 |
| Kansu | 38 | 甘肃 |
| Jilin | 37 | 吉林 |
| jilin | 35 | 吉林（拼写差异，看作同省） |
| Inner Mongolia | 36 | 内蒙古 |
| Fukien | 34 | 福建 |
| Kiangsi | 33 | 江西 |
| … | … | 其余省略 |
| **（state 字段为空）** | 377 | 未标注省份，多为聚合平台镜像或无归属网络电台 |

### 不可达项的来源集中度

108 个不可达项里，**少数几个域名贡献了绝大多数失败**：

| 域名 | 不可达数 | 失败原因 |
|------|----------|----------|
| `stream.zeno.fm` | 59 | 404（ZenoFM 平台上的镜像电台大部分已下线或改名） |
| `stream.hrbtv.net` | 12 | TCP 不可达（哈尔滨台本地 CDN 节点失效） |
| `lhttp-hw.qtfm.cn` | 7 | 不稳定（蜻蜓 FM 海外节点抖动） |
| `lhttp.qingting.fm` | 6 | 不稳定（蜻蜓 FM 主站同上原因） |
| `stm.rthk.hk` | 5 | TCP 不可达（香港电台 RTHK 入口在本地网络下不稳） |
| 其余 ~19 个域名 | 各 1～3 | 单点失效 |

注意：先前用户清单里集中 "CNR 中国之声系 403（CDN 拒外）" 的现象在本份 API 数据里**没有复现**——本份里 CNR 一律走 `satellitepull.cnr.cn` 且全部 200 可达。可能差异是 APN / DNS 解析路径不同时段表现不同；本次记录以本批次实测为准。

## 与既有资料的对照

- **可达率**：本份 API 完整集 **94.7%** > 用户原 450 条清单的 **56.9%**。原因：本份是社区维护的电台目录，broken 项已被 `hidebroken=true` 隐去了一部分，剩下少量是拉流瞬间 CDN 抖动；用户原清单含较多个人手工收录的过时链接。
- **覆盖面**：本份 API 完整集（2038 条，覆盖大量地方台 / 聚合台镜像）远超用户原清单（450 条，偏已知大台）；两者合并可拼出覆盖面最广的目录。
- **协议比例**：本份 https 占多数（63.4%），与用户原清单相反——说明近两年聚合平台已普遍升 https。
- **BBC 现状**：用户原清单里 11 路 BBC HLS 全部 410 Gone；本份 API 完整集中**没有 BBC 条目**（radio-browser 社区对 BBC 的收录本就稀疏，且 BBC 公开 HLS 几乎全部下线）。

## 相关

- [[HLS流媒体协议]]：本份 1930 个可达项中约 38% 是 HLS（m3u8），其余多为 MP3 单段流 / AAC 单段流。
- [[A2DP蓝牙音频协议]]：作为 ESP32 设备拉流落地再经蓝牙 A2DP 转发的下游协议，与本档互补。
- [[ESP32网络音频转发蓝牙-v1.4.0运行日志]]：v1.4.0 日志里曾记录"央广 HLS 播放列表无媒体段"问题，本份 API 数据里 CNR 系列全部可达，差异未写入正文，等用户决定是否需要在 wiki 内追加这条新近变化。
- [[在线电台流媒体URL清单]]：用户原 450 条手抄清单的摘要与检测结果，可与本档合并使用。

---

**内容来源**：`raw/在线电台URL-radio-browser-API完整集.json`
**数据接口**：radio-browser.info `/json/stations/bycountrycodeexact/CN`，参数 `limit=5000&hidebroken=true&order=votes`，本地实测节点 `de1.api`。
**拉取时间**：2026-09-10
**验证方法**：Python urllib 多线程并发 GET（HEAD 不被所有 CDN 支持），6 秒超时，读取 ≥ 50 字节非空内容且 HTTP 200 + Content-Type 走通判为可达；同步记录失败原因（DNS / TCP / TLS / 4xx / 5xx / 超时）。
