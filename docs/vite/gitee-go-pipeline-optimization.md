# Gitee Go 流水线优化方案

针对 `.workflow/main-gitee.yml` 的深度审查与优化建议。

---

## 📋 当前流水线架构

```mermaid
graph LR
    A[推送 main] --> B[构建: npm ci + docs:build + tar]
    B --> C[上传制品: general_artifacts]
    C --> D[发布版本: release_artifacts]
    D --> E[部署: deploy@agent]
    E --> F[服务器: ~/gitee_go/deploy/ + /opt/wwwroot]
```

当前共 **4 个阶段**，串行执行，部署阶段包含冗余操作。

---

## 🔴 严重问题

### P1: 部署阶段 script 与 deploy-web-v2.sh 架构矛盾

**当前代码**（第 75-78 行）:
```yaml
script:
  - mkdir -p /opt/wwwroot
  - tar -xzf ~/gitee_go/deploy/output.tar.gz -C /opt/wwwroot
  - chmod -R 755 /opt/wwwroot
```

**问题分析**:

| # | 问题 | 影响 |
|---|------|------|
| 1 | 解压到 `/opt/wwwroot` 而非站点目录 `/opt/1panel/www/sites/sntip/index` | 制品落在"中转目录"而非 Web 目录，需要额外的脚本再搬一次 |
| 2 | `chmod -R 755` 对所有文件设置执行权限 | 文件应为 644，755 意味着 `.html`、`.css`、`.js` 等静态资源都有执行权限，不安全且不规范 |
| 3 | 解压操作在流水线中执行一次，cron 脚本又解压一次 | 同一个 tar.gz 被解压两次，浪费 IO 且逻辑混乱 |
| 4 | 解压到 `/opt/wwwroot` 但 deploy-web-v2.sh 从 `~/gitee_go/deploy/` 读取 | 两个路径完全不同，v2 脚本根本不读 `/opt/wwwroot`，这段 script 属于遗留逻辑 |

**v2 架构设计**:
```
流水线 → 推送 output.tar.gz 到 ~/gitee_go/deploy/ → 不做任何解压
                                                    → deploy-web-v2.sh 定时检测并部署
```

**优化方案**: 部署阶段仅负责推送制品，删除所有 script 中的解压和权限操作。

---

### P2: 制品路径不一致导致部署链路断裂

当前流水线的 `deployArtifact.target` 和 `script` 操作的路径不一致:

```yaml
deployArtifact:
  - target: ~/gitee_go/deploy     # ← 制品推送到这里
script:
  - tar -xzf ~/gitee_go/deploy/output.tar.gz -C /opt/wwwroot  # ← 解压到另一个目录
```

这意味着:
- 制品被推送到 `~/gitee_go/deploy/output.tar.gz` ✅ 正确
- 同时又被手动解压到 `/opt/wwwroot` ❌ 多余且与 v2 脚本无关
- deploy-web-v2.sh 读取 `~/gitee_go/deploy/output.tar.gz` ✅ 正确
- `/opt/wwwroot` 中的内容无人消费 ❌ 浪费磁盘

**优化方案**: 删除 script，只保留制品推送。

---

## 🟡 架构问题

### P3: 部署阶段职责过重，违反单一职责

当前部署阶段同时做了三件事:
1. **推送制品**（`deployArtifact`）— 应该做
2. **解压到 /opt/wwwroot**（`script`）— 不应该做
3. **设置权限**（`script`）— 不应该做

按照 v2 架构，部署阶段的唯一职责是**将制品推送到服务器指定目录**，解压、对比、权限设置都由 `deploy-web-v2.sh` 完成。

---

### P4: 上传制品和发布版本阶段可合并

当前分两个独立阶段:

```yaml
- name: stage-upload        # 上传到 general_artifacts
  step: publish@general_artifacts

- name: stage-release        # 发布到 release_artifacts
  step: publish@release_artifacts
```

**问题**:
- 两个阶段各只有一个步骤，功能紧密耦合，没有独立存在的必要
- 多一个阶段 = 多一次调度开销 + 多一个可能的失败点
- Gitee Go 的 `deploy@agent` 可以直接从 `general_artifacts` 拉取制品

**优化方案**: 考虑是否真的需要 release 阶段。如果不需要版本回溯功能，可以去掉 `stage-release`。

---

### P5: 无构建缓存机制

**当前**:
```yaml
commands:
  - npm ci          # 每次全量安装依赖
  - npm run docs:build
```

**问题**:
- `npm ci` 每次都从镜像源下载全部依赖，即使 `package-lock.json` 没变
- VitePress 项目依赖不多（5个），但 `npm ci` 仍需 15-30s 网络请求
- Gitee Go 云服务器如果网络抖动，`npm ci` 可能超时失败

