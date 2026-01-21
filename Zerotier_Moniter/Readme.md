# step1 编写监控脚本

多次检测确认（防止因网络瞬间抖动导致误判重启）和日志滚动记录

```zsh
vim ~/zt-monitor.sh
```

zt-monitor.sh 脚本见当前目录

加点执行权限
```zsh
chmod +x ~/zt-monitor.sh
```

因为脚本中的zerotier-cli每次运行都需要sudo, 不然直接运行会报错(zerotier-cli: authtoken.secret not found or readable), 

为了让脚本在不加 sudo 的情况下运行 zerotier-cli, 我们可以:

将当前用户加入 zerotier-one 用户组, 拥有该组权限的用户可以直接读取密钥
```
sudo usermod -aG zerotier-one $USER
```

# step2 设置触发机制, 尽可能robust

结合 systemd 定时器(能处理开机后的启动依赖, 或者使用Crontab), 目的是让脚本像系统服务一样被管理，可以创建一个 systemd 单元

## 1, 定义要执行的任务

先创建service单元文件
```zsh
sudo vim /etc/systemd/system/zt-monitor.service
```
zt-monitor.service 文件见当前目录


## 2, 定义执行周期

