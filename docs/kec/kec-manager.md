# KEC 课程管理平台

面向职业院校教务管理的轻量级课程编排系统，覆盖从基础数据维护到学期报表导出的完整教务工作流。

---

## 平台定位

KEC 解决的是一个具体问题：**职业院校每学期排课时，教务人员需要在专业、班级、课程、教材之间反复对照，耗时且容易出错。** 平台将这些数据统一管理，自动匹配培养方案，一键导出开课和教材统计报表。

| 角色 | 能做什么 |
|------|----------|
| **超级管理员** | 全部功能 + 系统设置 + 用户管理 + 数据重置 |
| **管理员** | 基础数据 CRUD + 班级/方案管理 + 导入导出 |
| **访客** | 查询报表只读 + 导出 |

> 详细权限设计见：[权限管理设计方案](/kec/auth-design)

---

## 核心工作流

```
基础数据录入 → 班级管理 → 培养方案制定 → 查询报表导出
   (一次性)      (每学年)     (按专业/层次)     (每学期)
```

### 1. 基础数据（搭建框架）

录入**学院 → 专业 → 培养层次 → 课程 → 教材**，形成数据骨架。课程和教材支持 Excel 批量导入。

### 2. 班级管理（每学年）

创建新班级时关联学院/专业/层次，系统**自动推算年级和当前学期**。支持按多条件筛选和批量操作。

### 3. 培养方案（核心）

为每个专业或培养层次制定开课计划——哪些课程在哪些学期开、每周多少课时、用什么教材。课程矩阵视图直观展示学期分布。

### 4. 查询报表（每学期产出）

一键查看当前学期所有班级的开课情况（班级、课程、课时、教材），支持按学院/专业/层次筛选，导出 Excel。

---

## 技术栈

| 层 | 技术 | 版本 | 说明 |
|----|------|------|------|
| 前端 | Vue 3 + Element Plus + Vite | Vue 3.5 / EP 2.14 / Vite 5.4 | Composition API，中文组件库 |
| 后端 | Express 5 + Prisma ORM | Express 5.1 / Prisma 6.x | RESTful API，JWT 认证 |
| 数据库 | SQLite（主）/ MySQL（可选） | Prisma SQLite 方案 | 开发开箱即用，生产可切换 |
| 进程管理 | PM2 | — | 守护进程 + 日志管理 |
| 部署 | 1Panel + Nginx | — | 反向代理 + HTTPS |

---

## 文档导航

### 入门
- [KEC 说明文档](/kec/kec-readme) — 完整 README，含技术栈和项目结构说明
- [登录指南](/kec/login-guide) — 默认管理员账号与常见登录问题
- [初始化流程](/kec/init-flow) — 首次部署后的数据导入顺序

### 部署
- [1Panel 部署指南 (PM2)](/kec/deploy-1panel) — PM2 + Nginx 反向代理方式
- [1Panel Docker 部署](/kec/1panel-docker-deploy) — Docker Compose 容器化方式
- [生产环境部署指南](/kec/DEPLOYMENT_GUIDE) — 一键部署和更新部署完整流程
- [更新操作指南](/kec/update-operations-guide) — SSH 远程部署、本地部署、手动更新全方案
- [故障排查指南](/kec/troubleshooting) — 常见错误诊断与修复

### 设计
- [权限管理设计方案](/kec/auth-design) — 三级权限模型 + JWT 双令牌认证流程

### 开发
- [代码重构指南](/kec/refactoring-guide) — 重构原则、架构演进与最佳实践
- [版本管理指南](/kec/version-management) — 自动化版本号管理与语义化版本

### 技术专题
- [学期计算逻辑](/kec/semester-calculation) — 年级推算和学期序号的算法
- [班级状态修复](/kec/class-status-fix) — 毕业/在读状态的判定与修复
- [子系统分析](/kec/subsystem-analysis) — 各模块的解耦设计
- [系统重置功能](/kec/system-reset-feature) — 数据清空和重置策略
- [教材查询性能优化](/kec/textbook-query-optimization) — 查询性能调优
- [种子数据使用指南](/kec/seed-usage) — 数据库初始化与安全重置

### 质量
- [最新代码审计报告](/kec/code-audit-latest) — 综合评分 9.2/10
- [项目合规检查报告](/kec/project-compliance-check) — 全面代码审查与配置验证
- [测试体系与报告](/kec/testing) — 单元测试 108 用例 + 功能测试 60 用例

### 历史
- [重构总结](/kec/refactoring-summary) — 14 个模块 Controller 层提取完成
- [前端修复总结](/kec/frontend-fix-summary) — Critical + High 安全修复
- [验证中间件修复总结](/kec/validation-fix-summary) — P0+P1 安全加固
- [变更日志](/kec/changelog) — 版本更新记录（当前 v1.5.19）

---

## 项目地址

- **Gitee**: [gitee.com/shub77/kec-manager](https://gitee.com/shub77/kec-manager)
- **在线体验**: 部署后访问 `https://your-domain.com`（默认账号 `admin` / `admin@123456`，首次登录请修改密码）

---

*KEC = Knowledge · Education · Curriculum*
