# 知行笔记

> 基于 VitePress 的极简风格知识分享平台 — **知行合一，止于至善**

<p>
  <a href="https://sntip.cn" target="_blank"><img src="https://img.shields.io/badge/在线地址-sntip.cn-brightgreen" alt="在线地址"></a>
  <a href="https://gitee.com/shub77/vitepress-tip" target="_blank"><img src="https://img.shields.io/badge/Gitee-仓库-red" alt="Gitee"></a>
  <a href="https://github.com/shub2026/vitepress-tip" target="_blank"><img src="https://img.shields.io/badge/GitHub-仓库-blue" alt="GitHub"></a>
  <a href="https://vitepress.dev/zh/" target="_blank"><img src="https://img.shields.io/badge/VitePress-1.6%2B-purple" alt="VitePress"></a>
</p>

---

## 特性

- 📝 **纯 Markdown 创作** — 专注内容，无需关心样式
- ⚡ **极速构建** — VitePress 的 HMR 开发体验，秒级热更新
- 🎨 **极简风格** — 自定义品牌色（绿）与渐变 Hero，支持深色模式
- 📱 **响应式布局** — PC / 平板 / 手机全端适配
- 🔍 **本地全文搜索** — 离线可用，无外部依赖
- 🗺️ **Mermaid 流程图** — 原生支持流程图、时序图、类图等
- 🕐 **更新时间显示** — 每篇文章自动展示最后更新时间
- 🗂️ **自动 Sitemap** — SEO 友好，自动生成站点地图

---

## 快速开始

**环境要求：** Node.js >= 18

```sh
# 克隆项目
git clone https://GitHub.com/shub2026/vitepress-tip.git
cd vitepress-tip

# 安装依赖
npm install

# 启动开发服务器（热更新）
npm run docs:dev

# 构建生产版本
npm run docs:build

# 本地预览构建产物
npm run docs:preview
```

---

## 常用命令

| 命令 | 说明 |
|------|------|
| `npm run docs:dev` | 启动开发服务器（localhost:5173） |
| `npm run docs:build` | 构建生产版本到 `docs/.vitepress/dist` |
| `npm run docs:preview` | 本地预览构建产物 |
| `npm run format` | Prettier 格式化所有文档 |

---

## 项目结构

```
vitepress-tip/
├── docs/                          # 文档源码目录
│   ├── .vitepress/                # VitePress 配置与主题
│   │   ├── components/            # 自定义 Vue 组件
│   │   │   └── BookmarkNav.vue    #   书签导航组件
│   │   ├── config.ts              #   站点配置（导航、侧边栏、SEO）
│   │   └── theme/                 #   自定义主题
│   │       ├── index.ts           #     主题入口
│   │       └── style/             #     样式文件
│   │           ├── var.css        #       品牌色变量（主色 #32CB8F）
│   │           ├── hero.css       #       Hero 标题+图片左右布局
│   │           ├── blockquote.css #       引用块圆角样式
│   │           ├── custom-block.css #     提示容器样式（7 种类型）
│   │           └── mermaid.css    #       Mermaid 图表容器样式
│   ├── vite/                      # 构建指南
│   ├── AI_about/                  # AI 应用指南（提示词 + 模型选型）
│   ├── linux/                     # Linux 学习笔记
│   ├── other/                     # 其他内容（证件照、Lightroom 等）
│   ├── public/                    # 静态资源（logo、图标）
│   ├── bookmarks.md               # 书签导航页
│   └── index.md                   # 首页
├── .workflow/                     # Gitee Go CI/CD 流水线
│   └── main-gitee.yml             #   Gitee Go 构建配置
├── deploy.sh                      # GitHub Pages 旧版部署脚本
├── deploy-web-v2.sh               # 服务器部署脚本（含锁/回滚/校验）
├── .editorconfig
├── .gitignore
├── .prettierrc
├── package.json
└── README.md
```

---

## 添加内容

1. 在对应目录下新建 `.md` 文件
2. 在 `docs/.vitepress/config.ts` 侧边栏 `sidebar` 中添加对应条目

| 目录 | 用途 |
|------|------|
| `docs/vite/` | 构建与部署指南 |
| `docs/AI_about/` | AI 应用指南（提示词文档 + 模型对比） |
| `docs/linux/` | Linux 学习笔记 |
| `docs/other/` | 工具技巧与杂项 |

---

## 部署架构

站点采用**分离式部署架构**，支持自动发布与安全回滚：

```
┌──────────────┐    git push     ┌──────────────────┐
│  开发者推送    │ ──────────────→ │  Gitee Go 流水线  │
│  main 分支    │                 │  Node 25.4 构建   │
└──────────────┘                 └────────┬─────────┘
                                          │ 构建完成
                                          ▼
┌──────────────┐    WebHook POST    ┌──────────────────┐
│  部署目标目录  │ ←────────────── │  ss.sntip.cn      │
│  /opt/1panel/ │                   │  PHP 接收请求     │
│  www/sites/   │                   │  → 调用 Shell    │
│  cs/index     │                   └────────┬─────────┘
└──────────────┘                             │
                                             ▼
                                    ┌──────────────────┐
                                    │ deploy-web-v2.sh  │
                                    │ ① 锁机制防并发    │
                                    │ ② git pull 检测   │
                                    │ ③ npm build      │
                                    │ ④ 制品校验       │
                                    │ ⑤ 部署 + 回滚    │
                                    │ ⑥ 耗时统计       │
                                    └──────────────────┘
```


### 自动部署流程

推送 `main` 分支到 Gitee → Gitee Go 自动触发构建 → 服务器自动定时执行 `deploy-web-v2.sh` → 执行部署（含锁机制、制品校验、回滚）。

- **流水线配置**：`.workflow/main-gitee.yml`
- **部署脚本**：`deploy-web-v2.sh`（778 行，含锁/校验/回滚/计时）
- **服务器管理**：1Panel

**以上部署已弃用，改为GitHub Actions自动化部署**

### 手动构建

```sh
npm run docs:build
```

构建产物位于 `docs/.vitepress/dist`，可部署到任意静态托管服务。

---

## 仓库镜像

| 平台 | 地址 | 用途 |
|------|------|------|
| [Gitee](https://gitee.com/shub77/vitepress-tip) | 主仓库 | 托管源码 + Gitee Go CI/CD 自动构建 |
| [GitHub](https://github.com/shub2026/vitepress-tip) | 镜像仓库 | 代码备份与社区协作 |

---

## 技术栈

| 技术 | 说明 |
|------|------|
| [VitePress](https://vitepress.dev/zh/) | 静态站点生成器（基于 Vite + Vue） |
| [Vue 3](https://vuejs.org/) | 组件化开发 |
| [Mermaid](https://mermaid.js.org/) | 流程图与图表 |
| [Gitee Go](https://gitee.com/features/gitee-go) | CI/CD 持续集成 |
| [1Panel](https://1panel.cn/) | Linux 服务器管理面板 |

---

## License

[MIT](LICENSE)
