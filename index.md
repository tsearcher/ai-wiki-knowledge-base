# 知识库目录（index.md）

> 全库目录。查阅时先在这里圈出相关页面，再只读那几页。页面之间用 `[[双链]]` 互链，每页页尾注明内容来自 `raw/` 的哪几份资料。
> 运转规则见 [[AGENTS]]（根目录 `AGENTS.md`）；干活日志见 `log.md`。

## 概念（concepts/）

| 页面 | 简介 |
|------|------|
| [本地 AI Wiki 知识库](concepts/本地AI-Wiki知识库.md) | 本地结构化 Markdown 软件版本归档库，打包自动录入、可 RAG 检索 |
| [语义化版本号](concepts/语义化版本号.md) | `vX.Y.Z` 版本号格式及打包命名应用 |
| [HLS 流媒体协议](concepts/HLS流媒体协议.md) | m3u8 播放列表 + 分段的流媒体协议 |
| [A2DP 蓝牙音频协议](concepts/A2DP蓝牙音频协议.md) | 蓝牙立体声音频传输协议 |
| [插电混动与 DM-i 技术](concepts/插电混动与DM-i技术.md) | PHEV 纯电/混动切换与比亚迪 DM-i 路线 |
| [好人条款与安全保障义务](concepts/好人条款与安全保障义务.md) | 民法典第 184/1198 条及店主帮扶案适用 |
| [双碳三新](concepts/双碳三新.md) | 研究院（抚顺石化）低碳技术工作板块 |
| [AI 赋能炼化优化](concepts/AI赋能炼化优化.md) | 研究院将 AI 用于炼化科研与生产优化 |
| [颗粒捕捉器 GPF](concepts/颗粒捕捉器GPF.md) | 汽油车颗粒捕捉器及低温短途堵塞问题 |
| [Markdown 标记语言](concepts/Markdown标记语言.md) | 轻量级标记语言，覆盖核心语法与 GFM/Mermaid/LaTeX 等扩展 |
| [端侧 AI](concepts/端侧AI.md) | 将 AI 模型直接在终端设备本地运行的技术路线，核心瓶颈为内存墙 |
| [具身智能](concepts/具身智能.md) | AI 嵌入物理实体，在真实环境中通过感知—理解—行动形成闭环 |

## 工具与人物（entities/）

| 页面 | 简介 |
|------|------|
| [project-packager Skill](entities/project-packager-Skill.md) | 项目打包归档 + 本地 AI Wiki 维护 Skill |
| [ESP32 网络音频转发蓝牙设备](entities/ESP32网络音频转发蓝牙设备.md) | 抓网络电台 HLS 经蓝牙 A2DP 转发的 ESP32 设备 |
| [比亚迪海狮 06 DM-i](entities/比亚迪海狮06-DM-i.md) | 极寒对比中被推荐的插电混动 SUV |
| [大众探岳 300TSI](entities/大众探岳300TSI.md) | 极寒对比中作为参照的燃油 SUV |
| [DeepSeek-R1](entities/DeepSeek-R1.md) | 深度求索开发的文本对话型 AI 助手 |
| [玄戒芯片](entities/玄戒芯片.md) | 小米自研芯片品牌，覆盖手机 SoC、AI 加速与智驾三大算力底座 |
| [Qwen3.8-Flash](entities/Qwen3.8-Flash.md) | 阿里开源 MoE 大模型，千亿参数仅激活 6B，价格仅 Opus4.6 的 3% |
| [DeepSeek Harness](entities/DeepSeek-Harness.md) | DeepSeek 官方 Agent 框架，"Everything is a Plugin"，本地运行 Web UI |

## 原始资料摘要（sources/）

