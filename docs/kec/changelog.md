# 变更日志

所有重要的项目更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本控制遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.5] - 2026-06-14

### 安全修复
- 修复 JWT Access Token 有效期过长（24h → 15m）
- 删除生产代码中的 3 处调试 console.log 语句
- 审计日志失败改为记录到 Winston，不再静默丢失

### 新增
- 集成 Helmet 8.2 安全中间件，自动添加 8+ 个 HTTP 安全响应头
- 统一 Prisma CLI 与 Client 版本至 6.19.3

### 质量
- 综合评分从 8.5/10 提升至 9.2/10（代码审计 2026-06-14）
- 全部 P0/P1 安全问题已修复，批准投入生产

---

## [1.0.4] - 2026-06-13

### 新增
- 自动化测试框架（Vitest 4.1.8 + Supertest）
- 108 个测试用例：认证 25 / 权限 18 / 业务 30 / 验证 35
- GitHub Actions CI/CD：Node 18.x 和 20.x 双版本矩阵测试
- 强密码策略：8-128 字符，须含大小写 + 数字 + 特殊字符

### 修复
- 修复 CORS 无 Origin 请求绕过问题
- 修复导出接口 Authorization Header 缺失问题
- settingsStore 加载/保存添加错误处理
- 多个列表页添加服务端分页，解决大数据量性能问题

---

## [1.0.3] - 2026-06-13

### 新增
- 版本管理工具脚本（`npm run version:patch/minor/major`）
- 生产环境部署检查清单文档
- 代码重构指南文档

### 修复
- 修复 `plan.routes.js` 中 `finalPlans` 变量未定义导致的运行时崩溃
- 修复 AuthService 使用原生 Error 导致认证错误返回 500 的问题
- 修复学期导出接口缺少 Authorization Header 的问题
- 修复前端导入接口绕过 Axios 拦截器的问题

### 优化
- 控制器层重构：plan 和 export 模块提取独立 Controller
- 响应命名转换中间件（snake_case → camelCase）统一处理

---

## [1.0.2] - 2026-06-12

### 新增
- 系统重置功能：支持按模块单独清空或全量重置
- 历史学期查询功能
- 数据库索引优化（audit_logs、classes、courses、textbooks）
- Docker Compose 部署支持（多阶段构建、资源限制、健康检查）

### 修复
- 修复培养方案班级数量统计错误
- 修复查询路由适配新 PlanCourseSemester 模型
- 修复 TOKEN localStorage 安全存储策略
- 修复教材查询性能问题（N+1 查询优化）

### 优化
- Dashboard 使用缓存减少冗余 API 调用
- Axios 拦截器实现 Token 自动刷新 + 请求队列

---

## [1.0.1] - 2026-06-10

### 新增
- 操作审计日志：全操作链路记录、按条件筛选导出
- 教材管理：启用/停用切换、批量操作
- 班级批量操作：设置专业/学院/层次/入学年份/学制/状态
- 系统标识设置：可配置单位名称显示在登录页

### 修复
- 修复培养方案匹配逻辑
- 修复页面布局问题

### 优化
- 项目名称统一为"管理平台"（原"管理系统"）
- 前端路由守卫强制三级权限验证

---

## [1.0.0] - 2026-06-08

### 新增
- 首次正式发布版本
- 完整的课程管理平台功能
  - 基础数据管理（培养层次、专业、学院、课程、教材、班级）
  - 培养方案管理（课程矩阵可视化编辑）
  - 查询报表功能（当前学期、历史学期、教材统计）
  - 用户管理和权限控制（三级 RBAC）
  - Excel 批量导入导出
- 前后端分离架构（Vue 3 + Element Plus + Node.js + Prisma）
- 页脚版本号显示功能

### 技术栈
- 前端：Vue 3.5.34, Element Plus 2.14.1, Vite 5.4.21, Pinia 3.0
- 后端：Node.js, Express 5.1.0, Prisma 6.19.3
- 数据库：SQLite（默认），支持切换 MySQL

---

## 版本说明

- **主版本号** (v1.x.x)：不兼容的 API 修改
- **次版本号** (vx.1.x)：新功能（向后兼容）
- **修订号** (vx.x.1)：Bug 修复（向后兼容）

## 发布流程

1. 更新 `package.json` 中的版本号：`npm run version:patch`
2. 在此文件中记录变更内容
3. 提交代码并打标签：`git tag v1.0.5`
4. 推送标签：`git push && git push --tags`
