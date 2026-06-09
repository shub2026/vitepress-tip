---
title: KEC平台 - 详细实施方案
sidebar: false
---

# 课程管理系统 - 详细实施方案

## 一、项目背景与目标

教学管理人员（1-3人）需要一个轻量级、独立运行的课程管理系统，用于管理计划、班级、人才培养方案和教材信息，支持按学期查询开课情况和教材使用情况，并导出Excel报表。系统先在本地使用，成熟后部署到阿里云。

## 二、技术选型

| 层级 | 技术 | 选型理由 |
|------|------|----------|
| **前端** | Vue 3 + Element Plus + Vite | 轻量高效，Element Plus 表格/表单/上传组件完美匹配后台管理需求，中文社区活跃 |
| **后端** | Node.js + Express | 用户选择，轻量灵活，RESTful API 开发效率高 |
| **ORM** | Prisma | 原生支持 SQLite 和 MySQL，schema 迁移无缝切换，类型安全 |
| **数据库** | SQLite（本地）→ MySQL（云端） | 零配置本地运行，后期一行命令迁移到 MySQL |
| **Excel处理** | exceljs | 纯 JS 实现，读写 Excel 稳定可靠，无需额外依赖 |
| **状态管理** | Pinia | Vue 3 官方推荐，轻量简洁 |
| **路由** | Vue Router 4 | 标准路由方案 |
| **HTTP客户端** | Axios | 标准方案 |

## 三、数据库设计

### 3.1 数据模型（ER关系）

```
Major(专业类别) 1──1 TrainingPlan(培养方案)
TrainingPlan 1──N PlanCourse(方案课程明细)
PlanCourse N──1 Course(课程)
PlanCourse 1──N PlanTextbook(方案教材关联)
PlanTextbook N──1 Textbook(教材)
Class(班级) N──1 Major
Class N──0..1 TrainingPlan (特殊指定覆盖)
SystemSetting(系统设置)
```

### 3.2 表结构详细设计

#### `majors` - 专业类别（3-5个）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| name | String | 专业名称，如"学前教育"、"计算机应用" |
| code | String? | 专业编码（可选） |
| description | String? | 描述 |
| created_at | DateTime | 创建时间 |
| updated_at | DateTime | 更新时间 |

#### `courses` - 课程

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| name | String | 课程名称，如"语文"、"数学" |
| code | String? | 课程编码（可选） |
| type | Enum | 课程类型：public(公共基础课) / professional(专业课) |
| description | String? | 描述 |
| created_at | DateTime |  |
| updated_at | DateTime | |

#### `training_plans` - 人才培养方案（3-5套）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| name | String | 方案名称，如"2024级学前教育培养方案" |
| major_id | Int (FK) | 关联专业类别 |
| version | String? | 版本号 |
| description | String? | 描述 |
| created_at | DateTime |  |
| updated_at | DateTime | |

#### `plan_courses` - 培养方案课程明细（核心关联表）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| plan_id | Int (FK) | 关联培养方案 |
| course_id | Int (FK) | 关联课程 |
| start_semester | Int | 开课起始学期（如1） |
| end_semester | Int | 开课结束学期（如4） |
| weekly_hours | Float | 每周课时数（如4） |
| weeks_per_semester | Int | 每学期周数（默认18） |
| total_hours | Int | 自动计算或手动：weekly_hours × weeks_per_semester × 学期数 |
| created_at | DateTime |  |
| updated_at | DateTime |  |

#### `textbooks` - 教材

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| title | String | 书名 |
| isbn | String? | 书号 |
| publisher | String? | 出版社 |
| author | String? | 作者 |
| edition | String? | 版次 |
| publish_date | String? | 出版日期 |
| price | Float? | 定价 |
| description | String? | 备注 |
| created_at | DateTime |  |
| updated_at | DateTime |  |

#### `plan` - 培养方案中课程关联教材

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| plan_course_id | Int (FK) | 关联方案课程 |
| textbook_id | Int (FK) | 关联教材 |
| semester | Int | 使用学期（如第3学期用） |
| is_required | Boolean | 是否必订（默认true） |
| created_at | DateTime |  |

#### `classes` - 班级（300个以内）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| name | String | 班级名称，如"2024级学前1班" |
| enrollment_year | Int | 入学年份（如2024） |
| duration_years | Int | 学制年数（如3） |
| major_id | Int (FK) | 所属专业类别 |
| student_count | Int | 班级人数 |
| custom_plan_id | Int? (FK) | 特殊指定的培养方案（覆盖默认） |
| status | Enum | active(在读) / graduated(已毕业) |
| created_at | DateTime |  |
| updated_at | DateTime |  |

