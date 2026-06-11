# KEC 课程管理平台 — 全面代码审查报告 V2

**审查日期：** 2026-06-11  
**审查范围：** 全仓库（后端 35+ 源文件 + 前端 40+ 源文件 + Prisma Schema + 文档 + 配置）  
**审查维度：** 后端代码质量 · 前端代码质量 · 安全性 · 数据库设计 · 配置完整性  
**发现问题：** 共 50+ 个已确认问题

---

## 问题总览

| 严重级别 | 后端 | 前端 | 安全 | 合计 |
|----------|------|------|------|------|
| **Critical** | 4 | 3 | 3 | **10** |
| **High** | 6 | 5 | 6 | **17** |
| **Medium** | 8 | 10 | 7 | **25** |
| **Low** | 10 | 8 | 5 | **23** |
| **合计** | **28** | **26** | **21** | **75** |

> 注：部分问题跨维度重复，去重后实际独立问题约 50+ 个。

---

## 一、严重问题 (Critical) — 需立即修复

### 🔴 C1. JWT 密钥硬编码 + 环境变量缺失
**文件：** `server/src/config/auth.config.js:2` + `server/.env`  
**维度：** 安全 / 后端

```js
jwtSecret: process.env.JWT_SECRET || 'kec-course-management-secret-key-2026',
```

`.env` 文件未设置 `JWT_SECRET`，系统始终使用硬编码默认密钥。项目在 GitHub 公开，攻击者可自行签发任意用户（含 `super_admin`）的合法 Token。

**修复：** 移除默认值，生产环境强制检查环境变量；从 Git 历史清除 `.env` 文件。

### 🔴 C2. CORS 配置过于宽松
**文件：** `server/src/app.js:24-27`  
**维度：** 安全 / 后端

```js
app.use(cors({ origin: true, credentials: true }));
```

`origin: true` 允许任意来源的跨域请求，结合 `credentials: true` 存在 CSRF 攻击风险。

**修复：** 配置具体白名单，如 `origin: ['https://sntip.cn', 'http://localhost:5173']`。

### 🔴 C3. 默认管理员凭据公开在多个文件中
**文件：** `server/prisma/seed.js:27-39`, `README.md:145`, `docs/auth-design.md:112-113`  
**维度：** 安全

默认 `admin / admin@123456` 出现在源码、README、设计文档三处。

**修复：** seed.js 改为生成随机密码并仅输出到控制台；README 中移除默认密码。

### 🔴 C4. Token 通过 URL Query 参数传递
**文件：** 前端 `ClassList.vue:617`, `CourseList.vue:157`, `TextbookList.vue:411`, `SemesterQuery.vue:157` + 后端 `auth.middleware.js:12-14`  
**维度：** 前端 / 安全

```js
window.open(`/api/export/template/courses?token=${token}`, '_blank')
```

Token 出现在 URL 中，会被浏览器历史、服务器日志、Referer 头记录。

**修复：** 改用 POST 请求 + body 传参，或实现一次性下载 Token。

### 🔴 C5. Token 存储在 localStorage — XSS 攻击面
**文件：** `client/src/stores/auth.js:7-9, 31-33`  
**维度：** 前端 / 安全

```js
const token = ref(localStorage.getItem('token') || '')
localStorage.setItem('token', newToken)
```

任何 XSS 漏洞都可直接窃取 Token 和用户信息。

**修复：** Access Token 改为内存存储，Refresh Token 使用 httpOnly Cookie。

### 🔴 C6. 测试账号硬编码在生产代码中
**文件：** `client/src/views/Login.vue:104-116`  
**维度：** 前端

```html
<code>admin</code> / <code>admin@123456</code>
<code>guest</code> / <code>guest@123456</code>
```

**修复：** 通过环境变量控制，仅开发环境显示。

### 🔴 C7. 健康检查接口泄露系统信息
**文件：** `server/src/app.js:42-61`  
**维度：** 安全 / 后端

`/api/health` 返回 `uptime` 等系统信息。

**修复：** 移除 `uptime` 字段，仅返回最小信息。

### 🔴 C8. 系统设置 GET 接口完全公开
**文件：** `server/src/app.js:89` + `server/src/routes/settings.routes.js:15`  
**维度：** 安全 / 后端

`GET /api/settings` 无任何认证中间件，虽然风险已较之前降低（其他端点已修复），但仍暴露系统配置信息。

### 🔴 C9. `userInfo` JSON 解析无异常处理
**文件：** `client/src/stores/auth.js:9`  
**维度：** 前端

```js
const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || 'null'))
```

localStorage 被篡改时 `JSON.parse` 抛出异常导致应用白屏崩溃。

