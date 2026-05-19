# Meta Llama 提示词最佳实践指南

> 掌握 Llama 3、Llama 2 的提示词技巧，充分发挥开源大语言模型的优势

![Meta Llama Logo](https://img.shields.io/badge/Meta-Llama%203%2F2-orange)
![Status](https://img.shields.io/badge/状态-已完成-green)

---
## 1. 模型概述

### 1.1 模型版本与特点

| 模型 | 发布时间 | 上下文窗口 | 核心能力 | 适用场景 |
|------|---------|-----------|---------|---------|
| **Llama 3 (8B)** | 2024年4月 | 8K tokens | 轻量级、可本地部署 | 移动端、边缘计算、实时应用 |
| **Llama 3 (70B)** | 2024年4月 | 8K tokens | 最强推理、接近GPT-3.5水平 | 通用任务、代码生成、推理 |
| **Llama 2 (7B)** | 2023年7月 | 4K tokens | 轻量级、免费商用 | 简单任务、原型开发 |
| **Llama 2 (13B)** | 2023年7月 | 4K tokens | 平衡性能和资源消耗 | 中等复杂度任务 |
| **Llama 2 (70B)** | 2023年7月 | 4K tokens | Llama 2系列最强版本 | 复杂推理、研究 |

### 1.2 核心优势

✅ **开源免费**：可免费商用（遵守社区许可协议）  
✅ **本地部署**：可部署在本地服务器，保护数据隐私  
✅ **可微调**：支持Fine-tuning，可针对特定任务优化  
✅ **社区活跃**：Hugging Face上有大量预训练模型和LoRA权重  
✅ **多语言支持**：Llama 3对多语言支持更好

### 1.3 限制与注意事项

⚠️ **上下文窗口较小**：Llama 3支持8K，Llama 2仅4K  
⚠️ **指令遵循能力较弱**：不如GPT-4和Claude，需要更详细的提示词  
⚠️ **中文能力较弱**：Llama 3中文能力有提升，但仍不如英文  
⚠️ **部署资源要求高**：70B模型需要多GPU或高内存  
⚠️ **无官方API**：需要自己部署或使用第三方服务（如Replicate、Hugging Face Inference API）

---

## 2. 提示词基础

### 2.1 Llama提示词的基本结构

Llama使用特定的聊天模板格式。最重要的是使用正确的标记。

#### Llama 2 格式

```
[INST] <<SYS>>
You are a helpful, respectful and honest assistant.
<</SYS>>

[用户指令]
[/INST]
[模型回答]
```

#### Llama 3 格式（推荐）

Llama 3使用类似但更简洁的格式：

```
<|begin_of_text|><|start_header_id|>system<|end_header_id|>

You are a helpful assistant.<|eot_id|><|start_header_id|>user<|end_header_id|>

[用户指令]<|eot_id|><|start_header_id|>assistant<|end_header_id|>
```

**重要**：在实际应用中，建议使用Hugging Face的`transformers`库或`llama-cpp-python`来处理这些标记，而不是手动编写。

### 2.2 使用Hugging Face Transformers（推荐）

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = "meta-llama/Meta-Llama-3-8B-Instruct"

tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name)

# 使用聊天模板（Llama 3）
messages = [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "请解释什么是机器学习。"}
]

inputs = tokenizer.apply_chat_template(
    messages,
    add_generation_prompt=True,
    return_tensors="pt"
)

outputs = model.generate(inputs, max_new_tokens=512)
response = tokenizer.decode(outputs[0], skip_special_tokens=True)
print(response)
```

### 2.3 使用Ollama（本地运行，最简单）

[Ollama](https://ollama.com/)是运行Llama等开源模型的最简单方式。

#### 安装和使用

```bash
# 安装Ollama（MacOS/Linux）
curl -fsSL https://ollama.com/install.sh | sh

# 运行Llama 3
ollama run llama3

# 在Python中使用
pip install ollama
```

#### Python代码示例

```python
import ollama

# 单次对话
response = ollama.chat(
    model='llama3',
    messages=[
        {'role': 'system', 'content': '你是一位资深的数据科学家。'},
        {'role': 'user', 'content': '请解释什么是过拟合（overfitting）。'}
    ]
)
print(response['message']['content'])

# 流式输出
stream = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': '讲一个关于AI的笑话'}],
    stream=True
)

for chunk in stream:
    print(chunk['message']['content'], end='', flush=True)
