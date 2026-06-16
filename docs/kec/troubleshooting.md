---
layout: doc
sidebar: false
---

# 故障排查指南

本指南汇总了 KEC Manager 常见问题的诊断步骤和修复方法。

## 500 错误

### `/api/settings` 返回 500

**典型错误信息：**

```
/api/settings:1 Failed to load resource: the server responded with a status of 500 ()
加载系统标识失败: AxiosError: Request failed with status code 500
```

#### 根本原因

`/api/settings` 接口在登录页被调用以获取系统标识（organization_name），在生产环境中可能因为以下原因返回 500：

- 数据库文件不存在或路径错误
- 数据库文件权限不足
- Prisma Client 未正确生成
- `system_settings` 表不存在或未初始化
- 数据库连接失败但错误未被正确处理

#### 快速修复

如果诊断结果提示缺少设置项：

```
缺少 organization_name 设置
缺少 current_semester 设置
```

这不是错误，仅需初始化默认设置：

```bash
cd /opt/1panel/www/sites/kec/index/kec-manager/server
npm run init:settings
pm2 restart kec-server
```

执行后运行诊断确认：

```bash
npm run diagnose
```

::: tip 提示
诊断脚本会自动检查环境变量、数据库文件、目录权限、数据库连接、`system_settings` 表可访问性以及默认设置是否已初始化。
:::

#### 诊断步骤

**1. 检查服务状态和日志**

```bash
# 查看服务状态
pm2 status

# 查看详细错误日志
pm2 logs kec-server --err --lines 100

# 实时监听日志
pm2 logs kec-server --lines 0
```

**关键信息查找：**
- `[Settings GET Error]` - 后端错误日志
- 具体的错误消息和堆栈跟踪
- Prisma 相关错误

**2. 直接测试后端接口**

```bash
# 绕过 Nginx 直接测试
curl http://localhost:3000/api/settings -v
curl http://localhost:3000/api/settings -i
```

**期望返回：**

```json
{
  "code": 200,
  "message": "success",
  "data": {
    "organization_name": {"value": "欢迎回来"},
    "current_semester": {"value": "2025-2026-2"}
  }
}
```

**3. 检查代码版本**

```bash
cd /opt/1panel/www/sites/kec/index/kec-manager/server
git log --oneline -5
grep -A 5 "Settings GET Error Stack" src/routes/settings.routes.js
```

如果代码未更新：

```bash
git pull
pm2 restart kec-server
```

**4. 完整健康检查**

```bash
curl http://localhost:3000/api/health
ls -la data/kec.db
cat .env | grep DATABASE_URL
```

#### 快速诊断脚本

创建临时脚本 `/tmp/quick-check.sh`：

```bash
#!/bin/bash

echo "=== KEC Manager 快速诊断 ==="
echo ""

echo "1. Git 状态:"
cd /opt/1panel/www/sites/kec/index/kec-manager
git log --oneline -3
echo ""

echo "2. PM2 状态:"
pm2 status
echo ""

echo "3. 最近错误日志:"
pm2 logs kec-server --err --lines 20 --nostream
echo ""

echo "4. 本地接口测试:"
curl -s http://localhost:3000/api/settings | head -c 200
echo ""
echo ""

echo "5. 健康检查:"
curl -s http://localhost:3000/api/health | head -c 200
echo ""
echo ""

echo "6. 数据库文件权限:"
ls -lh /opt/1panel/www/sites/kec/index/kec-manager/server/data/kec.db
echo ""

echo "=== 诊断完成 ==="
```

执行：

```bash
chmod +x /tmp/quick-check.sh
bash /tmp/quick-check.sh
```

#### 解决方案

##### 方案 1：修复数据库文件权限（最常见）

```bash
cd /path/to/kec-manager/server

# 确保数据目录存在
mkdir -p data

# 设置正确的权限
chown -R www-data:www-data data/
chmod 755 data/

# 如果数据库文件已存在
if [ -f data/kec.db ]; then
  chown www-data:www-data data/kec.db
  chmod 644 data/kec.db
fi

# 重启服务
pm2 restart kec-server
```

