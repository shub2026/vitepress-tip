#!/bin/bash
# ============================================================================
# deploy-web-v2.sh — Gitee Go 制品条件部署脚本（v2 优化版）
# ============================================================================
# 用法：
#   bash deploy-web-v2.sh              # 默认：检测制品 → 对比 → 条件部署
#   bash deploy-web-v2.sh --force       # 强制部署，跳过 MD5 对比
#   bash deploy-web-v2.sh --dry-run     # 仅对比，不执行实际部署
#   bash deploy-web-v2.sh --rollback    # 回滚到上一备份版本
#   bash deploy-web-v2.sh --status      # 查看当前部署状态
#   bash deploy-web-v2.sh --help        # 显示帮助
# ============================================================================
# 架构说明：
#   Gitee Go 流水线 → 构建并打包 output.tar.gz
#                    → deploy@agent 推送到 ~/gitee_go/deploy/
#                    → 本脚本定时检测 → 智能对比 → 条件部署到 Web 目录
# ============================================================================

# -------------------- 确保 HOME 和 USER 环境变量（必须在 set -eu 之前） --------------------
if [ -z "${HOME:-}" ]; then
    HOME=$(eval echo "~$(id -un)")
    export HOME
fi
if [ -z "${USER:-}" ]; then
    USER=$(id -un)
    export USER
fi

set -euo pipefail

# ======================== 配置区 ========================
# 制品来源目录（Gitee Go deploy@agent 推送目标）
DEPLOY_SRC_DIR="${DEPLOY_SRC_DIR:-$HOME/gitee_go/deploy}"
# 制品文件名
ARTIFACT_NAME="${ARTIFACT_NAME:-output.tar.gz}"
# Web 站点目录（1Panel 站点根目录）
TARGET_DIR="${TARGET_DIR:-/opt/1panel/www/sites/sntip/index}"
# 临时解压目录模板
TEMP_TEMPLATE="${TEMP_TEMPLATE:-/tmp/deploy-v2.XXXXXX}"
# 最大备份数
MAX_BACKUPS="${MAX_BACKUPS:-5}"
# 嵌套制品最小有效字节数
NESTED_MIN_SIZE="${NESTED_MIN_SIZE:-100}"
# 部署锁文件
LOCK_FILE="${LOCK_FILE:-/tmp/deploy-v2.lock}"
# 部署日志文件
LOG_FILE="${LOG_FILE:-/var/log/deploy-v2.log}"
# 构建产物关键文件（用于完整性校验）
REQUIRED_FILES="${REQUIRED_FILES:-index.html 404.html}"
# ======================== 配置区 END ========================

# 计算制品完整路径
SOURCE_TAR="$DEPLOY_SRC_DIR/$ARTIFACT_NAME"

# -------------------- 颜色输出 --------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# 时间戳格式
TS_FORMAT="%Y-%m-%d %H:%M:%S"

log_info()  { echo -e "${CYAN}[$(date +"$TS_FORMAT")] ${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${CYAN}[$(date +"$TS_FORMAT")] ${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${CYAN}[$(date +"$TS_FORMAT")] ${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${CYAN}[$(date +"$TS_FORMAT")] ${RED}[ERROR]${NC} $1"; }

# 同时输出到日志文件
log_to_file() {
    local msg
    msg="$(date +"$TS_FORMAT") $1"
    # 确保日志目录存在
    if [ -n "${LOG_FILE:-}" ]; then
        mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
        echo "$msg" >> "$LOG_FILE" 2>/dev/null || true
    fi
}

log_info_f()  { log_info "$1";  log_to_file "[INFO]  $1"; }
log_ok_f()    { log_ok "$1";    log_to_file "[OK]    $1"; }
log_warn_f()  { log_warn "$1";  log_to_file "[WARN]  $1"; }
log_error_f() { log_error "$1"; log_to_file "[ERROR] $1"; }

# -------------------- 全局变量 --------------------
TEMP_DIR=""
START_TIME=""
SCRIPT_MODE="deploy"  # deploy | force | dry-run | rollback | status

