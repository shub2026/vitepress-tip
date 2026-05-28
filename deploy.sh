#!/bin/bash
# ============================================================================
# VitePress 知行笔记 - 应急部署脚本
# 用途：当 Gitee Go 流水线失败时的应急方案
# 功能：在服务器上直接拉取代码 → 构建 → 部署到 Web 目录
# 用法：
#   bash deploy.sh              # 完整部署（拉取 + 构建 + 部署）
#   bash deploy.sh --rollback   # 回滚到上一版本
# ============================================================================

set -eu

# -------------------- 配置区 --------------------
PROJECT_DIR="/opt/wwwroot"
GIT_REPO="https://gitee.com/shub77/vitepress-tip.git"
GIT_BRANCH="main"
DIST_DIR="$PROJECT_DIR/docs/.vitepress/dist"
WEB_DIR="/opt/1panel/www/sites/sntip/index"
NPM_REGISTRY="https://registry.npmmirror.com"
MAX_BACKUPS=5  # 最多保留的备份数量

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

# -------------------- 函数：环境检查 --------------------
check_environment() {
    log_info "检查服务器环境..."
    
    # 检查必要命令
    local required_cmds=(git npm node)
    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "缺少必要命令: $cmd"
            exit 1
        fi
    done
    
    # 检查 Node.js 版本
    local current_node_version
    current_node_version=$(node -v | sed 's/^v//')
    log_info "当前 Node.js 版本: $current_node_version"
    
    # 检查磁盘空间（至少需要 500MB）
    local available_space
    available_space=$(df -m "$PROJECT_DIR" 2>/dev/null | awk 'NR==2 {print $4}' || echo "0")
    if [ "$available_space" -lt 500 ]; then
        log_error "磁盘空间不足: ${available_space}MB (至少需要 500MB)"
        exit 1
    fi
    
    log_ok "环境检查通过 (可用空间: ${available_space}MB)"
}

# -------------------- 函数：拉取最新代码 --------------------
pull_latest() {
    log_info "拉取最新代码到 $PROJECT_DIR ..."
    
    if [ ! -d "$PROJECT_DIR/.git" ]; then
        log_info "首次部署：克隆仓库..."
        mkdir -p "$PROJECT_DIR"
        git clone "$GIT_REPO" "$PROJECT_DIR"
    else
        cd "$PROJECT_DIR"
        
        # 保存本地修改（如果有）
        git stash 2>/dev/null || true
        
        # 拉取最新
        git fetch origin
        git reset --hard "origin/$GIT_BRANCH"
    fi
    
    log_ok "代码已更新到最新 commit: $(cd "$PROJECT_DIR" && git rev-parse --short HEAD)"
}

# -------------------- 函数：构建项目 --------------------
build_project() {
    log_info "安装依赖并构建 VitePress..."
    
    cd "$PROJECT_DIR"
    
    # 安装依赖（与流水线一致）
    npm config set registry "$NPM_REGISTRY"
    npm ci --prefer-offline --no-audit
    
    # VitePress 构建
    npm run docs:build
    
    log_ok "构建完成 → $DIST_DIR"
}

# -------------------- 函数：验证构建产物 --------------------
verify_build() {
    log_info "验证构建产物完整性..."
    
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
    
    local file_count
    file_count=$(find "$DIST_DIR" -type f | wc -l)
    
    log_ok "构建产物验证通过 (${total_size}MB, $file_count 个文件)"
    return 0
}

# -------------------- 函数：部署到 Web 目录 --------------------
deploy_to_web() {
    log_info "部署到 Web 目录: $WEB_DIR"
    
    # 确保目标目录存在
    mkdir -p "$WEB_DIR"
    
    # 备份旧版本（如果目录不为空）
    if [ "$(ls -A "$WEB_DIR" 2>/dev/null)" ]; then
        BACKUP_DIR="${WEB_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
        cp -a "$WEB_DIR" "$BACKUP_DIR"
        log_info "已备份旧版本到: $BACKUP_DIR"
        
        # 清理超出 MAX_BACKUPS 的旧备份
        OLD_BACKUPS=$(ls -1dr "${WEB_DIR}_backup_"* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)) || true)
        if [ -n "$OLD_BACKUPS" ]; then
            echo "$OLD_BACKUPS" | xargs rm -rf
            log_info "已清理旧备份，保留最近 $MAX_BACKUPS 个"
        fi
    fi
    
    # 清空目标目录（保留隐藏文件如 .user.ini）
    find "$WEB_DIR" -mindepth 1 -not -name '.*' -delete 2>/dev/null || true
    
    # 复制构建产物到 Web 目录
    cp -a "$DIST_DIR/." "$WEB_DIR/"
    
    # 设置权限
    chmod -R 755 "$WEB_DIR"
    
    local file_count
    file_count=$(find "$WEB_DIR" -type f | wc -l)
    
    log_ok "部署完成 → $WEB_DIR ($file_count 个文件)"
}

