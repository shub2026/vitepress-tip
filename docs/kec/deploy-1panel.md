# KEC 课程管理平台 — 1Panel 服务器部署指南

**适用环境：** 1Panel 面板 · Ubuntu 22.04 / CentOS 7+  
**部署方式：** PM2 进程管理 + Nginx 反向代理  
**数据库：** 支持 SQLite（开箱即用）和 MySQL（生产推荐）

---

## 一、环境准备

### 1.1 服务器基础环境

```bash
# 确认 Node.js 版本 ≥ 18
node -v

# 如果未安装，在 1Panel 面板 → 运行环境 → Node.js 中安装
# 推荐 Node.js 20.x LTS
```

### 1.2 安装 Git（如未安装）

```bash
# Ubuntu
apt install git -y

# CentOS
yum install git -y
```

### 1.3 创建站点目录

在 1Panel 面板中创建网站目录（以 `/opt/1panel/www/sites/kec` 为例）：

```bash
mkdir -p /opt/1panel/www/sites/kec
```

---

## 二、克隆项目

```bash
cd /opt/1panel/www/sites
git clone https://github.com/shub2026/kec-manager.git kec

cd kec
```

---

## 三、方案一：SQLite 部署（开箱即用）

SQLite 方案无需额外安装数据库服务，适合小规模使用或演示环境。

### 3.1 安装依赖

```bash
# 根目录依赖
npm install

# 后端依赖
cd server && npm install && cd ..

# 前端依赖
cd client && npm install && cd ..
```

### 3.2 配置环境变量

```bash
cd server
cat > .env << 'EOF'
# ===== SQLite 配置 =====
DATABASE_URL="file:./kec.db"

# ===== 服务端口 =====
PORT=3000

# ===== JWT 密钥（生产环境请替换为随机字符串）=====
# 生成随机密钥：openssl rand -base64 64
JWT_SECRET=your-random-secret-key-change-me

# ===== 日志级别（开发: debug, 生产: info）=====
LOG_LEVEL=info

# ===== CORS 允许的来源（生产环境填写实际域名）=====
ALLOWED_ORIGINS=https://your-domain.com
EOF
```

### 3.3 初始化数据库

```bash
# 生成 Prisma Client
npx prisma generate

# 执行数据库迁移（创建 SQLite 数据库和表结构）
npx prisma migrate deploy

# 创建超级管理员账号
node prisma/seed.js
```

### 3.4 构建前端

```bash
cd ../client

# 如果使用了 API 代理，需先配置生产环境 API 地址
# 编辑 vite.config.js，或创建 .env.production：
cat > .env.production << 'EOF'
VITE_API_BASE_URL=/api
EOF

npm run build
# 构建产物输出到 dist/ 目录
```

### 3.5 SQLite 注意事项

| 项目 | 说明 |
|------|------|
| 数据文件 | `server/prisma/kec.db` |
| 并发限制 | 不支持多进程并发写入 |
| 备份方式 | 直接复制 `.db` 文件即可 |
| 适用场景 | 单用户/小规模使用、演示环境 |
| 备份脚本 | `cp server/prisma/kec.db backups/kec-$(date +%Y%m%d).db` |

---

## 四、方案二：MySQL 部署（生产推荐）

MySQL 方案支持并发写入，适合多用户正式环境。

### 4.1 安装 MySQL

在 1Panel 面板中：
1. **应用商店** → 搜索 **MySQL** → 安装（推荐 8.0）
2. 安装完成后记录 **root 密码**

或命令行安装：

```bash
# 1Panel 已内置 MySQL，在面板 → 数据库 中创建即可
```

### 4.2 创建数据库和用户

在 1Panel 面板 **数据库** 页面中：
1. 点击 **创建数据库**
2. 填写信息：

| 字段 | 值 |
|------|-----|
| 数据库名 | `kec_course` |
| 用户名 | `kec_user` |
| 密码 | 点击生成随机密码并**妥善保存** |
| 访问权限 | `本地服务器` |

