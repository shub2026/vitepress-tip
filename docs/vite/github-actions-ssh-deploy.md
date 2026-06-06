# GitHub Actions + SSH 自动部署 VitePress 到服务器

本文详细介绍如何配置 GitHub Actions，实现 VitePress 项目自动构建并部署到服务器。

## 整体流程

```
本地推送代码 → GitHub Actions 触发 → 构建 VitePress → SSH 连接服务器 → 部署到目标目录
```

## 前置准备

- GitHub 仓库（存放 VitePress 源码）
- 服务器（安装 Web 服务器，如 Nginx/1Panel）
- 服务器 IP、SSH 端口、用户名、密码/密钥

## 步骤一：生成 SSH 密钥对（核心步骤）

SSH 密钥是实现无密码登录的核心，GitHub Actions 使用私钥连接服务器。

### 1.1 在本地机器生成密钥对

```bash
# 生成 ED25519 算法密钥（推荐）
ssh-keygen -t ed25519 -C "github-actions@deploy"

# 或者使用 RSA 算法（兼容性更好）
ssh-keygen -t rsa -b 4096 -C "github-actions@deploy"
```

**交互提示说明：**

- `Enter file in which to save the key`：输入保存路径，如 `/home/user/.ssh/github_actions`
- `Enter passphrase`：**留空**（GitHub Actions 无法输入密码）
- `Enter same passphrase again`：确认留空

### 1.2 查看生成的密钥

```bash
ls -la ~/.ssh/github_actions*
# 输出：
# ~/.ssh/github_actions      # 私钥（放在 GitHub Secrets）
# ~/.ssh/github_actions.pub  # 公钥（放到服务器）
```

### 1.3 将公钥添加到服务器

**方法 A：使用 ssh-copy-id（推荐）**

```bash
ssh-copy-id -i ~/.ssh/github_actions.pub user@server_ip
```

**方法 B：手动添加**

```bash
# 1. 查看公钥内容
cat ~/.ssh/github_actions.pub

# 2. 登录服务器
ssh user@server_ip

# 3. 将公钥内容追加到 ~/.ssh/authorized_keys
echo "ssh-ed25519 AAAA... github-actions@deploy" >> ~/.ssh/authorized_keys

# 4. 设置正确权限
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### 1.4 测试 SSH 密钥登录

```bash
ssh -i ~/.ssh/github_actions user@server_ip
# 如果能直接登录，说明密钥配置成功
```

## 步骤二：配置 GitHub Secrets

将敏感信息存储在 GitHub Secrets 中，避免明文暴露。

### 2.1 进入仓库设置

1. 访问 GitHub 仓库页面
2. 点击 `Settings` → `Secrets and variables` → `Actions`
3. 点击 `New repository secret`

### 2.2 添加以下 Secrets

| Name              | Value            | 说明                               |
| ----------------- | ---------------- | ---------------------------------- |
| `SSH_HOST`        | `your_server_ip` | 服务器 IP 或域名                   |
| `SSH_PRIVATE_KEY` | 私钥内容         | `~/.ssh/github_actions` 的全部内容 |

### 2.3 获取私钥内容

```bash
cat ~/.ssh/github_actions
# 复制全部内容（包括 -----BEGIN/END-----）
```

**注意：**

- 私钥内容要原样复制，不要添加额外空格或换行
- `-----BEGIN OPENSSH PRIVATE KEY-----` 和 `-----END OPENSSH PRIVATE KEY-----` 必须包含

## 步骤三：创建 GitHub Actions 工作流

在项目中创建 `.github/workflows/deploy.yml`。

### 3.1 创建工作流文件

```bash
mkdir -p .github/workflows
touch .github/workflows/deploy.yml
```

### 3.2 本项目实际工作流配置

以下是对齐本项目 `.github/workflows/deploy.yml` 的实际配置：

```yaml
name: Deploy to Server

# 触发条件：推送到 main 分支，或手动触发
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      # 1. 检出代码
      - name: Checkout
        uses: actions/checkout@v4

      # 2. 设置 Node.js（版本与本地开发一致）
      - name: Setup Node
        uses: actions/setup-node@v5
        with:
          node-version: 22
          cache: 'npm'

      # 3. 安装依赖
      - name: Install dependencies
        run: npm install

      # 4. 构建 VitePress
      - name: Build VitePress
        run: npm run docs:build

      # 5. 通过 SSH 部署到服务器（使用 ssh-deploy Action）
      - name: Deploy to Server
        uses: easingthemes/ssh-deploy@main
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          ARGS: '-rlgoDzvc -i --delete'
          SOURCE: 'docs/.vitepress/dist/'
          REMOTE_HOST: ${{ secrets.SSH_HOST }}
          REMOTE_USER: root
          TARGET: '/opt/1panel/www/sites/sntip/index/'
