# Google Gemini 提示词最佳实践指南

> 掌握 Gemini 1.5 Pro、Gemini 1.5 Flash 的提示词技巧，充分发挥Gemini在超长上下文和多模态方面的优势

![Google Gemini Logo](https://img.shields.io/badge/Google-Gemini%201.5%20Pro%2FFlash-blue)
![Status](https://img.shields.io/badge/状态-已完成-green)

---

## 1. 模型概述

### 1.1 模型版本与特点

| 模型                 | 发布时间   | 上下文窗口        | 核心能力               | 适用场景                       |
| -------------------- | ---------- | ----------------- | ---------------------- | ------------------------------ |
| **Gemini 1.5 Pro**   | 2024年5月  | 1M tokens (100万) | 超长上下文、多模态推理 | 长文档分析、视频理解、研究     |
| **Gemini 1.5 Flash** | 2024年5月  | 1M tokens         | 高速度、低成本         | 实时对话、大规模应用、快速推理 |
| **Gemini 1.0 Pro**   | 2023年12月 | 32K tokens        | 平衡性能和成本         | 通用任务、代码生成             |
| **Gemini 1.0 Ultra** | 2023年12月 | 32K tokens        | 最强推理能力           | 复杂推理、学术研究             |

### 1.2 核心优势

✅ **超长上下文**：1M tokens（约75万字），可处理完整书籍、长视频  
✅ **多模态能力**：支持文本、图像、音频、视频输入  
✅ **视频理解**：可直接分析视频内容（独家能力）  
✅ **研究能力**：擅长信息整合和来源引用  
✅ **Google生态集成**：与Google搜索、Google Workspace无缝集成

### 1.3 限制与注意事项

⚠️ **实时信息**：虽然可联网，但搜索结果质量不稳定  
⚠️ **中文能力**：中文理解和生成能力弱于英文  
⚠️ **数学计算**：在精确数学计算上不如GPT-4  
⚠️ **代码生成**：代码质量尚可，但不如GPT-4和Claude  
⚠️ **API限制**：有每分钟/每天的调用次数限制

---

## 2. 提示词基础

### 2.1 Gemini提示词的基本结构

Gemini使用`role`字段来区分不同角色的消息。

#### 基础格式（单次对话）

```python
import google.generativeai as genai

genai.configure(api_key="YOUR_API_KEY")

model = genai.GenerativeModel('gemini-1.5-pro')

prompt = "请解释什么是量子计算。"

response = model.generate_content(prompt)
print(response.text)
```

#### 多轮对话格式

```python
model = genai.GenerativeModel('gemini-1.5-pro')

chat = model.start_chat(history=[
    {"role": "user", "parts": ["你好，我是新手程序员"]},
    {"role": "model", "parts": ["你好！欢迎来到编程世界。有什么可以帮你的吗？"]}
])

response = chat.send_message("请推荐一本Python入门书")
print(response.text)
```

### 2.2 提示词类型（Gemini特有）

Gemini支持多种提示词类型，可以组合使用。

#### 类型1：系统提示（System Prompt）

```python
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    system_instruction="你是一位资深的数据科学家，擅长用简洁明了的语言解释复杂概念。"
)

response = model.generate_content("请解释什么是神经网络。")
```

#### 类型2：上下文提示（Context Prompt）

```python
context = """
上下文：你正在撰写一篇关于人工智能伦理的学术文章。
目标读者：计算机科学专业的研究生。
文章主题：AI算法的公平性和透明度。
"""

prompt = f"{context}\n\n请撰写文章的结论部分。"

response = model.generate_content(prompt)
```

#### 类型3：角色提示（Role Prompt）

```python
prompt = """
你是一位拥有15年经验的投资顾问，擅长价值投资。
你的建议基于扎实的财务分析和长期投资理念。
你善于用通俗易懂的语言解释复杂的金融概念。

任务：请分析以下公司的投资价值：[公司信息]
"""

response = model.generate_content(prompt)
```

### 2.3 核心提示词技巧

#### ✅ 技巧1：组合使用系统、上下文、角色提示

```python
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    system_instruction="""
    你是一位资深的技术文档撰写者。
    你的文档清晰、准确、易于理解。
    你善于使用图表、示例和类比来解释复杂概念。
    """
)

chat = model.start_chat()

response = chat.send_message("""
上下文：我们开发了一款新的Python Web框架，名叫"SwiftWeb"。
目标读者：有Flask或Django经验的Python开发者。
任务：请撰写一篇"SwiftWeb快速入门"教程，包含以下部分：
1. 安装
2. 第一个应用
3. 路由和视图
4. 模板系统
5. 数据库集成

要求：
- 字数：2000-2500字
- 包含可运行的代码示例
- 和Flask/Django对比
- 输出格式：Markdown
""")
```

#### ✅ 技巧2：少样本提示（Few-Shot）

```python
prompt = """
我 will show you examples of text classification, then you should do the same.

Example 1:
Text: "这个产品真的太棒了，超出我的预期！"
Category: Positive
Reasoning: User uses positive words like "太棒了" and "超出预期".

Example 2:
Text: "质量一般，性价比不高，不推荐购买。"
Category: Negative
Reasoning: User explicitly says "不推荐购买" and mentions low cost-performance.

Now classify this text:
Text: "还算可以吧，没什么特别的。"

Category and Reasoning:
"""

response = model.generate_content(prompt)
```

#### ✅ 技巧3：后退提示（Step-Back Prompting）

后退提示是一种先考虑一般原则，再解决具体问题的技术。

```python
# 步骤1：后退一步，考虑一般原则

prompt1 = """
在解决具体的优化问题之前，让我们先考虑一般的优化原则。

问题：对于一个电商网站，有哪些常见的性能优化策略？

请列出5-7个通用的性能优化原则，适用于大多数Web应用。
"""

response1 = model.generate_content(prompt1)
general_principles = response1.text

# 步骤2：应用一般原则到具体问题

prompt2 = f"""
基于以下性能优化的一般原则：

{general_principles}

现在，请为以下具体场景制定优化方案：

场景：一个电商网站，主要性能瓶颈是：
1. 商品搜索响应慢（平均3秒）
2. 商品详情页加载慢（平均2秒）
3. 购物车结算流程繁琐（5步，转化率仅60%）

请应用一般原则，给出具体的优化建议。
"""

response2 = model.generate_content(prompt2)
```

#### ✅ 技巧4：思维链（Chain-of-Thought）

```python
prompt = """
请解决以下逻辑推理问题。让我们逐步思考：

问题：所有的猫都是动物。有些动物会游泳。问：是否所有的猫都会游泳？

让我们一步步分析：

步骤1：理解已知前提
- 前提1：所有的猫都是动物。
- 前提2：有些动物会游泳。

步骤2：分析逻辑关系
- 前提1告诉我们：猫 ⊆ 动物（猫是动物的子集）
- 前提2告诉我们：存在一些动物会游泳，但并非所有动物。

步骤3：检查是否能推导出结论
- 我们知道猫是动物，但前提2只说"有些"动物会游泳。
- "有些"不代表"所有"。

步骤4：寻找反例
- 如果"会游泳的动物"指的是鱼、海豚等，那么猫不在其中。
- 所以，不能得出"所有的猫都会游泳"的结论。

结论：
"""

response = model.generate_content(prompt)
```

### 2.4 提示词编写原则

#### 原则1：具体化（Be Specific）

```markdown
❌ 不好的提示词：
"帮我写点东西"

✅ 好的提示词：
"你是一位资深的技术博客作者。

任务：请写一篇关于「使用Docker容器化部署Python应用」的技术教程。

要求：

1. 目标读者：中级开发者（有Python基础，了解基本Linux命令）
2. 字数：2000-2500字
3. 包含以下部分：
   - 引言：为什么需要容器化
   - Docker基础概念
   - 实战：容器化一个Flask应用
   - Dockerfile最佳实践
   - 生产环境部署注意事项
4. 每个部分都包含可运行的代码示例
5. 代码需要详细注释
6. 风格：专业但亲和，避免过于学术化
7. 输出格式：Markdown"
```

#### 原则2：使用分隔符（Use Delimiters）

```python
article_text = """
[此处粘贴一篇2000字的文章]
"""

prompt = f"""
请总结以下文章的核心观点：

---
{article_text}
---

要求：
1. 提取3-5个关键要点
2. 每个要点用1-2句话概括
3. 输出格式：Markdown列表
"""

response = model.generate_content(prompt)
```

#### 原则3：要求逐步推理

```python
prompt = """
请解决以下数学问题，并展示完整的推理过程：

问题：一个游泳池有甲、乙两根水管。单开甲管，2小时注满；单开乙管，3小时注满。如果同时打开两根水管，需要多少小时注满游泳池？

要求：
1. 先列出已知条件
2. 建立数学模型（用方程或比例）
3. 逐步计算，每一步都详细说明
4. 验证答案的合理性
5. 给出最终答案（用分数和小数两种形式表示）

非常重要：请展示所有推理步骤，不要跳步。
"""

response = model.generate_content(prompt)
```

---

## 3. 写作任务提示词

### 3.1 文章写作

#### 示例1：深度技术文章

**提示词**：

```python
prompt = """
你是一位资深的技术作家，擅长撰写深度技术分析和教程。
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

response = model.generate_content(prompt)
```

**预期输出**：

- 一篇结构完整、深度充足的技术文章
- 包含代码示例和对比表格
- 适合发布在技术博客或技术杂志

#### 示例2：商业分析报告

**提示词**：

```python
prompt = """
你是一位商业分析专家，擅长通过数据洞察业务问题，并提供可操作的建议。
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

response = model.generate_content(prompt)
```

### 3.2 创意写作

#### 示例1：科幻短篇故事

**提示词**：

```python
prompt = """
你是一位科幻小说作家，擅长构建引人入胜的未来世界和深刻的哲学思考。
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

response = model.generate_content(prompt)
```

### 3.3 文本优化

#### 示例：学术文本润色

**提示词**：

```python
original_text = """
机器学习在很多领域都有应用。比如图像识别，机器可以识别出图片里有啥。
还有自然语言处理，机器能理解和生成人类语言。这些应用都很有用。
但是机器学习也有问题，比如需要很多数据，还可能不公平。所以我们要注意这些问题。
"""

prompt = f"""
你是一位学术写作编辑，擅长提升学术文本的清晰度、准确性和表达力。
你熟悉各个学科的写作规范，能够保持学术风格的同时让文字更加流畅。

任务：请润色以下学术论文段落，使其更加学术化、流畅和清晰。

原文：
---
{original_text}
---

要求：
1. 保持原意和核心观点
2. 使用学术写作风格（正式、客观、精确）
3. 改善句子结构和段落流畅度
4. 使用恰当的学术词汇
5. 添加逻辑连接词
6. 输出润色后的文本
7. 附上润色说明（列出主要改进点）

输出格式：
## 润色后的文本
[润色后的文本]

## 润色说明
1. [改进点1]
2. [改进点2]
...
"""

response = model.generate_content(prompt)
```

**预期输出**：

```markdown
## 润色后的文本

机器学习已在诸多领域展现出广泛的应用价值。在计算机视觉领域，深度学习方法在图像分类、目标检测等任务上取得了突破性进展。在自然语言处理领域，大语言模型（LLM）展现出理解和生成人类语言的强大能力。这些技术进展为各行各业带来了实质性的改进。

然而，机器学习技术的应用也面临若干挑战。首先，许多先进模型依赖大规模标注数据进行训练，数据获取成本高昂。其次，算法偏见问题日益凸显，模型可能放大训练数据中的社会偏见，导致不公平的决策。因此，在部署机器学习系统时，必须谨慎考虑数据质量、算法公平性等问题。

## 润色说明

1. **提升学术化程度**：
   - "有很多应用" → "展现出广泛的应用价值"
   - "有啥" → 删除口语化表达
   - "都很有用" → "为各行各业带来了实质性的改进"

2. **使用专业术语**：
   - 添加"深度学习方法"、"大语言模型（LLM）"等专业词汇
   - 使用"计算机视觉"、"自然语言处理"等标准术语

3. **改善句子结构**：
   - 使用复杂句和复合句
   - 添加逻辑连接词（"然而"、"首先"、"其次"、"因此"）

4. **强化论证**：
   - 不只是罗列观点，而是解释原因和影响
   - 例如："数据获取成本高昂"、"导致不公平的决策"

5. **保持客观语气**：
   - 避免主观表述
   - 使用"可能"、"应当"等谨慎的表述
```

---

## 4. 代码开发提示词

### 4.1 代码生成

#### 示例1：Web API开发

**提示词**：

```python
prompt = """
你是一位资深的后端开发工程师，擅长Python和FastAPI框架。
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
├── main.py # FastAPI应用入口
├── config.py # 配置管理
├── models.py # SQLAlchemy模型
├── schemas.py # Pydantic schemas
├── database.py # 数据库连接
├── auth/
│ ├── **init**.py
│ ├── routes.py # 认证路由
│ ├── jwt_handler.py # JWT处理
│ └── auth_utils.py # 认证工具函数
├── users/
│ ├── **init**.py
│ ├── routes.py # 用户路由
│ └── services.py # 用户服务层
└── tests/
├── **init**.py
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

response = model.generate_content(prompt)
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

#### 示例2：数据处理脚本

**提示词**：

```python
prompt = """
你是一位数据工程师，擅长使用Python进行数据清洗、转换和分析。
你编写的代码高效、可读，善于使用pandas、numpy等库。

任务：请编写一个Python脚本，用于处理电商订单数据。

数据描述：
输入数据（CSV格式）：
- order_id: 订单ID
- user_id: 用户ID
- order_date: 订单日期（YYYY-MM-DD格式）
- product_id: 商品ID
- product_name: 商品名称
- category: 商品类别
- price: 单价
- quantity: 数量
- payment_method: 支付方式
- status: 订单状态（completed/refunded/canceled）

示例数据：
```

order_id,user_id,order_date,product_id,product_name,category,price,quantity,payment_method,status
1001,501,2024-04-01,P001,Wireless Earbuds,Electronics,899,1,Credit Card,completed
1002,502,2024-04-01,P002,Running Shoes,Sports,599,2,PayPal,completed
1003,503,2024-04-02,P003,Coffee Maker,Home,399,1,Debit Card,refunded
...

```

处理需求：
请实现以下功能：

1. 数据加载和初步检查
   - 加载CSV文件
   - 检查数据规模、列名、数据类型
   - 检查缺失值、重复值

2. 数据清洗
   - 处理缺失值（根据业务逻辑选择填充或删除）
   - 去除重复订单
   - 标准化payment_method（统一大小写）
   - 转换order_date为datetime类型

3. 特征工程
   - 计算订单总金额（price × quantity）
   - 提取年份、月份、星期几
   - 对用户进行RFM分析（Recency, Frequency, Monetary）

4. 数据分析
   - 销售额趋势分析（按日、按周、按月）
   - 各类别销售额占比
   - 支付方式偏好
   - 退款率和取消率
   - 用户价值分层（基于RFM）

5. 输出结果
   - 清洗后的数据保存为新的CSV
   - 分析结果保存为Excel（多个sheet）
   - 生成数据质量报告（Markdown格式）
   - 使用matplotlib/seaborn生成可视化图表

代码要求：
- 使用函数式编程，每个功能模块化
- 添加详细注释和docstring
- 添加日志记录
- 异常处理完善
- 使用配置文件（config.yaml）管理参数
- 提供命令行接口（使用argparse或click）

文件结构：
```

order*analysis/
├── main.py # 主程序入口
├── config.yaml # 配置文件
├── src/
│ ├── **init**.py
│ ├── data_loader.py # 数据加载模块
│ ├── data_cleaner.py # 数据清洗模块
│ ├── feature_engine.py # 特征工程模块
│ ├── analyzer.py # 分析模块
│ └── visualizer.py # 可视化模块
├── tests/
│ └── test*\*.py # 单元测试
├── data/
│ ├── raw/ # 原始数据
│ └── processed/ # 处理后数据
├── reports/ # 分析报告
└── requirements.txt

```

补充要求：
- 代码应该易于扩展（例如，可以轻松添加新的分析模块）
- 配置应该灵活（例如，可以通过config.yaml改变输入输出路径）
- 日志应该详细但不冗长
- 异常应该被捕获并记录，但不应该导致程序崩溃（除非是致命错误）
"""

response = model.generate_content(prompt)
```

### 4.2 代码审查与优化

#### 示例：代码审查

**提示词**：

````python
code_to_review = """
import mysql.connector
import hashlib

def register_user(username, password, email):
    # Connect to database
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="password123",
        database="user_db"
    )
    cursor = conn.cursor()

    # Hash the password
    hashed_pwd = hashlib.md5(password.encode()).hexdigest()

    # Insert user into database
    sql = "INSERT INTO users (username, password, email) VALUES ('" + username + "', '" + hashed_pwd + "', '" + email + "')"
    cursor.execute(sql)
    conn.commit()

    cursor.close()
    conn.close()

    return "User registered successfully"

def login_user(username, password):
    conn = mysql.connector.connect(
        host="localhost",
        user="root",
        password="password123",
        database="user_db"
    )
    cursor = conn.cursor()

    hashed_pwd = hashlib.md5(password.encode()).hexdigest()

    sql = "SELECT * FROM users WHERE username = '" + username + "' AND password = '" + hashed_pwd + "'"
    cursor.execute(sql)
    result = cursor.fetchone()

    cursor.close()
    conn.close()

    if result:
        return "Login successful"
    else:
        return "Login failed"

if __name__ == "__main__":
    print(register_user("john", "pass123", "john@example.com"))
    print(login_user("john", "pass123"))
"""

prompt = f"""
你是一位资深代码审查专家，擅长发现代码中的bug、性能问题、安全漏洞和可维护性issue。
你的审查细致、专业，能够提供建设性的改进建议。

任务：请审查以下Python代码，并提供详细的审查报告。

代码：
```python
{code_to_review}
````

审查维度：
请从以下维度审查代码：

1. **安全性**
   - SQL注入漏洞
   - 密码哈希方法的安全性
   - 敏感信息硬编码
   - 其他安全漏洞

2. **代码质量**
   - 命名规范
   - 代码重复
   - 函数设计
   - 注释和文档

3. **错误处理**
   - 异常处理
   - 边界条件
   - 资源管理

4. **性能**
   - 数据库连接的效率
   - 是否有明显的性能瓶颈

5. **最佳实践**
   - Python最佳实践遵循情况
   - 数据库操作最佳实践
   - 密码存储最佳实践

输出格式：
请提供以下内容的审查报告：

1. **执行摘要**（总体评价）
2. **详细问题列表**（按严重程度排序：🔴严重 / 🟡中等 / 🟢轻微）
3. **改进建议**（针对每个问题）
4. **重构后的完整代码**
5. **改进说明**（列出主要改进点）

要求：

- 审查报告应该详细但不冗长
- 每个问题都应该有具体的代码片段作为证据
- 改进建议应该可操作、有优先级
- 重构后的代码应该完整、可运行
  """

response = model.generate_content(prompt)

````

---

## 5. 图像生成与分析提示词

### 5.1 图像生成（通过文本描述引导）

虽然Gemini本身不具备DALL-E那样的图像生成能力，但可以通过详细的文本描述来引导其他图像生成工具，或者用于图像编辑任务。

#### 示例：引导图像生成工具的提示词

**提示词**：

```python
prompt = """
请为以下场景生成详细的图像生成提示词（适用于DALL-E、Midjourney等工具）。

场景：一张产品展示图，展示一款现代智能手表。

请生成：
1. **基础提示词**（适用于大多数图像生成工具）
2. **增强提示词**（添加光照、材质、构图等细节）
3. **负面提示词**（不希望出现的元素）

要求：
- 提示词应该详细、具体
- 包含艺术风格、光照条件、材质质感等描述
- 适合高分辨率输出（如2048x2048或更高）
- 如果使用DALL-E 3，请提供适当的提示词格式
- 如果使用Midjourney，请添加适当的参数（如--ar 1:1 --v 6）

输出格式：
## 基础提示词
[提示词文本]

## 增强提示词
[提示词文本]

## 负面提示词
[提示词文本]

## 工具特定提示词
### DALL-E 3
[提示词]

### Midjourney
[提示词]

### Stable Diffusion
[提示词]
"""

response = model.generate_content(prompt)
````

**预期输出**：

```markdown
## 基础提示词

Product photography of a modern smartwatch on a minimalist white background, centered composition, front view, high-quality, detailed, 4K

## 增强提示词

Product photography of a modern smartwatch (Apple Watch Ultra style) on a minimalist white background, centered composition, front view, showing the watch face displaying a colorful abstract pattern.

Lighting: Soft studio lighting from the left, creating gentle shadows that highlight the watch's metallic texture and curved edges. No harsh reflections.

Material: The watch body is brushed titanium with a matte black strap (fluoroelastomer). The screen is OLED with deep blacks and vibrant colors.

Composition: The watch is centered, occupying about 60% of the frame. The background is pure white (#FFFFFF), creating high contrast. Shallow depth of field (f/2.8) to slightly blur the edges.

Details: Visible speaker holes, button texture, and sensor array on the back. The watch face shows fitness metrics (heart rate: 72 BPM, steps: 8,432).

Style: Commercial product photography, like what you'd see in an Apple or Samsung ad.

Resolution: 4K (3840x3840), sharp focus on the watch face and body.

## 负面提示词

blurry, pixelated, low-resolution, distorted, warped, extra arms, extra legs, bad anatomy, ugly, oversaturated, underexposed, overexposed, harsh shadows, reflections on the screen, fingerprints, dust, scratches, watermark, text, signature, frame, border

## 工具特定提示词

### DALL-E 3

A modern smartwatch (Apple Watch Ultra style) in product photography style, centered on a pure white background. The watch has a brushed titanium body and a black fluoroelastomer strap. The OLED screen displays a colorful abstract pattern with fitness metrics (heart rate: 72 BPM, steps: 8,432). Soft studio lighting from the left highlights the metallic texture. High detail, 4K resolution, commercial photography style. --ar 1:1

### Midjourney

Product photography of a modern smartwatch, brushed titanium body, black strap, OLED screen showing fitness metrics, centered on pure white background, soft studio lighting, high detail, 8k, commercial style --ar 1:1 --v 6 --style raw --s 250

### Stable Diffusion (Automatic1111)

Product photography of a modern smartwatch, brushed titanium body, black fluoroelastomer strap, OLED screen displaying colorful abstract pattern with fitness metrics, centered composition, pure white background, soft studio lighting, highly detailed, 8k, commercial photography, sharp focus, cinematic lighting --ar 1:1 --v 6.0 --style raw --s 250 --q 2
```

### 5.2 图像分析

Gemini的多模态能力使其非常擅长图像分析。

#### 示例：图像内容分析

**提示词**（使用Gemini的多模态输入）：

```python
import google.generativeai as genai
import PIL.Image

# 加载图像
image = PIL.Image.open("product_photo.jpg")

model = genai.GenerativeModel('gemini-1.5-pro')

prompt = """
请分析这张产品照片，并提供详细的评估报告。

分析维度：
1. **构图**：主体位置、平衡感、视角
2. **光照**：光线类型、方向、质量
3. **色彩**：色彩方案、饱和度、对比度
4. **清晰度**：焦点、锐度、细节
5. **背景**：是否干扰主体、是否需要移除
6. **产品展示**：产品特性是否清晰展示
7. **商业价值**：是否适合用于电商、广告等场景

输出格式：
- 总分：1-10分
- 各维度打分（1-10分）和简短评价
- 优点（3-5个）
- 缺点（3-5个）
- 改进建议（具体、可操作）

请以Markdown格式输出。
"""

response = model.generate_content([prompt, image])
print(response.text)
```

---

## 6. 数据分析提示词

### 6.1 数据解读

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

prompt = f"""
你是一位数据分析师，擅长从数据中提取业务洞察，并提供可操作的建议。
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

response = model.generate_content(prompt)
```

**预期输出**：

（参考之前Claude章节中的"销售数据分析"输出示例，结构类似）

---

## 7. 推理任务提示词

### 7.1 逻辑推理

#### 示例：演绎推理

**提示词**：

```python
prompt = """
你是一位逻辑推理专家，擅长演绎推理、归纳推理和批判性思维。
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
- 逻辑符号（如⊆表示包含于）
- 示范性解释
- 结论的明确表述
"""

response = model.generate_content(prompt)
```

**预期输出**：

（参考之前Claude章节中的"逻辑推理"输出示例，结构类似）

---

## 8. 高级技巧

### 8.1 思维树（Tree of Thoughts）在Gemini中的应用

对于需要探索多个可能性的问题，可以让Gemini生成和评估多个思路。

#### 示例：复杂决策问题

**提示词**：

```python
prompt = """
你是一位决策分析专家，擅长使用结构化方法帮助人们做出复杂决策。

任务：我们需要决定是否投资一个新的AI创业公司。请使用思维树（Tree of Thoughts）方法，生成和评估多个决策思路。

创业公司信息：
- 业务：开发企业级AI客服平台
- 阶段：种子轮，寻求500万美元投资
- 团队：3位创始人（2位技术，1位销售），均无创业经验
- 产品：MVP已完成，有3个付费客户
- 市场：企业AI客服市场预计2027年达到300亿美元
- 竞争：已有数家成熟竞争对手（如Intercom、Zendesk AI）
- 估值：2000万美元（Pre-money）

请完成以下分析：

1. **生成3个不同的投资策略**
   - 策略1：全额投资500万美元
   - 策略2：部分投资（如200万美元）+ 后续跟投权
   - 策略3：不投资，但提供资源和指导

2. **对每种策略进行评估**
   评估维度：
   - 潜在回报（ROI）
   - 风险水平
   - 团队能力匹配
   - 市场时机
   - 竞争格局

3. **决策树分析**
   对每种策略，分析：
   - 最佳情况（概率、回报）
   - 一般情况（概率、回报）
   - 最差情况（概率、回报）
   - 风险调整后预期回报

4. **最终建议**
   基于以上分析，给出明确的投资建议，并解释理由。

输出格式：
请以Markdown格式输出，包含：
- 每个策略的详细描述
- 评估表格
- 决策树图（用ASCII艺术或文字描述）
- 最终建议和理由
"""

response = model.generate_content(prompt)
```

### 8.2 ReAct（推理+行动）在Gemini中的应用

Gemini可以结合工具使用，实现ReAct（Reasoning + Acting）范式。

#### 示例：结合搜索引擎的问答

**提示词**：

```python
# 注意：以下代码需要结合实际的工具调用机制
# Gemini 原生支持函数调用（Function Calling），通过 tools 参数声明可用函数
# 但可以通过Prompt Engineering模拟ReAct

prompt = """
你是一个AI助手，可以使用以下工具：
- search[查询]：搜索网络信息
- calculator[表达式]：计算数学表达式
- weather[城市]：查询天气

任务：分析2024年AI行业的发展趋势。

请按照ReAct范式（Reasoning + Acting）进行：

思考（Thought）：我现在需要什么信息？
行动（Action）：调用相关工具
观察（Observation）：观察工具返回的结果
...（循环，直到有足够信息）
最终答案（Final Answer）：综合所有信息给出结论

现在开始：
"""

# 模拟ReAct循环
def react_loop(task, max_iterations=5):
    conversation = f"任务：{task}\n\n"

    for i in range(max_iterations):
        # 让Gemini生成下一步的Thought和Action
        prompt = conversation + "\n请决定下一步的Thought和Action。"
        response = model.generate_content(prompt)
        thought_action = response.text

        conversation += thought_action + "\n\n"

        # 解析Action（这里需要解析模型输出的文本，提取工具调用）
        # 注意：这是简化版本，实际需要更复杂的解析逻辑
        if "search[" in thought_action:
            # 执行搜索（这里应该调用真实的搜索API）
            search_query = extract_query(thought_action)
            search_result = mock_search(search_query)
            conversation += f"观察：{search_result}\n\n"
        elif "Final Answer:" in thought_action:
            break

    return conversation

result = react_loop("分析2024年AI行业的发展趋势")
print(result)
```

---

## 9. 配置参数建议

### 9.1 Temperature（温度）

控制生成文本的随机性。

| 任务类型                       | 推荐Temperature | 说明                           |
| ------------------------------ | --------------- | ------------------------------ |
| 事实性任务（翻译、摘要、问答） | 0.1 - 0.3       | 低温度使输出更确定、一致       |
| 平衡任务（通用对话、解释）     | 0.3 - 0.7       | 适度随机性，保持连贯           |
| 创意任务（写作、头脑风暴）     | 0.7 - 1.0       | 高温度增加多样性和创意         |
| 代码生成                       | 0.2 - 0.5       | 较低温度确保语法正确和逻辑一致 |

**示例**：

```python
# 事实性任务 - 低温度
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    generation_config=genai.types.GenerationConfig(
        temperature=0.2,  # 确保翻译准确一致
    )
)

response = model.generate_content("将以下句子翻译成法语：[句子]")

# 创意写作 - 高温度
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    generation_config=genai.types.GenerationConfig(
        temperature=0.85,  # 增加创意和多样性
    )
)