# -------------------- 清理与信号处理 --------------------
cleanup() {
    local exit_code=$?
    if [ -n "${TEMP_DIR:-}" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
    # 释放锁
    release_lock
    # 记录耗时
    if [ -n "${START_TIME:-}" ]; then
        local end_time elapsed
        end_time=$(date +%s)
        elapsed=$((end_time - START_TIME))
        log_info_f "脚本退出 (code=$exit_code, 耗时=${elapsed}s)"
    fi
}
trap cleanup EXIT

# 捕获信号，确保优雅退出
trap 'log_warn_f "收到中断信号，正在清理..."; exit 130' INT TERM HUP

# -------------------- 文件锁机制 --------------------
acquire_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid lock_age
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
        lock_age=$(($(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)))

        # 如果锁超过 10 分钟，视为残留锁，强制清除
        if [ "$lock_age" -gt 600 ]; then
            log_warn_f "检测到残留锁 (PID=$lock_pid, 已存在 ${lock_age}s)，强制清除"
            rm -f "$LOCK_FILE"
        else
            log_error_f "另一个部署实例正在运行 (PID=$lock_pid, 已运行 ${lock_age}s)"
            log_error_f "如果确认无其他实例，请手动删除: rm -f $LOCK_FILE"
            exit 1
        fi
    fi

    echo $$ > "$LOCK_FILE"
    log_info_f "已获取部署锁 (PID=$$)"
}

release_lock() {
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        if [ "$lock_pid" = "$$" ]; then
            rm -f "$LOCK_FILE"
            log_info_f "已释放部署锁"
        fi
    fi
}

# -------------------- 查看部署状态 --------------------
show_status() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║         部署状态检查                         ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
    echo ""

    # 制品信息
    echo -e "${CYAN}[制品源]${NC}"
    if [ -f "$SOURCE_TAR" ]; then
        local fsize fmtime
        fsize=$(du -sh "$SOURCE_TAR" 2>/dev/null | awk '{print $1}')
        fmtime=$(stat -c '%y' "$SOURCE_TAR" 2>/dev/null | cut -d'.' -f1 || echo "unknown")
        echo "  文件: $SOURCE_TAR"
        echo "  大小: $fsize"
        echo "  修改: $fmtime"
    else
        echo -e "  ${RED}制品文件不存在: $SOURCE_TAR${NC}"
    fi
    echo ""

    # 目标目录信息
    echo -e "${CYAN}[站点目录]${NC}"
    if [ -d "$TARGET_DIR" ]; then
        local fcount dsize
        fcount=$(find "$TARGET_DIR" -type f 2>/dev/null | wc -l)
        dsize=$(du -sh "$TARGET_DIR" 2>/dev/null | awk '{print $1}')
        echo "  目录: $TARGET_DIR"
        echo "  文件数: $fcount"
        echo "  大小: $dsize"

        # 检查关键文件
        echo "  关键文件:"
        for f in $REQUIRED_FILES; do
            if [ -e "$TARGET_DIR/$f" ]; then
                echo -e "    ${GREEN}✓${NC} $f"
            else
                echo -e "    ${RED}✗${NC} $f (缺失)"
            fi
        done
    else
        echo -e "  ${RED}站点目录不存在: $TARGET_DIR${NC}"
    fi
    echo ""

    # 备份信息
    echo -e "${CYAN}[备份列表]${NC}"
    local backup_count
    backup_count=$(ls -1dr "${TARGET_DIR}_backup_"* 2>/dev/null | grep -cE "_backup_[0-9]{8}_[0-9]{6}$" || true)
    backup_count=${backup_count:-0}
    if [ "$backup_count" -gt 0 ] 2>/dev/null; then
        ls -1drt "${TARGET_DIR}_backup_"* 2>/dev/null | grep -E "_backup_[0-9]{8}_[0-9]{6}$" | while read -r dir; do
            local bname bsize
            bname=$(basename "$dir")
            bsize=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
            echo "  $bsize  $bname"
        done
        echo "  共 $backup_count 个备份"
    else
        echo "  无备份"
    fi
    echo ""

    # 锁状态
    echo -e "${CYAN}[锁状态]${NC}"
    if [ -f "$LOCK_FILE" ]; then
        local lock_pid lock_age
        lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "unknown")
        lock_age=$(($(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)))
        echo -e "  ${YELLOW}锁定中${NC} (PID=$lock_pid, 已 ${lock_age}s)"
    else
        echo -e "  ${GREEN}未锁定${NC}"
    fi
    echo ""
}