> 创建后记录连接信息：
> ```
> 主机: localhost
> 端口: 3306
> 数据库: kec_course
> 用户名: kec_user
> 密码: <生成的密码>
> ```

### 4.3 安装依赖

```bash
cd /opt/1panel/www/sites/kec

# 根目录依赖
npm install

# 后端依赖
cd server && npm install && cd ..

# 前端依赖
cd client && npm install && cd ..
```

### 4.4 配置环境变量

```bash
cd server
cat > .env << 'EOF'
# ===== MySQL 配置 =====
DATABASE_URL="mysql://kec_user:<密码>@localhost:3306/kec_course"

# ===== 服务端口 =====
PORT=3000

# ===== JWT 密钥（生产环境请替换为随机字符串）=====
JWT_SECRET=your-random-secret-key-change-me

# ===== 日志级别 =====
LOG_LEVEL=info

# ===== CORS 允许的来源 =====
ALLOWED_ORIGINS=https://your-domain.com
EOF
```

> ⚠️ 将 `<密码>` 替换为 4.2 步中生成的数据库密码

### 4.5 修改 Prisma Schema 为 MySQL

编辑 `server/prisma/schema.prisma`：

```diff
datasource db {
-  provider = "sqlite"
-  url      = env("DATABASE_URL")
+  provider = "mysql"
+  url      = env("DATABASE_URL")
}
```

> 如果需要在 SQLite 和 MySQL 之间灵活切换，可以保留两个 datasource 块，通过环境变量控制。

### 4.6 初始化数据库

```bash
# 生成 Prisma Client（MySQL 版本）
npx prisma generate

# 执行数据库迁移（创建 MySQL 表结构）
npx prisma migrate deploy

# 创建超级管理员账号
node prisma/seed.js
```

验证数据库是否创建成功：

```bash
# 在 1Panel 数据库页面查看 kec_course 库中的表
# 应包含: users, classes, courses, colleges, majors, training_levels,
#         training_plans, plan_courses, plan_course_semesters, 
#         plan_textbooks, textbooks, system_settings, audit_logs
```

### 4.7 构建前端

```bash
cd ../client
npm run build
```

### 4.8 MySQL 日常维护

| 操作 | 命令/方法 |
|------|----------|
| 备份数据库 | 1Panel 面板 → 数据库 → 备份 |
| 定时备份 | 1Panel 面板 → 计划任务 → 添加备份任务 |
| 恢复数据库 | 1Panel 面板 → 数据库 → 导入 |
| 查看连接数 | `mysql -u root -p -e "SHOW PROCESSLIST;"` |

---

## 五、PM2 进程管理

### 5.1 安装 PM2

```bash
# 全局安装
npm install -g pm2

# 或通过 1Panel 面板 → 运行环境 → Node.js → PM2 管理
```

### 5.2 启动后端服务

```bash
cd /opt/1panel/www/sites/kec/server

# 启动服务
pm2 start src/server.js --name kec-api

# 设置开机自启
pm2 save
pm2 startup

# 查看状态
pm2 status
```

### 5.3 PM2 常用命令

| 命令 | 说明 |
|------|------|
| `pm2 status` | 查看所有进程状态 |
| `pm2 logs kec-api` | 查看实时日志 |
| `pm2 restart kec-api` | 重启服务 |
| `pm2 stop kec-api` | 停止服务 |
| `pm2 delete kec-api` | 删除进程 |
| `pm2 monit` | 实时监控面板 |

### 5.4 配置 PM2 生态系统文件（可选）

创建 `ecosystem.config.cjs`（在项目根目录）：

```javascript
module.exports = {
  apps: [{
    name: 'kec-api',
    script: './server/src/server.js',
    cwd: '/opt/1panel/www/sites/kec',
    env: {
      NODE_ENV: 'production',
    },
    instances: 1,
    exec_mode: 'fork',
    max_memory_restart: '500M',
    log_date_format: 'YYYY-MM-DD HH:mm:ss',
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    merge_logs: true,
  }]
};
```