response = model.generate_content("写一个关于太空探险的短篇故事")
```

### 9.2 Top P（核采样）

控制生成时考虑的token范围。

**建议**：

- 一般任务：top_p=0.9（默认）
- 需要高质量输出：top_p=0.95
- 需要更多样性：top_p=0.99

```python
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    generation_config=genai.types.GenerationConfig(
        temperature=0.7,
        top_p=0.95,  # 从高概率token中采样
    )
)

response = model.generate_content("生成10个创意产品名称")
```

### 9.3 Top K

控制生成时考虑的前K个token。

**建议**：

- 一般任务：top_k=40（默认）
- 需要更多多样性：top_k=50
- 需要更确定性输出：top_k=20

```python
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    generation_config=genai.types.GenerationConfig(
        temperature=0.7,
        top_p=0.95,
        top_k=40,  # 考虑前40个概率最高的token
    )
)
```

### 9.4 Max Output Tokens（最大生成长度）

控制模型生成的最大token数。

**建议**：

- 简单任务：100-300 tokens
- 中等任务（摘要、解释）：300-1000 tokens
- 复杂任务（文章、代码）：1000-4000 tokens
- 长文档：8192+ tokens（Gemini 1.5 Pro支持1M）

```python
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    generation_config=genai.types.GenerationConfig(
        max_output_tokens=2000,  # 限制输出长度约1500字
        temperature=0.7,
    )
)