##### 方案 2：重新初始化数据库

```bash
cd /path/to/kec-manager/server

# 1. 重新生成 Prisma Client
npx prisma generate

# 2. 执行数据库迁移
npx prisma migrate deploy

# 3. 初始化默认设置（可选）
npm run db:seed

# 4. 重启服务
pm2 restart kec-server
```

##### 方案 3：检查并修复环境变量

```bash
cd /path/to/kec-manager/server

# 检查 .env 文件是否存在
if [ ! -f .env ]; then
  cp .env.production.example .env
  echo "请编辑 .env 文件并配置正确的值"
fi

# 验证 DATABASE_URL 格式
# SQLite: file:/absolute/path/to/data/kec.db
# MySQL: mysql://user:pass@host:3306/dbname

# 验证 JWT_SECRET 长度（至少 32 字符）
echo $JWT_SECRET | wc -c

# 重启服务
pm2 restart kec-server
```

##### 方案 4：手动初始化 system_settings 表

如果数据库连接正常但缺少设置记录，创建 `init-settings.js`：

```javascript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function initSettings() {
  const defaults = [
    {
      key: 'current_semester',
      value: '2025-2026-2',
      description: '当前学期（格式：起始学年-结束学年-学期序号，如 2025-2026-2 表示2025-2026学年第2学期）'
    },
    {
      key: 'organization_name',
      value: '欢迎回来',
      description: '系统标识（单位名称），用于首页展示'
    }
  ];

  for (const setting of defaults) {
    await prisma.system_settings.upsert({
      where: { key: setting.key },
      update: {},
      create: setting
    });
    console.log(`✓ 已初始化: ${setting.key}`);
  }

  await prisma.$disconnect();
  console.log('✅ 所有设置已初始化');
}

initSettings().catch(console.error);
```

运行：

```bash
cd /path/to/kec-manager/server
node init-settings.js
pm2 restart kec-server
```

##### 方案 5：检查 Nginx 配置

确保 Nginx 正确代理 API 请求：

```nginx
location /api/ {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;

    # 增加超时时间
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;

    # 错误处理
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
}
```

测试并重载：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

#### 可能原因与排查

##### PM2 缓存了旧代码

`git log` 显示最新提交但错误仍存在：

```bash
pm2 delete kec-server
cd /opt/1panel/www/sites/kec/index/kec-manager/server
pm2 start src/server.js --name kec-server
pm2 save
```

##### Prisma Client 版本不匹配

日志中出现 Prisma 相关错误：

```bash
cd /opt/1panel/www/sites/kec/index/kec-manager/server
npx prisma generate
pm2 restart kec-server
```

##### 环境变量未加载

日志中出现 `DATABASE_URL is not defined`：

```bash
cat /opt/1panel/www/sites/kec/index/kec-manager/server/.env | grep DATABASE_URL

# 如果缺失，重新创建
cp /opt/1panel/www/sites/kec/index/kec-manager/server/.env.production.example \
   /opt/1panel/www/sites/kec/index/kec-manager/server/.env

vim /opt/1panel/www/sites/kec/index/kec-manager/server/.env
pm2 restart kec-server
```

##### 端口被占用

PM2 日志中出现 `EADDRINUSE` 错误：

```bash
lsof -i :3000
kill -9 <PID>
pm2 start src/server.js --name kec-server
```

##### 数据库文件权限问题

日志中出现 `SQLITE_CANTOPEN` 或 `permission denied`：

```bash
cd /opt/1panel/www/sites/kec/index/kec-manager/server
chown -R $(whoami):$(whoami) data/
chmod 755 data/
chmod 644 data/kec.db
pm2 restart kec-server
```

#### 代码层面的修复

`server/src/routes/settings.routes.js` 已增强错误处理：