**优化方案**:
- 利用 Gitee Go 的缓存功能缓存 `node_modules`（如果支持）
- 或者在构建命令中先检查 `node_modules` 是否存在:
  ```yaml
  commands:
    - npm config set registry https://registry.npmmirror.com
    - if [ ! -d node_modules ]; then npm ci; fi
    - npm run docs:build
  ```

---

### P6: 无构建失败快速检测

当前构建命令是:
```yaml
commands:
  - npm ci
  - npm run docs:build
  - cd docs/.vitepress/dist && tar -czf ../../../output.tar.gz .
```

**问题**:
- 如果 `docs:build` 失败，`dist` 目录可能不存在或不完整
- `tar` 命令不会检查上一步的退出码（YAML 数组中每个命令独立执行）
- 可能打包出一个空制品或部分文件，后续阶段不会发现

**优化方案**:
```yaml
commands:
  - npm config set registry https://registry.npmmirror.com
  - npm ci
  - npm run docs:build
  - test -f docs/.vitepress/dist/index.html || exit 1
  - cd docs/.vitepress/dist && tar -czf ../../../output.tar.gz .
```

---

## 🟠 可靠性改进

### P7: Node.js 版本锁定过于激进

当前: `nodeVersion: 25.4.0`

**问题**:
- Node.js 25 是 Current（非 LTS）版本，生命周期短
- Gitee Go 云环境可能不总能提供 25.4.0 精确版本
- VitePress 1.x 推荐的 Node.js 版本是 >= 18

**优化方案**:
- 生产环境建议使用 LTS 版本: `nodeVersion: '20'` 或 `nodeVersion: '22'`
- 如果依赖 Node.js 25 的新特性，在注释中说明原因

---

### P8: 缺少构建超时和重试配置

当前:
```yaml
strategy: naturally    # 构建阶段
strategy:
  retry: '0'          # 上传和发布阶段
strategy: {}           # 部署阶段
```

**问题**:
- 构建阶段没有 retry，网络抖动导致 `npm ci` 失败无法自动重试
- 部署阶段 `strategy: {}` 空配置，没有重试也没有超时
- 2核2G 服务器上构建容易 OOM，应该有重试机制

**优化方案**:
```yaml
# 构建阶段增加重试
strategy:
  retry: '2'

# 部署阶段增加重试
strategy:
  retry: '1'
```

---

### P9: 制品未校验完整性

当前打包后直接作为 artifact，没有任何校验:

```yaml
- cd docs/.vitepress/dist && tar -czf ../../../output.tar.gz .
```

**优化方案**:
```yaml
commands:
  - npm ci
  - npm run docs:build
  - cd docs/.vitepress/dist
  - test -f index.html || { echo "ERROR: build output missing"; exit 1; }
  - FILE_COUNT=$(find . -type f | wc -l)
  - 'echo "Build output: $FILE_COUNT files"'
  - test "$FILE_COUNT" -gt 5 || { echo "ERROR: too few output files"; exit 1; }
  - tar -czf ../../../output.tar.gz .
  - ls -lh ../../../output.tar.gz
```

---

### P10: 部署脚本路径硬编码

当前 script 中的路径 `/opt/wwwroot` 是硬编码的，与 v2 架构不匹配。

**优化方案**: 部署阶段不再执行 script，改由 deploy-web-v2.sh 统一处理。

---

## 🟢 体验优化

### P11: 流水线名称不够语义化

当前: `displayName: main-gitee`

**优化方案**: `displayName: VitePress 自动构建与部署`

---

### P12: 缺少通知配置

当前所有阶段的 `notify: []`，构建失败无人知晓。

**优化方案**: 在上传阶段和部署阶段添加通知（如果 Gitee Go 支持）:
```yaml
notify:
  - type: wechat
    events: [fail]
```

---

### P13: tar 打包缺少排除规则

当前打包了 `dist` 目录下的所有内容:
```yaml
- cd docs/.vitepress/dist && tar -czf ../../../output.tar.gz .
```

VitePress 构建可能生成一些调试文件（如 `.map` 文件），生产环境不需要。

**优化方案**:
```yaml
- cd docs/.vitepress/dist && tar -czf ../../../output.tar.gz --exclude='*.map' .
```

---

## ✅ 优化后的流水线