response = model.generate_content("写一篇关于气候变化的文章")
```

### 9.5 推荐配置组合

#### 配置1：精准翻译任务

```python
{
    "model": "gemini-1.5-pro",
    "temperature": 0.2,
    "top_p": 0.9,
    "top_k": 30
}
```

#### 配置2：创意写作

```python
{
    "model": "gemini-1.5-pro",
    "temperature": 0.85,
    "top_p": 0.95,
    "top_k": 50,
    "max_output_tokens": 4096
}
```

#### 配置3：代码生成

```python
{
    "model": "gemini-1.5-pro",
    "temperature": 0.3,
    "top_p": 0.95,
    "max_output_tokens": 3000
}
```

#### 配置4：数据分析

```python
{
    "model": "gemini-1.5-pro",
    "temperature": 0.4,
    "top_p": 0.9,
    "max_output_tokens": 2048
}
```

---

## 10. 常见错误与解决方案

### 10.1 输出格式不符合要求

**问题描述**：期望JSON或其他结构化输出，但Gemini输出纯文本。

**解决方案**：

#### 方法1：在提示词中强制格式

```python
prompt = """
请分析以下句子的情感，并以JSON格式输出结果。

句子："这个产品真的很棒，超出我的预期！"

输出格式（严格遵守）：
{
  "sentiment": "[Positive/Neutral/Negative]",
  "confidence": [0-1之间的数值],
  "reasoning": "[简要说明]"
}

非常重要：只输出JSON，不要添加任何JSON以外的内容。
"""

