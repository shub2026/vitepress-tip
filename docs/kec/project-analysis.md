---
title: KEC平台 - 项目深度分析报告
sidebar: false
---

> 本文档反映的代码版本：2026-06-11

# KEC课程管理平台 - 项目深度分析报告

## 一、项目概述

### 1.1 项目定位

**KEC课程管理平台（Course Management Platform）** 是一个面向教学管理人员的轻量级课程管理系统，用于管理课程、班级、人才培养方案和教材信息，支持按学期查询开课情况和教材使用情况，并提供Excel报表导出功能。

### 1.2 目标用户与规模

- **用户群体**：教学管理人员（1-3人）
- **业务规模**：
  - 专业：3-5个
  - 班级：≤300个
  - 培养方案：3-5套
  - 学院：若干二级学院
  - 培养层次：大专、本科、研究生等

### 1.3 核心价值主张

1. **自动化年级推算**：根据入学年份和学制自动计算班级在读年级和学期
2. **灵活的方案匹配**：支持按专业、按培养层次或自定义方式关联培养方案
3. **可视化矩阵编辑**：以"学期×课程"矩阵形式直观配置培养方案
4. **智能数据导入**：批量导入时自动创建缺失的基础数据（学院、专业、层次）
5. **独立运行**：不依赖外部系统，可本地部署，成熟后可上云

---

## 二、技术架构详解

### 2.1 技术栈全景

#### 前端技术栈

| 技术 | 版本 | 用途 | 说明 |
|------|------|------|------|
| Vue 3 | ^3.5.34 | UI框架 | Composition API + 响应式系统 |
| Element Plus | ^2.14.1 | UI组件库 | 企业级Vue 3组件库 |
| Vite | ^5.4.21 | 构建工具 | 快速开发服务器和热更新 |
| Pinia | ^3.0.4 | 状态管理 | Vue 3官方推荐状态管理 |
| Vue Router | ^4.6.4 | 路由管理 | 单页应用路由 |
| Axios | ^1.17.0 | HTTP客户端 | RESTful API调用 |
| @element-plus/icons-vue | ^2.3.2 | 图标库 | Element Plus图标集 |
| SortableJS | ^1.15.7 | 拖拽排序 | 列表拖拽排序 |

#### 后端技术栈

| 技术 | 版本 | 用途 | 说明 |
|------|------|------|------|
| Node.js | - | 运行时环境 | JavaScript运行时 |
| Express | ^5.1.0 | Web框架 | 轻量级Web应用框架 |
| Prisma Client | ^6.10.1 | ORM | 类型安全的数据库ORM |
| SQLite | - | 数据库 | 本地零配置数据库（可迁移MySQL） |
| Multer | ^2.0.1 | 文件上传 | 处理multipart/form-data |
| ExcelJS | ^4.4.0 | Excel处理 | 读写Excel文件 |
| CORS | ^2.8.5 | 跨域处理 | 跨域资源共享中间件 |

#### 开发工具

- **concurrently**：同时启动前后端开发服务器
- **nodemon**：后端代码热重载

### 2.2 项目结构

