# 主流AI大模型提示词最佳实践指南

> 全面整理 OpenAI、Claude、Gemini、Llama、Mistral、DeepSeek、千问、GLM、Kimi、MiniMax、Hy3、ERNIE 等主流AI大模型的提示词技巧与实用模板

> 📊 **模型选型参考**：如需了解各模型性能对比与选型建议，请查看 [国产大模型选择指南](./domestic-llm-guide)

[![Documentation](https://img.shields.io/badge/文档-完整-green)](https://gitee.com/shub77/vitepress-tip)
[![Models](https://img.shields.io/badge/模型-12大主流-blue)](https://gitee.com/shub77/vitepress-tip)
[![Language](https://img.shields.io/badge/语言-中文-brightgreen)](https://gitee.com/shub77/vitepress-tip)
[![Status](https://img.shields.io/badge/状态-持续更新-yellow)](https://gitee.com/shub77/vitepress-tip)

---

## 📖 简介

本指南系统整理了当前主流AI大模型的提示词（Prompt）最佳实践，旨在帮助开发者和AI使用者快速掌握各模型的提示词技巧，提高AI交互效率和输出质量。

### 核心特点

- ✅ **全面覆盖**：涵盖12大主流AI模型系列（含7大国产模型）
- ✅ **场景丰富**：包含写作、代码、图像、数据分析、推理等主流使用场景
- ✅ **实用性强**：每个场景提供多个详细的中文提示词示例
- ✅ **参数指导**：提供各场景下的最佳配置参数建议
- ✅ **模板齐全**：提供可复用的提示词模板

---

## 🎯 快速导航

### 按模型查看

| 模型系列             | 代表模型                        | 文档链接                                  | 特色能力                         |
| -------------------- | ------------------------------- | ----------------------------------------- | -------------------------------- |
| **选型参考**         | 全模型对比                      | [查看指南](./domestic-llm-guide)          | 性能评分、价格对比、场景推荐     |
| **OpenAI**           | GPT-4o, GPT-4, GPT-3.5, DALL-E  | [查看指南](./openai-gpt-prompts.md)       | 最强推理、图像生成、函数调用     |
| **Anthropic Claude** | Claude 3.5 Sonnet, Opus, Haiku  | [查看指南](./anthropic-claude-prompts.md) | 长文本处理、安全对齐、角色扮演   |
| **Google Gemini**    | Gemini 1.5 Pro, Flash           | [查看指南](./google-gemini-prompts.md)    | 多模态、超长上下文、研究摘要     |
| **Meta Llama**       | Llama 3, Llama 2                | [查看指南](./meta-llama-prompts.md)       | 开源免费、本地部署、可定制       |
| **Mistral AI**       | Mistral 7B, Mixtral 8x7B        | [查看指南](./mistral-prompts.md)          | 代码生成、JSON输出、高效推理     |
| **DeepSeek**         | DeepSeek V4-Pro, V4-Flash       | [查看指南](./deepseek-prompts.md)         | 国产综合最强、编码第一、推理顶尖 |
| **千问(Qwen)**       | Qwen3.6-35B-A3B, Qwen3-235B     | [查看指南](./qwen-prompts.md)             | 开源生态标杆、本地部署、编程视觉 |
| **智谱AI GLM**       | GLM-5.1, GLM-5v-Turbo           | [查看指南](./glm-prompts.md)              | 中文理解最强、企业级服务、多模态 |
| **Kimi (月之暗面)**   | Kimi K2.6, K2.5                 | [查看指南](./kimi-prompts.md)             | 长文本之王、Agent国产最强        |
| **MiniMax**          | MiniMax M2.7, M2.5              | [查看指南](./minimax-prompts.md)          | 创意写作、极致性价比              |
| **腾讯混元 Hy3**     | Hy3 preview                     | [查看指南](./hy3-prompts.md)              | 快慢思考融合、Agent稳定、开源    |
| **百度文心 ERNIE**   | ERNIE 5.1                       | [查看指南](./ernie-prompts.md)            | Agent突出、搜索国内第一、创作强   |

### 按使用场景查看

| 使用场景     | 推荐模型                            | 快速链接                          |
| ------------ | ----------------------------------- | --------------------------------- |
| **写作任务** | Claude > MiniMax > ERNIE > GPT-4    | [写作提示词技巧](#写作任务提示词) |
| **代码开发** | DeepSeek V4-Pro > GPT-4 > Claude    | [代码提示词技巧](#代码开发提示词) |
| **图像生成** | DALL-E > Gemini > GLM-5v-Turbo     | [图像提示词技巧](#图像生成提示词) |
| **数据分析** | GPT-4 > Gemini > Hy3 > Claude       | [数据分析提示词](#数据分析提示词) |
| **推理任务** | DeepSeek V4-Pro > Hy3 > ERNIE       | [推理提示词技巧](#推理任务提示词) |
| **长文档处理** | Kimi K2.6 > DeepSeek V4-Pro > GLM-5.1 | [国产模型优势](#国产模型特点)   |
| **Agent/工具** | Kimi K2.6 > ERNIE 5.1 > Hy3 > GLM-5.1 | [国产模型优势](#国产模型特点)   |
| **中文任务** | GLM-5.1 > Qwen3.6 > ERNIE > DeepSeek | [国产模型优势](#国产模型特点)     |

---

## 🇨🇳 国产模型特点

### DeepSeek（深度求索）

**核心优势**：

- ✅ 国产综合最强：DS V4-Pro 综合评分 87，编码 89.8，均为国产第一
- ✅ 超长上下文：1M tokens 原生支持
- ✅ 混合注意力架构：1M 上下文 FLOPs 仅 V3 的 27%
- ✅ MIT 完全开源：1.6T 参数全球最大开源权重

**推荐场景**：代码生成、数学推理、长文档分析、技术问答

### 千问(Qwen)（阿里巴巴）

**核心优势**：

- ✅ 开源生态标杆：Apache 2.0，8B~397B 全系列覆盖
- ✅ MoE 架构高效：Qwen3.6-35B-A3B 仅 30B 激活，21GB 即可本地运行
- ✅ 多模态支持：Qwen-VL 支持图像理解
- ✅ 编程能力突出：编码评分 85

**推荐场景**：本地部署、中文编程、图文混合任务

### 智谱AI GLM（清华系）

**核心优势**：

- ✅ 中文理解国产最强：中文评分 93 分
- ✅ 百万级超长上下文：GLM-5.1 支持 1M+ tokens
- ✅ 全面均衡：MMLU 90 / 中文 93 / Agent 88，无明显短板
- ✅ 企业级服务：智谱为「全球大模型第一股」

**推荐场景**：企业应用、中文对话、多模态分析、通用任务

### Kimi（月之暗面）

**核心优势**：

- ✅ 长文本国产第一：长文理解评分 95，百万级上下文稳定可用
- ✅ Agent 能力最强：Agent 评分 92，国产最高
- ✅ 文件上传分析：支持 PDF/Word/Excel/PPT 等多格式文件直接分析
- ✅ 联网搜索：支持实时信息检索

**推荐场景**：长文档分析、Agent 编排、代码审查、研究报告

### MiniMax

**核心优势**：

- ✅ 创意写作国产最强：创意写作评分 88
- ✅ 极致性价比：API 价格 ¥1/¥4，不到其他旗舰 1/4
- ✅ 百万级上下文：M2.7 支持 1M tokens
- ✅ 推理速度快：仅 45B 激活参数

**推荐场景**：内容创作、营销文案、大规模批量调用、预算敏感场景

### 腾讯混元 Hy3

**核心优势**：

- ✅ 快慢思考融合：直觉思维 + 深度推理按需切换
- ✅ Agent 稳定可靠：在 CodeBuddy 内验证，可驱动 495 步复杂流程
- ✅ 极致性价比：输入 ¥1.2 / 输出 ¥4.0
- ✅ 推理能力强：清华大学数学博士资格考国内最高分

**推荐场景**：复杂推理、Agent 工作流、企业内部集成、技术问答

### 百度文心 ERNIE

**核心优势**：

- ✅ Agent 能力突出：τ³-bench 超越 DeepSeek V4-Pro
- ✅ 搜索国内第一：Arena 搜索榜全球第 4 / 国内第 1
- ✅ 创作能力卓越：意图洞察-内容创作闭环
- ✅ 极致效率：仅用 6% 的预训练成本

**推荐场景**：搜索增强问答、智能体任务、中文创作、内容优化

---

## 🚀 快速入门

### 提示词工程核心原则

#### 1️⃣ 提供清晰的指令

```markdown
❌ 不好的提示词：
"帮我写点东西"

✅ 好的提示词：
"你是一个资深技术博客作者。请写一篇关于【Docker容器化部署】的教程文章，
面向中级开发者，包含实际案例和代码示例，字数约1500字。"
```

#### 2️⃣ 使用少样本示例（Few-Shot）

```markdown
请提供以下格式的输出：

输入：今天天气真好
输出：{"sentiment": "positive", "confidence": 0.95}

输入：这个产品太糟糕了
输出：{"sentiment": "negative", "confidence": 0.92}

输入：[你的输入]
输出：
```

#### 3️⃣ 要求逐步推理（Chain-of-Thought）

```markdown
请逐步分析并解决以下问题：

问题：一个商店有120件商品，第一天卖了1/3，第二天卖了剩余的1/2，
问还剩多少件？

要求：

1. 先列出已知条件
2. 详细说明每一步计算过程
3. 给出最终答案
```

#### 4️⃣ 明确输出格式

```markdown
请将分析结果以JSON格式输出，包含以下字段：

- summary: 内容摘要
- key_points: 关键要点数组
- sentiment: 情感倾向（positive/neutral/negative）
- confidence: 置信度（0-1之间的小数）
```

---

## 📚 各模型提示词核心技巧对比

### OpenAI GPT 系列

**核心优势**：推理能力强、生态完善、支持多模态

**提示词技巧**：

- 使用系统消息（System Message）设定角色和行为规范
- 链式思考（CoT）："请逐步推理后给出答案"
- 少样本提示：提供3-5个示例
- 函数调用：结构化输出的最佳选择

**配置建议**：

- 事实性任务：temperature=0-0.3
- 创意任务：temperature=0.7-1.0
- 推理任务：temperature=0

📖 **详细指南**：[OpenAI GPT 提示词最佳实践](./openai-gpt-prompts.md)

---

### Anthropic Claude 系列

**核心优势**：长上下文（200K tokens）、安全对齐、角色扮演自然

**提示词技巧**：

- 使用XML标签结构化提示词：`<instructions>...</instructions>`
- 预填充响应：在Assistant部分预先填写开头
- 分离数据与指令：避免指令被误认为数据
- 角色提示：`你是一个资深的数据科学家...`

**配置建议**：

- 长文档分析：temperature=0.3-0.5
- 创意写作：temperature=0.7-0.9
- 设置max_tokens避免过长输出

📖 **详细指南**：[Anthropic Claude 提示词最佳实践](./anthropic-claude-prompts.md)

---

### Google Gemini 系列

**核心优势**：超长上下文（1M tokens）、多模态、研究能力

**提示词技巧**：

- 组合使用系统/上下文/角色提示
- 后退提示（Step-Back）：先考虑一般原则
- 思维树（ToT）：探索多个推理路径
- 多模态提示：文本+图像混合输入

**配置建议**：

- 事实性任务：temperature=0.1, top_p=0.9
- 创意任务：temperature=0.9, top_p=0.99
- 研究任务：要求提供来源链接

📖 **详细指南**：[Google Gemini 提示词最佳实践](./google-gemini-prompts.md)

---

### Meta Llama 系列

**核心优势**：开源免费、本地部署、可定制微调

**提示词技巧**：

- 使用正确的聊天模板格式（对Llama 3尤为重要）
- 明确指定任务类型和输出格式
- 少样本提示效果显著
- 注意：Llama对提示词格式较敏感

**配置建议**：

- 使用官方推荐的系统提示词
- temperature=0.1-0.3（事实任务）
- temperature=0.7-0.9（创意任务）

📖 **详细指南**：[Meta Llama 提示词最佳实践](./meta-llama-prompts.md)

---

### Mistral AI 系列

**核心优势**：代码生成能力强、JSON输出稳定、模型小巧高效

**提示词技巧**：

- 使用`[INST]...[/INST]`格式（Mistral特定）
- 明确请求JSON输出：`Just generate the JSON object without explanations`
- 代码生成：直接描述需求，Mistral理解能力强
- ⚠️ 注意：对提示词注入攻击较敏感

**配置建议**：

- 代码生成：temperature=0.2-0.5
- 对话任务：temperature=0.7
- 使用官方推荐的系统提示词增强安全性

📖 **详细指南**：[Mistral AI 提示词最佳实践](./mistral-prompts.md)

---

### DeepSeek 系列

**核心优势**：国产综合最强（87分）、编码第一（89.8分）、百万级上下文

**提示词技巧**：

- 使用简单的聊天模板格式（User/Assistant）
- 默认开启思维链（Thinking Mode），无需额外提示
- 提供详细指令和示例效果最佳
- V4-Pro 适合编码和推理，V4-Flash 适合日常对话

**配置建议**：

- 推理任务：temperature=0.2, top_p=0.9
- 代码生成：temperature=0.3-0.5
- 长文本分析：利用 1M 上下文优势

📖 **详细指南**：[DeepSeek 提示词最佳实践](./deepseek-prompts.md)

---

### 千问(Qwen) 系列

**核心优势**：开源生态标杆、MoE 高效架构、本地部署友好

**提示词技巧**：

- 使用系统消息（System Message）设定角色
- 提供详细指令，Qwen3.6 指令遵循能力显著提升
- 少样本提示效果显著
- Qwen3.6-35B-A3B 适合本地部署，Qwen3-235B 适合云端高精度

**配置建议**：

- 中文任务：temperature=0.3-0.5
- 本地部署：使用 Qwen3.6-35B-A3B（21GB 量化）
- 代码生成：使用 Qwen3.6 系列

📖 **详细指南**：[千问(Qwen) 提示词最佳实践](./qwen-prompts.md)

---

### 智谱AI GLM 系列

**核心优势**：中文理解国产最强（93分）、全面均衡、企业级服务成熟

**提示词技巧**：

- 使用系统消息设定角色和行为
- 提供详细指令，GLM-5.1 指令遵循能力显著提升
- 长文本任务充分发挥 1M+ 上下文优势
- GLM-5v-Turbo 支持图像理解

**配置建议**：

- 中文任务：temperature=0.3-0.5
- 企业应用：使用 GLM-5.1
- 多模态任务：使用 GLM-5v-Turbo

📖 **详细指南**：[智谱AI GLM 提示词最佳实践](./glm-prompts.md)

---

### Kimi 系列

**核心优势**：长文本国产第一（95分）、Agent 国产最强（92分）

**提示词技巧**：

- 利用文件上传功能分析 PDF/Word/Excel/PPT 等多格式文档
- 超长文档（数百页）一次性处理，充分发挥 1M 上下文优势
- 复杂 Agent 任务逐步编排，工具调用能力强
- 支持联网搜索获取最新信息

**配置建议**：

- 长文档分析：temperature=0.2-0.4
- Agent 任务：temperature=0.3-0.5
- 代码审查：temperature=0.2

📖 **详细指南**：[Kimi 提示词最佳实践](./kimi-prompts.md)

---

### MiniMax 系列

**核心优势**：创意写作国产最强（88分）、极致性价比（¥1/¥4）

**提示词技巧**：

- 创意写作和文案生成效果最佳，适合需要文采的任务
- 高 temperature（0.7-0.9）激发创意
- 利用超低价格进行大规模批量内容生成
- 百万级上下文可处理长篇内容

**配置建议**：

- 创意写作：temperature=0.7-0.9
- 营销文案：temperature=0.6-0.8
- 批量生成：利用价格优势实现规模效应

📖 **详细指南**：[MiniMax 提示词最佳实践](./minimax-prompts.md)

---

### 腾讯混元 Hy3 系列

**核心优势**：快慢思考融合、Agent 稳定可靠、极致性价比

**提示词技巧**：

- 复杂推理任务可先直觉判断再深度验证
- Agent 工作流稳定，支持数百步的复杂编排
- 多步拆解问题，逐步推进效果最佳
- 256K 上下文适合中等长度文档处理

**配置建议**：

- 复杂推理：temperature=0.1-0.3
- Agent 任务：temperature=0.2-0.4
- 技术写作：temperature=0.3-0.5

📖 **详细指南**：[Hy3 提示词最佳实践](./hy3-prompts.md)

---

### 百度文心 ERNIE 系列

**核心优势**：Agent 能力突出、搜索国内第一（1223分）、创作能力强

**提示词技巧**：

- 搜索增强任务效果最佳，可获取最新实时信息
- Agent 任务复杂编排，τ³-bench 超越 DeepSeek V4-Pro
- 中文创作和内容优化表现优秀
- 意图洞察-内容创作闭环，适合品牌营销场景

**配置建议**：

- 搜索问答：temperature=0.2-0.4
- Agent 任务：temperature=0.3-0.5
- 创意写作：temperature=0.7-0.9

📖 **详细指南**：[ERNIE 提示词最佳实践](./ernie-prompts.md)

---

## 🎓 提示词工程进阶技巧

### 1. 链式提示（Prompt Chaining）

将复杂任务分解为多个简单步骤：

```markdown
步骤1：提取关键信息
"请从以下文章中提取3-5个关键要点：\n[文章内容]"

步骤2：生成摘要
"基于以下关键要点，生成一段200字的摘要：\n[步骤1的输出]"

步骤3：翻译成其他语言
"将以下摘要翻译成英文：\n[步骤2的输出]"
```

### 2. 自我一致性（Self-Consistency）

让模型多次回答，选择最常见的结果：

```markdown
请独立回答以下问题3次，每次都逐步推理：
问题：一个数列的前三项分别是1, 4, 9，请推测第10项是多少？

第1次回答：
[推理过程]
答案：[答案1]

第2次回答：
[推理过程]
答案：[答案2]

第3次回答：
[推理过程]
答案：[答案3]

最终答案：[选择出现次数最多的答案]，因为自我一致性检验表明这是最可靠的答案。
```

### 3. 思维树（Tree of Thoughts）

探索多个推理分支：

```markdown
问题：[复杂问题]

请生成3种不同的解决思路：
思路1：[描述]
思路2：[描述]
思路3：[描述]

对每种思路进行评估：
思路1优缺点：...
思路2优缺点：...
思路3优缺点：...

最佳思路：[选择并详细展开]
```

### 4. ReAct（推理+行动）

结合工具使用：

```markdown
你是一个AI助手，可以使用以下工具：

- search[查询]：搜索网络信息
- calculator[表达式]：计算数学表达式

任务：分析2024年AI行业的发展趋势

思考：我需要先搜索2024年AI行业的相关信息
行动：search[2024年AI行业发展趋势]

观察：[搜索结果]

思考：基于搜索结果，我需要进行数据分析
...

最终答案：[综合结论]
```

---

## 📊 使用场景最佳实践

### 写作任务

| 场景     | 推荐模型              | 关键技巧          | 参数配置            |
| -------- | --------------------- | ----------------- | ------------------- |
| 博客文章 | Claude > MiniMax > GPT-4 | 提供详细大纲要求  | temperature=0.7     |
| 学术论文 | DeepSeek V4-Pro > GPT-4 > GLM | 要求引用来源      | temperature=0.3     |
| 商业文案 | ERNIE > GPT-4 > MiniMax | 明确目标受众      | temperature=0.8     |
| 创意故事 | MiniMax > Claude > GPT-4 | 角色扮演+情节要求 | temperature=0.9     |
| 中文写作 | GLM-5.1 > Qwen3.6 > ERNIE | 明确中文表达风格  | temperature=0.6-0.8 |

### 代码开发

| 场景     | 推荐模型                   | 关键技巧               | 参数配置        |
| -------- | -------------------------- | ---------------------- | --------------- |
| 代码生成 | DeepSeek V4-Pro > GPT-4 > Mistral | 提供详细需求和示例     | temperature=0.2 |
| 代码审查 | Claude > GPT-4 > Kimi      | 明确审查维度           | temperature=0.3 |
| Bug修复  | DeepSeek V4-Pro > GPT-4    | 提供错误信息和代码片段 | temperature=0.1 |
| 代码翻译 | Mistral > DeepSeek         | 明确源语言和目标语言   | temperature=0.3 |
| 算法实现 | DeepSeek V4-Pro > Hy3      | 要求逐步推理           | temperature=0.2 |

### 图像生成

| 场景       | 推荐模型              | 关键技巧                 | 参数配置 |
| ---------- | --------------------- | ------------------------ | -------- |
| 写实图像   | DALL-E 3              | 详细描述光照、材质、构图 | -        |
| 艺术插画   | DALL-E 3              | 明确艺术风格和色彩方案   | -        |
| 图像编辑   | Gemini                | 提供原图和修改要求       | -        |
| 中文提示词 | GLM-5v-Turbo > Gemini | 用中文描述图像需求       | -        |

### 数据分析

| 场景         | 推荐模型                 | 关键技巧         | 参数配置        |
| ------------ | ------------------------ | ---------------- | --------------- |
| 数据解读     | GPT-4 > Hy3 > Gemini     | 要求结构化输出   | temperature=0.4 |
| 可视化建议   | Gemini > GPT-4 > Hy3     | 推荐图表类型     | temperature=0.5 |
| 业务洞察     | GPT-4 > ERNIE > Hy3      | 基于数据给出建议 | temperature=0.3 |
| 中文数据分析 | GLM-5.1 > Qwen3.6 > ERNIE | 中文报告和洞察   | temperature=0.4 |

---

## ⚠️ 常见问题与解决方案

### Q1: 模型产生幻觉（编造信息）怎么办？

**解决方案**：

1. 在系统消息中添加诚实指令
2. 要求引用来源
3. 使用RAG（检索增强生成）
4. 降低Temperature

### Q2: 输出格式不符合要求？

**解决方案**：

1. 在提示词中明确指定输出格式
2. 提供输出格式示例
3. 使用少样本提示展示期望格式
4. OpenAI可使用函数调用强制格式化输出

### Q3: 输出过于冗长或简短？

**解决方案**：

1. 明确指定字数要求
2. 设置max_tokens参数限制长度
3. 在提示词中添加：`请控制在XX字以内`
4. 对于Claude，设置max_tokens并明确告知模型

### Q4: 如何提高推理任务的准确性？

**解决方案**：

1. 使用链式思考：`请逐步推理后再给出答案`
2. 提供类似问题的解题示例（少样本）
3. 使用自我一致性：多次推理取多数答案
4. 将复杂问题分解为多个简单步骤

### Q5: 国产模型如何选择？

**选择建议**：

1. **中文任务**：优先选择 GLM-5.1 或 Qwen3.6
2. **数学推理**：优先选择 DeepSeek V4-Pro 或 Hy3
3. **代码生成**：优先选择 DeepSeek V4-Pro
4. **长文档处理**：优先选择 Kimi K2.6
5. **Agent 任务**：优先选择 Kimi K2.6 或 ERNIE 5.1
6. **创意写作**：优先选择 MiniMax M2.7 或 ERNIE 5.1
7. **搜索增强**：优先选择 ERNIE 5.1
8. **本地部署**：可选择 Qwen3.6-35B-A3B 或 DeepSeek V4-Flash
9. **高性价比**：优先选择 MiniMax M2.7 或 DeepSeek V4-Flash
10. **多模态任务**：可选择 GLM-5v-Turbo 或 Hy3 preview

---

## 🔗 参考资料

### 官方文档

1. **OpenAI Platform Documentation**  
   https://platform.openai.com/docs/introduction  
   最权威的API文档，包含模型介绍、API参考、最佳实践。

2. **Anthropic Documentation**  
   https://docs.anthropic.com/  
   Claude的官方API文档，包含模型介绍、API参考、最佳实践。

3. **Google Gemini API Documentation**  
   https://ai.google.dev/gemini-api/docs  
   Gemini的官方API文档，包含模型介绍、API参考、快速入门。

4. **DeepSeek Official Documentation**  
   https://platform.deepseek.com/docs  
   DeepSeek的官方API文档。

5. **千问(Qwen) 阿里云文档**  
   https://help.aliyun.com/zh/model-studio/developer-reference/api-reference  
   千问的官方API文档。

6. **智谱AI 开放平台文档**  
   https://open.bigmodel.cn/dev/api  
   智谱AI的官方API文档。

7. **月之暗面 Moonshot AI 开放平台**  
   https://platform.moonshot.cn/docs  
   Kimi的官方API文档。

8. **MiniMax 开放平台**  
   https://platform.minimax.chat/documentation  
   MiniMax的官方API文档。

9. **腾讯混元大模型文档**  
   https://cloud.tencent.com/product/hunyuan  
   腾讯混元的云产品文档。

10. **百度千帆大模型平台**  
    https://cloud.baidu.com/doc/WENXINWORKSHOP/index.html  
    百度文心ERNIE的API文档。

### 社区资源

1. **Prompt Engineering Guide**  
   https://www.promptingguide.ai/  
   全面的提示词工程指南，包含各种技术和案例。

2. **Awesome ChatGPT Prompts**  
   https://github.com/f/awesome-chatgpt-prompts  
   丰富的ChatGPT提示词示例，涵盖各种角色和场景。

3. **Hugging Face Transformers Documentation**  
   https://python.langchain.com/  
   如果需要在应用中集成AI API，LangChain是非常好的框架。

### 相关论文

1. **"Language Models are Few-Shot Learners"** (Brown et al., 2020)  
   介绍了GPT-3和少样本学习的能力。

2. **"Chain-of-Thought Prompting Elicits Reasoning in Large Language Models"** (Wei et al., 2022)  
   提出思维链提示词技术，显著提升推理能力。

3. **"Large Language Models are Zero-Shot Reasoners"** (Kojima et al., 2022)  
   发现简单的"Let's think step by step"就能激活推理能力。

4. **"Self-Consistency Improves Language Models as Mathematical Problem Solvers"** (Wang et al., 2022)  
   提出自我一致性方法，通过多次采样提升准确性。

---

## 📝 更新日志

- **2026-05-31**：重构索引页，新增 Kimi / MiniMax / Hy3 / ERNIE 四大国产模型
- **2026-05-31**：更新 DeepSeek→V4 / Qwen→Qwen3.6 / GLM→GLM-5.1 模型版本
- **2026-05-18**：初始版本发布，完成基础8大主流模型提示词指南
- 涵盖写作、代码、图像、数据分析、推理等场景
- 提供丰富的实用示例和可复用模板

---

## 🤝 贡献与反馈

如果你发现任何错误或有改进建议，欢迎：

- 提交Issue进行讨论
- 提交Pull Request贡献内容
- 分享你的提示词使用技巧

---

## 📄 许可证

本文档采用 MIT 许可证。可自由使用、修改和分发。

---

**最后更新时间**：2026年5月31日  
**作者**：AI Engineering Team  
**版本**：v3.0（重构为12大模型，更新至最新版本）