response = model.generate_content(prompt)
```

#### 方法2：使用少样本示例

```python
prompt = """
请学习以下情感分析的输出格式，然后分析新句子。

示例1：
输入：这个产品真的太棒了，超出我的预期！
输出：{"sentiment": "Positive", "confidence": 0.95, "reasoning": "用户使用了'太棒了'、'超出预期'等正面词汇。"}

示例2：
输入：质量一般，性价比不高，不推荐购买。
输出：{"sentiment": "Negative", "confidence": 0.88, "reasoning": "用户明确指出'不推荐购买'，且提到性价比不高。"}

现在请分析：
输入：还算可以吧，没什么特别的。
输出：
"""

response = model.generate_content(prompt)
```

### 10.2 输出过于冗长

**问题描述**：Gemini输出过长，超出预期。

**解决方案**：

#### 方法1：明确指定字数要求

```python
prompt = """
请写一篇关于人工智能的短文。

要求：
1. 字数：500-600字（严格遵守）
2. 包含3个主要观点
3. 每个观点用一段话阐述
4. 风格：通俗易懂

非常重要：请确保字数在500-600字之间，不要超出。
"""

response = model.generate_content(prompt)
```

#### 方法2：设置max_output_tokens限制

```python
model = genai.GenerativeModel(
    'gemini-1.5-pro',
    generation_config=genai.types.GenerationConfig(
        max_output_tokens=800,  # 约500-600字
    )
)