```
kec-manager/
├── client/                    # 前端项目 (Vue 3)
│   ├── src/
│   │   ├── api/              # API接口封装 (9个模块)
│   │   │   ├── major.js      # 专业API
│   │   │   ├── college.js    # 学院API
│   │   │   ├── trainingLevel.js  # 培养层次API
│   │   │   ├── course.js     # 课程API
│   │   │   ├── textbook.js   # 教材API
│   │   │   ├── class.js      # 班级API
│   │   │   ├── plan.js       # 培养方案API
│   │   │   ├── query.js      # 查询API
│   │   │   └── setting.js    # 系统设置API
│   │   ├── components/       # 公共组件
│   │   │   ├── Layout.vue    # 布局组件（导航+顶栏+主内容区）
│   │   │   └── CourseMatrix.vue  # 课程矩阵编辑器（核心复杂组件）
│   │   ├── views/            # 页面视图 (14个页面)
│   │   │   ├── Dashboard.vue         # 首页概览
│   │   │   ├── Majors.vue            # 专业管理
│   │   │   ├── Colleges.vue          # 学院管理
│   │   │   ├── TrainingLevels.vue    # 培养层次
│   │   │   ├── Courses.vue           # 课程管理
│   │   │   ├── Textbooks.vue         # 教材管理
│   │   │   ├── Classes.vue           # 班级管理
│   │   │   ├── Plans.vue             # 培养方案列表
│   │   │   ├── PlanDetail.vue        # 方案明细编辑
│   │   │   ├── QuerySemester.vue     # 当前学期开课查询
│   │   │   ├── QueryPlan.vue         # 培养方案查询
│   │   │   ├── QueryTextbook.vue     # 教材使用查询
│   │   │   ├── Settings.vue          # 系统设置
│   │   │   └── AuditLogs.vue         # 操作日志
│   │   ├── router/           # 路由配置
│   │   │   └── index.js      # 路由定义
│   │   ├── stores/           # Pinia状态管理
│   │   │   └── settings.js   # 系统设置状态
│   │   ├── utils/            # 工具函数
│   │   │   └── request.js    # Axios封装（拦截器+错误处理）
│   │   ├── App.vue           # 根组件
│   │   └── main.js           # 入口文件
│   ├── vite.config.js        # Vite配置（含API代理）
│   └── package.json
│
├── server/                    # 后端项目 (Express)
│   ├── prisma/
│   │   ├── schema.prisma     # 数据库模型定义 (10个表)
│   │   └── migrations/       # 数据库迁移文件
│   ├── src/
│   │   ├── routes/           # 路由层 (12个路由模块)
│   │   │   ├── major.routes.js       # 专业路由
│   │   │   ├── college.routes.js     # 学院路由
│   │   │   ├── trainingLevel.routes.js  # 培养层次路由
│   │   │   ├── course.routes.js      # 课程路由
│   │   │   ├── textbook.routes.js    # 教材路由
│   │   │   ├── class.routes.js       # 班级路由
│   │   │   ├── plan.routes.js        # 培养方案路由
│   │   │   ├── query.routes.js       # 查询路由
│   │   │   ├── import.routes.js      # 导入路由
│   │   │   ├── export.routes.js      # 导出路由
│   │   │   ├── setting.routes.js     # 系统设置路由
│   │   │   └── audit.routes.js       # 审计日志路由
│   │   ├── services/         # 业务逻辑层
│   │   │   ├── settings.service.js   # 设置服务
│   │   │   └── audit.service.js      # 审计服务
│   │   ├── middleware/       # 中间件
│   │   │   └── error.middleware.js   # 全局错误处理
│   │   ├── lib/              # 核心库
│   │   │   └── prisma.js     # Prisma实例
│   │   ├── utils/            # 工具函数
│   │   │   ├── response.js   # 统一响应格式
│   │   │   └── excel.js      # Excel处理工具
│   │   ├── app.js            # Express应用配置
│   │   └── server.js         # 服务器入口
│   ├── uploads/              # 临时上传文件目录
│   └── package.json
│
├── docs/                     # 文档目录
│   ├── project-analysis.md   # 项目分析报告（本文档）
│   ├── plan.md               # 详细实施方案文档
│   ├── class-status-fix.md   # 班级状态修复文档
│   ├── semester-calculation.md  # 学期计算文档
│   ├── system-reset-feature.md  # 系统重置功能文档
│   ├── code-audit-report.md     # 代码审计报告
│   ├── code-audit-report-v2.md  # 代码审计报告 v2
│   ├── subsystem-analysis.md    # 子系统分析
│   ├── textbook-query-optimization.md  # 教材查询性能优化方案
│   ├── test-report.md           # 测试报告
│   ├── deploy-1panel.md         # 1Panel 部署文档
│   ├── auth-design.md           # 权限设计文档
│   ├── kec-manager.md           # KEC Manager 文档
│   ├── kec-readme.md            # KEC README
│   └── 初始化流程.md            # 初始化流程
│
└── package.json              # 根目录脚本（concurrently启动前后端）
```

### 2.3 开发工作流

```bash
# 同时启动前后端开发服务器
npm run dev

# 单独启动
npm run dev:server    # 后端 http://localhost:3000
npm run dev:client    # 前端 http://localhost:5173

# 数据库操作
npm run db:migrate    # 执行数据库迁移
npm run db:generate   # 生成Prisma客户端

# 构建生产版本
npm run build         # 构建前端静态资源
```

### 2.4 前后端通信机制

#### Vite代理配置（开发环境）

```javascript
// client/vite.config.js
server: {
  port: 5173,
  proxy: {
    '/api': {
      target: 'http://localhost:3000',
      changeOrigin: true,
    }
  }
}
```

#### Axios拦截器

```javascript
// client/src/utils/request.js
const service = axios.create({
  baseURL: '/api',
  timeout: 30000
})

// 响应拦截器
service.interceptors.response.use(
  response => response.data,
  error => {
    // 统一错误处理
    ElMessage.error(error.message || '请求失败')
    return Promise.reject(error)
  }
)
```