#### `system_settings` - 系统设置

| 字段 | 类型 | 说明 |
|------|------|------|
| id | Int (PK, auto) | 主键 |
| key | String (unique) | 设置项键名 |
| value | String | 设置项值 |
| description | String? | 说明 |

关键设置项：
- `current_semester`: 当前学期标识，如 "2025-2026-2"（学年-学期序号）
- `semester_start_date`: 当前学期开学日期
- `weeks_per_semester_default`: 默认每学期周数（18）

## 四、核心业务逻辑

### 4.1 年级推算算法

```
当前学年 = 系统设置的当前学期中提取
班级入学学年 = class.enrollment_year
在读年级 = 当前学年 - 入学学年 + 1
当前学期 = (年级 - 1) × 2 + 当前学期序号(1或2)

示例：2024年入学，当前学期为 2025-2026学年第2学期
  年级 = 2025 - 2024 + 1 = 2（二年级）
  当前学期序号 = (2-1)×2 + 2 = 第4学期
```

### 4.2 班级开课查询逻辑

```
1. 获取当前学期配置（如第4学期）
2. 遍历所有在读班级
3. 对每个班级：
   a. 获取其培养方案（优先 custom_plan_id，否则取专业默认方案）
   b. 查询 plan_courses 中 start_semester <= 当前学期 <= end_semester 的课程
   c. 获取每门课程在该学期关联的教材
4. 汇总输出：班级 → 课程 → 课时 → 教材
```

### 4.3 教材使用情况查询

```
1. 选定某教材
2. 查找该教材在所有 plan_textbooks 中的记录
3. 反查对应的 plan_course → training_plan
4. 查找使用该培养方案的所有班级（当前学期在开课范围内的）
5. 汇总：教材 → 使用班级列表 → 各班人数 → 合计人数
```

## 五、系统功能模块

### 5.1 基础数据管理

| 模块 | 功能 | 操作 |
|------|------|------|
| **专业管理** | 专业类别 CRUD | 新增、编辑、删除、列表 |
| **课程管理** | 课程信息 CRUD | 新增、编辑、删除、列表、Excel批量导入 |
| **教材管理** | 教材信息 CRUD | 新增、编辑、删除、列表、Excel批量导入 |
| **班级管理** | 班级信息 CRUD | 新增、编辑、删除、列表、Excel批量导入 |
| **培养方案** | 方案 CRUD + 明细编辑 | 创建方案、添加/移除课程、设置学期课时、关联教材 |
| **系统设置** | 学期配置 | 设置当前学期、默认周数等 |

### 5.2 查询与报表

| 功能 | 说明 | 输出 |
|------|------|------|
| **当前学期开课总览** | 所有班级本学期开设课程、课时、教材 | 页面展示 + Excel导出 |
| **教材使用情况** | 某教材被哪些班级使用、学生人数合计 | 页面展示 + Excel导出 |
| **班级课程表** | 单个班级的完整课程安排 | 页面展示 |
| **培养方案查看** | 查看某方案的完整课程设置 | 页面展示 |

### 5.3 Excel 导入/导出

| 功能 | 说明 |
|------|------|
| 班级批量导入 | 提供模板下载，按格式填写后上传 |
| 课程批量导入 | 同上 |
| 教材批量导入 | 同上 |
| 开课情况导出 | 按班级/课程/教材维度导出当前学期开课报表 |
| 教材使用导出 | 导出教材对应班级和人数报表 |

## 六、项目目录结构

