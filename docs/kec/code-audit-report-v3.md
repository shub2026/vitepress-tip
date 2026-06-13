# KEC 课程管理平台 — 全面检查分析报告（V3）

> 生成时间：2026-06-11 23:52 CST | 仓库：github.com/shub2026/kec-manager | 分支：main | 最新提交：72023ab
> 代码总量：15,114 行 | 提交次数：83 次 | 数据模型：12 个 | 路由模块：14 个

---

## 一、项目概览

| 维度 | 详情 |
|------|------|
| **项目名称** | KEC 课程管理平台 (course-management) |
| **定位** | 面向职业技术院校/技工学校的轻量级课程管理平台 |
| **架构** | 前后端分离：Vue 3 + Express 5 + Prisma 6 + SQLite/MySQL |
| **代码规模** | 前端 ~6,200 行（16 个页面 + 3 个组件），后端 ~8,900 行（28 个源文件） |
| **功能模块** | 基础数据、班级管理、培养方案、查询报表、导入导出、系统管理 |
| **权限体系** | 三级角色：super_admin / admin / viewer |
| **代码质量** | 整体良好，架构清晰；存在若干安全和一致性问题需修复 |

---

## 二、技术栈评估

| 层级 | 技术 | 版本 | 评价 |
|------|------|------|------|
| 前端框架 | Vue 3 (Composition API) | 3.5.34 | ✅ 一致使用 `<script setup>`，Composition API 写法规范 |
| UI 组件库 | Element Plus | 2.14.1 | ✅ 企业级组件，中文国际化 |
| 构建工具 | Vite | 5.4.21 | ✅ 极速 HMR，配置简洁 |
| 状态管理 | Pinia | 3.0.4 | ✅ 官方推荐，auth/settings 两个 store 职责清晰 |
| HTTP 客户端 | Axios | 1.17.0 | ✅ Token 自动刷新队列，拦截器完善 |
| 后端框架 | Express | 5.1.0 | ✅ ESM 模块化，14 个路由模块 |
| ORM | Prisma | 6.19.3 | ✅ 类型安全，支持 SQLite/MySQL 切换 |
| 认证 | JWT | 9.0.3 | ⚠️ 双 Token 机制但共享同一密钥，建议分离 |
| 密码加密 | bcryptjs | 3.0.3 | ⚠️ 迭代次数 10，推荐 ≥12 |
| Excel | ExcelJS | 4.4.0 | ✅ 纯 JS 实现，无系统依赖 |
| 日志 | Winston | 3.19.0 | ⚠️ 已配置但全项目仍用 console.log，虚设 |

---

## 三、安全问题分析

### 🔴 严重（4 项）

| 编号 | 问题 | 位置 | 影响 |
|------|------|------|------|
| **C1** | 登录接口无速率限制 | `auth.routes.js:9` | 可被暴力破解密码，无任何防护 |
| **C2** | Token 支持 URL 查询参数传递 | `auth.middleware.js:12-13` | Token 会被记录在服务器日志、浏览器历史、Referer 头中 |
| **C3** | 班级写操作缺少角色权限校验 | `class.routes.js` POST/PUT/DELETE | viewer 角色可创建/修改/删除班级 |
| **C4** | 培养方案写操作缺少角色权限校验 | `plan.routes.js` 部分 POST/PUT/DELETE | viewer 角色可修改培养方案课程/学期/教材 |

> **说明**：plan.routes.js 中课程/学期/教材的写操作已添加 `roleMiddleware`，但方案本身的 POST（创建）和 PUT（更新）缺少角色校验。

### 🟠 高危（7 项）

| 编号 | 问题 | 位置 | 影响 |
|------|------|------|------|
| **H1** | 错误处理器泄露内部错误 | `error.js:5-9` | 生产环境暴露 err.message 可能含数据库细节 |
| **H2** | 修改密码接口未应用验证中间件 | `auth.routes.js:78-95` | 未使用已定义的 `validateChangePassword`，允许弱密码 |
| **H3** | 创建用户时不校验密码强度 | `user.routes.js:53` | 管理员可创建极弱密码用户 |
| **H4** | 系统设置 PUT 可注入任意 Key | `settings.routes.js:35-46` | 遍历 `req.body` 无白名单，可注入非法设置项 |
| **H5** | 批量导入非事务性操作 | `import.routes.js` | 部分成功部分失败，无回滚机制 |
| **H6** | 导入数据未经清洗直接存储 | `import.routes.js:221` | 潜在存储型 XSS（虽然前端 Element Plus 默认转义） |
| **H7** | 直接修改 Prisma 查询结果对象 | `class.routes.js:260-267` | `cls.status = ...` 直接修改查询返回对象，代码异味 |

### 🟡 中危（10 项）

