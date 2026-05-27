#!/bin/bash
# ============================================================================
# VitePress 知行笔记 - 服务器端部署脚本
# 用途：拉取 Gitee 仓库最新代码 → 构建 → 部署到 /opt/wwwroot
# 用法：
#   bash deploy.sh          # 完整构建部署
#   bash deploy.sh --pull   # 仅拉取 + 构建（不覆盖 wwwroot）
#   bash deploy.sh --quick  # 使用 Gitee Go 制品快速部署（配合流水线）
# ============================================================================

set -euo pipefail

# -------------------- 配置区 --------------------
PROJECT_DIR="/opt/vitepress-tip"
DEPLOY_DIR="/opt/wwwroot"
GIT_REMOTE="origin"
GIT_BRANCH="main"
NPM_REGISTRY="https://registry.npmmirror.com"
GITEE_REPO="https://gitee.com/shub77/vitepress-tip.git"

# -------------------- 颜色输出 --------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -------------------- 函数：首次克隆 --------------------
clone_project() {
    log_info "首次部署：克隆仓库..."
    
    if [ -d "$PROJECT_DIR" ]; then
        log_warn "目录 $PROJECT_DIR 已存在，跳过克隆"
        return 0
    fi
    
    mkdir -p "$(dirname "$PROJECT_DIR")"
    git clone "$GITEE_REPO" "$PROJECT_DIR"
    log_ok "仓库克隆完成: $PROJECT_DIR"
}

# -------------------- 函数：拉取最新代码 --------------------
pull_latest() {
    log_info "拉取最新代码..."
    
    if [ ! -d "$PROJECT_DIR/.git" ]; then
        log_warn "Git 仓库不存在，执行首次克隆..."
        clone_project
    fi
    
    cd "$PROJECT_DIR"
    
    # 保存本地修改（如果有）
    git stash 2>/dev/null || true
    
    # 拉取最新
    git fetch "$GIT_REMOTE"
    git reset --hard "${GIT_REMOTE}/${GIT_BRANCH}"
    
    log_ok "代码已更新到最新 commit: $(git rev-parse --short HEAD)"
}

# -------------------- 函数：构建 --------------------
build_project() {
    log_info "安装依赖并构建..."
    
    cd "$PROJECT_DIR"
    
    # 安装依赖
    npm config set registry "$NPM_REGISTRY"
    npm ci --prefer-offline --no-audit
    
    # VitePress 构建
    npm run docs:build
    
    log_ok "构建完成 → $PROJECT_DIR/docs/.vitepress/dist"
}

# -------------------- 函数：部署到 wwwroot --------------------
deploy_to_wwwroot() {
    log_info "部署到 $DEPLOY_DIR ..."
    
    # 确保目标目录存在
    mkdir -p "$DEPLOY_DIR"
    
    # 备份旧版本
    if [ "$(ls -A "$DEPLOY_DIR" 2>/dev/null)" ]; then
        BACKUP_DIR="${DEPLOY_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        cp -a "$DEPLOY_DIR" "$BACKUP_DIR"
        log_info "已备份旧版本到: $BACKUP_DIR"
    fi
    
    # 清空目标目录
    find "$DEPLOY_DIR" -mindepth 1 -delete 2>/dev/null || true
    
    # 复制构建产物
    cp -a "$PROJECT_DIR/docs/.vitepress/dist/." "$DEPLOY_DIR/"
    
    # 设置权限
    chmod -R 755 "$DEPLOY_DIR"
    
    log_ok "部署完成 → $DEPLOY_DIR"
}

# -------------------- 函数：快速部署（使用 Gitee Go 制品）--------------------
quick_deploy_from_artifact() {
    # 此模式用于 Gitee Go deploy@agent 步骤调用
    # 制品已由流水线解压到指定位置，此处只需移动到 /opt/wwwroot
    local ARTIFACT_TAR="${1:-~/gitee_go/deploy/output.tar.gz}"
    
    if [ ! -f "$ARTIFACT_TAR" ]; then
        log_warn "制品文件不存在: $ARTIFACT_TAR，回退到完整构建模式"
        full_deploy
        return
    fi
    
    log_info "从制品快速部署: $ARTIFACT_TAR"
    
    mkdir -p "$DEPLOY_DIR"
    find "$DEPLOY_DIR" -mindepth 1 -delete 2>/dev/null || true
    tar -xzf "$ARTIFACT_TAR" -C "$DEPLOY_DIR"
    chmod -R 755 "$DEPLOY_DIR"
    
    log_ok "制品部署完成 → $DEPLOY_DIR"
}

# -------------------- 函数：完整部署 --------------------
full_deploy() {
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║     知行笔记 VitePress 自动部署脚本          ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    
    local START_TIME=$(date +%s)
    
    pull_latest
    build_project
    deploy_to_wwwroot
    
    local END_TIME=$(date +%s)
    local ELAPSED=$((END_TIME - START_TIME))
    
    echo ""
    log_ok "🎉 全部完成！耗时 ${ELAPSED}s"
    log_info "站点目录: $DEPLOY_DIR"
    echo ""
}

# -------------------- 入口 --------------------
case "${1:-}" in
    --pull)
        pull_latest
        build_project
        log_info "仅构建完成（未覆盖 wwwroot），dist 目录: $PROJECT_DIR/docs/.vitepress/dist"
        ;;
    --quick)
        quick_deploy_from_artifact "${2:-}"
        ;;
    --help|-h)
        echo "用法: bash deploy.sh [选项]"
        echo ""
        echo "选项:"
        echo "  (无参数)    完整部署：拉取 → 构建 → 部署到 /opt/wwwroot"
        echo "  --pull      仅拉取 + 构建，不覆盖 wwwroot（用于预检查）"
        echo "  --quick     从 Gitee Go 制品快速部署（配合流水线使用）"
        echo "  --help      显示此帮助"
        ;;
    *)
        full_deploy
        ;;
esac
