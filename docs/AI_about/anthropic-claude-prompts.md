# Anthropic Claude 提示词最佳实践指南

> 掌握 Claude 3.5 Sonnet、Claude 3 Opus、Claude 3 Haiku 的提示词技巧，充分发挥Claude在长文本处理和角色扮演方面的优势

![Anthropic Logo](https://img.shields.io/badge/Anthropic-Claude%203.5%20Sonnet%2Fopus%2Fhaiku-purple)
![Status](https://img.shields.io/badge/状态-已完成-green)

---
## 1. 模型概述

### 1.1 模型版本与特点

| 模型 | 发布时间 | 上下文窗口 | 核心能力 | 适用场景 |
|------|---------|-----------|---------|---------|
| **Claude 3.5 Sonnet** | 2024年6月 | 200K tokens | 最强综合能力、性价比高 | 通用任务、长文档分析、代码开发 |
| **Claude 3 Opus** | 2024年3月 | 200K tokens | 最强推理能力 | 复杂推理、学术研究、法律分析 |
| **Claude 3 Sonnet** | 2024年3月 | 200K tokens | 平衡性能和成本 | 中等复杂度任务、客户服务 |
| **Claude 3 Haiku** | 2024年3月 | 200K tokens | 最快速度、低成本 | 简单任务、实时对话、大规模应用 |

### 1.2 核心优势

✅ **超长上下文**：200K tokens（约15万字），可处理完整书籍  
✅ **优秀的安全对齐**：不易产生有害输出，适合敏感场景  
✅ **角色扮演自然**：擅长模拟各种专业角色  
✅ **长文档处理**：在 summarization、QA等任务上表现出色  
✅ **多语言支持**：对中文等非英语语言支持良好

### 1.3 限制与注意事项

⚠️ **数学计算**：在数学和精确计算任务上不如GPT-4  
⚠️ **实时信息**：训练数据有截止时间，无实时网络访问  
⚠️ **成本**：Claude 3 Opus的API成本较高  
⚠️ **输出冗长**：如果不加限制，容易生成过长的输出  
⚠️ **幻觉问题**：虽然较少，但仍可能产生不准确信息

---

## 2. 提示词基础

### 2.1 Claude提示词的基本结构

Claude使用`Human:`和`Assistant:`作为对话标记，也可以使用XML标签来结构化提示词。

#### 基础格式

```markdown
Human: [用户的问题或指令]

Assistant: [Claude的回答]
```

#### 使用XML标签结构化（推荐）

```markdown
Human: 
<instructions>
你是一个资深的数据科学家。请分析以下数据集，提取关键洞察。
</instructions>

<context>
我们是一家电商平台，想了解上季度的销售情况。
</context>

<data>
[数据集]
</data>

<requirements>
1. 计算关键指标（均值、中位数、标准差）
2. 识别趋势和异常值
3. 提供业务建议
4. 输出格式：Markdown表格
</requirements>

Assistant:
```

### 2.2 核心提示词技巧

#### ✅ 技巧1：使用清晰的部分标题

使用XML标签或Markdown标题将提示词分为清晰的部分：

```markdown
Human:
# 任务
请撰写一篇产品评测文章。

# 产品信息
- 名称：MacBook Pro 16寸
- 价格：¥18,999起
- 核心特性：[列出3-5个特性]

# 目标读者
科技爱好者、专业创作者

# 文章结构
1. 引言
2. 设计与做工
3. 性能测试
4. 续航表现
5. 优缺点总结
6. 购买建议

# 要求
- 字数：2000-2500字
- 风格：专业、客观、详细
- 包含实际测试数据
- 与使用场景匹配的建议

Assistant:
```

#### ✅ 技巧2：提供少量示例（Few-Shot）

```markdown
Human:
我 will give you examples of sentiment analysis, then you should do the same.

Example 1:
Text: "这个产品真的太棒了，超出我的预期！"
Sentiment: Positive
Reasoning: 用户使用了"太棒了"、"超出预期"等正面词汇。

Example 2:
Text: "质量一般，性价比不高，不推荐购买。"
Sentiment: Negative
Reasoning: 用户明确指出"不推荐购买"，且提到性价比不高。

Now analyze this text:
Text: "还算可以吧，没什么特别的。"
Sentiment and Reasoning:

Assistant:
```

#### ✅ 技巧3：要求逐步思考（Chain-of-Thought）

```markdown
Human:
请解决以下逻辑推理问题。在给出最终答案之前，请先逐步分析。

问题：所有的猫都是动物。有些动物会游泳。问：是否所有的猫都会游泳？

请按以下步骤思考：
1. 列出已知前提
2. 分析逻辑关系
3. 检查是否存在反例
4. 得出最终结论

Assistant:
```

#### ✅ 技巧4：使用角色提示（Role Prompting）

```markdown
Human:
<role>
你是一位拥有15年经验的企业管理顾问，擅长组织变革和战略规化。
你的建议基于扎实的管理学理论和丰富的实战经验。
你善于用简洁、有力的语言传达深刻的见解。
</role>

<task>
我们是一家200人规模的软件公司，目前面临以下挑战：
1. 产品交付周期过长（平均6个月）
2. 团队沟通效率低
3. 技术债务累积严重

请提供改进建议。
</task>

<requirements>
1. 针对每个挑战提供3条具体建议
2. 建议应该可操作、有优先级
3. 引用相关的管理理论或最佳实践
4. 字数：1500-2000字
</requirements>

Assistant:
```

### 2.3 Claude特有功能：预填充响应（Pre-filling Response）

Claude支持在`Assistant:`部分预先填写内容，以引导输出格式。

#### 示例：强制JSON输出

```markdown
Human:
请分析以下句子的情感，并以JSON格式输出结果。

句子："这个产品真的很棒，超出我的预期！"

输出格式：
{
  "sentiment": "[Positive/Neutral/Negative]",
  "confidence": [0-1之间的数值],
  "reasoning": "[简要说明]"
}

Assistant:
{
  "sentiment": "Positive",
```

**说明**：通过在`Assistant:`后预填`{ "sentiment": "Positive",`，Claude会继续完成JSON的输出。

### 2.4 提示词编写原则

#### 原则1：清晰直接

```markdown
❌ 不好的提示词：
"帮我看看这个，说说你的想法"

✅ 好的提示词：
"请审查以下Python代码，重点关注：
1. 代码质量（可读性、命名规范）
2. 性能优化空间
3. 潜在bug
4. 最佳实践遵循情况

代码：
[代码内容]

请以Markdown格式输出审查报告。"
```

#### 原则2：分离数据与指令

将数据与指令明确分开，避免指令被误认为是数据。

```markdown
❌ 容易混淆的提示词：
"请将以下文字翻译为英文：不要翻译这段文字"

✅ 清晰的提示词：
<instructions>
请将提供的文字翻译为英文。
</instructions>

<text_to_translate>
不要翻译这段文字
</text_to_translate>

<output_format>
只需输出翻译后的英文文本，不要添加任何解释。
</output_format>
```

#### 原则3：逐步引导复杂任务

对于复杂任务，将其分解为多个简单步骤。

```markdown
Human:
我们将分步完成一篇市场分析报告。

## 步骤1：数据理解
首先，请观察以下数据，并告诉我：
1. 数据包含哪些字段？
2. 数据的时间范围是什么？
3. 有哪些明显的趋势或异常？

数据：
[数据内容]

请只完成步骤1的分析。

Assistant:
```

（在后续对话中继续引导步骤2、步骤3...）

---

## 3. 写作任务提示词

### 3.1 文章写作

#### 示例1：深度技术分析文章

**提示词**：

```markdown
Human:
<role>
你是一位资深的技术作家，擅长撰写深度技术分析和教程。
你的文章逻辑清晰、例证丰富、适合中级到高级开发者阅读。
</role>

<task>
请撰写一篇关于「微服务架构中的分布式事务管理」的深度技术文章。
</task>

<key_points>
文章应涵盖以下要点：
1. 分布式事务的挑战（CAP定理、网络分区等）
2. 常见解决方案：
   - 两阶段提交（2PC）
   - 补偿事务（Saga模式）
   - 本地消息表
   - 最大努力通知
3. 各方案的优缺点对比
4. 实际案例分析（可以虚构一个电商场景）
5. 方案选择建议
</key_points>

<structure>
文章结构：
1. 引言（300字）：微服务架构的普及和分布式事务的挑战
2. 核心概念（500字）：事务ACID、分布式事务定义
3. 解决方案详解（1200字）：逐一介绍上述4种方案
4. 对比分析（400字）：表格对比各方案
5. 实战案例（600字）：电商订单系统的分布式事务设计
6. 总结与建议（300字）
</structure>

<requirements>
- 总字数：3000-3500字
- 包含代码示例（Java或Python）
- 包含架构图描述（用文字描述，我会后续绘制）
- 使用表格对比不同方案
- 风格：专业、深入、实用
- 目标读者：有微服务实践经验的开发者
</requirements>

Assistant:
```

**预期输出**：
- 一篇结构完整、深度充足的技术文章
- 包含代码示例和对比表格
- 适合发布在技术博客或技术杂志

#### 示例2：商业分析报告

**提示词**：

```markdown
Human:
<role>
你是一位商业分析专家，擅长通过数据洞察业务问题，并提供可操作的建议。
你的报告严谨、客观，注重数据支撑和逻辑推理。
</role>

<task>
请撰写一份关于「2024年Q2电商平台销售业绩」的分析报告。
</task>

<data>
销售数据概要：
- 总销售额：5000万元（Q1：4200万元，环比增长19%）
- 订单数：15万单（Q1：12万单，环比增长25%）
- 客单价：333元（Q1：350元，环比下降5%）
- 退货率：8%（Q1：6%，环比上升2%）
- 主要品类占比：电子数码45%、服装30%、家居25%
</data>

<report_structure>
报告应包含以下部分：
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
</report_structure>

<requirements>
- 总字数：2500-3000字
- 使用数据图表描述（用文字说明图表内容和结论）
- 分析问题根源， not just 描述现象
- 提供具体、可执行的建议
- 风格：专业、数据驱动、实用
- 输出格式：Markdown，包含标题、段落、列表、表格
</requirements>

Assistant:
```

### 3.2 创意写作

#### 示例1：科幻短篇故事

**提示词**：

```markdown
Human:
<role>
你是一位科幻小说作家，擅长构建引人入胜的未来世界和深刻的哲学思考。
你的故事情节紧凑、角色立体、科技设定严谨。
</role>

<task>
请创作一个关于「记忆交易」的科幻短篇故事。
</task>

<story_elements>
故事应包含以下元素：
- 背景：2150年，记忆已经成为可以交易的商品
- 主角：一个记忆交易商，名叫林远
- 冲突：一个神秘的客人委托他购买一段危险的记忆
- 转折：这段记忆可能涉及一个惊天的秘密
- 主题：探讨记忆、身份、隐私的伦理问题
</story_elements>

<requirements>
- 字数：2000-2500字
- 视角：第三人称有限视角（主要跟随主角）
- 风格：叙事紧凑，对话自然，描写细腻
- 包含科幻元素的合理设定（不要硬塞技术名词）
- 结尾留有余味和思考空间
- 避免 cliché 的科幻套路
</requirements>

Assistant:
```

#### 示例2：诗歌创作

**提示词**：

```markdown
Human:
<role>
你是一位现代诗人，擅长用优美的意象和深刻的情感表达复杂的主题。
你的诗歌既有古典的韵味，又有现代的视角。
</role>

<task>
请创作一首关于「时间」的现代诗。
</task>

<requirements>
- 形式：自由诗，不严格押韵
- 长度：20-30行
- 核心意象：流水、沙漏、白发、老照片、四季更替
- 情感：既有对时间流逝的感慨，也有对当下的珍惜
- 风格：唯美、抒情、略带哲理
- 避免陈词滥调（如"时间就是金钱"等）
</requirements>

Assistant:
```

### 3.3 文本优化

#### 示例1：学术文本润色

**提示词**：

```markdown
Human:
<role>
你是一位学术写作编辑，擅长提升学术文本的清晰度、准确性和表达力。
你熟悉各个学科的写作规范，能够保持学术风格的同时让文字更加流畅。
</role>

<task>
请润色以下学术论文段落，使其更加学术化、流畅和清晰。
</task>

<original_text>
机器学习在很多领域都有应用。比如图像识别，机器可以识别出图片里有啥。还有自然语言处理，机器能理解和生成人类语言。这些应用都很有用。但是机器学习也有问题，比如需要很多数据，还可能不公平。所以我们要注意这些问题。
</original_text>

<requirements>
1. 保持原意和核心观点
2. 使用学术写作风格（正式、客观、精确）
3. 改善句子结构和段落流畅度
4. 使用恰当的学术词汇
5. 添加逻辑连接词
6. 输出润色后的文本，并附上润色说明（列出主要改进点）
</requirements>

Assistant:
```

**预期输出**：

润色后的文本：
```
机器学习已在诸多领域展现出广泛的应用价值。在计算机视觉领域，深度学习方法在图像分类、目标检测等任务上取得了突破性进展。在自然语言处理领域，大语言模型（LLM）展现出理解和生成人类语言的强大能力。这些技术进展为各行各业带来了实质性的改进。

然而，机器学习技术的应用也面临若干挑战。首先，许多先进模型依赖大规模标注数据进行训练，数据获取成本高昂。其次，算法偏见问题日益凸显，模型可能放大训练数据中的社会偏见，导致不公平的决策。因此，在部署机器学习系统时，必须谨慎考虑数据质量、算法公平性等问题。
```

润色说明：
1. 将口语化表达改为学术化表达（如"有应用"→"展现出广泛的应用价值"）
2. 添加具体技术名词（深度学习方法、大语言模型、LLM）
3. 改善句子结构，增加复杂句和复合句
4. 使用逻辑连接词（然而、首先、其次、因此）
5. 强化论证， not just 罗列观点

---

## 4. 代码开发提示词

### 4.1 代码生成

#### 示例1：Web API开发

**提示词**：

```markdown
Human:
<role>
你是一位资深的后端开发工程师，擅长Python和FastAPI框架。
你编写的代码遵循PEP 8规范，包含详细注释，注重安全性和性能。
</role>

<task>
请使用FastAPI框架开发一个「用户认证和授权」的RESTful API。
</task>

<requirements>
## 功能需求
1. 用户注册（邮箱+密码）
2. 用户登录（返回JWT token）
3. 刷新token
4. 获取当前用户信息
5. 更新用户信息
6. 基于角色的访问控制（RBAC）

## 技术要求
- Python 3.9+
- FastAPI框架
- SQLAlchemy ORM（SQLite数据库，可配置为其他数据库）
- Pydantic进行数据验证
- JWT认证（使用PyJWT）
- 密码哈希（使用bcrypt）
- 包含单元测试

## 代码组织
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

## 输出要求
1. 所有文件的完整代码
2. 详细的中文注释
3. 文档字符串（docstring）
4. 错误处理
5. 输入验证
6. 安全性考虑（SQL注入、XSS、CSRF等）
7. 单元测试代码
8. README.md（包含安装、运行、API文档说明）
</requirements>

<additional_info>
- 使用async/await异步编程
- 添加请求日志
- 包含API速率限制
- 添加Swagger文档（FastAPI自动生成）
</additional_info>

Assistant:
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

```markdown
Human:
<role>
你是一位数据工程师，擅长使用Python进行数据清洗、转换和分析。
你编写的代码高效、可读，善于使用pandas、numpy等库。
</role>

<task>
请编写一个Python脚本，用于处理电商订单数据。
</task>

<data_description>
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
</data_description>

<processing_requirements>
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

## 代码要求
- 使用函数式编程，每个功能模块化
- 添加详细注释和docstring
- 添加日志记录
- 异常处理完善
- 使用配置文件（config.yaml）管理参数
- 提供命令行接口（使用argparse或click）

## 文件结构
```
order_analysis/
├── main.py              # 主程序入口
├── config.yaml          # 配置文件
├── src/
│   ├── __init__.py
│   ├── data_loader.py   # 数据加载模块
│   ├── data_cleaner.py  # 数据清洗模块
│   ├── feature_engine.py # 特征工程模块
│   ├── analyzer.py      # 分析模块
│   └── visualizer.py    # 可视化模块
├── tests/
│   └── test_*.py        # 单元测试
├── data/
│   ├── raw/             # 原始数据
│   └── processed/       # 处理后数据
├── reports/             # 分析报告
└── requirements.txt
```

Assistant:
```

### 4.2 代码审查与优化

#### 示例：代码审查

**提示词**：

```markdown
Human:
<role>
你是一位资深代码审查专家，擅长发现代码中的bug、性能问题、安全漏洞和可维护性issue。
你的审查细致、专业，能够提供建设性的改进建议。
</role>

<task>
请审查以下Python代码，并提供详细的审查报告。
</task>

<code>
&#96;&#96;&#96;python
import mysql.connector
import hashlib

def register_user(username, pasword, email):
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

# Main program
if __name__ == "__main__":
    print(register_user("john", "pass123", "john@example.com"))
    print(login_user("john", "pass123"))
&#96;&#96;&#96;
</code>

<review_criteria>
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

## 输出格式
请提供以下内容的审查报告：
1. 执行摘要（总体评价）
2. 详细问题列表（按严重程度排序）
3. 改进建议（针对每个问题）
4. 重构后的完整代码
5. 改进说明
</review_criteria>

Assistant:
```

**预期输出**：

```markdown
# 代码审查报告

## 1. 执行摘要

❌ **总体评价**：代码存在严重的安全和设计问题，不建议在生产环境使用。

**主要问题**：
- 🔴 严重的SQL注入漏洞
- 🔴 不安全的密码哈希方法（MD5）
- 🔴 敏感信息硬编码
- 🟡 缺乏异常处理
- 🟡 数据库连接管理不当
- 🟢 代码结构简单，易于理解（唯一优点）

## 2. 详细问题列表

### 🔴 严重问题

#### 问题1：SQL注入漏洞
**位置**：`register_user()`和`login_user()`中的SQL语句拼接

**问题描述**：
```python
# 不安全的代码
sql = "INSERT INTO users (username, password, email) VALUES ('" + username + "', '" + hashed_pwd + "', '" + email + "')"
```

如果攻击者输入 `username = "admin'; DROP TABLE users; --"`，将执行恶意SQL。

**修复建议**：使用参数化查询（prepared statements）

#### 问题2：不安全的密码哈希（MD5）
**问题描述**：MD5已被证明不安全，容易被彩虹表攻击破解。

**修复建议**：使用bcrypt、argon2或至少SHA-256。

#### 问题3：敏感信息硬编码
**问题描述**：数据库密码`password123`直接写在代码中。

**修复建议**：使用环境变量或配置文件。

### 🟡 中等问题

#### 问题4：缺乏异常处理
**问题描述**：数据库操作、文件IO等可能抛出异常，但代码中没有`try-except`块。

**修复建议**：添加异常处理，优雅地捕获和处理异常。

#### 问题5：数据库连接未使用上下文管理器
**问题描述**：如果`cursor.execute()`抛出异常，`conn.close()`可能不会执行，导致连接泄露。

**修复建议**：使用`with`语句（上下文管理器）自动管理资源。

### 🟢 轻微问题

#### 问题6：函数命名不规范
**问题描述**：`register_user`和`login_user`应该使用下划线命名（snake_case），这个做得对，但`pasword`参数名拼写错误。

**修复建议**：修正拼写错误为`password`。

## 3. 改进建议

### 建议1：使用参数化查询防止SQL注入
```python
# 不安全
sql = "SELECT * FROM users WHERE username = '" + username + "'"

# 安全
sql = "SELECT * FROM users WHERE username = %s"
cursor.execute(sql, (username,))
```

### 建议2：使用bcrypt哈希密码
```python
import bcrypt

# 哈希密码
hashed = bcrypt.hashpw(password.encode(), bcrypt.gensalt())

# 验证密码
bcrypt.checkpw(password.encode(), hashed)
```

### 建议3：使用环境变量管理敏感信息
```python
import os
from dotenv import load_dotenv

load_dotenv()  # 从.env文件加载环境变量

conn = mysql.connector.connect(
    host=os.getenv("DB_HOST"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)
```

## 4. 重构后的完整代码

```python
import mysql.connector
import bcrypt
import os
from dotenv import load_dotenv
from mysql.connector import pooling
from contextlib import contextmanager

load_dotenv()

# 创建数据库连接池
connection_pool = pooling.MySQLConnectionPool(
    pool_name="user_pool",
    pool_size=5,
    pool_reset_session=True,
    host=os.getenv("DB_HOST", "localhost"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    database=os.getenv("DB_NAME")
)

@contextmanager
def get_db_connection():
    """上下文管理器：自动管理数据库连接。"""
    conn = connection_pool.get_connection()
    try:
        yield conn
    finally:
        conn.close()

def register_user(username: str, password: str, email: str) -> str:
    """
    注册新用户。
    
    Args:
        username: 用户名
        password: 密码（明文）
        email: 邮箱
    
    Returns:
        成功或错误消息
    """
    try:
        # 哈希密码（使用bcrypt）
        hashed_pwd = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
        
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # 使用参数化查询防止SQL注入
                sql = "INSERT INTO users (username, password, email) VALUES (%s, %s, %s)"
                cursor.execute(sql, (username, hashed_pwd, email))
                conn.commit()
        
        return "User registered successfully"
    
    except mysql.connector.IntegrityError:
        return "Error: Username or email already exists"
    except Exception as e:
        return f"Registration failed: {str(e)}"

def login_user(username: str, pasword: str) -> str:
    """
    用户登录。
    
    Args:
        username: 用户名
        password: 密码（明文）
    
    Returns:
        成功或错误消息
    """
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                # 查询用户
                sql = "SELECT password FROM users WHERE username = %s"
                cursor.execute(sql, (username,))
                result = cursor.fetchone()
                
                if result:
                    # 验证密码
                    hashed_pwd = result[0]
                    if bcrypt.checkpw(password.encode(), hashed_pwd.encode()):
                        return "Login successful"
                    else:
                        return "Login failed: Incorrect password"
                else:
                    return "Login failed: User not found"
    
    except Exception as e:
        return f"Login error: {str(e)}"

if __name__ == "__main__":
    # 注意：实际生产环境中，不要硬编码测试数据
    print(register_user("john", "pass123", "john@example.com"))
    print(login_user("john", "pass123"))
```

## 5. 改进说明

### 安全性改进
1. ✅ 使用参数化查询，防止SQL注入
2. ✅ 使用bcrypt哈希密码，提升安全性
3. ✅ 使用环境变量管理敏感信息
4. ✅ 添加异常处理，避免信息泄露

### 代码质量改进
1. ✅ 使用数据库连接池，提升性能
2. ✅ 使用上下文管理器，自动管理资源
3. ✅ 添加函数文档字符串（docstring）
4. ✅ 类型提示（type hints）
5. ✅ 修正拼写错误（`pasword` → `password`）

### 可维护性改进
1. ✅ 分离配置和代码
2. ✅ 使用连接池，便于扩展
3. ✅ 更清晰的错误处理和消息

---

**结论**：原代码存在严重安全漏洞，绝对不能用于生产环境。重构后的代码解决了主要问题，符合安全最佳实践。
```

---

## 5. 数据分析提示词

### 5.1 数据解读

#### 示例：销售数据分析

**提示词**：

```markdown
Human:
<role>
你是一位数据分析师，擅长从数据中提取业务洞察，并提供可操作的建议。
你的分析严谨、客观，注重数据驱动的决策。
</role>

<task>
请分析以下电商平台的销售数据，并提取关键洞察。
</task>

<data>
2024年Q2销售数据（CSV格式）：

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
</data>

<analysis_requirements>
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

## 输出格式
请以Markdown格式输出分析报告，包含：
- 标题和章节结构
- 表格（用于展示数据和对比）
- 要点列表
- 结论和建议

Assistant:
```

**预期输出**：

```markdown
# 2024年Q2电商销售数据分析报告

**数据时间范围**：2024年4月1日 - 2024年6月24日（12周）

---

## 1. 数据概览

### 核心指标变化趋势

| 指标 | 期初值（4月1日） | 期末值（6月24日） | 增长率 |
|------|-----------------|-----------------|--------|
| 销售额 | 150,000元 | 235,000元 | +56.7% |
| 订单数 | 500单 | 800单 | +60.0% |
| 客单价 | 300元 | 294元 | -2.0% |
| 活跃用户数 | 1,200人 | 1,620人 | +35.0% |
| 退货率 | 5.2% | 6.8% | +1.6pp |
| 广告支出 | 15,000元 | 42,000元 | +180.0% |

**初步观察**：销售额和订单数均显著增长，但客单价略有下降，退货率上升，广告支出增长过快。

---

## 2. 关键指标分析

### 2.1 销售额增长率

**周环比增长率**：
- 4月：平均周增长率 +6.7%
- 5月：平均周增长率 +4.8%
- 6月：平均周增长率 +2.3%

**趋势**：销售额持续增长，但增速放缓。

### 2.2 订单数 vs 销售额增长

| 月份 | 订单数增长率 | 销售额增长率 | 分析 |
|------|-------------|-------------|------|
| 4月 | +30.0% | +40.0% | 订单和销售额同步增长 |
| 5月 | +15.4% | +15.8% | 订单和销售额同步增长 |
| 6月 | +6.7% | +6.8% | 订单和销售额同步增长 |

**洞察**：订单数增长与销售额增长高度相关（斜率≈1），说明增长主要来自订单量增加，而非客单价提升。

### 2.3 客单价变化趋势

**趋势图描述**：
```
客单价（元）
310 ┤
300 ┤ ══════════════════╗
290 ┤                 ║
280 ┤                 ╚════════════════════════
270 ┤
    └─────────────────────────────────────────
     4月1日  4月15日  5月1日  5月15日  6月1日  6月24日
```

**分析**：
- 客单价在4月中旬达到峰值（327元），之后持续下降
- 6月客单价稳定在291-294元，下降趋缓

**可能原因**：
1. 促销活动中，用户倾向于购买低价商品
2. 新用户占比增加，首次购买倾向于低价商品
3. 商品结构变化（更多低价商品被推广）

### 2.4 广告支出回报率（ROAS）分析

**ROAS计算公式**：销售额 / 广告支出

| 日期 | 销售额 | 广告支出 | ROAS | 评估 |
|------|--------|---------|------|------|
| 4月1日 | 150,000 | 15,000 | 10.0 | 优秀 |
| 4月15日 | 170,000 | 20,000 | 8.5 | 良好 |
| 5月1日 | 190,000 | 25,000 | 7.6 | 良好 |
| 5月15日 | 210,000 | 30,000 | 7.0 | 可接受 |
| 6月1日 | 225,000 | 38,000 | 5.9 | 偏低 |
| 6月24日 | 235,000 | 42,000 | 5.6 | 偏低 |

**趋势**：ROAS持续下降，从10.0降至5.6。

**问题分析**：
- 广告支出增长（+180%）远高于销售额增长（+56.7%）
- 可能存在广告投放效率下降、受众疲劳、竞争加剧等问题

---

## 3. 相关性分析

### 3.1 广告支出与销售额

**相关系数**：r ≈ 0.97（高度正相关）

**回归分析**：
```
销售额 = 106,52 + 3.01 × 广告支出
```

**解释**：每增加1元广告支出，销售额增加约3.01元。但近期边际效益递减。

### 3.2 活跃用户数与销售额

**相关系数**：r ≈ 0.99（高度正相关）

**分析**：活跃用户数是销售额增长的主要驱动因素。

### 3.3 退货率与客单价

**观察**：
- 客单价较高的时期（4月中旬），退货率较低（4.8%）
- 客单价下降后，退货率上升（6.8%）

**可能解释**：低价商品的质量或用户期望值可能更低，导致退货率上升。

---

## 4. 异常检测

### 异常点1：5月6日订单数激增

**观察**：5月6日当周，订单数从600单激增至700单（+16.7%），但客单价从300元降至292元。

**可能原因**：
- 五一假期促销活动
- 季节性需求（夏季商品开始热销）

**建议**：分析5月6日当周的具体促销活动，复制成功策略。

### 异常点2：6月退货率持续上升

**观察**：6月退货率从5.5%上升至6.8%，超过行业平均水平（通常5%）。

**可能原因**：
1. 商品质量问题
2. 描述与实物不符
3. 用户期望值管理不当

**紧急建议**：立即审查6月退货商品，识别质量问题或描述不符的商品。

---

## 5. 业务洞察

### 洞察1：增长质量下降
虽然销售额持续增长，但增长质量在下降：
- 客单价下降（从327元降至291元）
- 广告效率下降（ROAS从10.0降至5.6）
- 退货率上升（从5.2%升至6.8%）

**建议**：不应只关注GMV增长，应关注增长质量和利润率。

### 洞察2：新用户获取成本高企
广告支出增长180%，但销售额仅增长56.7%，说明新用户获取成本（CAC）在上升。

**建议**：
1. 优化广告投放策略（受众定向、创意优化）
2. 提高复购率，降低对广告的依赖

### 洞察3：客单价下降需要警惕
客单价下降可能意味着：
1. 用户消费能力下沉
2. 商品结构不合理（低价商品占比过高）
3. 促销过度，用户习惯了折扣

**建议**：推出高客单价商品的营销策略（捆绑销售、满减、会员专享等）。

### 洞察4：退货率是红色信号
退货率超过6.5%需要立即关注，可能导致：
1. 利润侵蚀（物流成本、商品损耗）
2. 用户体验下降
3. 品牌声誉受损

**建议**：建立退货原因分析机制，区分质量问题、描述不符、用户主观原因等。

### 洞察5：活跃用户增长是亮点
活跃用户数增长35%，说明用户获取和留存策略有效。

**建议**：
1. 继续投资用户增长
2. 但同时提高用户生命周期价值（LTV）

---

## 6. 建议

### 建议1：优化广告投放，提升ROAS（紧急）

**行动**：
1. 暂停低效广告渠道（ROAS < 4.0）
2. A/B测试不同广告创意和受众定向
3. 引入归因分析，了解各渠道的真实贡献
4. 设置广告支出上限，避免过度烧钱

**预期效果**：ROAS提升至7.0+

### 建议2：客单价提升计划（重要）

**行动**：
1. 推出捆绑销售（Bundle）策略
2. 设置满减门槛（如满399减50）
3. 推广高客单价商品（专题页、推荐位）
4. 会员专享折扣（仅限高客单价商品）

**预期效果**：客单价回升至310元+

### 建议3：退货率控制计划（紧急）

**行动**：
1. 立即审查退货率TOP 20的商品
2. 对质量问题商品下架或改进
3. 优化商品描述和图片，避免过度美化
4. 引入"试穿/试用"服务，降低退货意愿
5. 设置退货政策（如"7天无理由退货"但用户承担运费）

**预期效果**：退货率降至5.5%以下

### 建议4：提升用户复购率（重要）

**行动**：
1. 建立用户分层体系（新用户、活跃用户、沉睡用户）
2. 针对沉睡用户（30天未购买）推送个性化优惠
3. 引入订阅模式或会员计划
4. 优化推荐算法，提升交叉销售（Cross-sell）和向上销售（Up-sell）

**预期效果**：复购率提升15%+

---

## 7. 结论

Q2数据显示，平台在用户增长和销售额增长上取得了显著成绩，但增长质量存在隐患：
1. 广告效率下降
2. 客单价下降
3. 退货率上升

**核心建议**：从"追求GMV增长"转向"追求利润增长"，优化广告投放、提升客单价、控制退货率。

**下一步**：建议每周跟踪核心指标，建立预警机制（如退货率>6%自动报警）。
```

---

## 6. 推理任务提示词

### 6.1 逻辑推理

#### 示例：演绎推理

**提示词**：

```markdown
Human:
<role>
你是一位逻辑推理专家，擅长演绎推理、归纳推理和批判性思维。
你的推理严谨、清晰，能够让读者轻松跟随你的思路。
</role>

<task>
请解决以下逻辑推理问题，并详细展示推理过程。
</task>

<problem>
所有的哺乳动物都是脊椎动物。
所有的猫都是哺乳动物。
请问：所有的猫都是脊椎动物吗？
</problem>

<reasoning_steps>
请按以下步骤推理：

1. **理解问题**：重述问题，确保准确理解。
2. **列出已知前提**：清晰列出所有给定的前提。
3. **分析逻辑关系**：识别前提之间的逻辑关联。
4. **应用推理规则**：使用演绎推理（如三段论）。
5. **检查有效性**：验证推理过程是否符合逻辑规则。
6. **得出结论**：给出明确的最终答案。
7. **反思**：思考是否存在反例或边界情况。
</reasoning_steps>

<output_format>
请以清晰的Markdown格式输出推理过程，包含：
- 标题和分节
- 逻辑符号（如⊆表示包含于）
- 示范性解释
</output_format>

Assistant:
```

**预期输出**：

```markdown
# 逻辑推理分析

## 1. 理解问题

**问题重述**：给定两个前提："所有的哺乳动物都是脊椎动物"和"所有的猫都是哺乳动物"，问是否"所有的猫都是脊椎动物"。

**问题类型**：演绎推理（三段论）

---

## 2. 列出已知前提

**前提1（Premise 1）**：所有的哺乳动物都是脊椎动物。  
符号化表示：若 X 是哺乳动物，则 X 是脊椎动物。  
∀X: Mammal(X) → Vertebrate(X)

**前提2（Premise 2）**：所有的猫都是哺乳动物。  
符号化表示：若 X 是猫，则 X 是哺乳动物。  
∀X: Cat(X) → Mammal(X)

**待证结论（Conclusion to Prove）**：所有的猫都是脊椎动物。  
符号化表示：若 X 是猫，则 X 是脊椎动物。  
∀X: Cat(X) → Vertebrate(X)

---

## 3. 分析逻辑关系

### 关系图

```
Cat (猫)
  │
  │ ⊆ (包含于)
  ▼
Mammal (哺乳动物)
  │
  │ ⊆ (包含于)
  ▼
Vertebrate (脊椎动物)
```

### 逻辑链

前提2建立了"猫"和"哺乳动物"的包含关系：  
Cat ⊆ Mammal

前提1建立了"哺乳动物"和"脊椎动物"的包含关系：  
Mammal ⊆ Vertebrate

根据包含关系的传递性（Transitivity）：  
如果 A ⊆ B 且 B ⊆ C，则 A ⊆ C

因此：  
Cat ⊆ Vertebrate

---

## 4. 应用推理规则

### 三段论（Syllogism）

这是一个典型的三段论结构：

- **大前提（Major Premise）**：所有的哺乳动物都是脊椎动物。
- **小前提（Minor Premise）**：所有的猫都是哺乳动物。
- **结论（Conclusion）**：所有的猫都是脊椎动物。

### 形式化证明

1. ∀X: Cat(X) → Mammal(X) 【前提2】
2. ∀X: Mammal(X) → Vertebrate(X) 【前提1】
3. 取任意个体 a
4. 假设 Cat(a) 【假设a是猫】
5. Mammal(a) 【4, 1, 假言推理（Modus Ponens）】
6. Vertebrate(a) 【5, 2, 假言推理】
7. Cat(a) → Vertebrate(a) 【4-6, 条件引入】
8. ∀X: Cat(X) → Vertebrate(X) 【7, 全称引入】

**证毕（QED）**

---

## 5. 检查有效性

### 有效性标准

一个推理是**有效的（Valid）**，当且仅当：如果所有前提为真，则结论必然为真。

### 验证

- 假设前提1为真（所有哺乳动物都是脊椎动物）
- 假设前提2为真（所有猫都是哺乳动物）
- 在这些假设下，结论（所有猫都是脊椎动物）**必然为真**

✅ **推理有效**

### 是否可靠（Sound）？

一个推理是**可靠的（Sound）**，当且仅当：
1. 推理有效
2. 所有前提实际上为真

在现实中：
- 前提1为真（哺乳动物确实是脊椎动物）
- 前提2为真（猫确实是哺乳动物）
- 因此，这个推理既是有效的，也是可靠的

✅ **推理可靠**

---

## 6. 得出结论

**最终答案**：✅ **是的，所有的猫都是脊椎动物。**

**推理总结**：
- 因为所有的猫都是哺乳动物（前提2）
- 且所有的哺乳动物都是脊椎动物（前提1）
- 所以，所有的猫都是脊椎动物（传递性）

---

## 7. 反思

### 可能的误区

❌ **误区1**：混淆"所有A是B"与"所有B是A"  
- "所有的猫都是哺乳动物" ≠ "所有的哺乳动物都是猫"  
- 包含关系是单向的，不是双向的

✅ **正确理解**：猫是哺乳动物的子集，哺乳动物是脊椎动物的子集。

### 边界情况

❓ **问题**：如果存在一个"非典型猫"（如基因突变），结论是仍然成立？  
✅ **答案**：是的。前提中"所有的猫"指的是猫这个物种的定义，而不是个体差异。如果一个动物不满足"哺乳动物"的定义，它就不会被分类为"猫"。

### 逻辑规则总结

这个推理应用了以下逻辑规则：
1. **假言推理（Modus Ponens）**：如果 P→Q 且 P，则 Q
2. **传递性（Transitivity）**：如果 A⊆B 且 B⊆C，则 A⊆C
3. **全称量化（Universal Quantification）**：∀X 表示"对于所有X"

---

## 8. 拓展思考

### 逆命题、否命题、逆否命题

对于给定的命题："所有的猫都是脊椎动物"（Cat → Vertebrate）

1. **逆命题**：所有的脊椎动物都是猫。（❌ 错误）
2. **否命题**：不是猫的动物不是脊椎动物。（❌ 错误）
3. **逆否命题**：不是脊椎动物的动物不是猫。（✅ 正确）

**逻辑等价性**：原命题 ↔ 逆否命题

---

## 总结

通过严谨的演绎推理，我们证明了"所有的猫都是脊椎动物"这一结论。推理过程有效且可靠，符合逻辑规则。

**核心要点**：
- 使用三段论结构
- 应用包含关系的传递性
- 验证推理的有效性和可靠性
- 避免常见的逻辑误区
```

---

## 7. 高级技巧

### 7.1 思维链（Chain-of-Thought）在Claude中的应用

Claude特别擅长长链条推理，可以通过以下方式激活：

#### 示例：复杂数学问题

**提示词**：

```markdown
Human:
<instructions>
请解决以下数学问题。在给出最终答案之前，你必须：

1. **理解问题**：重述问题，确保理解
2. **识别已知和未知**：列出已知条件和待求量
3. **制定解题策略**：选择适当的解题方法
4. **逐步计算**：展示每一步计算过程
5. **验证答案**：检查答案的合理性
6. **总结**：用一句话概括答案

非常重要：不要跳过任何步骤，即使你认为很简单。
</instructions>

<problem>
一个农场有鸡和兔子共35只，共有94只脚。请问鸡和兔子各有多少只？
</problem>

Assistant:
```

**预期输出**：

```markdown
# 解题过程

## 1. 理解问题

**问题重述**：一个农场里共有35只动物，这些动物要么是鸡，要么是兔子。已知这些动物总共有94只脚。问：鸡有多少只？兔子有多少只？

**关键信息**：
- 总动物数：35只
- 总脚数：94只
- 鸡的脚数：2只/只
- 兔子的脚数：4只/只

---

## 2. 识别已知和未知

**已知条件**：
- 鸡的数量 + 兔子的数量 = 35
- 鸡的脚数 + 兔子的脚数 = 94
- 每只鸡有2只脚
- 每只兔子有4只脚

**未知量**：
- 鸡的数量（设为 x）
- 兔子的数量（设为 y）

---

## 3. 制定解题策略

**方法选择**：建立二元一次方程组

**理由**：
- 有两个未知量（鸡的数量、兔子的数量）
- 有两个等量关系（总数量、总脚数）
- 可以使用代入法或消元法求解

---

## 4. 逐步计算

### 步骤1：建立方程

根据已知条件，可以建立以下方程组：

\[
\begin{cases}
x + y = 35 & \text{(1) 总数量方程} \\
2x + 4y = 94 & \text{(2) 总脚数方程}
\end{cases}
\]

其中：
- \(x\) = 鸡的数量
- \(y\) = 兔子的数量

### 步骤2：化简方程

观察方程(2)，可以两边同时除以2，化简得：

\[
x + 2y = 47 \quad \text{(3)}
\]

### 步骤3：使用消元法

现在我们有：
\[
\begin{cases}
x + y = 35 & \text{(1)} \\
x + 2y = 47 & \text{(3)}
\end{cases}
\]

用方程(3)减去方程(1)：

\[
(x + 2y) - (x + y) = 47 - 35
\]

化简：

\[
x + 2y - x - y = 12
\]
\[
y = 12
\]

### 步骤4：求解 x

将 \(y = 12\) 代入方程(1)：

\[
x + 12 = 35
\]
\[
x = 35 - 12
\]
\[
x = 23
\]

### 步骤5：得出答案

- 鸡的数量：23只
- 兔子的数量：12只

---

## 5. 验证答案

### 验证1：总数量

\[
x + y = 23 + 12 = 35 \quad ✓
\]

符合题目条件。

### 验证2：总脚数

鸡的脚数：\(23 \times 2 = 46\)  
兔子的脚数：\(12 \times 4 = 48\)  
总脚数：\(46 + 48 = 94\) ✓

符合题目条件。

### 验证3：合理性检查

- 鸡和兔子的数量都是正整数 ✓
- 数量在合理范围内（没有负数或过大）✓
- 脚数计算正确 ✓

**结论**：答案合理。

---

## 6. 总结

**最终答案**：农场有**23只鸡**和**12只兔子**。

**解题关键**：
- 将实际问题转化为数学模型（方程组）
- 使用消元法求解方程组
- 验证答案的合理性

---

## 拓展：其他解题方法

### 方法2：假设法（算术方法）

**思路**：假设所有动物都是鸡，然后计算差值。

**步骤**：
1. 假设35只都是鸡，总脚数 = \(35 \times 2 = 70\)
2. 实际总脚数 = 94
3. 差值 = \(94 - 70 = 24\)
4. 每将1只鸡替换为1只兔子，脚数增加 \(4 - 2 = 2\)
5. 需要替换的次数 = \(24 \div 2 = 12\)
6. 因此，兔子数量 = 12只，鸡数量 = \(35 - 12 = 23\)只

**答案一致** ✓

---

## 最终结论

通过多种方法验证，确认答案正确：

\[
\boxed{鸡 = 23 \text{只}, \quad 兔子 = 12 \text{只}}
\]
```

### 7.2 思维树（Tree of Thoughts）在Claude中的应用

对于需要探索多个可能性的问题，可以让Claude生成和评估多个思路。

#### 示例：复杂决策问题

**提示词**：

```markdown
Human:
<task>
我们需要决定是否投资一个新的AI创业公司。请使用思维树（Tree of Thoughts）方法，生成和评估多个决策思路。
</task>

<company_info>
创业公司信息：
- 业务：开发企业级AI客服平台
- 阶段：种子轮，寻求500万美元投资
- 团队：3位创始人（2位技术，1位销售），均无创业经验
- 产品：MVP已完成，有3个付费客户
- 市场：企业AI客服市场预计2027年达到300亿美元
- 竞争：已有数家成熟竞争对手（如Intercom、Zendesk AI）
- 估值：2000万美元（Pre-money）
</company_info>

<requirements>
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

<output_format>
请以Markdown格式输出，包含：
- 每个策略的详细描述
- 评估表格
- 决策树图（用ASCII艺术或文字描述）
- 最终建议和理由
</output_format>

Assistant:
```

### 7.3 使用Claude的长文档处理能力

Claude的200K上下文窗口使其能够处理非常长的文档。可以通过以下方式充分利用：

#### 示例：长文档摘要和分析

**提示词**：

```markdown
Human:
<task>
我将会提供一份很长的研究报告（约2万字）。请你：

1. 提取核心观点和结论
2. 总结每个章节的要点
3. 识别报告中的数据和证据
4. 评估论证的逻辑性和完整性
5. 提供关键引用（如果有的话）
</task>

<document>
[在此粘贴长篇文档，可能包含数万字]
</document>

<output_requirements>
请以以下格式输出：

1. **执行摘要**（300字以内）
   - 报告的核心结论
   - 主要发现和观点

2. **章节摘要**
   对每个章节，提供：
   - 章节标题
   - 核心论点（1-2句话）
   - 关键证据或数据

3. **数据和证据清单**
   列出报告中的所有重要数据，包含：
   - 数据描述
   - 数值
   - 来源（如果报告中有提及）

4. **论证评估**
   - 论证是否逻辑严密？
   - 是否有数据支撑？
   - 是否存在逻辑漏洞或偏见？

5. **关键引用**
   如果报告引用了其他研究或专家观点，列出最重要的3-5条。

<tone>
客观、简洁、准确。不要添加报告中没有的信息。
</tone>

Assistant:
```

---

## 8. 配置参数建议

### 8.1 Max Tokens（最大生成长度）

Claude的`max_tokens`参数控制模型生成的最大token数。

**建议设置**：

| 任务类型 | 推荐Max Tokens | 说明 |
|---------|----------------|------|
| 简单问答 | 500 - 1,000 | 足够输出简洁答案 |
| 文章写作 | 2,000 - 4,000 | 约1500-3000字 |
| 长文档分析 | 4,096 - 8,192 | 处理长文档摘要 |
| 代码生成 | 2,000 - 4,000 | 完整代码文件 |
| 数据分析报告 | 3,000 - 5,000 | 详细分析报告 |

**注意**：Claude 3.5 Sonnet支持最多8192 tokens的输出。

**示例**：

```python
import anthropic

client = anthropic.Anthropic(api_key="your-api-key")

message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=4096,  # 限制输出长度
    messages=[
        {"role": "user", "content": "请撰写一篇关于AI伦理的长篇文章..."}
    ]
)
```

### 8.2 Temperature（温度）

Claude的`temperature`参数控制生成文本的随机性。

**建议设置**：

| 任务类型 | 推荐Temperature | 说明 |
|---------|----------------|------|
| 事实性任务（摘要、翻译、问答） | 0.0 - 0.3 | 低温度使输出更确定、一致 |
| 通用对话和解释 | 0.3 - 0.7 | 平衡创造性和连贯性 |
| 创意写作（故事、诗歌） | 0.7 - 1.0 | 高温度增加多样性和创意 |
| 代码生成 | 0.2 - 0.5 | 较低温度确保语法正确 |

**示例**：

```python
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=4096,
    temperature=0.3,  # 事实性任务，使用低温度
    messages=[
        {"role": "user", "content": "请将以下文章翻译为英文：[文章内容]"}
    ]
)
```

### 8.3 Top P（核采样）

Claude也支持`top_p`参数，控制生成时考虑的token范围。

**建议设置**：

| 场景 | 推荐Top P | 说明 |
|------|-----------|------|
| 高质量输出 | 0.9 | 默认设置，平衡质量和多样性 |
| 需要更多创造性 | 0.95 - 0.99 | 从高概率token中采样 |
| 需要更确定性输出 | 0.8 - 0.9 | 缩小采样范围 |

**注意**：通常只需要调整`temperature`或`top_p`中的一个，不要同时调整两个。

### 8.4 Stop Sequences（停止序列）

`stop_sequences`参数可以指定模型在生成到某个序列时停止。

**使用场景**：

1. **强制JSON输出**

```python
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=1000,
    stop_sequences=["```\n\n"],  # 遇到```\n\n时停止
    messages=[
        {"role": "user", "content": "请以JSON格式输出结果：\n\n```json\n"}
    ]
)
```

2. **控制输出长度**

```python
# 在生成到一定长度后停止
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=2000,
    stop_sequences=["\n\n---\n\n"],  # 遇到分隔线时停止
    messages=[
        {"role": "user", "content": "请写一篇文章，在适当位置用---\n\n分隔章节"}
    ]
)
```

### 8.5 推荐配置组合

#### 配置1：精准翻译任务

```python
{
    "model": "claude-3-5-sonnet-20240620",
    "max_tokens": 2000,
    "temperature": 0.2,  # 低温度确保翻译准确
    "top_p": 0.9
}
```

#### 配置2：创意写作

```python
{
    "model": "claude-3-5-sonnet-20240620",
    "max_tokens": 4096,
    "temperature": 0.85,  # 高温度增加创意
    "top_p": 0.95
}
```

#### 配置3：代码生成

```python
{
    "model": "claude-3-5-sonnet-20240620",
    "max_tokens": 3000,
    "temperature": 0.3,  # 较低温度确保代码正确
    "top_p": 0.9,
    "stop_sequences": ["\n\n```\n"]  # 代码块结束后停止
}
```

#### 配置4：长文档分析

```python
{
    "model": "claude-3-5-sonnet-20240620",
    "max_tokens": 8192,  # 使用最大输出长度
    "temperature": 0.4,  # 适度创造性
    "top_p": 0.9
}
```

---

## 9. 常见错误与解决方案

### 9.1 输出过于冗长

**问题描述**：Claude容易生成过长的输出，超出预期长度。

**解决方案**：

#### 方法1：明确指定字数要求

```markdown
Human:
请撰写一篇产品评测文章。

