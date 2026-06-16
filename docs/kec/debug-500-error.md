# 紧急调试：/api/settings 500 错误

## 当前状态

- ✅ 诊断脚本通过（数据库和设置都正常）
- ❌ 前端访问仍然返回 500 错误
- 📍 问题定位：后端服务层面

## 立即执行的诊断步骤

### 1. 检查 PM2 服务状态和日志

```bash
# 查看服务状态
pm2 status

# 查看详细错误日志（最重要！）
pm2 logs kec-server --err --lines 100

# 实时监听日志
pm2 logs kec-server --lines 0
```

**关键信息查找：**
- `[Settings GET Error]` - 我们添加的错误日志
- 具体的错误消息和堆栈跟踪
- Prisma 相关错误

### 2. 直接测试后端接口

```bash
# 在服务器上直接测试（绕过 Nginx）
curl http://localhost:3000/api/settings -v

# 检查响应头和完整响应
curl http://localhost:3000/api/settings -i
```

**期望结果：**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "organization_name": {"value": "欢迎回来", ...},
    "current_semester": {"value": "2025-2026-2", ...}
  }
}
```

**如果仍然 500：**
```bash
# 查看完整的错误响应
curl http://localhost:3000/api/settings 2>&1 | cat -v
```

### 3. 检查代码是否已更新

```bash
# 确认 settings.routes.js 包含最新的错误处理
cd /opt/1panel/www/sites/kec/index/kec-manager/server
git log --oneline -5

# 检查文件内容是否包含新的错误处理代码
grep -A 5 "Settings GET Error Stack" src/routes/settings.routes.js
```

如果没有输出，说明代码未更新，需要：
```bash
git pull
pm2 restart kec-server
```

### 4. 强制重启服务

```bash
# 完全停止并重启
pm2 stop kec-server
pm2 delete kec-server
pm2 start src/server.js --name kec-server
pm2 save

# 等待 5 秒后检查
sleep 5
pm2 logs kec-server --lines 20
```

### 5. 检查 Nginx 配置

```bash
# 测试 Nginx 配置
sudo nginx -t

# 查看 Nginx 错误日志
sudo tail -f /var/log/nginx/error.log

# 重载 Nginx
sudo systemctl reload nginx
```

## 可能的原因和解决方案

### 原因 1：PM2 缓存了旧代码

**症状：** `git log` 显示最新提交，但错误仍然存在

**解决：**
```bash
pm2 delete kec-server
cd /opt/1panel/www/sites/kec/index/kec-manager/server
pm2 start src/server.js --name kec-server
pm2 save
```

### 原因 2：Prisma Client 版本不匹配

**症状：** 日志中出现 Prisma 相关错误

**解决：**
```bash
cd /opt/1panel/www/sites/kec/index/kec-manager/server
npx prisma generate
pm2 restart kec-server
```

### 原因 3：环境变量未加载

**症状：** 日志中出现 `DATABASE_URL is not defined` 或类似错误

**解决：**
```bash
# 检查 .env 文件
cat /opt/1panel/www/sites/kec/index/kec-manager/server/.env | grep DATABASE_URL

# 如果缺失，重新创建
cp /opt/1panel/www/sites/kec/index/kec-manager/server/.env.production.example \
   /opt/1panel/www/sites/kec/index/kec-manager/server/.env

# 编辑配置文件
vim /opt/1panel/www/sites/kec/index/kec-manager/server/.env

# 重启服务
pm2 restart kec-server
```

### 原因 4：端口被占用

**症状：** PM2 日志中出现 `EADDRINUSE` 错误

**解决：**
```bash
# 查找占用 3000 端口的进程
lsof -i :3000

# 杀死旧进程
kill -9 <PID>

# 重新启动
pm2 start src/server.js --name kec-server
```

### 原因 5：数据库文件权限问题

**症状：** 日志中出现 `SQLITE_CANTOPEN` 或 `permission denied`

**解决：**
```bash
cd /opt/1panel/www/sites/kec/index/kec-manager/server
chown -R $(whoami):$(whoami) data/
chmod 755 data/
chmod 644 data/kec.db
pm2 restart kec-server
```

## 快速诊断脚本

创建临时诊断脚本 `/tmp/quick-check.sh`：

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

## 终极解决方案（如果以上都无效）

```bash
# 1. 完全重置服务
cd /opt/1panel/www/sites/kec/index/kec-manager
pm2 stop kec-server
pm2 delete kec-server

# 2. 清理 node_modules 并重新安装
cd server
rm -rf node_modules
npm install --production

# 3. 重新生成 Prisma Client
npx prisma generate

# 4. 初始化设置
npm run init:settings

# 5. 启动服务
pm2 start src/server.js --name kec-server
pm2 save

# 6. 验证
sleep 3
pm2 logs kec-server --lines 30
curl http://localhost:3000/api/settings
```

## 联系支持

如果执行完以上步骤仍然失败，请提供：

1. `pm2 logs kec-server --err --lines 100` 的完整输出
2. `curl http://localhost:3000/api/settings -v` 的完整输出
3. `cat /opt/1panel/www/sites/kec/index/kec-manager/server/.env | grep -v "^#" | grep -v "^$"`
4. Node.js 版本：`node -v`
5. PM2 版本：`pm2 -v`
