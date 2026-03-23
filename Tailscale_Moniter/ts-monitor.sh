#!/bin/bash

# ==========================================
# Tailscale 连接状态守护脚本
# 说明: 此服务器已在后台禁用了Key Expiry（密钥过期）
# ==========================================

LOG_FILE="/var/log/ts-monitor.log"

log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_ts_status() {
    # 如果 tailscale 服务完全挂了或者掉线，ip 命令会返回错空或报错
    local ts_ip=$(tailscale ip -4 2>/dev/null)
    
    # 检查是否成功获取到了100开头的 Tailscale IP
    if ! echo "$ts_ip" | grep -qE "^100\.[0-9]+\.[0-9]+\.[0-9]+$"; then
        return 1  # 没获取到合法IP，认为已断线
    fi
    
    # 获取真正的自身状态 (通过 tailscale status --json 解析)
    # BackendState 正常时应为 "Running"
    local backend_state=$(tailscale status --json 2>/dev/null | grep -o '"BackendState": *"[^"]*"' | cut -d'"' -f4)
    
    if [ "$backend_state" != "Running" ]; then
        return 1 # 状态不是 Running，可能是 Stopped(下线) 或 NeedsLogin 或其它异常
    fi

    return 0
}

log_msg "[INFO] Tailscale Monitor 已启动..."

while true; do
    if ! check_ts_status; then
        sleep 10
        # 连续两次检测失败，确认状态异常，执行抢救逻辑
        if ! check_ts_status; then
            log_msg "[WARN] Tailscale 状态异常，正在尝试重启并重新连接..."
            
            # 1. 强行重启底层守护进程
            systemctl restart tailscaled
            sleep 20
            
            # 2. 尝试重新连接
            # 不使用 Auth Key，直接拉起保存的本地配置。
            # --timeout=30s 是极重要的核心保护机制：防止脚本永久死锁
            tailscale up --timeout=30s
            
            log_msg "[INFO] Tailscale 已完成重启流程。"
        fi
    fi
    # 周期性扫描间隔，默认 3 分钟
    sleep 180
done