response = model.generate_content("写一篇关于人工智能的短文，500-600字。")
```

### 10.3 推理错误

**问题描述**：Gemini在逻辑推理、数学计算等任务上出错。

**解决方案**：

#### 方法1：要求逐步推理

```python
prompt = """
请解决以下数学问题，并展示完整的推理过程：

问题：[问题内容]

要求：
1. 先列出已知条件和待求量
2. 建立数学模型或方程
3. 逐步计算，每一步都详细说明
4. 给出最终答案
5. 验证答案的合理性

非常重要：请展示所有推理步骤，不要跳步。
"""

response = model.generate_content(prompt)
```

#### 方法2：使用少样本推理示例

```python
prompt = """
请学习以下推理模式，然后解决新问题。

示例：
问题：如果3个苹果花费6元，那么5个苹果花费多少元？
推理：
1. 先求单价：6元 ÷ 3个 = 2元/个
2. 再求总价：2元/个 × 5个 = 10元
答案：10元

现在请解决：
问题：如果一辆汽车以每小时60公里的速度行驶，2.5小时能行驶多少公里？
推理：
"""

response = model.generate_content(prompt)
```

---

## 11. 实用提示词模板

### 模板1：长文档分析（利用Gemini的超长上下文）

```python
prompt = """
你是一位{角色，如：法律分析师/医学研究者/商业顾问}，擅长阅读和分析长篇文档。
你的分析严谨、客观，能够提取关键信息并识别潜在风险。

任务：请分析以下{文档类型，如：合同/研究报告/商业计划书}，并提供详细分析。

文档：
---
[在此粘贴长篇文档，可能包含数万字]
---

分析要求：
请完成以下分析：

1. **执行摘要**（300字以内）
   - 文档的核心内容
   - 主要结论或建议

2. **详细分析**
   对每个主要部分，提供：
   - 章节标题
   - 核心论点
   - 支持证据
   - 你的评估（逻辑性、完整性、偏见等）

3. **关键发现**
   列出3-5个最重要的发现或洞见。

4. **风险评估**（如果适用）
   识别文档中的潜在风险或问题。

5. **建议**
   基于你的分析，提供可操作的建议。

输出格式：
请以Markdown格式输出，包含标题、段落、列表和表格（如果需要）。
"""

