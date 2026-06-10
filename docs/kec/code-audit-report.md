# KEC 课程管理平台 - 全面代码审查报告

**审查日期：** 2026-06-10  
**审查范围：** 后端 32 个源文件 + 前端 36 个源文件 + Prisma Schema  
**发现问题：** 共 28 个已确认问题（去重后）

---

## 问题总览

| 严重级别 | 数量 | 说明 |
|----------|------|------|
| Critical | 4 | 安全漏洞或功能完全不可用，需立即修复 |
| High | 7 | 影响功能正确性，需尽快修复 |
| Medium | 10 | 影响体验/性能/健壮性 |
| Low | 7 | 代码质量/安全加固 |

---

## 一、严重问题 (Critical) — 建议立即修复

### 1. [安全] 7 个数据重置接口缺少权限验证 — 任何登录用户可清空数据库

**文件：** `server/src/routes/settings.routes.js:63, 82, 101, 120, 132, 142, 150`  
**类别：** 安全漏洞

`POST /reset/majors`、`/reset/colleges`、`/reset/levels`、`/reset/courses`、`/reset/textbooks`、`/reset/classes`、`/reset/plans` 均**没有** `roleMiddleware('super_admin')` 保护。

而 `app.js:88` 对 settings 路由只应用了全局 `authMiddleware`（仅需登录）：

```javascript
// app.js:88
app.use('/api/settings', authMiddleware, settingsRoutes);
```

**影响：** `viewer` 角色的用户也可以直接调用这些接口清空专业、学院、课程、教材、班级、培养方案等核心数据，造成灾难性数据丢失。

**对比：** 同一文件中 `/reset/basic`（行49）、`/reset/settings`（行162）、`/reset/audit-logs`（行193）和 `PUT /`（行34）都有 `roleMiddleware('super_admin')`。

**修复方向：** 为所有缺失权限检查的 reset 路由添加 `roleMiddleware('super_admin')`，或将 reset 路径统一注册为需要 super_admin 权限。

---

### 2. [功能] 教材导出使用了错误的 Prisma 关系名 — 功能完全不可用

**文件：** `server/src/routes/export.routes.js:294-303`  
**类别：** 逻辑错误

```javascript
// 当前代码（错误）                 // Prisma Schema 中的正确名称
planTextbooks: {                   // → plan_textbooks
  include: { semester: {           // → plan_course_semesters
    include: { planCourses: {      // → plan_courses  
      include: { plan: {...} }     // → training_plans
```

Prisma Schema 中所有关系名均使用 snake_case，但此处使用了 camelCase。Prisma 会直接抛出 `Unknown relation field` 验证错误。

**影响：** 教材导出功能完全崩溃，用户每次导出都会收到 500 错误。

**参考：** `query.routes.js` 中正确使用了 snake_case 关系名。

---

### 3. [功能] 教材导出查询结果字段访问也是错误的

**文件：** `server/src/routes/export.routes.js:334-337`  
**类别：** 逻辑错误

即使 Issue #2 修复后，后续访问查询结果的代码也使用了错误的字段名：

```javascript
for (const pt of textbook.plan_textbooks) {  // 修复 #2 后才能到这
  const sem = pt.semester;          // ← 应为 pt.plan_course_semesters
  const pc = sem.plan_courses;      // ← 正确
  const plan = pc.plan;             // ← 应为 pc.training_plans
```

**影响：** 所有字段访问都会得到 `undefined`，导致后续 `sem.semester`、`pc.courses.name` 等全部崩溃。

---

### 4. [功能] 学期导出中自定义方案的班级被跳过

**文件：** `server/src/routes/export.routes.js:156-157`  
**类别：** 逻辑错误

```javascript
if (cls.custom_plan_id) {
  return cls.customPlan;  // ← undefined！include 的关系名是 training_plans
}
```

查询中 include 的关系名是 `training_plans`，但代码访问 `cls.customPlan`（始终为 `undefined`）。

