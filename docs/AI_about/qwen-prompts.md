# 千问(Qwen) 提示词最佳实践指南

> 掌握 Qwen-Max、Qwen-Plus、Qwen-Turbo 的提示词技巧，充分发挥阿里云通义千问的强大能力

![Qwen Logo](https://img.shields.io/badge/Qwen-Max%2FPlus-blue)
![Status](https://img.shields.io/badge/状态-已完成-green)

---

## 1. 模型概述

### 1.1 模型版本与特点

| 模型            | 发布时间   | 上下文窗口  | 核心能力           | 适用场景                     |
| --------------- | ---------- | ----------- | ------------------ | ---------------------------- |
| **Qwen-Max**    | 2024年4月  | 32K tokens  | 最强推理能力       | 复杂推理、学术研究、代码生成 |
| **Qwen-Plus**   | 2024年4月  | 128K tokens | 平衡性能和成本     | 通用任务、长文档处理         |
| **Qwen-Turbo**  | 2024年4月  | 128K tokens | 高速度、低成本     | 大规模应用、实时对话         |
| **Qwen-72B**    | 2023年11月 | 32K tokens  | 开源版本最强       | 本地部署、微调               |
| **Qwen-14B/7B** | 2023年11月 | 32K tokens  | 轻量级、可本地部署 | 边缘计算、移动端             |

### 1.2 核心优势

✅ **中文能力强**：针对中文优化，理解和生成质量高  
✅ **长上下文**：Qwen-Plus/Turbo支持128K tokens  
✅ **代码生成优秀**：Qwen2.5-Coder系列在代码任务上表现突出  
✅ **多模态支持**：Qwen-VL支持图像理解  
✅ **开源免费**：Qwen开源版本可商用，可本地部署

### 1.3 限制与注意事项

⚠️ **英文能力**：虽然支持英文，但能力不如中文  
⚠️ **API速率限制**：有每分钟/每天的调用次数限制  
⚠️ **部署资源要求**：72B参数模型需要多GPU或高内存  
⚠️ **指令遵循能力中等**：不如GPT-4，需要更详细的提示词  
⚠️ **开源版本更新慢**：API版本通常先于开源版本更新

---

## 2. 提示词基础

### 2.1 千问(Qwen)提示词的基本结构

千问使用标准的OpenAI格式（如果通过阿里云API调用）。

#### 使用阿里云Dashscope SDK（推荐）

```python
import dashscope
from dashscope import Generation

dashscope.api_key = "YOUR_API_KEY"

# 单次对话
response = Generation.call(
    model='qwen-max',
    prompt='请解释什么是机器学习。'
)

print(response.output.text)
```

#### 使用OpenAI兼容格式（更通用）

```python
import openai

client = openai.OpenAI(
    api_key="YOUR_DASHSCOPE_API_KEY",
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1"
)

# 单次对话
response = client.chat.completions.create(
    model="qwen-max",
    messages=[
        {"role": "system", "content": "你是一个有用的助手。"},
        {"role": "user", "content": "请解释什么是机器学习。"}
    ]
)

print(response.choices[0].message.content)
```

### 2.2 使用Ollama（本地运行开源版本）

Qwen开源版本可以在Ollama上运行。

```bash
# 安装Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 运行Qwen2.5（需要较大内存）
ollama run qwen2.5:72b

# 运行Qwen2.5-Coder（代码专用）
ollama run qwen2.5-coder:32b
```

#### Python代码示例

```python
import ollama

# 单次对话
response = ollama.chat(
    model='qwen2.5:72b',
    messages=[
        {'role': 'user', 'content': '请解释什么是过拟合（overfitting）。'}
    ]
)
print(response['message']['content'])
```

### 2.3 核心提示词技巧

#### ✅ 技巧1：使用系统消息（System Message）

```python
response = client.chat.completions.create(
    model="qwen-max",
    messages=[
        {"role": "system", "content": "你是一位资深的技术博客作者，擅长将复杂的技术概念用通俗易懂的语言表达出来。"},
        {"role": "user", "content": "请写一篇关于Docker容器化部署的技术博客文章。"}
    ]
)
```

#### ✅ 技巧2：提供详细指令

千问的指令遵循能力中等，需要更详细、更明确的指令。

```python
prompt = """你是一位资深的技术博客作者，擅长将复杂的技术概念用通俗易懂的语言表达出来。

任务：请写一篇关于「使用Docker容器化部署Python应用」的技术博客文章。

文章要求：
1. 目标读者：中级开发者（有Python基础，了解基本Linux命令）
2. 字数：2000-2500字
3. 包含以下部分：
   - 引言：为什么需要容器化（3-5个痛点）
   - Docker基础概念简介（镜像、容器、Dockerfile）
   - 实战：容器化一个Flask应用（完整代码示例）
   - Dockerfile最佳实践（5-7条）
   - docker-compose多服务编排（示例：Web + Redis + PostgreSQL）
   - 生产环境部署注意事项（安全、监控、日志）
   - 总结与延伸阅读
4. 每个部分都包含代码示例（Python或Bash）
5. 代码需要详细注释
6. 风格：专业但亲和，避免过于学术化
7. 输出格式：Markdown

非常重要：请确保文章结构清晰，代码可直接运行。"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

#### ✅ 技巧3：少样本提示（Few-Shot）

```python
prompt = """我将给你展示情感分析的示例，然后你分析新句子。

示例1：
输入：这个产品真的太棒了，超出我的预期！
输出：{"sentiment": "positive", "confidence": 0.95, "reason": "用户使用了'太棒了'、'超出预期'等正面词汇。"}

示例2：
输入：质量一般，性价比不高，不推荐购买。
输出：{"sentiment": "negative", "confidence": 0.88, "reason": "用户明确指出'不推荐购买'，且提到性价比不高。"}

示例3：
输入：还算可以吧，没什么特别的。
输出：{"sentiment": "neutral", "confidence": 0.65, "reason": "用户没有明确表达满意或不满，态度中立。"}

现在请分析：
输入：质量太差了，浪费钱。
输出："""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

#### ✅ 技巧4：要求逐步思考（Chain-of-Thought）

```python
prompt = """请解决以下逻辑推理问题。在给出最终答案之前，请先逐步分析。

问题：所有的猫都是动物。有些动物会游泳。问：是否所有的猫都会游泳？

请按以下步骤思考：

1. **列出已知前提**
   - 前提1：所有的猫都是动物。
   - 前提2：有些动物会游泳。

2. **分析逻辑关系**
   - 前提1建立了"猫"和"动物"的包含关系。
   - 前提2只说明"有些"动物会游泳，不是"所有"动物。

3. **检查是否能推导出结论**
   - 我们知道猫是动物，但前提2只说"有些"动物会游泳。
   - "有些"不代表"所有"。

4. **寻找反例**
   - 如果"会游泳的动物"指的是鱼、海豚等，那么猫不在其中。
   - 所以，不能得出"所有的猫都会游泳"的结论。

5. **得出结论**
   - 最终答案：不能得出"所有的猫都会游泳"的结论。
   - 正确回答是：不确定/无法确定。

现在，请按照上述步骤，详细展示你的推理过程。"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## 3. 写作任务提示词

### 3.1 文章写作

#### 示例：技术博客文章

**提示词**：

```python
prompt = """你是一位资深的技术作家，擅长撰写深度技术分析和教程。
你的文章逻辑清晰、例证丰富、适合中级到高级开发者阅读。

任务：请撰写一篇关于「微服务架构中的分布式事务管理」的深度技术文章。

关键要点：
1. 分布式事务的挑战（CAP定理、网络分区等）
2. 常见解决方案：
   - 两阶段提交（2PC）
   - 补偿事务（Saga模式）
   - 本地消息表
   - 最大努力通知
3. 各方案的优缺点对比
4. 实际案例分析（可以虚构一个电商场景）
5. 方案选择建议

文章结构：
1. 引言（300字）：微服务架构的普及和分布式事务的挑战
2. 核心概念（500字）：事务ACID、分布式事务定义
3. 解决方案详解（1200字）：逐一介绍上述4种方案
4. 对比分析（400字）：表格对比各方案
5. 实战案例（600字）：电商订单系统的分布式事务设计
6. 总结与建议（300字）

要求：
- 总字数：3000-3500字
- 包含代码示例（Java或Python）
- 包含架构图描述（用文字描述，我会后续绘制）
- 使用表格对比不同方案
- 风格：专业、深入、实用
- 目标读者：有微服务实践经验的开发者
- 输出格式：Markdown

补充信息：
- 你可以引用知名公司的实际案例（如阿里巴巴、腾讯等）
- 如果有相关的开源框架（如Seata），可以提及"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## 4. 代码开发提示词

### 4.1 代码生成（千问的强项）

千问在代码生成上表现出色，特别是Qwen2.5-Coder系列。

#### 示例：Python Web API开发

**提示词**：

```python
prompt = """你是一位资深的后端开发工程师，擅长Python和FastAPI框架。
你编写的代码遵循PEP 8规范，包含详细注释，注重安全性和性能。

任务：请使用FastAPI框架开发一个「用户认证和授权」的RESTful API。

功能需求：
1. 用户注册（邮箱+密码）
2. 用户登录（返回JWT token）
3. 刷新token
4. 获取当前用户信息
5. 更新用户信息
6. 基于角色的访问控制（RBAC）

技术要求：
- Python 3.9+
- FastAPI框架
- SQLAlchemy ORM（SQLite数据库，可配置为其他数据库）
- Pydantic进行数据验证
- JWT认证（使用PyJWT）
- 密码哈希（使用bcrypt）
- 包含单元测试

输出要求：
1. 所有文件的完整代码
2. 详细的中文注释
3. 文档字符串（docstring）
4. 错误处理
5. 输入验证
6. 安全性考虑（SQL注入、XSS、CSRF等）
7. 单元测试代码
8. README.md（包含安装、运行、API文档说明）

补充要求：
- 使用async/await异步编程
- 添加请求日志
- 包含API速率限制
- 添加Swagger文档（FastAPI自动生成）"""

response = client.chat.completions.create(
    model="qwen2.5-coder:32b",  # 使用代码专用模型
    messages=[{"role": "user", "content": prompt}]
)
```

**预期输出**：
完整的项目代码，包含：

- `main.py`：FastAPI应用入口
- `models.py`：User、Role等SQLAlchemy模型
- `schemas.py`：Pydantic schemas（UserCreate、UserResponse等）
- `auth/routes.py`：注册、登录、刷新token等端点
- `auth/jwt_handler.py`：JWT生成和验证
- `tests/test_auth.py`：单元测试
- `README.md`：项目文档

---

## 5. 数据分析提示词

### 5.1 数据解读

#### 示例：销售数据分析

**提示词**：

```python
data = """
日期,销售额,订单数,客单价,活跃用户数,退货率,广告支出
2024-04-01,150000,500,300,1200,5.2%,15000
2024-04-08,165000,550,300,1250,5.0%,18000
2024-04-15,170000,520,327,1300,4.8%,20000
"""

prompt = f"""你是一位数据分析师，擅长从数据中提取业务洞察，并提供可操作的建议。
你的分析严谨、客观，注重数据驱动的决策。

任务：请分析以下电商平台的销售数据，并提取关键洞察。

数据（CSV格式）：
```

{data}

```

分析要求：
请完成以下分析：

1. **数据概览**
   - 数据时间范围
   - 核心指标的变化趋势

2. **关键指标分析**
   - 销售额增长率（按周）
   - 订单数增长率
   - 客单价变化趋势
   - 活跃用户增长
   - 退货率趋势
   - 广告支出回报率（ROAS）分析

3. **业务洞察**
   - 至少提取3个关键洞察
   - 每个洞察都应该有数据支撑

4. **建议**
   - 提供至少2条可操作的业务建议
   - 建议应该基于数据分析结果

输出格式：
请以Markdown格式输出分析报告，包含：
- 标题和章节结构
- 表格（用于展示数据和对比）
- 要点列表
- 结论和建议

非常重要：请基于数据说话，不要添加数据中没有的信息。"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## 6. 推理任务提示词

### 6.1 逻辑推理

#### 示例：演绎推理

**提示词**：

```python
prompt = """你是一位逻辑推理专家，擅长演绎推理、归纳推理和批判性思维。
你的推理严谨、清晰，能够让读者轻松跟随你的思路。

任务：请解决以下逻辑推理问题，并详细展示推理过程。

问题：
所有的哺乳动物都是脊椎动物。
所有的猫都是哺乳动物。
请问：所有的猫都是脊椎动物吗？

推理步骤：
请按以下步骤推理：

1. **理解问题**：重述问题，确保准确理解。
2. **列出已知前提**：清晰列出所有给定的前提。
3. **分析逻辑关系**：识别前提之间的逻辑关联。
4. **应用推理规则**：使用演绎推理（如三段论）。
5. **检查有效性**：验证推理过程是否符合逻辑规则。
6. **得出结论**：给出明确的最终答案。

输出格式：
请以清晰的Markdown格式输出推理过程，包含：
- 标题和分节
- 逻辑符号（如⊂表示包含于）
- 示范性解释
- 结论的明确表述"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## 7. 高级技巧

### 7.1 使用系统消息和少样本结合

```python
messages = [
    {"role": "system", "content": "你是一位资深的数据科学家，擅长用简洁明了的语言解释复杂概念。你的回答应该包含具体例子，并且避免不必要的技术术语。"},
    {"role": "user", "content": "请解释什么是神经网络。"}
]

response = client.chat.completions.create(
    model="qwen-max",
    messages=messages
)
```

### 7.2 思维链（Chain-of-Thought）在千问中的应用

```python
prompt = """请解决以下数学问题。让我们逐步思考：

问题：一个游泳池有甲、乙两根水管。单开甲管，2小时注满；单开乙管，3小时注满。如果同时打开两根水管，需要多少小时注满游泳池？

让我们一步步分析：

步骤1：理解问题
- 甲管单独注满需要2小时，意味着甲管每小时注满1/2个游泳池。
- 乙管单独注满需要3小时，意味着乙管每小时注满1/3个游泳池。

步骤2：建立数学模型
- 当两根水管同时打开时，它们的注水速度相加。
- 总速度 = 甲管速度 + 乙管速度 = 1/2 + 1/3

步骤3：计算总速度
- 1/2 + 1/3 = 3/6 + 2/6 = 5/6
- 所以两根水管同时工作，每小时注满5/6个游泳池。

步骤4：计算所需时间
- 时间 = 总工作量 ÷ 速度 = 1 ÷ (5/6) = 6/5 = 1.2小时

步骤5：转换为分钟（可选）
- 1.2小时 = 1小时12分钟

步骤6：验证答案
- 检查：1.2小时内，甲管注入了1.2 × (1/2) = 0.6个游泳池
- 乙管注入了1.2 × (1/3) = 0.4个游泳池
- 总计：0.6 + 0.4 = 1.0个游泳池 ✓

最终答案：需要1.2小时（或1小时12分钟）。

现在，请使用相同的步骤，解决以下新问题：
问题：如果丙管单独注满需要4小时，那么三根水管（甲、乙、丙）同时打开，需要多少小时注满游泳池？"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

---

## 8. 配置参数建议

### 8.1 Temperature（温度）

控制生成文本的随机性。

| 任务类型                       | 推荐Temperature | 说明                     |
| ------------------------------ | --------------- | ------------------------ |
| 事实性任务（翻译、摘要、问答） | 0.1 - 0.3       | 低温度使输出更确定、一致 |
| 平衡任务（通用对话、解释）     | 0.3 - 0.7       | 适度随机性，保持连贯     |
| 创意任务（写作、头脑风暴）     | 0.7 - 1.0       | 高温度增加多样性和创意   |
| 代码生成                       | 0.2 - 0.5       | 较低温度确保语法正确     |

**使用阿里云Dashscope SDK的示例**：

```python
from dashscope import Generation

# 事实性任务 - 低温度
response = Generation.call(
    model='qwen-max',
    prompt='将以下句子翻译成法语：[句子]',
    temperature=0.2  # 确保翻译准确一致
)

# 创意写作 - 高温度
response = Generation.call(
    model='qwen-max',
    prompt='写一个关于太空探险的短篇故事',
    temperature=0.85  # 增加创意和多样性
)
```

### 8.2 Top P（核采样）

控制生成时考虑的token范围。

**建议**：

- 一般任务：top_p=0.9（默认）
- 需要高质量输出：top_p=0.95
- 需要更多样性：top_p=0.99

```python
response = Generation.call(
    model='qwen-max',
    prompt='生成10个创意产品名称',
    temperature=0.8,
    top_p=0.95  # 从高概率token中采样
)
```

### 8.3 Max Tokens（最大生成长度）

控制模型生成的最大token数。

**建议**：

- 简单任务：100-300 tokens
- 中等任务（摘要、解释）：300-1000 tokens
- 复杂任务（文章、代码）：1000-4000 tokens

```python
response = Generation.call(
    model='qwen-max',
    prompt='写一篇关于气候变化的文章',
    max_tokens=2000,  # 限制输出长度约1500字
    temperature=0.7
)
```

### 8.4 推荐配置组合

#### 配置1：精准翻译任务

```python
{
    "model": "qwen-max",
    "temperature": 0.2,
    "top_p": 0.9,
    "max_tokens": 500
}
```

#### 配置2：创意写作

```python
{
    "model": "qwen-max",
    "temperature": 0.85,
    "top_p": 0.95,
    "max_tokens": 4096
}
```

#### 配置3：代码生成（使用Qwen2.5-Coder）

```python
{
    "model": "qwen2.5-coder:32b",
    "temperature": 0.3,
    "top_p": 0.95,
    "max_tokens": 3000
}
```

---

## 9. 常见错误与解决方案

### 9.1 输出格式不符合要求

**问题描述**：期望JSON输出，但千问输出纯文本。

**解决方案**：

#### 方法1：在提示词中强制格式

```python
prompt = """请分析以下句子的情感，并以JSON格式输出结果。

句子："这个产品真的很棒，超出我的预期！"

输出格式（严格遵守）：
{
  "sentiment": "[Positive/Neutral/Negative]",
  "confidence": [0-1之间的数值],
  "reason": "[简要说明]"
}

非常重要：只输出JSON，不要添加任何JSON以外的内容。"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

#### 方法2：使用少样本示例

```python
prompt = """请学习以下情感分析的输出格式，然后分析新句子。

示例1：
输入：这个产品真的太棒了，超出我的预期！
输出：{"sentiment": "Positive", "confidence": 0.95, "reason": "用户使用了'太棒了'、'超出预期'等正面词汇。"}

示例2：
输入：质量一般，性价比不高，不推荐购买。
输出：{"sentiment": "Negative", "confidence": 0.88, "reason": "用户明确指出'不推荐购买'，且提到性价比不高。"}

现在请分析：
输入：还算可以吧，没什么特别的。
输出："""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

### 9.2 输出过于冗长

**问题描述**：千问输出过长，超出预期长度。

**解决方案**：

#### 方法1：明确指定字数要求

```python
prompt = """请写一篇关于人工智能的短文。

要求：
1. 字数：500-600字（严格遵守）
2. 包含3个主要观点
3. 每个观点用一段话阐述

非常重要：请确保字数在500-600字之间，不要超出。"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}],
    max_tokens=800  # 约500-600字
)
```

---

## 10. 实用提示词模板

### 模板1：技术文章写作

```python
prompt = """你是一位[角色，如：资深技术博客作者/学术写作助手]，擅长[写作风格描述]。

任务：请写一篇关于「[文章主题]」的[文体，如：教程/评论/分析报告]。

## 目标读者
[描述目标读者，如：中级开发者/学术研究/普通消费者]

## 文章要求
1. 字数：[X-Y字]
2. 结构：
   - 引言：[要求]
   - 主体：[章节安排]
   - 结论：[要求]
3. 风格：[专业/亲和/学术/营销]
4. 包含：[代码示例/数据图表/案例分析]
5. 语调：[客观/热情/严谨/ persuasive]

## 补充信息
[提供任何相关的背景信息、关键词、参考资料等]

输出格式：Markdown"""

response = client.chat.completions.create(
    model="qwen-max",
    messages=[{"role": "user", "content": prompt}]
)
```

### 模板2：代码生成（Python）

```python
prompt = """你是一个[语言]高级开发工程师，
擅长[领域，如：Web开发/数据科学/算法实现]。

## 任务描述
[详细描述需要实现的功acent]

## 具体需求
1. [需求1]
2. [需求2]
3. [需求3]
...

## 技术要求
- 编程语言：[语言及版本]
- 框架/库：[列出需要的框架]
- 代码规范：[如：PEP 8/Airbnb Style]
- 性能要求：[如：时间复杂度O(n log n)]

## 输出要求
1. 完整的可运行代码
2. 详细注释
3. 文档字符串（docstring）
4. 使用示例
5. 单元测试
6. 复杂度分析"""

response = client.chat.completions.create(
    model="qwen2.5-coder:32b",  # 使用代码专用模型
    messages=[{"role": "user", "content": prompt}]
)
```

---

## 11. 参考资料

### 官方文档

1. **阿里云通义千问API文档**  
   https://help.aliyun.com/zh/model-studio/developer-reference/api-reference  
   千问的官方API文档，包含模型介绍、API参考、快速入门。

2. **Qwen2.5官方发布**  
   https://qwen.readthedocs.io/en/latest/news/qwen2.5.html  
   Qwen2.5的官方发布公告和技术细节。

3. **Hugging Face Qwen Models**  
   https://huggingface.co/Qwen  
   千问的官方模型仓库，可以下载模型权重。

### 社区资源

1. **Qwen官方GitHub**  
   https://github.com/QwenLM/Qwen  
   千问的官方GitHub仓库，包含模型代码、微调教程等。

2. **Ollama - Qwen**  
   https://ollama.com/library/qwen2.5  
   使用Ollama运行千问的最简单方式。

3. **Qwen Cookbook**  
   https://github.com/QwenLM/Qwen-Agent  
   千问Agent开发框架和使用示例。

### 教程

1. **Running Qwen2.5 Locally with Ollama**  
   https://ollama.com/library/qwen2.5  
   Ollama的千问使用指南。

2. **Fine-tuning Qwen2.5 with LoRA**  
   https://qwen.readthedocs.io/en/latest/fine-tune/fine-tune.html  
   千问官方提供的微调教程。

---

## 📝 更新日志

- **2026-05-18**：初始版本发布，完成千问(Qwen)提示词指南
- 包含Qwen-Max/Plus/Turbo的详细提示词技巧
- 涵盖写作、代码、数据分析、推理等主流场景
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
**版本**：v1.0