| 编号 | 问题 |
|------|------|
| **M1** | 路由错误处理模式不一致：部分用 `try/catch + next(e)`，部分用嵌套 `try/catch + fail()`，部分直接 `throw` |
| **M2** | 审计日志记录方式不一致：`auth.routes.js` 直接 `prisma.audit_logs.create()`，其他路由用 `createAuditLog()` |
| **M3** | 学期参数解析逻辑重复 5 处（query.routes.js ×2, export.routes.js ×3），未抽取公共函数 |
| **M4** | 方案匹配逻辑 `findBestMatchPlan` 在 query.routes.js 和 export.routes.js 各实现一次 |
| **M5** | GET 请求中执行写操作：各路由 GET `/` 中自动修复 `sortOrder` 并写回数据库 |
| **M6** | `getActiveClassFilter` 无 duration 空值兜底：若无班级数据则 `durationValues` 为空，返回 `{ OR: [] }` 可能匹配不到任何记录 |
| **M7** | 生产代码大量 `console.log` 调试输出（import.routes.js 尤甚） |
| **M8** | `update-class-status.js` 脚本完全不可用：使用 `prisma.class.findMany()` 但模型名为 `classes`，且字段用 camelCase（应为 snake_case） |
| **M9** | Access Token 和 Refresh Token 共用同一 `jwtSecret`，安全风险 |
| **M10** | 系统设置 GET 接口执行写操作（创建缺失设置项） |

### 🔵 低危（10 项）

| 编号 | 问题 |
|------|------|
| **L1** | 自定义错误类（AppError/NotFoundError 等）已定义但全项目从未使用 |
| **L2** | 验证中间件（validateClass/validateCourse 等）已定义但路由未引用 |
| **L3** | `naming.js` 中 `shallowSnakeToCamel`/`shallowCamelToSnake` 未被任何代码引用 |
| **L4** | `constants/index.js` 中 `CLASS_STATUS`/`PASSWORD_POLICY` 等常量未被路由引用 |
| **L5** | `paginate()` 响应工具函数已定义但从未使用 |
| **L6** | bcrypt 迭代次数 10（推荐 12+） |
| **L7** | `.gitignore` 缺少 `*.log` 和 `logs/` 排除 |
| **L8** | `seed.js` 为破坏性操作（先清空所有数据再创建），无确认提示 |
| **L9** | 关闭时未等待活跃连接完成（`server.close()` 无回调） |
| **L10** | 前端 `cache.js` 无大小限制，长期运行可能内存泄漏 |

---

## 四、前端代码分析

### 🔴 严重（1 项）

| 编号 | 问题 | 位置 |
|------|------|------|
| **FC1** | Token 通过 URL 查询参数暴露 | 导出功能使用 `window.open` 携带 Token |

### 🟠 高危（4 项）

| 编号 | 问题 |
|------|------|
| **FH1** | 删除操作部分缺少组件级错误处理 |
| **FH2** | 批量操作使用逐条 API 调用（班级批量设置），无批量接口 |
| **FH3** | Token 刷新队列在 `processQueue` 后未正确传递新 Token 给重试请求 |
| **FH4** | 开发模式暴露测试账号密码（`admin/admin@123456`） |

### 🟡 中危（6 项）

| 编号 | 问题 |
|------|------|
| **FM1** | CourseMatrix 排序交换可能产生竞态（并行 `Promise.all` 两个更新） |
| **FM2** | `sortOrder`/`sort_order` 命名在前后端混用（中间件转换存在，但代码可读性差） |
| **FM3** | 导出功能使用 `window.open` 绕过 Axios 拦截器，Token 处理不一致 |
| **FM4** | 前端 Dashboard 统计逻辑：获取全部数据仅取 length，应使用 count 接口 |
| **FM5** | 设置 store 无格式校验，学期字符串解析可能出错 |
| **FM6** | 历史查询页和当前查询页存在大量重复代码 |

### 🔵 低危（6 项）

| 编号 | 问题 |
|------|------|
| **FL1** | Layout 中 `passwordFormRef` 和 `changingPassword` 已声明但未使用 |
| **FL2** | 无国际化支持（硬编码中文） |
| **FL3** | 无障碍缺失（无 aria 标签） |
| **FL4** | 版权信息含个人邮箱 `admin@example.com` |
| **FL5** | CSS 未使用 CSS 变量/预处理器，样式分散 |
| **FL6** | `App.vue` 仅含 `<router-view />`，template 可直接写在 main.js 中 |

---

## 五、数据模型分析

### 模型关系图

