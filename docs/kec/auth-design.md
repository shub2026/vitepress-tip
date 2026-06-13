---
title: KEC平台 - 权限管理系统设计方案
---

本文档反映的代码版本：2026-06-11

# 权限管理系统设计方案

## 一、需求分析

### 1.1 当前问题

- 系统完全开放，无任何身份验证
- 任何人都可以访问和修改所有数据
- 无法区分不同操作人的责任和权限
- 存在数据泄露和恶意篡改风险

### 1.2 业务需求

#### 角色定义

1. **超级管理员（Super Admin）**
   - 系统的最高权限角色
   - 可以管理系统设置（学期配置、数据重置等）
   - 可以查看和管理审计日志
   - 可以管理所有用户（包括管理员和访客）
   - 拥有 admin 的所有权限

2. **管理员（Admin）**
   - 可以登录系统
   - 设置和维护基础信息（专业、学院、培养层次、课程、教材）
   - 管理培养方案
   - 管理班级
   - 查看所有页面
   - 可以管理访客账号

3. **访客（Viewer/Guest）**
   - 通过访客登录或免登录访问
   - 只能访问查询页面：
     - 当前学期开课查询
     - 培养方案查询
     - 教材使用查询
   - 其他涉及基本信息维护和系统设置的页面对其不可见
   - 所有只读操作

### 1.3 技术选型建议

**推荐方案：JWT Token + 前端路由守卫 + 后端中间件鉴权**

**优点**：
- 无状态认证，适合前后端分离架构
- 实现简单，成熟稳定
- 易于扩展到多端（Web、移动端）
- 支持角色权限控制

**备选方案**：
- Session/Cookie（需要处理CSRF，不推荐）
- OAuth 2.0（过度设计，不适合内部系统）

---

## 二、数据库设计

### 2.1 用户表设计

```prisma
// server/prisma/schema.prisma

model users {
  id            Int         @id @default(autoincrement())
  username      String      @unique                        // 用户名（唯一）
  password      String                                     // bcryptjs加密后的密码
  role          String      @default("viewer")             // 角色：super_admin | admin | viewer
  real_name     String?                                    // 真实姓名
  email         String?                                    // 邮箱
  is_active     Boolean     @default(true)                 // 是否激活
  last_login_at DateTime?                                  // 最后登录时间
  created_at    DateTime    @default(now())
  updated_at    DateTime    @updatedAt

  audit_logs    audit_logs[]                               // 关联操作日志

  @@index([username])
  @@index([role])
}
```

### 2.2 操作日志表扩展

```prisma
model audit_logs {
  id          Int      @id @default(autoincrement())
  action      String
  module      String
  operator_id Int?                                    // 新增：操作人ID
  operator    users?   @relation(fields: [operator_id], references: [id])
  ip          String?
  details     String?
  result      String
  message     String?
  created_at  DateTime @default(now())

  @@index([action])
  @@index([module])
  @@index([operator_id])
  @@index([created_at(sort: Desc)])
}
```

### 2.3 初始化管理员账号

```javascript
// server/prisma/seed.js
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  // 检查是否已存在管理员
  const adminExists = await prisma.users.findUnique({
    where: { username: 'admin' }
  })

  if (!adminExists) {
    // 创建默认超级管理员账号
    const hashedPassword = await bcrypt.hash('admin@123456', 10)

    await prisma.users.create({
      data: {
        username: 'admin',
        password: hashedPassword,
        role: 'super_admin',
        real_name: '系统管理员',
        email: 'admin@example.com'
      }
    })

    console.log('默认超级管理员账号已创建：')
    console.log('用户名: admin')
    console.log('密码: admin@123456')
    console.log('请及时修改密码！')
  }

  // 创建示例访客账号（可选）
  const viewerExists = await prisma.users.findUnique({
    where: { username: 'guest' }
  })

  if (!viewerExists) {
    const hashedPassword = await bcrypt.hash('guest@123456', 10)

    await prisma.users.create({
      data: {
        username: 'guest',
        password: hashedPassword,
        role: 'viewer',
        real_name: '访客',
        email: 'guest@example.com'
      }
    })

    console.log('示例访客账号已创建：')
    console.log('用户名: guest')
    console.log('密码: guest@123456')
  }
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

在 `schema.prisma` 中配置 seed：

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "sqlite"
  url      = env("DATABASE_URL")
}

// ... models ...

// 添加 seed 配置
// 在 package.json 中添加：
// "prisma": {
//   "seed": "node prisma/seed.js"
// }
```