```

### 2.4 核心提示词技巧

#### ✅ 技巧1：提供详细指令

Llama的指令遵循能力弱于GPT-4，因此需要更详细、更明确的指令。

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

非常重要：请确保文章结构清晰，代码可直接运行。
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

#### ✅ 技巧2：使用少样本示例（Few-Shot）

```python
prompt = """我 will show you examples of sentiment analysis, then you should do the same.

Example 1:
Text: "这个产品真的太棒了，超出我的预期！"
Output: {"sentiment": "positive", "confidence": 0.95, "reason": "用户使用了'太棒了'、'超出预期'等正面词汇。"}

Example 2:
Text: "质量一般，性价比不高，不推荐购买。"
Output: {"sentiment": "negative", "confidence": 0.88, "reason": "用户明确指出'不推荐购买'，且提到性价比不高。"}

Example 3:
Text: "还算可以吧，没什么特别的。"
Output: {"sentiment": "neutral", "confidence": 0.65, "reason": "用户没有明确表达满意或不满，态度中立。"}

Now analyze this text:
Text: "质量太差了，浪费钱。"
Output: """

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

#### ✅ 技巧3：要求逐步思考（Chain-of-Thought）

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

现在，请按照上述步骤，详细展示你的推理过程。
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

---

## 3. 写作任务提示词

### 3.1 文章写作

#### 示例1：技术博客文章

**提示词**：

```python
prompt = """你是一位资深的技术博客作者，擅长撰写深度技术分析和教程。
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
- 你可以引用知名公司的实际案例（如阿里巴巴、Netflix等）
- 如果有相关的开源框架（如Seata），可以提及
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

**预期输出**：
- 一篇结构完整、深度充足的技术文章
- 包含代码示例和对比表格
- 适合发布在技术博客或技术杂志

#### 示例2：商业分析报告

**提示词**：

```python
prompt = """你是一位商业分析专家，擅长通过数据洞察业务问题，并提供可操作的建议。
你的报告严谨、客观，注重数据支撑和逻辑推理。

任务：请撰写一份关于「2024年Q2电商平台销售业绩」的分析报告。

销售数据概要：
- 总销售额：5000万元（Q1：4200万元，环比增长19%）
- 订单数：15万单（Q1：12万单，环比增长25%）
- 客单价：333元（Q1：350元，环比下降5%）
- 退货率：8%（Q1：6%，环比上升2%）
- 主要品类占比：电子数码45%、服装30%、家居25%

报告结构：
1. 执行摘要（200字）
2. 整体业绩回顾（400字）
3. 关键指标分析（800字）
   - 销售额增长分析
   - 订单数增长分析
   - 客单价下降原因探究
   - 退货率上升预警
4. 品类表现分析（500字）
5. 问题诊断与建议（600字）
6. 下季度展望（300字）

要求：
- 总字数：2500-3000字
- 使用数据图表描述（用文字说明图表内容和结论）
- 分析问题根源，not just 描述现象
- 提供具体、可执行的建议
- 风格：专业、数据驱动、实用
- 输出格式：Markdown，包含标题、段落、列表、表格
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

### 3.2 创意写作

#### 示例：科幻短篇故事

**提示词**：

```python
prompt = """你是一位科幻小说作家，擅长构建引人入胜的未来世界和深刻的哲学思考。
你的故事情节紧凑、角色立体、科技设定严谨。

任务：请创作一个关于「记忆交易」的科幻短篇故事。

故事元素：
- 背景：2150年，记忆已经成为可以交易的商品
- 主角：一个记忆交易商，名叫林远
- 冲突：一个神秘的客人委托他购买一段危险的记忆
- 转折：这段记忆可能涉及一个惊天的秘密
- 主题：探讨记忆、身份、隐私的伦理问题

要求：
- 字数：2000-2500字
- 视角：第三人称有限视角（主要跟随主角）
- 风格：叙事紧凑，对话自然，描写细腻
- 包含科幻元素的合理设定（不要硬塞技术名词）
- 结尾留有余味和思考空间
- 避免 cliché 的科幻套路

补充要求：
- 故事应该有至少两个转折点
- 主角的动机应该清晰且合理
- 科技设定应该服务于剧情，而非炫技
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

---

## 4. 代码开发提示词

### 4.1 代码生成

#### 示例：Web API开发

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

代码组织：
```
app/
├── main.py              # FastAPI应用入口
├── config.py           # 配置管理
├── models.py           # SQLAlchemy模型
├── schemas.py          # Pydantic schemas
├── database.py         # 数据库连接
├── auth/
│   ├── __init__.py
│   ├── routes.py       # 认证路由
│   ├── jwt_handler.py  # JWT处理
│   └── auth_utils.py   # 认证工具函数
├── users/
│   ├── __init__.py
│   ├── routes.py       # 用户路由
│   └── services.py     # 用户服务层
└── tests/
    ├── __init__.py
    ├── test_auth.py
    └── test_users.py
```

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
- 添加Swagger文档（FastAPI自动生成）
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
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
2024-04-22,180000,600,300,1350,5.5%,22000
2024-04-29,190000,650,292,1400,6.0%,25000
2024-05-06,210000,700,300,1500,5.8%,30000
2024-05-13,205000,680,301,1480,5.5%,28000
2024-05-20,215000,720,299,1520,5.3%,32000
2024-05-27,220000,750,293,1550,5.7%,35000
2024-06-03,225000,770,292,1580,6.2%,38000
2024-06-10,230000,790,291,1600,6.5%,40000
2024-06-17,228000,780,292,1590,6.3%,39000
2024-06-24,235000,800,294,1620,6.8%,42000
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