**影响：** 所有设置了自定义培养方案的班级，在学期导出 Excel 中被完全遗漏。

**参考：** `query.routes.js:75` 中正确使用了 `cls.training_plans`。

---

## 二、高优先级 (High) — 影响功能正确性

### 5. 班级更新会意外清除 custom_plan_id

**文件：** `server/src/routes/class.routes.js:272`  
**类别：** 逻辑错误

```javascript
custom_plan_id: customPlanId !== undefined && customPlanId !== null 
  ? Number(customPlanId) : null,
```

当前端发送 PUT 请求但**没有包含 `customPlanId` 字段**时，`customPlanId` 为 `undefined`，条件 `customPlanId !== undefined` 为 `false`，结果赋值为 `null`。

**影响：** 每次更新班级信息（即使只是想改个名字），都会静默移除已关联的自定义培养方案，导致查询报表中该班级不再显示正确的课程安排。

**修复方向：** 未提供时应保留原值：

```javascript
custom_plan_id: customPlanId !== undefined 
  ? (customPlanId ? Number(customPlanId) : null) 
  : undefined,  // undefined 让 Prisma 跳过该字段
```

---

### 6. 培养方案审计日志引用错误的属性名 — 日志始终记录"未设置"

**文件：** `server/src/routes/plan.routes.js:149-151`（POST 创建）和 `230-244`（PUT 更新）  
**类别：** 逻辑错误

```javascript
colleges: plan.college?.name || '未设置',        // → plan.colleges?.name
majors: plan.major?.name || '未设置',            // → plan.majors?.name  
training_levels: plan.trainingLevel?.name || '未设置', // → plan.training_levels?.name
```

Prisma 关系名是 `colleges`/`majors`/`training_levels`（复数/下划线），代码使用了单数/驼峰形式。

**影响：** 所有培养方案的创建和更新操作，审计日志中的部门/专业/层次信息均错误记录为"未设置"，失去审计追溯价值。

---

### 7. 方案课程添加的审计日志引用不存在的属性

**文件：** `server/src/routes/plan.routes.js:411`  
**类别：** 逻辑错误

```javascript
details: `为培养方案添加课程 ID: ${pc.courseId}`,
// pc.courseId 为 undefined，应为 pc.course_id
```

**影响：** 审计日志记录为 `"为培养方案添加课程 ID: undefined"`，无法追溯具体添加了哪门课程。

---

### 8. errorHandler 无法识别 AppError.statusCode

**文件：** `server/src/middleware/error.js:6`  
**类别：** 逻辑错误

```javascript
const status = err.status || 500;  // AppError 用的是 statusCode，不是 status
```

**影响：** 所有 `AppError` 子类（`NotFoundError`/`ValidationError`/`AuthenticationError`/`AuthorizationError`/`ConflictError`）都会返回 500 而非预期的 404/422/401/403/409。虽然目前路由中未直接使用这些错误类，但一旦开始使用就会出问题。

**修复方向：** 将 `err.status` 改为 `err.status || err.statusCode`。

---

### 9. 重置基础数据不清空培养方案 — 产生孤立数据

**文件：** `server/src/routes/settings.routes.js:49-58`  
**类别：** 数据一致性

`/reset/basic` 清空了 `classes`、`textbooks`、`courses`、`majors`、`colleges`、`training_levels`，但**没有清空** `training_plans` 及其关联表（`plan_courses`、`plan_course_semesters`、`plan_textbooks`）。

**影响：** 重置后 `training_plans` 仍然存在，但其引用的 `majors`、`colleges`、`training_levels` 已被删除，系统中残留大量孤立的培养方案数据。

**修复方向：** 在 `/reset/basic` 中按依赖顺序先清空 `plan_textbooks` → `plan_course_semesters` → `plan_courses` → `training_plans`。

---

### 10. 所有重置操作缺少事务保护