# -------------------- 嵌套制品解压 --------------------
# 处理 Gitee Go 可能产生的嵌套 artifact 包
handle_nested_artifact() {
    local extract_dir="$1"
    local tar_err_file="$2"

    # 查找所有可能的嵌套 tar.gz（更灵活的匹配模式）
    local nested_tars
    nested_tars=$(find "$extract_dir" -name "*.tar.gz" -type f 2>/dev/null)

    if [ -z "$nested_tars" ]; then
        return 0  # 无嵌套包
    fi

    # 取第一个非空的有效嵌套包
    local found_nested=""
    while IFS= read -r nested_tar; do
        local nsize
        nsize=$(wc -c < "$nested_tar" 2>/dev/null || echo 0)

        # 过滤过小的包
        if [ "$nsize" -lt "$NESTED_MIN_SIZE" ]; then
            log_warn_f "跳过过小的嵌套包: $(basename "$nested_tar") ($nsize 字节)"
            rm -f "$nested_tar"
            continue
        fi

        # 验证是否为合法 gzip 文件
        if command -v file >/dev/null 2>&1; then
            local ntype
            ntype=$(file -b "$nested_tar" 2>/dev/null || echo "")
            case "$ntype" in
                *gzip*|*tar*)
                    found_nested="$nested_tar"
                    break
                    ;;
                *)
                    log_warn_f "跳过非压缩包文件: $(basename "$nested_tar") (类型: $ntype)"
                    rm -f "$nested_tar"
                    continue
                    ;;
            esac
        else
            # 无 file 命令时用 gzip 测试
            if gzip -t "$nested_tar" 2>/dev/null; then
                found_nested="$nested_tar"
                break
            else
                log_warn_f "跳过无效压缩包: $(basename "$nested_tar")"
                rm -f "$nested_tar"
                continue
            fi
        fi
    done <<< "$nested_tars"

    if [ -z "$found_nested" ]; then
        return 0  # 无有效嵌套包
    fi

    log_info_f "检测到嵌套制品包: $(basename "$found_nested")"
    local nsize
    nsize=$(wc -c < "$found_nested" 2>/dev/null || echo 0)
    log_info_f "嵌套包大小: $nsize 字节"

    # 创建二次解压目录（在 TEMP_DIR 内，确保 cleanup 能清理）
    local nested_dir
    nested_dir="$TEMP_DIR/nested"
    mkdir -p "$nested_dir"

    # 二次解压
    if ! tar -xzf "$found_nested" -C "$nested_dir" 2>"$tar_err_file"; then
        log_error_f "嵌套包解压失败:"
        cat "$tar_err_file" 2>/dev/null | while IFS= read -r line; do
            log_error_f "  $line"
        done
        log_warn_f "删除损坏的嵌套包，保留其他解压内容"
        rm -f "$found_nested"
        return 0
    fi

    # 验证二次解压结果
    local nested_file_count
    nested_file_count=$(find "$nested_dir" -type f 2>/dev/null | wc -l)
    if [ "$nested_file_count" -eq 0 ]; then
        log_error_f "二次解压后目录为空"
        return 1
    fi

    # 用内层内容替换外层
    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"
    cp -a "$nested_dir/." "$extract_dir/"
    log_info_f "二次解压成功，获得 $nested_file_count 个文件"
    return 0
}

# -------------------- 构建产物完整性验证 --------------------
verify_artifact() {
    local extract_dir="$1"
    local file_count

    file_count=$(find "$extract_dir" -type f 2>/dev/null | wc -l)
    if [ "$file_count" -eq 0 ]; then
        log_error_f "制品解压后为空"
        return 1
    fi

    log_info_f "制品文件数: $file_count"

    # 检查关键文件
    local missing=0
    for f in $REQUIRED_FILES; do
        if [ ! -e "$extract_dir/$f" ]; then
            log_warn_f "缺少关键文件: $f"
            missing=$((missing + 1))
        fi
    done

    if [ "$missing" -gt 0 ]; then
        log_error_f "制品完整性校验失败，缺少 $missing 个关键文件"
        return 1
    fi

    # 检查制品总大小（至少 10KB）
    local total_size
    total_size=$(du -sk "$extract_dir" 2>/dev/null | awk '{print $1}')
    if [ "${total_size:-0}" -lt 10 ]; then
        log_error_f "制品总大小异常: ${total_size}KB（预期至少 10KB）"
        return 1
    fi

    log_ok_f "制品完整性验证通过 ($file_count 个文件, ${total_size}KB)"
    return 0
}