3. **相关性分析**
   - 广告支出与销售额的关系
   - 活跃用户数与销售额的关系
   - 退货率与销售额/客单价的关系

4. **异常检测**
   - 识别数据中的异常值或突变点
   - 分析可能的原因

5. **业务洞察**
   - 至少提取5个关键洞察
   - 每个洞察都应该有数据支撑

6. **建议**
   - 提供至少3条可操作的业务建议
   - 建议应该基于数据分析结果

输出格式：
请以Markdown格式输出分析报告，包含：
- 标题和章节结构
- 表格（用于展示数据和对比）
- 要点列表
- 结论和建议

非常重要：请基于数据说话，不要添加数据中没有的信息。
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
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
7. **反思**：思考是否存在反例或边界情况。

输出格式：
请以清晰的Markdown格式输出推理过程，包含：
- 标题和分节
- 逻辑符号（如⊂表示包含于）
- 示范性解释
- 结论的明确表述
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

---

## 7. 高级技巧

### 7.1 使用系统提示（System Prompt）

虽然Llama的系统性弱于GPT-4，但仍可以通过系统提示引导行为。

```python
messages = [
    {'role': 'system', 'content': '你是一位资深的数据科学家，擅长用简洁明了的语言解释复杂概念。你的回答应该包含具体例子，并且避免不必要的技术术语。'},
    {'role': 'user', 'content': '请解释什么是神经网络。'}
]

response = ollama.chat(
    model='llama3',
    messages=messages
)
```

### 7.2 思维链（Chain-of-Thought）在Llama中的应用

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
问题：如果丙管单独注满需要4小时，那么三根水管（甲、乙、丙）同时打开，需要多少小时注满游泳池？
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

---

## 8. 配置参数建议

### 8.1 Temperature（温度）

控制生成文本的随机性。

| 任务类型 | 推荐Temperature | 说明 |
|---------|----------------|------|
| 事实性任务（翻译、摘要、问答） | 0.1 - 0.3 | 低温度使输出更确定、一致 |
| 平衡任务（通用对话、解释） | 0.3 - 0.7 | 适度随机性，保持连贯 |
| 创意任务（写作、头脑风暴） | 0.7 - 1.0 | 高温度增加多样性和创意 |
| 代码生成 | 0.2 - 0.5 | 较低温度确保语法正确 |

**使用Ollama的示例**：

```python
response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': '请将以下句子翻译成法语：[句子]'}],
    options={'temperature': 0.2}  # 低温度确保翻译准确
)

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': '写一个关于太空探险的短篇故事'}],
    options={'temperature': 0.85}  # 高温度增加创意
)
```

### 8.2 Top P（核采样）

控制生成时考虑的token范围。

**建议**：
- 一般任务：top_p=0.9（默认）
- 需要高质量输出：top_p=0.95
- 需要更多样性：top_p=0.99

```python
response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': '生成10个创意产品名称'}],
    options={
        'temperature': 0.8,
        'top_p': 0.95  # 从高概率token中采样
    }
)
```

### 8.3 Max Tokens（最大生成长度）

控制模型生成的最大token数。

**建议**：
- 简单任务：100-300 tokens
- 中等任务（摘要、解释）：300-1000 tokens
- 复杂任务（文章、代码）：1000-4000 tokens

```python
response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': '写一篇关于气候变化的文章'}],
    options={
        'num_predict': 2000,  # 限制输出长度约1500字
        'temperature': 0.7
    }
)
```

### 8.4 推荐配置组合

#### 配置1：精准翻译任务

```python
{
    "model": "llama3",
    "temperature": 0.2,
    "top_p": 0.9,
    "num_predict": 500
}
```

#### 配置2：创意写作

```python
{
    "model": "llama3",
    "temperature": 0.85,
    "top_p": 0.95,
    "num_predict": 4096
}
```

#### 配置3：代码生成

```python
{
    "model": "llama3",
    "temperature": 0.3,
    "top_p": 0.95,
    "num_predict": 3000
}
```

---

## 9. 常见错误与解决方案

### 9.1 输出格式不符合要求

**问题描述**：期望JSON或其他结构化输出，但Llama输出纯文本。

**解决方案**：

#### 方法1：在提示词中强制格式