```
colleges ──1:N──→ classes
colleges ──1:N──→ training_plans

majors ──1:N──→ classes
majors ──1:N──→ training_plans

training_levels ──1:N──→ classes
training_levels ──1:N──→ training_plans

training_plans ──1:N──→ plan_courses ──1:N──→ plan_course_semesters ──1:N──→ plan_textbooks
                                    ↕                              ↕
                                courses                        textbooks

training_plans ←──1:N── classes (via custom_plan_id，自定义方案关联)
```

### ⚠️ Schema 设计问题

| 编号 | 问题 | 影响 |
|------|------|------|
| **S1** | `plan_textbooks` 缺少 `updated_at` 字段（已注释掉） | 无法追踪教材关联的最后修改时间 |
| **S2** | `system_settings` 缺少 `created_at`/`updated_at` 字段（已注释掉） | 无法追踪设置变更时间 |
| **S3** | `textbooks.publish_date` 类型为 String 而非 DateTime | 无法进行日期范围查询 |
| **S4** | `classes.status` 字段冗余 | 状态由 `enrollment_year` + `duration_years` + 当前学期动态计算，数据库存储可能过期 |
| **S5** | Prisma 模型名使用 snake_case 复数（`users`, `audit_logs`） | 不符合 Prisma 惯例（通常 PascalCase 单数），且与文档不一致 |

---

## 六、代码架构评价

### ✅ 优点

1. **前后端分离架构清晰**：14 个路由模块、9 个前端 API 模块，职责分明
2. **命名转换中间件设计优雅**：`snake_case` ↔ `camelCase` 自动转换，解耦前后端命名约定
3. **Token 刷新队列机制**：`failedQueue` 模式防止并发请求重复刷新
4. **Prisma ORM 使用得当**：有效防止 SQL 注入，支持 SQLite/MySQL 无缝切换
5. **课程矩阵组件设计良好**：`CourseMatrix.vue` 作为可复用组件，props/emits/expose 完整
6. **数据重置功能设计周全**：三级级联策略 + 按 Module 单独清空，防止误操作
7. **README 文档详尽**：覆盖快速开始、API 文档、部署指南、FAQ，堪称模板级
8. **JWT 密钥启动校验**：缺失时立即报错，防止不安全运行
9. **班级状态动态计算**：基于学期配置自动推算在读/已毕业状态，逻辑严谨
10. **培养方案匹配优先级**：自定义方案 > 按专业 > 按层次，规则清晰

### ⚠️ 需改进

1. **权限校验不完整**：class 和 plan 的写操作缺少角色中间件（**最紧迫**）
2. **大量死代码**：错误类、验证器、常量、审计中间件等已定义但未集成到路由
3. **日志系统虚设**：Winston 已配置但全项目仍用 `console.log`
4. **导入操作非事务性**：大数据量导入缺乏原子性保证
5. **重复代码多**：学期解析、方案匹配、错误处理模式在多个文件中重复实现
6. **`update-class-status.js` 脚本完全不可用**：模型名和字段名全部错误

---

## 七、修复优先级建议

### 🔥 第一优先级（立即修复，约 2h）

| 序号 | 问题 | 工时 |
|------|------|------|
| 1 | 为 `class.routes.js` POST/PUT/DELETE 添加 `roleMiddleware('admin', 'super_admin')` | 0.5h |
| 2 | 为 `plan.routes.js` 的方案创建/更新添加 `roleMiddleware` | 0.3h |
| 3 | 安装 `express-rate-limit` 为登录接口添加速率限制 | 0.5h |
| 4 | 移除 Token URL 查询参数支持 | 0.3h |
| 5 | 修复 `update-class-status.js` 的模型名和字段名 | 0.2h |

### ⚡ 第二优先级（本周内，约 5h）

| 序号 | 问题 | 工时 |
|------|------|------|
| 6 | 错误处理器区分生产/开发环境 | 0.5h |
| 7 | 修改密码接口应用 `validateChangePassword` 中间件 | 0.3h |
| 8 | 创建用户时校验密码强度 | 0.3h |
| 9 | 系统设置 PUT 添加 Key 白名单校验 | 0.5h |
| 10 | 导入操作包装为事务（$transaction） | 2h |
| 11 | 移除生产代码中调试 console.log | 1h |
| 12 | 前端导出改用 fetch + blob（替代 window.open 暴露 Token） | 0.5h |

### 🔄 第三优先级（迭代优化，约 10h）

| 序号 | 问题 | 工时 |
|------|------|------|
| 13 | 统一错误处理模式（全部使用 next(e) + errorHandler） | 2h |
| 14 | 整合自定义错误类到路由 | 2h |
| 15 | 启用 Winston 日志替换 console | 2h |
| 16 | 提取重复逻辑（学期解析、方案匹配）为共享工具函数 | 2h |
| 17 | 统一审计日志记录方式（全部用 createAuditLog） | 1h |
| 18 | Access/Refresh Token 使用不同密钥 | 1h |