```

> **说明**：本项目使用 `easingthemes/ssh-deploy` 直接通过 SSH 将构建产物（`dist/`）同步到服务器，无需在服务器上安装 Node.js 或保留源码。

### 3.3本项目工作流优化配置v2

```yaml
name: Deploy to My Server

on:
  push:
    branches: [main]
  workflow_dispatch:

# 防止并发部署导致服务器文件状态异常
concurrency:
  group: deploy-${{ github.ref }}
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      # 1. 拉取代码
      - name: Checkout
        uses: actions/checkout@v5

      # 2. 安装 Node.js 并配置缓存
      - name: Setup Node
        uses: actions/setup-node@v5
        with:
          node-version: 22
          cache: 'npm'
          cache-dependency-path: package-lock.json

      # 3. 安装依赖并构建
      - name: Install dependencies
        run: npm ci
      - name: Build VitePress
        run: npm run docs:build

      # 4. 上传构建产物，供部署 job 使用
      - name: Upload dist artifact
        uses: actions/upload-artifact@v7.0.1
        with:
          name: dist
          path: docs/.vitepress/dist/

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      # 下载构建产物
      - name: Download dist artifact
        uses: actions/download-artifact@v8.0.1
        with:
          name: dist
          path: dist/

      # 部署到服务器
      - name: Deploy to Server
        uses: easingthemes/ssh-deploy@v6.0.3
        with:
          SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
          ARGS: '-rlgoDzvc -i --delete'
          SOURCE: 'dist/'
          REMOTE_HOST: ${{ secrets.REMOTE_HOST }}
          REMOTE_USER: root
          TARGET: '/opt/1panel/www/sites/sntip/index/'
```

## 步骤四：配置 VitePress 项目

确保 `package.json` 中有构建脚本。

### 4.1 检查 package.json

```json
{
  "scripts": {
    "docs:dev": "vitepress dev docs",
    "docs:build": "vitepress build docs"
  }
}
```

### 4.2 测试本地构建

```bash
npm run docs:build
# 确认生成 docs/.vitepress/dist 目录
```

## 步骤五：提交并测试

### 5.1 提交工作流文件

```bash
git add .github/workflows/deploy.yml
git commit -m "ci: 添加 GitHub Actions 自动部署配置"
git push origin main
```

### 5.2 查看执行结果

1. 进入 GitHub 仓库
2. 点击 `Actions` 标签页
3. 查看工作流执行状态
4. 如果失败，点击具体任务查看日志

## 常见问题排查

### 问题 1：SSH 连接失败

**错误信息：** `Permission denied (publickey)`

**解决方法：**

- 检查私钥格式是否完整（包含 BEGIN/END）
- 确认公钥已正确添加到服务器的 `~/.ssh/authorized_keys`
- 确认服务器 SSH 端口是否正确
- 检查服务器防火墙是否允许 GitHub Actions IP

### 问题 2：权限不足

**错误信息：** `Permission denied`

**解决方法：**

```bash
# 在服务器上设置部署目录权限
sudo chown -R $USER:$USER /opt/1panel/www/sites/sntip/index
chmod 755 /opt/1panel/www/sites/sntip/index
```

### 问题 3：Node.js 版本不匹配

**解决方法：**
在 `actions/setup-node@v5` 中指定正确的 Node.js 版本：

```yaml
with:
  node-version: '22' # 与本地开发版本一致
```

### 问题 4：构建产物路径错误

**解决方法：**
确认 VitePress 构建输出目录：

```yaml
path: docs/.vitepress/dist/ # 默认路径
# 或检查 vite.config.ts 中的 outDir 配置
```

## 安全建议

1. **使用 deploy keys**：为服务器创建专门的部署用户，不要用 root
2. **限制 IP 访问**：在服务器防火墙中限制 SSH 访问来源
3. **定期轮换密钥**：每隔 3-6 个月更换 SSH 密钥
4. **启用审计日志**：记录部署操作，便于追溯

## 总结

通过以上配置，每次 `git push` 到 `main` 分支后，GitHub Actions 会自动：

1. 检出代码
2. 安装依赖（Node.js 22）
3. 构建 VitePress 站点
4. 通过 `easingthemes/ssh-deploy` 将 `dist/` 同步到服务器 `/opt/1panel/www/sites/sntip/index/`

构建和部署全部在 GitHub Actions 云端完成，服务器只需运行 Web 服务（如 Nginx/1Panel），无需安装 Node.js。

## 参考链接

- [GitHub Actions 官方文档](https://docs.github.com/en/actions)
- [VitePress 部署指南](https://vitepress.dev/guide/deployment)
- [SSH 密钥管理](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
