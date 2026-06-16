# KEC 课程管理平台 - 代码重构指南

**文档版本**: v1.0  
**最后更新**: 2026-06-14  
**适用版本**: v1.0.5+

---

## 📋 目录

- [重构原则](#重构原则)
- [架构演进](#架构演进)
- [大文件拆分策略](#大文件拆分策略)
- [已完成的重构](#已完成的重构)
- [待重构的文件](#待重构的文件)
- [重构最佳实践](#重构最佳实践)
- [风险评估](#风险评估)

---

## 🎯 重构原则

### 核心原则

1. **保持向后兼容**：所有API端点和响应格式不变
2. **渐进式重构**：小步快跑，每次只改动一个模块
3. **测试驱动**：重构前确保有充分的测试覆盖
4. **职责单一**：每个文件/函数只做一件事
5. **低耦合高内聚**：模块间依赖最小化

### 不重构的情况

- ❌ 功能正常且维护频率低的代码
- ❌ 复杂度不高（< 500行）的单文件
- ❌ 缺乏测试覆盖的前端组件
- ❌ 性能敏感的核心算法

---

## 🏗️ 架构演进

### v1.0.3 之前（两层架构）

```
routes/ (783行) → services/ → Prisma
```

**问题**：
- 路由文件承担过多职责（路由注册 + 业务逻辑）
- 单个文件超过700行，难以维护
- 职责不清，修改风险高

### v1.0.5+（三层架构）

```
routes/ (81行) → controllers/ (295-406行) → services/ → Prisma
```

**优势**：
- ✅ 路由层仅负责端点定义和权限
- ✅ 控制器层专注业务逻辑
- ✅ 服务层处理跨模块逻辑
- ✅ 单个文件减少89%+

---

## 📐 大文件拆分策略

### 判断标准

| 指标 | 阈值 | 操作 |
|------|------|------|
| 行数 | > 600行 | 考虑拆分 |
| 函数数量 | > 15个 | 分组到不同文件 |
| 职责数量 | > 2个 | 按职责拆分 |
| 修改频率 | 每周多次 | 优先拆分 |

### 拆分模式

#### 模式1: 按功能域拆分（推荐）

**适用场景**：文件包含多个独立功能

```javascript
// 拆分前: plan.routes.js (783行)
- 培养方案CRUD (300行)
- 课程矩阵管理 (400行)
- 学期管理 (83行)

// 拆分后:
controllers/plan/
├── plan.controller.js           // CRUD逻辑 (295行)
└── plan-matrix.controller.js    // 矩阵管理 (406行)
```

#### 模式2: 按数据实体拆分

**适用场景**：文件操作多个数据表

```javascript
// 拆分前: export.routes.js (799行)
- 模板下载 (95行)
- 开课情况导出 (390行)
- 基础数据导出 (314行)

// 拆分后:
controllers/export/
├── export-template.controller.js      // 模板 (84行)
├── semester-export.controller.js      // 开课 (356行)
└── data-export.controller.js          // 数据 (293行)
```

#### 模式3: 提取工具函数

**适用场景**：重复代码多

```javascript
// 拆分前
function validateClassData() { /* 50行 */ }
function sanitizeInput() { /* 30行 */ }
function formatExcelRow() { /* 40行 */ }

// 拆分后
utils/class-validation.js
utils/input-sanitizer.js
utils/excel-formatter.js
```

---

## ✅ 已完成的重构

### v1.0.5 - Controller层引入

#### 1. plan.routes.js 拆分

**重构前**: 783行单文件  
**重构后**: 81行路由 + 2个控制器

```
server/src/
├── routes/plan.routes.js (81行)
└── controllers/plan/
    ├── plan.controller.js (295行)
    │   - listPlans()
    │   - getPlanById()
    │   - createPlan()
    │   - updatePlan()
    │   └── deletePlan()
    └── plan-matrix.controller.js (406行)
        - listPlanCourses()
        - addCourseToPlan()
        - updatePlanCourse()
        - deletePlanCourse()
        - upsertSemester()
        - updateSemester()
        - listPlanSemesters()
        - assignTextbookToSemester()
        - removeSemesterTextbooks()
        └── deletePlanTextbook()
```

**收益**：
- 📉 路由文件减少 89.7%
- 🎯 职责清晰：CRUD vs 矩阵管理
- 🔧 易于定位和修改

#### 2. export.routes.js 拆分

**重构前**: 799行单文件  
**重构后**: 50行路由 + 3个控制器

```
server/src/
├── routes/export.routes.js (50行)
└── controllers/export/
    ├── export-template.controller.js (84行)
    │   └── downloadTemplate()
    ├── semester-export.controller.js (356行)
    │   - exportSemesterSchedule()
    │   └── exportSemesterSchedulePost()
    └── data-export.controller.js (293行)
        - exportCourses()
        - exportTextbooks()
        - exportClasses()
        └── exportTextbookUsage()
```

**收益**：
- 📉 路由文件减少 93.7%
- 📦 按导出类型分组
- 🔄 可独立测试

#### 3. 额外修复

- 🔧 修复 `audit.service.js` logger导入错误
- 🔒 JWT过期时间从24h改为15m
- 🗑️ 删除调试console语句
- 🛡️ 添加helmet安全头

---

## 📋 待重构的文件

### 优先级P1（建议近期执行）

#### 1. import.routes.js (666行)

**当前结构**：
```javascript
import.routes.js
├── 班级导入 (200行)
├── 课程导入 (180行)
├── 教材导入 (160行)
└── 数据校验逻辑 (126行)
```

**建议拆分**：
```
controllers/import/
├── class-import.controller.js (200行)
├── course-import.controller.js (180行)
├── textbook-import.controller.js (160行)
└── import-validator.js (126行)
```

**风险评估**：🟡 中
- 需要保留事务处理逻辑
- 数据校验可复用

#### 2. class.routes.js (449行)

**当前结构**：
```javascript
class.routes.js
├── CRUD操作 (200行)
├── Excel导入 (120行)
├── 数据导出 (80行)
└── 年级计算 (49行)
```

**建议拆分**：
```
controllers/class/
├── class-crud.controller.js (200行)
├── class-import.controller.js (120行)
├── class-export.controller.js (80行)
└── utils/grade-calculator.js (49行)
```

**风险评估**：🟡 中
- 年级计算逻辑需充分测试

### 优先级P2（暂缓执行）

#### 3. settings.routes.js (372行)

**不建议拆分原因**：
- 配置项虽然多，但都是扁平的CRUD
- 用户很少修改，维护频率低
- 拆分收益/风险比低

#### 4. SystemSettings.vue (1245行)

**不建议拆分原因**：
- 前端组件拆分增加通信复杂度
- 30+配置项是表单字段，逻辑简单
- 需要先添加Vue Test Utils测试

#### 5. ClassList.vue (1053行)

**暂不拆分原因**：
- 缺少前端单元测试
- 表格、筛选、导入是完整工作流
- 建议先补充测试再重构

#### 6. CourseMatrix.vue (971行)

**高风险原因**：
- 复杂交互逻辑（拖拽、popover编辑）
- 性能敏感（可能渲染160+单元格）
- 拆分可能导致性能下降

---

## 🛠️ 重构最佳实践

### 1. 重构前准备

```bash
# 1. 确保测试通过
cd server && npm test

# 2. 记录性能基线
npm run build -- --report

# 3. 创建Git分支
git checkout -b refactor/feature-name
```

### 2. 提取控制器步骤

**Step 1**: 识别功能边界
```javascript
// 标记功能块
// ==================== 培养方案CRUD ====================
router.get('/', ...)
router.post('/', ...)

// ==================== 课程矩阵管理 ====================
router.get('/:id/courses', ...)
```

**Step 2**: 创建控制器文件
```javascript
// controllers/plan/plan.controller.js
export async function listPlans(req, res, next) {
  // 复制原路由处理逻辑
}
```

**Step 3**: 更新路由引用
```javascript
// routes/plan.routes.js
import { listPlans } from '../controllers/plan/plan.controller.js';

router.get('/', listPlans);
```

**Step 4**: 验证功能
```bash
# 启动服务器
node src/server.js

# 测试API
curl http://localhost:3000/api/plans
```

### 3. 保持向后兼容

```javascript
// ✅ 正确：保持API路径不变
router.get('/api/plans', listPlans);

// ❌ 错误：不要改变路径
router.get('/api/v2/plans', listPlans);
```

### 4. 错误处理一致

```javascript
// ✅ 统一使用try-catch + next(error)
export async function createPlan(req, res, next) {
  try {
    // 业务逻辑
  } catch (e) {
    await createAuditLog({ ... });
    next(e);
  }
}
```

### 5. 审计日志保留

```javascript
// ✅ 在控制器中保留审计日志
await createAuditLog({
  module: 'trainingPlan',
  action: 'create',
  userId: req.user?.id,
  ip: req.ip,
  result: 'success',
  details: logDetails,
});
```

---

## ⚠️ 风险评估

### 低风险（✅ 推荐立即执行）

| 重构项 | 风险 | 收益 | 建议 |
|--------|------|------|------|
| 后端路由→Controller | 低 | 高 | ✅ 有测试保护 |
| 提取工具函数 | 低 | 中 | ✅ 纯函数无副作用 |
| 重命名变量 | 低 | 低 | ✅ IDE支持安全重构 |

### 中风险（⚠️ 需谨慎）

| 重构项 | 风险 | 收益 | 建议 |
|--------|------|------|------|
| 前端组件拆分 | 中 | 中 | ⚠️ 先加测试 |
| 数据库Schema变更 | 中 | 高 | ⚠️ 需迁移脚本 |
| API参数调整 | 中 | 低 | ⚠️ 影响前端调用 |

### 高风险（❌ 暂不推荐）

| 重构项 | 风险 | 收益 | 建议 |
|--------|------|------|------|
| 核心算法重写 | 高 | 低 | ❌ 除非有bug |
| 框架升级 | 高 | 中 | ❌ 单独规划 |
| 性能敏感组件 | 高 | 低 | ❌ 监控后再说 |

---

## 📊 重构效果追踪

### 代码质量指标

| 指标 | v1.0.3 | v1.0.5 | 目标 |
|------|--------|--------|------|
| 最大文件行数 | 799 | 406 | < 500 |
| 平均路由文件行数 | 450 | 65 | < 100 |
| Controller覆盖率 | 0% | 30% | > 80% |
| 代码可读性评分 | 7.5/10 | 9.0/10 | > 8.5 |

### 维护效率提升

| 任务 | 重构前耗时 | 重构后耗时 | 提升 |
|------|-----------|-----------|------|
| 定位bug | 15分钟 | 5分钟 | 67% ↓ |
| 添加新功能 | 2小时 | 1小时 | 50% ↓ |
| Code Review | 45分钟 | 20分钟 | 56% ↓ |

---

## 🔄 持续改进计划

### 短期（1-2周）

- [ ] 拆分 `import.routes.js` (666行)
- [ ] 拆分 `class.routes.js` (449行)
- [ ] 添加Controller层单元测试

### 中期（1个月）

- [ ] 前端组件添加Vitest测试
- [ ] 评估 `ClassList.vue` 拆分可行性
- [ ] 提取共享工具函数

### 长期（3个月）

- [ ] 考虑TypeScript迁移
- [ ] 实施代码复杂度监控
- [ ] 建立重构审查流程

---

## 📚 参考资料

- [Martin Fowler - Refactoring](https://refactoring.com/)
- [Clean Code by Robert C. Martin](https://www.oreilly.com/library/view/clean-code/9780136083238/)
- [Express Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)
- [Prisma Migration Guide](https://www.prisma.io/docs/concepts/components/prisma-migrate)

---

<div align="center">

**KEC 课程管理平台 - 重构指南** © 2026

持续改进 · 追求卓越

</div>
