# 1Panel自动拉取执行脚本

## 配置计划任务步骤

1. 在1Panel后台进入【计划任务】页面
2. 点击【创建计划任务】
3. 任务类型：选择 Shell脚本
4. 任务名称：自定义（如 "更新VitePress站点"）
5. 执行周期：根据需求选择，建议：

- 生产环境：每天一次（凌晨低峰期）
- 测试环境：每30分钟或手动执行

6. 脚本内容：粘贴优化后的完整脚本
7. 首次可点击【执行】按钮手动测试

:::tip 注意事项

- SSH密钥：确保服务器已配置Gitee的部署公钥，否则 git pull 会失败
- Node.js版本：VitePress 1.0要求Node.js 18及以上版本
- 构建输出：确保网站根目录指向构建后的 `docs/.vitepress/dist` 目录
  :::

## 脚本代码
简要脚本，只执行**拉取 → 构建**两个环节，减少其他干扰

```sh
#!/bin/bash
# VitePress站点自动更新脚本

echo "=== VitePress站点自动更新开始 ==="
date

# 切换到项目目录
cd /opt/1panel/www/sites/sntip/index/vitepress-tip || {
  echo "错误：项目目录不存在"
  exit 1
}

# 拉取最新代码
echo "正在拉取最新代码..."
git pull origin main
if [ $? -ne 0 ]; then
  echo "错误：git pull 失败"
  exit 1
fi

# 检查 node 和 npm 是否可用
if ! command -v node &> /dev/null; then
  echo "错误：node 命令不可用"
  exit 1
fi
if ! command -v npm &> /dev/null; then
  echo "错误：npm 命令不可用"
  exit 1
fi

# 构建站点
echo "正在构建VitePress站点..."
npm run docs:build
if [ $? -ne 0 ]; then
  echo "错误：构建失败"
  exit 1
fi

echo "=== VitePress站点更新完成 ==="
date

```

## 脚本代码【优化】
常用脚本，设置5分钟自行执行脚本**拉取 → 检查更新 → 构建**

```sh
#!/bin/bash
# VitePress站点自动更新脚本

echo "=== VitePress站点自动更新开始 ==="
date

# 切换到项目目录
cd /opt/1panel/www/sites/sntip/index/vitepress-tip || {
  echo "错误：项目目录不存在"
  exit 1
}

# 拉取最新代码前，记录当前 commit
OLD_COMMIT=$(git rev-parse HEAD)

# 拉取最新代码
echo "正在拉取最新代码..."
git pull origin main
if [ $? -ne 0 ]; then
  echo "错误：git pull 失败"
  exit 1
fi

# 拉取后，检查是否有新提交
NEW_COMMIT=$(git rev-parse HEAD)
if [ "$OLD_COMMIT" = "$NEW_COMMIT" ]; then
  echo "已是最新，无更新，退出。"
  exit 0
fi

echo "检测到新更新，开始构建..."

# 加载 node 环境
# 优先尝试 nvm（兼容多种安装路径），找不到则直接用系统 node
NODE_BIN=""
NPM_BIN=""

# 尝试加载 nvm（按常见路径依次查找）
for NVM_TRY in "/root/.nvm" "$HOME/.nvm" "/usr/local/nvm"; do
  if [ -s "$NVM_TRY/nvm.sh" ]; then
    export NVM_DIR="$NVM_TRY"
    \. "$NVM_DIR/nvm.sh"
    echo "已加载 nvm：$NVM_DIR"
    break
  fi
done

# 查找 node/npm 绝对路径（兼容 nvm 和系统安装）
NODE_BIN=$(command -v node 2>/dev/null)
NPM_BIN=$(command -v npm 2>/dev/null)

# 如果 command -v 找不到，尝试常见系统路径
if [ -z "$NODE_BIN" ]; then
  for TRY in "/usr/bin/node" "/usr/local/bin/node" "/usr/local/nodejs/bin/node"; do
    if [ -x "$TRY" ]; then
      NODE_BIN="$TRY"
      break
    fi
  done
fi

if [ -z "$NPM_BIN" ]; then
  for TRY in "/usr/bin/npm" "/usr/local/bin/npm" "/usr/local/nodejs/bin/npm"; do
    if [ -x "$TRY" ]; then
      NPM_BIN="$TRY"
      break
    fi
  done
fi

if [ -z "$NODE_BIN" ]; then
  echo "错误：找不到 node，请确认服务器已安装 Node.js"
  exit 1
fi
if [ -z "$NPM_BIN" ]; then
  echo "错误：找不到 npm，请确认服务器已安装 npm"
  exit 1
fi

echo "使用 node：$NODE_BIN ($($NODE_BIN --version))"
echo "使用 npm：$NPM_BIN ($($NPM_BIN --version))"

# 构建站点
echo "正在构建VitePress站点..."
$NPM_BIN run docs:build
if [ $? -ne 0 ]; then
  echo "错误：构建失败"
  exit 1
fi

echo "=== VitePress站点更新完成 ==="
date


```