```
course-management/
├── server/                    # 后端
│   ├── prisma/
│   │   ├── schema.prisma      # 数据库模型定义
│   │   └── migrations/        # 迁移文件
│   ├── src/
│   │   ├── app.js             # Express 应用入口
│   │   ├── routes/            # 路由定义
│   │   │   ├── major.routes.js
│   │   │   ├── course.routes.js
│   │   │   ├── textbook.routes.js
│   │   │   ├── class.routes.js
│   │   │   ├── plan.routes.js
│   │   │   ├── query.routes.js
│   │   │   ├── import.routes.js
│   │   │   ├── export.routes.js
│   │   │   └── settings.routes.js
│   │   ├── controllers/       # 控制器
│   │   ├── services/          # 业务逻辑
│   │   │   ├── grade.service.js      # 年级推算
│   │   │   ├── schedule.service.js   # 开课查询
│   │   │   ├── textbook.service.js   # 教材使用查询
│   │   │   └── import.service.js     # Excel导入处理
│   │   ├── utils/
│   │   │   ├── excel.js       # Excel读写工具
│   │   │   └── response.js    # 统一响应格式
│   │   └── middleware/
│   │       └── error.js       # 全局错误处理
│   ├── uploads/               # 临时上传文件目录
│   ├── package.json
│   └── .env
│
├── client/                    # 前端
│   ├── src/
│   │   ├── App.vue
│   │   ├── main.js
│   │   ├── router/
│   │   │   └── index.js
│   │   ├── stores/
│   │   │   └── settings.js    # 系统设置store
│   │   ├── api/               # API调用封装
│   │   │   ├── major.js
│   │   │   ├── course.js
│   │   │   ├── textbook.js
│   │   │   ├── class.js
│   │   │   ├── plan.js
│   │   │   ├── query.js
│   │   │   └── settings.js
│   │   ├── views/
│   │   │   ├── Dashboard.vue          # 首页概览
│   │   │   ├── major/
│   │   │   │   └── MajorList.vue
│   │   │   ├── course/
│   │   │   │   └── CourseList.vue
│   │   │   ├── textbook/
│   │   │   │   └── TextbookList.vue
│   │   │   ├── class/
│   │   │   │   ├── ClassList.vue
│   │   │   │   └── ClassImport.vue
│   │   │   ├── plan/
│   │   │   │   ├── PlanList.vue
│   │   │   │   └── PlanDetail.vue     # 方案明细编辑（核心页面）
│   │   │   ├── query/
│   │   │   │   ├── SemesterQuery.vue  # 当前学期开课查询
│   │   │   │   └── TextbookQuery.vue  # 教材使用查询
│   │   │   └── settings/
│   │   │       └── SystemSettings.vue
│   │   ├── components/
│   │   │   ├── Layout.vue             # 布局框架（侧栏+顶栏）
│   │   │   ├── ImportDialog.vue       # 通用导入弹窗
│   │   │   └── ExportButton.vue       # 通用导出按钮
│   │   └── utils/
│   │       └── request.js             # Axios封装
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
│
├── package.json               # 根目录脚本（同时启动前后端）
├── README.md
└── .gitignore
```

## 七、前端页面设计

### 7.1 布局

- **左侧导航栏**：固定菜单（首页、专业管理、课程管理、班级管理、教材管理、培养方案、查询报表、系统设置）
- **顶栏**：显示当前学期信息，快速切换学期
- **主内容区**：各功能页面

### 7.2 关键页面交互

**培养方案明细编辑（核心复杂页面）**：
- 表格展示：行=课程，列=学期（学期1、学期2...学期6）
- 每个单元格可编辑：周课时数、是否开课
- 教材关联：点击课程行展开，可添加/修改该课程各学期使用的教材

**开课查询页面**：
- 筛选：按专业、按年级筛选
- 表格：班级名 | 专业 | 年级 | 本学期课程 | 周课时 | 使用教材
- 导出按钮：生成Excel下载

**教材使用查询页面**：
- 搜索/选择教材
- 结果：教材信息 + 使用班级列表（班级名、人数）+ 合计人数
- 导出按钮

## 八、API 接口设计

### RESTful API

```
# 专业类别
GET    /api/majors
POST   /api/majors
PUT    /api/majors/:id
DELETE /api/majors/:id

# 课程
GET    /api/courses
POST   /api/courses
PUT    /api/courses/:id
DELETE /api/courses/:id

# 教材
GET    /api/textbooks
POST   /api/textbooks
PUT    /api/textbooks/:id
DELETE /api/textbooks/:id

# 班级
GET    /api/classes
POST   /api/classes
PUT    /api/classes/:id
DELETE /api/classes/:id
POST   /api/classes/import          # 批量导入

# 培养方案
GET    /api/plans
POST   /api/plans
PUT    /api/plans/:id
DELETE /api/plans/:id
GET    /api/plans/:id/courses       # 获取方案课程列表
POST   /api/plans/:id/courses       # 添加课程到方案
PUT    /api/plan-courses/:id        # 更新方案课程
DELETE /api/plan-courses/:id
POST   /api/plan-courses/:id/textbooks  # 关联教材
DELETE /api/plan-textbooks/:id

# 查询
GET    /api/query/semester          # 当前学期开课查询
GET    /api/query/textbook/:id      # 教材使用情况

# 导入导出
POST   /api/import/courses          # 导入课程Excel
POST   /api/import/textbooks        # 导入教材Excel
POST   /api/import/classes          # 导入班级Excel
GET    /api/export/semester         # 导出开课情况Excel
GET    /api/export/textbook/:id     # 导出教材使用情况Excel
GET    /api/export/template/:type   # 下载导入模板

# 系统设置
GET    /api/settings
PUT    /api/settings
```