```yaml
version: '1.0'
name: main-gitee
displayName: VitePress 自动构建与部署

triggers:
  trigger: auto
  push:
    branches:
      prefix:
        - main

stages:
  # ==================== 阶段一：构建 ====================
  - name: stage-build
    displayName: 构建
    strategy: naturally
    trigger: auto
    steps:
      - step: build@nodejs
        name: build-nodejs
        displayName: Node.js 构建
        nodeVersion: '20'                    # P7: 使用 LTS 版本
        commands:
          # 配置镜像源
          - npm config set registry https://registry.npmmirror.com
          # 安装依赖（优先使用缓存）
          - if [ ! -d node_modules ]; then npm ci; else npm ci --prefer-offline; fi
          # 构建项目
          - npm run docs:build
          # P6: 构建产物完整性校验
          - test -f docs/.vitepress/dist/index.html || { echo "ERROR: index.html not found, build may have failed"; exit 1; }
          - FILE_COUNT=$(find docs/.vitepress/dist -type f | wc -l)
          - echo "Build output: $FILE_COUNT files"
          - test "$FILE_COUNT" -gt 5 || { echo "ERROR: too few output files ($FILE_COUNT), build may be incomplete"; exit 1; }
          # 打包制品（排除 sourcemap）
          - cd docs/.vitepress/dist && tar -czf ../../../output.tar.gz --exclude='*.map' .
          # 显示制品信息
          - ls -lh ../../../output.tar.gz
        artifacts:
          - name: BUILD_ARTIFACT
            path:
              - output.tar.gz
        strategy:
          retry: '2'                         # P8: 构建重试

  # ==================== 阶段二：上传制品 ====================
  - name: stage-upload
    displayName: 上传制品
    strategy: naturally
    trigger: auto
    steps:
      - step: publish@general_artifacts
        name: publish_general_artifacts
        displayName: 上传制品
        dependArtifact: BUILD_ARTIFACT
        artifactName: output
        notify: []
        strategy:
          retry: '1'                         # P8: 上传重试

  # ==================== 阶段三：发布版本 ====================
  - name: stage-release
    displayName: 发布版本
    strategy: naturally
    trigger: auto
    steps:
      - step: publish@release_artifacts
        name: publish_release_artifacts
        displayName: 发布
        dependArtifact: output
        version: 1.0.0.0
        autoIncrement: true
        notify: []
        strategy:
          retry: '1'                         # P8: 发布重试

  # ==================== 阶段四：部署 ====================
  - name: stage-deploy
    displayName: 部署
    strategy: naturally
    trigger: auto
    steps:
      - step: deploy@agent
        name: deploy_agent
        displayName: 部署制品到服务器
        hostGroupID:
          ID: ali2026
          hostID:
            - c2a096df-4e33-455b-96ec-b183130b69b4
        deployArtifact:
          - source: artifact
            name: output
            target: ~/gitee_go/deploy        # P1/P2: 仅推送制品，不解压
            artifactRepository: release
            artifactName: output
            artifactVersion: latest
        # P1/P3/P10: 删除冗余 script
        # 解压、对比、权限设置全部由 deploy-web-v2.sh 完成
        script:
          - echo "制品已推送到 ~/gitee_go/deploy/，等待 deploy-web-v2.sh 定时部署"
        strategy:
          retry: '1'                         # P8: 部署重试
```

---

## 📊 优化前后对比

| 对比项 | 优化前 | 优化后 |
|--------|--------|--------|
| **部署阶段 script** | 解压+chmod到 /opt/wwwroot | 仅 echo 提示，不做任何文件操作 |
| **Node.js 版本** | 25.4.0 (Current) | 20 (LTS) |
| **构建重试** | 无 (retry: 0) | 2次重试 |
| **部署重试** | 无 (strategy: {}) | 1次重试 |
| **构建产物校验** | 无 | 检查 index.html + 文件数 > 5 |
| **tar 排除** | 无 | 排除 *.map 文件 |
| **依赖安装** | 每次全量 npm ci | 优先缓存 --prefer-offline |
| **职责分离** | 流水线既推送又解压 | 流水线只推送，deploy-web-v2.sh 负责解压和部署 |
| **权限设置** | chmod -R 755（不安全） | 由 v2 脚本设置 目录755/文件644 |
| **制品消费路径** | /opt/wwwroot（无人使用） | ~/gitee_go/deploy/（v2 脚本读取） |

---

## 🔄 配套改动

此流水线优化需要配合 `deploy-web-v2.sh` 使用，核心变更点:

| 变更 | 说明 |
|------|------|
| **删除 `/opt/wwwroot` 解压** | 流水线不再往 /opt/wwwroot 写任何内容 |
| **cron 定时任务** | 配置 `*/3 * * * * /bin/bash /path/to/deploy-web-v2.sh` |
| **deploy.sh 保留** | 应急脚本仍然使用 `/opt/wwwroot` 路径，不受影响 |
| **v1 脚本兼容** | 旧脚本 `deploy-wwwroot-to-web.sh` 可保留但不再需要 |

---

## ⚠️ 迁移注意事项

1. **Node.js 版本变更**: 从 25 降到 20，需确认项目无依赖 Node.js 25 独有 API（VitePress + Mermaid 无此问题）
2. **删除 script 后**: `/opt/wwwroot` 不再自动更新，如果其他服务依赖此目录，需同步修改
3. **重试次数**: 构建重试 2 次可能导致流水线总耗时增加，如服务器资源紧张可适当减少
4. **sourcemap 排除**: 如果生产环境需要调试，去掉 `--exclude='*.map'`
5. **deploy-web-v2.sh 部署**: 确保服务器已部署 v2 脚本并配置 cron
