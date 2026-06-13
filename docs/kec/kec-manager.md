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

### 入门必读
- [KEC 说明文档](/kec/kec-readme) — 完整的 README，含技术栈和项目结构说明
- [登录指南](/kec/login-guide) — 默认管理员账号与常见登录问题
- [1Panel 部署指南 (PM2)](/kec/deploy-1panel) — PM2 + Nginx 反向代理方式
- [1Panel Docker 部署](/kec/1panel-docker-deploy) — Docker Compose 容器化方式
- [初始化流程](/kec/init-flow) — 首次部署后的数据导入顺序

### 设计文档
- [权限管理设计方案](/kec/auth-design) — 三级权限模型 + JWT 认证流程
- [详细实施方案](/kec/plan) — 技术选型和开发计划
- [项目深度分析](/kec/project-analysis) — 架构和模块分析

### 技术专题
- [学期计算逻辑](/kec/semester-calculation) — 年级推算和学期序号的算法
- [班级状态修复](/kec/class-status-fix) — 毕业/在读状态的判定与修复
- [子系统分析](/kec/subsystem-analysis) — 各模块的解耦设计
- [系统重置功能](/kec/system-reset-feature) — 数据清空和重置策略
- [教材查询性能优化](/kec/textbook-query-optimization) — 查询性能调优

### 运维部署
- [生产环境部署指南](/kec/DEPLOYMENT_GUIDE) — 一键部署和更新部署完整流程
- [部署检查清单](/kec/PRODUCTION_DEPLOYMENT) — SQLite/MySQL 双方案部署前检查
- [配置更新指南](/kec/CONFIG_UPDATE_GUIDE) — 生产环境配置变更参考
- [500 错误排障修复](/kec/kec-500-error-fix) — /api/settings 500 错误诊断与修复

### 数据管理
- [种子数据使用指南](/kec/seed-usage) — 数据库初始化与安全重置
- [变更日志](/kec/changelog) — 版本更新记录

### 质量保障
- [代码审计报告](/kec/code-audit-report) — V1 审计（28 个问题，Critical 全部已修复）
- [代码审计报告 V2](/kec/code-audit-report-v2) — V2 审计（50+ 问题，安全加固建议）
- [全面检查分析报告 V3](/kec/code-audit-report-v3) — V3 审计（11 严重 / 12 高危，2026-06-12）
- [全面检查分析报告 V4](/kec/code-audit-report-v4) — V4 审计（2026-06-12，大量问题已修复）
- [生产部署成熟度评估](/kec/deploy-readiness-report) — 2026-06-13，116 次提交当前版本评估
- [全功能测试报告](/kec/test-report) — 60 用例，98.3% 通过率
- [开发进度说明](/kec/development-progress) — 完整提交日志与里程碑记录

---

## 项目地址

- **GitHub**: [github.com/shub2026/kec-manager](https://github.com/shub2026/kec-manager)
- **在线体验**: 部署后访问 `https://your-domain.com`（默认账号 `admin` / `admin@123456`，首次登录请修改密码）

---

*KEC = Knowledge · Education · Curriculum*
