# 生产环境 /api/settings 500 错误修复指南

## 问题描述

登录页面显示以下错误：
```
/api/settings:1 Failed to load resource: the server responded with a status of 500 ()
加载系统标识失败: AxiosError: Request failed with status code 500
```

## 快速修复（针对诊断提示"缺少设置"的情况）

**如果你看到诊断结果提示：**
```
缺少 organization_name 设置
缺少 current_semester 设置
```

**这不是错误！只需执行以下命令初始化默认设置：**

```bash
cd /opt/1panel/www/sites/kec/index/kec-manager/server
npm run init:settings
pm2 restart kec-server
```

执行后再次运行诊断确认：
```bash
npm run diagnose
```

应该看到所有检查都通过 ✅

---

## 根本原因

`/api/settings` 接口在登录页被调用以获取系统标识（organization_name），但在生产环境中可能因为以下原因返回 500 错误：

1. **数据库文件不存在或路径错误**
2. **数据库文件权限不足**
3. **Prisma Client 未正确生成**
4. **system_settings 表不存在或未初始化**
5. **数据库连接失败但错误未被正确处理**

## 快速诊断

### 方法 1：使用诊断脚本（推荐）

```bash
cd /path/to/kec-manager/server
npm run diagnose
```

诊断脚本会自动检查：
- ✅ 环境变量配置
- ✅ 数据库文件和目录存在性
- ✅ 数据库文件权限
- ✅ 数据库连接状态
- ✅ system_settings 表可访问性
- ✅ 默认设置是否已初始化

### 方法 2：手动检查

```bash
# 1. 检查 PM2 日志
pm2 logs kec-server --lines 50

# 2. 检查健康状态
curl http://localhost:3000/api/health

# 3. 直接测试 settings 接口
curl http://localhost:3000/api/settings -v

# 4. 检查数据库文件
ls -la data/kec.db

# 5. 检查环境变量
cat .env | grep DATABASE_URL
```

## 解决方案

### 方案 1：修复数据库文件权限（最常见）

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

### 方案 2：重新初始化数据库

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

### 方案 3：检查并修复环境变量

```bash
cd /path/to/kec-manager/server

# 1. 检查 .env 文件是否存在
if [ ! -f .env ]; then
  cp .env.production.example .env
  echo "请编辑 .env 文件并配置正确的值"
fi

# 2. 验证 DATABASE_URL 格式
# SQLite 应该是: file:/absolute/path/to/data/kec.db
# MySQL 应该是: mysql://user:pass@host:3306/dbname

# 3. 验证 JWT_SECRET 长度（至少 32 字符）
echo $JWT_SECRET | wc -c

# 4. 重启服务
pm2 restart kec-server
```

### 方案 4：手动初始化 system_settings 表

如果数据库连接正常但缺少设置记录：

```javascript
// 创建 init-settings.js
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

### 方案 5：检查 Nginx 配置

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

测试并重载 Nginx：
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 代码层面的修复

本次更新已对 `server/src/routes/settings.routes.js` 进行了以下改进：

### 改进 1：增强错误处理

```javascript
router.get('/', async (req, res, next) => {
  try {
    const settings = await prisma.system_settings.findMany();
    // ... 处理逻辑
    success(res, map);
  } catch (e) {
    console.error('[Settings GET Error]', e.message);
    console.error('[Settings GET Error Stack]', e.stack); // 新增：完整堆栈

    // 降级处理：返回默认设置
    const defaultMap = {};
    for (const [key, def] of Object.entries(DEFAULT_SETTINGS)) {
      defaultMap[key] = { value: def.value, description: def.description, isDefault: true };
    }

    // 明确返回 200 状态码（修复前可能返回 undefined）
    return res.status(200).json({
      code: 200,
      message: '使用默认设置',
      data: defaultMap
    });
  }
});
```

### 改进 2：前端重试机制

在登录页面添加重试逻辑（前端代码需要实现）：

```javascript
// 伪代码示例
async function loadSystemSettings(retryCount = 3) {
  for (let i = 0; i < retryCount; i++) {
    try {
      const response = await axios.get('/api/settings');
      return response.data;
    } catch (error) {
      if (i === retryCount - 1) {
        // 最后一次失败，使用默认值
        return {
          organization_name: { value: '课程管理系统', isDefault: true }
        };
      }
      // 等待后重试
      await new Promise(resolve => setTimeout(resolve, 1000 * (i + 1)));
    }
  }
}
```

## 预防措施

### 1. 部署前检查清单

```bash
# □ Node.js 版本 >= 18
node --version

# □ 数据库目录存在且有正确权限
ls -la data/

# □ .env 文件已正确配置
cat .env | grep -v "^#" | grep -v "^$"

# □ Prisma Client 已生成
npx prisma generate

# □ 数据库迁移已执行
npx prisma migrate deploy

# □ 健康检查通过
curl http://localhost:3000/api/health

# □ Settings 接口正常
curl http://localhost:3000/api/settings
```

### 2. 监控和告警

```bash
# 创建监控脚本 monitor.sh
#!/bin/bash

HEALTH_CHECK=$(curl -s http://localhost:3000/api/health)
SETTINGS_CHECK=$(curl -s http://localhost:3000/api/settings)

if echo "$HEALTH_CHECK" | grep -q '"status":"ok"'; then
  echo "✅ 健康检查通过"
else
  echo "❌ 健康检查失败"
  pm2 restart kec-server
  # 发送告警通知...
fi

if echo "$SETTINGS_CHECK" | grep -q '"code":200'; then
  echo "✅ Settings 接口正常"
else
  echo "❌ Settings 接口异常"
  # 发送告警通知...
fi
```

### 3. 定期备份

```bash
# crontab -e
# 每天凌晨 2 点备份数据库
0 2 * * * cp /path/to/kec-manager/server/data/kec.db /backup/kec_$(date +\%Y\%m\%d).db
```

## 常见问题 FAQ

### Q1: 为什么本地开发正常，生产环境报错？

**A:** 常见原因：
- 生产环境的数据库路径不同
- 文件权限设置不同
- 环境变量未正确配置
- 数据库未初始化

### Q2: SQLite 和 MySQL 哪个更适合生产环境？

**A:**
- **SQLite**: 适合小型部署（< 1000 用户），单文件，易备份
- **MySQL**: 适合中大型部署，支持并发，更稳定

### Q3: 如何查看完整的错误日志？

```bash
# PM2 日志
pm2 logs kec-server --lines 100

# 仅错误日志
pm2 logs kec-server --err

# Nginx 错误日志
tail -f /var/log/nginx/error.log
```

### Q4: 数据库被锁定怎么办？

```bash
# 检查是否有多个进程访问
lsof data/kec.db

# 重启服务释放锁
pm2 restart kec-server

# 考虑切换到 MySQL 以支持更高并发
```

## 联系支持

如果以上方案都无法解决问题，请：

1. 收集以下信息：
   - `pm2 logs kec-server --lines 100` 的输出
   - `curl http://localhost:3000/api/health` 的输出
   - `.env` 文件内容（隐藏敏感信息）
   - 操作系统和 Node.js 版本

2. 提交 Issue 到项目仓库

3. 查看项目文档：`docs/PRODUCTION_DEPLOYMENT.md`

---

**最后更新**: 2026-06-13
**相关修复**: settings.routes.js 错误处理增强
