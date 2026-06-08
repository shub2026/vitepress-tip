# KEC课程管理平台说明

面向教学管理人员的轻量级课程管理平台

---

## 平台简介

KEC课程管理平台是一套独立运行的教学管理解决方案，专为中小型教育机构设计。平台采用现代化技术栈，提供课程管理、班级编排、培养方案制定、教材管理等核心功能，支持按学期自动查询开课情况和教材使用统计。

### 适用场景

- 职业技术学院、技工学校的课程与班级管理
- 培训机构的培养方案与教材管理
- 教务部门的开课计划与教学资源调配

### 核心特性

| 特性 | 说明 |
|------|------|
| **一体化管理** | 课程、班级、培养方案、教材信息统一管理，数据互通 |
| **智能年级推算** | 根据入学年份和当前学期配置，自动计算班级在读年级 |
| **灵活培养方案** | 支持按专业或培养层次制定方案，特殊班级可单独指定 |
| **一键导出报表** | 开课情况、教材使用情况支持 Excel 导出，便于打印和分发 |
| **批量导入** | 支持通过 Excel 批量导入班级、课程、教材数据 |
| **双数据库支持** | 本地开发用 SQLite，生产环境可无缝切换到 MySQL |

---

## 技术架构

### 技术选型

```
前端层          Vue 3 + Element Plus + Vite
                  ↓
API层          Express.js (RESTful API)
                  ↓
数据层          Prisma ORM
                  ↓
存储层          SQLite (开发) / MySQL (生产)
```

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 前端框架 | Vue 3 | 3.4+ | Composition API，响应式开发 |
| UI组件库 | Element Plus | 2.5+ | 企业级组件库，开箱即用 |
| 构建工具 | Vite | 5.2+ | 极速开发体验，热更新秒开 |
| 状态管理 | Pinia | 2.1+ | Vue 3 官方推荐状态管理 |
| 路由 | Vue Router | 4.3+ | 单页应用路由管理 |
| 后端框架 | Express | 5.1+ | 轻量灵活的 Node.js Web 框架 |
| ORM | Prisma | 6.10+ | 类型安全，支持多数据库 |
| 数据库 | SQLite / MySQL | - | 开发/生产环境分离 |
| Excel处理 | exceljs | 4.4+ | 纯 JS 实现，无需额外依赖 |

### 系统架构图

```
┌─────────────────────────────────────────────┐
│                 浏览器客户端                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  班级管理  │  │ 培养方案  │  │ 查询报表  │   │
│  └──────────┘  └──────────┘  └──────────┘   │
└──────────────────────┬──────────────────────┘
                       │ HTTP/REST API
┌──────────────────────┴──────────────────────┐
│              Express 后端服务                  │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌──────┐  │
│  │ 路由层  │→│ 业务逻辑│→│ 数据访问│→│工具类│  │
│  └────────┘ └────────┘ └────────┘ └──────┘  │
└──────────────────────┬──────────────────────┘
                       │ Prisma Client
┌──────────────────────┴──────────────────────┐
│              数据库 (SQLite/MySQL)             │
│  majors | courses | classes | plans | ...    │
└─────────────────────────────────────────────┘
```

---

## 环境要求

- **Node.js**: 18.x 或 20.x LTS 版本
- **npm**: 8.x 或更高版本
- **操作系统**: Windows / macOS / Linux

> 推荐使用 nvm 管理 Node.js 版本

---

## 快速开始

### 1. 克隆项目

```bash
git clone https://github.com/shub2026/kec-manager.git
cd kec-manager
```

### 2. 安装依赖

```bash
# 安装根目录依赖（用于同时启动前后端）
npm install

# 安装后端依赖
cd server && npm install && cd ..

# 安装前端依赖
cd client && npm install && cd ..
```

### 3. 初始化数据库

```bash
cd server
npx prisma migrate dev --name init
npx prisma generate
cd ..
```

### 4. 导入示例数据（可选）

```bash
cd server
node prisma/seed.js
cd ..
```

示例数据包含：
- 5个培养层次（中专、3+2大专、高技工、5年制大专、高职）
- 4个学院、5个专业
- 11门课程（公共基础课 + 专业课）
- 6本教材
- 3套培养方案
- 12个班级（覆盖不同专业和层次）

### 5. 启动开发服务器

```bash
# 同时启动前后端（推荐）
npm run dev

# 或分别启动
cd server && npm run dev    # 后端 API: http://localhost:3000
cd client && npm run dev    # 前端页面: http://localhost:5173
```

