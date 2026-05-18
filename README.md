# 知行笔记

基于 VitePress 的极简风格知识分享平台，知行合一，止于至善。 

## 快速开始

### 环境要求

- Node.js >= 18
- npm / pnpm / yarn

### 安装步骤

```sh
# 克隆项目
git clone https://gitee.com/shub77/vitepress-tip.git

# 进入项目目录
cd vitepress-tip

# 安装依赖
npm install

# 启动开发服务器
npm run docs:dev
```

### 常用命令

| 命令 | 说明 |
|------|------|
| `npm run docs:dev` | 启动开发服务器 |
| `npm run docs:build` | 构建生产版本 |
| `npm run docs:preview` | 预览生产版本 |
| `npm run format` | 格式化代码 |

## 项目结构

```
vitepress-tip/
├── docs/                      # 文档目录
│   ├── .vitepress/
│   │   ├── config.ts          # VitePress 配置
│   │   └── theme/             # 自定义主题
│   │       ├── index.ts       # 主题入口
│   │       └── style/         # 样式文件
│   │           ├── index.css
│   │           ├── var.css
│   │           ├── blockquote.css
│   │           ├── custom-block.css
│   │           └── hero.css
│   ├── content_A/              # 指南文章
│   ├── content_B/              # 收藏文章
│   ├── content_C/              # 其他示例
│   ├── public/                 # 静态资源
│   └── index.md                # 首页
├── .editorconfig              # 编辑器配置
├── .prettierrc                # Prettier 配置
├── .prettierignore            # Prettier 忽略文件
└── package.json
```

## 部署

本项目可部署到任意静态托管服务：

- Vercel
- Netlify
- GitHub Pages
- Gitee Pages
- 1Panel

构建命令：

```sh
npm run docs:build
```

构建产物在 `docs/.vitepress/dist` 目录。

## 关键特性

- 📝 完全基于 Markdown，自动生成网站
- ⚡ 超快的开发和构建速度
- 🎨 干净美观的风格设计
- 🔄 实时预览，改完立即看到效果
- 📱 自适应手机和电脑屏幕
- 🌙 支持深色模式

## 自定义

### 修改主题色

编辑 `.vitepress/theme/style/var.css` 文件中的 CSS 变量。

### 添加文章

在 `docs/content_A/`、`docs/content_B/` 或 `docs/content_C/` 目录下创建 `.md` 文件。

### 修改侧边栏

编辑 `.vitepress/config.ts` 中的 `sidebar` 配置。

## License

[MIT](LICENSE)
