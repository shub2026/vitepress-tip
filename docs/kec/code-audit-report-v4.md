# KEC 课程管理平台 - 全面检查分析报告

**报告版本**: v3  
**检查日期**: 2026年06月12日  
**项目路径**: `/workspace/kec-manager-audit-20260612`  
**代码版本**: commit `3f4f755` (main)  
**检查范围**: 后端 (Express + Prisma) / 前端 (Vue 3 + Element Plus) / 数据库 / 文档一致性

---

## 执行摘要

本次对 kec-manager 项目进行了全面审计，覆盖**后端安全**、**前端质量**、**数据库设计**、**功能完整性**和**文档一致性**五个维度。项目整体架构清晰、功能完整，大部分已知问题已在之前版本中修复。本次审计新发现 **11个严重问题、12个高危问题、26个中危问题、18个低危问题**。

---

## 一、严重问题 (11项)

| # | 问题 | 位置 | 影响 |
|---|------|------|------|
| **C1** | **JWT 无吊销/黑名单机制** | `server/src/services/auth.service.js:83-104` | Token泄露后7天内无法使其失效 |
| **C2** | **登出接口不使Token失效** | `server/src/routes/auth.routes.js:67-83` | 登出后Token仍可用，安全风险极高 |
| **C3** | **`plan.routes.js` 中 `finalPlans` 变量未定义** | `server/src/routes/plan.routes.js:51,64` | **运行时崩溃**，培养方案列表接口完全不可用 |
| **C4** | **JWT派生密钥 - 密钥隔离形同虚设** | `server/src/config/auth.config.js:31-32` | 获取JWT_SECRET即可推算Refresh/Download密钥 |
| **C5** | **AuthService全部使用原生Error** | `server/src/services/auth.service.js` 多处 | 认证错误被当作500返回，前端无法区分错误类型 |
| **C6** | **导入功能事务不完整** | `server/src/routes/import.routes.js:86-301` | 事务回滚后自动创建的基础数据无法回滚 |
| **C7** | **导入循环内N+1查询** | `server/src/routes/import.routes.js:219,401,551` | 1000行数据=1000次额外DB查询，性能极差 |
| **C8** | **Token存储在localStorage** | `client/src/stores/auth.js:7-8,42-43` | XSS攻击可直接窃取Token和RefreshToken |
| **C9** | **用户角色信息存储在localStorage** | `client/src/stores/auth.js:13-14,44` | 攻击者可篡改角色字段尝试提权 |
| **C10** | **学期导出接口缺少Authorization Header** | `client/src/views/query/SemesterQuery.vue:155-160`、`HistoricalSemesterQuery.vue:209-214` | 导出请求可能失败或未授权即可导出 |
| **C11** | **README数据库模型表与实际Schema严重不一致** | `README.md` 数据库模型表 | 9处字段描述错误，误导开发者 |

---

## 二、高危问题 (12项)

| # | 问题 | 位置 | 影响 |
|---|------|------|------|
| **H1** | JWT Access Token 有效期过长(24h) | `server/src/config/auth.config.js:44` | Token泄露后24小时利用窗口 |
| **H2** | CORS允许无Origin请求绕过 | `server/src/app.js:31-32` | 绕过CORS白名单检查 |
| **H3** | 用户创建时无密码强度验证 | `server/src/routes/user.routes.js:51-99` | 管理员可创建弱密码账户（如`1`） |
| **H4** | 大量路由未使用express-validator验证中间件 | 8个路由文件 | 输入缺少系统校验，增加注入风险 |
| **H5** | ID参数未验证（parseInt未防护NaN） | 所有 `/:id` 路由 | 可能导致意外行为或查询错误 |
| **H6** | .env.example 中硬编码弱密钥占位符 | `server/.env.example:9` | 可能被直接复制使用 |
| **H7** | 导出/下载接口绕过axios拦截器 | 5个前端文件 | Token刷新机制失效，401无法自动恢复 |
| **H8** | 导入接口使用原生fetch/XHR绕过拦截器 | 3个前端文件 | 同上，且XHR实现无Token刷新 |
| **H9** | settingsStore load()/save() 无错误处理 | `client/src/stores/settings.js:23-39` | 设置加载/保存失败导致未捕获异常 |
| **H10** | 多个列表页全量加载数据无分页 | 6个前端列表组件 | 数据量大时性能崩溃、内存溢出 |
| **H11** | class loadMeta() 无错误处理 | `client/src/views/class/ClassList.vue:450-456` | 任一接口失败导致元数据全部不可用 |
| **H12** | 缺少CSRF防护 | 全局 | 无CSRF Token，关键操作缺乏防护 |

---

## 三、中危问题 (26项)

### 3.1 后端 (14项)

