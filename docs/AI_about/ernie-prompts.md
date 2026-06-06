# 百度文心 ERNIE 提示词最佳实践指南

> 掌握 ERNIE 5.1 的提示词技巧，充分发挥百度文心在 Agent 和搜索增强方面的强大能力

![ERNIE Logo](https://img.shields.io/badge/Baidu-ERNIE--5.1-blue)
![Status](https://img.shields.io/badge/状态-已完成-green)

---

## 1. 模型概述

### 1.1 模型版本与特点

| 模型          | 发布时间  | 架构 | 总参数 | 激活参数 | 上下文窗口  | 核心能力                        | 适用场景                       |
| ------------- | --------- | ---- | ------ | -------- | ----------- | ------------------------------- | ------------------------------ |
| **ERNIE 5.1** | 2026年5月 | MoE  | ~800B  | ~50B     | 128K tokens | Agent突出、搜索增强、创作能力强 | 智能体任务、搜索问答、中文创作 |

### 1.2 核心优势

✅ **Agent 能力突出**：τ³-bench 超越 DeepSeek V4-Pro，接近国际领先闭源模型  
✅ **搜索表现最强**：Arena 搜索榜全球第 4 / 国内第 1（1223 分）  
✅ **创作能力卓越**：被评价为"懂用户、懂内容、懂场景"的创作标杆  
✅ **极致效率**：仅用同规模模型 6% 的预训练成本  
✅ **AIME26 高分**：使用工具后得分 99.6，仅次于 Gemini 3.1 Pro  
✅ **OPD 多阶段训练**：创新性的在线策略蒸馏技术，解决多能力冲突问题

### 1.3 限制与注意事项

⚠️ **上下文 128K**：不支持百万级超长上下文  
⚠️ **闭源**：不可自部署，仅通过百度千帆平台调用  
⚠️ **编码能力中等**：编码评分 82，不如 DeepSeek V4-Pro（89.8）  
⚠️ **生态相对封闭**：主要依赖百度系产品生态

---

## 2. 提示词基础

### 2.1 ERNIE 提示词的基本结构

ERNIE 使用百度千帆平台的 API 格式。

#### 使用百度千帆 API

```python
import requests

API_KEY = "YOUR_ERNIE_API_KEY"
SECRET_KEY = "YOUR_SECRET_KEY"

def get_access_token():
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {
        "grant_type": "client_credentials",
        "client_id": API_KEY,
        "client_secret": SECRET_KEY
    }
    response = requests.post(url, params=params)
    return response.json().get("access_token")

def chat_with_ernie(messages):
    url = f"https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/ernie-5.1?access_token={get_access_token()}"
    payload = {"messages": messages}
    response = requests.post(url, json=payload)
    return response.json()

# 单次对话
messages = [
    {"role": "user", "content": "请解释什么是大语言模型。"}
]
result = chat_with_ernie(messages)
print(result.get("result"))
```

### 2.2 核心提示词技巧

#### ✅ 技巧1：发挥搜索增强优势

ERNIE 5.1 搜索能力国内最强，适合需要实时信息的任务：

```python
prompt = """我需要了解2026年5月的最新AI行业动态。

请帮我：
1. 搜索并整理本月最重要的5条AI新闻
2. 每一条包含：事件概述、影响分析、相关公司/人物
3. 最后给出一个整体趋势判断

要求：
- 信息必须是最新的（2026年5月）
- 每条新闻标注信息来源
- 分析要有深度，不只是新闻摘要
- 输出格式：Markdown 表格

如有需要，你可以联网搜索验证信息准确性。"""
```

#### ✅ 技巧2：复杂 Agent 任务

ERNIE 的 Agent 能力是其最大亮点：

```python
prompt = """你是一个项目经理助手，请帮我完成以下工作流：

**任务**：制定一个「公司官网改版项目」的完整执行计划

请逐步执行：

**步骤1：需求分析**
- 列出官网改版的常见动机（至少8个）
- 帮我设计一个需求调研问卷（10个问题）

**步骤2：竞品分析**
- 分析3个行业标杆官网的设计特点
- 输出对比表格

**步骤3：项目计划**
- 制定6周的执行排期
- 明确每个里程碑的交付物
- 识别关键风险和应对方案

**步骤4：资源评估**
- 估算所需的人力（角色、数量、工时）
- 预算范围建议
- 工具和平台推荐

每个步骤完成后，确认我的反馈再进入下一步。"""
```

#### ✅ 技巧3：中文创作和内容优化

```python
prompt = """你是一个资深的内容策略专家。

请帮助我优化以下产品文案：

原始文案：
「我们的产品是一款基于AI技术的智能客服系统，可以7x24小时在线，
支持多轮对话和知识库管理，帮助企业降低客服成本，提升客户满意度。」

请从以下角度优化：
1. **痛点驱动版**：从用户痛点切入，制造共鸣
2. **数据支撑版**：加入具体的效果数据（如降低客服成本XX%）
3. **场景化版**：描述具体的使用场景和用户故事
4. **极简版**：控制在50字以内，适合广告投放

每种版本提供2个备选方案。"""
```

---

## 3. 配置参数建议

### 3.1 Temperature

| 任务类型   | 推荐Temperature | 说明               |
| ---------- | --------------- | ------------------ |
| 搜索问答   | 0.2 - 0.4       | 保持准确性和事实性 |
| Agent 任务 | 0.3 - 0.5       | 平衡稳定性和灵活性 |
| 创意写作   | 0.7 - 0.9       | 高温度增加文采     |
| 内容优化   | 0.5 - 0.7       | 平衡创意和准确性   |
| 数据分析   | 0.1 - 0.3       | 确保分析严谨       |

---

## 4. 参考资料

### 官方文档

1. **百度文心一言开放平台**  
   https://yiyan.baidu.com  
   文心一言官网，可在线体验。

2. **百度千帆大模型平台文档**  
   https://cloud.baidu.com/doc/WENXINWORKSHOP/index.html  
   百度千帆平台 API 文档。

3. **ERNIE 5.1 技术博客**  
   https://ernie.baidu.com/blog/zh/posts/ernie-5.1-0508-release/  
   百度官方发布的 ERNIE 5.1 详细介绍。

---

## 📝 更新日志

- **2026-05-31**：初始版本发布，包含 ERNIE 5.1 提示词指南

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
**版本**：v1.0
