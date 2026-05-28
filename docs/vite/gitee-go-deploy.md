# Gitee Go 流水线部署配置指南

本文档介绍从**代码推送 → Gitee Go 自动构建 → 服务器自动部署**的完整流程。
适用于本项目（基于 VitePress 的知识分享站点）。

---

## 一、部署架构

部署分**两条路径**，共用同一个目标目录 `/opt/wwwroot`：

```
                         推送 main 分支
                              │
              ┌───────────────┴───────────────┐
              ▼                               ▼
     ┌─────────────────┐            ┌──────────────────┐
     │  Gitee Go 流水线 │           │   deploy.sh      │
     │  (主线·全自动)   │            │   (备用·按需)     │
     └────────┬────────┘            └────────┬─────────┘
              │                              │
    ┌─────────┼─────────┐          ┌────────┼─────────┐
    │ ① npm ci         │          │ 手动    │ 定时    │ Webhook
    │ ② docs:build     │          │ SSH执行 │ 1Panel  │ 触发
    │ ③ tar 打包       │           │        │ 计划任务 │
    │ ④ 上传制品       │           └────────┼─────────┘
    │ ⑤ deploy@agent   │                   │
    │    → /opt/wwwroot │                  │
    └──────────────────┘                   │
              │                            │
              └───────────┬────────────────┘
                          ▼
                  ┌──────────────┐
                  │ /opt/wwwroot │  ← 站点根目录（唯一）
                  └──────┬───────┘
                         ▼
                  ┌──────────────┐
                  │ Nginx/1Panel │  ← 对外提供服务
                  └──────────────┘
```

| 路径 | 触发方式 | 适用场景 | 配置文件 |
|------|---------|---------|---------|
| **Gitee Go 流水线**（主线） | 推送 `main` 自动触发 | 日常发布，零人工介入 | `.workflow/main-pipeline.yml` |
| **deploy.sh**（备用） | SSH 手动 / 定时任务 / Webhook | 故障修复、预检查、离线构建 | `deploy.sh`（服务器上） |

---

## 二、主线：Gitee Go 流水线

### 2.1 开通 Gitee Go

1. 进入 Gitee 仓库 → **服务 → Gitee Go**
2. 首次使用点击 **开通 Gitee Go**，按提示授权
3. 免费版即可满足 VitePress 构建需求

### 2.2 添加自有主机

Gitee Go 需要将构建产物推送到你的服务器，先添加主机：

1. Gitee Go 后台 → **主机管理** → **添加主机**
2. 按提示在服务器上执行安装命令，注册为自有主机
3. 记下生成的主机组 ID，替换流水线文件中的 `my-server`

> 每组主机有一个唯一 ID。如果只有一台服务器，主机组里放一台即可。

### 2.3 流水线配置

流水线文件位于 `.workflow/main-gitee.yml`，推送 `main` 分支后自动运行四个步骤：

```yaml
# .workflow/main-gitee.yml（精简版）
triggers:
  push:
    branches:
      prefix: [main]           # ← 只响应 main 分支推送

steps:
  build@nodejs                 # ① Node.js 20 构建 → 打包 output.tar.gz
  publish@general_artifacts    # ② 上传制品到 Gitee 制品库
  publish@release_artifacts    # ③ 发布版本（版本号自动 +1）
  deploy@agent                 # ④ 主机部署 → 解压到 /opt/wwwroot
```

**四个步骤做了什么：**

| 步骤 | 执行内容 |
|------|---------|
| `build@nodejs` | `npm ci` → `npm run docs:build` → `tar -czf output.tar.gz` |
| `publish@general_artifacts` | 制品上传到 Gitee 仓库，留存可追溯 |
| `publish@release_artifacts` | 生成带版本号的 Release，方便回滚 |
| `deploy@agent` | 下载最新制品 → 清空 `/opt/wwwroot` → 解压 → `chmod 755` |

### 2.4 修改主机组 ID

将 `my-server` 替换为你实际的主机组 ID：

```yaml
# 需要改这一处
- step: deploy@agent
  hostGroupID:
    ID: my-server    # ← 改为你在 Gitee Go 后台看到的主机组 ID
```

> **不需要**配置 Webhook——Gitee Go 流水线已经是全自动的，`deploy@agent` 步骤直接把制品推到服务器。

### 2.5 验证流水线

1. **Gitee Go → 流水线**，应能看到 `知行笔记 - 主流水线`
2. 推送代码到 `main` 分支，观察是否自动触发
3. 点击运行记录可查看实时日志，四个步骤全部绿色即为成功

---

## 三、服务器端初始化（一次性）

以下操作在服务器上执行，只需做一次。

### 3.1 环境要求

```sh
node --version   # 需要 >= 18（Gitee Go 流水线构建不需要，但 deploy.sh 需要）
git --version    # 需要已安装
```