# -------------------- MD5 对比（精确统计） --------------------
compare_directories() {
    local src_dir="$1"
    local tgt_dir="$2"
    local md5_src="$3"
    local md5_tgt="$4"

    log_info_f "正在对比源与目标目录..."

    # 生成源目录 MD5 清单
    (cd "$src_dir" && find . -type f -exec md5sum {} + 2>/dev/null || true) | sort > "$md5_src"

    # 生成目标目录 MD5 清单
    local tgt_file_count
    tgt_file_count=$(find "$tgt_dir" -type f 2>/dev/null | wc -l)
    if [ "$tgt_file_count" -eq 0 ]; then
        log_warn_f "目标目录为空，将执行首次部署..."
        > "$md5_tgt"
        echo "0"  # 返回目标文件数
        return 0
    fi

    (cd "$tgt_dir" && find . -type f -exec md5sum {} + 2>/dev/null || true) | sort > "$md5_tgt"

    echo "$tgt_file_count"
    return 0
}

# -------------------- 精确差异统计 --------------------
analyze_diff() {
    local md5_src="$1"
    local md5_tgt="$2"

    local diff_output
    diff_output=$(diff "$md5_src" "$md5_tgt" 2>/dev/null) || true

    if [ -z "$diff_output" ]; then
        echo "0 0 0"  # 无差异
        return 1      # 表示无需部署
    fi

    # 精确统计：新增、修改、删除
    # "< " = 只在源中（新文件或修改后的文件）
    # "> " = 只在目标中（需删除的文件或修改前的文件）
    local added modified removed

    # 获取源文件列表和目标文件列表中的文件名
    local src_files tgt_files common_files
    src_files=$(awk '{print $2}' "$md5_src" | sort)
    tgt_files=$(awk '{print $2}' "$md5_tgt" | sort)

    # 新增的文件（只在源中存在）
    added=$(comm -23 <(echo "$src_files") <(echo "$tgt_files") | wc -l)

    # 删除的文件（只在目标中存在）
    removed=$(comm -13 <(echo "$src_files") <(echo "$tgt_files") | wc -l)

    # 修改的文件（两边都存在但 MD5 不同）
    common_files=$(comm -12 <(echo "$src_files") <(echo "$tgt_files"))
    modified=0
    if [ -n "$common_files" ]; then
        while IFS= read -r fname; do
            local src_md5 tgt_md5
            src_md5=$(grep -F " $fname$" "$md5_src" | awk '{print $1}')
            tgt_md5=$(grep -F " $fname$" "$md5_tgt" | awk '{print $1}')
            if [ "$src_md5" != "$tgt_md5" ]; then
                modified=$((modified + 1))
            fi
        done <<< "$common_files"
    fi

    echo "$added $modified $removed"
    return 0  # 表示有差异
}

# -------------------- 备份与清理 --------------------
backup_target() {
    local tgt_dir="$1"
    local tgt_file_count="$2"

    if [ "$tgt_file_count" -eq 0 ]; then
        return 0
    fi

    local backup_dir
    backup_dir="${tgt_dir}_backup_$(date +%Y%m%d_%H%M%S)"

    log_info_f "备份当前站点到: $(basename "$backup_dir")"
    if ! cp -a "$tgt_dir" "$backup_dir"; then
        log_error_f "备份失败，中止部署以确保安全"
        return 1
    fi
    log_ok_f "备份完成"

    # 清理超出上限的旧备份（严格正则匹配，防止误删）
    local old_backups
    old_backups=$(ls -1dr "${tgt_dir}_backup_"* 2>/dev/null \
        | grep -E "${tgt_dir}_backup_[0-9]{8}_[0-9]{6}$" \
        | tail -n +$((MAX_BACKUPS + 1)) || true)

    if [ -n "$old_backups" ]; then
        local count
        count=$(echo "$old_backups" | wc -l)
        log_info_f "清理 $count 个旧备份，保留最近 $MAX_BACKUPS 个"
        echo "$old_backups" | xargs rm -rf
    fi

    return 0
}