启动成功后访问：
- **前端界面**: http://localhost:5173
- **后端 API**: http://localhost:3000
- **健康检查**: http://localhost:3000/api/health

---

## 项目结构

```
kec-manager/
├── client/                         # 前端应用
│   ├── src/
│   │   ├── api/                    # API 请求封装
│   │   │   ├── class.js            # 班级管理 API
│   │   │   ├── college.js          # 学院管理 API
│   │   │   ├── course.js           # 课程管理 API
│   │   │   ├── major.js            # 专业管理 API
│   │   │   ├── plan.js             # 培养方案 API
│   │   │   ├── query.js            # 查询报表 API
│   │   │   ├── textbook.js         # 教材管理 API
│   │   │   └── trainingLevel.js    # 培养层次 API
│   │   ├── components/             # 通用组件
│   │   │   ├── CourseMatrix.vue    # 课程矩阵组件
│   │   │   └── Layout.vue          # 主布局框架
│   │   ├── router/                 # 路由配置
│   │   ├── stores/                 # Pinia 状态管理
│   │   ├── utils/                  # 工具函数
│   │   │   └── request.js          # Axios 封装
│   │   ├── views/                  # 页面组件
│   │   │   ├── Dashboard.vue       # 首页概览
│   │   │   ├── class/              # 班级管理
│   │   │   ├── college/            # 学院管理
│   │   │   ├── course/             # 课程管理
│   │   │   ├── major/              # 专业管理
│   │   │   ├── plan/               # 培养方案
│   │   │   ├── query/              # 查询报表
│   │   │   ├── textbook/           # 教材管理
│   │   │   └── trainingLevel/      # 培养层次管理
│   │   ├── App.vue                 # 根组件
│   │   └── main.js                 # 入口文件
│   ├── index.html                  # HTML 模板
│   ├── vite.config.js              # Vite 配置
│   └── package.json
│
├── server/                         # 后端服务
│   ├── prisma/
│   │   ├── schema.prisma           # 数据库模型定义
│   │   ├── migrations/             # 数据库迁移文件
│   │   └── seed.js                 # 种子数据脚本
│   ├── src/
│   │   ├── routes/                 # API 路由
│   │   │   ├── class.routes.js     # 班级管理接口
│   │   │   ├── college.routes.js   # 学院管理接口
│   │   │   ├── course.routes.js    # 课程管理接口
│   │   │   ├── export.routes.js    # Excel 导出接口
│   │   │   ├── import.routes.js    # Excel 导入接口
│   │   │   ├── major.routes.js     # 专业管理接口
│   │   │   ├── plan.routes.js      # 培养方案接口
│   │   │   ├── query.routes.js     # 查询报表接口
│   │   │   ├── settings.routes.js  # 系统设置接口
│   │   │   ├── textbook.routes.js  # 教材管理接口
│   │   │   └── trainingLevel.routes.js # 培养层次接口
│   │   ├── services/               # 业务逻辑层
│   │   │   └── settings.service.js # 系统设置服务
│   │   ├── middleware/             # 中间件
│   │   │   └── error.js            # 全局错误处理
│   │   ├── utils/                  # 工具函数
│   │   │   ├── excel.js            # Excel 读写工具
│   │   │   └── response.js         # 统一响应格式
│   │   ├── lib/                    # 库文件
│   │   │   └── prisma.js           # Prisma 客户端实例
│   │   └── server.js               # 服务入口
│   ├── uploads/                    # 文件上传临时目录
│   ├── .env                        # 环境变量配置
│   └── package.json
│
├── docs/                           # 文档目录
│   └── plan.md                     # 详细设计方案
│
├── package.json                    # 根目录脚本配置
└── README.md                       # 项目说明文档
```

---

## 功能模块

### 1. 基础数据管理

#### 学院管理
- 学院信息的增删改查
- 支持排序功能
- 显示各学院下的班级数量

#### 专业管理
- 专业类别的维护
- 关联所属学院
- 绑定默认培养方案

#### 培养层次管理
- 学历层次的定义（如：中专、大专、高职等）
- 支持拖拽排序
- 编码和描述管理

#### 课程管理
- 公共基础课与专业课分类
- 课程基本信息：名称、类型、学时等
- 支持 Excel 批量导入

#### 教材管理
- 教材信息录入：书名、ISBN、出版社、作者
- 支持按学期关联到培养方案课程
- Excel 批量导入功能

### 2. 班级管理

- 班级基本信息：名称、入学年份、学制、人数
- 关联专业、学院、培养层次
- 支持特殊班级单独指定培养方案
- 自动计算在读年级和当前学期
- Excel 模板下载和批量导入