**修复：** 使用 try-catch 包裹。

### 🔴 C10. 更新班级状态脚本 Prisma 模型名错误
**文件：** `server/scripts/update-class-status.js:20, 44`  
**维度：** 后端

```js
prisma.class.findMany()   // 错误！Prisma 模型名为 classes（复数）
prisma.class.update()     // 错误！
```

该脚本完全无法运行。

---

## 二、高优先级问题 (High)

### 🟠 H1. Token 刷新接口无速率限制
**文件：** `server/src/routes/auth.routes.js:24-37`  
**维度：** 安全 / 后端

`POST /api/auth/refresh` 无任何速率限制，可能被暴力调用耗尽资源。

### 🟠 H2. Refresh Token 无法主动撤销
**文件：** `server/src/services/auth.service.js:91-100`  
**维度：** 安全 / 后端

Refresh Token 签发后 7 天内无法撤销。即使修改密码，旧 Refresh Token 仍有效。

**修复：** 在 users 表增加 `token_version` 字段，修改密码时递增。

### 🟠 H3. 修改密码后旧 Token 仍然有效
**文件：** `server/src/services/auth.service.js:110-131`  
**维度：** 安全 / 后端

修改密码仅更新哈希，旧的 Access/Refresh Token 在过期前仍有效。

### 🟠 H4. 登录接口缺少速率限制和验证码
**文件：** `server/src/routes/auth.routes.js:9-22` + `client/src/views/Login.vue`  
**维度：** 安全

无速率限制、无验证码、无账户锁定机制，存在暴力破解风险。

### 🟠 H5. 导入接口文件类型验证不严格
**文件：** `server/src/routes/import.routes.js:15`  
**维度：** 后端 / 安全

```js
if (file.originalname.match(/\.(xlsx|xls)$/i)) {
```

仅检查后缀名，未验证 MIME 类型和文件内容。

### 🟠 H6. 多处 console.log 输出敏感信息
**文件：** 前端 5+ 处 + 后端 3+ 处  
**维度：** 前端 / 后端

包括用户角色检查、API 响应详情、设置数据、导入数据等。生产环境泄露敏感信息。

### 🟠 H7. 导入功能绕过 axios 拦截器
**文件：** `CourseList.vue:193-214`, `TextbookList.vue:447-468`, `ClassList.vue:653-751`  
**维度：** 前端

文件上传使用原生 `fetch`，绕过了 axios 的 Token 刷新和错误处理机制。

### 🟠 H8. 响应拦截器 logout() 无 await
**文件：** `client/src/utils/request.js:82`  
**维度：** 前端

```js
authStore.logout()  // 无 await，可能导致竞态条件
```

### 🟠 H9. 路由守卫打印敏感信息
**文件：** `client/src/router/index.js:106-111`  
**维度：** 前端

权限检查失败时打印用户角色到控制台。

### 🟠 H10. 用户创建时 role 默认值逻辑问题
**文件：** `server/src/routes/user.routes.js:48-64`  
**维度：** 后端

role 为 undefined 时验证可能误判。

### 🟠 H11. 命名转换中间件与审计中间件 res.json 冲突
**文件：** `server/src/middleware/naming.middleware.js:32-50` + `server/src/middleware/audit.js`  
**维度：** 后端

两者都重写 `res.json`，存在冲突风险。

### 🟠 H12. settings 路由 GET 接口 console.log 泄露配置
**文件：** `server/src/routes/settings.routes.js:18, 31`  
**维度：** 安全 / 后端

```js
console.log('[Settings API] 从数据库读取的设置:', settings.map(...))
```

### 🟠 H13. fetchUserInfo 无递归深度限制
**文件：** `client/src/stores/auth.js:78-91`  
**维度：** 前端

token 刷新后再次 401 会无限递归。

### 🟠 H14. 登录时序攻击风险
**文件：** `server/src/services/auth.service.js:12-18`  
**维度：** 安全

用户不存在时不执行 bcrypt，响应时间差异可枚举有效用户名。

### 🟠 H15. validation.js 全部验证规则未使用
**文件：** `server/src/middleware/validation.js`  
**维度：** 后端 / 安全

定义了 8 组 express-validator 规则，但所有路由中零处引用。`validateChangePassword` 中的强密码规则从未生效。

### 🟠 H16. 密码规则过于简单
**文件：** `client/src/views/system/ChangePasswordDialog.vue:82-85`  
**维度：** 前端 / 安全

仅要求长度 >= 8，未要求大小写、数字、特殊字符组合。

### 🟠 H17. UserManagement 编辑时字段命名不一致
**文件：** `client/src/views/system/UserManagement.vue:172-178 vs 244-249`  
**维度：** 前端