```bash
# 使用配置文件启动
pm2 start ecosystem.config.cjs
```

---

## 六、Nginx 反向代理配置

### 6.1 在 1Panel 中创建网站

1. **网站** → **创建网站** → **静态网站**
2. 填写信息：

| 字段 | 值 |
|------|-----|
| 主域名 | `your-domain.com`（或 `kec.your-domain.com`） |
| 网站目录 | `/opt/1panel/www/sites/kec/client/dist` |
| 备注 | KEC 课程管理平台 |

### 6.2 配置反向代理

创建网站后，点击 **设置** → **反向代理**，添加规则：

| 代理名称 | 代理路径 | 目标 URL | 发送域名 |
|----------|----------|----------|----------|
| API 代理 | `/api/` | `http://127.0.0.1:3000` | 否 |

或者直接编辑 Nginx 配置文件（**设置** → **配置文件**）：

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name your-domain.com;

    # 前端静态文件
    location / {
        root /opt/1panel/www/sites/kec/client/dist;
        index index.html;
        try_files $uri $uri/ /index.html;

        # 静态资源缓存
        location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 30d;
            add_header Cache-Control "public, immutable";
        }
    }

    # 后端 API 代理
    location /api/ {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # 上传文件大小限制
        client_max_body_size 20M;
    }
}
```

### 6.3 启用 HTTPS（推荐）

在 1Panel 网站设置中：
1. **设置** → **HTTPS** → **启用**
2. 选择 **自动申请 Let's Encrypt 证书**（免费）
3. 填写邮箱地址，点击保存

---

## 七、首次部署验证

### 7.1 检查后端服务

```bash
# 健康检查
curl http://localhost:3000/api/health

# 预期返回
# {"status":"ok","timestamp":"...","database":"connected","uptime":3}
```

### 7.2 检查前端访问

浏览器访问 `http://your-domain.com`，应看到 KEC 登录页面。

### 7.3 登录系统

| 字段 | 值 |
|------|-----|
| 用户名 | `admin` |
| 密码 | `admin@123456` |

> ⚠️ **首次登录后请立即修改默认密码！**

### 7.4 导入基础数据

登录后按以下顺序导入基础数据：

1. **培养层次** — 如：中专、大专、本科、高技工
2. **学院** — 各二级学院
3. **专业** — 各专业类别
4. **课程** — 公共基础课与专业课（支持 Excel 批量导入）
5. **教材** — 教材信息（支持 Excel 批量导入）
6. **班级** — 班级数据（支持 Excel 批量导入）
7. **培养方案** — 制定各专业的开课计划

---

## 八、更新部署

当 GitHub 仓库有更新时，执行以下步骤：

```bash
cd /opt/1panel/www/sites/kec

# 1. 拉取最新代码
git pull origin main

# 2. 安装新依赖（如有新增）
npm install
cd server && npm install && cd ..
cd client && npm install && cd ..

# 3. 执行数据库迁移（如有结构变更）
cd server
npx prisma generate
npx prisma migrate deploy
cd ..

# 4. 构建前端
cd client && npm run build && cd ..

# 5. 重启后端服务
pm2 restart kec-api

# 6. 验证
curl http://localhost:3000/api/health
```

---

## 九、定时备份

### 9.1 SQLite 备份（1Panel 计划任务）

在 1Panel 面板 → **计划任务** 中创建：

| 字段 | 值 |
|------|-----|
| 任务名称 | KEC SQLite 数据库备份 |
| 执行周期 | 每天凌晨 2:00 |
| 脚本内容 | 见下方 |

```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/kec"
mkdir -p "$BACKUP_DIR"
cp /opt/1panel/www/sites/kec/server/prisma/kec.db \
   "$BACKUP_DIR/kec-$(date +%Y%m%d-%H%M%S).db"
# 保留最近 7 天的备份
find "$BACKUP_DIR" -name "*.db" -mtime +7 -delete
```