**筛选功能**：
- 按学院筛选
- 按专业筛选
- 按培养层次筛选

### 3. 培养方案

- 按专业或培养层次创建方案
- 方案版本管理
- 课程明细编辑：
  - 添加/移除课程
  - 设置开课学期范围
  - 配置周课时和学期周数
- 教材关联：为每门课程的每个学期指定教材

**方案类型**：
- 专业方案：关联到特定专业，该专业班级默认使用
- 层次方案：关联到培养层次，跨专业通用
- 自定义方案：为特殊班级单独指定

### 4. 查询报表

#### 开课查询
查询当前学期所有班级的开课情况：

- **筛选条件**：学院、专业、培养层次
- **展示信息**：
  - 班级名称、二级学院、专业、培养层次
  - 年级、当前学期、学生人数
  - 开课数量、周课时合计
  - 培养方案名称
- **展开详情**：查看每门课程的详细信息和使用的教材
- **导出 Excel**：一键导出当前查询结果

#### 教材使用查询
查询某教材的使用情况：

- **展示信息**：
  - 使用该教材的所有班级
  - 对应课程、学期
  - 学生人数合计
- **用途**：便于安排试卷印刷、教材采购等
- **导出 Excel**：导出统计表

### 5. 系统设置

- 当前学期配置（格式：2025-2026-2）
- 开学日期设置
- 默认学期周数配置

---

## 数据库设计

### 数据表概览

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| `system_settings` | 系统设置 | key, value |
| `training_levels` | 培养层次 | name, code, sort_order |
| `colleges` | 学院 | name, sort_order |
| `majors` | 专业类别 | name, college_id, default_plan_id |
| `courses` | 课程 | name, type (public/specialized) |
| `textbooks` | 教材 | title, isbn, publisher, author |
| `training_plans` | 培养方案 | name, major_id, training_level_id, version |
| `plan_courses` | 方案课程明细 | plan_id, course_id, start_semester, end_semester, weekly_hours |
| `plan_course_semesters` | 学期记录 | plan_course_id, semester, weekly_hours, weeks_count |
| `plan_textbooks` | 教材关联 | semester_id, textbook_id, is_required |
| `classes` | 班级 | name, enrollment_year, duration_years, major_id, college_id, training_level_id, custom_plan_id |

### 数据关系图

```
┌─────────────────┐
│ training_levels │
└────────┬────────┘
         │ 1:N
         │
┌────────┴────────┐     ┌──────────────┐
│    colleges     │     │    majors     │
└────────┬────────┘     └───────┬──────┘
         │                      │
         │ 1:N                  │ 1:N
         │                      │
         └──────────┬───────────┘
                    │
              ┌─────┴─────┐
              │  classes  │
              └─────┬─────┘
                    │
         ┌──────────┼──────────┐
         │          │          │
    college_id  major_id  custom_plan_id
         │          │          │
         │          │     ┌────┴────────┐
         │          │     │training_plans│
         │          │     └────┬────────┘
         │          │          │ 1:N
         │          │     ┌────┴──────────┐
         │          │     │ plan_courses  │
         │          │     └────┬──────────┘
         │          │          │ 1:N
         │          │     ┌────┴──────────────┐
         │          │     │plan_course_semesters│
         │          │     └────┬──────────────┘
         │          │          │ 1:N
         │          │     ┌────┴──────────┐
         │          │     │plan_textbooks │
         │          │     └────┬──────────┘
         │          │          │ N:1
         │          │     ┌────┴────┐
         │          │     │textbooks│
         │          │     └─────────┘
         │          │
         │          └──── courses (via plan_courses)
         │
         └────────── (direct relation)
```

### 年级推算逻辑

```javascript
// 根据入学年份和当前学期计算年级
const grade = currentStartYear - enrollmentYear + 1;

// 计算当前是第几个学期
const currentSemesterNum = (grade - 1) * 2 + semesterIndex;
// semesterIndex: 1=上学期, 2=下学期

// 示例：
// 当前学期: 2025-2026学年 第2学期 (semesterIndex=2, startYear=2025)
// 2024年入学 → grade = 2025 - 2024 + 1 = 2年级 → 第4学期
// 2025年入学 → grade = 2025 - 2025 + 1 = 1年级 → 第2学期
```

---

## API 接口文档

### 基础数据接口

#### 学院管理 `/api/colleges`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/colleges` | 获取所有学院（含班级数统计） |
| POST | `/api/colleges` | 新增学院 |
| PUT | `/api/colleges/:id` | 更新学院 |
| DELETE | `/api/colleges/:id` | 删除学院 |