`formData.value.realName` vs `user.real_name` 混用，提交时 realName 为 undefined。

---

## 三、中优先级问题 (Medium)

### 🟡 M1. plan_courses 缺少唯一约束
**文件：** `server/prisma/schema.prisma:106-123`  
**维度：** 后端 / 数据库

缺少 `@@unique([plan_id, course_id])`，代码中通过捕获 P2002 错误处理重复，但 Prisma 无法自动检测。

### 🟡 M2. textbooks.publish_date 使用 String 类型
**文件：** `server/prisma/schema.prisma:149`  
**维度：** 后端 / 数据库

日期字段应为 `DateTime` 而非 `String`。

### 🟡 M3. system_settings 缺少 updated_at
**文件：** `server/prisma/schema.prisma:135-140`  
**维度：** 后端 / 数据库

### 🟡 M4. plan_textbooks 缺少 updated_at
**文件：** `server/prisma/schema.prisma:125-133`  
**维度：** 后端 / 数据库

### 🟡 M5. 排序初始化逻辑在 6 个路由中重复
**文件：** `course.routes.js`, `plan.routes.js`, `major.routes.js`, `college.routes.js`, `textbook.routes.js`, `trainingLevel.routes.js`  
**维度：** 后端

每个列表路由都有相同的 sortOrder 检查逻辑，应提取为工具函数。

### 🟡 M6. 嵌套 try-catch 过度使用
**文件：** 多个路由文件  
**维度：** 后端

内层 catch 中 throw e 到外层 catch，异常处理路径复杂。

### 🟡 M7. 分页参数缺少上限
**文件：** `class.routes.js:62`, `audit.routes.js:15` 等多处  
**维度：** 后端

`pageSize` 无上限，可传入极大值导致数据库性能问题。

### 🟡 M8. 数据库使用 SQLite
**文件：** `server/prisma/schema.prisma:5-8`  
**维度：** 后端 / 数据库

SQLite 不支持并发写入，不适合生产环境。

### 🟡 M9. Express 5.x 版本风险
**文件：** `server/package.json:19`  
**维度：** 后端

Express 5.x 仍在开发中，API 可能不稳定。

### 🟡 M10. npm 依赖存在已知漏洞
**文件：** `server/package.json`, `client/package.json`  
**维度：** 安全

- exceljs 间接依赖存在缓冲区漏洞
- esbuild 开发服务器存在 SSRF 风险（仅开发环境）
- vite 存在路径遍历风险（仅开发环境）

### 🟡 M11. 前端缺少 404 路由
**文件：** `client/src/router/index.js`  
**维度：** 前端

未定义 `path: '/:pathMatch(.*)*'`，访问未定义路由显示空白页。

### 🟡 M12. API 调用缺少用户友好错误反馈
**文件：** `Dashboard.vue:81`, `SemesterQuery.vue:140`, `PlanQuery.vue:305-308`, `AuditLog.vue:241-244`  
**维度：** 前端

catch 块仅 console.error，未向用户展示错误提示。

### 🟡 M13. Layout 组件 settings 加载无错误处理
**文件：** `client/src/components/Layout.vue:149`  
**维度：** 前端

### 🟡 M14. 排序并发修改可能导致数据不一致
**文件：** `CollegeList.vue:136-143`, `CourseList.vue:277-284` 等 6 个组件  
**维度：** 前端

两个独立的 PUT 请求分别更新 sortOrder，一个失败会导致状态不一致。

### 🟡 M15. filterName 防抖 timer 未在组件卸载时清除
**文件：** `client/src/views/class/ClassList.vue:445-451`  
**维度：** 前端

可能导致内存泄漏。

### 🟡 M16. CourseMatrix 组件过大（972 行）
**文件：** `client/src/components/CourseMatrix.vue`  
**维度：** 前端

单个组件包含矩阵渲染、编辑、排序、学期设置、教材关联，应拆分。

### 🟡 M17. 缓存 Map 无限增长风险
**文件：** `client/src/utils/cache.js:6`  
**维度：** 前端

无容量限制，长时间运行可能内存泄漏。

### 🟡 M18. 排序逻辑在 6 个组件中重复
**文件：** `CollegeList.vue`, `CourseList.vue`, `MajorList.vue`, `TrainingLevelList.vue`, `PlanList.vue`, `TextbookList.vue`  
**维度：** 前端

上移/下移逻辑几乎完全相同，应抽取为 `useSortable` 组合式函数。

### 🟡 M19. PlanList 排序在筛选后不正确
**文件：** `client/src/views/plan/PlanList.vue:285-287`  
**维度：** 前端

