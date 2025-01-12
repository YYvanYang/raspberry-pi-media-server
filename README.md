# 树莓派5媒体服务器安装脚本

专为树莓派5设计的媒体服务器一键安装/更新脚本，充分利用树莓派5的高性能，提供完整的家庭媒体解决方案。

## 主要功能

- **Jellyfin**: 媒体服务器
  - 支持树莓派5硬件加速转码
  - 支持4K视频播放和转码
  - 智能识别影视信息
  - 跨平台客户端支持
  
- **Aria2 + AriaNg**: 下载工具
  - 支持BT/磁力链接下载
  - 美观的Web管理界面
  - 支持远程下载管理
  
- **Samba**: 网络文件共享
  - 高性能文件共享
  - 优化的性能配置
  - 支持中文处理

## 系统要求

- Raspberry Pi 5
  - 支持所有内存版本（4GB/8GB）
  - 推荐8GB内存版本以获得最佳性能
- Raspberry Pi OS (64位)
  - 基于 Debian 12 (bookworm)
  - 支持官方系统和定制系统
- 存储要求：
  - 系统盘：至少20GB
  - 建议外接USB3.0硬盘存储媒体文件
- 网络：
  - 有线网络（推荐2.5G网口）
  - 支持WiFi 6

## 快速开始

1. 下载安装脚本：
```bash
wget https://raw.githubusercontent.com/用户名/raspberry-pi5-media-server/main/install.sh
```

2. 添加执行权限：
```bash
chmod +x install.sh
```

3. 执行安装：
```bash
sudo ./install.sh
```

## 服务访问

### Jellyfin
- 访问地址：`http://树莓派IP:8096`
- 首次配置：
  - 创建管理员账户
  - 配置媒体库
  - 开启硬件加速
- 支持客户端：
  - Web浏览器
  - iOS/Android应用
  - Apple TV/Android TV
  - Smart TV应用

### Aria2 + AriaNg
- 访问地址：`http://树莓派IP/ariang/`
- 首次配置：
  1. 打开AriaNg
  2. 点击设置图标
  3. 配置RPC连接：
     - 地址：`http://树莓派IP:6800/jsonrpc`
     - 密钥：见 `~/media_server_info.txt`

### Samba共享
- Windows：`\\树莓派IP\Media`
- macOS：`smb://树莓派IP/Media`
- Linux：`smb://树莓派IP/Media`
- 访问凭据：
  - 用户名：系统用户名
  - 密码：见安装日志

## 目录结构

```
~/media/
├── movies/     # 电影目录
├── tv/         # 剧集目录
├── music/      # 音乐目录
└── downloads/  # 下载目录
```

## 性能优化建议

1. 存储配置
   - 系统安装在高速SD卡或SSD
   - 媒体文件存储在USB3.0硬盘
   - 使用ext4文件系统

2. 散热方案
   - 使用官方主动散热器
   - 保持通风良好
   - 监控CPU温度

3. 网络优化
   - 使用有线网络
   - 启用巨型帧（Jumbo frames）
   - 优化网络缓冲区设置

## 常见问题解决

### 1. AriaNg连接失败
- 检查RPC密钥是否正确配置
- 确认Aria2服务状态：`systemctl status aria2`
- 查看RPC密钥：`~/media_server_info.txt`

### 2. Jellyfin播放卡顿
- 检查硬件解码是否启用
- 确认网络带宽充足
- 查看CPU温度和性能

### 3. Samba访问问题
- 检查服务状态：`systemctl status smbd`
- 重置访问密码：`sudo smbpasswd -a 用户名`
- 确认网络连接正常

## 维护指南

### 日常维护
```bash
# 系统更新
sudo apt update && sudo apt upgrade -y

# 空间检查
df -h
du -sh ~/media/*

# 服务状态
systemctl status jellyfin aria2 smbd
```

### 配置文件
- Aria2：`~/.aria2/aria2.conf`
- Jellyfin：`/etc/jellyfin/`
- Samba：`/etc/samba/smb.conf`
- 服务信息：`~/media_server_info.txt`

## 问题反馈

遇到问题请提供：
1. 树莓派5具体型号和系统版本
2. 详细错误信息
3. 安装日志：`/tmp/media_server_install.log`

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件