# -------------------- 执行部署 --------------------
do_deploy() {
    local extract_dir="$1"
    local tgt_dir="$2"

    log_info_f "开始部署..."

    # 清空目标目录（保留隐藏文件如 .user.ini）
    find "$tgt_dir" -mindepth 1 -not -name '.*' -delete 2>/dev/null || true

    # 复制文件到目标
    cp -a "$extract_dir/." "$tgt_dir/"

    # 规范化权限：目录 755、文件 644
    log_info_f "设置目录与文件权限..."
    find "$tgt_dir" -type d -exec chmod 755 {} +
    find "$tgt_dir" -type f -exec chmod 644 {} +

    # 验证部署结果
    local deploy_count
    deploy_count=$(find "$tgt_dir" -type f 2>/dev/null | wc -l)

    if [ "$deploy_count" -eq 0 ]; then
        log_error_f "部署后目标目录为空，部署可能失败"
        return 1
    fi

    log_ok_f "部署完成 → $tgt_dir ($deploy_count 个文件)"
    return 0
}

# -------------------- 回滚到上一备份 --------------------
do_rollback() {
    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║         回滚到上一版本                       ║${NC}"
    echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
    echo ""

    # 查找最新备份（严格正则匹配）
    local latest_backup
    latest_backup=$(ls -1dt "${TARGET_DIR}_backup_"* 2>/dev/null \
        | grep -E "${TARGET_DIR}_backup_[0-9]{8}_[0-9]{6}$" \
        | head -n 1 || true)

    if [ -z "$latest_backup" ] || [ ! -d "$latest_backup" ]; then
        log_error_f "未找到可用的备份版本"
        exit 1
    fi

    log_info_f "最新备份: $(basename "$latest_backup")"
    local backup_size
    backup_size=$(du -sh "$latest_backup" 2>/dev/null | awk '{print $1}')
    log_info_f "备份大小: $backup_size"

    local backup_files
    backup_files=$(find "$latest_backup" -type f 2>/dev/null | wc -l)
    log_info_f "备份文件数: $backup_files"

    # 交互确认（仅在终端中）
    if [ -t 0 ]; then
        read -rp "确认回滚到此版本? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info_f "已取消回滚"
            exit 0
        fi
    else
        log_info_f "非交互模式，自动确认回滚"
    fi

    # 备份当前版本
    if [ -d "$TARGET_DIR" ] && [ "$(ls -A "$TARGET_DIR" 2>/dev/null)" ]; then
        local current_backup
        current_backup="${TARGET_DIR}_backup_current_$(date +%Y%m%d_%H%M%S)"
        cp -a "$TARGET_DIR" "$current_backup"
        log_info_f "已备份当前版本到: $(basename "$current_backup")"
    fi

    # 恢复备份
    log_info_f "恢复备份到 $TARGET_DIR ..."
    find "$TARGET_DIR" -mindepth 1 -not -name '.*' -delete 2>/dev/null || true
    cp -a "$latest_backup/." "$TARGET_DIR/"

    # 规范化权限
    find "$TARGET_DIR" -type d -exec chmod 755 {} +
    find "$TARGET_DIR" -type f -exec chmod 644 {} +

    local file_count
    file_count=$(find "$TARGET_DIR" -type f | wc -l)

    log_ok_f "回滚完成! 站点已恢复到备份版本 ($file_count 个文件)"
    echo ""
}