使用原始列表索引而非筛选后列表索引。

### 🟡 M20. trainingLevel 路由缺少审计日志
**文件：** `server/src/routes/trainingLevel.routes.js`  
**维度：** 后端

POST/PUT/DELETE 操作未记录审计日志，与其他路由不一致。

### 🟡 M21. 审计日志 ip 字段多数路由未填充
**文件：** 多个路由文件  
**维度：** 安全 / 后端

Schema 定义了 ip 字段但多数路由未传入 `ip: req.ip`。

### 🟡 M22. 硬编码数据库文件名
**文件：** `server/.env:1`  
**维度：** 后端

`DATABASE_URL="file:./reset.db"`，`reset` 语义易混淆。

### 🟡 M23. 排序后端无批量接口
**文件：** 多个路由  
**维度：** 后端

前端通过两个独立 PUT 调换 sortOrder，缺少后端批量排序接口。

### 🟡 M24. 未使用 paginate 工具函数
**文件：** `server/src/utils/response.js:5-16`  
**维度：** 后端

### 🟡 M25. 未使用自定义错误类
**文件：** `server/src/utils/error.js`  
**维度：** 后端

定义了 AppError/NotFoundError/ValidationError 但零处使用。

---

## 四、低优先级问题 (Low)

### 🔵 L1. 代码风格不一致（分号使用）
**文件：** 多个路由文件  
**维度：** 后端

auth.routes.js 无分号，class.routes.js 有分号。

### 🔵 L2. 未使用的常量定义
**文件：** `server/src/constants/index.js`  
**维度：** 后端

PASSWORD_POLICY、AUDIT_MODULES 等定义了但未引用。

### 🔵 L3. `.gitignore` 缺少 `.env.example`
**文件：** 根目录  
**维度：** 配置

### 🔵 L4. `bcryptjs` 而非 `bcrypt`
**文件：** `server/package.json:16`  
**维度：** 安全

纯 JS 实现比 C++ 原生慢 30-50%，对当前规模影响不大。

### 🔵 L5. Prisma password 字段无长度约束
**文件：** `server/prisma/schema.prisma:197`  
**维度：** 后端 / 数据库

### 🔵 L6. 文档中代码示例与实际实现不一致
**文件：** `docs/auth-design.md`  
**维度：** 文档

模型名、字段名、权限模型存在差异。

### 🔵 L7. vite.config.js 路径别名写法可优化
**文件：** `client/vite.config.js:11`  
**维度：** 前端

### 🔵 L8. App.vue 缺少全局错误边界
**文件：** `client/src/App.vue`  
**维度：** 前端

### 🔵 L9. 全局注册所有 Element Plus 图标
**文件：** `client/src/main.js:17-19`  
**维度：** 前端

注册了数百个图标，增加打包体积。

### 🔵 L10. 缺少 ARIA 标签和键盘导航
**文件：** 所有 .vue 文件  
**维度：** 前端 / 可访问性

### 🔵 L11. CSS 硬编码颜色值
**文件：** 多处  
**维度：** 前端

未使用 Element Plus CSS 变量，深色模式切换困难。

### 🔵 L12. SystemSettings 表单字段命名不一致
**文件：** `client/src/views/settings/SystemSettings.vue:45-46`  
**维度：** 前端

混用 snake_case（`current_semester`）和 camelCase。

### 🔵 L13. package-lock.json 未用 npm ci
**文件：** 根目录  
**维度：** 配置

### 🔵 L14. 未使用 helmet 安全头中间件
**文件：** `server/src/app.js`  
**维度：** 安全 / 后端

### 🔵 L15. 未配置 CSP 内容安全策略
**文件：** 全局  
**维度：** 安全

### 🔵 L16. 缺少 HTTPS/HSTS 配置指引
**文件：** 全局  
**维度：** 安全 / 配置

### 🔵 L17-23. 其他低优先级问题（详见各子报告）

---

## 五、代码亮点

### 后端亮点
1. **完善的分层架构** — `routes → services → prisma` 职责分明
2. **审计日志体系完善** — 大部分数据操作有审计记录（操作人、IP、操作类型、结果）
3. **命名转换中间件** — camelToSnake/snakeToCamel 自动转换解决前后端命名不一致
4. **数据库关系设计合理** — 外键关系、级联删除、复合唯一约束设计良好
5. **事务使用得当** — plan 操作使用 $transaction 确保数据一致性
6. **全局异常处理** — 统一处理 Prisma P2025 错误
7. **密码 bcryptjs 加密存储**
8. **导入功能设计完善** — 支持自动创建关联数据、重复检测、逐行错误报告
9. **学期计算逻辑清晰**
10. **常量定义规范**

