# 生产环境 /api/settings 500 错误排障与修复

## 问题描述

登录页面显示以下错误：
```
/api/settings:1 Failed to load resource: the server responded with a status of 500 ()
加载系统标识失败: AxiosError: Request failed with status code 500
```

---

## 快速修复（缺少默认设置）

如果诊断提示"缺少 organization_name 设置"或"缺少 current_semester 设置"，直接初始化即可：

```bash
cd /path/to/kec-manager/server
npm run init:settings
pm2 restart kec-server
```

---

## 根本原因

`/api/settings` 接口在登录页被调用以获取系统标识（organization_name），但在生产环境中可能因以下原因返回 500：

1. **数据库文件不存在或路径错误**
2. **数据库文件权限不足**
3. **Prisma Client 未正确生成**
4. **system_settings 表不存在或未初始化**
5. **数据库连接失败但错误未被正确处理**
6. **PM2 缓存了旧代码**
7. **环境变量未加载**

---

## 紧急诊断步骤

### 1. 使用诊断脚本（推荐）

```bash
cd /path/to/kec-manager/server
npm run diagnose
```

诊断脚本自动检查：环境变量、数据库文件、权限、连接状态、system_settings 表、默认设置。

### 2. 检查 PM2 服务状态和日志

```bash
# 查看服务状态
pm2 status

# 查看详细错误日志（最重要！）
pm2 logs kec-server --err --lines 100

# 实时监听日志
pm2 logs kec-server --lines 0
```

**关键信息查找**：`[Settings GET Error]` 日志、Prisma 相关错误、EADDRINUSE 端口占用。

### 3. 直接测试后端接口

```bash
# 在服务器上直接测试（绕过 Nginx）
curl http://localhost:3000/api/settings -v

# 健康检查
curl http://localhost:3000/api/health
```

### 4. 检查代码是否已更新

```bash
cd /path/to/kec-manager/server
git log --oneline -5
grep -A 5 "Settings GET Error Stack" src/routes/settings.routes.js
```

如果没有输出，需要拉取最新代码：

```bash
git pull
pm2 restart kec-server
```

### 5. 快速诊断脚本

```bash
#!/bin/bash
echo "=== KEC Manager 快速诊断 ==="
cd /path/to/kec-manager
git log --oneline -3
pm2 status
pm2 logs kec-server --err --lines 20 --nostream
curl -s http://localhost:3000/api/settings | head -c 200
curl -s http://localhost:3000/api/health | head -c 200
ls -lh server/data/kec.db
echo "=== 诊断完成 ==="
```

---

## 完整解决方案

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

pm2 restart kec-server
```

### 方案 2：重新初始化数据库

```bash
cd /path/to/kec-manager/server
npx prisma generate
npx prisma migrate deploy
npm run db:seed
pm2 restart kec-server
```

### 方案 3：强制重启（清除 PM2 缓存）

```bash
pm2 stop kec-server
pm2 delete kec-server
pm2 start src/server.js --name kec-server
pm2 save

sleep 5
pm2 logs kec-server --lines 20
```

### 方案 4：检查和修复环境变量

```bash
cd /path/to/kec-manager/server

if [ ! -f .env ]; then
  cp .env.production.example .env
  echo "请编辑 .env 文件并配置正确的值"
fi

# 验证关键配置
cat .env | grep DATABASE_URL
cat .env | grep -v "^#" | grep -v "^$"
pm2 restart kec-server
```

### 方案 5：端口被占用

```bash
# 查找占用 3000 端口的进程
lsof -i :3000
kill -9 <PID>
pm2 start src/server.js --name kec-server
```

### 方案 6：终极重置

```bash
cd /path/to/kec-manager
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

---

## 代码层面的修复

服务端已对 `settings.routes.js` 进行增强：

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

    return res.status(200).json({
      code: 200,
      message: '使用默认设置',
      data: defaultMap
    });
  }
});
```

---

## Nginx 配置检查

确保 Nginx 正确代理 API 请求：

```nginx
location /api/ {
    proxy_pass http://localhost:3000;
    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_connect_timeout 60s;
    proxy_send_timeout 60s;
    proxy_read_timeout 60s;
    proxy_next_upstream error timeout invalid_header http_500 http_502 http_503;
}
```

```bash
sudo nginx -t
sudo systemctl reload nginx
```

---

## 预防措施

### 部署前检查清单

```bash
node --version                        # □ Node.js >= 18
ls -la data/                          # □ 数据库目录存在且有正确权限
cat .env | grep -v "^#" | grep -v "^$" # □ .env 已正确配置
npx prisma generate                    # □ Prisma Client 已生成
npx prisma migrate deploy              # □ 数据库迁移已执行
curl http://localhost:3000/api/health  # □ 健康检查通过
curl http://localhost:3000/api/settings # □ Settings 接口正常
```

### 定期备份

```bash
# crontab -e，每天凌晨 2 点备份
0 2 * * * cp /path/to/kec-manager/server/data/kec.db /backup/kec_$(date +\%Y\%m\%d).db
```

---

## 常见问题 FAQ

### Q: 为什么本地开发正常，生产环境报错？

生产环境的数据库路径、文件权限、环境变量可能与本地不同。

### Q: SQLite 和 MySQL 哪个更适合生产环境？

- **SQLite**：适合小型部署（< 1000 用户），单文件，易备份
- **MySQL**：适合中大型部署，支持并发，更稳定

### Q: 数据库被锁定怎么办？

```bash
lsof data/kec.db       # 检查是否有多个进程访问
pm2 restart kec-server # 重启释放锁
# 考虑切换到 MySQL 以支持更高并发
```

---

**最后更新**: 2026-06-13
**相关修复**: settings.routes.js 错误处理增强