---

## 三、后端实现

### 3.1 安装依赖

```bash
cd server
npm install jsonwebtoken bcryptjs
npm install --save-dev @types/jsonwebtoken @types/bcryptjs
```

### 3.2 JWT配置

```javascript
// server/src/config/auth.config.js
export const authConfig = {
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key-change-in-production',
  jwtExpiresIn: '24h', // Token有效期24小时
  jwtRefreshExpiresIn: '7d' // Refresh Token有效期7天
}
```

### 3.3 认证服务

```javascript
// server/src/services/auth.service.js
import jwt from 'jsonwebtoken'
import bcrypt from 'bcryptjs'
import { prisma } from '../lib/prisma.js'
import { authConfig } from '../config/auth.config.js'

export class AuthService {
  /**
   * 用户登录
   */
  static async login(username, password) {
    // 1. 查找用户
    const user = await prisma.users.findUnique({
      where: { username }
    })

    if (!user) {
      throw new Error('用户名或密码错误')
    }

    // 2. 验证密码
    const isValidPassword = await bcrypt.compare(password, user.password)
    if (!isValidPassword) {
      throw new Error('用户名或密码错误')
    }

    // 3. 检查账号是否激活
    if (!user.is_active) {
      throw new Error('账号已被禁用')
    }

    // 4. 生成Token
    const token = this.generateToken(user)
    const refreshToken = this.generateRefreshToken(user)

    // 5. 更新最后登录时间
    await prisma.users.update({
      where: { id: user.id },
      data: { last_login_at: new Date() }
    })

    // 6. 记录登录日志
    await prisma.audit_logs.create({
      data: {
        action: 'login',
        module: 'auth',
        operator_id: user.id,
        result: 'success',
        message: `${user.username} 登录系统`
      }
    })

    return {
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        real_name: user.real_name,
        email: user.email
      },
      token,
      refreshToken
    }
  }

  /**
   * 刷新Token
   */
  static async refreshToken(refreshToken) {
    try {
      const decoded = jwt.verify(refreshToken, authConfig.jwtSecret)
      const user = await prisma.users.findUnique({
        where: { id: decoded.id }
      })

      if (!user || !user.is_active) {
        throw new Error('Refresh Token无效')
      }

      const newToken = this.generateToken(user)
      return { token: newToken }
    } catch (error) {
      throw new Error('Refresh Token已过期或无效')
    }
  }

  /**
   * 生成Access Token
   */
  static generateToken(user) {
    return jwt.sign(
      {
        id: user.id,
        username: user.username,
        role: user.role
      },
      authConfig.jwtSecret,
      { expiresIn: authConfig.jwtExpiresIn }
    )
  }

  /**
   * 生成Refresh Token
   */
  static generateRefreshToken(user) {
    return jwt.sign(
      {
        id: user.id,
        type: 'refresh'
      },
      authConfig.jwtSecret,
      { expiresIn: authConfig.jwtRefreshExpiresIn }
    )
  }

  /**
   * 验证Token
   */
  static verifyToken(token) {
    try {
      return jwt.verify(token, authConfig.jwtSecret)
    } catch (error) {
      return null
    }
  }

  /**
   * 修改密码
   */
  static async changePassword(userId, oldPassword, newPassword) {
    const user = await prisma.users.findUnique({
      where: { id: userId }
    })

    if (!user) {
      throw new Error('用户不存在')
    }

    // 验证旧密码
    const isValid = await bcrypt.compare(oldPassword, user.password)
    if (!isValid) {
      throw new Error('原密码错误')
    }

    // 更新密码
    const hashedPassword = await bcrypt.hash(newPassword, 10)
    await prisma.users.update({
      where: { id: userId },
      data: { password: hashedPassword }
    })

    return { message: '密码修改成功' }
  }
}
```

