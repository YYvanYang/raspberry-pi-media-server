# Raspberry Pi Media Server Setup

一个用于在树莓派5上快速部署媒体服务器的一键安装/更新脚本。

## 功能特点

- 支持一键安装和更新
- 自动获取并安装最新版本的组件
- 保留原有配置
- 详细的日志记录
- 自动保存所有服务访问信息

## 包含的服务

1. Jellyfin - 媒体服务器
   - 支持视频、音乐、图片管理和转码
   - 支持硬件加速转码
   - 提供优秀的移动端和TV端应用

2. Aria2 - 下载工具
   - 支持多协议下载
   - 支持BitTorrent和磁力链接
   - 通过AriaNg提供Web界面

3. qBittorrent - BT下载工具
   - 完整的BT下载解决方案
   - 内置搜索功能
   - Web界面管理

4. Samba - 网络文件共享
   - 支持Windows/macOS/Linux访问
   - 自动优化性能配置
   - 中文支持

## 系统要求

- Raspberry Pi 5
- Raspberry Pi OS (64位)
- 至少20GB可用空间
- 建议使用有线网络连接

## 目录结构

```
~/media/
├── movies/     # 电影目录
├── tv/         # 电视剧目录
├── music/      # 音乐目录
└── downloads/  # 下载目录
```

## 安装方法

1. 下载安装脚本：
```bash
wget https://raw.githubusercontent.com/你的用户名/raspberry-pi-media-server/main/media-server-installer.sh
```

2. 添加执行权限：
```bash
chmod +x media-server-installer.sh
```

3. 运行脚本：
```bash
sudo ./media-server-installer.sh
```

## 服务访问

安装完成后，可以通过以下方式访问各个服务：

### 1. Jellyfin
- 网址：`http://树莓派IP:8096`
- 首次访问需要创建管理员账户
- 支持的客户端：
  - 浏览器访问
  - Jellyfin官方App
  - Apple TV
  - Android TV

### 2. AriaNg (Aria2 Web前端)
- 网址：`http://树莓派IP/ariang/`
- 首次使用需要配置Aria2 RPC连接：
  1. 打开AriaNg网页
  2. 点击右上角的齿轮⚙️设置图标
  3. 选择"Aria2 RPC"选项
  4. 填写RPC配置：
     - 协议: http
     - 主机: 树莓派IP
     - 端口: 6800
     - 接口地址: /jsonrpc
     - SSL/TLS: 关闭
     - 密钥: 在 ~/media_server_info.txt 文件中查看 RPC密钥
  5. 如果不设置正确的RPC密钥，会显示"认证失败"的错误

### 3. qBittorrent
- 网址：`http://树莓派IP:8080`
- 默认用户名：admin
- 默认密码：adminadmin
- 建议首次登录后修改密码

### 4. Samba共享
- Windows访问: 在文件资源管理器地址栏输入 `\\树莓派IP\Media`
- macOS访问: 在访达中按 Cmd+K，输入 `smb://树莓派IP/Media`
- Linux访问: 在文件管理器中输入 `smb://树莓派IP/Media`
- 使用系统用户名和安装时设置的Samba密码登录

## 配置文件位置

- Aria2: `~/.aria2/aria2.conf`
- Jellyfin: `/etc/jellyfin/`
- qBittorrent: `~/.config/qBittorrent/`
- Samba: `/etc/samba/smb.conf`
- 服务访问信息: `~/media_server_info.txt`

## 常见问题

### 1. AriaNg显示"认证失败"
- 检查是否正确填写了RPC密钥
- RPC密钥可在 `~/media_server_info.txt` 文件中找到
- 确认Aria2服务正在运行：`systemctl status aria2`

### 2. 无法访问Jellyfin
- 确认服务状态：`systemctl status jellyfin`
- 检查端口是否被占用：`netstat -tlpn | grep 8096`
- 查看错误日志：`journalctl -u jellyfin`

### 3. Samba无法访问
- 确认服务状态：`systemctl status smbd`
- 重置Samba密码：`sudo smbpasswd -a 用户名`
- 检查防火墙设置

### 4. 下载速度慢
- 检查网络连接
- 调整 Aria2 配置中的连接数和最大下载速度
- 使用更多的 BT trackers

## 维护指南

### 日常维护
1. 系统更新
```bash
sudo apt update && sudo apt upgrade -y
```

2. 检查硬盘空间
```bash
df -h
du -sh ~/media/*
```

3. 查看服务状态
```bash
systemctl status jellyfin
systemctl status aria2
systemctl status qbittorrent
systemctl status smbd
```

### 备份建议
建议定期备份以下内容：
1. 配置文件
2. Jellyfin元数据
3. 下载任务列表
4. media_server_info.txt

## 更新记录

- 2025.01.12: 初始版本发布
  - 支持一键安装所有服务
  - 支持自动更新到最新版本
  - 添加详细的日志记录

## 问题反馈

如果遇到问题，请在GitHub Issues中反馈，并附上以下信息：
1. 树莓派型号和系统版本
2. 具体的错误信息
3. /tmp/media_server_install.log 的内容

## License

本项目采用 MIT License - 详见 [LICENSE](LICENSE) 文件