---

## 八、统计数据总览

| 维度 | 🔴 严重 | 🟠 高危 | 🟡 中危 | 🔵 低危 | 合计 |
|------|---------|---------|---------|---------|------|
| 后端安全 | 4 | 7 | 10 | 10 | 31 |
| 前端代码 | 1 | 4 | 6 | 6 | 17 |
| 数据模型 | 0 | 0 | 5 | 0 | 5 |
| **总计** | **5** | **11** | **21** | **16** | **53** |

---

## 九、功能模块完整性检查

| 功能模块 | 后端 API | 前端页面 | 权限控制 | 审计日志 | 评价 |
|----------|---------|---------|---------|---------|------|
| 认证（登录/登出/刷新/改密） | ✅ 5 个端点 | ✅ Login.vue | ✅ | ✅ | 完整 |
| 用户管理 | ✅ 5 个端点 | ✅ UserManagement.vue | ✅ | ✅ | 完整 |
| 学院管理 | ✅ 4 个端点 | ✅ CollegeList.vue | ✅ | ✅ | 完整 |
| 专业管理 | ✅ 4 个端点 | ✅ MajorList.vue | ✅ | ✅ | 完整 |
| 培养层次 | ✅ 4 个端点 | ✅ TrainingLevelList.vue | ✅ | ⚠️ 缺少 | 基本完整 |
| 课程管理 | ✅ 4 个端点 | ✅ CourseList.vue | ✅ | ✅ | 完整 |
| 教材管理 | ✅ 5 个端点 | ✅ TextbookList.vue | ✅ | ✅ | 完整 |
| 班级管理 | ✅ 4 个端点 + 统计 | ✅ ClassList.vue | ⚠️ 写操作缺 roleMiddleware | ✅ | 需修复 |
| 培养方案 | ✅ 14 个端点 | ✅ PlanList + PlanDetail | ⚠️ 部分缺 roleMiddleware | ✅ | 需修复 |
| 当前开课查询 | ✅ | ✅ SemesterQuery.vue | ✅ | N/A | 完整 |
| 历史开课查询 | ✅ | ✅ HistoricalSemesterQuery.vue | ✅ | N/A | 完整 |
| 培养方案查询 | ✅ | ✅ PlanQuery.vue | ✅ | N/A | 完整 |
| 教材使用查询 | ✅ 2 个端点 | ✅ TextbookQuery.vue | ✅ | N/A | 完整 |
| 历史教材查询 | ✅ | ✅ HistoricalTextbookQuery.vue | ✅ | N/A | 完整 |
| Excel 导入 | ✅ 3 个端点 | ✅ | ✅ | ✅ | 功能完整，缺事务 |
| Excel 导出 | ✅ 6 个端点 | ✅ | ✅ | ✅ | 完整 |
| 系统设置 | ✅ 12 个端点 | ✅ SystemSettings.vue | ✅ | ⚠️ 重置缺日志 | 基本完整 |
| 操作日志 | ✅ 1 个端点 | ✅ AuditLog.vue | ✅ | N/A | 完整 |
| Dashboard | ✅ 统计 API | ✅ Dashboard.vue | ✅ | N/A | 完整 |

---

## 十、结论

KEC 课程管理平台是一个**架构设计良好、功能完整**的教学管理系统。经过 83 次提交和多轮 Bug 修复迭代，整体代码质量处于良好水平。

### 当前最紧迫的问题

1. **4 项严重安全漏洞**：权限校验缺失（C3/C4）、登录无速率限制（C1）、Token 泄露风险（C2）
2. **`update-class-status.js` 脚本致命 Bug**：模型名和字段名全部错误，完全不可执行

这些问题修复成本低（合计约 2h），但安全影响面广，**建议立即处理**。

### 中期改进方向

1. **消除死代码**：验证器、错误类、常量等基础设施已定义但未集成，建议逐步接入或移除
2. **启用 Winston 日志**：替换散落的 `console.log`，实现结构化日志
3. **抽取公共逻辑**：学期解析、方案匹配、错误处理模式存在大量重复
4. **导入事务化**：批量导入操作包装为 Prisma `$transaction`

### 长期演进建议

1. **Schema 重构**：考虑将 Prisma 模型名改为 PascalCase 单数（Prisma 惯例）
2. **API 版本化**：添加 `/api/v1/` 前缀，为后续 API 变更留出空间
3. **前端状态缓存优化**：当前内存缓存无上限，需引入 LRU 策略
4. **测试覆盖**：当前零测试覆盖，建议至少为权限校验和核心业务逻辑添加单元测试

---

*报告基于 main 分支最新代码（72023ab）全量审查生成，覆盖 28 个后端源文件、16 个前端页面、12 个数据模型。*
