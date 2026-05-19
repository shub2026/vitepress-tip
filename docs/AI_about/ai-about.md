# 主流AI大模型提示词最佳实践指南

> 全面整理 OpenAI、Claude、Gemini、Llama、Mistral、DeepSeek、千问、智谱AI 等主流AI大模型的提示词技巧与实用模板

[![Documentation](https://img.shields.io/badge/文档-完整-green)](https://gitee.com/shub77/vitepress-tip)
[![Models](https://img.shields.io/badge/模型-8大主流-blue)](https://gitee.com/shub77/vitepress-tip)
[![Language](https://img.shields.io/badge/语言-中文-brightgreen)](https://gitee.com/shub77/vitepress-tip)
[![Status](https://img.shields.io/badge/状态-持续更新-yellow)](https://gitee.com/shub77/vitepress-tip)

---

## 📖 简介

本指南系统整理了当前主流AI大模型的提示词（Prompt）最佳实践，旨在帮助开发者和AI使用者快速掌握各模型的提示词技巧，提高AI交互效率和输出质量。

### 核心特点

- ✅ **全面覆盖**：涵盖8大主流AI模型系列（含国产模型）
- ✅ **场景丰富**：包含写作、代码、图像、数据分析、推理等主流使用场景
- ✅ **实用性强**：每个场景提供多个详细的中文提示词示例
- ✅ **参数指导**：提供各场景下的最佳配置参数建议
- ✅ **模板齐全**：提供可复用的提示词模板

---

## 🎯 快速导航

### 按模型查看

| 模型系列 | 代表模型 | 文档链接 | 特色能力 |
|---------|---------|---------|---------|
| **OpenAI** | GPT-4o, GPT-4, GPT-3.5, DALL-E | [查看指南](./openai-gpt-prompts.md) | 最强推理、图像生成、函数调用 |
| **Anthropic Claude** | Claude 3.5 Sonnet, Opus, Haiku | [查看指南](./anthropic-claude-prompts.md) | 长文本处理、安全对齐、角色扮演 |
| **Google Gemini** | Gemini 1.5 Pro, Flash | [查看指南](./google-gemini-prompts.md) | 多模态、超长上下文、研究摘要 |
| **Meta Llama** | Llama 3, Llama 2 | [查看指南](./meta-llama-prompts.md) | 开源免费、本地部署、可定制 |
| **Mistral AI** | Mistral 7B, Mixtral 8x7B | [查看指南](./mistral-prompts.md) | 代码生成、JSON输出、高效推理 |
| **DeepSeek** | DeepSeek-V2, DeepSeek-R1 | [查看指南](./deepseek-prompts.md) | 强大推理能力、代码生成、数学能力 |
| **千问(Qwen)** | Qwen-Max, Qwen-Plus, Qwen-Turbo | [查看指南](./qwen-prompts.md) | 中文能力强、长上下文、多模态 |
| **智谱AI GLM** | GLM-4, ChatGLM | [查看指南](./glm-prompts.md) | 中文优化、多模态支持、开源免费 |

### 按使用场景查看

| 使用场景 | 推荐模型 | 快速链接 |
|---------|---------|---------|
| **写作任务** | Claude > GPT-4 > Gemini | [写作提示词技巧](#写作任务提示词) |
| **代码开发** | GPT-4 > Claude > DeepSeek > Mistral | [代码提示词技巧](#代码开发提示词) |
| **图像生成** | DALL-E > Gemini | [图像提示词技巧](#图像生成提示词) |
| **数据分析** | GPT-4 > Gemini > Claude | [数据分析提示词](#数据分析提示词) |
| **推理任务** | GPT-4 > DeepSeek-R1 > Claude | [推理提示词技巧](#推理任务提示词) |
| **中文任务** | Qwen > GLM > DeepSeek | [国产模型优势](#国产模型特点) |

---

## 🇨🇳 国产模型特点

### DeepSeek（深度求索）

**核心优势**：
- ✅ 推理能力强：DeepSeek-R1在数学和逻辑推理上达到顶尖水平
- ✅ 代码生成优秀：DeepSeek-Coder系列在代码任务上表现出色
- ✅ 开源免费：可商用，可本地部署
- ✅ 中文能力强：对中文理解和生成优化

**推荐场景**：数学问题、逻辑推理、代码生成、算法实现

### 千问(Qwen)（阿里巴巴）

**核心优势**：
- ✅ 中文能力强：针对中文优化，理解和生成质量高
- ✅ 长上下文：Qwen-Plus/Turbo支持128K tokens
- ✅ 多模态支持：Qwen-VL支持图像理解
- ✅ 开源免费：Qwen开源版本可商用

**推荐场景**：中文写作、长文档分析、图文混合任务

### 智谱AI GLM（清华系）

**核心优势**：
- ✅ 中文能力强：针对中文优化
- ✅ 长上下文：GLM-4支持128K tokens
- ✅ 多模态支持：GLM-4V支持图像理解
- ✅ 开源免费：ChatGLM系列可商用

**推荐场景**：中文对话、图文分析、本地部署

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

**核心优势**：推理能力强、代码生成优秀、中文支持好

**提示词技巧**：
- 使用正确的聊天模板格式
- 提供详细指令（DeepSeek指令遵循能力中等）
- 少样本提示效果显著
- DeepSeek-R1擅长数学和逻辑推理

**配置建议**：
- 推理任务：temperature=0.2, top_p=0.9
- 代码生成：temperature=0.3-0.5
- 使用DeepSeek-Coder进行代码任务

📖 **详细指南**：[DeepSeek 提示词最佳实践](./deepseek-prompts.md)

---

### 千问(Qwen) 系列

**核心优势**：中文能力强、长上下文、多模态支持

**提示词技巧**：
- 使用系统消息（System Message）设定角色
- 提供详细指令（千问指令遵循能力中等）
- 少样本提示效果显著
- 中文任务表现优异

**配置建议**：
- 中文任务：temperature=0.3-0.5
- 长文档分析：使用Qwen-Plus/Turbo（128K上下文）
- 代码生成：使用Qwen2.5-Coder

📖 **详细指南**：[千问(Qwen) 提示词最佳实践](./qwen-prompts.md)

---

### 智谱AI GLM 系列

**核心优势**：中文优化、多模态、开源免费

**提示词技巧**：
- 使用系统消息设定角色和行为
- 提供详细指令（GLM指令遵循能力中等）
- 少样本提示效果显著
- GLM-4V支持图像理解

**配置建议**：
- 中文任务：temperature=0.3-0.5
- 图像分析：使用GLM-4V
- 本地部署：使用ChatGLM3-6B

📖 **详细指南**：[智谱AI GLM 提示词最佳实践](./glm-prompts.md)

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

| 场景 | 推荐模型 | 关键技巧 | 参数配置 |
|------|---------|---------|---------|
| 博客文章 | Claude > Qwen > GPT-4 | 提供详细大纲要求 | temperature=0.7 |
| 学术论文 | GPT-4 > GLM | 要求引用来源 | temperature=0.3 |
| 商业文案 | GPT-4 > Qwen | 明确目标受众 | temperature=0.8 |
| 创意故事 | Claude > GPT-4 | 角色扮演+情节要求 | temperature=0.9 |
| 中文写作 | Qwen > GLM > DeepSeek | 明确中文表达风格 | temperature=0.6-0.8 |

### 代码开发

| 场景 | 推荐模型 | 关键技巧 | 参数配置 |
|------|---------|---------|---------|
| 代码生成 | GPT-4 > DeepSeek > Mistral | 提供详细需求和示例 | temperature=0.2 |
| 代码审查 | Claude > GPT-4 | 明确审查维度 | temperature=0.3 |
| Bug修复 | GPT-4 > DeepSeek | 提供错误信息和代码片段 | temperature=0.1 |
| 代码翻译 | Mistral > DeepSeek | 明确源语言和目标语言 | temperature=0.3 |
| 算法实现 | DeepSeek-R1 > GPT-4 | 要求逐步推理 | temperature=0.2 |

### 图像生成

| 场景 | 推荐模型 | 关键技巧 | 参数配置 |
|------|---------|---------|---------|
| 写实图像 | DALL-E 3 | 详细描述光照、材质、构图 | - |
| 艺术插画 | DALL-E 3 | 明确艺术风格和色彩方案 | - |
| 图像编辑 | Gemini | 提供原图和修改要求 | - |
| 中文提示词 | Qwen-VL > Gemini | 用中文描述图像需求 | - |

### 数据分析

| 场景 | 推荐模型 | 关键技巧 | 参数配置 |
|------|---------|---------|---------|
| 数据解读 | GPT-4 > Gemini | 要求结构化输出 | temperature=0.4 |
| 可视化建议 | Gemini > GPT-4 | 推荐图表类型 | temperature=0.5 |
| 业务洞察 | GPT-4 > Qwen | 基于数据给出建议 | temperature=0.3 |
| 中文数据分析 | Qwen > GLM | 中文报告和洞察 | temperature=0.4 |

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
1. **中文任务**：优先选择Qwen或GLM
2. **数学推理**：优先选择DeepSeek-R1
3. **代码生成**：优先选择DeepSeek-Coder
4. **本地部署**：可选择ChatGLM3-6B或Qwen2.5-7B
5. **多模态任务**：可选择Qwen-VL或GLM-4V

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

- **2026-05-18**：初始版本发布，完成8大主流模型提示词指南
- **2026-05-18**：新增国产模型（DeepSeek、千问、智谱AI GLM）
- 包含GPT-4o/GPT-4/Claude 3.5/Gemini 1.5/DeepSeek-V2/Qwen-Max/GLM-4的详细提示词技巧
- 涵盖写作、代码、图像、数据分析、推理5大场景
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

**最后更新时间**：2026年5月18日  
**作者**：AI Engineering Team  
**版本**：v2.0（新增国产模型）