### 3.4 认证中间件

```javascript
// server/src/middleware/auth.middleware.js
import { AuthService } from '../services/auth.service.js'

/**
 * 认证中间件 - 验证Token有效性
 */
export function authMiddleware(req, res, next) {
  let token = null

  // 优先从 Authorization 头获取
  const authHeader = req.headers.authorization
  if (authHeader && authHeader.startsWith('Bearer ')) {
    token = authHeader.substring(7)
  }
  // 备选：从查询参数获取（用于 window.open 等场景）
  else if (req.query.token) {
    token = req.query.token
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: '未授权，请先登录'
    })
  }

  const decoded = AuthService.verifyToken(token)

  if (!decoded) {
    return res.status(401).json({
      success: false,
      message: 'Token无效或已过期'
    })
  }

  // 将用户信息附加到请求对象
  req.user = decoded
  next()
}

/**
 * 角色授权中间件 - 验证用户角色
 * @param {String[]} allowedRoles - 允许的角色列表
 */
export function roleMiddleware(...allowedRoles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: '未授权'
      })
    }

    if (!allowedRoles.includes(req.user.role)) {
      // 记录未授权访问尝试
      console.warn(`用户 ${req.user.username} 尝试访问受限资源`)

      return res.status(403).json({
        success: false,
        message: '权限不足，无法执行此操作'
      })
    }

    next()
  }
}

/**
 * 可选认证中间件 - Token存在则验证，不存在则允许匿名访问
 */
export function optionalAuthMiddleware(req, res, next) {
  const authHeader = req.headers.authorization

  if (authHeader && authHeader.startsWith('Bearer ')) {
    const token = authHeader.substring(7)
    const decoded = AuthService.verifyToken(token)

    if (decoded) {
      req.user = decoded
    }
  }

  next()
}
```

### 3.5 认证路由

```javascript
// server/src/routes/auth.routes.js
import express from 'express'
import { AuthService } from '../services/auth.service.js'
import { authMiddleware } from '../middleware/auth.middleware.js'
import { success, fail } from '../utils/response.js'

const router = express.Router()

/**
 * POST /api/auth/login
 * 用户登录
 */
router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body

    if (!username || !password) {
      return fail(res, '请输入用户名和密码')
    }

    const result = await AuthService.login(username, password)
    success(res, result, '登录成功')
  } catch (error) {
    fail(res, error.message)
  }
})

/**
 * POST /api/auth/refresh
 * 刷新Token
 */
router.post('/refresh', async (req, res) => {
  try {
    const { refreshToken } = req.body

    if (!refreshToken) {
      return fail(res, '请提供Refresh Token')
    }

    const result = await AuthService.refreshToken(refreshToken)
    success(res, result)
  } catch (error) {
    fail(res, error.message)
  }
})

/**
 * POST /api/auth/logout
 * 用户登出（前端清除Token，后端记录日志）
 */
router.post('/logout', authMiddleware, async (req, res) => {
  try {
    // 记录登出日志
    await prisma.audit_logs.create({
      data: {
        action: 'logout',
        module: 'auth',
        operator_id: req.user.id,
        result: 'success',
        message: `${req.user.username} 登出系统`
      }
    })

    success(res, null, '登出成功')
  } catch (error) {
    fail(res, error.message)
  }
})

/**
 * GET /api/auth/me
 * 获取当前用户信息
 */
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const user = await prisma.users.findUnique({
      where: { id: req.user.id },
      select: {
        id: true,
        username: true,
        role: true,
        real_name: true,
        email: true,
        last_login_at: true,
        created_at: true
      }
    })

    success(res, user)
  } catch (error) {
    fail(res, error.message)
  }
})

/**
 * PUT /api/auth/password
 * 修改密码
 */
router.put('/password', authMiddleware, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body

    if (!oldPassword || !newPassword) {
      return fail(res, '请提供原密码和新密码')
    }

    if (newPassword.length < 8) {
      return fail(res, '新密码长度至少8位')
    }

    await AuthService.changePassword(req.user.id, oldPassword, newPassword)
    success(res, null, '密码修改成功')
  } catch (error) {
    fail(res, error.message)
  }
})

export default router
```

