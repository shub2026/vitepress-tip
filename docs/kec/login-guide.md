# 登录指南

## 默认管理员账号

数据库初始化后，系统会自动创建默认管理员账号。

| 字段 | 值 |
|------|-----|
| 用户名 | `admin` |
| 密码 | `admin@123456` |
| 角色 | `super_admin`（超级管理员） |

> ⚠️ **生产环境首次登录后请立即修改密码！**

## 访问地址

| 环境 | 前端 | 后端 API |
|------|------|----------|
| 本地开发 | `http://localhost:5173` | `http://localhost:3000` |
| 生产环境 | 部署域名（如 `https://kec.sntip.cn`） | 同域名 `/api` 路径 |

## 忘记密码

### 方法 1：通过 Prisma Studio 修改

```bash
cd server
npx prisma studio
# 在浏览器中打开 users 表，修改 password 字段
```

### 方法 2：命令行重置

```bash
cd server
node -e "import('bcryptjs').then(b => b.default.hash('新密码', 12).then(h => console.log(h)))"
# 复制输出的哈希值，在 Prisma Studio 中更新 users 表的 password 字段
```

### 方法 3：重置数据库（会清空所有数据）

```bash
cd server
npm run db:seed:reset
```

## 常见问题

**Q: 登录提示"用户名或密码错误"？**

- 确认密码是 `admin@123456`（不是 `123456`）
- 确认数据库已初始化：`cd server && npm run db:seed`
- 确认后端服务正在运行：`pm2 status`

**Q: 登录页报 /api/settings 500 错误？**

```bash
cd server
npm run init:settings
pm2 restart kec-server
```

**Q: 登录报 /api/auth/login 500 错误？**

```bash
cd server
npm run db:seed
pm2 restart kec-server
```

> 更多故障排查见 [故障排查指南](/kec/troubleshooting)