如果没有 Node.js，用 nvm 安装：

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 20
nvm use 20
```

### 3.2 克隆项目

```sh
cd /opt
git clone https://gitee.com/shub77/vitepress-tip.git
```

### 3.3 确保目标目录存在

```sh
mkdir -p /opt/wwwroot
```

**注意**：不需要手动构建。Gitee Go 流水线第一次跑完就会自动把内容部署到 `/opt/wwwroot`。

---

## 四、Nginx / 1Panel 站点配置

### 4.1 1Panel 方式

1. **网站 → 创建网站 → 静态网站**
2. 配置：

| 配置项 | 值 |
|--------|-----|
| 主域名 | 你的域名 |
| 根目录 | `/opt/wwwroot` |

3. **设置 → 伪静态**，填入 SPA 路由规则：

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

4. **设置 → HTTPS → 申请证书**（Let's Encrypt），开启强制 HTTPS

### 4.2 原生 Nginx 方式

```nginx
server {
    listen       80;
    server_name  你的域名;
    root         /opt/wwwroot;
    index        index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 五、备用方案：deploy.sh

### 5.1 脚本位置

项目根目录的 `deploy.sh` 已随仓库克隆到服务器的 `/opt/vitepress-tip/deploy.sh`。

### 5.2 三种模式

| 命令 | 做什么 | 什么时候用 |
|------|--------|-----------|
| `bash deploy.sh` | 完整部署：拉取 → 构建 → 覆盖 `/opt/wwwroot`，旧版自动备份 | 流水线挂了手动救急 |
| `bash deploy.sh --pull` | 只拉取 + 构建，不动 `/opt/wwwroot` | 推送前本地验证是否能编译通过 |
| `bash deploy.sh --quick` | 直接解压 Gitee Go 已下载的制品到 `/opt/wwwroot` | 制品已到服务器但解压失败，补刀 |

### 5.3 每次部署自动备份

完整模式执行时，如果 `/opt/wwwroot` 已有内容，脚本会自动备份到：

```
/opt/wwwroot_backup_20250527_223000/
```

### 5.4 搭配 1Panel 计划任务

1. 1Panel → **计划任务 → 创建计划任务**
2. 类型：**Shell 脚本**
3. 名称：`更新VitePress站点`
4. 执行周期：每天一次（如凌晨 3:00）
5. 脚本：`bash /opt/vitepress-tip/deploy.sh`

> 定时任务 + Gitee Go 流水线可以并存。流水线负责实时发布，定时任务兜底确保状态一致。

### 5.5 搭配 Webhook（可选）

如果不想依赖 Gitee Go，可以用 Gitee Webhook + deploy.sh 实现轻量级自动部署。

**1. Gitee 端：管理 → WebHooks → 添加**

| 字段 | 值 |
|------|-----|
| URL | `http://你的服务器IP:9000/hook` |
| 密码 | 自定义（如 `abc123`） |
| 事件 | Push |

**2. 服务器端：用 Node.js 起一个极简 Webhook 服务**

```js
// webhook.js —— 复制到服务器 /opt/vitepress-tip/ 目录
const http = require('http');
const { exec } = require('child_process');
const SECRET = 'abc123'; // 和 Gitee Webhook 密码一致

http.createServer((req, res) => {
  if (req.method === 'POST' && req.url === '/hook') {
    const token = req.headers['x-gitee-token'] || '';
    if (token !== SECRET) { res.writeHead(403); return res.end('Forbidden'); }

    exec('nohup bash /opt/vitepress-tip/deploy.sh > /tmp/deploy.log 2>&1 &');
    res.end('OK');
  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
}).listen(9000, () => console.log('Webhook listening on :9000'));
```

```sh
# 服务器上启动
node /opt/vitepress-tip/webhook.js &

# 或配合 PM2 保持常驻
pm2 start /opt/vitepress-tip/webhook.js --name vitepress-webhook
```

---

## 六、日常发布流程

### 正常流程（推荐）

```sh
# 本地编辑文章
git add .
git commit -m "更新文章"
git push origin main
```

之后的环节全自动：

```
push main → Gitee Go 触发 → 构建 → 上传制品 → 部署到 /opt/wwwroot → 网站更新
```

全程约 1~2 分钟，无需登录服务器。

### 手动兜底

如果流水线异常，SSH 到服务器执行：

```sh
bash /opt/vitepress-tip/deploy.sh
```

---

## 七、常见问题

### Q1：Gitee Go 构建失败？

进入 Gitee Go 查看构建日志，常见原因：

- 新增了依赖但 `package.json` 没提交
- Markdown 中有语法错误导致 VitePress 编译失败
- 网络问题导致 npm install 超时

### Q2：流水线构建成功但网站没更新？

- 检查 `deploy@agent` 步骤是否执行成功（绿色）
- SSH 到服务器确认：`ls /opt/wwwroot/index.html` 是否存在
- 确认 Nginx/1Panel 根目录指向 `/opt/wwwroot`

### Q3：网站子路径访问 404？

确认伪静态规则已配置（第四章），VitePress 是 SPA，需要 `try_files` 规则。

### Q4：权限不足（Permission denied）？

```sh
chown -R 1000:1000 /opt/wwwroot
```

如果 1Panel 以不同用户运行，调整对应的 uid/gid。

### Q5：deploy.sh 报 git 认证失败？

服务器的 Git 没有配置 Gitee 凭据。改用 SSH 方式克隆：

```sh
cd /opt/vitepress-tip
git remote set-url origin git@gitee.com:shub77/vitepress-tip.git
```

前提是服务器上已配置好 SSH Key 并添加到 Gitee。

---

## 八、参考链接

- [Gitee Go 官方文档](https://gitee.com/help/articles/4311)
- [Gitee WebHook 配置指南](https://gitee.com/help/articles/4336)
- [VitePress 部署文档](https://vitepress.dev/zh/guide/deploy)