### 3.6 保护现有路由

```javascript
// server/src/app.js
import express from 'express'
import cors from 'cors'
import authRoutes from './routes/auth.routes.js'
import userRoutes from './routes/user.routes.js'
import majorRoutes from './routes/major.routes.js'
import collegeRoutes from './routes/college.routes.js'
import trainingLevelRoutes from './routes/trainingLevel.routes.js'
import courseRoutes from './routes/course.routes.js'
import textbookRoutes from './routes/textbook.routes.js'
import classRoutes from './routes/class.routes.js'
import planRoutes from './routes/plan.routes.js'
import queryRoutes from './routes/query.routes.js'
import importRoutes from './routes/import.routes.js'
import exportRoutes from './routes/export.routes.js'
import settingRoutes from './routes/setting.routes.js'
import auditRoutes from './routes/audit.routes.js'
import { authMiddleware, roleMiddleware } from './middleware/auth.middleware.js'
import { errorHandler } from './middleware/error.middleware.js'

const app = express()

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// 公开路由（无需认证）
app.use('/api/auth', authRoutes)
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// 需要认证的路由
// 查询接口 - 所有登录用户可访问
app.use('/api/query', authMiddleware, queryRoutes)

// 导出接口 - 所有登录用户可访问
app.use('/api/export', authMiddleware, exportRoutes)

// 用户管理 - admin和super_admin可访问（admin只能管理访客）
app.use('/api/users', authMiddleware, roleMiddleware('admin', 'super_admin'), userRoutes)

// 基础数据管理 - 所有登录用户可访问（只读），写操作权限在路由内部控制
app.use('/api/majors', authMiddleware, majorRoutes)
app.use('/api/colleges', authMiddleware, collegeRoutes)
app.use('/api/training-levels', authMiddleware, trainingLevelRoutes)
app.use('/api/courses', authMiddleware, courseRoutes)
app.use('/api/textbooks', authMiddleware, textbookRoutes)

// 班级管理 - 所有登录用户可访问（只读），写操作权限在路由内部控制
app.use('/api/classes', authMiddleware, classRoutes)

// 培养方案管理 - 所有登录用户可访问（只读），写操作权限在路由内部控制
app.use('/api/plans', authMiddleware, planRoutes)

// 导入接口 - admin和super_admin可访问
app.use('/api/import', authMiddleware, roleMiddleware('admin', 'super_admin'), importRoutes)

// 系统设置 - GET公开访问（登录页需要），写操作需要super_admin权限
app.use('/api/settings', settingRoutes)

// 审计日志 - 仅超级管理员可访问
app.use('/api/audit', authMiddleware, roleMiddleware('super_admin'), auditRoutes)

// 错误处理中间件
app.use(errorHandler)

export { app }
```

### 3.7 操作日志增强

