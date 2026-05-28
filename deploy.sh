#!/bin/bash
# ============================================================================
# VitePress 知行笔记 - 应急部署脚本
# 用途：当 Gitee Go 流水线部署失败时，作为第二套应急方案
# 功能：
#   1. 完整构建部署（拉取 → 构建 → 部署 → 健康检查）
#   2. 仅从制品部署（跳过构建，快速恢复）
#   3. 回滚到上一版本
# 用法：
#   bash deploy.sh              # 完整构建部署
#   bash deploy.sh --artifact   # 从制品快速部署
#   bash deploy.sh --rollback   # 回滚到上一版本
#   bash deploy.sh --dry-run    # 预检查（仅拉取 + 构建，不部署）
# ============================================================================

set -euo pipefail

# -------------------- 配置区 --------------------
PROJECT_DIR="/opt/vitepress-tip"
DEPLOY_DIR="/opt/1panel/www/sites/sntip/index"
BACKUP_BASE_DIR="/opt/1panel/www/sites/sntip"
GIT_REMOTE="origin"
GIT_BRANCH="main"
NPM_REGISTRY="https://registry.npmmirror.com"
GITEE_REPO="https://gitee.com/shub77/vitepress-tip.git"
NODE_VERSION="25.4.0"  # 与流水线保持一致
MAX_BACKUPS=5  # 最多保留的备份数量

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

# -------------------- 函数：环境检查 --------------------
check_environment() {
    log_info "检查部署环境..."
    
    # 检查必要命令
    local required_cmds=(git npm node tar)
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "缺少必要命令: $cmd"
            exit 1
        fi
    done
    
    # 检查 Node.js 版本
    local current_node_version
    current_node_version=$(node -v | sed 's/^v//')
    log_info "当前 Node.js 版本: $current_node_version (流水线使用: $NODE_VERSION)"
    
    # 检查磁盘空间（至少需要 500MB）
    local available_space
    available_space=$(df -m "$PROJECT_DIR" 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
    if [ "$available_space" -lt 500 ]; then
        log_error "磁盘空间不足: ${available_space}MB (至少需要 500MB)"
        exit 1
    fi
    
    log_ok "环境检查通过 (可用空间: ${available_space}MB)"
}

# -------------------- 函数：清理旧备份 --------------------
cleanup_old_backups() {
    log_info "清理旧备份 (最多保留 $MAX_BACKUPS 个)..."
    
    local backup_dirs
    backup_dirs=$(ls -dt "${BACKUP_BASE_DIR}"/index_backup_* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)))
    
    if [ -n "$backup_dirs" ]; then
        echo "$backup_dirs" | while read -r dir; do
            rm -rf "$dir"
            log_info "已删除旧备份: $dir"
        done
    fi
}

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
    
    # 安装依赖（与流水线一致）
    npm config set registry "$NPM_REGISTRY"
    npm ci --prefer-offline --no-audit
    
    # VitePress 构建
    npm run docs:build
    
    log_ok "构建完成 → $PROJECT_DIR/docs/.vitepress/dist"
}

# -------------------- 函数：验证构建产物 --------------------
verify_build() {
    log_info "验证构建产物完整性..."
    
    local DIST_DIR="$PROJECT_DIR/docs/.vitepress/dist"
    
    # 检查 dist 目录是否存在
    if [ ! -d "$DIST_DIR" ]; then
        log_error "构建产物目录不存在: $DIST_DIR"
        return 1
    fi
    
    # 检查关键文件
    local required_files=("index.html" "assets" "404.html")
    for file in "${required_files[@]}"; do
        if [ ! -e "$DIST_DIR/$file" ]; then
            log_error "缺少关键文件/目录: $file"
            return 1
        fi
    done
    
    # 检查文件大小（至少应该有内容）
    local total_size
    total_size=$(du -sm "$DIST_DIR" | awk '{print $1}')
    if [ "$total_size" -lt 1 ]; then
        log_error "构建产物过小: ${total_size}MB"
        return 1
    fi
    
    log_ok "构建产物验证通过 (${total_size}MB, 包含 ${#required_files[@]} 个关键项)"
    return 0
}

