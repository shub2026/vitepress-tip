#!/bin/bash
# ============================================================================
# 条件部署脚本：将流水线制品解压到 1Panel 站点目录
# 用法：bash deploy-wwwroot-to-web.sh
# 逻辑：
#   1. 检测 ~/gitee_go/deploy/output.tar.gz 是否存在
#   2. 解压到临时目录
#   3. 对比临时目录与目标目录差异
#   4. 有变动才执行部署
# ============================================================================

# 确保 HOME 环境变量存在（必须在 set -eu 之前）
if [ -z "${HOME:-}" ]; then
    HOME=$(eval echo "~$(whoami)")
    export HOME
fi

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

# 查看制品内容结构
log_info "制品内容列表:"
tar -tzf "$SOURCE_TAR" 2>/dev/null | head -20 || true
echo "---"

# 尝试直接解压
if ! tar -xzf "$SOURCE_TAR" -C "$EXTRACT_DIR" 2>/tmp/tar_error.txt; then
    log_error "制品解压失败:"
    cat /tmp/tar_error.txt
    exit 1
fi

# 检查是否存在嵌套的 artifact tar.gz 文件
NESTED_TAR=$(find "$EXTRACT_DIR" -name "artifact_*.tar.gz" -type f 2>/dev/null | head -1)
if [ -n "$NESTED_TAR" ]; then
    log_info "检测到嵌套制品包: $(basename "$NESTED_TAR")"
    
    # 检查文件大小和类型
    NESTED_SIZE=$(wc -c < "$NESTED_TAR" 2>/dev/null || echo 0)
    log_info "嵌套包大小: $NESTED_SIZE 字节"
    
    # 使用 file 命令检查文件类型
    if command -v file >/dev/null 2>&1; then
        NESTED_TYPE=$(file "$NESTED_TAR" 2>/dev/null || echo "unknown")
        log_info "嵌套包类型: $NESTED_TYPE"
    fi
    
    # 如果文件太小（小于100字节），可能是空包或占位符
    if [ "$NESTED_SIZE" -lt 100 ]; then
        log_warn "嵌套包过小（$NESTED_SIZE 字节），可能是空包，直接删除"
        rm -f "$NESTED_TAR"
    else
        log_info "正在二次解压..."
        
        # 创建二次解压目录
        NESTED_DIR="$TEMP_DIR/nested"
        mkdir -p "$NESTED_DIR"
        
        # 查看嵌套包内容
        log_info "嵌套包内容列表:"
        if ! tar -tzf "$NESTED_TAR" 2>/tmp/tar_list_error.txt | head -20; then
            log_warn "无法列出嵌套包内容:"
            cat /tmp/tar_list_error.txt 2>/dev/null || true
        fi
        echo "---"
        
        # 尝试二次解压
        if tar -xzf "$NESTED_TAR" -C "$NESTED_DIR" 2>/tmp/tar_error2.txt; then
            # 二次解压成功，用内层内容替换
            NESTED_FILES=$(find "$NESTED_DIR" -type f 2>/dev/null | wc -l)
            if [ "$NESTED_FILES" -gt 0 ]; then
                rm -rf "$EXTRACT_DIR"/*
                cp -a "$NESTED_DIR/." "$EXTRACT_DIR/"
                log_info "二次解压成功，获得 $NESTED_FILES 个文件"
            else
                log_error "二次解压后目录为空"
                exit 1
            fi
        else
            log_error "嵌套包解压失败:"
            cat /tmp/tar_error2.txt 2>/dev/null || true
            log_warn "删除损坏的嵌套包，保留其他解压内容"
            rm -f "$NESTED_TAR"
        fi
    fi
fi

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