**文件：** `server/src/routes/settings.routes.js:49-189`（所有 reset 端点）  
**类别：** 数据一致性

每个 reset 端点包含多个独立的 `deleteMany` 操作（`/reset/settings` 有 11 个连续调用），没有使用 `prisma.$transaction()`。

**影响：** 中途某个操作失败会导致数据部分清空的不一致状态，且难以恢复。

---

### 11. 教材关联操作缺少事务保护

**文件：** `server/src/routes/plan.routes.js:693-704`  
**类别：** 数据一致性

"先删后增"模式没有事务包裹：

```javascript
await prisma.plan_textbooks.deleteMany({ where: { semester_id: Number(id) } });
// 如果下面的 create 失败，旧数据已丢失！
const pt = await prisma.plan_textbooks.create({ data: { ... } });
```

**影响：** 如果 create 操作失败，原有的教材关联已被删除但新关联未创建，数据丢失。

---

## 三、前端严重/高优先级问题

### 12. [安全] dangerouslyUseHTMLString 存在 XSS 风险

**文件：** `client/src/views/class/ClassList.vue:818-833`  
**类别：** 安全漏洞

```javascript
function showErrorsDialog(errors) {
  const errorListHtml = errors.map((error, index) => 
    `<div>...${error}</div>`  // error 来自服务器，未转义
  ).join('')
  
  ElMessageBox.alert(
    `<div>...${errorListHtml}</div>`,
    ...,
    { dangerouslyUseHTMLString: true }
  )
}
```

**影响：** 恶意用户可通过构造特殊班级名称（如 `<img src=x onerror=alert(1)>`），在导入失败时触发 XSS。

---

### 13. fetchUserInfo / 401 重试无递归深度限制

**文件：** `client/src/stores/auth.js:78-91`, `client/src/utils/request.js:52-84`  
**类别：** 逻辑错误

`fetchUserInfo` 在 catch 中调用 `refreshAccessToken()` 后递归调用自身，无深度限制。`request.js` 的 401 拦截器也存在类似问题。

```javascript
async function fetchUserInfo() {
  try {
    const response = await request.get('/auth/me')
    // ...
  } catch (error) {
    const refreshed = await refreshAccessToken()
    if (refreshed) {
      return fetchUserInfo()  // 无限递归！
    }
  }
}
```

**影响：** 如果 token 刷新后请求仍然 401，会形成无限递归循环，浏览器发出大量请求直至卡死。

---

### 14. localStorage 中 userInfo 解析无 try-catch

**文件：** `client/src/stores/auth.js:9`  
**类别：** 类型安全

```javascript
const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || 'null'))
```

**影响：** 如果 localStorage 中的 `userInfo` 值是非法 JSON（被手动篡改、存储损坏），`JSON.parse` 抛出异常，导致整个 auth store 初始化失败，页面白屏崩溃。

---

### 15. 排序按钮在筛选激活时操作错误的记录

**文件：** `client/src/views/plan/PlanList.vue:65`, `client/src/views/textbook/TextbookList.vue:75`  
**类别：** 逻辑错误

表格渲染的是 `filteredlist`（筛选后数据），`$index` 是其索引；但排序函数用这个索引访问 `list`（完整数据），操作对象完全错误。

```html
<el-table :data="filteredlist">
  <!-- $index 是 filteredlist 的索引 -->
  <el-button :disabled="$index === list.length - 1" @click="handleMoveDown(row, $index)" />
</el-table>
```

**影响：** 当用户筛选后点击排序按钮，会交换完全错误的两条记录，导致数据顺序混乱。

---

## 四、中等优先级 (Medium) — 体验/性能/健壮性

### 16. 审计日志 API 响应 "logs" 数组未被命名转换中间件处理

**文件：** `server/src/middleware/naming.middleware.js:34-42`  
**类别：** 命名转换遗漏