---

## 三、核心功能模块详解

### 3.1 基础数据管理

#### 3.1.1 专业管理 (`/majors`)

**功能描述**：专业的增删改查

**数据字段**：
- `id`: 唯一标识
- `name`: 专业名称
- `code`: 专业编码
- `description`: 专业描述
- `sort_order`: 排序序号

**业务特点**：简单CRUD，无复杂业务逻辑，为班级和方案提供基础数据

#### 3.1.2 学院管理 (`/colleges`)

**功能描述**：二级学院的增删改查

**数据字段**：
- `id`: 唯一标识
- `name`: 学院名称（唯一约束）
- `code`: 学院编码
- `description`: 学院描述
- `sort_order`: 排序序号

**业务用途**：为班级提供学院维度分类，支持按学院筛选和统计

#### 3.1.3 培养层次管理 (`/training-levels`)

**功能描述**：培养层次的增删改查

**数据字段**：
- `id`: 唯一标识
- `name`: 层次名称（唯一约束，如"大专"、"本科"、"研究生"）
- `code`: 层次编码
- `description`: 层次描述
- `sort_order`: 排序序号

**特殊机制**：班级导入时可自动创建不存在的培养层次，避免手动预置数据

#### 3.1.4 课程管理 (`/courses`)

**功能描述**：课程的增删改查 + Excel批量导入

**数据字段**：
- `id`: 唯一标识
- `name`: 课程名称
- `code`: 课程编码
- `type`: 课程类型（`public`公共基础课 / `professional`专业课）
- `description`: 课程描述

**导入模板**：课程名称、课程编码、课程类型

**业务价值**：课程是培养方案的核心组成元素，分为公共课和专业课两类

#### 3.1.5 教材管理 (`/textbooks`)

**功能描述**：教材的增删改查 + Excel批量导入

**数据字段**：
- `id`: 唯一标识
- `title`: 书名
- `isbn`: ISBN号
- `publisher`: 出版社
- `author`: 作者
- `edition`: 版次
- `publish_date`: 出版日期
- `price`: 定价
- `category`: 类别
- `is_active`: 是否启用

**导入模板**：7个字段（书名、ISBN、出版社、作者、版次、出版日期、定价）

**业务用途**：为培养方案中的课程提供教材关联，支持教材使用情况查询

#### 3.1.6 班级管理 (`/classes`) ⭐核心模块

**功能描述**：班级的增删改查 + Excel批量导入 + 批量操作

**数据字段**：
- **基本信息**：
  - `id`: 唯一标识
  - `name`: 班级名称
  - `enrollment_year`: 入学年份（如2024）
  - `duration_years`: 学制（年，如3年制填3）
  - `student_count`: 人数
  - `status`: 状态（`active`在读 / `graduated`已毕业）
- **关联信息**：
  - `major_id`: 专业ID（外键→majors）
  - `college_id`: 学院ID（外键→colleges）
  - `training_level_id`: 培养层次ID（外键→training_levels）
  - `custom_plan_id`: 自定义培养方案ID（外键→training_plans，可选）

**核心特性**：

1. **自动状态计算**：根据入学年份、学制和当前学期自动判断"在读/已毕业"

   **年级推算算法**：
   ```javascript
   // 从系统设置获取当前学期（如 "2025-2026-2"）
   const [startYear, endYear, semesterIndex] = current_semester.split('-').map(Number)

   // 计算当前年级
   const grade = startYear - enrollment_year + 1

   // 计算当前学期序号（第几个学期）
   const currentSemesterNum = (grade - 1) * 2 + semesterIndex

   // 判断状态
   const totalSemesters = duration_years * 2
   const status = currentSemesterNum <= totalSemesters ? 'active' : 'graduated'
   ```

   **示例场景**：
   - 班级A：2024年入学，3年制
   - 当前学期：2025-2026学年 第2学期
   - 计算：grade = 2025 - 2024 + 1 = 2年级
   - 当前学期序号 = (2-1)×2 + 2 = 第4学期
   - 总学期数 = 3 × 2 = 6学期
   - 第4学期 ≤ 6学期 → status = 'active' (在读)

2. **灵活筛选**：支持按名称、学院、专业、层次、入学年份、状态、培养方案筛选

3. **批量操作**：支持批量删除、批量设置专业/学院/层次/入学年份/学制/状态

4. **分页加载**：支持10/20/50/100条每页