# -------------------- 显示帮助 --------------------
show_help() {
    echo ""
    echo -e "${BOLD}deploy-web-v2.sh${NC} — Gitee Go 制品条件部署脚本 (v2)"
    echo ""
    echo "用法: bash deploy-web-v2.sh [选项]"
    echo ""
    echo "选项:"
    echo "  (无参数)       条件部署：检测制品 → MD5对比 → 有变动才部署"
    echo "  --force        强制部署：跳过MD5对比，直接部署"
    echo "  --dry-run      模拟运行：仅对比差异，不执行实际部署"
    echo "  --rollback     回滚：恢复到最近的备份版本"
    echo "  --status       状态：查看制品、站点、备份信息"
    echo "  --help         显示此帮助"
    echo ""
    echo "环境变量（可覆盖默认配置）:"
    echo "  DEPLOY_SRC_DIR  制品来源目录  (默认: ~/gitee_go/deploy)"
    echo "  ARTIFACT_NAME   制品文件名    (默认: output.tar.gz)"
    echo "  TARGET_DIR      站点目录      (默认: /opt/1panel/www/sites/sntip/index)"
    echo "  MAX_BACKUPS     最大备份数    (默认: 5)"
    echo "  LOG_FILE        日志文件路径  (默认: /var/log/deploy-v2.log)"
    echo ""
    echo "部署架构:"
    echo "  1. Gitee Go 流水线构建并推送 output.tar.gz → ~/gitee_go/deploy/"
    echo "  2. 本脚本(cron定时)检测制品 → MD5智能对比 → 条件部署"
    echo "  3. 仅在文件变动时执行部署，无变动秒级退出"
    echo ""
    echo "定时任务配置:"
    echo "  */3 * * * * /bin/bash /path/to/deploy-web-v2.sh >> /var/log/deploy-v2.log 2>&1"
    echo ""
}

