# 树莓派5媒体中心

专为树莓派5设计的媒体中心方案，集成下载和文件共享功能，完美配合 Apple TV + Infuse 实现家庭影音播放。

## 功能概览

### 下载管理
- **Aria2 + AriaNg**
  - 支持多种下载协议（HTTP/BT/磁力链接）
  - 美观的Web管理界面
  - 支持远程操作和管理

### 文件共享
- **Samba**
  - 高性能局域网文件共享
  - 完美兼容 Apple TV + Infuse 组合
  - 支持全平台访问（Windows/macOS/iOS）

### 影音播放
- **Apple TV + Infuse**
  - 支持几乎所有主流视频格式
  - 自动下载影片元数据
  - 优秀的播放体验和界面

## 快速开始

1. 下载并安装：
```bash
wget https://raw.githubusercontent.com/YYvanYang/raspberry-pi-media-server/main/media-server-installer.sh
chmod +x media-server-installer.sh
sudo ./media-server-installer.sh
```

2. 配置下载工具：
```bash
# 访问 AriaNg Web界面
http://树莓派IP/ariang/
```

3. 设置媒体目录：
```
~/media/
├── movies/     # 电影
├── tv/         # 剧集
├── music/      # 音乐
└── downloads/  # 下载目录
```

## 媒体播放设置

### Apple TV + Infuse 设置教程

1. **准备工作**
   - Apple TV 已连接到局域网
   - 在 App Store 下载安装 Infuse
   - 确保树莓派 Samba 服务正常运行

2. **Infuse 配置步骤**
   - 打开 Infuse
   - 点击"添加共享"（Add Share）
   - 选择"SMB"作为共享类型
   - 输入以下信息：
     - 地址：树莓派IP（如：192.168.1.100）
     - 共享名：Media
     - 用户名：pi（或你的用户名）
     - 密码：你的 Samba 密码
   - 选择要导入的媒体文件夹

3. **文件命名建议**
   - 电影：`电影名 (年份).扩展名`
     - 示例：`海上钢琴师 (1998).mkv`
   - 剧集：`剧集名/季/SxxExx.扩展名`
     - 示例：`黑镜/Season 1/S01E01.mkv`

4. **最佳实践**
   - 使用有线网络连接
   - 定期整理媒体文件结构
   - 保持一致的命名规范

## 服务配置

### Aria2 + AriaNg
- 地址：`http://树莓派IP/ariang/`
- 首次配置：
  1. 点击设置图标
  2. 配置 RPC：
     - 地址：`http://树莓派IP:6800/jsonrpc`
     - 密钥：见 `~/media_server_info.txt`

### Samba 文件共享
- Windows：`\\树莓派IP\Media`
- macOS：`smb://树莓派IP/Media`
- 凭据：见安装日志

## 性能优化

### 存储配置
- 系统：高速 SD 卡或 SSD
- 媒体：USB 3.0 硬盘
- 文件系统：ext4

### 网络优化
- 使用有线网络
- 开启巨型帧（MTU 9000）
- 优化 Samba 配置

## 常见问题

### 1. Infuse 无法连接
- 检查 Samba 服务状态
- 验证网络连接
- 确认用户名密码正确

### 2. AriaNg 连接失败
- 检查 RPC 密钥配置
- 确认 Aria2 服务状态
- 查看错误日志

### 3. 播放卡顿
- 检查网络带宽
- 确认视频编码格式
- 查看存储设备性能

## 维护指南

### 日常维护
```bash
# 更新系统
sudo apt update && sudo apt upgrade -y

# 检查服务
systemctl status aria2 smbd

# 查看空间
df -h
```

### 配置文件位置
- Aria2：`~/.aria2/aria2.conf`
- Samba：`/etc/samba/smb.conf`
- 服务信息：`~/media_server_info.txt`

## 问题反馈

反馈时请提供：
1. 树莓派5型号和系统版本
2. 详细错误信息
3. 相关日志

## 更新记录

- 2025.01.14
  - 优化媒体中心架构
  - 完善 Apple TV + Infuse 设置指南
  - 改进性能优化建议

## 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件