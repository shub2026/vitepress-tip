# 知行笔记

基于 VitePress 的极简风格知识分享平台，知行合一，止于至善。

> 线上地址：[https://sntip.cn](https://sntip.cn)

## 特性

- 📝 完全基于 Markdown，专注内容创作
- ⚡ 极速开发与构建（VitePress 1.6+）
- 🎨 极简风格设计，支持深色模式
- 📱 响应式布局，兼容移动端
- 🔍 内置本地全文搜索
- 🗺️ Mermaid 流程图支持
- 🕐 文章最后更新时间显示
- 🗂️ 自动生成 Sitemap

## 快速开始

**环境要求：** Node.js >= 18

```sh
# 克隆项目
git clone https://gitee.com/shub77/vitepress-tip.git
cd vitepress-tip

# 安装依赖
npm install

# 启动开发服务器
npm run docs:dev
```

## 常用命令

| 命令 | 说明 |
|---|---|
| `npm run docs:dev` | 启动开发服务器 |
| `npm run docs:build` | 构建生产版本 |
| `npm run docs:preview` | 本地预览构建产物 |
| `npm run format` | Prettier 格式化文档 |

## 项目结构

```
vitepress-tip/
├── docs/
│   ├── .vitepress/
│   │   ├── components/         # 自定义 Vue 组件
│   │   │   └── BookmarkNav.vue
│   │   ├── config.ts           # 站点配置（导航、侧边栏、SEO 等）
│   │   └── theme/              # 自定义主题
│   │       ├── index.ts        # 主题入口
│   │       └── style/          # 自定义样式
│   │           ├── var.css         # 品牌色 & 渐变色变量
│   │           ├── hero.css        # 首页 Hero 布局
│   │           ├── blockquote.css  # 引用块样式
│   │           └── custom-block.css# 提示容器样式（7 种类型）
│   ├── vite/                   # 构建指南文章
│   ├── AI_about/               # AI 应用指南
│   ├── other/                  # 其他文章
│   ├── public/                 # 静态资源（图片、图标）
│   ├── bookmarks.md            # 书签页
│   └── index.md                # 首页
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions 部署配置
├── .editorconfig
├── .prettierrc
└── package.json
```

## 添加内容

在对应目录下新建 `.md` 文件，再到 `docs/.vitepress/config.ts` 的 `sidebar` 中添加对应条目即可。

| 目录 | 用途 |
|---|---|
| `docs/vite/` | 构建指南 |
| `docs/AI_about/` | AI 应用指南 |
| `docs/other/` | 其他内容 |

## 部署

### 自动部署（Gitee Go）

推送 `main` 分支自动触发 VitePress 构建 → 通过 WebHook 部署到服务器。

流水线配置：`.workflow/main-gitee.yml`

```
构建(Node 25.4) → git pull 检测更新 → 构建 dist → WebHook 触发部署脚本
```

### 手动构建

```sh
npm run docs:build
```

构建产物位于 `docs/.vitepress/dist`，可部署到任意静态托管服务（Vercel、Netlify、GitHub Pages、1Panel 等）。

## License

[MIT](LICENSE)
