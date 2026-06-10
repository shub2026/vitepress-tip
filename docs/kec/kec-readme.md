# KEC 课程管理平台

<div align="center">

面向教学管理人员的轻量级课程管理平台

[![Node](https://img.shields.io/badge/node-%3E%3D18.0-green.svg)](https://nodejs.org/)
[![Vue](https://img.shields.io/badge/vue-3.x-brightgreen.svg)](https://vuejs.org/)
[![Express](https://img.shields.io/badge/express-5.x-blue.svg)](https://expressjs.com/)
[![Prisma](https://img.shields.io/badge/prisma-6.x-blue.svg)](https://www.prisma.io/)

</div>

---

## 平台简介

KEC 课程管理平台是一套独立运行的教学管理解决方案，专为中小型教育机构设计。平台采用前后端分离架构，提供课程管理、班级编排、培养方案制定、教材管理等核心功能，支持按学期自动查询开课情况和教材使用统计。

### 适用场景

- 职业技术学院、技工学校的课程与班级管理
- 培训机构的培养方案与教材管理
- 教务部门的开课计划与教学资源调配

### 核心特性

| 特性 | 说明 |
|------|------|
| **三级权限体系** | 超级管理员、管理员、访客三种角色，精细化权限控制 |
| **一体化管理** | 学院、专业、层次、课程、教材、班级统一管理 |
| **智能年级推算** | 根据入学年份和当前学期配置，自动计算班级在读年级和毕业状态 |
| **灵活培养方案** | 支持按专业或培养层次制定方案，特殊班级可单独指定自定义方案 |
| **课程矩阵编辑** | 以矩阵视图展示课程-学期分布，直观编辑周课时和关联教材 |
| **批量导入导出** | Excel 批量导入班级/课程/教材，开课和教材使用情况一键导出 |
| **操作审计日志** | 全操作链路记录，支持查询和导出，便于安全审计 |
| **双数据库支持** | 开发环境 SQLite 开箱即用，生产环境可无缝切换到 MySQL |

---

## 技术架构

### 技术选型

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 前端框架 | Vue 3 | 3.5+ | Composition API + `<script setup>` |
| UI 组件库 | Element Plus | 2.14+ | 企业级组件库，中文国际化 |
| 构建工具 | Vite | 5.4+ | 极速开发体验，HMR 热更新 |
| 状态管理 | Pinia | 3.0+ | Vue 3 官方推荐状态管理 |
| HTTP 客户端 | Axios | 1.17+ | 请求拦截、Token 自动刷新 |
| 后端框架 | Express | 5.1+ | Node.js Web 框架 |
| ORM | Prisma | 6.10+ | 类型安全，支持 SQLite/MySQL 切换 |
| 认证 | JWT | 9.0+ | Access Token + Refresh Token 双令牌机制 |
| 日志 | Winston | 3.19+ | 结构化日志，文件滚动存储 |
| Excel | ExcelJS | 4.4+ | 纯 JS 实现，无需额外系统依赖 |

### 系统架构图

```
┌───────────────────────────────────────────────────────┐
│                     浏览器客户端                       │
│  Vue 3 + Element Plus + Pinia + Vue Router            │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐  │
│  │ 基础数据  │ │ 班级管理  │ │ 培养方案  │ │ 查询报表  │  │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘  │
└────────────────────────┬──────────────────────────────┘
                         │ Axios (REST API + JWT Bearer)
┌────────────────────────┴──────────────────────────────┐
│                   Express 后端服务                     │
│  ┌────────┐  ┌──────────┐  ┌────────┐  ┌───────────┐  │
│  │ 路由层  │→│ 中间件链  │→│ 业务逻辑│→│ Prisma ORM│  │
│  │14个模块│  │认证/权限  │  │ 服务层  │  │ 数据访问   │  │
│  └────────┘  │命名转换   │  └────────┘  └───────────┘  │
│              │审计日志   │                              │
│              └──────────┘                              │
└────────────────────────┬──────────────────────────────┘
                         │ Prisma Client
┌────────────────────────┴──────────────────────────────┐
│                数据库 (SQLite / MySQL)                 │
│  12 张数据表：users, classes, training_plans, ...      │
└───────────────────────────────────────────────────────┘
```

---

## 环境要求

- **Node.js**: 18.x 或 20.x LTS
- **npm**: 8.x+
- **操作系统**: Windows / macOS / Linux

---

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/shub2026/kec-manager.git
cd kec-manager
```

### 2. 安装依赖

```bash
# 安装根目录依赖（concurrently 用于同时启动前后端）
npm install

# 安装后端依赖
cd server && npm install && cd ..

# 安装前端依赖
cd client && npm install && cd ..
```

### 3. 初始化数据库

```bash
cd server

# 执行数据库迁移（创建表结构）
npx prisma migrate dev

# 生成 Prisma Client
npx prisma generate

cd ..
```

### 4. 创建超级管理员账号（首次部署必需）

```bash
cd server
npm run db:seed
cd ..
```

此步骤会创建一个超级管理员账号：

| 字段 | 值 |
|------|-----|
| 用户名 | `admin` |
| 密码 | `admin@123456` |
| 角色 | `super_admin` |

> 首次登录后请立即修改默认密码。

### 5. 启动开发服务器

```bash
# 同时启动前后端（推荐）
npm run dev

# 或分别启动
npm run dev:server    # 后端 API: http://localhost:3000
npm run dev:client    # 前端页面: http://localhost:5173
```

启动成功后访问：

| 地址 | 说明 |
|------|------|
| http://localhost:5173 | 前端界面 |
| http://localhost:3000 | 后端 API |
| http://localhost:3000/api/health | 健康检查 |

### 6. 导入基础数据

平台不包含示例数据。首次部署后，使用管理员账号登录，按以下顺序导入基础数据：

1. **培养层次** — 如：中专、大专、高技工等
2. **学院** — 各二级学院
3. **专业** — 各专业类别
4. **课程** — 公共基础课与专业课（支持 Excel 批量导入）
5. **教材** — 教材信息（支持 Excel 批量导入）
6. **班级** — 班级数据（支持 Excel 批量导入）
7. **培养方案** — 制定各专业的开课计划

---

## 项目结构

```
kec-manager/
├── client/                              # 前端应用
│   ├── src/
│   │   ├── api/                         # API 请求封装（9个模块）
│   │   │   ├── audit.js                 # 审计日志 API
│   │   │   ├── class.js                 # 班级管理 API
│   │   │   ├── college.js               # 学院管理 API
│   │   │   ├── course.js                # 课程管理 API
│   │   │   ├── major.js                 # 专业管理 API
│   │   │   ├── plan.js                  # 培养方案 API（13个方法）
│   │   │   ├── query.js                 # 查询报表 API
│   │   │   ├── textbook.js              # 教材管理 API
│   │   │   └── trainingLevel.js         # 培养层次 API
│   │   ├── components/                  # 通用组件
│   │   │   ├── Layout.vue               # 主布局（侧边栏+顶栏+内容区）
│   │   │   ├── ChangePasswordDialog.vue # 修改密码弹窗
│   │   │   └── CourseMatrix.vue         # 课程矩阵组件（核心）
│   │   ├── router/
│   │   │   └── index.js                 # 路由配置（17个路由+权限守卫）
│   │   ├── stores/                      # Pinia 状态管理
│   │   │   ├── auth.js                  # 认证状态（登录/Token/用户信息）
│   │   │   └── settings.js              # 系统设置状态
│   │   ├── utils/
│   │   │   ├── request.js               # Axios 封装（拦截器+Token刷新）
│   │   │   └── cache.js                 # API 响应内存缓存
│   │   ├── views/                       # 页面组件（16个页面）
│   │   │   ├── Login.vue                # 登录页
│   │   │   ├── Dashboard.vue            # 首页概览
│   │   │   ├── class/ClassList.vue      # 班级管理
│   │   │   ├── college/CollegeList.vue  # 学院管理
│   │   │   ├── course/CourseList.vue    # 课程管理
│   │   │   ├── major/MajorList.vue      # 专业管理
│   │   │   ├── plan/
│   │   │   │   ├── PlanList.vue         # 培养方案列表
│   │   │   │   └── PlanDetail.vue       # 方案明细（课程矩阵）
│   │   │   ├── query/
│   │   │   │   ├── SemesterQuery.vue    # 当前学期开课查询
│   │   │   │   ├── PlanQuery.vue        # 培养方案查询
│   │   │   │   └── TextbookQuery.vue    # 教材使用查询
│   │   │   ├── textbook/TextbookList.vue# 教材管理
│   │   │   ├── trainingLevel/           # 培养层次管理
│   │   │   ├── settings/SystemSettings.vue # 系统设置
│   │   │   └── system/
│   │   │       ├── AuditLog.vue         # 操作日志
│   │   │       └── UserManagement.vue   # 用户管理
│   │   ├── App.vue
│   │   └── main.js
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
│
├── server/                              # 后端服务
│   ├── prisma/
│   │   ├── schema.prisma                # 数据模型定义（12个模型）
│   │   ├── migrations/                  # 数据库迁移文件
│   │   └── seed.js                      # 种子数据脚本
│   ├── src/
│   │   ├── routes/                      # API 路由（14个模块）
│   │   │   ├── auth.routes.js           # 认证（登录/登出/刷新Token/改密）
│   │   │   ├── user.routes.js           # 用户管理（CRUD+启禁用）
│   │   │   ├── major.routes.js          # 专业管理
│   │   │   ├── college.routes.js        # 学院管理
│   │   │   ├── trainingLevel.routes.js  # 培养层次管理
│   │   │   ├── course.routes.js         # 课程管理
│   │   │   ├── textbook.routes.js       # 教材管理
│   │   │   ├── class.routes.js          # 班级管理（含状态自动计算）
│   │   │   ├── plan.routes.js           # 培养方案（14个端点）
│   │   │   ├── query.routes.js          # 查询报表
│   │   │   ├── import.routes.js         # Excel 导入（班级/课程/教材）
│   │   │   ├── export.routes.js         # Excel 导出
│   │   │   ├── settings.routes.js       # 系统设置+数据重置
│   │   │   └── audit.routes.js          # 审计日志查询
│   │   ├── services/                    # 业务逻辑层
│   │   │   ├── auth.service.js          # 认证服务（JWT签发/验证/改密）
│   │   │   ├── audit.service.js         # 审计日志服务
│   │   │   └── settings.service.js      # 系统设置服务（学期解析）
│   │   ├── middleware/
│   │   │   ├── auth.middleware.js        # JWT认证+角色权限中间件
│   │   │   ├── naming.middleware.js      # 响应命名转换（snake→camel）
│   │   │   ├── audit.js                 # 审计日志中间件
│   │   │   ├── validation.js            # 请求验证规则
│   │   │   └── error.js                 # 全局错误处理
│   │   ├── utils/
│   │   │   ├── naming.js                # 命名转换工具（camelCase⇄snake_case）
│   │   │   ├── excel.js                 # Excel 读写工具
│   │   │   ├── response.js              # 统一响应格式
│   │   │   └── error.js                 # 错误类定义
│   │   ├── config/
│   │   │   ├── auth.config.js           # JWT 配置
│   │   │   └── logger.js                # Winston 日志配置
│   │   ├── constants/
│   │   │   └── index.js                 # 全局常量
│   │   ├── lib/
│   │   │   └── prisma.js                # Prisma Client 单例
│   │   ├── app.js                       # Express 应用（路由挂载+中间件注册）
│   │   └── server.js                    # 服务入口（端口监听+优雅关闭）
│   ├── uploads/                         # 文件上传临时目录
│   ├── .env                             # 环境变量
│   └── package.json
│
├── docs/                                # 文档目录
│
├── package.json                         # 根目录脚本（concurrently）
└── README.md
```

---

## 功能模块

### 权限体系

系统采用三级权限管理：

| 角色 | 标识 | 权限范围 |
|------|------|----------|
| 超级管理员 | `super_admin` | 所有功能，含系统设置、用户管理、操作日志、数据重置 |
| 管理员 | `admin` | 基础数据 CRUD、培养方案管理、班级管理、导入导出、用户管理（仅限访客） |
| 访客 | `viewer` | 查询报表只读（开课查询、方案查询、教材查询、导出） |

### 1. 基础数据管理

| 模块 | 功能 |
|------|------|
| **学院管理** | 学院 CRUD、排序、显示班级数统计 |
| **专业管理** | 专业 CRUD、排序、显示班级数和方案数统计 |
| **培养层次** | 层次 CRUD、排序、显示班级数统计（如中专/大专/高技工） |
| **课程管理** | 课程 CRUD、按类型筛选（公共基础课/专业课/选修课）、排序、Excel 导入 |
| **教材管理** | 教材 CRUD、启用/停用切换、按类别/出版社筛选、批量操作、Excel 导入 |

### 2. 班级管理

- 班级基本信息：名称、入学年份、学制、人数
- 关联学院、专业、培养层次
- 自定义培养方案（为特殊班级单独指定）
- **自动计算**在读年级和班级状态（在读/已毕业）
- 丰富的筛选条件（名称/学院/专业/层次/入学年份/状态/方案）
- 服务端分页
- 批量操作：删除、设置专业/学院/层次/入学年份/学制/状态
- Excel 模板下载和批量导入（支持跳过/覆盖重复策略）

### 3. 培养方案

- **三种关联方式**（二选一或自定义）：
  - 按专业关联 — 该专业所有班级默认使用
  - 按培养层次关联 — 跨专业通用
  - 自定义方案 — 为特定班级单独指定
- 方案课程管理：添加课程、设置开课学期范围、配置周课时
- **课程矩阵视图**：以二维矩阵展示课程-学期分布，支持在线编辑
- 学期明细：每个学期可配置独立的周课时和周数
- 教材关联：为每门课程的每个学期指定教材（必订/选订）
- 按学院筛选方案列表

### 4. 查询报表

| 报表 | 说明 |
|------|------|
| **当前学期开课查询** | 按学院/专业/层次/入学年份/年级筛选，展开行查看课程明细和教材，导出 Excel |
| **培养方案查询** | 选择方案后显示完整课程矩阵，按公共课/专业课分组，显示周课时/教材/总课时 |
| **教材使用查询** | 搜索教材后显示使用详情（班级/课程/专业/年级/人数/是否必订），导出 Excel |

### 5. 系统管理

| 功能 | 说明 |
|------|------|
| **用户管理** | 创建/编辑/禁用/删除用户，管理员只能管理访客账号 |
| **操作日志** | 按操作类型/模块/结果筛选，分页查看详情 |
| **系统设置** | 当前学期配置，数据重置（支持按模块单独清空或全量重置） |

### 6. 导入导出

| 类型 | 功能 |
|------|------|
| **Excel 导入** | 班级、课程、教材批量导入，支持模板下载，重复数据处理策略 |
| **Excel 导出** | 当前学期开课情况导出、单个教材使用情况导出、导入模板下载 |

---

## 数据库设计

### 数据模型概览

| 模型 | 说明 | 关键字段 |
|------|------|----------|
| `users` | 用户表 | username, password, role, real_name, is_active |
| `audit_logs` | 审计日志 | action, module, operator_id, result, created_at |
| `colleges` | 学院 | name, code, sort_order |
| `majors` | 专业 | name, code, sort_order |
| `training_levels` | 培养层次 | name, code, sort_order |
| `courses` | 课程 | name, code, type (public/professional/elective) |
| `textbooks` | 教材 | title, isbn, publisher, author, category, is_active |
| `training_plans` | 培养方案 | name, major_id?, training_level_id?, college_id? |
| `plan_courses` | 方案课程 | plan_id, course_id, start_semester, end_semester, weekly_hours |
| `plan_course_semesters` | 学期记录 | plan_course_id, semester, weekly_hours, weeks_count |
| `plan_textbooks` | 方案教材 | semester_id, textbook_id, is_required |
| `classes` | 班级 | name, enrollment_year, duration_years, major_id?, college_id?, custom_plan_id? |
| `system_settings` | 系统设置 | key (unique), value |

### 数据关系

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

**班级培养方案匹配优先级：**
1. 自定义方案（`classes.custom_plan_id`） — 最高优先
2. 按专业匹配（`training_plans.major_id = classes.major_id`）
3. 按培养层次匹配（`training_plans.training_level_id = classes.training_level_id`）

### 年级推算逻辑

```javascript
// 当前学期配置：startYear=2025, semesterIndex=2
// 年级 = 当前学年起始年份 - 入学年份 + 1
const grade = startYear - enrollmentYear + 1;

// 当前学期序号 = (年级 - 1) × 2 + 学期索引
const currentSemesterNum = (grade - 1) * 2 + semesterIndex;
// semesterIndex: 1=秋季(上学期), 2=春季(下学期)

// 示例（当前学期: 2025-2026学年第2学期）:
// 2024年入学 → grade=2 → 第4学期
// 2025年入学 → grade=1 → 第2学期
```

---

## API 接口文档

### 认证接口 `/api/auth`（公开）

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/auth/login` | 用户登录 |
| POST | `/api/auth/refresh` | 刷新 Access Token |
| POST | `/api/auth/logout` | 用户登出 |
| GET | `/api/auth/me` | 获取当前用户信息 |
| PUT | `/api/auth/password` | 修改密码 |

### 用户管理 `/api/users`（admin + super_admin）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/users` | 用户列表（admin 仅可见访客） |
| POST | `/api/users` | 创建用户（admin 仅可创建访客） |
| PUT | `/api/users/:id` | 更新用户 |
| PUT | `/api/users/:id/status` | 激活/禁用用户 |
| DELETE | `/api/users/:id` | 删除用户 |

### 基础数据接口（GET 需登录，写操作需 admin）

| 模块 | GET 列表 | POST 创建 | PUT 更新 | DELETE 删除 |
|------|---------|----------|---------|------------|
| 学院 `/api/colleges` | 含班级数统计 | 名称唯一约束 | | 有班级时禁止 |
| 专业 `/api/majors` | 含班级数+方案数 | | | 有班级时禁止 |
| 培养层次 `/api/training-levels` | 含班级数统计 | | | 有班级时禁止 |
| 课程 `/api/courses` | 可按 type 筛选 | | | 被方案使用时禁止 |
| 教材 `/api/textbooks` | | | | 被方案引用时禁止 |

教材额外接口：`POST /api/textbooks/:id/toggle-status`（切换启用/停用）

### 班级管理 `/api/classes`（GET 需登录，写操作需 admin）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/classes` | 分页列表（page/pageSize），支持多条件筛选 |
| POST | `/api/classes` | 创建班级（自动计算状态） |
| PUT | `/api/classes/:id` | 更新班级（自动重算状态） |
| DELETE | `/api/classes/:id` | 删除班级 |

**筛选参数**：`name`、`majorId`、`collegeId`、`trainingLevelId`、`enrollmentYear`、`status`、`planId`（特殊值 `"null"` 筛选空值，`"none"` 筛选未关联方案的班级）

### 培养方案 `/api/plans`（GET 需登录，写操作需 admin）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/plans` | 方案列表（含课程数+班级数统计） |
| POST | `/api/plans` | 创建方案 |
| PUT | `/api/plans/:id` | 更新方案 |
| DELETE | `/api/plans/:id` | 删除方案 |
| GET | `/api/plans/:id/courses` | 方案课程列表（含学期+教材） |
| POST | `/api/plans/:id/courses` | 添加课程到方案 |
| PUT | `/api/plans/courses/:id` | 更新方案课程 |
| DELETE | `/api/plans/courses/:id` | 删除方案课程 |
| GET | `/api/plans/:id/semesters` | 获取方案学期列表 |
| POST | `/api/plans/:planId/courses/:courseId/semesters` | 添加/更新学期安排 |
| PUT | `/api/plans/semesters/:id` | 更新学期安排 |
| POST | `/api/plans/semesters/:id/textbooks` | 关联教材到学期 |
| DELETE | `/api/plans/semesters/:id/textbooks` | 取消教材关联 |
| DELETE | `/api/plans/textbooks/:id` | 删除教材关联 |

### 查询报表 `/api/query`（需登录）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/query/semester` | 当前学期开课查询 |
| GET | `/api/query/textbook/:id` | 单个教材使用情况 |
| GET | `/api/query/textbooks` | 所有教材使用概览 |

**开课查询参数**：`majorId`、`collegeId`、`trainingLevelId`、`enrollmentYear`、`grade`

### Excel 导入导出 `/api/import` `/api/export`（导出需登录，导入需 admin）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/export/template/:type` | 下载导入模板（classes/courses/textbooks） |
| GET | `/api/export/semester` | 导出当前学期开课情况 |
| GET | `/api/export/textbook/:id` | 导出教材使用情况 |
| POST | `/api/import/classes` | 批量导入班级（Excel） |
| POST | `/api/import/courses` | 批量导入课程（Excel） |
| POST | `/api/import/textbooks` | 批量导入教材（Excel） |

### 系统设置 `/api/settings`（GET 需登录，PUT/重置需 super_admin）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/settings` | 获取系统设置 |
| PUT | `/api/settings` | 更新系统设置 |
| POST | `/api/settings/reset/basic` | 清空所有基础数据 |
| POST | `/api/settings/reset/majors` | 清空专业（级联清空方案） |
| POST | `/api/settings/reset/colleges` | 清空学院（级联清空方案） |
| POST | `/api/settings/reset/levels` | 清空层次（级联清空方案） |
| POST | `/api/settings/reset/courses` | 清空课程（级联清空方案课程） |
| POST | `/api/settings/reset/textbooks` | 清空教材（级联清空方案教材） |
| POST | `/api/settings/reset/classes` | 清空班级 |
| POST | `/api/settings/reset/plans` | 清空培养方案 |
| POST | `/api/settings/reset/settings` | 系统重置（清空所有业务数据，保留用户） |
| POST | `/api/settings/reset/audit-logs` | 清空操作日志 |

### 审计日志 `/api/audit`（super_admin）

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/audit/logs` | 分页查询操作日志（筛选：action/module/result） |

### 响应格式

**成功响应：**
```json
{
  "success": true,
  "message": "操作成功",
  "data": { ... }
}
```

**分页响应：**
```json
{
  "success": true,
  "message": "查询成功",
  "items": [ ... ],
  "total": 100
}
```

**错误响应：**
```json
{
  "success": false,
  "message": "错误描述"
}
```

> 响应字段名自动从 snake_case 转换为 camelCase（通过命名转换中间件）。

---

## 部署指南

### 1. 环境变量配置

编辑 `server/.env`：

```env
# 数据库连接（开发环境使用 SQLite）
DATABASE_URL="file:./dev.db"

# 生产环境使用 MySQL
# DATABASE_URL="mysql://username:password@host:3306/course_management"

# 服务端口
PORT=3000

# JWT 密钥（生产环境请替换为高强度随机字符串）
JWT_SECRET=your-production-secret-key
```

### 2. 数据库迁移

```bash
cd server
npx prisma migrate deploy    # 生产环境迁移
npx prisma generate          # 生成 Prisma Client
npm run db:seed              # 创建管理员账号
```

### 3. 构建前端

```bash
cd client
npm run build                # 输出到 dist/ 目录
```

### 4. Nginx 配置

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # 前端静态文件
    location / {
        root /path/to/client/dist;
        try_files $uri $uri/ /index.html;

        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
        }
    }

    # 后端 API 代理
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 10M;
    }
}
```

### 5. PM2 进程管理

```bash
npm install -g pm2

cd server
pm2 start src/server.js --name kec-api

pm2 save
pm2 startup

# 常用命令
pm2 status               # 查看状态
pm2 logs kec-api         # 查看日志
pm2 restart kec-api      # 重启服务
```

---

## 常见问题

### 班级年级是如何计算的？

```
年级 = 当前学年起始年份 - 班级入学年份 + 1
当前学期序号 = (年级 - 1) × 2 + 学期索引 (1=秋季, 2=春季)
```

班级状态（在读/已毕业）由系统根据入学年份、学制和当前学期配置自动计算，每次创建或更新班级时自动重算。

### 培养方案的匹配规则是什么？

系统按以下优先级为班级匹配培养方案：

1. **自定义方案** — 班级编辑时手动指定的方案（最高优先级）
2. **按专业匹配** — 培养方案的 `major_id` 与班级的 `major_id` 一致
3. **按培养层次匹配** — 培养方案的 `training_level_id` 与班级的 `training_level_id` 一致

### Excel 导入失败怎么办？

1. 确保使用系统提供的最新模板（点击"下载模板"获取）
2. 检查必填字段（带 * 号的列）是否完整
3. 课程类型请使用标准名称：`公共基础课`、`专业课`、`选修课`
4. 导入班级时，如果专业/学院/层次不存在，系统会自动创建
5. 重复数据处理策略：`skip`（跳过）或 `overwrite`（覆盖）

### 遇到数据库字段缺失错误怎么办？

如果提示类似 `column 'sort_order' does not exist` 的错误：

```bash
cd server
npx prisma migrate reset --force   # 重置数据库并重新应用迁移
npx prisma generate                # 重新生成 Prisma Client
npm run db:seed                    # 重新创建管理员账号
```

### 如何从 SQLite 切换到 MySQL？

1. 修改 `server/.env` 中的 `DATABASE_URL` 为 MySQL 连接字符串
2. 运行 `npx prisma migrate deploy` 创建表结构
3. 运行 `npm run db:seed` 创建管理员账号

Prisma 会自动处理数据库差异。

---

## npm scripts

### 根目录

| 命令 | 说明 |
|------|------|
| `npm run dev` | 同时启动前后端开发服务器 |
| `npm run dev:server` | 仅启动后端（端口 3000） |
| `npm run dev:client` | 仅启动前端（端口 5173） |
| `npm run db:migrate` | 执行数据库迁移 |
| `npm run db:generate` | 生成 Prisma Client |

### 后端 (server/)

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动后端（--watch 模式） |
| `npm start` | 启动后端（生产模式） |
| `npm run db:migrate` | 执行 Prisma 迁移 |
| `npm run db:generate` | 生成 Prisma Client |
| `npm run db:seed` | 执行种子数据脚本 |

### 前端 (client/)

| 命令 | 说明 |
|------|------|
| `npm run dev` | 启动 Vite 开发服务器 |
| `npm run build` | 构建生产版本 |
| `npm run preview` | 预览构建结果 |

---

## 许可证

MIT License

---

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。

**项目地址**: https://github.com/shub2026/kec-manager