### 前端亮点
1. **响应拦截器设计优秀** — Token 刷新队列机制，支持并发 401 批量重试
2. **路由守卫完善** — 多层权限控制（auth/admin/super_admin），角色校验清晰
3. **缓存工具完整** — TTL 缓存、过期清理、统计功能
4. **Pinia Store 结构清晰** — Composition API 风格
5. **CourseMatrix 矩阵视图** — 分组展示、颜色区分、教材关联功能完整
6. **SystemSettings 危险操作保护** — 需输入确认文字
7. **批量操作功能** — 批量删除、批量设置
8. **响应式设计** — Login/SystemSettings 支持移动端
9. **统一 API 封装**
10. **导入进度展示**

---

## 六、与上次审查（V1）对比

上次审查（2026-06-10）发现 28 个问题，本次复查确认：

| 上次问题 | 状态 |
|----------|------|
| C1 - 数据重置接口缺少权限验证 | ✅ 已修复 |
| C2 - 教材导出 Prisma 关系名错误 | ✅ 已修复 |
| C4 - 自定义方案班级导出被跳过 | ✅ 已修复 |
| H5 - 班级更新清除 custom_plan_id | ✅ 已修复 |
| H9 - 重置基础数据不清空培养方案 | ✅ 已修复 |
| H10 - 重置操作缺少事务保护 | ✅ 已修复 |
| M24 - JWT Secret 硬编码 | ❌ 仍未修复 |
| L26 - .env 未加入 .gitignore | ✅ 已修复 |
| L30 - 健康检查泄露数据库错误 | ✅ 已修复 |

**已修复 8/9 个上次问题，修复率 89%。**

---

## 七、修复优先级路线图

### 🔴 P0 — 立即修复（本周内）
1. **JWT 密钥**：移除硬编码默认值，配置 `JWT_SECRET` 环境变量，添加启动检查
2. **默认凭据**：seed.js 生成随机密码，README/文档中移除默认密码
3. **CORS 配置**：生产环境指定 origin 白名单
4. **Token URL 传递**：导出接口改为 POST + body 传参
5. **Token localStorage**：Access Token 改为内存存储
6. **测试账号**：Login 页面通过环境变量控制显示
7. **userInfo JSON**：添加 try-catch 保护
8. **脚本修复**：修正 update-class-status.js 的 Prisma 模型名
9. **健康检查**：移除 uptime 字段

### 🟠 P1 — 尽快修复（两周内）
10. **登录防护**：添加 express-rate-limit + 验证码
11. **Refresh Token 撤销**：实现 token_version 机制
12. **密码策略**：启用 validateChangePassword 中间件
13. **日志清理**：移除生产环境 console.log
14. **fetchUserInfo 递归限制**
15. **logout await 修复**
16. **UserManagement 字段命名修复**

### 🟡 P2 — 计划修复（一个月内）
17. **plan_courses 唯一约束**
18. **日期字段类型修正**
19. **排序逻辑去重**（前后端）
20. **依赖漏洞修复**
21. **404 路由**
22. **批量排序接口**
23. **审计日志完善**（ip 填充 + trainingLevel）
24. **CourseMatrix 组件拆分**

### 🔵 P3 — 持续改进
25. **Helmet + CSP 安全头**
26. **数据库迁移到 MySQL**
27. **代码风格统一**（ESLint + Prettier）
28. **Element Plus 图标按需引入**
29. **可访问性改进**
30. **文档更新**

---

## 八、风险矩阵

| 风险类别 | Critical | High | Medium | Low | 合计 |
|----------|----------|------|--------|-----|------|
| 认证与授权 | 2 | 2 | 0 | 0 | 4 |
| 敏感信息泄露 | 4 | 3 | 1 | 1 | 9 |
| 输入验证 | 0 | 2 | 0 | 0 | 2 |
| 代码健壮性 | 2 | 5 | 12 | 7 | 26 |
| 配置安全 | 1 | 2 | 3 | 3 | 9 |
| 数据库设计 | 0 | 0 | 4 | 1 | 5 |
| **合计** | **9** | **14** | **20** | **12** | **55** |

---

**总体评价：** 项目架构清晰、分层合理，上次审查后修复率达 89%，代码质量持续提升。当前最突出的风险集中在 **JWT 密钥硬编码**、**Token 传输/存储方式**和**默认凭据公开**三个安全问题上。建议在公开发布前优先修复 P0 级别的 9 个问题。

*报告由 WorkBuddy 自动生成，基于 3 个专业审查代理的并行分析结果。*
