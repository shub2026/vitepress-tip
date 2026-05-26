# Gitee Go 流水线 + 1Panel 部署配置指南

本文档详细介绍从**代码推送 → Gitee Go 自动构建 → 服务器自动拉取部署**的完整流程。适用于本项目（基于 VitePress 的知识分享站点 `sntip.cn`）。

## 一、架构概览

```
本地推送 main 分支
       ↓
Gitee 仓库收到推送
       ├──→ Gitee Go 流水线构建（CI：编译验证）
       └──→ Webhook → 服务器（CD：拉取代码 + 构建 + 更新站点）
```

| 组件 | 作用 | 配置位置 |
|------|------|----------|
| Gitee Go | 代码推送后自动构建，验证编译是否通过 | `.workflow/main-pipeline.yml` |
| Gitee Webhook | 推送后通知服务器执行部署脚本 | Gitee 仓库 Webhook 设置 |
| 1Panel 计划任务 | 服务器定时拉取并构建 | 1Panel 后台 → 计划任务 |

## 二、Gitee 端配置

### 2.1 开通 Gitee Go

1. 进入 Gitee 仓库页面
2. 点击顶部菜单 **服务 → Gitee Go**
3. 首次使用点击 **开通 Gitee Go**，按提示授权
4. 选择 **免费版** 即可满足 VitePress 构建需求

### 2.2 确认流水线文件

本项目已配置好流水线文件 `.workflow/main-pipeline.yml`，核心内容：

```yaml
version: '1.0'
name: main-pipeline
displayName: main-pipeline
triggers:
  trigger: auto
  push:
    branches:
      prefix:
        - ''
stages:
  - name: stage-build
    displayName: 构建
    strategy: naturally
    trigger: auto
    steps:
      - step: build@nodejs
        name: build-nodejs
        displayName: Nodejs 构建
        nodeVersion: 20.18.0
        commands:
          - npm config set registry https://registry.npmmirror.com
          - npm install && npm run docs:build
        artifacts:
          - name: BUILD_ARTIFACT
            path:
              - docs/.vitepress/dist
        caches:
          - ~/.npm
```

**要点说明：**
- 推送任意分支（`prefix: ''`）均会触发构建
- 使用 **Node.js 20.18.0**（LTS 版本，兼容性好）
- 设置国内 npm 镜像源加速依赖安装
- 构建产物为 `docs/.vitepress/dist`
- 缓存 `~/.npm` 避免重复下载依赖

### 2.3 触发流水线验证

1. 前往 **服务 → Gitee Go → 流水线**
2. 应能看到 `main-pipeline` 流水线
3. 本地推送一次代码到 `main` 分支，检查流水线是否自动触发
4. 点击流水线名称可查看**实时构建日志**

### 2.4 配置 Webhook（通知服务器）

Gitee Go 负责 CI 验证，实际部署还需配置 Webhook 通知服务器拉取代码：

1. 进入 Gitee 仓库 → **管理 → WebHooks**
2. 点击 **添加 WebHook**
3. 填写以下信息：

| 字段 | 值 |
|------|-----|
| **URL** | `http://你的服务器IP:端口/webhook`（需服务器端监听） |
| **密码/密钥** | 自定义一个密钥（如 `mypassword123`），服务器端验证用 |
| **触发事件** | 勾选 **Push** 即可 |

4. 点击 **添加**

> 服务器端需要部署一个 Webhook 接收服务，可参考下方第三节的 PHP 接收脚本。

## 三、服务器端配置（1Panel）

### 3.1 服务器环境准备

通过 SSH 登录服务器，确保已安装以下环境：

```sh
# 检查 Git
node --version  # 需 >= 18
npm --version
```

如未安装，以 CentOS/RHEL 为例：

```sh
yum install -y git
```

Node.js 推荐通过 nvm 安装（方便切换版本）：

```sh
# 安装 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc

# 安装 Node.js 20 LTS
nvm install 20
nvm use 20
node --version  # 确认输出 v20.x
```

### 3.2 克隆项目到服务器

```sh
# 创建目录
mkdir -p /opt/1panel/www/sites/sntip/index
cd /opt/1panel/www/sites/sntip/index

# 克隆仓库
git clone https://gitee.com/你的用户名/vitepress-tip.git
cd vitepress-tip

# 安装依赖并首次构建
npm install
npm run docs:build
```

构建完成后，记下 `docs/.vitepress/dist` 的完整路径。

### 3.3 1Panel 创建网站

1. 登录 1Panel 后台 → **网站** → **创建网站**
2. 选择 **静态网站**
3. 配置：

| 配置项 | 值 |
|--------|-----|
| 主域名 | `doc.sntip.cn`（你的域名） |
| 根目录 | `/opt/1panel/www/sites/sntip/index/vitepress-tip/docs/.vitepress/dist` |

