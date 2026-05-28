#!/bin/bash
# ============================================================================
# 鏉′欢閮ㄧ讲鑴氭湰锛氬皢娴佹按绾垮埗鍝佽В鍘嬪埌 1Panel 绔欑偣鐩綍
# 鐢ㄦ硶锛歜ash deploy-wwwroot-to-web.sh
# 閫昏緫锛?
#   1. 妫€娴?$HOME/gitee_go/deploy/output.tar.gz 鏄惁瀛樺湪
#   2. 瑙ｅ帇鍒颁复鏃剁洰褰?
#   3. 瀵规瘮涓存椂鐩綍涓庣洰鏍囩洰褰曞樊寮?
#   4. 鏈夊彉鍔ㄦ墠鎵ц閮ㄧ讲
# ============================================================================

set -eu

SOURCE_TAR="$HOME/gitee_go/deploy/output.tar.gz"
TARGET_DIR="/opt/1panel/www/sites/sntip/index"
TEMP_DIR="/tmp/deploy_cs_$$"
EXTRACT_DIR="$TEMP_DIR/extract"

# -------------------- 棰滆壊杈撳嚭 --------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# -------------------- 娓呯悊涓存椂鐩綍 --------------------
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# -------------------- 妫€鏌ュ埗鍝佹枃浠?--------------------
if [ ! -f "$SOURCE_TAR" ]; then
    log_error "鍒跺搧鏂囦欢涓嶅瓨鍦? $SOURCE_TAR"
    exit 1
fi

# -------------------- 瑙ｅ帇鍒跺搧鍒颁复鏃剁洰褰?--------------------
log_info "瑙ｅ帇鍒跺搧: $SOURCE_TAR"
mkdir -p "$EXTRACT_DIR"
tar -xzf "$SOURCE_TAR" -C "$EXTRACT_DIR"

SOURCE_FILE_COUNT=$(find "$EXTRACT_DIR" -type f 2>/dev/null | wc -l)
if [ "$SOURCE_FILE_COUNT" -eq 0 ]; then
    log_error "鍒跺搧瑙ｅ帇鍚庝负绌?
    exit 1
fi
log_info "鍒跺搧鏂囦欢鏁? $SOURCE_FILE_COUNT"

# -------------------- 纭繚鐩爣鐩綍瀛樺湪 --------------------
mkdir -p "$TARGET_DIR"

# -------------------- 瀵规瘮鏂囦欢宸紓 --------------------
log_info "姝ｅ湪瀵规瘮婧愪笌鐩爣鐩綍..."

# 鐢熸垚瑙ｅ帇鐩綍鏂囦欢娓呭崟锛堝惈 MD5锛?
cd "$EXTRACT_DIR"
find . -type f -exec md5sum {} \; 2>/dev/null | sort > "$TEMP_DIR/source.md5" || true

# 鐢熸垚鐩爣鐩綍鏂囦欢娓呭崟锛堝惈 MD5锛?
cd "$TARGET_DIR"
TARGET_FILE_COUNT=$(find . -type f 2>/dev/null | wc -l)
if [ "$TARGET_FILE_COUNT" -eq 0 ]; then
    log_warn "鐩爣鐩綍涓虹┖锛屽皢鎵ц棣栨閮ㄧ讲..."
    > "$TEMP_DIR/target.md5"
else
    find . -type f -exec md5sum {} \; 2>/dev/null | sort > "$TEMP_DIR/target.md5" || true
fi

# 瀵规瘮宸紓
DIFF_OUTPUT=$(diff "$TEMP_DIR/source.md5" "$TEMP_DIR/target.md5" 2>/dev/null) || true

if [ -z "$DIFF_OUTPUT" ]; then
    log_ok "鐩爣鐩綍宸叉槸鏈€鏂帮紝鏃犻渶閮ㄧ讲銆?
    exit 0
fi

# -------------------- 鏄剧ず鍙樺姩鎽樿 --------------------
ADDED=$(echo "$DIFF_OUTPUT" | grep -c "^< " || echo 0)
REMOVED=$(echo "$DIFF_OUTPUT" | grep -c "^> " || echo 0)

log_warn "妫€娴嬪埌鏂囦欢鍙樺姩锛堟柊澧? $ADDED, 鍒犻櫎: $REMOVED锛?

# 鏄剧ず鍓?0琛屽樊寮?
echo "$DIFF_OUTPUT" | head -20
DIFF_LINES=$(echo "$DIFF_OUTPUT" | wc -l)
if [ "$DIFF_LINES" -gt 20 ]; then
    echo "... (鍏?$DIFF_LINES 琛屽樊寮傦紝浠呮樉绀哄墠 20 琛?"
fi

# -------------------- 鎵ц閮ㄧ讲 --------------------
log_info "寮€濮嬮儴缃?.."

# 澶囦唤鏃х増鏈紙浠呬繚鐣欐渶杩?涓級
if [ "$TARGET_FILE_COUNT" -gt 0 ]; then
    BACKUP_DIR="${TARGET_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
    cp -a "$TARGET_DIR" "$BACKUP_DIR"
    log_info "宸插浠藉埌: $BACKUP_DIR"

    # 娓呯悊瓒呭嚭5涓殑鏃у浠?
    OLD_BACKUPS=$(ls -1dr "${TARGET_DIR}_backup_"* 2>/dev/null | tail -n +6 || true)
    if [ -n "$OLD_BACKUPS" ]; then
        echo "$OLD_BACKUPS" | xargs rm -rf
        log_info "宸叉竻鐞嗘棫澶囦唤锛屼繚鐣欐渶杩?涓?
    fi
fi

# 娓呯┖鐩爣鐩綍锛堜繚鐣欓殣钘忔枃浠跺 .user.ini锛?
find "$TARGET_DIR" -mindepth 1 -not -name '.*' -delete 2>/dev/null || true

# 澶嶅埗瑙ｅ帇鍚庣殑鏂囦欢鍒扮洰鏍?
cp -a "$EXTRACT_DIR/." "$TARGET_DIR/"

# 璁剧疆鏉冮檺
chmod -R 755 "$TARGET_DIR"

log_ok "閮ㄧ讲瀹屾垚 鈫?$TARGET_DIR"