# -------------------- 主流程 --------------------
main() {
    START_TIME=$(date +%s)

    # 解析命令行参数
    case "${1:-}" in
        --force)    SCRIPT_MODE="force" ;;
        --dry-run)  SCRIPT_MODE="dry-run" ;;
        --rollback) SCRIPT_MODE="rollback" ;;
        --status)   SCRIPT_MODE="status" ;;
        --help|-h)  show_help; exit 0 ;;
        "")         SCRIPT_MODE="deploy" ;;
        *)
            log_error_f "未知参数: $1"
            show_help
            exit 1
            ;;
    esac

    # 回滚模式不需要锁和制品
    if [ "$SCRIPT_MODE" = "rollback" ]; then
        do_rollback
        exit 0
    fi

    # 状态查看模式
    if [ "$SCRIPT_MODE" = "status" ]; then
        show_status
        exit 0
    fi

    # 获取文件锁（防止并发）
    acquire_lock

    echo ""
    echo -e "${BOLD}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}║     Gitee Go 制品部署 (v2)                  ║${NC}"
    echo -e "${BOLD}║     模式: $SCRIPT_MODE                           ${NC}║"
    echo -e "${BOLD}╚══════════════════════════════════════════════╝${NC}"
    echo ""

    # -------------------- 检查制品文件 --------------------
    log_info_f "制品路径: $SOURCE_TAR"

    if [ ! -f "$SOURCE_TAR" ]; then
        log_error_f "制品文件不存在: $SOURCE_TAR"
        log_info_f "请确认 Gitee Go 流水线已成功推送制品"
        exit 1
    fi

    local tar_size
    tar_size=$(du -sh "$SOURCE_TAR" 2>/dev/null | awk '{print $1}')
    log_ok_f "制品文件就绪 ($tar_size)"

    # -------------------- 创建临时目录 --------------------
    TEMP_DIR=$(mktemp -d "$TEMP_TEMPLATE")
    local extract_dir="$TEMP_DIR/extract"
    local tar_err_file="$TEMP_DIR/tar_err.log"
    local md5_src_file="$TEMP_DIR/source.md5"
    local md5_tgt_file="$TEMP_DIR/target.md5"

    mkdir -p "$extract_dir"

    # -------------------- 解压制品 --------------------
    log_info_f "解压制品..."

    # 预览制品内容（前15行即可）
    log_info_f "制品内容预览:"
    tar -tzf "$SOURCE_TAR" 2>/dev/null | head -15 || true
    echo "---"

    # 解压到临时目录
    if ! tar -xzf "$SOURCE_TAR" -C "$extract_dir" 2>"$tar_err_file"; then
        log_error_f "制品解压失败:"
        cat "$tar_err_file" 2>/dev/null | while IFS= read -r line; do
            log_error_f "  $line"
        done
        exit 1
    fi
    log_ok_f "制品解压完成"

    # -------------------- 处理嵌套制品 --------------------
    handle_nested_artifact "$extract_dir" "$tar_err_file"

    # -------------------- 验证制品完整性 --------------------
    if ! verify_artifact "$extract_dir"; then
        log_error_f "制品完整性验证失败，中止部署"
        exit 1
    fi

    # -------------------- 对比差异 --------------------
    local tgt_file_count
    tgt_file_count=$(compare_directories "$extract_dir" "$TARGET_DIR" "$md5_src_file" "$md5_tgt_file")

    if [ "$SCRIPT_MODE" = "force" ]; then
        log_warn_f "强制模式：跳过MD5对比，直接部署"
    else
        # 精确差异分析
        local diff_result
        diff_result=$(analyze_diff "$md5_src_file" "$md5_tgt_file")
        local has_diff=$?

        if [ "$has_diff" -ne 0 ]; then
            log_ok_f "目标目录已是最新，无需部署。"
            exit 0
        fi

        # 解析差异统计
        local added modified removed
        read -r added modified removed <<< "$diff_result"

        local total_changes=$((added + modified + removed))
        log_warn_f "检测到文件变动: 新增=$added, 修改=$modified, 删除=$removed (共 $total_changes 项)"

        # dry-run 模式到此结束
        if [ "$SCRIPT_MODE" = "dry-run" ]; then
            log_info_f "[dry-run] 模拟完成，未执行实际部署"

            # 显示具体变动文件（前10个）
            if [ "$added" -gt 0 ]; then
                echo -e "\n  ${GREEN}新增文件:${NC}"
                comm -23 <(awk '{print $2}' "$md5_src_file" | sort) <(awk '{print $2}' "$md5_tgt_file" | sort) | head -10
                [ "$added" -gt 10 ] && echo "  ... 共 $added 个"
            fi
            if [ "$removed" -gt 0 ]; then
                echo -e "\n  ${RED}删除文件:${NC}"
                comm -13 <(awk '{print $2}' "$md5_src_file" | sort) <(awk '{print $2}' "$md5_tgt_file" | sort) | head -10
                [ "$removed" -gt 10 ] && echo "  ... 共 $removed 个"
            fi

            exit 0
        fi
    fi

    # -------------------- 备份 --------------------
    if ! backup_target "$TARGET_DIR" "$tgt_file_count"; then
        log_error_f "备份失败，中止部署"
        exit 1
    fi

    # -------------------- 执行部署 --------------------
    if ! do_deploy "$extract_dir" "$TARGET_DIR"; then
        log_error_f "部署失败!"

        # 尝试自动回滚
        local latest_backup
        latest_backup=$(ls -1dt "${TARGET_DIR}_backup_"* 2>/dev/null \
            | grep -E "${TARGET_DIR}_backup_[0-9]{8}_[0-9]{6}$" \
            | head -n 1 || true)

        if [ -n "$latest_backup" ] && [ -d "$latest_backup" ]; then
            log_warn_f "正在自动回滚到最近备份: $(basename "$latest_backup")"
            find "$TARGET_DIR" -mindepth 1 -not -name '.*' -delete 2>/dev/null || true
            cp -a "$latest_backup/." "$TARGET_DIR/"
            find "$TARGET_DIR" -type d -exec chmod 755 {} +
            find "$TARGET_DIR" -type f -exec chmod 644 {} +
            log_ok_f "已自动回滚"
        else
            log_error_f "无可用备份，无法自动回滚"
        fi

        exit 1
    fi

    # -------------------- 部署成功后清理制品（可选） --------------------
    # 部署成功后删除源制品文件，避免下次 cron 重复处理
    # 注释此行可保留制品用于审计，但 cron 场景建议启用
    log_info_f "清理已部署的制品文件: $SOURCE_TAR"
    rm -f "$SOURCE_TAR"
    log_ok_f "制品文件已清理"

    # -------------------- 完成 --------------------
    local end_time elapsed
    end_time=$(date +%s)
    elapsed=$((end_time - START_TIME))

    echo ""
    log_ok_f "部署流程完成! 耗时 ${elapsed}s"
    log_info_f "站点目录: $TARGET_DIR"
    echo ""
}

# -------------------- 入口 --------------------
main "$@"