| 页面 | 对应 raw 文件 |
|------|---------------|
| [project-packager 完整文件包](sources/project-packager完整文件包.md) | `可直接导入的完整 Skill 文件包.md` |
| [project-packager 跨平台安装与 Windows 批处理工具](sources/project-packager跨平台安装与Windows批处理.md) | `跨平台一键安装脚本和Windows 原生批处理打包工具.md` |
| [project-packager 增强版：打包归档与本地 AI Wiki](sources/project-packager增强版-本地AIWiki.md) | `项目打包归档并写入本地AI WIKI知识库.md` |
| [ESP32 网络音频转发蓝牙 v1.4.0 运行日志](sources/ESP32网络音频转发蓝牙-v1.4.0运行日志.md) | `v1.4.0版本输出内容.txt` |
| [ESP32 网络音频转发蓝牙 — 软件说明书](sources/ESP32网络音频转发蓝牙-软件说明书.md) | `README_软件说明书.md` |
| [ESP32 网络音频转发蓝牙 — 用户使用说明书](sources/ESP32网络音频转发蓝牙-用户使用说明书.md) | `用户使用说明书.md` |
| [研究院月生产经营例会书面汇报模板](sources/研究院月生产经营例会书面汇报模板.md) | `2026年研究院月生产经营例会书面汇报材料…(修订).docx` |
| [店主帮扶老人赔 1.9 万事件](sources/店主帮扶老人赔1.9万事件.md) | `店主帮扶老人赔1.9万…调解协议曝光….docx` |
| [抚顺极寒探岳 300TSI 对比海狮 06 DM-i 成本分析](sources/抚顺极寒探岳300TSI对比海狮06DM-i成本分析.md) | `抚顺极寒环境下探岳300TSI vs 海狮06 DM.docx` |
| [DeepSeek-R1 智能助手自述](sources/DeepSeek-R1智能助手自述.md) | `智能助手多功能.docx` |
| [Markdown 语法完全演示手册](sources/Markdown语法完全演示手册.md) | `sample.md` |
| [小米玄戒芯片三连发](sources/小米玄戒芯片三连发.md) | `「米芯」三连发：雷军五年花了 210 亿，归来已「不只手机」.md` |
| [第二届世界人形机器人运动会](sources/第二届世界人形机器人运动会.md) | `机器人运动会2.0，赛出了哪些新亮点？.md` |
| [2026 人形机器人新纪录之年](sources/2026人形机器人新纪录之年.md) | `2026，人形机器人的“新纪录”之年.md` |
| [Qwen3.8-Flash 发布](sources/Qwen3.8-Flash发布.md) | `阿里开源Qwen3.8-Flash，性能超Opus4.6价格仅为其3%.md` |
| [工作通知深度解读助手提示词](sources/工作通知深度解读助手提示词.md) | `工作通知深度解读助手 _ 高阶完整版提示词（标准Markdown）.md` |
| [DeepSeek Harness Windows 安装完全指南](sources/DeepSeek-Harness-Windows安装完全指南.md) | `DeepSeek Harness 在 Windows 上的安装、磁盘布局与排错完全指南.md` |
| [在线电台流媒体 URL 清单](sources/在线电台流媒体URL清单.md) | `在线电台流媒体URL清单.md` |
| [在线电台 URL — radio-browser API 完整集](sources/在线电台URL-radio-browser-API完整集.md) | `在线电台URL-radio-browser-API完整集.json` |
| [在线电台 URL — 格式化分级清单](sources/在线电台URL-格式化分级清单.md) | `电台_格式化.txt` |

## 原始资料清单（raw/，只读，按类目标签分组）

### 工作总结

1. `2026年研究院月生产经营例会书面汇报材料（书面汇报单位使用）(修订).docx`

### 工作日志

2. `v1.4.0版本输出内容.txt`
12. `README_软件说明书.md`
13. `用户使用说明书.md`

### 工作小窍门

9. `sample.md`

### 个人日记

（暂无）

### AI类技术资料

3. `可直接导入的完整 Skill 文件包.md`
4. `跨平台一键安装脚本和Windows 原生批处理打包工具.md`
5. `项目打包归档并写入本地AI WIKI知识库.md`
6. `智能助手多功能.docx`
16. `工作通知深度解读助手 _ 高阶完整版提示词（标准Markdown）.md`
17. `DeepSeek Harness 在 Windows 上的安装、磁盘布局与排错完全指南.md`

### 数智资讯

10. `「米芯」三连发：雷军五年花了 210 亿，归来已「不只手机」.md`
11. `机器人运动会2.0，赛出了哪些新亮点？.md`
14. `2026，人形机器人的“新纪录”之年.md`
15. `阿里开源Qwen3.8-Flash，性能超Opus4.6价格仅为其3%.md`
18. `在线电台流媒体URL清单.md`
19. `在线电台URL-radio-browser-API完整集.json`
20. `电台_格式化.txt`

### 生活常识

7. `店主帮扶老人赔1.9万：官方两次处理被指欠妥 调解协议曝光_协商_赔偿_索赔.docx`
8. `抚顺极寒环境下探岳300TSI vs 海狮06 DM.docx`

## 统计

- 原始资料：20 份（工作总结 1 / 工作日志 3 / 工作小窍门 1 / AI类技术资料 6 / 数智资讯 7 / 生活常识 2；个人日记 暂无）
- 概念页：12　工具/人物页：8　资料摘要页：20　合计 40 页（sources/ 内另有 3 份非 .md 衍生数据文件随本次新增）
- 最后编译：2026-09-10
