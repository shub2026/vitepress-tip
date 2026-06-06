# 知行笔记

> 基于 VitePress 的极简风格知识分享平台 — **知行合一，止于至善**

<p>
  <a href="https://sntip.cn" target="_blank"><img src="https://img.shields.io/badge/在线地址-sntip.cn-brightgreen" alt="在线地址"></a>
  <a href="https://github.com/shub2026/vitepress-tip" target="_blank"><img src="https://img.shields.io/badge/GitHub-仓库-blue" alt="GitHub"></a>
  <a href="https://gitee.com/shub77/vitepress-tip" target="_blank"><img src="https://img.shields.io/badge/Gitee-仓库-red" alt="Gitee"></a>
  <a href="https://vitepress.dev/zh/" target="_blank"><img src="https://img.shields.io/badge/VitePress-1.6.4-purple" alt="VitePress"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green" alt="License"></a>
</p>

---

## 特性

- 📝 **纯 Markdown 创作** — 专注内容，无需关心样式
- ⚡ **极速构建** — VitePress HMR 开发体验，秒级热更新
- 🎨 **极简风格** — 自定义品牌色 `#32CB8F`，支持深色模式
- 📱 **响应式布局** — PC / 平板 / 手机全端适配
- 🔍 **本地全文搜索** — 离线可用，无外部依赖
- 🗺️ **Mermaid 流程图** — 原生支持流程图、时序图、类图
- 🕐 **更新时间显示** — 每篇文章自动展示最后更新时间
- 🗂️ **自动 Sitemap** — SEO 友好，自动生成站点地图
- ✏️ **编辑链接** — 页面底部直达 GitHub 编辑页

---

## 快速开始

**环境要求：** Node.js >= 18

```sh
# 克隆项目
git clone https://github.com/shub2026/vitepress-tip.git
cd vitepress-tip

# 安装依赖
npm install

# 启动开发服务器
npm run docs:dev

# 构建生产版本
npm run docs:build

# 本地预览构建产物
npm run docs:preview
```

---

## 命令

| 命令 | 说明 |
|------|------|
| `npm run docs:dev` | 启动开发服务器 |
| `npm run docs:build` | 构建到 `docs/.vitepress/dist` |
| `npm run docs:preview` | 本地预览构建产物 |
| `npm run format` | Prettier 格式化文档 |
| `npm run type-check` | TypeScript 类型检查 |
| `npm run clean` | 清理构建缓存 |

---

## 项目结构

```
vitepress-tip/
├── docs/
│   ├── .vitepress/              # 配置与主题
│   │   ├── components/          # 自定义 Vue 组件
│   │   ├── config.ts            # 站点配置（导航、侧边栏、SEO）
│   │   └── theme/               # 自定义主题样式
│   ├── vite/                    # 构建与部署指南（8 篇）
│   ├── AI_about/                # AI 应用指南（14 篇，含 12 大模型提示词）
│   ├── linux/                   # Linux 学习笔记
│   ├── other/                   # 其他内容（证件照、Lightroom 等）
│   ├── public/                  # 静态资源
│   └── index.md                 # 首页
├── .workflow/                   # Gitee Go CI/CD 流水线
├── deploy-web-v2.sh             # 服务器部署脚本（锁/校验/回滚）
├── tsconfig.json                # TypeScript 配置
├── package.json
└── README.md
```

---

## 内容导航

| 分类 | 目录 | 内容 |
|------|------|------|
| 构建指南 | `docs/vite/` | VitePress 搭建、1Panel 部署、Gitee Go 流水线、GitHub Actions + SSH 部署、Git 常用命令 |
| AI 应用指南 | `docs/AI_about/` | 12 大主流模型提示词最佳实践、国产大模型选型对比 |
| Linux 学习 | `docs/linux/` | Ubuntu 文件系统架构、日常使用说明 |
| 其他 | `docs/other/` | 证件照处理、Lightroom 技巧、WPS 配置 |

---

## 部署

项目支持多种部署方式，详见 `docs/vite/` 目录下的构建指南。

| 方式 | 说明 | 文档 |
|------|------|------|
| GitHub Actions + SSH | 推送即自动部署到服务器 | [查看](./docs/vite/github-actions-ssh-deploy.md) |
| Gitee Go 流水线 | 国产 CI/CD 方案 | [查看](./docs/vite/gitee-go-deploy-v2.md) |
| 手动构建 | `npm run docs:build`，产物在 `dist` | [查看](./docs/vite/basic-setup.md) |

### 当前部署架构

```
git push → GitHub Actions → SSH → 服务器部署目录
```

---

## 仓库

| 平台 | 地址 |
|------|------|
| GitHub | https://github.com/shub2026/vitepress-tip |
| Gitee | https://gitee.com/shub77/vitepress-tip |
| 在线站点 | https://sntip.cn |

---

## 技术栈

| 技术 | 用途 |
|------|------|
| [VitePress 1.6](https://vitepress.dev/zh/) | 静态站点生成器 |
| [Vue 3](https://vuejs.org/) | 组件框架 |
| [Mermaid](https://mermaid.js.org/) | 图表渲染 |
| [GitHub Actions](https://github.com/features/actions) | CI/CD 自动部署 |
| [1Panel](https://1panel.cn/) | 服务器管理 |

---

## License

[MIT](LICENSE)
