---
title: KEC平台 - 班级状态计算逻辑修复记录
sidebar: false
---

# 班级状态计算逻辑逻辑修复记录

## 问题描述

在班级管理页面中，2023年入学、3年制的班级显示为"已毕业"，但实际上它们应该还是"在读"状态。

**具体情况**：
- 当前学期：2025-2026学年第2学期（2026年春季）
- 2023级学生：入学于2023年9月
- 当前年级：2025 - 2023 + 1 = 3年级
- 当前学期：(3-1)×2 + 2 = 第6学期
- 总学期数：3 × 2 = 6学期
- **正确状态**：在校（因为第6学期 <= 6学期）
- **错误显示**：已毕业

## 根本原因

原有的状态计算逻辑只比较年份，没有考虑具体的学期：

```javascript
// 旧代码 - 错误
const graduationYear = enrollmentYear + durationYears;
return currentYear < graduationYear ? 'active' : 'graduated';
```

这导致2023 + 3 = 2026，而当前年份是2025或2026，判断条件不稳定。

## 修复方案

### 1. 修正计算逻辑

使用年级与学制进行比较：

```javascript
// 新代码 - 正确
const grade = startYear - enrollmentYear + 1;
return grade <= durationYears ? 'active' : 'graduated';
```

**关键规则**：
- 从系统设置中获取当前学期配置（如 "2025-2026-2"）
- 提取起始学年（startYear = 2025）
- 计算年级：grade = 2025 - 2023 + 1 = 3
- 判断：3 <= 3 → 在校 ✓

### 2. 批量更新历史数据

执行脚本 `node scripts/update-class-status.js` 更新了所有班级的状态：
- 共检查 216 个班级
- 更新了 27 个班级的状态
- 主要是2023年入学的3年制班级

### 3. 确保自动更新

修改后端API，确保每次编辑班级时都会重新计算状态：

**文件**: `server/src/routes/class.routes.js`

**修改点**:
1. `POST /api/classes` - 创建班级时自动计算
2. `PUT /api/classes/:id` - 更新班级时始终重新计算（忽略前端传来的status）
3. `import.routes.js` - Excel导入时自动计算

## 验证结果

### 测试案例

| 入学年份 | 学制 | 当前年级 | 计算结果 | 数据库状态 | 验证 |
|---------|------|---------|---------|-----------|------|
| 2023 | 3年 | 3年级 | active | active | ✓ |
| 2024 | 3年 | 2年级 | active | active | ✓ |
| 2025 | 3年 | 1年级 | active | active | ✓ |
| 2022 | 3年 | 4年级 | graduated | graduated | ✓ |

### 特殊案例说明

**2023级（3年制）**：
- 当前处于第6学期（最后一学期的第二个学期）
- 状态：**在校**（不是已毕业）
- 只有到了下一学期（2026-2027学年第1学期，即第7学期）才会变为"已毕业"

这种设计确保了学生在整个最后一学年都保持"在校"状态，直到真正毕业后才自动切换。

## 修改的文件清单

1. **server/src/routes/class.routes.js**
   - 重写 `calculateClassStatus` 函数
   - 添加详细的注释和示例
   - 修改创建和更新逻辑，始终使用学期信息计算状态

2. **server/src/routes/import.routes.js**
   - 导入 `getCurrentSemesterInfo`
   - 在Excel导入时使用正确的计算逻辑

3. **server/scripts/update-class-status.js** (新建)
   - 批量更新所有班级状态的脚本

4. **docs/semester-calculation.md**
   - 新增"班级状态计算规则"章节
   - 添加详细的计算公式和实际案例

## 使用说明

### 对于用户

1. **查看班级状态**：在班级管理页面，状态列会显示"在读"或"已毕业"
2. **编辑班级**：修改入学年份或学制后，状态会自动重新计算
3. **手动设置**：虽然表单中有状态下拉框，但保存时会被自动计算的值覆盖

### 对于开发者

如果需要手动触发状态更新：

```bash
cd server
node scripts/update-class-status.js
```

这会根据当前的学期配置重新计算所有班级的状态。

## 日期

2026-06-09
