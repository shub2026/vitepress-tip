#!/bin/bash
#========================================
# VitePress 自动化部署脚本
# 适用于 1Panel + Gitee Webhook
#========================================

set -e

# 配置
REPO_DIR="/opt/1panel/apps/vitepress/vitepress-tip"
WEB_DIR="/opt/1panel/apps/openresty/openresty/sites-enabled/vitepress"
BRANCH="main"

echo "========== 开始部署 =========="
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"

# 进入项目目录
cd "$REPO_DIR" || { echo "项目目录不存在"; exit 1; }

# 拉取最新代码
echo ">>> 拉取最新代码..."
git fetch origin
git reset --hard origin/$BRANCH

# 安装依赖
echo ">>> 安装依赖..."
npm install

# 构建项目
echo ">>> 构建项目..."
npm run docs:build

# 同步到Web目录
echo ">>> 同步到Web目录..."
rm -rf "$WEB_DIR"/*
cp -r docs/.vitepress/dist/* "$WEB_DIR/"

echo "========== 部署完成 =========="