## 九、实施计划（分阶段）

### 第一阶段：基础框架与数据管理（核心）

1. 项目初始化：前后端脚手架、数据库建表
2. 系统设置模块（当前学期配置）
3. 专业类别 CRUD
4. 课程管理 CRUD
5. 教材管理 CRUD
6. 班级管理 CRUD

### 第二阶段：培养方案（核心业务）

7. 培养方案 CRUD + 关联专业
8. 方案课程明细编辑（学期 × 课程 矩阵）
9. 课程关联教材
10. 班级特殊方案指定

### 第三阶段：导入导出

11. Excel 批量导入（班级、课程、教材）
12. 导入模板下载
13. 开课情况 Excel 导出
14. 教材使用情况 Excel 导出

### 第四阶段：查询报表

15. 首页概览（统计数据）
16. 当前学期开课查询（含筛选）
17. 教材使用查询（含人数统计）

### 第五阶段：完善与部署

18. 数据校验与错误处理完善
19. 本地测试与修复
20. 数据库迁移到 MySQL + 阿里云部署配置

## 十、可行性分析

### 10.1 数据规模评估

| 数据项 | 预估量 | 评估 |
|--------|--------|------|
| 专业类别 | 3-5 条 | 极小 |
| 培养方案 | 3-5 套 | 极小 |
| 课程 | 20-50 门 | 小 |
| 教材 | 50-100 本 | 小 |
| 班级 | ≤300 个 | 小 |
| 方案课程明细 | 每方案 10-20 门 × 5套 ≈ 100 条 | 小 |
| 教材关联 | ≈ 200 条 | 小 |

**结论：数据量极小，SQLite 完全可以胜任，响应速度在毫秒级。**

### 10.2 技术可行性

| 需求点 | 可行性 | 说明 |
|--------|--------|------|
| 课程/班级/教材 CRUD | 高 | 标准 CRUD，无技术难点 |
| Excel 批量导入 | 高 | exceljs 成熟方案，300行数据瞬间完成 |
| 培养方案矩阵编辑 | 中高 | 前端表格交互稍复杂，但 Element Plus 可编辑表格可满足 |
| 开课查询 | 高 | 简单的关联查询，数据量小无性能问题 |
| 教材使用统计 | 高 | 同上 |
| 年级自动推算 | 高 | 简单数学计算 |
| SQLite→MySQL 迁移 | 高 | Prisma 原生支持，改连接字符串+迁移即可 |
| 阿里云部署 | 高 | Node.js + MySQL，标准部署方案 |

### 10.3 风险点

| 风险 | 影响 | 应对策略 |
|------|------|----------|
| 培养方案编辑交互复杂 | 开发耗时增加 | 采用可编辑表格组件，分步实现 |
| Excel 导入格式不规范 | 数据错误 | 严格校验 + 错误提示 + 提供标准模板 |
| 学期切换时数据一致性 | 查询结果偏差 | 以学期配置为基准，不修改历史数据 |
| SQLite 并发写入 | 多用户同时操作 | 1-3人使用场景下不会成为瓶颈 |

### 10.4 综合评估

**项目完全可行。** 数据量小、用户少、业务逻辑清晰，Node.js + Express + Prisma + Vue 3 + Element Plus 的技术栈轻量且成熟，开发周期可控。

## 十一、验证方案

1. **单元测试**：核心业务逻辑（年级推算、开课查询）编写测试用例
2. **功能验证**：
   - 创建 3 个专业、3 套培养方案、10 个测试班级
   - 完成培养方案课程配置和教材关联
   - 测试开课查询结果正确性
   - 测试 Excel 导入导出完整性
3. **性能验证**：导入 300 个班级，验证响应时间
4. **部署验证**：本地 SQLite 运行 → 切换 MySQL 验证数据完整性
