# 教材查询性能优化方案

> 本文档反映的代码版本：2026-06-11

> ⚠️ **文档状态：方案设计（待实施）**  
> 本文档描述的性能优化方案尚未在代码中实施。当前代码仍使用全量加载+去重方案。

## 背景

KEC 课程管理平台中，教材使用情况查询接口 `GET /api/query/textbooks` 当前采用**全量加载 + 内存匹配**的策略，在数据规模增长时存在性能隐患。

## 当前实现分析

### 查询逻辑

```js
// query.routes.js 第 300-373 行
router.get('/textbooks', async (req, res, next) => {
  // 1. 全量加载所有教材（含关联的 plan_textbooks）
  const textbooks = await prisma.textbooks.findMany({
    include: { plan_textbooks: { ... } },
  });

  // 2. 全量加载所有活跃班级
  const allClasses = await prisma.classes.findMany({
    where: { status: 'active' },
  });

  // 3. 嵌套循环匹配：每本教材 × 每个关联 × 每个班级
  for (const tb of textbooks) {
    for (const pt of tb.plan_textbooks) {
      for (const c of allClasses) {
        if (c.enrollment_year !== enrollmentYear) continue;
        if (isClassMatchPlan(c, plan)) {
          usedClasses.add(c.id);
          totalStudents += c.student_count;
        }
      }
    }
  }
});
```

### 性能瓶颈

| 指标 | 当前（200教材 / 500班级） | 增长趋势 |
|------|--------------------------|----------|
| 数据库查询 | 2 次（全量） | 不变 |
| 内存匹配循环 | ~200 × 3000 × 500 ≈ 3 亿次 | O(n³) |
| 响应时间 | 1~3 秒 | 线性增长 |

## 优化方案：分类筛选 + 后端 WHERE

### 核心思路

不要先查全部再过滤，而是**让数据库在查询阶段就缩小结果集**。

```
优化前：全量查询 → 前端展示全部
优化后：前端选择类别 → 后端 WHERE category → 仅返回该类别教材
```

### 前端改造：级联选择器

```
┌──────────────────────────────────────────────┐
│  教材类别（一级）                              │
│  ┌──────────────────────────────────────┐     │
│  │ 全部类别 ▾                            │     │
│  │  ├─ 公共基础课                        │     │
│  │  ├─ 专业核心课                        │     │
│  │  ├─ 专业拓展课                        │     │
│  │  ├─ 实践教学课                        │     │
│  │  └─ 通识选修课                        │     │
│  └──────────────────────────────────────┘     │
│                                                │
│  教材名称（二级，根据类别联动）                  │
│  ┌──────────────────────────────────────┐     │
│  │ 请选择教材 ▾                           │     │
│  │  ├─ 高等数学（第七版）                 │     │
│  │  ├─ 线性代数                          │     │
│  │  └─ 概率论与数理统计                   │     │
│  └──────────────────────────────────────┘     │
└──────────────────────────────────────────────┘
```

联动逻辑：一级菜单选择类别 → 二级菜单仅加载该类别的教材 → 选中后调用查询接口。

### 后端改造：添加 category 参数

**文件**：`server/src/routes/query.routes.js`

在 `GET /api/query/textbooks` 接口中添加 `category` 查询参数：

```js
router.get('/textbooks', async (req, res, next) => {
  try {
    const semesterInfo = await getCurrentSemesterInfo();
    if (!semesterInfo) return fail(res, '请先设置当前学期');

    const { category } = req.query;  // 新增：类别筛选

    const textbookWhere = {};
    if (category) {
      textbookWhere.category = category;  // 数据库层面过滤
    }

    const [textbooks, allClasses] = await Promise.all([
      prisma.textbooks.findMany({
        where: textbookWhere,  // 使用条件过滤
        include: { plan_textbooks: { ... } },
        orderBy: { id: 'asc' },
      }),
      prisma.classes.findMany({ where: { status: 'active' } }),
    ]);

    // 后续匹配逻辑不变...
```

### 同时新增：类别列表接口

方便前端获取所有可用类别，用于填充一级下拉菜单：

```js
// GET /api/query/textbook-categories
router.get('/textbook-categories', async (req, res, next) => {
  try {
    const categories = await prisma.textbooks.findMany({
      select: { category: true },
      where: { category: { not: null }, is_active: true },
      distinct: ['category'],
      orderBy: { category: 'asc' },
    });
    success(res, categories.map(c => c.category));
  } catch (e) { next(e); }
});
```

## 效果预估

| 场景 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| 全量查询 | 200 本教材，1-3s | 不变 | — |
| 按类别查询（如"公共基础课"） | 200 本教材，1-3s | ~40 本，200-600ms | **约 5 倍** |
| 按类别 + 按教材查询 | 200 本教材，1-3s | 1 本，< 50ms | **约 20-60 倍** |

## 改造清单

| 文件 | 改动 | 说明 |
|------|------|------|
| `server/src/routes/query.routes.js` | 新增 `category` 参数筛选 | `GET /textbooks` 加 WHERE 条件 |
| `server/src/routes/query.routes.js` | 新增类别列表接口 | `GET /textbook-categories` |
| `client/src/api/query.js` | 新增类别 API 调用 | 封装前端请求 |
| `client/src/views/query/TextbookQuery.vue` | 改为级联选择器 | 一级类别 + 二级教材联动 |

## 扩展思考

如果未来教材超过 1000 本、班级超过 2000 个，SQLite 仍可胜任，但建议进一步优化：

1. **教材查询改为先匹配再聚合**：不嵌套循环所有班级，而是用 SQL JOIN + GROUP BY 在数据库层完成
2. **添加 Redis 缓存**：教材使用情况每小时变化不大，缓存 1 小时可大幅减少重复查询
3. **数据库迁移至 PostgreSQL**：当并发写入需求超过 50 用户/秒时，SQLite 单写锁会成为瓶颈
