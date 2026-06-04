# Ubuntu 文件系统架构与挂载详解

> 本文档系统介绍 Linux 文件系统层次结构（FHS）、挂载的核心概念，以及硬盘、U盘、网络文件系统等各类挂载操作实践。

---

## 目录

1. [Linux 文件系统层次结构标准（FHS）](#1-linux-文件系统层次结构标准fhs)
2. [根目录结构详解](#2-根目录结构详解)
3. [挂载的核心概念](#3-挂载的核心概念)
4. [挂载的基本操作](#4-挂载的基本操作)
5. [挂载本地硬盘](#5-挂载本地硬盘)
6. [挂载 U 盘与移动存储](#6-挂载-u-盘与移动存储)
7. [挂载网络文件系统](#7-挂载网络文件系统)
8. [自动挂载配置（/etc/fstab）](#8-自动挂载配置etcfstab)
9. [挂载相关实用命令](#9-挂载相关实用命令)
10. [常见问题与故障排查](#10-常见问题与故障排查)

---

## 1. Linux 文件系统层次结构标准（FHS）

### 1.1 什么是 FHS？

**FHS（Filesystem Hierarchy Standard，文件系统层次结构标准）** 是 Linux 系统中目录结构的规范标准，定义了各目录的用途和内容。

**核心理念**：
- **一切皆文件**：Linux 将所有资源（设备、进程、网络连接等）都抽象为文件
- **单一根目录**：整个文件系统从根目录 `/` 开始，形成统一的树形结构
- **目录职责明确**：每个目录有特定的用途，便于管理和维护

### 1.2 与 Windows 的对比

| 特性 | Linux | Windows |
|------|-------|---------|
| 根目录 | 单一根目录 `/` | 多个盘符 `C:\` `D:\` 等 |
| 设备访问 | `/dev/sda1` 等设备文件 | 盘符直接访问 |
| 挂载概念 | 设备需挂载到目录才能访问 | 盘符自动分配 |
| 路径分隔符 | `/` | `\` |
| 配置文件位置 | `/etc/` | 注册表 + 各目录 |
| 用户数据位置 | `/home/` | `C:\Users\` |

### 1.3 Linux 文件系统树形结构示意

```
/                          # 根目录
├── bin/                   # 基础命令（所有用户可用）
├── boot/                  # 启动相关文件
├── dev/                   # 设备文件
├── etc/                   # 系统配置文件
├── home/                  # 普通用户主目录
│   ├── user1/
│   └── user2/
├── lib/                   # 系统库文件
├── media/                 # 可移动设备自动挂载点
├── mnt/                   # 临时挂载点
├── opt/                   # 第三方软件安装目录
├── proc/                  # 进程信息（虚拟文件系统）
├── root/                  # root 用户主目录
├── run/                   # 运行时数据
├── sbin/                  # 系统管理命令
├── srv/                   # 服务数据目录
├── sys/                   # 系统信息（虚拟文件系统）
├── tmp/                   # 临时文件
├── usr/                   # 用户程序和数据
│   ├── bin/               # 用户命令
│   ├── lib/               # 用户库文件
│   └── local/             # 本地安装的软件
└── var/                   # 可变数据（日志、缓存等）
    ├── log/               # 日志文件
    ├── cache/             # 缓存数据
    └── tmp/               # 临时文件
```

---

## 2. 根目录结构详解

### 2.1 核心系统目录

| 目录 | 说明 | 示例内容 |
|------|------|----------|
| `/` | 根目录，整个文件系统的起点 | — |
| `/bin` | 基础用户命令，所有用户可用，系统启动必需 | `ls`, `cp`, `mv`, `cat`, `bash` |
| `/sbin` | 系统管理命令，通常需要 root 权限 | `fdisk`, `fsck`, `init`, `reboot` |
| `/lib` | 系统共享库，`/bin` 和 `/sbin` 命令依赖的库 | `*.so` 动态链接库 |
| `/lib64` | 64 位系统库文件 | 64 位共享库 |

> **注意**：现代 Ubuntu 中，`/bin`、`/sbin`、`/lib` 通常是指向 `/usr/bin`、`/usr/sbin`、`/usr/lib` 的符号链接（合并到 usr）。

### 2.2 启动与内核目录

| 目录 | 说明 |
|------|------|
| `/boot` | 启动加载器文件和内核镜像 |
| `/boot/vmlinuz-*` | Linux 内核文件 |
| `/boot/initrd.img-*` | 初始 RAM 磁盘镜像 |
| `/boot/grub/` | GRUB 引导加载器配置 |

### 2.3 设备与虚拟文件系统

| 目录 | 说明 | 特点 |
|------|------|------|
| `/dev` | 设备文件目录 | 每个设备对应一个文件 |
| `/dev/null` | 空设备，丢弃所有写入 | 无限接收，读取为空 |
| `/dev/zero` | 零设备 | 读取时返回无限个 `\0` |
| `/dev/random` | 随机数设备 | 阻塞式随机数 |
| `/dev/urandom` | 非阻塞随机数设备 | 非阻塞式 |
| `/dev/stdin` | 标准输入 | — |
| `/dev/stdout` | 标准输出 | — |
| `/dev/stderr` | 标准错误输出 | — |
| `/dev/sda` | 第一块 SCSI/SATA 硬盘 | 整个磁盘 |
| `/dev/sda1` | 第一块硬盘的第一个分区 | 分区设备 |
| `/dev/tty` | 终端设备 | — |

| 目录 | 说明 | 特点 |
|------|------|------|
| `/proc` | 进程信息虚拟文件系统 | 不占用磁盘空间 |
| `/proc/cpuinfo` | CPU 信息 | `cat /proc/cpuinfo` |
| `/proc/meminfo` | 内存信息 | `cat /proc/meminfo` |
| `/proc/[pid]/` | 指定进程的信息目录 | — |
| `/proc/version` | 内核版本信息 | — |

| 目录 | 说明 | 特点 |
|------|------|------|
| `/sys` | 系统设备信息虚拟文件系统 | 内核对象模型 |
| `/sys/class/` | 设备分类信息 | — |
| `/sys/block/` | 块设备信息 | — |

### 2.4 配置目录

| 目录 | 说明 |
|------|------|
| `/etc` | 系统配置文件目录（纯文本配置） |
| `/etc/passwd` | 用户账户信息 |
| `/etc/shadow` | 用户密码（加密） |
| `/etc/group` | 用户组信息 |
| `/etc/hosts` | 本地主机名解析 |
| `/etc/fstab` | 文件系统挂载配置 |
| `/etc/hostname` | 主机名 |
| `/etc/network/` | 网络配置（旧版） |
| `/etc/netplan/` | 网络配置（Ubuntu 新版） |
| `/etc/ssh/` | SSH 配置 |
| `/etc/apt/` | APT 包管理配置 |
| `/etc/systemd/` | systemd 服务配置 |

### 2.5 用户数据目录

| 目录 | 说明 |
|------|------|
| `/home` | 普通用户主目录的父目录 |
| `/home/username/` | 指定用户的主目录 |
| `/home/username/Documents/` | 用户文档（XDG 标准） |
| `/home/username/Downloads/` | 下载目录 |
| `/home/username/.config/` | 用户应用配置 |
| `/home/username/.local/` | 用户本地数据 |
| `/root` | root 用户的主目录 |

### 2.6 挂载点目录

| 目录 | 说明 |
|------|------|
| `/mnt` | 临时挂载点，管理员手动挂载使用 |
| `/media` | 可移动设备自动挂载点（U盘、光盘等） |
| `/media/username/设备名/` | 用户插入设备后自动挂载的位置 |

### 2.7 程序与数据目录

| 目录 | 说明 |
|------|------|
| `/usr` | Unix System Resources，用户程序和数据 |
| `/usr/bin/` | 用户命令（非系统启动必需） |
| `/usr/sbin/` | 非必需的系统管理命令 |
| `/usr/lib/` | 程序库文件 |
| `/usr/local/` | 本地编译安装的软件 |
| `/usr/share/` | 架构无关的共享数据 |
| `/usr/share/doc/` | 软件文档 |
| `/usr/share/man/` | man 手册页 |

| 目录 | 说明 |
|------|------|
| `/opt` | 第三方大型软件安装目录 |
| `/opt/google/chrome/` | Chrome 浏览器安装位置示例 |

| 目录 | 说明 |
|------|------|
| `/var` | 可变数据目录，系统运行时产生的数据 |
| `/var/log/` | 系统和应用日志 |
| `/var/cache/` | 应用缓存数据 |
| `/var/lib/` | 应用状态数据 |
| `/var/spool/` | 队列数据（打印、邮件等） |
| `/var/tmp/` | 临时文件（重启保留） |

### 2.8 临时目录

| 目录 | 说明 | 特点 |
|------|------|------|
| `/tmp` | 临时文件目录 | 所有用户可写，重启清空 |
| `/var/tmp` | 临时文件目录 | 重启保留 |

---

## 3. 挂载的核心概念

### 3.1 什么是挂载？

**挂载（Mount）** 是将存储设备（硬盘分区、U盘、网络存储等）连接到 Linux 文件系统树中的某个目录，使其内容可被访问的过程。

**核心要点**：
- Linux 不使用盘符（如 C:、D:），而是将设备挂载到目录
- 挂载点（Mount Point）是一个普通目录
- 挂载后，访问该目录就是访问设备中的内容
- 一个设备只能挂载到一个目录，但一个目录可以被多次挂载（后挂载覆盖前挂载）

### 3.2 挂载的本质

```
┌─────────────────┐         ┌─────────────────┐
│   存储设备       │  挂载   │   目录树         │
│  /dev/sdb1      │ ──────► │  /mnt/usb       │
│  (U盘分区)       │         │  (挂载点)        │
└─────────────────┘         └─────────────────┘
                                    │
                                    ▼
                            ┌─────────────────┐
                            │  访问 /mnt/usb  │
                            │  = 访问 U盘内容  │
                            └─────────────────┘
```

**挂载前**：
- `/dev/sdb1` 设备存在，但无法直接读取文件
- `/mnt/usb` 是空目录

**挂载后**：
- 访问 `/mnt/usb` 就是访问 U 盘中的文件
- `/mnt/usb` 中原有的内容被隐藏（直到卸载）

### 3.3 为什么需要挂载？

1. **统一的文件访问方式**：所有存储设备都通过目录访问，无需关心底层设备
2. **灵活的组织结构**：可以将不同设备挂载到任意位置
3. **安全性**：可以控制哪些设备在何时何地可被访问
4. **支持多种文件系统**：Linux 支持挂载 ext4、NTFS、FAT32、网络文件系统等

### 3.4 挂载点选择原则

| 挂载点目录 | 用途 | 说明 |
|------------|------|------|
| `/mnt/` | 临时手动挂载 | 管理员临时挂载设备使用 |
| `/media/username/设备名/` | 可移动设备自动挂载 | 系统自动管理，用户无需手动 |
| 自定义目录 | 特定用途挂载 | 如 `/data/`、`/backup/` |

---

## 4. 挂载的基本操作

### 4.1 查看当前挂载信息

```bash
# 查看所有挂载
mount

# 更清晰的格式
mount | column -t

# 使用 findmnt 查看（推荐）
findmnt

# 查看特定挂载点
findmnt /mnt/usb

# 查看设备挂载情况
lsblk -f    # 显示文件系统类型
df -hT      # 查看已挂载设备的使用情况
```

### 4.2 基本挂载命令

```bash
# 基本语法
sudo mount <设备> <挂载点>

# 示例：将 /dev/sdb1 挂载到 /mnt/usb
sudo mount /dev/sdb1 /mnt/usb

# 指定文件系统类型
sudo mount -t ext4 /dev/sdb1 /mnt/usb
sudo mount -t ntfs /dev/sdb1 /mnt/usb
sudo mount -t vfat /dev/sdb1 /mnt/usb    # FAT32
```

### 4.3 常用挂载选项

```bash
# 只读挂载
sudo mount -o ro /dev/sdb1 /mnt/usb

# 读写挂载（默认）
sudo mount -o rw /dev/sdb1 /mnt/usb

# 不更新访问时间（提高性能）
sudo mount -o noatime /dev/sdb1 /mnt/usb

# 同步写入（数据安全但较慢）
sudo mount -o sync /dev/sdb1 /mnt/usb

# 组合多个选项
sudo mount -o rw,noatime /dev/sdb1 /mnt/usb
```

### 4.4 卸载命令

```bash
# 基本卸载
sudo umount /mnt/usb

# 通过设备卸载
sudo umount /dev/sdb1

# 强制卸载（设备忙时使用，谨慎！）
sudo umount -l /mnt/usb    # 懒卸载，等引用释放后卸载
sudo umount -f /mnt/usb    # 强制卸载（NFS 等）
```

### 4.5 查看设备是否被占用

```bash
# 查看谁在使用挂载点
lsof /mnt/usb

# 查看占用进程
fuser -v /mnt/usb

# 终止占用进程后卸载
fuser -k /mnt/usb
sudo umount /mnt/usb
```

---

## 5. 挂载本地硬盘

### 5.1 查看硬盘信息

```bash
# 列出所有块设备
lsblk

# 查看分区表
sudo fdisk -l

# 查看设备详细信息
sudo blkid

# 查看未挂载的分区
lsblk -f | grep -v "/"
```

**输出示例**：

```
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda      8:0    0 238.5G  0 disk
├─sda1   8:1    0   512M  0 part /boot/efi
├─sda2   8:2    0    50G  0 part /
└─sda3   8:3    0   100G  0 part /home
sdb      8:16   0 465.8G  0 disk
└─sdb1   8:17   0 465.8G  0 part            # 未挂载
```

### 5.2 挂载新硬盘分区

```bash
# 1. 创建挂载点目录
sudo mkdir -p /data

# 2. 挂载分区
sudo mount /dev/sdb1 /data

# 3. 验证挂载
df -h | grep /data
ls /data

# 4. 设置目录权限（如需要）
sudo chown -R $USER:$USER /data
```

### 5.3 挂载 NTFS 格式硬盘（Windows 分区）

```bash
# 安装 NTFS 支持
sudo apt install ntfs-3g

# 挂载 NTFS 分区
sudo mount -t ntfs-3g /dev/sdb1 /mnt/windows

# 或使用默认识别
sudo mount /dev/sdb1 /mnt/windows

# 指定用户权限挂载（避免 root 权限问题）
sudo mount -t ntfs-3g -o uid=1000,gid=1000 /dev/sdb1 /mnt/windows
```

> **说明**：`uid=1000` 通常是第一个普通用户的 UID，可通过 `id -u` 查看。

### 5.4 挂载 exFAT 格式存储

```bash
# 安装 exFAT 支持
sudo apt install exfat-fuse exfat-utils

# 挂载
sudo mount -t exfat /dev/sdb1 /mnt/exfat
```

### 5.5 挂载 LVM 逻辑卷

```bash
# 查看 LVM 卷
sudo lvdisplay

# 挂载逻辑卷
sudo mount /dev/vg01/lv01 /mnt/lvm
```

---

## 6. 挂载 U 盘与移动存储

### 6.1 自动挂载（GNOME 桌面环境）

在 Ubuntu 桌面环境中，插入 U 盘后会**自动挂载**到 `/media/<用户名>/<设备名>/` 目录。

```bash
# 查看自动挂载的设备
ls /media/$USER/

# 或使用 lsblk 查看
lsblk
```

### 6.2 手动挂载 U 盘

```bash
# 1. 插入 U 盘后，查看设备
lsblk
# 假设 U 盘识别为 /dev/sdb1

# 2. 创建挂载点
sudo mkdir -p /mnt/usb

# 3. 挂载（自动识别文件系统类型）
sudo mount /dev/sdb1 /mnt/usb

# 4. 访问 U 盘内容
ls /mnt/usb

# 5. 使用完毕后卸载
sudo umount /mnt/usb
# 或
sudo umount /dev/sdb1
```

### 6.3 挂载 FAT32/U 盘并指定编码

```bash
# 解决中文文件名乱码问题
sudo mount -t vfat -o iocharset=utf8,uid=1000,gid=1000 /dev/sdb1 /mnt/usb
```

### 6.4 安全移除 U 盘

```bash
# 先卸载
sudo umount /dev/sdb1

# 安全移除（停止设备）
udisksctl power-off -b /dev/sdb1
```

### 6.5 挂载光盘/ISO 镜像

```bash
# 挂载物理光驱
sudo mount /dev/sr0 /mnt/cdrom

# 挂载 ISO 镜像文件（回环挂载）
sudo mkdir -p /mnt/iso
sudo mount -o loop ubuntu-24.04.iso /mnt/iso

# 访问 ISO 内容
ls /mnt/iso

# 卸载
sudo umount /mnt/iso
```

---

## 7. 挂载网络文件系统

### 7.1 挂载 NFS 共享

```bash
# 安装 NFS 客户端
sudo apt install nfs-common

# 创建挂载点
sudo mkdir -p /mnt/nfs

# 挂载 NFS 共享
sudo mount -t nfs 192.168.1.100:/shared /mnt/nfs

# 指定版本和选项
sudo mount -t nfs -o vers=4,rw 192.168.1.100:/shared /mnt/nfs

# 查看服务端导出的共享
showmount -e 192.168.1.100
```

### 7.2 挂载 SMB/CIFS 共享（Windows 共享）

```bash
# 安装 CIFS 工具
sudo apt install cifs-utils

# 创建挂载点
sudo mkdir -p /mnt/smb

# 基本挂载
sudo mount -t cifs //192.168.1.100/share /mnt/smb -o username=user,password=pass

# 更安全的凭据文件方式
echo "username=user" > ~/.smbcreds
echo "password=pass" >> ~/.smbcreds
chmod 600 ~/.smbcreds

sudo mount -t cifs //192.168.1.100/share /mnt/smb -o credentials=/home/user/.smbcreds

# 指定 UID/GID 和文件模式
sudo mount -t cifs //192.168.1.100/share /mnt/smb \
  -o credentials=/home/user/.smbcreds,uid=1000,gid=1000,file_mode=0644,dir_mode=0755
```

### 7.3 挂载 SSHFS（通过 SSH 挂载远程目录）

```bash
# 安装 SSHFS
sudo apt install sshfs

# 创建挂载点
mkdir -p ~/remote

# 挂载远程目录
sshfs user@remotehost:/path/to/dir ~/remote

# 卸载
fusermount -u ~/remote
```

### 7.4 挂载 WebDAV

```bash
# 安装 davfs2
sudo apt install davfs2

# 配置凭据（可选）
echo "https://webdav.example.com user password" | sudo tee -a /etc/davfs2/secrets
sudo chmod 600 /etc/davfs2/secrets

# 挂载
sudo mount -t davfs https://webdav.example.com /mnt/webdav
```

---

## 8. 自动挂载配置（/etc/fstab）

### 8.1 fstab 文件简介

`/etc/fstab` 是系统启动时自动挂载文件系统的配置文件。

```bash
# 查看 fstab 内容
cat /etc/fstab
```

**fstab 格式**：

```
<设备>    <挂载点>    <文件系统类型>    <挂载选项>    <dump>    <pass>
```

| 字段 | 说明 |
|------|------|
| 设备 | 设备路径、UUID 或 LABEL |
| 挂载点 | 挂载目录路径 |
| 文件系统类型 | ext4、ntfs、vfat、nfs 等 |
| 挂载选项 | `defaults`、`rw`、`ro`、`noatime` 等 |
| dump | dump 备份工具标志（0=不备份） |
| pass | fsck 检查顺序（0=不检查，1=根分区，2=其他分区） |

### 8.2 使用 UUID 挂载（推荐）

使用 UUID 比设备路径更稳定，不会因设备顺序变化而失效。

```bash
# 查看设备 UUID
sudo blkid

# 或
lsblk -f
```

**fstab 配置示例**：

```bash
# /etc/fstab 示例

# 根分区
UUID=xxxx-xxxx-xxxx-xxxx  /        ext4    defaults,noatime    0    1

# home 分区
UUID=yyyy-yyyy-yyyy-yyyy  /home    ext4    defaults,noatime    0    2

# 数据分区
UUID=zzzz-zzzz-zzzz-zzzz  /data    ext4    defaults,noatime    0    2

# NTFS 分区
UUID=nnnn-nnnn-nnnn-nnnn  /mnt/win  ntfs-3g  defaults,uid=1000,gid=1000  0  0

# FAT32 分区
UUID=ffff-ffff-ffff-ffff  /mnt/usb  vfat    defaults,uid=1000,gid=1000,iocharset=utf8  0  0

# NFS 共享
192.168.1.100:/shared  /mnt/nfs  nfs  defaults  0  0

# SMB/CIFS 共享
//192.168.1.100/share  /mnt/smb  cifs  credentials=/home/user/.smbcreds,uid=1000,gid=1000  0  0

# swap 分区
UUID=ssss-ssss-ssss-ssss  none     swap    sw    0    0
```

### 8.3 常用挂载选项详解

| 选项 | 说明 |
|------|------|
| `defaults` | 默认选项：`rw,suid,dev,exec,auto,nouser,async` |
| `rw` / `ro` | 读写 / 只读 |
| `noatime` | 不更新访问时间，提高性能 |
| `nodiratime` | 不更新目录访问时间 |
| `sync` / `async` | 同步 / 异步 I/O |
| `user` | 允许普通用户挂载 |
| `users` | 允许任何用户挂载和卸载 |
| `nofail` | 设备不存在时不报错（可移动设备） |
| `x-systemd.automount` | 按需自动挂载（访问时才挂载） |
| `x-systemd.idle-timeout=10min` | 空闲 10 分钟后自动卸载 |
| `uid=1000,gid=1000` | 指定所有者（FAT/NTFS） |
| `umask=022` | 设置默认权限掩码 |
| `iocharset=utf8` | 设置字符编码 |

### 8.4 添加自动挂载步骤

```bash
# 1. 查看设备 UUID
sudo blkid /dev/sdb1
# 输出：/dev/sdb1: UUID="a1b2c3d4-..." TYPE="ext4"

# 2. 创建挂载点
sudo mkdir -p /data

# 3. 编辑 fstab
sudo nano /etc/fstab

# 添加一行：
UUID=a1b2c3d4-xxxx-xxxx-xxxx-xxxxxxxxxxxx  /data  ext4  defaults,noatime  0  2

# 4. 测试挂载（不会报错才安全！）
sudo mount -a

# 5. 验证
df -h | grep /data
```

### 8.5 可移动设备自动挂载配置

对于可能不存在的设备（如外接硬盘），添加 `nofail` 和 `x-systemd.automount`：

```bash
# /etc/fstab
UUID=xxxx-xxxx  /mnt/external  ext4  nofail,x-systemd.automount,x-systemd.idle-timeout=10min  0  0
```

- `nofail`：设备不存在时系统正常启动
- `x-systemd.automount`：访问目录时自动挂载
- `x-systemd.idle-timeout`：空闲后自动卸载

### 8.6 使用 systemd-mount

```bash
# 临时挂载（重启后失效）
sudo systemd-mount /dev/sdb1 /mnt/usb

# 创建持久的挂载单元
sudo systemd-mount --create --owner user /dev/sdb1 /mnt/usb
```

---

## 9. 挂载相关实用命令

### 9.1 查看设备信息

```bash
# 查看块设备
lsblk
lsblk -f          # 显示文件系统类型
lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT

# 查看设备 UUID 和类型
sudo blkid
sudo blkid /dev/sdb1

# 查看磁盘分区表
sudo fdisk -l
sudo parted -l

# 查看文件系统信息
sudo file -s /dev/sdb1

# 查看设备标签
e2label /dev/sdb1           # ext 文件系统
sudo blkid -o value -s LABEL /dev/sdb1
```

### 9.2 挂载状态查看

```bash
# 查看所有挂载
mount
mount | column -t

# 使用 findmnt（推荐）
findmnt
findmnt -A                   # 树形显示所有
findmnt /mnt/usb             # 查看特定挂载点
findmnt -n -o SOURCE,TARGET  # 仅显示源和目标

# 查看挂载选项
findmnt -n -o OPTIONS /mnt/usb

# 查看文件系统使用
df -hT
df -hT /mnt/usb
```

### 9.3 挂载点操作

```bash
# 重新挂载（修改选项）
sudo mount -o remount,rw /mnt/usb

# 重新挂载为只读
sudo mount -o remount,ro /mnt/usb

# 绑定挂载（将一个目录挂载到另一个位置）
sudo mount --bind /old/path /new/path

# 递归绑定挂载
sudo mount --rbind /old/path /new/path

# 移动挂载点
sudo mount --move /mnt/old /mnt/new
```

### 9.4 文件系统检查与修复

```bash
# 检查 ext 文件系统（设备需先卸载）
sudo umount /dev/sdb1
sudo e2fsck -f /dev/sdb1

# 检查并自动修复
sudo e2fsck -f -y /dev/sdb1

# 检查 NTFS
sudo ntfsfix /dev/sdb1

# 检查 FAT32
sudo dosfsck -a /dev/sdb1
```

### 9.5 创建文件系统

```bash
# 格式化为 ext4
sudo mkfs.ext4 /dev/sdb1

# 格式化并设置标签
sudo mkfs.ext4 -L "DataDisk" /dev/sdb1

# 格式化为 ext3
sudo mkfs.ext3 /dev/sdb1

# 格式化为 NTFS
sudo mkfs.ntfs /dev/sdb1

# 格式化为 FAT32
sudo mkfs.vfat -F 32 /dev/sdb1

# 格式化为 exFAT
sudo mkfs.exfat /dev/sdb1
```

---

## 10. 常见问题与故障排查

### 10.1 设备无法挂载

**问题**：`mount: /mnt/usb: unknown filesystem type 'ntfs'`

**解决**：
```bash
sudo apt install ntfs-3g
sudo mount -t ntfs-3g /dev/sdb1 /mnt/usb
```

**问题**：`mount: /mnt/usb: mount point does not exist`

**解决**：
```bash
sudo mkdir -p /mnt/usb
```

**问题**：`mount: /mnt/usb: device is busy`

**解决**：
```bash
# 查看占用进程
lsof /mnt/usb
fuser -v /mnt/usb

# 终止占用进程
fuser -k /mnt/usb

# 或懒卸载
sudo umount -l /mnt/usb
```

### 10.2 NTFS 分区挂载后只读

**原因**：Windows 快速启动或休眠导致分区被锁定。

**解决**：
```bash
# 方法1：Windows 中完全关机（Shift + 关机）

# 方法2：强制挂载（可能丢失 Windows 休眠数据）
sudo mount -t ntfs-3g -o remove_uid /dev/sdb1 /mnt/win

# 方法3：修复 NTFS
sudo ntfsfix /dev/sdb1
sudo mount -t ntfs-3g /dev/sdb1 /mnt/win
```

### 10.3 fstab 配置错误导致无法启动

**解决**：
1. 启动时进入恢复模式（Recovery Mode）
2. 选择 `root` 进入 root shell
3. 重新挂载根分区为读写：
   ```bash
   mount -o remount,rw /
   ```
4. 编辑 fstab 注释掉错误行：
   ```bash
   nano /etc/fstab
   ```
5. 重启

**预防**：修改 fstab 后务必执行 `sudo mount -a` 测试。

### 10.4 中文文件名乱码

**解决**：
```bash
# FAT32 挂载时指定编码
sudo mount -t vfat -o iocharset=utf8 /dev/sdb1 /mnt/usb

# 在 fstab 中：
UUID=xxxx  /mnt/usb  vfat  defaults,iocharset=utf8,uid=1000,gid=1000  0  0
```

### 10.5 U 盘无法识别

**排查步骤**：
```bash
# 1. 查看内核日志
dmesg | tail

# 2. 查看设备
lsblk
lsusb

# 3. 手动触发设备识别
sudo udevadm trigger

# 4. 检查 USB 控制器
lspci | grep USB
```

### 10.6 NFS 挂载超时

**解决**：
```bash
# 检查网络连通性
ping nfs-server

# 检查 NFS 服务
rpcinfo -p nfs-server

# 检查防火墙
sudo ufw allow from nfs-server to any port nfs

# 使用较短超时
sudo mount -t nfs -o timeo=10,soft,intr nfs-server:/share /mnt/nfs
```

### 10.7 SMB/CIFS 挂载失败

**解决**：
```bash
# 检查 SMB 协议版本
sudo mount -t cifs //server/share /mnt/smb \
  -o username=user,password=pass,vers=3.0

# 检查防火墙（SMB 端口 445）
sudo ufw allow 445/tcp

# 查看详细错误
sudo mount -t cifs //server/share /mnt/smb -o username=user -vvv
```

---

## 附录：常用文件系统对比

| 文件系统 | 适用场景 | 最大文件大小 | 最大分区大小 | Linux 原生支持 |
|----------|----------|--------------|--------------|----------------|
| ext4 | Linux 系统分区 | 16TB | 1EB | ✅ |
| XFS | 大文件、高并发 | 8EB | 8EB | ✅ |
| Btrfs | 快照、压缩、校验 | 16EB | 16EB | ✅ |
| NTFS | Windows 兼容 | 16TB | 256TB | 需要 ntfs-3g |
| FAT32 | U 盘、跨平台 | 4GB | 2TB | ✅ |
| exFAT | 大文件 U 盘 | 16EB | 64ZB | 需要 exfat-fuse |

---

## 附录：挂载命令速查表

| 操作 | 命令 |
|------|------|
| 查看设备 | `lsblk -f` |
| 查看挂载 | `findmnt` 或 `mount` |
| 挂载设备 | `sudo mount /dev/sdb1 /mnt/usb` |
| 卸载设备 | `sudo umount /mnt/usb` |
| 查看占用 | `lsof /mnt/usb` |
| 重新挂载 | `sudo mount -o remount,rw /mnt/usb` |
| 查看 UUID | `sudo blkid` |
| 测试 fstab | `sudo mount -a` |
| 挂载 ISO | `sudo mount -o loop file.iso /mnt/iso` |
| 挂载 NFS | `sudo mount -t nfs server:/share /mnt/nfs` |
| 挂载 SMB | `sudo mount -t cifs //server/share /mnt/smb -o user=xxx` |

---

> **文档版本**：v1.0
> **适用系统**：Ubuntu 20.04 / 22.04 / 24.04 LTS
> **最后更新**：2025 年