5. **智能导入**：导入时自动创建不存在的学院、专业、培养层次

   **智能导入流程**：
   ```
   1. 读取Excel行数据
   2. 提取培养层次名称 → 查找是否存在
      ├─ 存在 → 使用现有ID
      └─ 不存在 → 自动创建并返回新ID
   3. 提取学院名称 → 同上逻辑
   4. 提取专业名称 → 同上逻辑
   5. 创建班级记录
   ```

---

### 3.2 培养方案管理 (`/plans`) ⭐⭐最复杂模块

#### 3.2.1 方案基本信息

**功能描述**：培养方案的增删改查

**数据字段**：
- `id`: 唯一标识
- `name`: 方案名称
- `major_id`: 专业ID（外键→majors，可选）
- `college_id`: 学院ID（外键→colleges，可选）
- `training_level_id`: 培养层次ID（外键→training_levels，可选）
- `version`: 版本号
- `description`: 方案描述

**关联规则**：专业、学院、层次**三选一**，三者只能选其一

**方案匹配优先级**：
1. **班级自定义方案**（`custom_plan_id`）：最高优先级，明确指定
2. **按专业匹配的方案**（`major_id`）：同专业班级默认使用
3. **按学院匹配的方案**（`college_id`）：同学院班级默认使用
4. **按培养层次匹配的方案**（`training_level_id`）：同层次班级默认使用

**匹配逻辑伪代码**：
```javascript
function getPlanForClass(classData) {
  // 优先使用自定义方案
  if (classData.custom_plan_id) {
    return findPlanById(classData.custom_plan_id)
  }

  // 其次按专业匹配
  if (classData.major_id) {
    const planByMajor = findPlanByMajor(classData.major_id)
    if (planByMajor) return planByMajor
  }

  // 然后按学院匹配
  if (classData.college_id) {
    const planByCollege = findPlanByCollege(classData.college_id)
    if (planByCollege) return planByCollege
  }

  // 最后按层次匹配
  if (classData.training_level_id) {
    return findPlanByLevel(classData.training_level_id)
  }

  return null
}
```

#### 3.2.2 方案课程矩阵 (`CourseMatrix.vue`) ⭐核心交互组件

**可视化布局**：
- **行**：课程（按类型分组：公共基础课、专业课）
- **列**：学期（第1学期 ~ 第N学期，N由最大学期数决定）
- **单元格**：周课时（0/2/4/6/8等数值）

**颜色编码**：
- 白色：0课时
- 浅蓝色：≤2课时
- 中蓝色：≤4课时
- 深蓝色：>4课时

**单元格交互**：
1. 点击单元格打开Popover编辑框
2. 选择周课时（下拉选项：0, 2, 4, 6, 8）
3. 可选择关联教材（周课时为0时不可选）
4. 实时显示学期总课时（周课时 × 周数）

**学期范围设置**：
- 通过对话框设置课程的起始学期和结束学期
- 例如：某课程设置开课范围为第1~4学期
- 系统自动为该课程在第1、2、3、4学期各创建一个学期明细记录

**统一学期周数**：
- 底部控制栏可一键设置所有学期的周数（默认18周）
- 支持单个学期单独调整周数

**排序功能**：
- 每个分组内支持上移/下移调整课程顺序
- 排序影响方案展示和导出时的顺序

**小计统计**：
- 每学期小计课时（该学期所有课程课时之和）
- 每组总课时（公共课组总课时、专业课组总课时）
- 方案总课时（所有课程所有学期课时之和）

**数据结构（三层嵌套）**：
```
TrainingPlan (培养方案)
  └─ PlanCourse[] (方案课程)
      ├─ id, plan_id, course_id
      ├─ start_semester, end_semester (开课范围)
      ├─ weekly_hours, weeks_per_semester (默认值)
      ├─ sort_order (排序)
      └─ PlanCourseSemester[] (学期明细)
          ├─ id, plan_course_id, semester
          ├─ weekly_hours (该学期周课时)
          ├─ weeks_count (该学期周数)
          └─ PlanTextbook[] (教材关联)
              └─ Textbook (教材)
```

**事务一致性保障**：
添加/修改课程时，使用Prisma事务确保：
1. 创建/更新 `PlanCourse`
2. 自动创建/同步对应学期的 `PlanCourseSemester` 记录
3. 失败时自动回滚

**关键API**：
```javascript
POST   /api/plans/:id/courses                 添加课程到方案
PUT    /api/plans/courses/:id                 更新方案课程
DELETE /api/plans/courses/:id                 删除方案课程
POST   /api/plans/:planId/courses/:courseId/semesters  创建/更新学期明细
PUT    /api/plans/semesters/:id               更新学期明细
POST   /api/plans/semesters/:id/textbooks     关联教材到学期
```

