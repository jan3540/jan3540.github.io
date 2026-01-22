#!/bin/bash
# ==============================================================================
# 脚本名称: test.sh
# 功能描述: 
#   1. 持续监控网络延迟 (Ping) 和丢包率
#   2. 测试瞬时下载速度
#   3. 监控指定进程 (EG-Connect) 是否存活
#   4. 验证 Google 连通性 (HTTP 状态码)
#   5. 将结果输出到日志文件，方便后续分析
#
# 使用方法:
#   chmod +x test.sh
#   ./test.sh
#   (推荐在 screen 或后台运行)
# ==============================================================================

# --- 配置区域 (可根据需要修改) ---
PING_TARGET="8.8.8.8"                          # Ping 测试目标 IP
SPEED_TEST_URL="http://speedtest.tele2.net/1MB.zip" # 测速文件 (小文件即可)
PROCESS_NAME="EG-Connect"                      # 需要监控的核心进程名
LOG_FILE="$HOME/network_test.log"              # 日志保存路径
SLEEP_INTERVAL=10                              # 每次循环检测的间隔时间 (秒)

# --- 函数定义: 自动安装缺失依赖 ---
# 参数1: 命令名 (如 ping)
# 参数2: 软件包名 (如 iputils-ping, 可选, 默认同命令名)
ensure_installed() {
    CMD=$1
    PKG=${2:-$1}

    if ! command -v "$CMD" &> /dev/null; then
        echo "[System] 警告: 未找到命令 '$CMD'，正在尝试安装软件包 '$PKG'..."
        sudo apt-get update -qq
        sudo apt-get install -y "$PKG"
        echo "[System] 安装完成: $PKG"
    fi
}

# --- 初始化检查 ---
echo "=== 网络稳定性测试脚本启动于 $(date '+%F %T') ===" | tee -a "$LOG_FILE"

# 检查并安装必要组件 (针对 Ubuntu Minimized 环境优化)
ensure_installed "ping" "iputils-ping"
ensure_installed "curl"
ensure_installed "ps" "procps"
ensure_installed "awk" "gawk"

# --- 如果日志文件不存在，先写入一行表头，方便阅读 ---
if [ ! -f "$LOG_FILE" ]; then
    echo "时间 | Ping延迟(ms) | 丢包率(%) | 下载速度(KB/s) | 进程状态 | Google连通性" >> "$LOG_FILE"
fi

# --- 主循环开始 ---
while true; do
    TIMESTAMP=$(date '+%F %T')

    # ---------------------------------------------------------
    # 1. Ping 测试
    # 说明: 使用 timeout 防止网络断开时脚本卡死
    # ---------------------------------------------------------
    PING_RESULT=$(timeout 5 ping -c 3 "$PING_TARGET" 2>/dev/null)
    if [ $? -eq 0 ]; then
        # 提取平均延迟 (根据 ping 输出格式解析第 5 个字段)
        AVG_LATENCY=$(echo "$PING_RESULT" | awk -F '/' 'END{print $5}')
        # 提取丢包率百分比
        LOSS=$(echo "$PING_RESULT" | grep -oP '\d+(?=% packet loss)')
    else
        AVG_LATENCY="NA"  # 网络不通
        LOSS="100"        # 100% 丢包
    fi

    # ---------------------------------------------------------
    # 2. 下载速度测试
    # 说明: 仅下载头部数据测速，不保存文件，超时设为 10秒
    # ---------------------------------------------------------
    SPEED_RESULT=$(timeout 10 curl -s --max-time 10 -o /dev/null -w "%{speed_download}" "$SPEED_TEST_URL")
    if [ $? -eq 0 ] && [ ! -z "$SPEED_RESULT" ]; then
        # curl 单位是 B/s，换算成 KB/s 保留两位小数
        SPEED_KB=$(awk "BEGIN {printf \"%.2f\", $SPEED_RESULT/1024}")
    else
        SPEED_KB="0"
    fi

    # ---------------------------------------------------------
    # 3. 核心进程监控
    # 说明: 监控 EG-Connect 是否在后台运行
    # ---------------------------------------------------------
    if ps -ef | grep -v grep | grep -q "$PROCESS_NAME"; then
         PROCESS_STATUS="Process Running"
    else
         PROCESS_STATUS="[ALERT] Process STOPPED" # 进程挂掉时标记明显一点
    fi

    # ---------------------------------------------------------
    # 4. Google 连通性测试 (HTTP HEAD 请求)
    # 说明: 验证代理是否真正生效
    # ---------------------------------------------------------
    CURL_RESULT=$(timeout 5 curl -I -s -o /dev/null -w "%{http_code}" https://www.google.com)
    if [ "$CURL_RESULT" == "200" ]; then
        CURL_STATUS="OK"
    else
        CURL_STATUS="FAIL($CURL_RESULT)" # 记录具体的错误码 (如 403, 000)
    fi

    # ---------------------------------------------------------
    # 5. 写入日志与屏幕输出
    # 说明: 
    #   - tee -a : 同时输出到屏幕和追加到文件
    #   - 格式说明: 时间 | 延迟 | 丢包 | 速度 | 进程 | 代理状态
    # ---------------------------------------------------------
    LOG_MSG="$TIMESTAMP | Ping: ${AVG_LATENCY}ms | Loss: ${LOSS}% | Speed: ${SPEED_KB} KB/s | $PROCESS_STATUS | Google: $CURL_STATUS"
    
    echo "$LOG_MSG" | tee -a "$LOG_FILE"

    # 等待下一次循环
    sleep $SLEEP_INTERVAL
done