| # | 问题 | 位置 |
|---|------|------|
| M1 | 错误消息中泄露内部错误详情 | `server/src/routes/import.routes.js:60` 及多处 |
| M2 | XSS清洗仅在导入功能中使用，其他路由缺失 | `server/src/routes/import.routes.js:14-19` |
| M3 | 审计日志中记录完整req.body可能含敏感信息 | `server/src/routes/import.routes.js:53` 及多处 |
| M4 | admin创建用户角色验证逻辑存在边界问题 | `server/src/routes/user.routes.js:60-68` |
| M5 | 嵌套try-catch导致错误处理不一致 | `server/src/routes/class.routes.js:345-412` 及7个文件 |
| M6 | 设置更新接口非事务性（循环upsert） | `server/src/routes/settings.routes.js:39-80` |
| M7 | 文件上传仅检查扩展名未验证实际内容 | `server/src/routes/import.routes.js:32-42` |
| M8 | 状态更新接口is_active未验证类型 | `server/src/routes/user.routes.js:184-226` |
| M9 | winston审计日志文件始终为空 | `server/src/config/logger.js:53-58` |
| M10 | 系统重置会清空审计日志 | `server/src/routes/settings.routes.js:327-340` |
| M11 | query.routes.js 中重复定义isClassMatchPlan函数 | `server/src/routes/query.routes.js:329-340` |
| M12 | 大量重复的审计日志代码 | 8个路由文件 |
| M13 | Prisma错误日志生产环境不输出 | `server/src/lib/prisma.js:12-20` |
| M14 | user.routes.js 中引用未定义变量username | `server/src/routes/user.routes.js:169,217` |

### 3.2 前端 (10项)

| # | 问题 | 位置 |
|---|------|------|
| M15 | 路由守卫Token刷新存在竞争条件 | `client/src/utils/request.js:57-84` |
| M16 | el-upload action属性暴露API路径 | 3个Vue文件 |
| M17 | 大量重复的排序/上下移代码（7个文件） | 7个List组件 |
| M18 | 大量重复的导出/下载代码（7个文件） | 7个Vue文件 |
| M19 | 多处load函数缺少catch错误提示 | 5个列表组件 |
| M20 | auth store initAuth时序问题 | `client/src/main.js:22-24` |
| M21 | CourseMatrix组件过大（970+行） | `client/src/components/CourseMatrix.vue` |
| M22 | PlanQuery与CourseMatrix大量重复逻辑 | `client/src/views/query/PlanQuery.vue` |
| M23 | 密码修改成功后连续两次弹提示 | `client/src/components/ChangePasswordDialog.vue:131,137` |
| M24 | 登录成功后双重导航 | `client/src/stores/auth.js:46` + `client/src/views/Login.vue:134` |

### 3.3 数据库 (2项)

| # | 问题 | 位置 |
|---|------|------|
| M25 | courses.name 和 majors.name 缺少@unique约束 | `server/prisma/schema.prisma:68,83` |
| M26 | training_plans缺少major_id/training_level_id索引 | `server/prisma/schema.prisma` |

---

## 四、低危问题 (18项)

<details>
<summary>展开查看低危问题详情</summary>

| # | 问题 | 位置 |
|---|------|------|
| L1 | 下载Token通过URL Query参数传递 | `server/src/middleware/auth.middleware.js:12` |
| L2 | 密码修改后旧Token仍可用 | `server/src/services/auth.service.js:153-193` |
| L3 | 错误响应格式不统一 | `fail()` vs `errorHandler` |
| L4 | BCRYPT_ROUNDS无上限校验 | `server/src/config/auth.config.js:28` |
| L5 | SQLite数据库文件存储在项目目录内 | `server/.env.example:2` |
| L6 | winston日志目录硬编码 | `server/src/config/logger.js:9` |
| L7 | 未配置Helmet安全头 | `server/src/app.js` |
| L8 | update-class-status.js不处理离校状态 | `server/scripts/update-class-status.js:40` |
| L9 | college.routes.js PUT接口未过滤undefined | `server/src/routes/college.routes.js:61-69` |
| L10 | 开发环境显示测试账号密码 | `client/src/views/Login.vue:65-78` |
| L11 | 多个表单对话框缺少完整验证规则 | 5个Vue文件 |
| L12 | UserManagement.vue字段命名不一致(snake_case/camelCase混用) | `client/src/views/system/UserManagement.vue` |
| L13 | 全量注册Element Plus图标增加bundle体积 | `client/src/main.js:17-19` |
| L14 | Login密码最短6位 vs 修改密码最短8位不一致 | `Login.vue:117` vs `ChangePasswordDialog.vue:84` |
| L15 | SystemSettings.vue硬编码开发者邮箱 | `client/src/views/settings/SystemSettings.vue:464-466` |
| L16 | classes.status字段冗余（动态计算） | `server/prisma/schema.prisma:38` |
| L17 | textbooks.publish_date为String而非DateTime | `server/prisma/schema.prisma:157` |
| L18 | 前端缺少auth/user/settings/import/export的API封装文件 | `client/src/api/` 目录 |

</details>

---

## 五、功能完整性评估