#### 专业管理 `/api/majors`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/majors` | 获取所有专业（可筛选） |
| POST | `/api/majors` | 新增专业 |
| PUT | `/api/majors/:id` | 更新专业 |
| DELETE | `/api/majors/:id` | 删除专业 |

#### 培养层次 `/api/training-levels`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/training-levels` | 获取所有层次（含排序） |
| POST | `/api/training-levels` | 新增层次 |
| PUT | `/api/training-levels/:id` | 更新层次 |
| DELETE | `/api/training-levels/:id` | 删除层次 |
| PUT | `/api/training-levels/:id/move` | 上移/下移排序 |

#### 课程管理 `/api/courses`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/courses` | 获取课程列表（可按类型筛选） |
| POST | `/api/courses` | 新增课程 |
| PUT | `/api/courses/:id` | 更新课程 |
| DELETE | `/api/courses/:id` | 删除课程 |

#### 教材管理 `/api/textbooks`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/textbooks` | 获取教材列表 |
| POST | `/api/textbooks` | 新增教材 |
| PUT | `/api/textbooks/:id` | 更新教材 |
| DELETE | `/api/textbooks/:id` | 删除教材 |

### 班级管理接口 `/api/classes`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/classes` | 获取班级列表（支持学院/专业/层次筛选） |
| POST | `/api/classes` | 新增班级 |
| PUT | `/api/classes/:id` | 更新班级 |
| DELETE | `/api/classes/:id` | 删除班级 |

**查询参数**：
- `collegeId`: 按学院筛选
- `majorId`: 按专业筛选
- `trainingLevelId`: 按培养层次筛选
- `status`: 按状态筛选（active/graduated）

### 培养方案接口 `/api/plans`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/plans` | 获取方案列表 |
| POST | `/api/plans` | 新增方案 |
| PUT | `/api/plans/:id` | 更新方案 |
| DELETE | `/api/plans/:id` | 删除方案 |
| GET | `/api/plans/:id/courses` | 获取方案课程明细 |
| POST | `/api/plans/:id/courses` | 添加课程到方案 |
| PUT | `/api/plans/courses/:id` | 更新方案课程 |
| DELETE | `/api/plans/courses/:id` | 从方案移除课程 |
| POST | `/api/plans/courses/:id/textbooks` | 关联教材到学期 |
| DELETE | `/api/plans/textbooks/:id` | 取消教材关联 |

### 查询报表接口 `/api/query`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/query/semester` | 当前学期开课查询 |
| GET | `/api/query/textbook/:id` | 指定教材使用情况 |
| GET | `/api/query/textbooks` | 所有教材使用概览 |

**开课查询参数**：
- `collegeId`: 按学院筛选
- `majorId`: 按专业筛选
- `trainingLevelId`: 按培养层次筛选

**返回示例**：
```json
{
  "code": 200,
  "data": {
    "semesterInfo": {
      "label": "2025-2026学年 第2学期",
      "startYear": 2025,
      "endYear": 2026,
      "semesterIndex": 2
    },
    "totalClasses": 12,
    "data": [
      {
        "classId": 1,
        "className": "2024级学前教育1班",
        "collegeName": "教育学院",
        "majorName": "学前教育",
        "trainingLevelName": "中专",
        "grade": 2,
        "currentSemester": 4,
        "studentCount": 45,
        "planName": "学前教育专业培养方案",
        "courses": [...]
      }
    ]
  }
}
```

### Excel 导入导出接口

#### 导出接口

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/export/semester` | 导出开课情况 Excel |
| GET | `/api/export/textbook/:id` | 导出教材使用情况 |
| GET | `/api/export/template/:type` | 下载导入模板 |

模板类型：`classes`、`courses`、`textbooks`

#### 导入接口

| 方法 | 路径 | 说明 |
|------|------|------|
| POST | `/api/import/classes` | 批量导入班级 |
| POST | `/api/import/courses` | 批量导入课程 |
| POST | `/api/import/textbooks` | 批量导入教材 |

**导入格式**：multipart/form-data，字段名 `file`

### 系统设置接口 `/api/settings`

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | `/api/settings` | 获取所有设置 |
| PUT | `/api/settings` | 更新设置 |

**设置项**：
- `current_semester`: 当前学期（如：2025-2026-2）
- `semester_start_date`: 开学日期
- `weeks_per_semester_default`: 默认学期周数

---

## 部署指南

### 1. 切换到 MySQL（生产环境）

修改 `server/.env`：

```env
DATABASE_URL="mysql://username:password@host:3306/course_management"
PORT=3000
NODE_ENV=production
```

### 2. 数据库迁移

```bash
cd server
npx prisma migrate deploy    # 生产环境迁移
npx prisma generate          # 生成客户端
node prisma/seed.js          # 可选：导入初始数据
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

        # 缓存静态资源
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

        # 文件上传大小限制
        client_max_body_size 10M;
    }
}
```

### 5. 进程管理（PM2）

```bash
# 全局安装 PM2
npm install -g pm2

