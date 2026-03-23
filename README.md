# Zerotier_Tailscale_Moniter
Moniter Zerotier or Tailscale


## How to execute the script
```shell
# 1. Grant execute permission to the script
chmod +x /data2/Zerotier_Tailscale_Moniter/Zerotier_Moniter/zt-monitor.sh
chmod +x /data2/Zerotier_Tailscale_Moniter/Tailscale_Moniter/ts-monitor.sh

# 2. Copy (or soft-link) the service file to the system's systemd directory
sudo cp /data2/Zerotier_Tailscale_Moniter/Zerotier_Moniter/zt-monitor.service /etc/systemd/system/
sudo cp /data2/Zerotier_Tailscale_Moniter/Tailscale_Moniter/ts-monitor.service /etc/systemd/system/

# 3. Reload the system services and start them
sudo systemctl daemon-reload
sudo systemctl start zt-monitor.service
sudo systemctl start ts-monitor.service

# 4. The most important step: set it to start automatically on boot
sudo systemctl enable zt-monitor.service
sudo systemctl enable ts-monitor.service

```

## How to monitor the service

Run
```shell
sudo systemctl status zt-monitor.service
sudo systemctl status ts-monitor.service
```

to check `Active: active (running)`

Or if there are a lot of echo commands in the .sh script, we can check it in the log 
```shell
sudo journalctl -u zt-monitor.service -f
sudo journalctl -u ts-monitor.service -f
```

Or we can just `tail -f` the log we wrote in the .sh script
```shell
tail -f /var/log/zt-monitor.log
```