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
│   │   ├── config.ts          # 站点配置（导航、侧边栏等）
│   │   └── theme/             # 自定义主题
│   │       ├── index.ts
│   │       └── style/         # CSS 变量与自定义样式
│   ├── vite/                  # 构建指南文章
│   ├── AI_about/              # AI 提示词指南
│   ├── other/                 # 其他文章
│   ├── public/                # 静态资源（图片、图标）
│   └── index.md               # 首页
├── .editorconfig
├── .prettierrc
└── package.json
```

## 添加内容

在对应目录下新建 `.md` 文件，再到 `docs/.vitepress/config.ts` 的 `sidebar` 中添加对应条目即可。

| 目录 | 用途 |
|---|---|
| `docs/vite/` | 构建指南 |
| `docs/AI_about/` | AI 提示词 |
| `docs/other/` | 其他内容 |

## 部署

构建后将 `docs/.vitepress/dist` 目录部署到任意静态托管服务：

```sh
npm run docs:build
```

支持 Vercel、Netlify、GitHub Pages、Gitee Pages、1Panel 等平台。

## License

[MIT](LICENSE)
