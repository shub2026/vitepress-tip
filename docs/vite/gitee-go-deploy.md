# Gitee Go 流水线配置与部署

Gitee Go 是 Gitee 提供的持续集成（CI）服务，支持在代码推送或 PR 时自动执行构建、测试和部署。本文档介绍如何为 VitePress 项目配置 Gitee Go 流水线。

## 一、流水线文件结构

流水线配置文件存放在项目根目录的 `.workflow/` 目录下：

| 文件 | 触发条件 | 用途 |
|------|----------|------|
| `master-pipeline.yml` | master 分支推送 | 生产环境构建 + 发布 |
| `branch-pipeline.yml` | 非 master 分支推送 | 分支验证构建 |
| `pr-pipeline.yml` | PR 提交到 master | PR 预检查构建 |

## 二、流水线配置详解

### 2.1 构建阶段

```yaml
- step: build@nodejs
  name: build_nodejs
  displayName: Nodejs 构建
  nodeVersion: 18.15.0   # VitePress 要求 Node >= 18
  commands:
    - npm install && npm run docs:build
  artifacts:
    - name: BUILD_ARTIFACT
      path:
        - ./docs/.vitepress/dist   # VitePress 构建输出目录
```

**要点说明：**

- **Node 版本**：VitePress 1.6+ 要求 **Node >= 18**，推荐使用 `18.15.0` 或 `20.10.0`
- **构建命令**：`npm run docs:build`，对应 `package.json` 中的 `docs:build` 脚本
- **产物路径**：VitePress 默认构建输出为 `docs/.vitepress/dist`，需正确配置 artifact 路径
- **依赖安装**：`npm install` 会安装 `package.json` 中声明的所有依赖

### 2.2 制品上传阶段

```yaml
- step: publish@general_artifacts
  name: publish_general_artifacts
  displayName: 上传制品
  dependArtifact: BUILD_ARTIFACT
  artifactName: output
  dependsOn: build_nodejs
```

构建产物上传到 Gitee 制品库，7 天后自动清除，可用于后续部署步骤。

### 2.3 发布阶段（仅 master 流水线）

```yaml
- step: publish@release_artifacts
  name: publish_release_artifacts
  displayName: '发布'
  dependArtifact: output
  version: '1.0.0.0'
  autoIncrement: true
```

master 流水线增加发布阶段，生成版本号并发布制品。

## 三、Gitee Go 配置步骤

### 3.1 开启 Gitee Go

1. 进入 Gitee 仓库页面
2. 点击顶部菜单 **服务 > Gitee Go**
3. 点击 **开通 Gitee Go**（首次使用需授权）
4. 选择 **免费版** 即可满足 VitePress 构建需求

### 3.2 确认流水线生效

开通后，Gitee 会自动扫描 `.workflow/` 目录下的流水线配置文件：

1. 进入 **服务 > Gitee Go > 流水线**
2. 应能看到三条流水线：`MasterPipeline`、`BranchPipeline`、`PRPipeline`
3. 推送代码到对应分支即可触发流水线执行

### 3.3 查看构建结果

- 在 **Gitee Go > 流水线** 页面查看执行状态
- 点击具体流水线可查看构建日志
- 构建成功后可在 **制品库** 中下载产物

## 四、结合 1Panel 部署

Gitee Go 构建生成的制品可通过以下方式部署到 1Panel 服务器：

### 方案 A：手动下载部署

1. 在 Gitee Go 制品库下载构建产物
2. 上传到服务器 Web 目录
3. 配置 Nginx 指向该目录

### 方案 B：结合 Webhook 自动部署

推荐使用已有的 Webhook 部署方案：

1. Gitee Go 构建完成后，通过仓库的 **WebHook** 通知服务器
2. 服务器端 `deploy.sh` 脚本拉取最新代码并构建
3. 部署架构：`Gitee Push → Gitee WebHook → PHP 接收 → Shell 部署`

详细部署流程参见 [1Panel 部署](./1panel-deploy) 文档。

## 五、流水线常见问题

### Q1：构建失败，提示 Node 版本过低？

```text
Error: Minimum Node.js version required is 18.x
```

**解决**：检查 `.workflow/*.yml` 中 `nodeVersion` 是否设置为 `18.15.0` 或更高版本。

### Q2：构建产物路径错误？

```text
Artifact path does not exist: ./dist
```

**解决**：VitePress 的输出目录是 `docs/.vitepress/dist`，非根目录的 `dist`。将 artifact path 改为 `./docs/.vitepress/dist`。

### Q3：`npm run build` 命令不存在？

```text
missing script: build
```

**解决**：VitePress 项目的构建命令是 `npm run docs:build`，对应脚本：
```json
"docs:build": "vitepress build docs"
```

### Q4：流水线未自动触发？

- 检查 `.workflow/*.yml` 中的 `triggers` 配置是否正确
- 确认 Gitee Go 服务已开通
- 检查推送的分支是否在触发规则内

## 六、参考链接

- [Gitee Go 官方文档](https://gitee.com/help/articles/4311)
- [VitePress 构建配置](https://vitepress.dev/zh/reference/site-config)
- [Gitee WebHook 配置指南](https://gitee.com/help/articles/4336)
- [1Panel 部署方案](./1panel-deploy)
