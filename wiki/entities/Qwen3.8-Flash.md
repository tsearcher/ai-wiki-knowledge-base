# Qwen3.8-Flash

> 这页讲一个产品：阿里千问（Qwen）系列于 2026-08-26 发布并开源的轻量激活 MoE 大模型，性能对标 Claude Opus4.6 而价格仅为其 3%。

## 它是什么

阿里发布的千问系列最新模型，多模态混合专家（MoE）架构，采用下一代（Next）模型架构。核心特点是**总参数大、激活参数小**：Transformer 参数 125B，推理时仅激活 6B，以极低计算成本获得前沿性能。

## 架构特点

- **MoE 稀疏激活**：千亿级总参数仅激活 60 亿，是效率与成本优势的技术根源。
- **下一代训练方法**：仅完成预训练的 Base 模型即超过 3 倍其大小的 Qwen3.7-Plus 基座（SuperGPQA / GSM8K / SWEBench-Pretrain）。
- **后训练强化**：经后训练后在智能体任务上实现跃迁。

## 性能表现

- SWE-bench Pro（智能体编程）：领先 Claude Opus4.6 多达 9.1 分。
- CoWorkBench（长程专业任务）、Toolathlon Verified（真实工具调用）：超越 DeepSeek-V4-Flash。
- 综合性能超越 Opus4.6、接近 Opus4.8。

## 成本

- 训练成本较 Qwen3.7-Plus 降约 90%（九分之一资源）。
- 推理定价：输入 1 元 / 百万 Tokens，输出 3 元 / 百万 Tokens——为 Claude Opus4.6 的 3%。

## 获取方式

首发上线"千问办公"；开发者和企业可通过千问 AI 平台获取 API 服务；模型已开源。

## 相关

- [[Qwen3.8-Flash发布]]：本库收录的发布报道摘要。
- [[DeepSeek-R1]]：国产大模型对比参照。

---
**内容来源**：`raw/阿里开源Qwen3.8-Flash，性能超Opus4.6价格仅为其3%.md`
