# KEC 课程管理平台

面向中小型教育机构的轻量级教学管理系统，覆盖培养计划、班级管理、教师排课、教材协调和数据导入导出全流程。

---

## 平台定位

KEC 解决的核心问题：**每学期排课时，教务人员需要在专业、班级、课程、教材、教师之间反复对照，耗时且容易出错。** 平台将这些数据统一管理，自动匹配培养方案，一键导出开课和教材统计报表。

| 角色 | 能做什么 |
|------|----------|
| **超级管理员** | 全部功能 + 系统设置 + 用户管理 + 数据重置 + 审计日志 |
| **管理员** | 基础数据 CRUD + 班级/方案/教师管理 + 排课操作 + 导入导出 |
| **访客** | 查询报表只读 + 导出 |

> 详细权限矩阵见：[权限管理设计方案](/kec/auth-design)

---

## 核心功能

### 1. 基础数据管理
录入**学院 → 专业 → 培养层次 → 课程 → 教材**，形成数据骨架。课程和教材支持 Excel 批量导入。

### 2. 班级管理
创建新班级时关联学院/专业/层次，系统**自动推算年级和当前学期**。支持按多条件筛选和批量操作。

### 3. 教师管理（v2.0+）
教师档案维护，配置任课学院偏好、培养层次偏好和可教课程。导入教师时自动创建关联基础数据。

### 4. 培养方案
为每个专业或培养层次制定开课计划——哪些课程在哪些学期开、每周多少课时、用什么教材。课程矩阵视图直观展示学期分布。

### 5. 自动排课（v2.0+）
四轮匹配算法：学院偏好 → 培养层次偏好 → 教材匹配 → 容量约束。支持手动排课、自动排课、批量排课和预览模式。

### 6. 查询报表
一键查看当前学期所有班级的开课情况（班级、课程、课时、教材、任课教师），支持按学院/专业/层次/教师多维度筛选，导出 Excel。

---

## 技术栈

| 层级 | 技术 | 说明 |
|------|------|------|
| 前端 | Vue 3.5 + Element Plus 2.14 + Pinia 3 + Vite 5 | Composition API，中文组件库 |
| 后端 | Express 5.1 + Prisma 6.19 + Winston 3.19 | RESTful API，JWT 双令牌认证 |
| 数据库 | SQLite（默认）/ MySQL（可选） | Prisma ORM，开发开箱即用，生产可切换 |
| 部署 | Docker Compose / 裸机（PM2 + Nginx） | 容器化或进程守护，反向代理 + HTTPS |

---

## 文档导航

### 入门
- [KEC 说明文档](/kec/kec-readme) — 完整 README，含技术栈、API 接口和数据库模型
- [登录指南](/kec/login-guide) — 默认管理员账号与常见登录问题
- [代码格式化指南](/kec/code-formatting) — Prettier 和 ESLint 配置与使用

### 部署
- [1Panel 部署指南 (PM2)](/kec/deploy-1panel) — PM2 + Nginx 反向代理方式
- [1Panel Docker 部署](/kec/1panel-docker-deploy) — Docker Compose 容器化方式
- [生产环境部署指南](/kec/DEPLOYMENT_GUIDE) — 一键部署和更新部署完整流程
- [更新操作指南](/kec/update-operations-guide) — SSH 远程部署、本地部署、手动更新全方案
- [故障排查指南](/kec/troubleshooting) — 常见错误诊断与修复

### 核心功能
- [权限管理设计方案](/kec/auth-design) — 三级权限模型 + JWT 双令牌认证流程
- [排课逻辑详解](/kec/teaching-arrange-logic) — 自动排课算法、匹配规则、容量约束
- [自动排课算法 v2](/kec/auto-arrange-logic-v2) — 教材内聚优化版
- [排课算法优化](/kec/scheduling-algorithm-optimization) — P1/P2/P3 缺陷修复记录
- [教材内聚度分析](/kec/textbook-cohesion-analysis) — 排课教材内聚度优化分析

### 技术专题
- [学期计算逻辑](/kec/semester-calculation) — 年级推算和学期序号的算法
- [导出导入审计](/kec/export-import-audit) — 导出/导入/模板接口检查报告

### 质量
- [安全审计报告](/kec/kec-audit-report) — 安全漏洞与业务逻辑审计（32 项）

### 历史
- [版本管理指南](/kec/version-management) — 自动化版本号管理与语义化版本
- [变更日志](/kec/changelog) — 版本更新记录（当前 v2.14.0）

---

## 项目地址

- **Gitee**: [gitee.com/shub77/kec-manager](https://gitee.com/shub77/kec-manager)
- **在线体验**: 部署后访问 `https://your-domain.com`（默认账号 `admin` / `admin@123456`，首次登录请修改密码）

---

*KEC = Knowledge · Education · Curriculum*
