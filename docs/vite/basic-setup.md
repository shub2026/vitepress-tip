# VitePress 构建基本命令

基于 `vitepress-tip` 项目的实际操作指南，涵盖从零搭建到日常开发的全流程。

---

## 环境要求

| 依赖 | 版本要求 | 检查命令 |
|------|----------|----------|
| Node.js | >= 18 | `node -v` |
| npm | 随 Node.js 自带 | `npm -v` |
| Git | 任意版本 | `git --version` |

---

## 一、克隆项目

```sh
# 从 GitHub 克隆
git clone https://github.com/shub2026/vitepress-tip.git
cd vitepress-tip
```

---

## 二、安装依赖

```sh
npm install
```

首次执行会安装以下核心依赖：

| 包 | 版本 | 用途 |
|---|------|------|
| `vitepress` | ^1.6.4 | 静态站点生成器 |
| `vue` | ^3.5.30 | 组件框架 |
| `mermaid` | ^11.13.0 | 图表渲染 |
| `vitepress-plugin-mermaid` | ^2.0.17 | Mermaid 集成插件 |
| `prettier` | ^3.3.0 | 代码格式化 |

---

## 三、开发命令

```sh
# 启动开发服务器（热更新，默认 http://localhost:5173）
npm run docs:dev

# 构建生产版本（输出到 docs/.vitepress/dist）
npm run docs:build

# 本地预览生产构建（默认 http://localhost:4173）
npm run docs:preview
```

| 命令 | 说明 | 端口 |
|------|------|------|
| `npm run docs:dev` | 开发模式，文件修改即时生效 | 5173 |
| `npm run docs:build` | 生产构建，输出静态文件 | — |
| `npm run docs:preview` | 预览构建产物，模拟生产环境 | 4173 |

---

## 四、辅助命令

```sh
# 代码格式化（Markdown、TypeScript、CSS）
npm run format

# TypeScript 类型检查
npm run type-check

# 清理构建缓存和产物
npm run clean
```

| 命令 | 说明 |
|------|------|
| `npm run format` | 使用 Prettier 格式化 `docs/` 下所有 `.md` `.ts` `.css` |
| `npm run type-check` | 基于 `tsconfig.json` 检查类型错误 |
| `npm run clean` | 删除 `dist` 和 `cache` 目录 |

---

## 五、添加新页面

1. 在对应目录下新建 `.md` 文件：

   ```
   docs/vite/新文档.md
   docs/linux/新笔记.md
   ```

2. 在 `docs/.vitepress/config.ts` 侧边栏中添加条目：

   ```ts
   { text: '新文档标题', link: '/vite/新文档' }
   ```

3. 启动开发服务器预览效果

---

## 六、日常开发流程

```sh
# 1. 拉取最新代码
git pull origin main

# 2. 启动开发服务器
npm run docs:dev

# 3. 编辑文档（浏览器实时预览）

# 4. 格式化代码
npm run format

# 5. 提交推送
git add .
git commit -m "docs: 更新说明"
git push origin main
```

---

## 七、项目结构速览

```
vitepress-tip/
├── docs/
│   ├── .vitepress/
│   │   ├── config.ts          # 站点配置（导航、侧边栏、SEO）
│   │   ├── theme/             # 自定义主题样式
│   │   └── dist/              # 构建产物（npm run docs:build 生成）
│   ├── vite/                  # 构建与部署指南
│   ├── AI_about/              # AI 应用指南
│   ├── linux/                 # Linux 学习笔记
│   ├── other/                 # 其他内容
│   └── index.md               # 首页
├── tsconfig.json              # TypeScript 配置
├── package.json               # 依赖与脚本
└── deploy-web-v2.sh           # 服务器部署脚本
```

---

## 八、常见问题

### Q: 构建失败，提示依赖缺失？

```sh
rm -rf node_modules package-lock.json
npm install
```

### Q: 开发服务器端口被占用？

```sh
# 指定其他端口
npx vitepress dev docs --port 3000
```

### Q: 构建后 chunk 大小警告？

项目已设置 `chunkSizeWarningLimit: 800KB`，超过此值会显示警告但不影响构建。Mermaid 等大型库会导致此警告，属正常现象。

### Q: 如何验证 TypeScript 配置是否正确？

```sh
npm run type-check
```