```javascript
router.get('/', async (req, res, next) => {
  try {
    const settings = await prisma.system_settings.findMany();
    // ... 处理逻辑
    success(res, map);
  } catch (e) {
    console.error('[Settings GET Error]', e.message);
    console.error('[Settings GET Error Stack]', e.stack);

    // 降级处理：返回默认设置
    const defaultMap = {};
    for (const [key, def] of Object.entries(DEFAULT_SETTINGS)) {
      defaultMap[key] = { value: def.value, description: def.description, isDefault: true };
    }

    // 明确返回 200 状态码
    return res.status(200).json({
      code: 200,
      message: '使用默认设置',
      data: defaultMap
    });
  }
});
```

前端可加入重试机制：

```javascript
async function loadSystemSettings(retryCount = 3) {
  for (let i = 0; i < retryCount; i++) {
    try {
      const response = await axios.get('/api/settings');
      return response.data;
    } catch (error) {
      if (i === retryCount - 1) {
        return {
          organization_name: { value: '课程管理系统', isDefault: true }
        };
      }
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}
```

#### 终极重置方案

如以上方案都无效，可完全重置服务：

```bash
cd /opt/1panel/www/sites/kec/index/kec-manager
pm2 stop kec-server
pm2 delete kec-server

cd server
rm -rf node_modules
npm install --production

npx prisma generate
npm run init:settings

pm2 start src/server.js --name kec-server
pm2 save

sleep 3
pm2 logs kec-server --lines 30
curl http://localhost:3000/api/settings
```

## 部署与预防

### 部署前检查清单

```bash
# Node.js 版本 >= 18
node --version

# 数据库目录存在且有正确权限
ls -la data/

# .env 文件已正确配置
cat .env | grep -v "^#" | grep -v "^$"

# Prisma Client 已生成
npx prisma generate

# 数据库迁移已执行
npx prisma migrate deploy

# 健康检查通过
curl http://localhost:3000/api/health

# Settings 接口正常
curl http://localhost:3000/api/settings
```

### 监控脚本示例

```bash
#!/bin/bash

HEALTH_CHECK=$(curl -s http://localhost:3000/api/health)
SETTINGS_CHECK=$(curl -s http://localhost:3000/api/settings)

if echo "$HEALTH_CHECK" | grep -q '"status":"ok"'; then
  echo "✅ 健康检查通过"
else
  echo "❌ 健康检查失败"
  pm2 restart kec-server
fi

if echo "$SETTINGS_CHECK" | grep -q '"code":200'; then
  echo "✅ Settings 接口正常"
else
  echo "❌ Settings 接口异常"
fi
```

### 定期备份

```bash
# crontab -e
# 每天凌晨 2 点备份数据库
0 2 * * * cp /path/to/kec-manager/server/data/kec.db /backup/kec_$(date +\%Y\%m\%d).db
```

## 常见问题 FAQ

### 为什么本地开发正常，生产环境报错？

常见原因：
- 生产环境的数据库路径不同
- 文件权限设置不同
- 环境变量未正确配置
- 数据库未初始化

### SQLite 和 MySQL 哪个更适合生产环境？

- **SQLite**：适合小型部署（< 1000 用户），单文件，易备份
- **MySQL**：适合中大型部署，支持并发，更稳定

### 如何查看完整的错误日志？

```bash
# PM2 日志
pm2 logs kec-server --lines 100

# 仅错误日志
pm2 logs kec-server --err

# Nginx 错误日志
tail -f /var/log/nginx/error.log
```

### 数据库被锁定怎么办？

```bash
# 检查是否有多个进程访问
lsof data/kec.db

# 重启服务释放锁
pm2 restart kec-server
```

## 联系支持

如果以上方案都无法解决问题，请收集以下信息：

- `pm2 logs kec-server --lines 100` 的输出
- `curl http://localhost:3000/api/settings -v` 的完整输出
- `curl http://localhost:3000/api/health` 的输出
- `.env` 文件内容（隐藏敏感信息）
- 操作系统、Node.js 版本（`node -v`）、PM2 版本（`pm2 -v`）

然后提交 Issue 到项目仓库。
