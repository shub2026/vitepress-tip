# OpenAI GPT 提示词最佳实践指南

> 掌握 GPT-4、GPT-4o、GPT-3.5 和 DALL-E 的提示词技巧，充分发挥OpenAI模型的强大能力

![OpenAI Logo](https://img.shields.io/badge/OpenAI-GPT--4%2FGPT--4o%2FGPT--3.5-orange)
![Status](https://img.shields.io/badge/状态-已完成-green)

---

## 📋 目录

1. [模型概述](#1-模型概述)
2. [提示词基础](#2-提示词基础)
3. [写作任务提示词](#3-写作任务提示词)
4. [代码开发提示词](#4-代码开发提示词)
5. [图像生成提示词（DALL-E）](#5-图像生成提示词dall-e)
6. [数据分析提示词](#6-数据分析提示词)
7. [推理任务提示词](#7-推理任务提示词)
8. [高级技巧](#8-高级技巧)
9. [配置参数建议](#9-配置参数建议)
10. [常见错误与解决方案](#10-常见错误与解决方案)
11. [实用提示词模板](#11-实用提示词模板)
12. [参考资料](#12-参考资料)

---

## 1. 模型概述

### 1.1 模型版本与特点

| 模型 | 发布时间 | 上下文窗口 | 核心能力 | 适用场景 |
|------|---------|-----------|---------|---------|
| **GPT-4o** | 2024年5月 | 128K tokens | 多模态（文本+图像+音频）、最快速度 | 实时对话、图像分析、语音交互 |
| **GPT-4 Turbo** | 2023年11月 | 128K tokens | 最强推理、知识截止2024年4月 | 复杂推理、专业写作、代码开发 |
| **GPT-4** | 2023年3月 | 8K/32K tokens | 强推理、高准确性 | 学术研究、法律分析、医疗咨询 |
| **GPT-3.5 Turbo** | 2023年3月 | 16K tokens | 性价比高、速度快 | 简单任务、大规模应用、原型开发 |
| **DALL-E 3** | 2023年9月 | N/A | 高质量图像生成 | 创意设计、视觉内容创作 |

### 1.2 核心优势

✅ **推理能力强**：在逻辑推理、数学计算、代码理解方面表现出色  
✅ **多模态支持**：GPT-4o支持图像输入和生成  
✅ **生态完善**：丰富的API、SDK和第三方工具支持  
✅ **函数调用**：结构化输出，便于集成外部工具  
✅ **持续更新**：模型能力不断提升，知识库持续更新

### 1.3 限制与注意事项

⚠️ **幻觉问题**：可能生成看似合理但错误的信息  
⚠️ **知识截止**：模型训练数据有时间点限制  
⚠️ **成本考虑**：GPT-4系列API调用成本较高  
⚠️ **速率限制**：API有每分钟/每天的调用次数限制  
⚠️ **数据隐私**：输入数据会被用于处理（可购买企业版获得数据隔离）

---

## 2. 提示词基础

### 2.1 提示词基本结构

OpenAI模型（特别是GPT-4和GPT-3.5）通常使用以下消息结构：

```markdown
[
  {"role": "system", "content": "系统消息：设定AI的行为规范"},
  {"role": "user", "content": "用户消息：提出具体问题或任务"},
  {"role": "assistant", "content": "助手回复：AI的回答（可选，用于少样本示例）"}
]
```

### 2.2 系统消息（System Message）的最佳实践

系统消息是OpenAI模型最强大的功能之一，它可以：

1. **设定角色和行为规范**
2. **指定输出格式**
3. **设置约束条件**
4. **提供持久性指令**

#### 示例1：基础系统消息

```markdown
{"role": "system", "content": "你是一个专业的Python开发工程师，擅长算法优化和代码重构。你的回答应该：1. 提供可运行的完整代码 2. 包含详细注释 3. 说明时间复杂度和空间复杂度 4. 提供测试用例"}
```

#### 示例2：格式化输出系统消息

```markdown
{"role": "system", "content": "你是一个数据分析助手。始终以JSON格式输出结果，包含以下字段：summary（文本摘要）、data（数值数据数组）、chart_type（推荐的图表类型：bar/line/pie/scatter）、insights（洞察数组）"}
```

#### 示例3：角色扮演系统消息

```markdown
{"role": "system", "content": "你是一位资深的产品经理，有10年互联网产品经验。请用产品思维分析问题，关注用户需求、商业价值和技术可行性。回答时先给出结论，再展开分析。"}
```

### 2.3 提示词编写的核心原则

#### ✅ 原则1：具体明确（Be Specific）

```markdown
❌ 不好的提示词：
"帮我写个代码"

✅ 好的提示词：
"你是一个Python开发工程师。请编写一个函数，实现快速排序算法。
要求：
1. 使用Python 3.9+语法
2. 支持自定义比较函数
3. 添加详细注释
4. 包含单元测试
5. 分析时间复杂度和空间复杂度"
```

#### ✅ 原则2：提供上下文（Provide Context）

```markdown
✅ 好的提示词：
"我正在开发一个电商网站，使用Django框架。需要实现购物车功能。

具体需求：
- 用户可以添加/删除商品
- 商品数量可以调整
- 实时计算总价
- 支持优惠券抵扣
- 数据需要持久化到数据库

请提供完整的模型和视图代码。"
```

#### ✅ 原则3：使用分隔符（Use Delimitators）

```markdown
✅ 好的提示词：
"请总结以下文章的核心观点：

---
[文章内容]
---

要求：
1. 提取3-5个关键要点
2. 每个要点用一句话概括
3. 输出格式为JSON"
```

#### ✅ 原则4：逐步思考（Think Step by Step）

```markdown
✅ 好的提示词：
"请解决以下数学问题，并展示完整的推理过程：

问题：一个水池有两根水管，一根单独注满需要6小时，另一根单独注满需要4小时。如果两根水管同时打开，需要多少小时注满水池？

要求：
1. 先列出已知条件
2. 建立数学模型
3. 逐步计算
4. 验证答案的合理性
5. 给出最终答案"
```

---

## 3. 写作任务提示词

### 3.1 文章写作

#### 示例1：博客文章写作

**提示词**：

```markdown
{"role": "system", "content": "你是一个资深的技术博客作者，擅长将复杂的技术概念用通俗易懂的语言表达出来。你的文章结构清晰，代码示例丰富，适合中级开发者阅读。"}

{"role": "user", "content": "请写一篇关于「使用Docker容器化部署Python应用」的技术博客文章。

要求：
1. 面向中级开发者
2. 字数约2000字
3. 包含以下部分：
   - 引言：为什么需要容器化
   - Docker基础概念简介
   - 实战：容器化一个Flask应用
   - Dockerfile最佳实践
   - docker-compose多服务编排
   - 生产环境部署注意事项
   - 总结与延伸阅读
4. 每个部分都包含代码示例
5. 代码需要详细注释
6. 提供完整的可运行代码仓库链接（假设）
7. 语调专业但不失亲和力"}

**预期输出**：
- 一篇结构完整、代码丰富的技术教程
- 代码示例可直接复制使用
- 包含实战案例和最佳实践
```

#### 示例2：学术论文写作

**提示词**：

```markdown
{"role": "system", "content": "你是一个学术写作助手，擅长协助撰写计算机科学领域的学术论文。你的写作风格严谨、客观，符合学术规范，善于引用相关文献。"}

{"role": "user", "content": "请帮我撰写一篇关于「大语言模型在代码生成中的应用」的学术论文摘要和引言部分。

已知信息：
- 研究方向：大语言模型（LLM）在软件开发中的应用
- 主要发现：GPT-4在代码生成任务上达到了人类中级开发者的水平
- 研究方法：对比实验（GPT-4 vs 人类开发者）
- 数据集：HumanEval, MBPP

要求：
1. 摘要（Abstract）：200-250字，包含研究背景、方法、主要发现和意义
2. 引言（Introduction）：800-1000字，包含：
   - 研究背景和意义
   - 问题描述
   - 主要贡献
   - 论文结构
3. 使用学术写作风格
4. 引用3-5篇相关文献（格式：APA）
5. 使用专业术语，定义首次出现的缩写"}

**预期输出**：
- 符合学术规范的摘要和引言
- 包含文献引用
- 结构清晰，逻辑严密
```

#### 示例3：商业文案写作

**提示词**：

```markdown
{"role": "system", "content": "你是一个资深的数字营销专家，擅长撰写有说服力的商业文案。你的文案注重用户痛点、产品价值和行为召唤（CTA），能够有效提升转化率。"}

{"role": "user", "content": "请为一款新的AI写作工具撰写营销落地页文案。

产品信息：
- 名称：WriteBot AI
- 核心功能：AI辅助写作、多语言支持、SEO优化、 plagiarism检测
- 目标用户：内容创作者、营销人员、学生
- 定价：$29/月（专业版）、$99/月（团队版）
- 独特卖点：比竞品速度快3倍，支持50+语言

文案要求：
1. 吸引人的标题（H1）
2. 副标题（H2）- 强调价值主张
3. 痛点描述（3-5个用户痛点）
4. 解决方案介绍
5. 核心功能展示（5-7个功能，每个包含图标、标题、描述）
6. 社会证明（用户评价、使用数据）
7. 定价方案对比表
8. 常见问题（FAQ）
9. 强烈的行为召唤（CTA）
10. 字数：1500-2000字
11. 风格：现代、专业、有说服力"}

**预期输出**：
- 完整的落地页文案
- 包含HTML标签建议
- 强调转化优化
- 适合直接用于网页开发
```

### 3.2 创意写作

#### 示例1：短篇故事创作

**提示词**：

```markdown
{"role": "system", "content": "你是一个创意写作大师，擅长创作引人入胜的短篇故事。你的故事有鲜明的角色、紧张的情节和意想不到的转折。"}

{"role": "user", "content": "请创作一个科幻短篇故事，主题是关于「时间旅行者的道德困境」。

要求：
1. 字数：1500-2000字
2. 视角：第一人称
3. 时间设定：2150年
4. 主角：一个时间管理局的特工
5. 情节要素：
   - 主角发现自己的祖先是历史罪人
   - 他有机会回到过去改变历史
   - 但这样做会引发时间悖论
   - 最终他做出艰难选择
6. 风格：叙事紧凑，情感丰富
7. 包含哲学思考
8. 结尾留有余味"}

**预期输出**：
- 完整的短篇故事
- 情节引人入胜
- 角色立体
- 包含道德思辨
```

#### 示例2：诗歌生成

**提示词**：

```markdown
{"role": "system", "content": "你是一个现代诗人，擅长用优美的语言表达深刻的情感。你的诗歌意象丰富，韵律自然。"}

{"role": "user", "content": "请创作一首关于「秋天」的现代诗。

要求：
1. 自由诗体，不严格押韵
2. 长度：20-30行
3. 意象：落叶、归雁、凉风、收获
4. 情感：既有离别之感，也有丰收之喜
5. 风格：唯美、抒情、略带哲理
6. 避免陈词滥调"}

**预期输出**：
- 一首原创现代诗
- 意象优美
- 情感真挚
```

### 3.3 文本优化

#### 示例1：润色改写

**提示词**：

```markdown
{"role": "system", "content": "你是一个专业的文字编辑，擅长润色和改写文章，使其更加流畅、优雅和专业。"}

{"role": "user", "content": "请润色以下文字，使其更加专业和流畅：

---
我们公司做AI产品已经3年了，遇到很多问题，比如数据不够、模型不准、用户不喜欢。现在我们想改进产品，需要你的建议。
---

要求：
1. 保持原意
2. 使用商务专业语言
3. 结构更清晰
4. 提供更精确的表达
5. 输出改写后的版本和改写说明"}

**预期输出**：
- 润色后的专业文本
- 改写说明（列出主要改进点）
```

#### 示例2：翻译

**提示词**：

```markdown
{"role": "system", "content": "你是一个专业翻译，精通中英双语，擅长技术文档翻译。你的翻译准确、流畅，符合目标语言的表达习惯。"}

{"role": "user", "content": "请将以下Python技术文档翻译成英文：

---
## 快速排序算法实现

快速排序是一种高效的排序算法，采用分治法策略。

### 算法步骤
1. 从数列中挑出一个元素，称为「基准」（pivot）
2. 重新排序数列，所有比基准值小的元素摆放在基准前面，所有比基准值大的元素摆在基准后面
3. 递归地对齐两个子序列进行排序

### 时间复杂度
- 最优情况：O(n log n)
- 平均情况：O(n log n)
- 最坏情况：O(n²)
---

要求：
1. 保留Markdown格式
2. 技术术语翻译准确
3. 语言自然流畅
4. 代码示例保持不变"}

**预期输出**：
- 高质量的英文翻译
- 保留原文结构
- 术语准确
```

---

## 4. 代码开发提示词

### 4.1 代码生成

#### 示例1：函数编写

**提示词**：

```markdown
{"role": "system", "content": "你是一个Python专家，擅长编写高质量、可维护的代码。你的代码遵循PEP 8规范，包含详细注释和文档字符串。"}

{"role": "user", "content": "请编写一个Python函数，实现LRU（Least Recently Used）缓存机制。

要求：
1. 使用Python 3.9+语法
2. 实现以下方法：
   - `__init__(self, capacity: int)`: 初始化缓存
   - `get(self, key: int) -> int`: 获取键值，如果不存在返回-1
   - `put(self, key: int, value: int) -> None`: 插入或更新键值
3. 时间复杂度：get和put都必须是O(1)
4. 使用`collections.OrderedDict`实现
5. 包含详细注释
6. 添加文档字符串（docstring）
7. 提供使用示例
8. 分析时间和空间复杂度"}

**预期输出**：
```python
from collections import OrderedDict

class LRUCache:
    """
    LRU (Least Recently Used) Cache implementation.
    
    This cache evicts the least recently used item when capacity is exceeded.
    Both get and put operations run in O(1) time complexity.
    """
    
    def __init__(self, capacity: int):
        """Initialize the LRU cache with given capacity."""
        self.capacity = capacity
        self.cache = OrderedDict()
    
    def get(self, key: int) -> int:
        """Get value by key. Returns -1 if key doesn't exist."""
        if key not in self.cache:
            return -1
        # Move to end to mark as recently used
        self.cache.move_to_end(key)
        return self.cache[key]
    
    def put(self, key: int, value: int) -> None:
        """Insert or update a key-value pair."""
        if key in self.cache:
            # Update value and mark as recently used
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            # Remove least recently used item
            self.cache.popitem(last=False)

# Usage example
if __name__ == "__main__":
    cache = LRUCache(2)
    cache.put(1, 1)
    cache.put(2, 2)
    print(cache.get(1))  # Returns 1
    cache.put(3, 3)      # Evicts key 2
    print(cache.get(2))  # Returns -1 (not found)
```

复杂度分析：
- 时间复杂度：get O(1), put O(1)
- 空间复杂度：O(capacity)
```

#### 示例2：完整程序开发

**提示词**：

```markdown
{"role": "system", "content": "你是一个全栈开发工程师，擅长Python后端开发和Web应用构建。你注重代码质量、安全性和用户体验。"}

{"role": "user", "content": "请开发一个完整的URL短链接生成服务，使用FastAPI框架。

功能需求：
1. 长链接转短链接
2. 短链接重定向到原始链接
3. 访问统计（点击次数）
4. 过期时间设置
5. 自定义短链接别名

技术要求：
1. 使用FastAPI框架
2. 使用SQLite数据库（通过SQLAlchemy ORM）
3. 使用Pydantic进行数据验证
4. 包含单元测试
5. 提供API文档（自动生成）
6. 添加日志记录
7. 错误处理完善

文件结构：
```
shortlink-service/
├── main.py
├── models.py
├── schemas.py
├── database.py
├── utils.py
├── tests/
│   └── test_main.py
└── requirements.txt
```

请提供完整的代码实现。"}

**预期输出**：
- 完整的项目代码结构
- 所有文件的代码实现
- 单元测试
- requirements.txt依赖清单
- 使用说明
```

### 4.2 代码审查与优化

#### 示例1：代码审查

**提示词**：

```markdown
{"role": "system", "content": "你是一个资深代码审查专家，擅长发现代码中的问题并提供建设性的改进建议。你的审查涵盖：代码质量、性能、安全性、可维护性、最佳实践。"}

{"role": "user", "content": "请审查以下Python代码，指出问题并提供改进建议：

```python
def process_data(data):
    result = []
    for i in range(len(data)):
        if data[i] > 0:
            result.append(data[i] * 2)
        else:
            result.append(data[i] * -1)
    return result

def calculate_average(numbers):
    sum = 0
    for num in numbers:
        sum += num
    return sum / len(numbers)

# 主程序
data = [1, -2, 3, -4, 5]
processed = process_data(data)
avg = calculate_average(processed)
print('Average:', avg)
```

审查维度：
1. 代码质量和可读性
2. 性能优化
3. Python最佳实践
4. 错误处理
5. 函数设计
6. 变量命名
7. 测试覆盖"}

**预期输出**：
- 详细的问题列表（按严重程度排序）
- 每个问题的解释和改进建议
- 重构后的完整代码
- 单元测试建议
```

#### 示例2：Bug修复

**提示词**：

```markdown
{"role": "system", "content": "你是一个调试专家，擅长快速定位和修复代码bug。你善于分析错误堆栈、理解代码逻辑，并提供根本解决方案。"}

{"role": "user", "content": "以下Python代码运行时报错，请帮我找出问题并修复：

代码：
```python
def divide_numbers(a, b):
    try:
        result = a / b
        return result
    except:
        print('Error occurred')

# 测试
print(divide_numbers(10, 2))
print(divide_numbers(10, 0))
print(divide_numbers(10, '2'))
```

错误信息：
```
Traceback (most recent call last):
  File 'test.py', line 12, in <module>
    print(divide_numbers(10, '2'))
  File 'test.py', line 3, in divide_numbers
    result = a / b
TypeError: unsupported operand type(s) for /: 'int' and 'str'
```

要求：
1. 分析错误原因
2. 提供修复后的完整代码
3. 改进异常处理
4. 添加输入验证
5. 提供测试用例验证修复"}

**预期输出**：
- 错误原因分析
- 修复后的完整代码
- 改进说明
- 测试用例
```

### 4.3 代码转换

#### 示例：Python转JavaScript

**提示词**：

```markdown
{"role": "system", "content": "你是一个多语言编程专家，擅长在不同编程语言之间转换代码，同时保持代码逻辑和功能的一致性。"}

{"role": "user", "content": "请将以下Python代码转换为JavaScript（ES6+）代码：

Python代码：
```python
import asyncio
from typing import List, Dict

async def fetch_user_data(user_ids: List[int]) -> Dict[int, dict]:
    """Fetch user data from API."""
    results = {}
    for user_id in user_ids:
        # Simulate API call
        await asyncio.sleep(0.1)
        results[user_id] = {
            'id': user_id,
            'name': f'User {user_id}',
            'email': f'user{user_id}@example.com'
        }
    return results

async def main():
    user_ids = [1, 2, 3, 4, 5]
    users = await fetch_user_data(user_ids)
    for user_id, data in users.items():
        print(f'{user_id}: {data[\"name\"]}')

if __name__ == '__main__':
    asyncio.run(main())
```

转换要求：
1. 使用JavaScript的async/await
2. 使用现代JS语法（箭头函数、模板字符串、const/let）
3. 添加JSDoc类型注释
4. 保持异步逻辑一致
5. 提供Node.js运行示例
6. 说明Python和JS的异步编程差异"}

**预期输出**：
- 完整的JavaScript代码
- JSDoc注释
- 运行说明
- Python vs JavaScript异步编程对比
```

---

## 5. 图像生成提示词（DALL-E）

### 5.1 基础图像生成

#### 示例1：写实风格图像

**提示词**：

```markdown
请使用DALL-E 3生成一张写实风格的图像：

提示词（Prompt）：
"A modern tech office workspace with large windows, natural lighting, 
multiple monitors displaying code on desks, a whiteboard with diagrams 
on the wall, plants in the corners, ergonomic chairs, coffee mugs, 
photorealistic, 8K resolution, cinematic lighting"

要求：
1. 风格：写实摄影风格
2. 分辨率：1792x1024（DALL-E 3支持）
3. 质量：hd（高清晰度）
4. 数量：1张
```

**提示词技巧**：
- ✅ 详细描述场景元素
- ✅ 指定光照条件
- ✅ 明确风格（photorealistic, cinematic lighting）
- ✅ 指定分辨率
- ❌ 避免模糊描述

#### 示例2：艺术插画风格

**提示词**：

```markdown
请使用DALL-E 3生成一张艺术插画：

提示词（Prompt）：
"An enchanting forest with glowing mushrooms, fairy lights floating in 
the air, a mystical river reflecting the moonlight, digital art, 
Studio Ghibli style, vibrant colors, whimsical atmosphere, 
intricate details, matte painting"

风格设置：
- 艺术风格：数字艺术、吉卜力风格
- 色彩：鲜艳、梦幻
- 氛围：神秘、宁静
```

### 5.2 高级图像控制

#### 示例1：构图控制

**提示词**：

```markdown
请生成一张产品展示图，严格控制构图：

提示词：
"Product photography of a smartwatch on a minimalist white background, 
centered composition, front view, soft studio lighting, 
shallow depth of field, 4K, commercial photography style

Camera settings: 85mm lens, f/2.8, ISO 100"

构图要点：
- 中心构图：产品位于画面正中
- 简约背景：白色，突出产品
- 浅景深：f/2.8，背景虚化
- 柔光：避免 harsh shadows
```

#### 示例2：风格混合

**提示词**：

```markdown
请生成一张融合多种艺术风格的图像：

提示词：
"A futuristic cityscape at sunset, blend of Cyberpunk and Art Deco 
styles, neon lights reflecting on wet streets, geometric patterns 
on buildings, flying cars, people in retro-futuristic fashion, 
oil painting texture combined with digital art, 
color palette: purple, orange, teal, highly detailed"

风格融合技巧：
- 明确列出要融合的风格（Cyberpunk + Art Deco）
- 描述如何融合（oil painting + digital art）
- 指定色彩方案
- 添加质感描述（texture）
```

---

## 6. 数据分析提示词

### 6.1 数据解读

#### 示例1：统计分析

**提示词**：

```markdown
{"role": "system", "content": "你是一个数据分析专家，擅长统计分析、数据可视化和业务洞察提取。你的分析严谨、客观，能够提供可操作的建议。"}

{"role": "user", "content": "请分析以下销售数据，提取关键洞察：

数据（CSV格式）：
```
月份,销售额,订单数,客单价,退货率
2024-01,150000,500,300,5%
2024-02,165000,550,300,4.5%
2024-03,170000,520,327,4.8%
2024-04,180000,600,300,5.2%
2024-05,190000,650,292,6%
2024-06,210000,700,300,5.5%
```

分析要求：
1. 计算环比增长率（MoM）
2. 识别趋势和异常
3. 分析退货率与销售额的关系
4. 提供业务建议
5. 推荐合适的可视化图表
6. 以JSON格式输出结果，包含：
   - summary（文本摘要）
   - metrics（关键指标数组）
   - trends（趋势分析）
   - insights（洞察数组）
   - recommendations（建议数组）
   - chart_recommendations（图表推荐）"}

**预期输出**：
```json
{
  "summary": "销售额呈现稳定增长趋势，6个月增长40%，但退货率也在上升，需要关注产品质量。",
  "metrics": [
    {"name": "总增长率", "value": "40%", "period": "2024-01 to 2024-06"},
    {"name": "平均客单价", "value": "304", "trend": "stable"},
    {"name": "平均退货率", "value": "5.17%", "trend": "increasing"}
  ],
  "trends": [
    "销售额持续增长，5月和6月增速加快",
    "订单数增长快于销售额，说明客单价有下降趋势",
    "退货率呈上升趋势，6月达到5.5%"
  ],
  "insights": [
    "6月订单数大幅增长（+7.7%），但客单价下降到292元",
    "退货率在6月显著提升，可能与订单激增导致质量控制不严有关",
    "客单价在3月达到峰值327元，之后下降并稳定在300元左右"
  ],
  "recommendations": [
    "调查6月退货率上升的根本原因，加强质量控制",
    "分析客单价下降原因，考虑推出捆绑销售提升客单价",
    "继续保持销售增长势头，同时关注利润率"
  ],
  "chart_recommendations": [
    {"chart_type": "line", "description": "销售额和订单数趋势图"},
    {"chart_type": "dual_axis", "description": "销售额（左轴）vs 退货率（右轴）"},
    {"chart_type": "bar", "description": "每月客单价对比"}
  ]
}
```

### 6.2 可视化建议

#### 示例：图表选择指导

**提示词**：

```markdown
{"role": "system", "content": "你是一个数据可视化专家，精通各类图表的特点和适用场景。你能够根据数据类型和分析目标推荐最合适的可视化方案。"}

{"role": "user", "content": "我有以下数据需要可视化，请推荐合适的图表类型：

数据1：过去12个月的销售额数据（时间序列）
数据2：不同产品类别的销售额占比（部分与整体）
数据3：销售额与广告支出的关系（两个连续变量）
数据4：不同地区的销售额对比（分类比较）
数据5：用户在网站上的行为路径（流程展示）

请为每个数据集推荐：
1. 最佳图表类型
2. 备选图表类型
3. 设计建议（颜色、标签、图例等）
4. 需要避免的常见错误
5. 推荐工具（Python: matplotlib/seaborn/plotly, Tableau, etc.）"}

**预期输出**：
- 每个数据集的详细可视化建议
- 包含图表示例描述
- 设计最佳实践
- 工具推荐
```

---

## 7. 推理任务提示词

### 7.1 逻辑推理

#### 示例1：链式思考（Chain-of-Thought）

**提示词**：

```markdown
{"role": "system", "content": "你是一个逻辑推理专家。在回答问题时，请始终展示完整的推理过程，逐步分析，确保每一步都清晰可验证。"}

{"role": "user", "content": "请解决以下逻辑推理问题，并展示完整的推理过程：

问题：
所有的猫都是动物。
有些动物会游泳。
问：是否所有的猫都会游泳？

要求：
1. 先列出已知条件
2. 分析逻辑关系
3. 逐步推理
4. 给出最终结论
5. 解释推理过程中可能出现的思维陷阱"}

**预期输出**：
```
## 推理过程

### 步骤1：列出已知条件
- 条件1：所有的猫都是动物（猫 → 动物）
- 条件2：有些动物会游泳（存在部分动物会游泳）

### 步骤2：分析逻辑关系
- 条件1建立了「猫」和「动物」的包含关系
- 条件2只说明「有些」动物会游泳，不是「所有」动物
- 从逻辑上，我们无法确定「会游泳的动物」是否包含「猫」

### 步骤3：逐步推理
1. 假设：所有的猫都会游泳
2. 验证：已知条件只说「有些动物会游泳」，这可能包含猫，也可能不包含
3. 反例：如果「会游泳的动物」指的是鲸鱼、海豚等，那么猫不在其中
4. 结论：无法确定所有猫都会游泳

### 最终结论
❌ 不能得出「所有的猫都会游泳」这个结论。
正确回答是：不确定/无法确定。

### 思维陷阱
⚠️ 常见错误：将「有些A是B」错误推导为「所有A是B」或「所有B是A」
⚠️ 这是典型的逻辑谬误，需要特别注意量词的范围。
```

### 7.2 问题解决

#### 示例：数学问题求解

**提示词**：

```markdown
{"role": "system", "content": "你是一个数学解题专家。你擅长将复杂问题分解为简单步骤，使用多种方法验证答案，并解释解题思路和原理。"}

{"role": "user", "content": "请解决以下数学问题，并使用至少两种方法验证答案：

问题：
一个游泳池有甲、乙、丙三根水管。
- 单开甲管，2小时注满
- 单开乙管，3小时注满
- 单开丙管，4小时注满

如果同时打开三根水管，需要多少小时注满游泳池？

要求：
1. 方法1：使用工作效率法
2. 方法2：使用方程法
3. 详细展示每种方法的计算步骤
4. 验证答案的合理性
5. 提供类似题目的通用解法"}

**预期输出**：
```
## 方法1：工作效率法

### 思路
将注满游泳池的工作量视为1，计算每根水管的注水效率（每小时完成的工作量）。

### 计算步骤
1. 甲管效率 = 1/2（每小时注满1/2个游泳池）
2. 乙管效率 = 1/3
3. 丙管效率 = 1/4

4. 三根水管同时工作的总效率：
   总效率 = 1/2 + 1/3 + 1/4
   
   通分（公分母12）：
   = 6/12 + 4/12 + 3/12
   = 13/12

5. 所需时间 = 工作量 ÷ 效率
   = 1 ÷ (13/12)
   = 12/13 小时
   ≈ 0.923 小时
   ≈ 55.38 分钟

答案：约0.923小时（或55.38分钟）

## 方法2：方程法

### 思路
设需要x小时注满，建立方程。

### 计算步骤
1. 设需要x小时
2. 甲管在x小时内完成的工作量：x × (1/2) = x/2
3. 乙管在x小时内完成的工作量：x × (1/3) = x/3
4. 丙管在x小时内完成的工作量：x × (1/4) = x/4

5. 建立方程：
   x/2 + x/3 + x/4 = 1

6. 解方程：
   通分（公分母12）：
   (6x + 4x + 3x) / 12 = 1
   13x / 12 = 1
   x = 12/13

答案：12/13小时（同方法1）

## 答案验证

### 验证1：代入检验
将x = 12/13代入原方程：
- 甲管完成：(12/13) × (1/2) = 6/13
- 乙管完成：(12/13) × (1/3) = 4/13
- 丙管完成：(12/13) × (1/4) = 3/13
- 总计：6/13 + 4/13 + 3/13 = 13/13 = 1 ✓

### 验证2：合理性检验
-  fastest single pipe (甲) takes 2 hours
-  三管同时开，时间应该少于2小时
-  12/13 ≈ 0.923小时 < 2小时 ✓
-  结果合理

## 通用解法

对于「合作完成工作」类型的问题：

公式：1/T = 1/t₁ + 1/t₂ + ... + 1/tₙ

其中：
- T = 合作完成所需时间
- t₁, t₂, ..., tₙ = 各自单独完成所需时间

步骤：
1. 确定总工作量（通常设为1）
2. 计算各自的工作效率（1/t）
3. 求和得到总效率
4. 用总工作量除以总效率得到时间
```

---

## 8. 高级技巧

### 8.1 少样本提示（Few-Shot Prompting）

少样本提示是通过在提示词中提供少量示例来引导模型输出特定格式或风格的技术。

#### 示例：情感分析

**提示词**：

```markdown
{"role": "user", "content": "请对以下评论进行情感分析，输出JSON格式结果。

示例1：
输入：这个产品真的太棒了，超出我的预期！
输出：{\"sentiment\": \"positive\", \"confidence\": 0.95, \"highlights\": [\"太棒了\", \"超出预期\"]}

示例2：
输入：质量一般，性价比不高，不推荐购买。
输出：{\"sentiment\": \"negative\", \"confidence\": 0.88, \"highlights\": [\"质量一般\", \"性价比不高\", \"不推荐\"]}

示例3：
输入：还算可以吧，没什么特别的。
输出：{\"sentiment\": \"neutral\", \"confidence\": 0.72, \"highlights\": [\"还算可以\", \"没什么特别\"]}

现在请分析：
输入：刚收到货，包装完好，还没开始用，期待后续效果。
输出："}

**技巧说明**：
- ✅ 提供3-5个多样化的示例
- ✅ 示例覆盖所有可能的输出类别
- ✅ 示例格式严格一致
- ✅ 在最后直接给出「输入：」引导模型续写

**预期输出**：
```json
{"sentiment": "neutral", "confidence": 0.68, "highlights": ["包装完好", "还没开始用", "期待后续效果"]}
```

### 8.2 思维链（Chain-of-Thought）高级应用

#### 示例：复杂推理任务

**提示词**：

```markdown
{"role": "system", "content": "你是一个逻辑推理专家。在回答任何复杂问题时，请遵循以下思维链步骤：\n1. 理解问题：重述问题确保理解\n2. 分解问题：将复杂问题分解为多个简单子问题\n3. 逐个解决：解决每个子问题\n4. 综合答案：将所有子问题的答案综合起来\n5. 验证答案：检查答案的合理性和完整性"}

{"role": "user", "content": "一个农民有17只羊，除了7只以外都死了，还剩几只羊？

请按照思维链步骤逐步推理。"}

**预期输出**：
```
## 思维链推理过程

### 步骤1：理解问题
问题：一个农民有17只羊，除了7只以外都死了，还剩几只羊？

关键短语：「除了7只以外都死了」
这句话的意思是：有7只羊没有死，其他的都死了。

### 步骤2：分解问题
- 子问题1：农民原来有多少只羊？→ 17只
- 子问题2：「除了7只以外都死了」这句话如何理解？
- 子问题3：没有死的羊有多少只？

### 步骤3：逐个解决
- 子问题1答案：17只
- 子问题2答案：「除了A以外都B」的意思是「A没有B，其他的都B」
  所以「除了7只以外都死了」=「7只没有死，其他都死了」
- 子问题3答案：7只

### 步骤4：综合答案
还存活的羊数量 = 7只

### 步骤5：验证答案
- 检查：17只羊，7只存活，10只死亡 → 符合「除了7只以外都死了」
- 答案合理 ✓

## 最终答案
还剩7只羊。
```

### 8.3 函数调用（Function Calling）

OpenAI的函数调用功能允许模型输出结构化数据，便于集成外部工具和API。

#### 示例：天气查询助手

**提示词和配置**：

```python
import openai
import json

# 定义可用函数
functions = [
    {
        "name": "get_weather",
        "description": "获取指定城市的当前天气",
        "parameters": {
            "type": "object",
            "properties": {
                "city": {
                    "type": "string",
                    "description": "城市名称，例如：北京、上海、New York"
                },
                "unit": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "温度单位"
                }
            },
            "required": ["city"]
        }
    }
]

# 调用API
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[
        {"role": "user", "content": "上海今天天气怎么样？"}
    ],
    functions=functions,
    function_call="auto"
)

# 解析响应
response_message = response["choices"][0]["message"]

# 如果模型选择调用函数
if response_message.get("function_call"):
    function_name = response_message["function_call"]["name"]
    function_args = json.loads(response_message["function_call"]["arguments"])
    
    # 这里应该实际调用天气API
    # 为演示目的，我们模拟返回结果
    function_response = {
        "city": "上海",
        "temperature": 22,
        "unit": "celsius",
        "condition": "多云",
        "humidity": 65
    }
    
    # 将函数响应发回模型
    second_response = openai.ChatCompletion.create(
        model="gpt-4o",
        messages=[
            {"role": "user", "content": "上海今天天气怎么样？"},
            response_message,
            {
                "role": "function",
                "name": function_name,
                "content": json.dumps(function_response)
            }
        ]
    )
    
    print(second_response["choices"][0]["message"]["content"])
```

**预期输出**：
```
上海今天天气不错！当前气温22°C，多云，湿度65%。是个适合外出的一天。
```

### 8.4 提示词链（Prompt Chaining）

将复杂任务分解为多个简单的提示词，逐个完成。

#### 示例：多步骤文章生成

**步骤1：生成大纲**

```markdown
{"role": "user", "content": "请为一篇关于「人工智能在医疗行业的应用」的文章生成详细大纲。

要求：
1. 包含引言、主体（5-7个部分）、结论
2. 每个部分列出3-5个要点
3. 逻辑清晰，层次分明
4. 输出格式为Markdown"}
```

**步骤2：基于大纲撰写引言**

```markdown
{"role": "user", "content": "根据以下大纲，撰写文章引言部分：

[插入步骤1生成的大纲]

要求：
1. 字数300-400字
2. 吸引读者注意力
3. 提出文章要解决的问题
4. 简要介绍文章结构"}
```

**步骤3：逐个部分撰写**

```markdown
{"role": "user", "content": "根据大纲撰写「诊断辅助系统」部分：

[插入大纲中该部分的要点]

要求：
1. 字数500-600字
2. 包含具体案例或数据
3. 解释技术原理
4. 讨论优势和局限"}
```

**优势**：
- ✅ 更好地控制输出质量
- ✅ 易于调试和优化
- ✅ 可以针对每个步骤使用不同的模型或参数
- ✅ 提高复杂任务的完成率

---

## 9. 配置参数建议

### 9.1 Temperature（温度）

控制生成文本的随机性。

| 任务类型 | 推荐Temperature | 说明 |
|---------|----------------|------|
| 事实性任务（翻译、摘要、问答） | 0 - 0.3 | 低温度使输出更确定、一致 |
| 平衡任务（通用对话、解释） | 0.3 - 0.7 | 适度随机性，保持连贯 |
| 创意任务（写作、头脑风暴） | 0.7 - 1.0 | 高温度增加多样性和创意 |
| 代码生成 | 0.2 - 0.5 | 较低温度确保语法正确和逻辑一致 |

**示例**：

```python
# 事实性任务 - 低温度
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "将以下句子翻译成法语：[句子]"}],
    temperature=0.3  # 确保翻译准确一致
)

# 创意写作 - 高温度
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "写一个关于太空探险的短篇故事"}],
    temperature=0.8  # 增加创意和多样性
)
```

### 9.2 Max Tokens（最大生成长度）

控制模型生成的最大token数。

**建议**：
- 简单任务：100-300 tokens
- 中等任务（摘要、解释）：300-1000 tokens
- 复杂任务（文章、代码）：1000-4000 tokens
- 长文档：4096+ tokens（GPT-4支持128K）

```python
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "写一篇关于气候变化的文章"}],
    max_tokens=2000  # 限制输出长度约1500字
)
```

### 9.3 Top P（核采样）

控制生成时考虑的token范围。

**建议**：
- 一般任务：top_p=0.9（默认）
- 需要高质量输出：top_p=0.95
- 需要更多样性：top_p=0.99

```python
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "生成10个创意产品名称"}],
    temperature=0.8,
    top_p=0.95  # 从高概率token中采样
)
```

### 9.4 Frequency Penalty & Presence Penalty

控制重复和引入新话题。

| 参数 | 范围 | 作用 | 使用场景 |
|------|------|------|---------|
| frequency_penalty | -2.0 到 2.0 | 降低重复token的概率 | 避免啰嗦、重复 |
| presence_penalty | -2.0 到 2.0 | 鼓励引入新话题 | 增加话题多样性 |

```python
# 避免重复 - 提高frequency_penalty
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "详细介绍Python的5个特性"}],
    temperature=0.7,
    frequency_penalty=0.5  # 避免重复描述同一特性
)

# 鼓励多样性 - 提高presence_penalty
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": " brainstorm 10个产品创意"}],
    temperature=0.9,
    presence_penalty=0.6  # 鼓励不同的创意方向
)
```

### 9.5 推荐配置组合

#### 配置1：精准翻译任务

```python
{
    "model": "gpt-4o",
    "temperature": 0.3,
    "top_p": 0.9,
    "frequency_penalty": 0,
    "presence_penalty": 0
}
```

#### 配置2：创意写作

```python
{
    "model": "gpt-4o",
    "temperature": 0.85,
    "top_p": 0.95,
    "frequency_penalty": 0.3,
    "presence_penalty": 0.4
}
```

#### 配置3：代码生成

```python
{
    "model": "gpt-4o",
    "temperature": 0.2,
    "top_p": 0.95,
    "max_tokens": 2000,
    "frequency_penalty": 0.2,
    "presence_penalty": 0
}
```

#### 配置4：数据分析

```python
{
    "model": "gpt-4o",
    "temperature": 0.4,
    "top_p": 0.9,
    "max_tokens": 1500,
    "frequency_penalty": 0.3,
    "presence_penalty": 0.2
}
```

---

## 10. 常见错误与解决方案

### 10.1 幻觉问题（Hallucination）

**问题描述**：模型生成看似合理但实际错误的信息。

**解决方案**：

#### 方法1：在系统消息中添加诚实指令

```markdown
{"role": "system", "content": "你是一个严谨的助手。如果你不确定答案，或者没有足够的信息，请明确说「我不确定」或「我没有足够的信息回答这个问题」。不要编造信息。"}
```

#### 方法2：要求引用来源

```markdown
{"role": "user", "content": "请解释量子计算的基本原理。

要求：
1. 如果你使用了外部知识，请说明信息来源
2. 如果某个观点存在争议，请说明
3. 对于不确定的部分，请明确标注"}
```

#### 方法3：使用RAG（检索增强生成）

```python
# 结合外部知识库
relevant_docs = search_knowledge_base(user_query)

response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[
        {"role": "system", "content": "你是一个助手。只根据提供的上下文回答问题。如果上下文没有相关信息，请说「我没有足够的信息」。"},
        {"role": "user", "content": f"上下文：\n{relevant_docs}\n\n问题：{user_query}"}
    ]
)
```

#### 方法4：降低Temperature

```python
# 降低temperature减少随机性
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": user_query}],
    temperature=0.2  # 更低的温度使输出更确定
)
```

### 10.2 输出格式不符合要求

**问题描述**：模型输出格式与期望不符（例如期望JSON但实际输出文本）。

**解决方案**：

#### 方法1：在系统消息中强制格式

```markdown
{"role": "system", "content": "你是一个数据分析助手。你必须始终以JSON格式输出，包含以下字段：summary, key_points, sentiment。不要输出任何JSON以外的内容。"}
```

#### 方法2：使用少样本示例

```markdown
{"role": "user", "content": "请将以下文本分类为positive/neutral/negative：

示例1：
输入：这个产品真的很棒！
输出：{"sentiment": "positive", "confidence": 0.92}

示例2：
输入：还可以吧，没什么特别的。
输出：{"sentiment": "neutral", "confidence": 0.65}

现在请分类：
输入：质量太差了，浪费钱。
输出："}
```

#### 方法3：使用函数调用强制结构化输出

```python
functions = [
    {
        "name": "classify_sentiment",
        "description": "对文本进行情感分类",
        "parameters": {
            "type": "object",
            "properties": {
                "sentiment": {
                    "type": "string",
                    "enum": ["positive", "neutral", "negative"]
                },
                "confidence": {
                    "type": "number",
                    "description": "置信度，0-1之间"
                }
            },
            "required": ["sentiment", "confidence"]
        }
    }
]

response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "质量太差了，浪费钱。"}],
    functions=functions,
    function_call={"name": "classify_sentiment"}
)
```

### 10.3 输出过于冗长或简短

**问题描述**：模型输出长度不符合预期。

**解决方案**：

#### 方法1：明确指定字数要求

```markdown
{"role": "user", "content": "请写一篇关于人工智能的短文。

要求：
1. 字数：500-600字
2. 包含3个主要观点
3. 每个观点用一段话阐述"}
```

#### 方法2：设置max_tokens限制

```python
response = openai.ChatCompletion.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "总结以下文章：[文章内容]"}],
    max_tokens=300  # 限制输出约200-250字
)
```

#### 方法3：在提示词中强调简洁

```markdown
{"role": "system", "content": "你是一个简洁高效的助手。回答问题时直击要点，避免冗长的解释和不必要的铺垫。"}