要求：
- **字数：1500-1800字**（严格遵守）
- 结构：[列出结构]
- 风格：[描述风格]

非常重要：请确保字数在要求范围内，不要超出。
```

#### 方法2：设置max_tokens限制

```python
message = client.messages.create(
    model="claude-3-5-sonnet-20240620",
    max_tokens=2500,  # 1800字约需2500 tokens（中文）
    messages=[...]
)
```

#### 方法3：在提示词中强调简洁

```markdown
Human:
<instructions>
你是一位简洁高效的助手。回答问题时：
1. 直击要点，避免冗长的铺垫
2. 删除不必要的重复
3. 使用简洁的语言表达复杂的概念
4. 如果可以用一句话说清楚，不要用一段话
</instructions>

<task>
请解释什么是区块链。
</task>
```

### 9.2 角色扮演不够自然

**问题描述**：Claude在角色扮演时，输出不够自然或不符合角色设定。

**解决方案**：

#### 方法1：提供详细的角色设定

```markdown
Human:
<role>
你是一位拥有20年经验的心理咨询师，专注于认知行为疗法（CBT）。
你的咨询风格：
- 同理心强，善于倾听
- 引导式提问，而非直接给出建议
- 使用开放式问题鼓励客户自我探索
- 保持专业边界，不超越咨询师职责
- 语言温和、 supportive，但不过度亲密