---

## 四、业务流程详解

### 4.1 班级年级自动推算流程

#### 触发时机

1. 创建班级时
2. 更新班级时（即使未修改入学年份/学制）
3. 查询班级列表时（前端计算展示）

#### 计算步骤

```javascript
Step 1: 从 system_settings 读取 current_semester (如 "2025-2026-2")
Step 2: 解析出 startYear=2025, endYear=2026, semesterIndex=2
Step 3: grade = startYear - enrollmentYear + 1
Step 4: currentSemesterNum = (grade - 1) * 2 + semesterIndex
Step 5: status = (grade <= durationYears) ? 'active' : 'graduated'
```

#### 示例场景推演

**场景1：正常在读**
```
班级A：2024年入学，3年制
当前学期：2025-2026学年 第2学期

grade = 2025 - 2024 + 1 = 2年级
currentSemester = (2-1)*2 + 2 = 第4学期
总学期数 = 3 * 2 = 6学期
第4学期 ≤ 6学期 → status = 'active' (在读)
```

**场景2：最后一学期**
```
班级A：2024年入学，3年制
当前学期：2026-2027学年 第2学期

grade = 2026 - 2024 + 1 = 3年级
currentSemester = (3-1)*2 + 2 = 第6学期
第6学期 ≤ 6学期 → status = 'active' (在读，最后一学期)
```

**场景3：已毕业**
```
班级A：2024年入学，3年制
当前学期：2027-2028学年 第1学期

grade = 2027 - 2024 + 1 = 4年级
4年级 > 3年制 → status = 'graduated' (已毕业)
```

---

## 五、API接口设计

### 5.1 RESTful API规范

#### 统一响应格式

**成功响应**：
```json
{
  "success": true,
  "message": "操作成功",
  "data": { ... }
}
```

**分页响应**：
```json
{
  "success": true,
  "data": {
    "list": [...],
    "total": 100,
    "page": 1,
    "pageSize": 20,
    "totalPages": 5
  }
}
```

**失败响应**：
```json
{
  "success": false,
  "message": "错误信息"
}
```

#### 通用HTTP状态码

- `200`: 成功
- `400`: 请求参数错误
- `401`: 未授权（未来扩展）
- `403`: 禁止访问（未来扩展）
- `404`: 资源不存在
- `500`: 服务器内部错误

### 5.2 核心API接口清单

#### 基础数据API

| 方法 | 路径 | 说明 | 请求体 | 响应 |
|------|------|------|--------|------|
| GET | `/api/majors` | 专业列表 | - | `{ data: [...] }` |
| POST | `/api/majors` | 创建专业 | `{ name, code, description }` | `{ data: {...} }` |
| PUT | `/api/majors/:id` | 更新专业 | `{ name, ... }` | `{ data: {...} }` |
| DELETE | `/api/majors/:id` | 删除专业 | - | `{ message: '删除成功' }` |

#### 课程与教材API

| 方法 | 路径 | 说明 | 请求体 | 响应 |
|------|------|------|--------|------|
| GET | `/api/courses` | 课程列表（支持分页） | `?page=1&pageSize=20&type=public` | `{ data: { list, total, page, pageSize } }` |
| POST | `/api/courses` | 创建课程 | `{ name, code, type, description }` | `{ data: {...} }` |
| PUT | `/api/courses/:id` | 更新课程 | `{ name, ... }` | `{ data: {...} }` |
| DELETE | `/api/courses/:id` | 删除课程 | - | `{ message: '删除成功' }` |

---

## 六、总结

本文档对KEC课程管理平台进行了全面深度的分析，涵盖：

1. **项目定位与规模**：轻量级内部管理系统，适合1-3人使用
2. **技术架构**：Vue 3 + Element Plus + Vite + Node.js + Express + Prisma + SQLite
3. **核心功能**：基础数据管理、培养方案矩阵编辑、查询报表、Excel导入导出
4. **业务流程**：班级年级自动推算、培养方案课程配置、开课查询、教材使用查询
5. **数据模型**：10个核心表，三层嵌套结构（培养方案→方案课程→学期明细→教材关联）

**项目优势**：
- 数据量小（≤300班级），SQLite完全胜任
- 技术栈成熟，开发周期可控
- 自动化程度高（年级推算、智能导入）
- 用户界面友好（矩阵编辑、可视化展示）

**适用场景**：
- 中职/高职/专科学校的课程管理
- 培训机构的教学计划管理
- 需要按学期查询开课情况和教材使用的场景