```javascript
// server/src/services/audit.service.js
import { prisma } from '../lib/prisma.js'

export class AuditService {
  /**
   * 记录操作日志
   */
  static async log(options) {
    const {
      action,
      module,
      operatorId,
      ip,
      details,
      result = 'success',
      message
    } = options

    try {
      await prisma.audit_logs.create({
        data: {
          action,
          module,
          operator_id: operatorId,
          ip,
          details,
          result,
          message
        }
      })
    } catch (error) {
      console.error('记录审计日志失败:', error)
    }
  }

  /**
   * 获取操作日志列表
   */
  static async getLogs(params = {}) {
    const {
      page = 1,
      pageSize = 20,
      action,
      module,
      operatorId,
      startDate,
      endDate
    } = params

    const skip = (page - 1) * pageSize
    const take = pageSize

    const where = {}

    if (action) where.action = action
    if (module) where.module = module
    if (operatorId) where.operator_id = parseInt(operatorId)
    if (startDate || endDate) {
      where.created_at = {}
      if (startDate) where.created_at.gte = new Date(startDate)
      if (endDate) where.created_at.lte = new Date(endDate)
    }

    const [list, total] = await Promise.all([
      prisma.audit_logs.findMany({
        where,
        skip,
        take,
        orderBy: { created_at: 'desc' },
        include: {
          operator: {
            select: {
              id: true,
              username: true,
              real_name: true
            }
          }
        }
      }),
      prisma.audit_logs.count({ where })
    ])

    return {
      list,
      total,
      page: parseInt(page),
      pageSize: parseInt(pageSize),
      totalPages: Math.ceil(total / pageSize)
    }
  }
}
```

在路由中使用：

```javascript
// 示例：在创建班级时记录日志
import { AuditService } from '../services/audit.service.js'

router.post('/', authMiddleware, roleMiddleware('admin', 'super_admin'), async (req, res) => {
  try {
    const classData = await prisma.classes.create({
      data: req.body
    })

    // 记录操作日志
    await AuditService.log({
      action: 'create',
      module: 'class',
      operatorId: req.user.id,
      ip: req.ip,
      details: JSON.stringify({ classId: classData.id, className: classData.name }),
      message: `创建班级：${classData.name}`
    })

    success(res, classData, '创建成功')
  } catch (error) {
    fail(res, error.message)
  }
})
```

---

## 四、前端实现

### 4.1 安装依赖

```bash
cd client
npm install pinia vue-router axios
```

### 4.2 创建认证Store

```javascript
// client/src/stores/auth.js
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import router from '@/router'
import axios from 'axios'

export const useAuthStore = defineStore('auth', () => {
  // State
  const token = ref(localStorage.getItem('token') || '')
  const refreshToken = ref(localStorage.getItem('refreshToken') || '')
  const userInfo = ref(JSON.parse(localStorage.getItem('userInfo') || 'null'))

  // Getters
  const isLoggedIn = computed(() => !!token.value)
  const isSuperAdmin = computed(() => userInfo.value?.role === 'super_admin')
  const isAdmin = computed(() => userInfo.value?.role === 'admin' || userInfo.value?.role === 'super_admin')
  const isViewer = computed(() => userInfo.value?.role === 'viewer')
  const username = computed(() => userInfo.value?.username || '')
  const realName = computed(() => userInfo.value?.real_name || '')

  // Actions
  async function login(username, password) {
    try {
      const response = await axios.post('/api/auth/login', {
        username,
        password
      })

      const { user, token: newToken, refreshToken: newRefreshToken } = response.data.data

      // 保存认证信息
      token.value = newToken
      refreshToken.value = newRefreshToken
      userInfo.value = user

      // 持久化到localStorage
      localStorage.setItem('token', newToken)
      localStorage.setItem('refreshToken', newRefreshToken)
      localStorage.setItem('userInfo', JSON.stringify(user))

      // 设置Axios默认header
      axios.defaults.headers.common['Authorization'] = `Bearer ${newToken}`

      // 跳转到首页
      router.push('/')

      return { success: true }
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || '登录失败'
      }
    }
  }

  async function logout() {
    try {
      // 调用后端登出接口
      await axios.post('/api/auth/logout')
    } catch (error) {
      console.error('登出请求失败:', error)
    } finally {
      // 清除本地认证信息
      clearAuth()
      router.push('/login')
    }
  }

  async function refreshAccessToken() {
    try {
      const response = await axios.post('/api/auth/refresh', {
        refreshToken: refreshToken.value
      })

      const { token: newToken } = response.data.data

      token.value = newToken
      localStorage.setItem('token', newToken)
      axios.defaults.headers.common['Authorization'] = `Bearer ${newToken}`

      return true
    } catch (error) {
      // Refresh Token失效，强制重新登录
      clearAuth()
      router.push('/login')
      return false
    }
  }

  async function fetchUserInfo() {
    try {
      const response = await axios.get('/api/auth/me')
      userInfo.value = response.data.data

      localStorage.setItem('userInfo', JSON.stringify(response.data.data))
      return true
    } catch (error) {
      // Token失效，尝试刷新
      const refreshed = await refreshAccessToken()
      if (refreshed) {
        return fetchUserInfo() // 重试
      }
      return false
    }
  }

  async function changePassword(oldPassword, newPassword) {
    try {
      await axios.put('/api/auth/password', {
        oldPassword,
        newPassword
      })
      return { success: true, message: '密码修改成功' }
    } catch (error) {
      return {
        success: false,
        message: error.response?.data?.message || '密码修改失败'
      }
    }
  }

  function clearAuth() {
    token.value = ''
    refreshToken.value = ''
    userInfo.value = null

    localStorage.removeItem('token')
    localStorage.removeItem('refreshToken')
    localStorage.removeItem('userInfo')

    delete axios.defaults.headers.common['Authorization']
  }

  // 初始化时恢复登录状态
  function initAuth() {
    if (token.value) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token.value}`
      fetchUserInfo()
    }
  }

  return {
    token,
    refreshToken,
    userInfo,
    isLoggedIn,
    isSuperAdmin,
    isAdmin,
    isViewer,
    username,
    realName,
    login,
    logout,
    refreshAccessToken,
    fetchUserInfo,
    changePassword,
    clearAuth,
    initAuth
  }
})
```

### 4.3 Axios拦截器优化

```javascript
// client/src/utils/request.js
import axios from 'axios'
import { ElMessage } from 'element-plus'
import router from '@/router'
import { useAuthStore } from '@/stores/auth'