在咨询中，你会：
- 反射客户的情感（"我听到你感到..."）
- 正常化客户的体验（"很多人面对类似情况时会有相同感受..."）
- 布置小而可行的行动作业
- 避免评判或指责
</role>

<scenario>
客户是一位28岁的年轻专业人士，因为工作压力感到焦虑，前来咨询。
</scenario>

<task>
请以咨询师的身份，开始第一次咨询对话。
</task>
```

#### 方法2：提供角色扮演示例

```markdown
Human:
我将给你展示心理咨询师与客户的对话示例，然后请你扮演咨询师继续对话。

<example>
客户："我最近工作压力很大，感觉快撑不住了。"
咨询师："听起来你最近承受了很多压力，能具体说说是什么让你感到'快撑不住了吗？"（反射情感 + 开放式提问）

客户："每天都有开不完的会，回不完的邮件，感觉根本没时间做实际工作。"
咨询师："我理解，那种一直'救火'却无法专注真正重要的工作的感觉确实很frustrating。你提到'实际工作'，能告诉我你认为最重要的工作是什么吗？"（正常化 + 探索价值观）
</example>

现在，请继续以下对话：

客户："我觉得自己一直让团队失望。项目进度落后，我感觉很自责。"
咨询师：（请你回答）
```

### 9.3 输出格式不符合要求

**问题描述**：期望JSON或其他结构化输出，但Claude输出纯文本。

**解决方案**：

#### 方法1：预填充响应（Pre-filling）

```markdown
Human:
请分析以下句子的情感，并以JSON格式输出。