{"role": "user", "content": "请用3-5句话解释什么是区块链。"}
```

### 10.4 推理错误

**问题描述**：模型在逻辑推理、数学计算等任务上出错。

**解决方案**：

#### 方法1：要求逐步推理

```markdown
{"role": "user", "content": "请解决以下数学问题：

问题：[问题内容]

要求：
1. 先列出已知条件和未知数
2. 建立数学模型或方程
3. 逐步计算，每一步都详细说明
4. 给出最终答案
5. 验证答案的合理性"}
```

#### 方法2：使用少样本推理示例

```markdown
{"role": "user", "content": "请学习以下推理模式，然后解决新问题：

示例：
问题：如果3个苹果花费6元，那么5个苹果花费多少元？
推理：
1. 先求单价：6元 ÷ 3个 = 2元/个
2. 再求总价：2元/个 × 5个 = 10元
答案：10元

现在请解决：
问题：如果一辆汽车以每小时60公里的速度行驶，2.5小时能行驶多少公里？
推理："}
```

#### 方法3：多次推理取多数答案（自我一致性）

```markdown
{"role": "user", "content": "请独立解决以下问题3次，每次都重新思考：

问题：[问题内容]

第1次解答：
[推理过程]
答案：[答案1]

第2次解答：
[推理过程]
答案：[答案2]

第3次解答：
[推理过程]
答案：[答案3]

最终答案：[选择出现次数最多的答案]，因为自我一致性检验表明这是最可靠的答案。"}
```

---

## 11. 实用提示词模板

### 模板1：文章写作

```markdown
你是一个[角色，如：资深技术博客作者/学术写作助手/营销文案专家]。

请写一篇关于「[文章主题]」的[文体，如：教程/评论/分析报告]。

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
```

### 模板2：代码开发

```markdown
你是一个[语言，如：Python/JavaScript/Java]高级开发工程师，
擅长[领域，如：Web开发/数据科学/算法实现]。

## 任务描述
[详细描述需要实现的功 volcani能或解决的问题]

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
6. 复杂度分析

## 约束条件
[列出任何限制或特殊情况]
```

### 模板3：数据分析

```markdown
你是一个数据分析专家，擅长[领域，如：商业分析/科学研究/金融分析]。

## 数据描述
[描述提供的数据，或粘贴数据]

## 分析任务
请完成以下分析：

### 1. 数据概览
- 数据规模（行数、列数）
- 各字段的数据类型和含义
- 缺失值情况

### 2. 描述性统计
- 核心指标（均值、中位数、标准差等）
- 数据分布情况

### 3. 趋势分析
[根据数据特点指定]

### 4. 洞察提取
- 关键发现
- 异常值识别
- 相关性分析

### 5. 建议
- 基于数据的业务建议
- 后续分析方向

## 输出格式
请以JSON格式输出，包含以下字段：
- summary（文本摘要）
- statistics（统计指标字典）
- insights（洞察数组）
- visualizations（推荐的图表类型和配置）
- recommendations（建议数组）

## 注意事项
[任何特殊要求或注意事项]
```

### 模板4：图像生成（DALL-E）

```markdown
请使用DALL-E 3生成一张[图像类型，如：产品展示图/艺术插画/写实照片]。

## 图像描述
[详细的描述，包含以下要素：]

### 主体
[描述图像中的主要对象或人物]

### 环境/背景
[描述场景、地点、背景元素]

### 风格
[艺术风格、摄影风格、插画风格等]

### 光照和色彩
[描述光照条件、色彩方案]

### 构图
[描述视角、布局、焦点]

### 质感
[描述材质、纹理]

## 技术参数
- 宽高比：[如：16:9 / 1:1 / 9:16]
- 质量：[standard / hd]
- 风格：[vivid / natural]

## 负面提示词（可选）
[描述不希望出现的元素，如：模糊、变形、多余肢体等]
```

### 模板5：推理任务

```markdown
你是一个逻辑推理专家。在回答问题时，请严格遵循以下思维链步骤。

## 思维链步骤
1. 理解问题：重述问题，确保准确理解
2. 列出已知条件：清晰列出所有给定信息
3. 识别未知量：明确需要求解的内容
4. 建立关系：找出已知和未知之间的关联
5. 逐步求解：每一步都详细解释
6. 验证答案：检查答案的合理性

## 问题
[问题描述]

## 要求
1. 严格按照思维链步骤推理
2. 每一步都清晰标注
3. 使用[语言，如：中文/英文]解释
4. 如果有多种解法，请都展示
5. 最后给出最终答案的明确表述

## 补充信息
[任何相关的背景知识或提示]
```

### 模板6：翻译任务

```markdown
你是一个专业翻译，精通[源语言]和[目标语言]，
擅长[领域，如：技术文档/商务信函/文学作品]翻译。

## 翻译要求
1. 准确性：忠实原文，不增删含义
2. 流畅性：符合目标语言的表达习惯
3. 专业性：术语翻译准确统一
4. 格式：保留原文的Markdown/HTML格式

## 待翻译内容
[粘贴需要翻译的文本]

## 术语表（可选）
[如果有专业术语，提供术语对照表]

## 补充说明
[任何特殊要求，如：保持语气/适应目标文化/本地化等]
```

---

## 12. 参考资料

### 官方文档

1. **OpenAI Platform Documentation**  
   https://platform.openai.com/docs/introduction  
   最权威的API文档，包含模型介绍、API参考、最佳实践

2. **OpenAI Cookbook**  
   https://github.com/openai/openai-cookbook  
   丰富的示例代码和使用案例，涵盖各种应用场景

3. **GPT-4 Technical Report**  
   https://arxiv.org/abs/2303.08774  
   GPT-4的技术报告，详细介绍模型能力和限制

4. **DALL-E 3 Documentation**  
   https://platform.openai.com/docs/guides/images  
   DALL-E 3的使用指南和最佳实践

### 社区资源

1. **Prompt Engineering Guide**  
   https://www.promptingguide.ai/  
   全面的提示词工程指南，包含各种技术和案例

2. **Awesome ChatGPT Prompts**  
   https://github.com/f/awesome-chatgpt-prompts  
   丰富的ChatGPT提示词示例，涵盖各种角色和场景

3. **OpenAI Community Forum**  
   https://community.openai.com/  
   官方社区论坛，可以提问、分享经验、获取帮助

4. **LangChain Documentation**  
   https://python.langchain.com/  
   如果需要在应用中集成OpenAI API，LangChain是非常好的框架

### 相关论文

1. **"Language Models are Few-Shot Learners"** (Brown et al., 2020)  
   介绍了GPT-3和少样本学习的能力

2. **"Chain-of-Thought Prompting Elicits Reasoning in Large Language Models"** (Wei et al., 2022)  
   提出思维链提示词技术，显著提升推理能力

3. **"Large Language Models are Zero-Shot Reasoners"** (Kojima et al., 2022)  
   发现简单的"Let's think step by step"就能激活推理能力

4. **"Self-Consistency Improves Language Models as Mathematical Problem Solvers"** (Wang et al., 2022)  
   提出自我一致性方法，通过多次采样提升准确性

### 视频教程

1. **OpenAI YouTube Channel**  
   https://www.youtube.com/@OpenAI  
   官方视频教程，包含API使用、最佳实践等

2. **Prompt Engineering for Developers** (DeepLearning.AI)  
   https://www.deeplearning.ai/short-courses/chatgpt-prompt-engineering-for-developers/  
   Andrew Ng主讲的提示词工程课程，免费

---

## 📝 更新日志

- **2026-05-18**：初始版本发布，完成OpenAI GPT全系列提示词指南
- 包含GPT-4o/GPT-4/GPT-3.5/DALL-E的详细提示词技巧
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
**版本**：v1.0
