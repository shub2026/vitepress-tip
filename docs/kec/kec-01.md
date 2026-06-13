

## 初次部署
第一次全新部署，在基础环境下
```sh
# 1.克隆仓库
git clone https://github.com/shub2026/kec-manager.git

# 2.项目根目录执行部署脚本
bash deploy.sh
```

部署脚本会自动执行以下 9 个步骤：
```
[1/9] 检查前置条件（Git、Node.js 版本）
[2/9] 创建部署目录
[3/9] 克隆代码到 /opt/1panel/www/sites/kec/index/kec-manager
[4/9] 安装前后端依赖
[5/9] 生成环境变量（JWT 密钥等）
[6/9] 数据库迁移 + 生成 Prisma Client + 初始化管理员账号
[7/9] 初始化系统设置（学期、系统标识）
[8/9] 构建前端
[9/9] 启动服务并验证
```

## 更新部署
代码有更新时，只需执行：
```sh
cd /opt/1panel/www/sites/kec/index/kec-manager

# 拉取最新代码
git pull

# 重新部署
bash deploy.sh
```
脚本会自动检测已有环境，跳过 .env 配置步骤，执行代码更新、依赖安装、数据库迁移、前端构建和服务重启。