# -------------------- 函数：健康检查 --------------------
health_check() {
    log_info "执行部署后健康检查..."
    
    # 检查部署目录
    if [ ! -d "$DEPLOY_DIR" ]; then
        log_error "部署目录不存在: $DEPLOY_DIR"
        return 1
    fi
    
    # 检查关键文件
    if [ ! -f "$DEPLOY_DIR/index.html" ]; then
        log_error "部署目录缺少 index.html"
        return 1
    fi
    
    # 检查文件数量（至少应该有多个文件）
    local file_count
    file_count=$(find "$DEPLOY_DIR" -type f | wc -l)
    if [ "$file_count" -lt 5 ]; then
        log_warn "部署目录文件数量异常: $file_count 个文件"
        return 1
    fi
    
    # 检查权限
    local wrong_perms
    wrong_perms=$(find "$DEPLOY_DIR" -type f ! -perm -u+r | head -n 5)
    if [ -n "$wrong_perms" ]; then
        log_warn "发现权限异常的文件:"
        echo "$wrong_perms"
    fi
    
    log_ok "健康检查通过 ($file_count 个文件)"
    return 0
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

# -------------------- 函数：完整部署 --------------------
full_deploy() {
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║     知行笔记 VitePress 应急部署脚本          ║"
    echo "║     (Gitee Go 流水线失败时的备用方案)        ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    
    local START_TIME=$(date +%s)
    
    check_environment
    pull_latest
    build_project
    
    # 构建后验证
    if ! verify_build; then
        log_error "构建产物验证失败，中止部署"
        exit 1
    fi
    
    deploy_to_wwwroot
    
    # 部署后健康检查
    if ! health_check; then
        log_warn "健康检查未通过，但部署已完成，请手动验证站点"
    fi
    
    cleanup_old_backups
    
    local END_TIME=$(date +%s)
    local ELAPSED=$((END_TIME - START_TIME))
    
    echo ""
    log_ok "🎉 全部完成！耗时 ${ELAPSED}s"
    log_info "站点目录: $DEPLOY_DIR"
    log_info "备份目录: ${BACKUP_BASE_DIR}/index_backup_*"
    echo ""
}

# -------------------- 函数：从制品部署 --------------------
artifact_deploy() {
    local ARTIFACT_PATH="${1:-}"
    
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║     从制品快速部署（跳过构建）               ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    
    # 如果未提供路径，尝试常见位置
    if [ -z "$ARTIFACT_PATH" ]; then
        if [ -f "$HOME/gitee_go/deploy/output.tar.gz" ]; then
            ARTIFACT_PATH="$HOME/gitee_go/deploy/output.tar.gz"
        elif [ -f "./output.tar.gz" ]; then
            ARTIFACT_PATH="./output.tar.gz"
        else
            log_error "未找到制品文件，请指定路径或运行完整部署"
            log_info "用法: bash deploy.sh --artifact <path-to-output.tar.gz>"
            exit 1
        fi
    fi
    
    if [ ! -f "$ARTIFACT_PATH" ]; then
        log_error "制品文件不存在: $ARTIFACT_PATH"
        exit 1
    fi
    
    log_info "使用制品文件: $ARTIFACT_PATH"
    
    local START_TIME=$(date +%s)
    
    # 备份当前版本
    mkdir -p "$DEPLOY_DIR"
    if [ "$(ls -A "$DEPLOY_DIR" 2>/dev/null)" ]; then
        local BACKUP_DIR="${BACKUP_BASE_DIR}/index_backup_$(date +%Y%m%d_%H%M%S)"
        cp -a "$DEPLOY_DIR" "$BACKUP_DIR"
        log_info "已备份当前版本到: $BACKUP_DIR"
    fi
    
    # 解压制品
    log_info "解压制品到 $DEPLOY_DIR ..."
    find "$DEPLOY_DIR" -mindepth 1 -delete 2>/dev/null || true
    tar -xzf "$ARTIFACT_PATH" -C "$DEPLOY_DIR"
    chmod -R 755 "$DEPLOY_DIR"
    
    # 健康检查
    if ! health_check; then
        log_warn "健康检查未通过，请手动验证站点"
    fi
    
    local END_TIME=$(date +%s)
    local ELAPSED=$((END_TIME - START_TIME))
    
    echo ""
    log_ok "🎉 制品部署完成！耗时 ${ELAPSED}s"
    log_info "站点目录: $DEPLOY_DIR"
    echo ""
}

# -------------------- 函数：回滚 --------------------
rollback_deploy() {
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║     回滚到上一版本                           ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    
    # 查找最新备份
    local LATEST_BACKUP
    LATEST_BACKUP=$(ls -dt "${BACKUP_BASE_DIR}"/index_backup_* 2>/dev/null | head -n 1)
    
    if [ -z "$LATEST_BACKUP" ] || [ ! -d "$LATEST_BACKUP" ]; then
        log_error "未找到可用的备份版本"
        exit 1
    fi
    
    log_info "最新备份: $LATEST_BACKUP"
    read -p "确认回滚到此版本? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "已取消回滚"
        exit 0
    fi
    
    # 备份当前版本
    local CURRENT_BACKUP="${BACKUP_BASE_DIR}/index_backup_current_$(date +%Y%m%d_%H%M%S)"
    if [ "$(ls -A "$DEPLOY_DIR" 2>/dev/null)" ]; then
        cp -a "$DEPLOY_DIR" "$CURRENT_BACKUP"
        log_info "已备份当前版本到: $CURRENT_BACKUP"
    fi
    
    # 恢复备份
    log_info "恢复备份到 $DEPLOY_DIR ..."
    find "$DEPLOY_DIR" -mindepth 1 -delete 2>/dev/null || true
    cp -a "$LATEST_BACKUP/." "$DEPLOY_DIR/"
    chmod -R 755 "$DEPLOY_DIR"
    
    log_ok "🎉 回滚完成！站点已恢复到备份版本"
    log_info "站点目录: $DEPLOY_DIR"
    echo ""
}

# -------------------- 入口 --------------------
case "${1:-}" in
    --artifact)
        artifact_deploy "${2:-}"
        ;;
    --rollback)
        rollback_deploy
        ;;
    --dry-run)
        check_environment
        pull_latest
        build_project
        verify_build
        log_info "预检查完成（未部署），dist 目录: $PROJECT_DIR/docs/.vitepress/dist"
        ;;
    --help|-h)
        echo "用法: bash deploy.sh [选项]"
        echo ""
        echo "选项:"
        echo "  (无参数)     完整部署：检查环境 → 拉取 → 构建 → 验证 → 部署 → 健康检查"
        echo "  --artifact   从制品快速部署（跳过构建，适用于流水线已构建成功）"
        echo "  --rollback   回滚到上一版本（从备份恢复）"
        echo "  --dry-run    预检查模式：仅拉取 + 构建 + 验证，不部署"
        echo "  --help       显示此帮助"
        echo ""
        echo "应急场景:"
        echo "  1. 流水线构建失败 → 使用完整部署排查问题"
        echo "  2. 流水线部署失败 → 使用 --artifact 从制品快速部署"
        echo "  3. 新版本有问题 → 使用 --rollback 回滚"
        ;;
    *)
        full_deploy
        ;;
esac