const service = axios.create({
  baseURL: '/api',
  timeout: 30000
})

// 请求拦截器
service.interceptors.request.use(
  config => {
    const authStore = useAuthStore()
    if (authStore.token) {
      config.headers.Authorization = `Bearer ${authStore.token}`
    }
    return config
  },
  error => {
    return Promise.reject(error)
  }
)

// 响应拦截器
let isRefreshing = false // 防止重复刷新Token
let failedQueue = [] // 失败的请求队列

const processQueue = (error, token = null) => {
  failedQueue.forEach(prom => {
    if (error) {
      prom.reject(error)
    } else {
      prom.resolve(token)
    }
  })
  failedQueue = []
}

service.interceptors.response.use(
  response => {
    return response.data
  },
  async error => {
    const originalRequest = error.config
    const authStore = useAuthStore()

    // 处理401未授权
    if (error.response?.status === 401) {
      if (isRefreshing) {
        // 正在刷新Token，将请求加入队列
        return new Promise((resolve, reject) => {
          failedQueue.push({ resolve, reject })
        })
          .then(token => {
            originalRequest.headers.Authorization = `Bearer ${token}`
            return service(originalRequest)
          })
          .catch(err => Promise.reject(err))
      }

      isRefreshing = true

      // 尝试刷新Token
      const refreshed = await authStore.refreshAccessToken()

      isRefreshing = false

      if (refreshed) {
        // 刷新成功，重试失败的请求
        processQueue(null, authStore.token)
        originalRequest.headers.Authorization = `Bearer ${authStore.token}`
        return service(originalRequest)
      } else {
        // 刷新失败，跳转登录页
        processQueue(error, null)
        ElMessage.error('登录已过期，请重新登录')
        authStore.logout()
        return Promise.reject(error)
      }
    }

    // 处理403权限不足
    if (error.response?.status === 403) {
      ElMessage.error('权限不足，无法执行此操作')
      return Promise.reject(error)
    }

    // 处理其他错误
    let message = '请求失败'

    if (error.response) {
      switch (error.response.status) {
        case 400:
          message = error.response.data?.message || '请求参数错误'
          break
        case 404:
          message = '请求的资源不存在'
          break
        case 500:
          message = '服务器内部错误'
          break
        default:
          message = error.response.data?.message || '未知错误'
      }
    } else if (error.code === 'ECONNABORTED') {
      message = '请求超时，请稍后重试'
    } else if (error.code === 'ERR_NETWORK') {
      message = '网络连接失败，请检查网络'
    }

    ElMessage.error({
      message,
      duration: 5000,
      showClose: true
    })

    return Promise.reject(error)
  }
)