### 9.2 MySQL 备份（1Panel 计划任务）

在 1Panel 面板 → **计划任务** → **备份数据库**：
- 选择 `kec_course` 数据库
- 设置执行周期（推荐每天凌晨 2:00）
- 备份保留 7 天

---

## 十、安全加固清单

| 序号 | 项目 | 操作 | 优先级 |
|------|------|------|--------|
| 1 | 修改默认密码 | 登录后立即修改 admin 密码 | 🔴 必须 |
| 2 | 更换 JWT 密钥 | `.env` 中设置随机 `JWT_SECRET` | 🔴 必须 |
| 3 | 配置 CORS | `.env` 中设置 `ALLOWED_ORIGINS` | 🟠 推荐 |
| 4 | 启用 HTTPS | 1Panel 中申请 Let's Encrypt 证书 | 🟠 推荐 |
| 5 | 防火墙 | 仅开放 80/443 端口，3000 仅本地监听 | 🟠 推荐 |
| 6 | 禁用 PM2 日志到控制台 | 设置 `pm2 set pm2:disable_logs true` | 🟡 可选 |
| 7 | 配置日志轮转 | PM2 日志和 Winston 日志设置轮转 | 🟡 可选 |
| 8 | 定期更新依赖 | `npm audit` 检查漏洞并升级 | 🟡 可选 |

生成随机 JWT 密钥：

```bash
openssl rand -base64 64
# 将输出结果填入 .env 的 JWT_SECRET
```

---

## 十一、故障排查

### 11.1 前端页面空白

```bash
# 检查 dist 目录是否存在
ls -la /opt/1panel/www/sites/kec/client/dist/

# 重新构建
cd /opt/1panel/www/sites/kec/client && npm run build
```

### 11.2 API 返回 502

```bash
# 检查后端进程是否运行
pm2 status

# 查看后端日志
pm2 logs kec-api --lines 50

# 重启后端
pm2 restart kec-api
```

### 11.3 数据库连接失败

```bash
# 检查 .env 配置
cat /opt/1panel/www/sites/kec/server/.env

# SQLite: 检查数据库文件是否存在
ls -la /opt/1panel/www/sites/kec/server/prisma/kec.db

# MySQL: 测试连接
mysql -u kec_user -p -h localhost kec_course -e "SELECT 1"
```

### 11.4 端口被占用

```bash
# 查看 3000 端口占用
lsof -i :3000

# 杀掉占用进程
kill -9 <PID>
```

---

## 十二、目录结构（部署后）

```
/opt/1panel/www/sites/kec/
├── client/
│   ├── dist/                  # 前端构建产物（Nginx 根目录）
│   └── ...
├── server/
│   ├── prisma/
│   │   ├── kec.db            # SQLite 数据库文件（方案一）
│   │   └── migrations/       # 数据库迁移记录
│   ├── src/
│   │   └── server.js         # 服务入口
│   ├── .env                  # 环境变量配置
│   └── ...
├── logs/                     # PM2 日志目录
│   ├── pm2-error.log
│   └── pm2-out.log
├── ecosystem.config.cjs      # PM2 配置文件（可选）
└── package.json
```

---

## 十三、SQLite vs MySQL 对比

| 对比项 | SQLite | MySQL |
|--------|--------|-------|
| 安装配置 | ✅ 零配置，开箱即用 | 需要安装数据库服务 |
| 并发写入 | ❌ 单写入锁 | ✅ 支持高并发 |
| 备份恢复 | ✅ 复制文件即可 | 需要 mysqldump 或面板操作 |
| 性能 | 适合单用户/小数据量 | 适合多用户/大数据量 |
| 运维成本 | ✅ 极低 | 中等 |
| 适用场景 | 演示环境、小规模使用 | 生产环境、多用户场景 |
| 1Panel 支持 | — | ✅ 内置数据库管理 |

---

*文档版本：1.0 · 最后更新：2026-06-11*