| 功能模块 | 后端实现 | 前端实现 | 评估 |
|----------|---------|---------|------|
| 基础数据管理（学院/专业/培养层次） | 完整 | 完整 | ✅ 完整 |
| 班级管理（CRUD/批量导入/年级推算/毕业标记） | 完整 | 完整 | ✅ 完整 |
| 课程库（公共基础课/专业课/周课时） | 完整 | 完整 | ✅ 完整 |
| 教材管理（CRUD/启用停用/课程关联） | 完整 | 完整 | ✅ 完整 |
| 培养方案（多版本/课程矩阵/特殊方案） | 完整 | 完整 | ✅ 完整 |
| 查询统计（开课/教材/审计/培养方案） | 完整 | 完整 | ✅ 完整 |
| 数据导入导出（模板/批量导入/导出） | 完整 | 完整 | ✅ 完整 |
| 用户权限（3种角色/JWT双令牌） | 完整 | 完整 | ✅ 完整 |
| 系统设置（单位名称/学期/品牌化/重置） | 完整 | 完整 | ✅ 完整 |
| **审计日志导出** | **缺失** | **缺失** | ❌ 缺失 |
| **README数据库模型表** | - | - | ❌ 严重不一致 |

---

## 六、数据库Schema评估

### 设计亮点
- 外键与级联策略设计合理（12个外键关系，CASCADE/RESTRICT/SET NULL使用恰当）
- 索引覆盖充分（18个索引，覆盖高频查询场景）
- 支持SQLite和MySQL双数据库

### 需改进项
- `training_plans` 缺少 `major_id`、`training_level_id` 索引（高频查询）
- `plan_textbooks` 缺少 `textbook_id` 索引（教材统计查询）
- `courses.name` 和 `majors.name` 缺少 `@unique` 约束

---

## 七、与v2报告对比

| 指标 | v2报告 | v3报告 | 变化 |
|------|--------|--------|------|
| 严重问题 | 未明确分级 | 11项 | 首次系统分级 |
| 高危问题 | 未明确分级 | 12项 | 首次系统分级 |
| 中危问题 | 未明确分级 | 26项 | 首次系统分级 |
| 低危问题 | 未明确分级 | 18项 | 首次系统分级 |
| 已修复问题 | 7项 | 已确认 | 新增C3(运行时崩溃)、H4/H5等 |
| 功能完整性 | 未全面检查 | 10/11模块完整 | 新发现审计导出缺失 |

---

## 八、优先修复建议

### 第一优先级（立即修复 - 影响系统可用性）

| 优先级 | 问题 | 修复方案 |
|--------|------|----------|
| 🔴 P0 | **C3: plan.routes.js finalPlans未定义** | 将第51行和64行的 `finalPlans` 改为 `plans` |
| 🔴 P0 | **C10: 学期导出缺少Authorization Header** | 添加Authorization Header或改用封装的request实例 |

### 第二优先级（尽快修复 - 安全风险）

| 优先级 | 问题 | 修复方案 |
|--------|------|----------|
| 🟠 P1 | **C1/C2: JWT无吊销机制** | 实现Token黑名单（Redis）或使用数据库记录失效Token |
| 🟠 P1 | **C4: JWT派生密钥** | 强制要求独立配置 JWT_REFRESH_SECRET 和 JWT_DOWNLOAD_SECRET |
| 🟠 P1 | **C8: Token存储在localStorage** | 改用httpOnly Cookie存储RefreshToken，内存存储AccessToken |
| 🟠 P1 | **C5: AuthService使用原生Error** | 替换为自定义 AuthenticationError 类 |

### 第三优先级（计划修复 - 代码质量）

| 优先级 | 问题 | 修复方案 |
|--------|------|----------|
| 🟡 P2 | **C6/C7: 导入功能事务和N+1** | 大事务包裹 + 批量预加载现有数据 |
| 🟡 P2 | **H3/H4/H5: 输入验证缺失** | 路由中启用已定义的express-validator中间件 |
| 🟡 P2 | **H10: 列表页无分页** | 实现服务端分页 |
| 🟡 P2 | **H7/H8: 绕过axios拦截器** | 统一使用封装的request实例，为文件下载添加blob处理 |

### 第四优先级（持续改进 - 文档与规范）

| 优先级 | 问题 | 修复方案 |
|--------|------|----------|
| 🟢 P3 | **C11: README数据库模型表不一致** | 根据实际schema更新README |
| 🟢 P3 | **M17/M18: 大量重复代码** | 提取公共composable和工具函数 |
| 🟢 P3 | **M21/M22: 组件过大/重复** | 拆分CourseMatrix，提取共享逻辑 |

---

## 九、统计数据

| 维度 | 数值 |
|------|------|
| 后端路由文件 | 14个 |
| 前端API封装文件 | 9个 |
| 前端页面组件 | 18个 |
| 前端公共组件 | 3个 |
| 数据库模型 | 12个 |
| 数据库索引 | 18个 |
| 外键关系 | 12个 |
| 功能模块 | 11个（10个完整，1个部分缺失） |
| 总问题数 | 67项 |
| 代码总行数（估算） | ~15,000行 |

---

**报告生成时间**: 2026-06-12 22:06 GMT+8  
**审计工具**: 人工 + AI辅助代码审查