中间件只处理 `data` 和 `items` 两种属性名，`logs` 数组中的 `created_at`、`operator_id` 等字段不会被转为 camelCase。

**影响：** 前端 `AuditLog.vue:68` 访问 `row.createdAt` 始终为 `undefined`，操作日志页面"操作时间"列始终显示 "-"。

---

### 17. ClassList 筛选框每次击键触发 API 请求（无 debounce）

**文件：** `client/src/views/class/ClassList.vue:8`  
**类别：** 性能

```html
<el-input v-model="filterName" @input="resetPaginationAndLoad" />
```

**影响：** 输入"2024级学前1班"（8个字符）将发送 8 个 HTTP 请求，多个并发请求可能以乱序返回，导致表格数据闪烁。

---

### 18. SemesterQuery 导出未携带筛选参数

**文件：** `client/src/views/query/SemesterQuery.vue:144-151`  
**类别：** 逻辑遗漏

```javascript
function exportExcel() {
  window.open(`/api/export/semester?token=${token}`, '_blank')
}
```

**影响：** 用户设置学院、专业、层次等筛选条件后点导出，导出的是全量数据而非筛选结果。

---

### 19. 教材查询 totalStudents 可能重复计算

**文件：** `server/src/routes/query.routes.js:343-358`  
**类别：** 逻辑错误

```javascript
if (isClassMatchPlan(c, plan)) {
  usedClasses.add(c.id);             // Set 去重
  totalStudents += c.student_count;  // 但这里每次都加！
}
```

**影响：** 如果一个教材被关联到多个培养方案或多个学期，同一班级的学生人数会被重复计算。

---

### 20. getCurrentSemesterInfo 未校验数据格式

**文件：** `server/src/services/settings.service.js:6-9`  
**类别：** 健壮性

```javascript
const parts = setting.value.split('-');
const startYear = Number(parts[0]);  // 格式异常时为 NaN
```

**影响：** 如果 `current_semester` 值格式异常，`NaN` 传播到所有下游计算（班级状态判断、年级计算等），全部失效且无错误提示。

---

### 21. PlanDetail 加载所有方案只为查找一个

**文件：** `client/src/views/plan/PlanDetail.vue:86-89`  
**类别：** 性能

```javascript
const res = await getPlans()  // 获取全部培养方案
plan.value = (res.data || []).find((p) => p.id === planId)  // 只用一个
```

**影响：** 当方案数量增多时，造成不必要的网络流量和延迟。

---

### 22. ClassList 额外请求 1000 条记录只为提取入学年份

**文件：** `client/src/views/class/ClassList.vue:436-446`  
**类别：** 性能

```javascript
const allRes = await getClasses({ pageSize: 1000 })  // 获取1000条
// 只为了提取 enrollmentYear 的去重值
```

**影响：** 每次无筛选加载时多一个大数据量请求，如果班级超过 1000 条，部分年份会丢失。

---

### 23. 导入循环内重复查询 getCurrentSemesterInfo

**文件：** `server/src/routes/import.routes.js:216`  
**类别：** 性能

`getCurrentSemesterInfo()` 在循环内调用，100 行的 Excel 多执行 100 次数据库查询。

---

### 24. JWT Secret 硬编码为默认值

**文件：** `server/src/config/auth.config.js:2`  
**类别：** 安全

```javascript
jwtSecret: process.env.JWT_SECRET || 'kec-course-management-secret-key-2026',
```

`.env` 中未定义 `JWT_SECRET`，JWT 始终使用公开的硬编码默认值签名。

**影响：** 获取源码的攻击者可以为任意用户（包括 super_admin）生成合法 Token。

---

### 25. 大量 console.log 残留在导入路由

**文件：** `server/src/routes/import.routes.js` 约 30+ 处  
**类别：** 代码质量

包含完整的请求数据、用户信息、行数据等调试日志。

**影响：** 生产环境产生日志噪音，可能泄露敏感信息（如用户 token、完整行数据）。