```python
prompt = """请分析以下句子的情感，并以JSON格式输出结果。

句子："这个产品真的很棒，超出我的预期！"

输出格式（严格遵守）：
{
  "sentiment": "[Positive/Neutral/Negative]",
  "confidence": [0-1之间的数值],
  "reasoning": "[简要说明]"
}

非常重要：只输出JSON，不要添加任何JSON以外的内容。
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

#### 方法2：使用少样本示例

```python
prompt = """请学习以下情感分析的输出格式，然后分析新句子。

示例1：
输入：这个产品真的太棒了，超出我的预期！
输出：{"sentiment": "Positive", "confidence": 0.95, "reasoning": "用户使用了'太棒了'、'超出预期'等正面词汇。"}

示例2：
输入：质量一般，性价比不高，不推荐购买。
输出：{"sentiment": "Negative", "confidence": 0.88, "reasoning": "用户明确指出'不推荐购买'，且提到性价比不高。"}

现在请分析：
输入：还算可以吧，没什么特别的。
输出："""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

### 9.2 输出过于冗长

**问题描述**：Llama容易生成过长的输出，超出预期长度。

**解决方案**：

#### 方法1：明确指定字数要求

```python
prompt = """请写一篇关于人工智能的短文。

要求：
1. 字数：500-600字（严格遵守）
2. 包含3个主要观点
3. 每个观点用一段话阐述
4. 风格：通俗易懂

非常重要：请确保字数在500-600字之间，不要超出。
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}],
    options={'num_predict': 800}  # 约500-600字
)
```

#### 方法2：设置num_predict限制

```python
response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': '写一篇关于人工智能的短文，500-600字。'}],
    options={'num_predict': 750}  # 限制输出长度
)
```

---

## 10. 实用提示词模板

### 模板1：本地部署的聊天助手

```python
import ollama

system_prompt = """你是一位 helpful assistant。
你的回答应该：
1. 准确且诚实
2. 尊重用户
3. 避免有害内容
4. 如果不确定，就说不确定
"""

def chat(user_message):
    response = ollama.chat(
        model='llama3',
        messages=[
            {'role': 'system', 'content': system_prompt},
            {'role': 'user', 'content': user_message}
        ]
    )
    return response['message']['content']

# 使用
print(chat("请解释什么是量子计算。"))
```

### 模板2：代码审查助手

```python
code_to_review = """
[在此粘贴需要审查的代码]
"""

prompt = f"""你是一位资深代码审查专家。
请审查以下Python代码，并重点关注：

1. **正确性**：是否有bug？边界条件是否处理？
2. **安全性**：是否有安全漏洞（如SQL注入、XSS等）？
3. **性能**：是否有性能瓶颈？时间/空间复杂度是否合理？
4. **可维护性**：命名是否规范？代码是否易于理解？
5. **最佳实践**：是否遵循PEP 8和行业最佳实践？

代码：
```python
{code_to_review}
```

输出格式：
## 执行摘要
[总体评价]

## 详细问题列表
### 🔴 严重问题
[列出严重问题]

### 🟡 中等问题
[列出中等问题]

### 🟢 轻微问题
[列出轻微问题]

## 改进建议
[针对每个问题提供改进建议]

## 重构后的代码
[提供改进后的完整代码]
"""

response = ollama.chat(
    model='llama3',
    messages=[{'role': 'user', 'content': prompt}]
)
```

---

## 11. 参考资料

### 官方文档

1. **Meta Llama 3 Documentation**  
   https://llama.meta.com/docs/model-cards-and-prompt-formats/llama3  
   Llama 3的官方文档，包含模型介绍、提示词格式等。

2. **Llama 2 Community License**  
   https://github.com/facebookresearch/llama/blob/main/LICENSE  
   Llama 2的许可证，规定了使用条件。

3. **Hugging Face Transformers Documentation**  
   https://huggingface.co/docs/transformers/main/en/model_doc/llama  
   使用Transformers库加载和推理Llama模型的文档。

### 社区资源

1. **Ollama**  
   https://ollama.com/  
   本地运行Llama等开源模型的最简单方式。

2. **Llama Recipes**  
   https://github.com/meta-llama/llama-recipes  
   Meta官方提供的Llama使用示例和最佳实践。

3. **Awesome Llama**  
   https://github.com/facebookresearch/llama  
   Llama相关的资源、项目、教程集合。

### 教程

1. **Fine-tuning Llama 3 with LoRA**  
   https://www.databricks.com/blog/fine-tuning-llama-3  
   Databricks提供的Llama 3微调教程。

2. **Running Llama 3 Locally with Ollama**  
   https://ollama.com/library/llama3  
   Ollama的Llama 3使用指南。

---

## 📝 更新日志

- **2026-05-18**：初始版本发布，完成Meta Llama提示词指南
- 包含Llama 3/Llama 2的详细提示词技巧
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