句子："这个产品真的很棒，超出我的预期！"

输出格式：
{
  "sentiment": "[Positive/Neutral/Negative]",
  "confidence": [0-1],
  "reasoning": "[解释]"
}

Assistant:
{
  "sentiment": "Positive",
```

（Claude会继续完成JSON）

#### 方法2：使用XML标签结构化输出

```markdown
Human:
请分析以下文章的要点，并按以下XML格式输出：

<analysis>
  <summary>[摘要]</summary>
  <key_points>
    <point>[要点1]</point>
    <point>[要点2]</point>
    ...
  </key_points>
  <sentiment>[情感倾向]</sentiment>
</analysis>

文章：
[文章内容]
```

#### 方法3：明确输出格式要求

```markdown
Human:
<task>
分析以下数据，并以JSON格式输出结果。
</task>

<data>
[数据内容]
</data>

<output_format>
输出必须严格符合以下JSON Schema：

{
  "type": "object",
  "properties": {
    "summary": {"type": "string"},
    "key_points": {
      "type": "array",
      "items": {"type": "string"}
    },
    "sentiment": {
      "type": "string",
      "enum": ["positive", "neutral", "negative"]
    }
  },
  "required": ["summary", "key_points", "sentiment"]
}

非常重要：
1. 输出必须是合法的JSON
2. 不要添加任何JSON以外的内容
3. 使用双引号，不要使用单引号
</output_format>
```

### 9.4 推理错误或不完整

**问题描述**：Claude在复杂推理任务中出错，或推理步骤不完整。

**解决方案**：

#### 方法1：强制逐步推理

```markdown
Human:
<instructions>
在解决以下数学问题之前，你必须：

1. **列出已知条件**：将所有已知信息清晰列出
2. **建立数学模型**：将问题转化为数学语言
3. **分步计算**：展示每一步计算过程，不要跳步
4. **验证答案**：检查答案的合理性

非常重要：如果有任何步骤不清晰，请停下来解释，不要继续。
</instructions>

<problem>
[数学问题]
</problem>
```

#### 方法2：使用"Let's think step by step"

```markdown
Human:
请解决以下逻辑推理问题。让我们逐步思考：

问题：[问题内容]

步骤1：[Claude会开始逐步推理]
```

#### 方法3：要求自我检查

```markdown
Human:
<task>
请解决以下复杂问题。
</task>

<requirements>
在完成解答后，你必须：

1. **自我检查**：回顾你的解答，检查是否有错误
2. **验证答案**：使用不同方法验证（如果可能）
3. **指出不确定性**：如果有任何步骤你不确定，请明确指出来
4. **提供改进方向**：如果答案可能不完美，提供改进的思路

不要直接给出答案，然后就结束。自我检查是强制性的。
</requirements>
```

---

## 10. 实用提示词模板

### 模板1：长文档分析

```markdown
Human:
<role>
你是一位[角色，如：法律分析师/医学研究者/商业顾问]，擅长阅读和分析长篇文档。
你的分析严谨、客观，能够提取关键信息并识别潜在风险。
</role>

<task>
请分析以下[文档类型，如：合同/研究报告/商业计划书]，并提供详细分析。
</task>

<document>
[在此粘贴长篇文档]
</document>

<analysis_requirements>
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

<output_format>
请以Markdown格式输出，包含标题、段落、列表和表格（如果需要）。
</output_format>

Assistant:
```

### 模板2：角色扮演对话

```markdown
Human:
<role>
你是一位[角色名称，如：心理咨询师/职业顾问/技术导师]，具有以下特征：

- 背景：[描述角色的背景和经验]
- 性格：[描述性格特点，如：耐心、严格、幽默等]
- 沟通风格：[描述沟通风格，如：温和但坚定/直接且不客气/鼓励式]
- 专业领域：[列出专业领域]
</role>

<scenario>
[描述具体场景，如：客户前来咨询职业转型/学生请教编程学习路径]
</scenario>

<task>
请以角色的 identity，与用户进行对话。在对话中：

1. **保持角色一致性**：所有回复都应该符合角色设定
2. **使用角色的口吻**：包括用词、句式、语气
3. **展现角色的专业知识**：提供专业、可信的建议
4. **适度展现角色的性格**：让对话更真实、有温度

<dialogue_format>
对话格式：

[角色名]：[对话内容]

如果用户没有指定回复，你可以主动提问或引导对话。
</dialogue_format>

Assistant:
```

### 模板3：数据分析和可视化建议

```markdown
Human:
<role>
你是一位数据分析师和可视化专家，擅长从数据中提取洞察，并选择最合适的图表类型展示数据。
</role>

<task>
我有以下数据，请帮我分析并推荐合适的可视化方案。
</task>

<data_description>
数据描述：
- 数据来源：[描述数据来源]
- 数据规模：[行数、列数]
- 字段列表：[列出字段名和含义]
- 示例数据：[提供几行示例数据]
</data_description>

<analysis_requirements>
请完成以下任务：

1. **数据理解**
   - 各字段的数据类型
   - 数据质量评估（缺失值、异常值等）
   - 数据分布特征

2. **分析目标**
   基于数据特点，我可能想要了解：
   - [分析目标1，如：趋势分析]
   - [分析目标2，如：对比分析]
   - [分析目标3，如：相关性分析]

3. **可视化推荐**
   对每个分析目标，推荐：
   - 最佳图表类型（如：折线图、柱状图、散点图等）
   - 推荐理由
   - 设计建议（颜色、标签、图例等）
   - 需要避免的常见错误

4. **分析建议**
   - 除了可视化，还可以进行哪些统计分析？
   - 如何深入挖掘数据价值？

<output_format>
请以Markdown格式输出，包含：
- 标题和分节
- 表格（用于对比不同图表类型）
- 图表描述（用文字描述预期的图表效果）
- 代码示例（如果使用Python/R，提供代码框架）
</output_format>

Assistant:
```

### 模板4：代码审查和重构

```markdown
Human:
<role>
你是一位资深代码审查专家，擅长发现代码中的bug、性能问题、安全漏洞和可维护性问题。
你的审查细致、专业，能够提供建设性的改进建议，并能够重构代码。
</role>

<task>
请审查以下[语言]代码，并提供详细的审查报告和重构建议。
</task>

<code>
[在此粘贴需要审查的代码]
</code>

<review_criteria>
请从以下维度审查代码：

1. **正确性**
   - 是否有bug？
   - 边界条件是否处理？
   - 算法是否正确？

2. **安全性**
   - 是否有安全漏洞（如SQL注入、XSS、缓冲区溢出等）？
   - 是否有敏感信息泄露？
   - 输入验证是否充分？

3. **性能**
   - 是否有性能瓶颈？
   - 时间复杂度和空间复杂度是否合理？
   - 是否有优化空间？

4. **可维护性**
   - 命名是否规范？
   - 代码是否易于理解？
   - 是否有适当的注释和文档？
   - 是否遵循语言和行业的编码规范？

5. **可扩展性**
   - 代码是否易于扩展？
   - 是否遵循SOLID原则？
   - 是否有适当的抽象和模块化？

<output_format>
请提供以下内容的审查报告：

1. **执行摘要**（总体评价）
2. **详细问题列表**（按严重程度排序：🔴严重 / 🟡中等 / 🟢轻微）
3. **改进建议**（针对每个问题）
4. **重构后的代码**（完整的、可运行的）
5. **改进说明**（列出主要改进点）

格式：Markdown，包含代码块、表格、列表等。
</output_format>

Assistant:
```

### 模板5：决策分析

```markdown
Human:
<role>
你是一位决策分析专家，擅长使用结构化方法（如决策树、SWOT分析、成本效益分析等）帮助人们做出复杂决策。
你的分析客观、全面，能够权衡利弊，并提供明确的建议。
</role>

<task>
我面临一个重要的决策，请帮我分析并给出建议。
</task>

<decision_context>
决策背景：
[描述你面临的决策，如：选择哪个工作offer/是否投资某个项目/选择哪种技术方案]

可选方案：
- 方案A：[描述]
- 方案B：[描述]
- 方案C：[描述]（如果有）

决策约束：
- 时间约束：[如有]
- 预算约束：[如有]
- 其他限制：[如有]
</decision_context>

<analysis_framework>
请使用以下框架进行分析：

1. **SWOT分析**（对每个方案）
   - Strengths（优势）
   - Weaknesses（劣势）
   - Opportunities（机会）
   - Threats（威胁）

2. **成本效益分析**
   对每个方案，评估：
   - 直接成本
   - 间接成本
   - 预期收益
   -  intangible收益（如品牌、声誉等）

3. **风险评估**
   对每个方案，识别：
   - 主要风险
   - 风险发生概率
   - 风险影响程度
   - 风险缓解措施

4. **决策矩阵**
   建立决策矩阵，对不同方案打分（1-10分）：
   - 成本（越低越好）
   - 收益（越高越好）
   - 风险（越低越好）
   - 可行性（越高越好）
   - 战略性（越高越好）

5. **敏感性分析**
   如果关键假设发生变化，决策是否会改变？

<output_format>
请以Markdown格式输出分析报告，包含：
- SWOT表格
- 成本效益对比表
- 风险矩阵
- 决策矩阵（打分表）
- 最终建议（明确、有理由支撑）

<tone>
客观、数据驱动、实用。避免模糊的表述，给出明确的建议。
</tone>

Assistant:
```

---

## 11. 参考资料

### 官方文档

1. **Anthropic Documentation**  
   https://docs.anthropic.com/  
   Claude的官方API文档，包含模型介绍、API参考、最佳实践。

2. **Claude Prompt Engineering Guide**  
   https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering  
   Anthropic官方的提示词工程指南，详细介绍Claude的提示词技巧。

3. **Claude 3 Model Card**  
   https://www-cdn.anthropic.com/de8ba9b01c9ab7cbabf5c33b80b7bbc618857627/Model_Card_Claude_3.pdf  
   Claude 3系列的模型卡片，包含模型能力、限制、安全评估等信息。

4. **Anthropic Cookbook**  
   https://github.com/anthropics/anthropic-cookbook  
   丰富的Claude使用案例和代码示例。

### 社区资源

1. **Awesome Claude Prompts**  
   https://github.com/anthropics/awesome-claude-prompts  
   Claude提示词示例集合，涵盖各种场景。

2. **Prompt Engineering for Claude**  
   https://www.promptingguide.ai/models/claude  
   PromptingGuide.ai上的Claude提示词指南。

3. **Anthropic Community Forum**  
   https://community.anthropic.com/  
   官方社区论坛，可以提问、分享经验、获取帮助。

### 视频教程

1. **Anthropic YouTube Channel**  
   https://www.youtube.com/@AnthropicAI  
   官方视频教程，包含产品介绍、使用案例等。

2. **DeepLearning.AI - ChatGPT Prompt Engineering for Developers**  
   https://www.deeplearning.ai/short-courses/chatgpt-prompt-engineering-for-developers/  
   虽然是针对ChatGPT的，但很多技巧也适用于Claude。

### 相关论文

1. **"Constitutional AI: Harmlessness from AI Feedback"** (Bai et al., 2022)  
   Anthropic提出的技术，通过AI反馈训练更安全的大语言模型。

2. **"Training a Helpful and Harmless Assistant with RLHF"** (Bai et al., 2022)  
   介绍Claude的训练方法，包括RLHF（人类反馈的强化学习）。

3. **"Measuring Progress on Scalable Oversight for Large Language Models"** (Bowman et al., 2022)  
   评估大语言模型的可扩展性监督方法。

---

## 📝 更新日志

- **2026-05-18**：初始版本发布，完成Claude 3系列提示词指南
- 包含Claude 3.5 Sonnet/Opus/Haiku的详细提示词技巧
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
