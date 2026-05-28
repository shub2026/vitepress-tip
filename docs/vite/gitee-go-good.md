# Gitee go优化部署方案
尝试了好多次Gitee go直接部署，总是不成功。
流水线只能到把压缩文件放到目录，成为`/opt/wwwroot/output.tar.gz`没法解压到网站web目录。
最后采用折中办法，先走流水线，最后再执行脚本解压缩到Web目录，**具体流程为Gitee go执行构建-上传制品-发布版本-部署**
>- 其中部署环节只负责把构建产物发送到服务器`/opt/wwwroot`目录
>- 下一步由1Panel自动脚本执行解压缩任务到`Web`目录进行访问

## 流水线代码

*特别是轻应用服务器，2核2G构建常常失败*
流水线完成**构建-上传制品-发布版本-部署**环节，在服务器构建减少服务器构建压力
以下为流水线`main-gitee.yml`文件代码
```yaml
version: '1.0'
name: main-gitee
displayName: main-gitee
triggers:
  trigger: auto
  push:
    branches:
      prefix:
        - main
stages:
  - name: stage-build
    displayName: 构建
    strategy: naturally
    trigger: auto
    steps:
      - step: build@nodejs
        name: build-nodejs
        displayName: Node.js 构建
        nodeVersion: 25.4.0
        commands:
          - npm config set registry https://registry.npmmirror.com
          - npm ci
          - npm run docs:build
          - cd docs/.vitepress/dist && tar -czf ../../../output.tar.gz .
        artifacts:
          - name: BUILD_ARTIFACT
            path:
              - output.tar.gz
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
          retry: '0'
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
          retry: '0'
  - name: stage-deploy
    displayName: 部署
    strategy: naturally
    trigger: auto
    steps:
      - step: deploy@agent
        name: deploy_agent
        displayName: 部署到服务器
        hostGroupID:
          ID: ali2026
          hostID:
            - c2a096df-4e33-455b-96ec-b183130b69b4
        deployArtifact:
          - source: artifact
            name: output
            target: ~/gitee_go/deploy
            artifactRepository: release
            artifactName: output
            artifactVersion: latest
        script:
          - mkdir -p /opt/wwwroot
          - tar -xzf ~/gitee_go/deploy/output.tar.gz -C /opt/wwwroot
          - chmod -R 755 /opt/wwwroot
        strategy: {}
```
## 解压部署脚本

流水线跑完后，服务器设置脚本间隔3分钟执行。脚本目的为解压缩，把`/opt/wwwroot/output.tar.gz`解压到指定文件夹*如Web访问目录*
- **文件**: `deploy-wwwroot-to-web.sh`
- **功能**: 将 `/opt/wwwroot/output.tar.gz` 解压后部署到` /opt/1panel/www/sites/sntip/index`
- **核心逻辑**: 
  1. 检测 `/opt/wwwroot/output.tar.gz `制品
  2. 解压到临时目录
  3. MD5 对比临时目录与目标目录差异
  4. 有变动才备份 + 部署
- **修复记录**:
  - v1: pipefail 导致空目录退出 → 改为 set -eu
  - v2: 源目录是 tar.gz 而非解压后的文件 → 改为先解压再对比部署
- **代码**
```sh
#!/bin/bash
# ============================================================================
# 条件部署脚本：将 /opt/wwwroot 制品解压到 1Panel 站点目录
# 用法：bash deploy-wwwroot-to-web.sh
# 逻辑：
#   1. 检测 /opt/wwwroot/output.tar.gz 是否存在
#   2. 解压到临时目录
#   3. 对比临时目录与目标目录差异
#   4. 有变动才执行部署
# ============================================================================

set -eu

SOURCE_TAR="/opt/wwwroot/output.tar.gz"
TARGET_DIR="/opt/1panel/www/sites/sntip/index"
TEMP_DIR="/tmp/deploy_cs_$$"
EXTRACT_DIR="$TEMP_DIR/extract"

# -------------------- 颜色输出 --------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -------------------- 清理临时目录 --------------------
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# -------------------- 检查制品文件 --------------------
if [ ! -f "$SOURCE_TAR" ]; then
    log_error "制品文件不存在: $SOURCE_TAR"
    exit 1
fi

# -------------------- 解压制品到临时目录 --------------------
log_info "解压制品: $SOURCE_TAR"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$SOURCE_TAR" -C "$EXTRACT_DIR"

SOURCE_FILE_COUNT=$(find "$EXTRACT_DIR" -type f 2>/dev/null | wc -l)
if [ "$SOURCE_FILE_COUNT" -eq 0 ]; then
    log_error "制品解压后为空"
    exit 1
fi
log_info "制品文件数: $SOURCE_FILE_COUNT"

# -------------------- 确保目标目录存在 --------------------
mkdir -p "$TARGET_DIR"

# -------------------- 对比文件差异 --------------------
log_info "正在对比源与目标目录..."

# 生成解压目录文件清单（含 MD5）
cd "$EXTRACT_DIR"
find . -type f -exec md5sum {} \; 2>/dev/null | sort > "$TEMP_DIR/source.md5" || true

# 生成目标目录文件清单（含 MD5）
cd "$TARGET_DIR"
TARGET_FILE_COUNT=$(find . -type f 2>/dev/null | wc -l)
if [ "$TARGET_FILE_COUNT" -eq 0 ]; then
    log_warn "目标目录为空，将执行首次部署..."
    > "$TEMP_DIR/target.md5"
else
    find . -type f -exec md5sum {} \; 2>/dev/null | sort > "$TEMP_DIR/target.md5" || true
fi

# 对比差异
DIFF_OUTPUT=$(diff "$TEMP_DIR/source.md5" "$TEMP_DIR/target.md5" 2>/dev/null) || true

if [ -z "$DIFF_OUTPUT" ]; then
    log_ok "目标目录已是最新，无需部署。"
    exit 0
fi

# -------------------- 显示变动摘要 --------------------
ADDED=$(echo "$DIFF_OUTPUT" | grep -c "^< " || echo 0)
REMOVED=$(echo "$DIFF_OUTPUT" | grep -c "^> " || echo 0)

log_warn "检测到文件变动（新增: $ADDED, 删除: $REMOVED）"

# 显示前20行差异
echo "$DIFF_OUTPUT" | head -20
DIFF_LINES=$(echo "$DIFF_OUTPUT" | wc -l)
if [ "$DIFF_LINES" -gt 20 ]; then
    echo "... (共 $DIFF_LINES 行差异，仅显示前 20 行)"
fi

# -------------------- 执行部署 --------------------
log_info "开始部署..."

# 备份旧版本（仅保留最近5个）
if [ "$TARGET_FILE_COUNT" -gt 0 ]; then
    BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    cp -a "$TARGET_DIR" "$BACKUP_DIR"
    log_info "已备份到: $BACKUP_DIR"

    # 清理超出5个的旧备份
    OLD_BACKUPS=$(ls -1dr "${TARGET_DIR}_backup_"* 2>/dev/null | tail -n +6 || true)
    if [ -n "$OLD_BACKUPS" ]; then
        echo "$OLD_BACKUPS" | xargs rm -rf
        log_info "已清理旧备份，保留最近5个"
    fi
fi

# 清空目标目录（保留隐藏文件如 .user.ini）
find "$TARGET_DIR" -mindepth 1 -not -name '.*' -delete 2>/dev/null || true

# 复制解压后的文件到目标
cp -a "$EXTRACT_DIR/." "$TARGET_DIR/"

# 设置权限
chmod -R 755 "$TARGET_DIR"

log_ok "部署完成 → $TARGET_DIR"

```
