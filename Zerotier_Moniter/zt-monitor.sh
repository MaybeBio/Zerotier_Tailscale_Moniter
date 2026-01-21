#!/bin/zsh

# 配置部分
NETWORK_ID="我们的16位网络ID"  # 填入我们的 ZeroTier Network ID, 详见zerotier官网控制台
LOG_FILE="$HOME/zt-monitor.log"

# 获取当前状态
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

# 逻辑判断：如果连续两次检测都失败（间隔5秒），才执行重启
if ! check_status; then
    sleep 10
    if ! check_status; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [警告] ZeroTier 状态异常，正在尝试重启服务..." >> "$LOG_FILE"
        
        # 尝试重启服务（由于重启服务需要 root，这里需要脚本有 sudo 权限或以 root 运行）
        sudo systemctl restart zerotier-one
        
        # 给服务几秒钟启动时间再尝试重新加入网络
        sleep 10
        zerotier-cli join "$NETWORK_ID"
        
        echo "$(date '+%Y-%m-%d %H:%M:%S') - [信息] 重启指令已发出。" >> "$LOG_FILE"
    fi
fi