export default service
```

---

## 五、实施步骤

### 5.1 第一阶段：数据库准备（1天）

1. 更新 `schema.prisma`，添加 `User` 表和扩展 `AuditLog`
2. 运行 `npx prisma migrate dev` 应用迁移
3. 创建 `seed.js` 脚本，初始化超级管理员账号
4. 运行 `npx prisma db seed` 填充初始数据

### 5.2 第二阶段：后端开发（2-3天）

1. 安装依赖：`jsonwebtoken`, `bcryptjs`
2. 创建 `auth.config.js` 配置文件
3. 实现 `auth.service.js` 认证服务
4. 创建 `auth.middleware.js` 中间件
5. 创建 `auth.routes.js` 认证路由
6. 修改 `app.js`，保护现有路由
7. 增强 `audit.service.js`，记录操作人

### 5.3 第三阶段：前端开发（2-3天）

1. 创建 `auth.js` Store
2. 优化 `request.js` 拦截器，处理Token刷新
3. 创建 `Login.vue` 登录页面
4. 修改 `router/index.js`，添加路由守卫
5. 优化 `Layout.vue`，根据角色显示菜单
6. 添加修改密码功能
7. 测试各种场景

### 5.4 第四阶段：测试与优化（1-2天）

1. 单元测试：认证服务、中间件
2. 集成测试：登录、Token刷新、权限控制
3. 端到端测试：完整业务流程
4. 安全测试：SQL注入、XSS、暴力破解防护
5. 性能测试：并发登录、Token验证

### 5.5 第五阶段：部署与文档（1天）

1. 更新 `.env.example`，添加 `JWT_SECRET`
2. 编写部署文档
3. 编写用户使用手册
4. 培训管理员如何使用系统

---

## 六、安全注意事项

### 6.1 密码安全

- 使用bcryptjs加密，salt rounds设为10
- 密码长度至少8位
- 建议定期更换密码
- 不要使用常见密码

### 6.2 Token安全

- JWT Secret必须足够复杂，不要硬编码在代码中
- Access Token有效期不宜过长（建议24小时）
- Refresh Token妥善存储，避免XSS攻击
- HTTPS环境下传输（生产环境必须）

### 6.3 防护措施

- 限制登录尝试次数（防止暴力破解）
- 记录登录日志，监控异常行为
- 启用CORS，限制跨域请求
- 输入验证，防止SQL注入和XSS

### 6.4 环境变量

```bash
# server/.env
DATABASE_URL="file:./dev.db"
JWT_SECRET="your-super-secret-key-at-least-32-characters-long"
PORT=3000
NODE_ENV=development
```

**重要**：`JWT_SECRET` 应该：
- 至少32个字符
- 包含大小写字母、数字、特殊字符
- 不要提交到版本控制系统
- 生产环境使用不同的密钥

---

## 七、总结

本权限管理系统设计方案基于JWT Token实现，具有以下特点：

**优点**：
1. ✅ 实现简单，成熟稳定
2. ✅ 前后端分离友好
3. ✅ 支持角色权限控制
4. ✅ 无状态认证，易于扩展
5. ✅ Token自动刷新，用户体验好

**适用场景**：
- 内部管理系统
- 小型团队使用
- 对安全性要求中等
- 用户数量较少（<1000）

**不适用场景**：
- 大规模分布式系统（建议使用OAuth 2.0 + API Gateway）
- 超高安全性要求（建议使用硬件Token + 生物识别）
- 需要第三方应用集成（建议使用OIDC）
