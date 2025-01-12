#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 日志函数
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# 检查是否为root用户运行
if [ "$EUID" -ne 0 ]; then 
    error "请使用root权限运行此脚本（使用sudo）"
fi

# 获取当前用户名（非root）
ACTUAL_USER=$(logname)
USER_HOME="/home/$ACTUAL_USER"

# 创建安装日志
INSTALL_LOG="/tmp/media_server_install.log"
exec 1> >(tee -a "$INSTALL_LOG")
exec 2> >(tee -a "$INSTALL_LOG" >&2)

# 检查并安装/更新基础依赖
install_base_dependencies() {
    log "更新系统并安装基础依赖..."
    apt update && apt upgrade -y
    apt install -y curl wget unzip git htop iftop nginx
}

# 安装/更新Aria2
setup_aria2() {
    log "配置Aria2..."
    
    # 安装或更新aria2
    apt install -y aria2
    
    # 创建配置目录
    sudo -u $ACTUAL_USER mkdir -p $USER_HOME/.aria2
    
    # 生成RPC密钥（如果不存在）
    if [ ! -f $USER_HOME/.aria2/aria2.conf ] || ! grep -q "rpc-secret" $USER_HOME/.aria2/aria2.conf; then
        RPC_SECRET=$(openssl rand -hex 16)
    else
        RPC_SECRET=$(grep "rpc-secret=" $USER_HOME/.aria2/aria2.conf | cut -d= -f2)
    fi
    
    # 创建配置文件
    cat > $USER_HOME/.aria2/aria2.conf << EOF
# 基础设置
dir=$USER_HOME/media/downloads
disk-cache=32M
file-allocation=falloc
continue=true
auto-file-renaming=true

# 下载连接相关
max-concurrent-downloads=5
max-connection-per-server=16
min-split-size=10M
split=32
max-overall-download-limit=0
max-download-limit=0
max-overall-upload-limit=1M
max-upload-limit=0

# BT设置
enable-dht=true
enable-dht6=true
enable-peer-exchange=true
bt-enable-lpd=true
bt-max-peers=0
seed-ratio=0.1

# RPC设置
enable-rpc=true
rpc-allow-origin-all=true
rpc-listen-all=true
rpc-listen-port=6800
rpc-secret=${RPC_SECRET}

# 日志设置
log=$USER_HOME/.aria2/aria2.log

# 会话保存
input-file=$USER_HOME/.aria2/aria2.session
save-session=$USER_HOME/.aria2/aria2.session
save-session-interval=60
EOF
    
    # 创建session文件
    sudo -u $ACTUAL_USER touch $USER_HOME/.aria2/aria2.session
    
    # 设置文件权限
    chown -R $ACTUAL_USER:$ACTUAL_USER $USER_HOME/.aria2
    chmod 644 $USER_HOME/.aria2/aria2.conf
    
    # 创建服务
    cat > /etc/systemd/system/aria2.service << EOF
[Unit]
Description=Aria2 Service
After=network.target

[Service]
Type=simple
User=$ACTUAL_USER
ExecStart=/usr/bin/aria2c --conf-path=$USER_HOME/.aria2/aria2.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable aria2
    systemctl restart aria2
}

# 安装/更新AriaNg
setup_ariang() {
    log "配置AriaNg..."
    
    # 获取最新版本号
    LATEST_VERSION=$(curl -s https://api.github.com/repos/mayswind/AriaNg/releases/latest | grep "tag_name" | cut -d'"' -f4)
    log "最新的AriaNg版本是: $LATEST_VERSION"
    
    # 下载并安装最新版本
    wget -O /tmp/AriaNg.zip "https://github.com/mayswind/AriaNg/releases/download/${LATEST_VERSION}/AriaNg-${LATEST_VERSION}.zip"
    rm -rf /var/www/html/ariang/*
    unzip /tmp/AriaNg.zip -d /var/www/html/ariang/
    rm /tmp/AriaNg.zip
    
    # 设置权限
    chown -R www-data:www-data /var/www/html/ariang
    chmod -R 755 /var/www/html/ariang
    
    systemctl restart nginx
}

# 安装/更新Samba
setup_samba() {
    log "配置Samba..."
    
    # 安装或更新samba
    apt install -y samba samba-common-bin
    
    # 备份原配置（如果存在且未备份）
    if [ -f /etc/samba/smb.conf ] && [ ! -f /etc/samba/smb.conf.bak ]; then
        cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
    fi
    
    # 创建新的配置文件
    cat > /etc/samba/smb.conf << EOF
[global]
workgroup = WORKGROUP
server string = Raspberry Pi Media Server
security = user
map to guest = bad user
unix charset = UTF-8
dos charset = cp936

# 性能优化
socket options = TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=131072 SO_SNDBUF=131072
read raw = yes
write raw = yes
use sendfile = yes
aio read size = 16384
aio write size = 16384

[Media]
path = $USER_HOME/media
browseable = yes
read only = no
guest ok = no
create mask = 0644
directory mask = 0755
valid users = $ACTUAL_USER
force user = $ACTUAL_USER
force group = $ACTUAL_USER
EOF
    
    # 如果用户不存在，设置samba密码
    if ! pdbedit -L | grep -q "$ACTUAL_USER"; then
        SAMBA_PASS=$(openssl rand -base64 12)
        (echo $SAMBA_PASS; echo $SAMBA_PASS) | smbpasswd -a $ACTUAL_USER
        log "已为Samba创建新密码：$SAMBA_PASS"
    fi
    
    systemctl restart smbd
    systemctl enable smbd
}

# 创建媒体目录结构
setup_directories() {
    log "创建媒体目录..."
    sudo -u $ACTUAL_USER mkdir -p $USER_HOME/media/{movies,tv,music,downloads}
    chmod -R 755 $USER_HOME/media
}

# 保存服务信息
save_service_info() {
    log "保存服务信息..."
    
    # 获取RPC密钥
    RPC_SECRET=$(grep "rpc-secret=" $USER_HOME/.aria2/aria2.conf | cut -d= -f2)
    
    cat > $USER_HOME/media_server_info.txt << EOF
=== 媒体服务器访问信息 ===

Aria2:
- RPC地址: http://$(hostname -I | cut -d' ' -f1):6800/jsonrpc
- RPC密钥: ${RPC_SECRET}
- Web界面: http://$(hostname -I | cut -d' ' -f1)/ariang/

Samba共享:
- 共享路径: \\\\$(hostname -I | cut -d' ' -f1)\\Media
- 用户名: $ACTUAL_USER
- 如果是新安装，密码请查看上方的安装日志

请妥善保存此文件中的密码信息！
EOF
    
    chown $ACTUAL_USER:$ACTUAL_USER $USER_HOME/media_server_info.txt
    chmod 600 $USER_HOME/media_server_info.txt
}

# 主函数
main() {
    log "开始安装/更新媒体服务器..."
    log "实际用户: $ACTUAL_USER"
    log "家目录: $USER_HOME"
    
    install_base_dependencies
    setup_directories
    setup_aria2
    setup_ariang
    setup_samba
    save_service_info
    
    log "安装/更新完成！"
    log "访问信息已保存到: $USER_HOME/media_server_info.txt"
    log "安装日志已保存到: $INSTALL_LOG"
    
    echo -e "\n${YELLOW}重要提示：${NC}"
    echo -e "1. 首次使用AriaNg时需要配置RPC连接"
    echo -e "2. RPC密钥在 $USER_HOME/media_server_info.txt 文件中"
    echo -e "3. 设置方法请参考README.md的'AriaNg RPC设置'部分"
}

# 执行主函数
main