---

## 五、低优先级 (Low) — 代码质量/安全加固

### 26. `.env` 未加入 `.gitignore`

**文件：** `.gitignore`  
**类别：** 安全

`.gitignore` 只忽略了 `.env.local`，没有忽略 `.env`。生产环境配置的数据库连接串可能被提交到仓库。

---

### 27. Token 通过 URL 参数传递

**文件：** `ClassList.vue:634`, `SemesterQuery.vue:148`, `TextbookQuery.vue:83`, `TextbookList.vue:408`  
**类别：** 安全

```javascript
window.open(`/api/export/semester?token=${token}`, '_blank')
```

Token 会出现在浏览器历史记录、Web 服务器日志、Referer 头中。

---

### 28. convertRequestNaming 中间件已定义但未注册

**文件：** `server/src/middleware/naming.middleware.js:15-21`  
**类别：** 架构

`convertRequestNaming`（camelCase → snake_case）已定义但**从未在 `app.js` 中注册**。所有路由手动做字段名转换。

**影响：** 死代码容易误导开发者，增加维护心智负担。

---

### 29. validation.js 全部验证规则未使用

**文件：** `server/src/middleware/validation.js`  
**类别：** 架构

定义了 8 组验证规则（`validateLogin`, `validateClass` 等），但全部 routes 中零处引用。各路由全部做手动验证。

**影响：** `validateChangePassword` 定义的密码复杂度要求（大小写+数字+特殊字符）从未生效。

---

### 30. 健康检查泄露数据库错误详情

**文件：** `server/src/app.js:57`  
**类别：** 安全

```javascript
error: e.message  // 可能包含数据库路径或连接串
```

---

### 31. AppError 类体系定义了但未集成

**文件：** `server/src/utils/error.js`  
**类别：** 架构

定义了完整的错误类体系（`AppError`, `NotFoundError`, `ValidationError` 等），但搜索整个 `server/src` 目录，没有任何路由或服务文件导入这些类。

---

### 32. authMiddleware 在 user 路由重复执行

**文件：** `server/src/app.js:69` + `server/src/routes/user.routes.js:10`  
**类别：** 架构

`app.js` 挂载时已应用 `authMiddleware`，`user.routes.js` 又在 router 级别再次应用，导致每个请求 JWT 验证执行两次。

---

## 六、修复优先级建议

| 优先级 | 问题编号 | 预估工作量 |
|--------|---------|-----------|
| **立即修复** | #1, #2, #3, #4 | 小 |
| **尽快修复** | #5, #6, #7, #8, #9, #10, #11 | 中 |
| **下次迭代** | #12, #13, #14, #15, #16, #17, #18 | 中 |
| **逐步优化** | #19-#25 | 小到中 |
| **技术债务** | #26-#32 | 小 |

---

## 七、架构观察总结

1. **命名转换不对称：** 响应方向有自动 snake_case → camelCase 中间件，但请求方向未启用。所有路由手动解构 camelCase 字段并映射到 snake_case，增加了出错概率。

2. **Prisma 关系名易混淆：** Schema 使用 snake_case 关系名（`plan_textbooks`、`plan_course_semesters`），但部分代码误用了 camelCase（`planTextbooks`），说明缺乏统一的代码审查或测试覆盖。

3. **验证层和错误体系未集成：** `validation.js` 和 `utils/error.js` 看起来是为规范化开发准备的基建，但尚未集成到实际路由中。

4. **事务使用不足：** 涉及多表操作的场景（重置数据、导入、先删后增）普遍缺少事务保护。

5. **批量操作效率低：** 前端批量操作使用 `Promise.all(ids.map(...))` 发送 N 个独立请求，缺少后端批量 API 端点。

6. **前端权限控制与后端不一致：** 前端路由守卫按角色控制菜单显示，但后端部分接口缺少对应的权限验证，形成安全缺口。