# -------------------- 函数：清理旧备份 --------------------
cleanup_old_backups() {
    log_info "清理旧备份 (最多保留 $MAX_BACKUPS 个)..."
    
    local backup_dirs
    backup_dirs=$(ls -dt "${WEB_DIR}_backup_"* 2>/dev/null | tail -n +$((MAX_BACKUPS + 1)))
    
    if [ -n "$backup_dirs" ]; then
        echo "$backup_dirs" | while read -r dir; do
            rm -rf "$dir"
            log_info "已删除旧备份: $dir"
        done
    fi
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
    
    deploy_to_web
    cleanup_old_backups
    
    local END_TIME=$(date +%s)
    local ELAPSED=$((END_TIME - START_TIME))
    
    echo ""
    log_ok "🎉 全部完成！耗时 ${ELAPSED}s"
    log_info "代码目录: $PROJECT_DIR"
    log_info "Web 目录: $WEB_DIR"
    log_info "备份目录: ${WEB_DIR}_backup_*"
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
    LATEST_BACKUP=$(ls -dt "${WEB_DIR}_backup_"* 2>/dev/null | head -n 1)
    
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
    local CURRENT_BACKUP="${WEB_DIR}_backup_current_$(date +%Y%m%d_%H%M%S)"
    if [ "$(ls -A "$WEB_DIR" 2>/dev/null)" ]; then
        cp -a "$WEB_DIR" "$CURRENT_BACKUP"
        log_info "已备份当前版本到: $CURRENT_BACKUP"
    fi
    
    # 恢复备份
    log_info "恢复备份到 $WEB_DIR ..."
    find "$WEB_DIR" -mindepth 1 -not -name '.*' -delete 2>/dev/null || true
    cp -a "$LATEST_BACKUP/." "$WEB_DIR/"
    chmod -R 755 "$WEB_DIR"
    
    local file_count
    file_count=$(find "$WEB_DIR" -type f | wc -l)
    
    log_ok "🎉 回滚完成！站点已恢复到备份版本 ($file_count 个文件)"
    log_info "Web 目录: $WEB_DIR"
    echo ""
}

# -------------------- 入口 --------------------
case "${1:-}" in
    --rollback)
        rollback_deploy
        ;;
    --help|-h)
        echo "用法: bash deploy.sh [选项]"
        echo ""
        echo "选项:"
        echo "  (无参数)       完整部署：拉取代码 → 构建 → 部署到 Web 目录"
        echo "  --rollback     回滚到上一版本（从备份恢复）"
        echo "  --help         显示此帮助"
        echo ""
        echo "部署流程:"
        echo "  1. 拉取代码到 /opt/wwwroot 并执行 git pull"
        echo "  2. 在 /opt/wwwroot 安装依赖并构建 VitePress"
        echo "  3. 备份当前 Web 目录（保留最近 5 个）"
        echo "  4. 清空 /opt/1panel/www/sites/sntip/index"
        echo "  5. 复制 dist 目录所有文件到 Web 目录"
        echo ""
        echo "应急场景:"
        echo "  1. 流水线构建失败 → 在服务器直接运行此脚本"
        echo "  2. 新版本有问题 → 使用 --rollback 快速回滚"
        echo ""
        echo "配置说明:"
        echo "  编辑脚本中的以下配置项:"
        echo "  PROJECT_DIR  - 代码目录 (默认: /opt/wwwroot)"
        echo "  GIT_REPO     - Git 仓库地址"
        echo "  WEB_DIR      - Web 访问目录 (默认: /opt/1panel/www/sites/sntip/index)"
        ;;
    *)
        full_deploy
        ;;
esac