# 启动后端服务
cd server
pm2 start src/server.js --name kec-api

# 设置开机自启
pm2 save
pm2 startup

# 常用命令
pm2 status              # 查看状态
pm2 logs kec-api        # 查看日志
pm2 restart kec-api     # 重启服务
pm2 stop kec-api        # 停止服务
```

### 6. Docker 部署（可选）

创建 `Dockerfile`：

```dockerfile
# 后端
FROM node:18-alpine AS backend
WORKDIR /app
COPY server/package*.json ./
RUN npm ci --only=production
COPY server/ .
RUN npx prisma generate
EXPOSE 3000
CMD ["node", "src/server.js"]

# 前端
FROM node:18-alpine AS frontend
WORKDIR /app
COPY client/package*.json ./
RUN npm ci
COPY client/ .
RUN npm run build

FROM nginx:alpine
COPY --from=frontend /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 常见问题

### Q1: 如何修改当前学期？

进入「系统设置」页面，修改「当前学期」配置。格式为 `起始学年-结束学年-学期序号`，例如 `2025-2026-2` 表示 2025-2026 学年第 2 学期。

### Q2: 班级年级是如何计算的？

系统根据以下公式自动计算：
```
年级 = 当前学年起始年份 - 班级入学年份 + 1
当前学期序号 = (年级 - 1) × 2 + 学期索引
```

例如：当前设置为 2025-2026学年第2学期
- 2024年入学的班级 → 2年级 → 第4学期
- 2025年入学的班级 → 1年级 → 第2学期

### Q3: 如何为特殊班级指定不同的培养方案？

在编辑班级时，「特殊方案」下拉框中选择指定的培养方案。未指定时，班级默认使用其专业关联的方案。

### Q4: Excel 导入失败怎么办？

1. 确保使用最新的模板文件（点击「下载模板」获取）
2. 检查必填字段是否完整
3. 确认关联数据（专业、学院等）已存在且名称匹配
4. 检查数字格式是否正确（入学年份、学制等）
5. 查看控制台错误提示，定位具体问题行

### Q5: 如何从 SQLite 迁移到 MySQL？

1. 修改 `server/.env` 中的 `DATABASE_URL` 为 MySQL 连接字符串
2. 运行 `npx prisma migrate deploy` 自动创建表结构
3. （可选）运行 `node prisma/seed.js` 导入初始数据

Prisma 会自动处理数据库差异，无需手动迁移数据。

### Q6: 培养方案的开课学期如何设置？

在培养方案详情页，添加课程后点击「编辑学期」按钮，可以：
- 设置开课学期范围（如：第1-4学期）
- 配置每周课时
- 设置学期周数
- 关联教材

### Q7: 如何导出某个学院的开课情况？

1. 进入「开课查询」页面
2. 使用「按学院筛选」选择目标学院
3. 点击「导出Excel」按钮

导出的文件将包含该学院所有班级的详细开课信息。

---

## 开发规范

### 代码风格

- 前端：遵循 Vue 3 Composition API 最佳实践
- 后端：使用 ES Modules，async/await 处理异步
- 命名：变量/函数使用 camelCase，组件使用 PascalCase

### Git 提交规范

```
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整
refactor: 重构代码
test: 测试相关
chore: 构建/工具链相关
```

### 分支策略

- `main`: 主分支，保持稳定可发布状态
- `develop`: 开发分支，日常开发在此进行
- `feature/*`: 功能分支，完成后合并到 develop

---

## 更新日志

### v1.0.0 (2026-06-08)

**新功能**：
- 修复开课查询培养层次不显示问题
- 班级管理和开课查询页面增加按学院筛选功能
- 开课查询表格增加二级学院列
- 项目标题更新为 KEC课程管理平台

**优化**：
- 完善数据库关联查询
- 优化筛选器布局和交互

---

## 许可证

MIT License

---

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。

**项目地址**: [https://github.com/shub2026/kec-manager](https://github.com/shub2026/kec-manager)
