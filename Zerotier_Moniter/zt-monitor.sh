#!/bin/bash

# 配置部分
NETWORK_ID="我们的network ID"    # 填入我们的 ZeroTier Network ID, 在网页端控制台中查看
LOG_FILE="/var/log/zt-monitor.log" # 推荐放在系统级日志目录 /var/log 中
    
log_msg() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

check_status() {
    # 检查基础服务是否在线, online
    local info_status=$(zerotier-cli info | awk '{print $5}')
    # 检查是否加入了特定网络, ok
    local list_status=$(zerotier-cli listnetworks | grep "$NETWORK_ID" | awk '{print $6}')

    if [ "$info_status" = "ONLINE" ] && [ "$list_status" = "OK" ]; then
        return 0 # 正常
    else
        return 1 # 异常
    fi
}

log_msg "[INFO] ZeroTier Monitor 已启动..."

# 死循环，利用 sleep 实现周期性
while true; do
    # 逻辑判断：如果连续两次检测都失败（间隔20秒），才执行重启
    if ! check_status; then
        sleep 20
        if ! check_status; then
            log_msg "[WARN] ZeroTier 状态异常，正在尝试重启服务..."
            
            # 使用 root 执行，去掉 sudo 避免密码弹窗
            systemctl restart zerotier-one
            
            # 等待几秒钟让服务跑起来
            sleep 30
            zerotier-cli join "$NETWORK_ID"
            
            log_msg "[INFO] ZeroTier 重启与 Join 指令已下发。"
        fi
    fi
    # 每次检查间隔为 3 分钟 (180秒)，可根据需调整
    sleep 180
done