4. 点击 **确认** 创建

### 3.4 配置伪静态（SPA 路由支持）

VitePress 是 SPA 应用，直接访问子路径会 404，需配置伪静态规则：

1. 在 1Panel 网站列表中找到刚创建的网站 → **设置 → 伪静态**
2. 填入以下规则并保存：

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

### 3.5 配置 Webhook 接收服务

在服务器上创建一个 PHP 脚本作为 Webhook 接收端点（需服务器已安装 PHP 和 Nginx）：

创建文件 `/opt/1panel/www/sites/sntip/index/webhook/deploy.php`：

```php
<?php
// Gitee Webhook 部署触发脚本

$secret = 'mypassword123'; // 与 Gitee Webhook 设置的密钥一致

// 获取请求内容
$payload = file_get_contents('php://input');
$signature = $_SERVER['HTTP_X_GITEE_TOKEN'] ?? '';

// 验证密钥
if ($signature !== $secret) {
    http_response_code(403);
    die('Forbidden: token mismatch');
}

// 执行部署脚本（后台运行，避免超时）
exec('nohup bash /opt/1panel/www/sites/sntip/index/deploy.sh > /tmp/deploy.log 2>&1 &');

echo 'Deploy triggered successfully';
```

> 如果你不想用 PHP，也可以使用 Node.js 的 `express` 搭建轻量级 Webhook 服务，原理相同。

### 3.6 创建部署脚本

创建 `/opt/1panel/www/sites/sntip/index/deploy.sh`：

```sh
#!/bin/bash
# VitePress 自动部署脚本

PROJECT_DIR="/opt/1panel/www/sites/sntip/index/vitepress-tip"

cd "$PROJECT_DIR" || exit 1

# 拉取最新代码
git fetch origin
git reset --hard origin/main

# 安装依赖并构建
npm install
npm run docs:build

echo "$(date): Deploy completed"
```

赋予执行权限：

```sh
chmod +x /opt/1panel/www/sites/sntip/index/deploy.sh
```

### 3.7 配置 1Panel 计划任务（可选）

如果不想配置 Webhook，也可以用 1Panel 的计划任务定期拉取更新：

1. 进入 1Panel **计划任务** → **创建计划任务**
2. 任务类型：**Shell 脚本**
3. 名称：`更新VitePress站点`
4. 执行周期：建议 **每天一次**（如凌晨 3:00），或 **每 30 分钟** 测试用
5. 脚本内容：粘贴上述 `deploy.sh` 内容
6. 点击 **执行** 手动测试一次

### 3.8 配置 SSL 证书（HTTPS）

1. 在 1Panel **网站 → 设置 → HTTPS**
2. 点击 **申请证书 → Let's Encrypt**
3. 选择域名 `doc.sntip.cn`，自动申请并配置
4. 开启 **强制 HTTPS** 跳转

## 四、完整发布流程验证

完成以上配置后，发布新文章的完整流程：

```sh
# 本地编辑文章后
cd vitepress-tip
git add .
git commit -m "新增部署配置指南"
git push origin main
```

自动化链路：

```
git push
  ↓
① Gitee Go 自动构建（CI，查看是否编译通过）
  ↓
② Gitee Webhook → 服务器（CD）
  ↓
③ 服务器拉取代码 → 构建 → 更新站点
  ↓
④ 访问 https://doc.sntip.cn 查看更新
```

## 五、常见问题

### Q1：Gitee Go 构建失败？

检查 `.workflow/main-pipeline.yml`：
- `nodeVersion` 是否为 `20.18.0` 或以上
- `artifacts.path` 是否正确指向 `docs/.vitepress/dist`
- 构建日志中是否有 npm 安装错误

### Q2：Webhook 没触发服务器更新？

```sh
# 在服务器上检查 Webhook 服务是否运行
# 查看部署日志
tail -f /tmp/deploy.log

# 手动测试部署脚本
bash /opt/1panel/www/sites/sntip/index/deploy.sh
```

### Q3：网站访问 404？

- 确认 1Panel 网站根目录是否指向 `docs/.vitepress/dist`
- 确认伪静态规则已配置
- 确认 SSL 证书已正确配置

### Q4：权限不足（Permission denied）？

1Panel 容器以 uid 1000 运行，如果站点目录在其他路径，可调整目录权限：

```sh
chown -R 1000:1000 /opt/1panel/www/sites/sntip/index/vitepress-tip
```

## 六、参考链接

- [Gitee Go 官方文档](https://gitee.com/help/articles/4311)
- [Gitee WebHook 配置指南](https://gitee.com/help/articles/4336)
- [VitePress 部署文档](https://vitepress.dev/zh/guide/deploy)
- [1Panel 部署](./1panel-deploy)
- [1Panel 自动拉取脚本](./1panel-script)
