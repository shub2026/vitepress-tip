# Ubuntu 日常使用说明

> 本文档面向 Ubuntu 桌面用户，涵盖系统设置、常用命令、软件管理、网络配置、快捷键等核心内容，帮助您快速上手并高效使用 Ubuntu 系统。

---

## 目录

1. [系统基本信息查看](#1-系统基本信息查看)
2. [系统更新与升级](#2-系统更新与升级)
3. [软件包管理](#3-软件包管理)
4. [文件与目录操作](#4-文件与目录操作)
5. [用户与权限管理](#5-用户与权限管理)
6. [进程与服务管理](#6-进程与服务管理)
7. [磁盘与存储管理](#7-磁盘与存储管理)
8. [网络配置与诊断](#8-网络配置与诊断)
9. [系统服务管理（systemd）](#9-系统服务管理systemd)
10. [压缩与解压](#10-压缩与解压)
11. [文本处理与查看](#11-文本处理与查看)
12. [Shell 快捷键](#12-shell-快捷键)
13. [桌面环境快捷键（GNOME）](#13-桌面环境快捷键gnome)
14. [APT 源配置](#14-apt-源配置)
15. [防火墙配置（UFW）](#15-防火墙配置ufw)
16. [SSH 远程连接](#16-ssh-远程连接)
17. [常用软件安装参考](#17-常用软件安装参考)
18. [系统备份与恢复](#18-系统备份与恢复)
19. [常见问题排查](#19-常见问题排查)
20. [实用技巧与推荐工具](#20-实用技巧与推荐工具)

---

## 1. 系统基本信息查看

| 命令                  | 说明                             |
| --------------------- | -------------------------------- |
| `uname -a`            | 查看内核版本及系统信息           |
| `lsb_release -a`      | 查看 Ubuntu 发行版详细信息       |
| `cat /etc/os-release` | 查看操作系统发行版信息           |
| `hostnamectl`         | 查看主机名、系统架构、内核等     |
| `uptime`              | 查看系统运行时间和负载           |
| `date`                | 查看当前日期和时间               |
| `timedatectl`         | 查看/设置时区                    |
| `free -h`             | 查看内存使用情况（人类可读格式） |
| `df -h`               | 查看磁盘分区使用情况             |
| `du -sh <目录>`       | 查看指定目录的磁盘占用大小       |
| `lscpu`               | 查看 CPU 信息                    |
| `lsblk`               | 列出所有块设备（磁盘/分区）      |
| `lspci`               | 列出 PCI 设备                    |
| `lsusb`               | 列出 USB 设备                    |
| `dmidecode -t system` | 查看硬件信息（需 sudo）          |
| `top` / `htop`        | 实时查看系统资源占用             |

### 示例

```bash
# 查看完整系统信息
hostnamectl

# 查看内存和交换分区
free -h

# 查看磁盘使用
df -hT

# 查看 CPU 型号
lscpu | grep "Model name"
```

---

## 2. 系统更新与升级

```bash
# 更新软件包列表（获取最新索引）
sudo apt update

# 升级所有已安装的软件包（不删除/不新增）
sudo apt upgrade -y

# 智能升级（处理依赖变更，可能删除旧包）
sudo apt full-upgrade -y

# 移除不再需要的依赖包
sudo apt autoremove -y

# 清理下载的缓存包
sudo apt clean

# 一键执行：更新 + 升级 + 清理
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean
```

> **提示**：建议定期执行更新，保持系统安全。可使用 `unattended-upgrades` 配置自动安全更新。

---

## 3. 软件包管理

### 3.1 APT 包管理（核心）

```bash
# 搜索软件包
apt search <关键词>

# 查看软件包详细信息
apt show <包名>

# 安装软件包
sudo apt install <包名>

# 卸载软件包（保留配置文件）
sudo apt remove <包名>

# 完全卸载（删除配置文件）
sudo apt purge <包名>

# 重新安装
sudo apt reinstall <包名>

# 列出已安装的包
apt list --installed

# 列出可升级的包
apt list --upgradable

# 查找某个文件属于哪个包
apt-file search <文件名>
# 需先安装：sudo apt install apt-file && sudo apt-file update
```

### 3.2 DEB 包安装

```bash
# 安装本地 .deb 文件
sudo dpkg -i package.deb

# 修复依赖问题
sudo apt install -f

# 卸载 .deb 包
sudo dpkg -r package_name

# 查看已安装的 deb 包列表
dpkg -l | grep <关键词>
```

### 3.3 Snap 包管理

```bash
# 搜索
snap find <关键词>

# 安装
sudo snap install <包名>

# 列出已安装
snap list

# 卸载
sudo snap remove <包名>

# 更新
sudo snap refresh <包名>
```

### 3.4 Flatpak 包管理

```bash
# 安装 Flatpak（如未安装）
sudo apt install flatpak

# 添加 Flathub 仓库
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# 搜索
flatpak search <关键词>

# 安装
flatpak install flathub <包名>

# 列出已安装
flatpak list

# 卸载
flatpak uninstall <包名>

# 更新
flatpak update
```

### 3.5 PPA（个人软件包归档）

```bash
# 添加 PPA
sudo add-apt-repository ppa:<用户名>/<仓库名>

# 移除 PPA
sudo add-apt-repository --remove ppa:<用户名>/<仓库名>

# 查看已添加的 PPA
ls /etc/apt/sources.list.d/
```

---

## 4. 文件与目录操作

### 4.1 基本操作

```bash
# 列出目录内容
ls              # 简要列表
ls -la          # 详细列表（含隐藏文件）
ls -lhS         # 按文件大小排序
ls -lt          # 按修改时间排序

# 切换目录
cd ~            # 回到主目录
cd ..           # 返回上级目录
cd -            # 返回上一次所在目录

# 显示当前路径
pwd

# 创建目录
mkdir <目录名>
mkdir -p a/b/c  # 递归创建多级目录

# 创建文件
touch <文件名>
```

### 4.2 复制、移动、删除

```bash
# 复制
cp source dest          # 复制文件
cp -r source_dir/ dest/ # 递归复制目录

# 移动 / 重命名
mv old_name new_name   # 重命名
mv file /path/to/dest/ # 移动文件

# 删除
rm file     # 删除文件
rm -r dir/  # 递归删除目录
rm -rf dir/ # 强制递归删除（谨慎使用！）
```

> ⚠️ **警告**：`rm -rf` 命令不可逆，使用前务必确认路径正确。

### 4.3 查找文件

```bash
# 按名称查找
find /path -name "*.txt"

# 按类型查找（f=文件, d=目录）
find /path -type f

# 按大小查找（+100M 表示大于 100MB）
find /path -size +100M

# 按修改时间查找（-7 表示 7 天内）
find /path -mtime -7

# 快速定位命令位置
which <命令名>
whereis <命令名>

# 使用 locate 快速查找（需先 updatedb）
sudo apt install mlocate
sudo updatedb
locate <文件名>
```

### 4.4 链接

```bash
# 创建软链接（快捷方式）
ln -s /path/to/target /path/to/link

# 创建硬链接
ln /path/to/target /path/to/link
```

### 4.5 文件权限

```bash
# 查看权限
ls -l

# 修改权限（数字方式）
chmod 755 file     # rwxr-xr-x
chmod 644 file     # rw-r--r--
chmod +x script.sh # 添加可执行权限

# 修改所有者
sudo chown user:group file

# 递归修改目录权限
chmod -R 755 dir/
sudo chown -R user:group dir/
```

**权限数字对照表**：

| 数字 | 权限 | 说明               |
| ---- | ---- | ------------------ |
| 7    | rwx  | 读取 + 写入 + 执行 |
| 6    | rw-  | 读取 + 写入        |
| 5    | r-x  | 读取 + 执行        |
| 4    | r--  | 仅读取             |
| 0    | ---  | 无权限             |

---

## 5. 用户与权限管理

```bash
# 查看当前用户
whoami
id

# 查看所有用户
cat /etc/passwd | grep -v nologin | grep -v false

# 创建新用户
sudo adduser <用户名>

# 删除用户（保留主目录）
sudo deluser <用户名>

# 删除用户及其主目录
sudo deluser --remove-home <用户名>

# 修改用户密码
passwd
sudo passwd <用户名>

# 将用户加入用户组
sudo usermod -aG <组名> <用户名>

# 查看用户所属组
groups <用户名>

# 切换用户
su - <用户名>

# 以 root 权限执行命令
sudo <命令>

# 查看 sudo 日志
cat /var/log/auth.log | grep sudo
```

### 常用用户组

| 组名       | 说明             |
| ---------- | ---------------- |
| `sudo`     | sudo 权限用户组  |
| `docker`   | Docker 使用权限  |
| `www-data` | Web 服务器用户   |
| `plugdev`  | 可热插拔设备权限 |
| `cdrom`    | 光驱访问权限     |

---

## 6. 进程与服务管理

```bash
# 查看进程
ps aux                  # 所有进程
ps aux | grep <关键词>  # 过滤进程
pstree                  # 树形显示进程关系

# 实时监控
top                     # 基础监控
htop                    # 增强版（需安装：sudo apt install htop）

# 终止进程
kill <PID>              # 正常终止
kill -9 <PID>           # 强制终止
killall <进程名>        # 按名称终止所有匹配进程
pkill <进程名>          # 按模式匹配终止

# 后台运行
command &               # 后台运行
nohup command &         # 后台运行，关闭终端不中断
jobs                    # 查看后台任务
fg %1                   # 将后台任务调到前台
bg %1                   # 让暂停的任务在后台继续

# 查看端口占用
sudo ss -tlnp          # 查看所有监听端口
sudo lsof -i :<端口号>  # 查看指定端口被哪个进程占用
```

---

## 7. 磁盘与存储管理

### 7.1 磁盘查看

```bash
# 查看磁盘分区
lsblk
sudo fdisk -l

# 查看文件系统使用情况
df -hT

# 查看指定目录大小
du -sh /path/to/dir
du -h --max-depth=1 /path/to/dir # 查看子目录大小
```

### 7.2 挂载与卸载

```bash
# 挂载设备
sudo mount /dev/sdXn /mnt/point

# 卸载
sudo umount /mnt/point

# 查看挂载信息
mount | column -t
findmnt

# 开机自动挂载：编辑 /etc/fstab
sudo nano /etc/fstab
```

### 7.3 格式化

```bash
# 格式化为 ext4
sudo mkfs.ext4 /dev/sdXn

# 格式化为 NTFS（需安装 ntfs-3g）
sudo mkfs.ntfs /dev/sdXn

# 格式化为 FAT32
sudo mkfs.vfat /dev/sdXn
```

### 7.4 USB 存储设备

```bash
# 查看 USB 设备
lsusb
dmesg | tail # 查看最近的系统日志，确认设备识别

# 自动挂载的 USB 通常在 /media/<用户名>/ 下
```

---

## 8. 网络配置与诊断

### 8.1 网络信息查看

```bash
# 查看所有网络接口和 IP
ip addr
# 或简写
ip a

# 查看路由表
ip route

# 查看网络连接
ss -tuln # 查看监听端口
ss -tun  # 查看所有连接

# 查看 DNS 配置
cat /etc/resolv.conf
resolvectl status # systemd-resolved 方式

# 查看无线网络
iwconfig               # 传统方式
nmcli device wifi list # NetworkManager 方式
```

### 8.2 网络诊断

```bash
# 测试连通性
ping -c 4 example.com

# 跟踪路由
traceroute example.com
# 或
tracepath example.com

# DNS 查询
nslookup example.com
dig example.com

# 下载测试
wget https://example.com
curl -I https://example.com # 仅查看响应头

# 测试带宽
sudo apt install speedtest-cli
speedtest-cli
```

### 8.3 网络配置（Netplan）

Ubuntu 18.04+ 使用 Netplan 管理网络配置：

```bash
# 配置文件位置
ls /etc/netplan/

# 编辑配置（示例：设置静态 IP）
sudo nano /etc/netplan/01-network-manager-all.yaml
```

静态 IP 配置示例：

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

```bash
# 应用配置
sudo netplan apply
```

### 8.4 NetworkManager（nmcli）

```bash
# 查看所有连接
nmcli connection show

# 连接 Wi-Fi
nmcli device wifi connect "SSID" password "密码"

# 查看设备状态
nmcli device status

# 设置静态 IP
nmcli connection modify "连接名" ipv4.addresses 192.168.1.100/24
nmcli connection modify "连接名" ipv4.gateway 192.168.1.1
nmcli connection modify "连接名" ipv4.dns "8.8.8.8 8.8.4.4"
nmcli connection up "连接名"
```

---

## 9. 系统服务管理（systemd）

```bash
# 查看服务状态
systemctl status <服务名>

# 启动 / 停止 / 重启服务
sudo systemctl start <服务名>
sudo systemctl stop <服务名>
sudo systemctl restart <服务名>

# 开机自启 / 禁止自启
sudo systemctl enable <服务名>
sudo systemctl disable <服务名>

# 查看是否开机自启
systemctl is-enabled <服务名>

# 查看所有服务
systemctl list-units --type=service

# 查看启动失败的服务
systemctl --failed

# 查看服务日志
journalctl -u <服务名>
journalctl -u <服务名> -f       # 实时跟踪日志
journalctl -u <服务名> --since today  # 今天的日志
```

### 常用服务名称

| 服务名           | 说明              |
| ---------------- | ----------------- |
| `ssh`            | SSH 远程登录服务  |
| `nginx`          | Nginx Web 服务器  |
| `apache2`        | Apache Web 服务器 |
| `mysql`          | MySQL 数据库      |
| `docker`         | Docker 容器服务   |
| `cron`           | 定时任务服务      |
| `ufw`            | 防火墙服务        |
| `NetworkManager` | 网络管理器        |
| `gdm3`           | GNOME 显示管理器  |

---

## 10. 压缩与解压

| 格式               | 压缩命令                          | 解压命令                   |
| ------------------ | --------------------------------- | -------------------------- |
| `.tar`             | `tar cvf archive.tar files/`      | `tar xvf archive.tar`      |
| `.tar.gz` / `.tgz` | `tar czvf archive.tar.gz files/`  | `tar xzvf archive.tar.gz`  |
| `.tar.bz2`         | `tar cjvf archive.tar.bz2 files/` | `tar xjvf archive.tar.bz2` |
| `.tar.xz`          | `tar cJvf archive.tar.xz files/`  | `tar xJvf archive.tar.xz`  |
| `.zip`             | `zip -r archive.zip files/`       | `unzip archive.zip`        |
| `.rar`             | `rar a archive.rar files/`        | `unrar x archive.rar`      |
| `.7z`              | `7z a archive.7z files/`          | `7z x archive.7z`          |

> **参数说明**：`c`=创建, `x`=解压, `v`=显示过程, `f`=指定文件名, `z`=gzip, `j`=bzip2, `J`=xz

---

## 11. 文本处理与查看

### 11.1 查看文件内容

```bash
cat file.txt        # 输出全部内容
less file.txt       # 分页查看（q 退出）
head -n 20 file.txt # 查看前 20 行
tail -n 20 file.txt # 查看后 20 行
tail -f file.log    # 实时跟踪文件末尾（常用于查看日志）
```

### 11.2 搜索与过滤

```bash
# grep 搜索
grep "关键词" file.txt
grep -i "关键词" file.txt # 忽略大小写
grep -r "关键词" /path/   # 递归搜索目录
grep -n "关键词" file.txt # 显示行号
grep -v "排除词" file.txt # 反向匹配

# 常用管道组合
cat file.txt | grep "error" | sort | uniq -c
ps aux | grep python
dmesg | grep -i usb
```

### 11.3 文本处理工具

```bash
# 排序
sort file.txt
sort -rn file.txt # 按数字倒序

# 去重
uniq # 需先排序
sort file.txt | uniq
sort file.txt | uniq -c # 统计重复次数

# 列/字段提取
cut -d',' -f1,3 file.csv  # 以逗号分隔，提取第1和第3列
awk '{print $1, $3}' file # 打印第1和第3列

# 字数统计
wc -l file.txt # 行数
wc -w file.txt # 单词数
wc -c file.txt # 字符数

# 文本替换
sed 's/旧/新/g' file.txt    # 替换所有匹配
sed -i 's/旧/新/g' file.txt # 直接修改文件
```

### 11.4 编辑器

```bash
nano file.txt # 新手友好，Ctrl+O 保存，Ctrl+X 退出
vim file.txt  # 高效编辑器，按 i 进入编辑模式，Esc 后 :wq 保存退出
```

---

## 12. Shell 快捷键

### 光标移动

| 快捷键     | 说明         |
| ---------- | ------------ |
| `Ctrl + A` | 移到行首     |
| `Ctrl + E` | 移到行尾     |
| `Ctrl + B` | 左移一个字符 |
| `Ctrl + F` | 右移一个字符 |
| `Alt + B`  | 左移一个单词 |
| `Alt + F`  | 右移一个单词 |

### 编辑操作

| 快捷键     | 说明                 |
| ---------- | -------------------- |
| `Ctrl + U` | 删除光标前的所有内容 |
| `Ctrl + K` | 删除光标后的所有内容 |
| `Ctrl + W` | 删除光标前的一个单词 |
| `Ctrl + L` | 清屏（等同 clear）   |
| `Ctrl + _` | 撤销上一次操作       |
| `Ctrl + T` | 交换光标前两个字符   |

### 历史与控制

| 快捷键     | 说明                           |
| ---------- | ------------------------------ |
| `Ctrl + R` | 反向搜索历史命令               |
| `Ctrl + C` | 中断当前命令                   |
| `Ctrl + D` | 退出当前 Shell                 |
| `Ctrl + Z` | 暂停当前命令（fg 恢复）        |
| `↑` / `↓`  | 浏览历史命令                   |
| `Tab`      | 自动补全（按两次显示所有选项） |

---

## 13. 桌面环境快捷键（GNOME）

### 系统快捷键

| 快捷键                    | 说明                 |
| ------------------------- | -------------------- |
| `Super`                   | 打开活动概览         |
| `Super + L`               | 锁定屏幕             |
| `Super + D`               | 显示桌面             |
| `Super + A`               | 打开应用程序列表     |
| `Super + E`               | 打开文件管理器       |
| `Super + S` / `Super + ↓` | 查看所有窗口（概览） |
| `Super + ↑`               | 切换工作区           |
| `Ctrl + Alt + T`          | 打开终端             |
| `Ctrl + Alt + Del`        | 注销                 |
| `Ctrl + Alt + L`          | 锁定屏幕             |
| `Print Screen`            | 截取全屏             |
| `Alt + Print Screen`      | 截取当前窗口         |
| `Shift + Print Screen`    | 选区截图             |

### 窗口管理

| 快捷键                   | 说明                   |
| ------------------------ | ---------------------- |
| `Alt + Tab`              | 切换窗口               |
| `Alt + F4`               | 关闭窗口               |
| `Alt + F7`               | 移动窗口               |
| `Alt + F8`               | 调整窗口大小           |
| `Super + ←` / `→`        | 窗口左/右半屏          |
| `Super + ↑` / `↓`        | 窗口最大化/还原        |
| `Ctrl + Super + ↑/↓/←/→` | 将窗口移动到指定工作区 |

---

## 14. APT 源配置

### 14.1 查看当前源

```bash
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d/
```

### 14.2 更换为国内镜像源

```bash
# 备份原有源
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# 编辑源文件
sudo nano /etc/apt/sources.list
```

**阿里云镜像源示例（Ubuntu 24.04 LTS）**：

```
deb http://mirrors.aliyun.com/ubuntu/ noble main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ noble-security main restricted universe multiverse
```

**常用国内镜像**：

| 镜像站   | 地址                           |
| -------- | ------------------------------ |
| 阿里云   | `mirrors.aliyun.com`           |
| 清华大学 | `mirrors.tuna.tsinghua.edu.cn` |
| 中科大   | `mirrors.ustc.edu.cn`          |
| 华为云   | `mirrors.huaweicloud.com`      |
| 网易     | `mirrors.163.com`              |

```bash
# 更换后执行
sudo apt update
```

### 14.3 使用图形界面更换源

```
设置 → 关于 → 软件和更新 → 下载自 → 选择镜像站点
```

---

## 15. 防火墙配置（UFW）

```bash
# 查看防火墙状态
sudo ufw status

# 启用 / 禁用防火墙
sudo ufw enable
sudo ufw disable

# 允许端口
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22

# 允许特定 IP
sudo ufw allow from 192.168.1.0/24

# 删除规则
sudo ufw delete allow 80/tcp

# 拒绝端口
sudo ufw deny 3306/tcp

# 查看详细规则
sudo ufw status verbose

# 重置防火墙
sudo ufw reset
```

---

## 16. SSH 远程连接

### 16.1 安装与启动 SSH 服务

```bash
# 安装 OpenSSH 服务器
sudo apt install openssh-server

# 启动并设置开机自启
sudo systemctl enable --now ssh

# 查看状态
sudo systemctl status ssh
```

### 16.2 SSH 连接

```bash
# 基本连接
ssh user@hostname

# 指定端口
ssh -p 2222 user@hostname

# 使用密钥登录
ssh -i ~/.ssh/id_rsa user@hostname
```

### 16.3 SSH 密钥配置

```bash
# 生成密钥对
ssh-keygen -t ed25519 -C "your_email@example.com"

# 将公钥复制到远程服务器
ssh-copy-id user@hostname

# 或手动复制
cat ~/.ssh/id_ed25519.pub | ssh user@hostname "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### 16.4 SSH 安全配置

```bash
sudo nano /etc/ssh/sshd_config
```

推荐配置项：

```
Port 22                    # 修改默认端口
PermitRootLogin no         # 禁止 root 直接登录
PasswordAuthentication no  # 仅允许密钥登录
PubkeyAuthentication yes   # 允许公钥认证
```

```bash
# 修改后重启 SSH 服务
sudo systemctl restart ssh
```

---

## 17. 常用软件安装参考

### 开发工具

```bash
# Git
sudo apt install git

# Python 开发环境
sudo apt install python3 python3-pip python3-venv

# Node.js（通过 NodeSource）
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install nodejs

# Java（OpenJDK）
sudo apt install openjdk-21-jdk

# Docker
sudo apt install docker.io
sudo usermod -aG docker $USER # 免 sudo 使用 docker

# VS Code
sudo snap install code --classic
```

### 常用工具

```bash
# 下载工具
sudo apt install wget curl

# 压缩工具
sudo apt install p7zip-full unrar zip

# 系统监控
sudo apt install htop neofetch

# 网络工具
sudo apt install net-tools dnsutils traceroute

# 文本编辑器
sudo apt install vim nano

# 截图工具
sudo apt install flameshot

# 终端增强
sudo apt install terminator                                                          # 多标签终端
sudo apt install zsh                                                                 # Zsh Shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" # Oh My Zsh
```

### 多媒体

```bash
# VLC 播放器
sudo apt install vlc

# 图片编辑
sudo apt install gimp

# 音频编辑
sudo apt install audacity
```

---

## 18. 系统备份与恢复

### 18.1 Timeshift（系统快照备份）

```bash
# 安装
sudo apt install timeshift

# 图形界面启动
sudo timeshift-gtk
```

> Timeshift 类似 Windows 的系统还原，可对系统进行快照备份和恢复，推荐使用 RSYNC 模式。

### 18.2 手动备份常用命令

```bash
# 备份 home 目录
tar czvf backup_home_$(date +%Y%m%d).tar.gz /home/user/

# 备份已安装软件包列表
dpkg --get-selections > installed_packages.txt

# 恢复软件包列表
sudo dpkg --set-selections < installed_packages.txt
sudo apt-get dselect-upgrade

# 备份 APT 源
tar czvf apt_sources_backup.tar.gz /etc/apt/sources.list /etc/apt/sources.list.d/
```

### 18.3 Clonezilla（磁盘克隆）

适用于完整的磁盘/分区备份和恢复，需从 Live USB 启动使用。

---

## 19. 常见问题排查

### 19.1 依赖问题

```bash
# 修复损坏的安装
sudo dpkg --configure -a
sudo apt install -f
```

### 19.2 磁盘空间不足

```bash
# 查看磁盘使用
df -h

# 查找大文件
sudo du -ah / | sort -rh | head -20

# 清理 APT 缓存
sudo apt clean
sudo apt autoremove

# 清理 Snap 旧版本
sudo snap list --all | awk '/disabled/{print $1, $3}' | while read name rev; do sudo snap remove "$name" --revision="$rev"; done

# 清理系统日志
sudo journalctl --vacuum-time=7d
```

### 19.3 无法联网

```bash
# 重启网络服务
sudo systemctl restart NetworkManager

# 检查 DNS
resolvectl status
ping 8.8.8.8    # 测试 IP 连通性
ping google.com # 测试 DNS 解析

# 重置网络配置
sudo nmcli networking off && sudo nmcli networking on
```

### 19.4 修复 GRUB 引导

```bash
sudo update-grub
```

### 19.5 查看系统日志

```bash
# 系统日志
journalctl -xe

# 内核日志
dmesg

# 认证日志
cat /var/log/auth.log

# 应用日志
cat /var/log/syslog
```

---

## 20. 实用技巧与推荐工具

### 20.1 命令别名（alias）

编辑 `~/.bashrc` 或 `~/.zshrc`：

```bash
# 常用别名
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias update='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y'
alias ports='ss -tlnp'
alias ..='cd ..'
alias ...='cd ../..'
alias cls='clear'

# 应用修改
source ~/.bashrc
```

### 20.2 命令行效率工具

| 工具       | 安装                        | 说明               |
| ---------- | --------------------------- | ------------------ |
| `htop`     | `sudo apt install htop`     | 交互式进程监控     |
| `ncdu`     | `sudo apt install ncdu`     | 交互式磁盘使用分析 |
| `tldr`     | `sudo apt install tldr`     | 简化版 man 手册    |
| `bat`      | `sudo apt install bat`      | 带语法高亮的 cat   |
| `fzf`      | `sudo apt install fzf`      | 模糊搜索工具       |
| `tree`     | `sudo apt install tree`     | 目录树形显示       |
| `jq`       | `sudo apt install jq`       | JSON 处理工具      |
| `ncdu`     | `sudo apt install ncdu`     | 磁盘使用分析       |
| `neofetch` | `sudo apt install neofetch` | 系统信息展示       |
| `zoxide`   | `sudo apt install zoxide`   | 智能目录跳转       |

### 20.3 使用 `tldr` 替代 man

```bash
tldr tar
tldr find
tldr systemctl
```

### 20.4 使用 `tree` 查看目录结构

```bash
tree -L 2 /path/to/dir # 显示 2 层深度
tree -a                # 包含隐藏文件
```

### 20.5 快速创建 Python 虚拟环境

```bash
python3 -m venv myenv
source myenv/bin/activate
# 退出虚拟环境
deactivate
```

### 20.6 使用 `history` 管理命令历史

```bash
history              # 查看历史命令
history | grep "关键词" # 搜索历史
!!                   # 执行上一条命令
sudo !!              # 以 sudo 执行上一条命令
!n                   # 执行第 n 条历史命令
```

---

## 附录：Ubuntu 版本代号参考

| 版本  | 代号            | LTS |
| ----- | --------------- | --- |
| 24.04 | Noble Numbat    | ✅  |
| 22.04 | Jammy Jellyfish | ✅  |
| 20.04 | Focal Fossa     | ✅  |
| 18.04 | Bionic Beaver   | ✅  |

---

> **文档版本**：v1.0
> **适用系统**：Ubuntu 20.04 / 22.04 / 24.04 LTS
> **最后更新**：2025 年