response = model.generate_content(prompt)
```

### 模板2：多模态分析（图像+文本）

```python
import PIL.Image

# 加载图像
image1 = PIL.Image.open("chart.png")
image2 = PIL.Image.open("product_photo.jpg")

model = genai.GenerativeModel('gemini-1.5-pro')

prompt = """
请分析以下内容，并结合图像信息提供综合评估。

文本内容：
---
[文本描述或文档]
---

图像1：[图表]
图像2：[产品照片]

任务：请基于文本和图像信息，完成以下分析：

1. **数据一致性检查**
   - 文本中的数据是否和图表一致？
   - 如果不一致，可能的原因是什么？

2. **产品展示评估**
   - 产品照片是否清晰展示了产品的关键特性？
   - 照片的质量和风格是否符合目标市场？

3. **综合建议**
   - 基于所有信息，提供改进建议。

输出格式：Markdown
"""

response = model.generate_content([prompt, image1, image2])
```

---

## 12. 参考资料

### 官方文档

1. **Google Gemini API Documentation**  
   https://ai.google.dev/gemini-api/docs  
   最权威的API文档，包含模型介绍、API参考、快速入门。

2. **Gemini Prompting Strategies**  
   https://ai.google.dev/gemini-api/docs/prompting-strategies  
   Gemini的提示词策略指南，详细介绍各种提示词技术。

3. **Google AI Studio**  
   https://ai.google.dev/gemini-api/docs/quickstart  
   可以快速测试Gemini的Web界面。

4. **Gemini 1.5 Technical Report**  
   https://arxiv.org/abs/2403.05530  
   Gemini 1.5的技术报告，详细介绍模型能力和架构。

### 社区资源

1. **Prompt Engineering for Gemini**  
   https://www.promptingguide.ai/models/gemini  
   PromptingGuide.ai上的Gemini提示词指南。

2. **Google AI Community**  
   https://discuss.ai.google.dev/  
   官方社区论坛，可以提问、分享经验、获取帮助。

3. **Gemini Cookbook**  
   https://github.com/google-gemini/gemini-cookbook  
   Google官方提供的Gemini使用示例和最佳实践。

### 视频教程

1. **Google AI YouTube Channel**  
   https://www.youtube.com/@GoogleAI  
   官方视频教程，包含Gemini介绍、使用案例等。

2. **Gemini API Quickstart**  
   https://www.youtube.com/watch?v=PaLM0hxkfLQ  
   Gemini API快速入门视频。

---

## 📝 更新日志

- **2026-05-18**：初始版本发布，完成Gemini 1.5提示词指南
- 包含Gemini 1.5 Pro/Flash的详细提示词技巧
- 涵盖写作、代码、图像分析、数据分析、推理等主流场景
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
