# 1panel部署Github中的Vitepress项目

在已安装1Panel的服务器上部署GitHub中的VitePress项目，主要分为服务器环境准备、项目克隆与构建、1Panel站点配置三个阶段。以下是详细的步骤指南：

## 一、 服务器环境准备（Node.js与Git）
在1Panel面板中，虽然自带应用商店，但为了更灵活地执行VitePress的构建命令，建议通过终端配置Node.js和Git环境。

### 安装 Git 与 Node.js
通过SSH连接到你的服务器（可以直接使用1Panel自带的终端，或通过ssh 账号@公网IP连接）。以CentOS/RedHat系统为例，执行以下命令安装基础环境：
> bashyum install git      # 安装git用于克隆代码
> yum install nodejs   # 安装Node.js环境
> yum install npm      # 安装npm包管理器

对于Ubuntu/Debian系统，可将yum替换为apt。安装完成后，通过 npm -v 和 node -v 验证是否安装成功。(注：VitePress要求Node.js版本需18及以上，若源内版本过低，建议通过NodeSource或nvm安装新版Node)。

### 安装 pnpm（可选但推荐）
VitePress官方推荐使用pnpm作为包管理器。安装完npm后，可全局安装pnpm并配置国内镜像源以加速下载：
```
bashnpm install -g pnpm
pnpm config set registry https://registry.npmmirror.com/ # 设置淘宝镜像源
```
## 二、 克隆GitHub项目并进行构建

### 克隆项目代码
在服务器上创建一个存放代码的目录（例如 /home/web/project），并将你的GitHub仓库克隆下来：
```yaml
bashmkdir -p /home/web/project
cd /home/web/project
git clone https://github.com/你的用户名/你的VitePress仓库.git
cd 你的VitePress仓库
```

安装依赖并构建静态文件
VitePress是一个静态站点生成器（SSG），部署上线需要先将Markdown源码构建为HTML静态文件。

- 如果项目使用 pnpm，执行：
```yaml
bashpnpm install       # 安装项目依赖
pnpm run docs:build # 执行构建命令
```
- 如果项目使用 npm，执行：
```yaml
bashnpm i
npm run docs:build
```
构建完成后，生成的静态网站文件会被存放在 docs/.vitepress/dist 目录下。请牢记这个dist目录的绝对路径（例如 /home/web/project/你的VitePress仓库/docs/.vitepress/dist），后续配置需要用到。

## 三、 在1Panel中配置网站并上线

1. 安装 Nginx
登录1Panel面板，进入应用商店，搜索并安装 Nginx。1Panel采用容器化部署，安装过程简单快速且相互隔离。

2. 创建网站并绑定目录

在1Panel左侧菜单点击网站，选择创建网站。
选择反向代理或静态网站（此处选择静态网站）。
主域名：填写你要绑定的域名（需提前解析到服务器IP）。
根目录：将默认的根目录路径修改为你刚才构建产出的 dist 目录的绝对路径，例如：/home/web/project/你的VitePress仓库/docs/.vitepress/dist。
点击创建。

#### 配置伪静态（关键步骤）
VitePress是基于Vue的单页应用（SPA），直接访问子路径刷新会出现404，需要将所有找不到的路径重定向到 index.html。

在1Panel的网站列表中，找到刚创建的网站，点击设置。
找到伪静态配置项，填入以下Nginx重写规则并保存：
```
nginxlocation / {
    try_files $uri $uri/ /index.html;
}
```
(如果不通过面板配置，传统方式是在Nginx的 nginx.conf 文件中的 server 下添加此 location 规则，并指定 root 为dist路径，index 为 index.html，最后执行 nginx -s reload 刷新配置)

### 配置SSL证书（可选）
为了网站安全，建议开启HTTPS。在1Panel网站设置中，找到HTTPS选项，可以选择申请免费的Let's Encrypt证书，申请后开启强制HTTPS即可。

## 四、 后续更新与维护
当你在GitHub上更新了文章后，只需在服务器对应的项目目录下重新拉取代码并构建即可：
```
bashcd /home/web/project/你的VitePress仓库
git pull
pnpm install        # 若有新依赖需执行
pnpm run docs:build # 重新构建
```
由于1Panel中网站的根目录直接指向了 dist 文件夹，构建完成后网站内容会自动生效，无需重启Nginx。

***💡 进阶自动化提示：***
如果希望每次推送代码到GitHub后服务器能自动更新，可以借助1Panel的计划任务功能或编写简单的Shell脚本监听GitHub Webhooks，实现 git pull 和 docs:build 的自动化执行，从而打造真正的持续集成/持续部署（CI/CD）流。生成脑图如何配置Node.js环境变量如何使用SSH克隆GitHub项目如何解决VitePress构建失败问题继续进行自动化部署，推送代码到Github后，实现自动更新2026-05-12 22:06ima引用 8 篇资料作为参考在1Panel环境中实现VitePress项目的自动化部署，核心痛点在于1Panel官方目前暂未原生支持Webhook来通知服务器执行更新。因此，我们需要借助GitHub Actions与服务器SSH的联动，实现“代码推送到GitHub -> 触发Action构建静态文件 -> SSH连接服务器拉取更新”的完整CI/CD闭环。
以下是实现VitePress自动化部署的详细方案：
## 一、 整体架构与构建策略选择
自动化部署有两种常见策略，结合VitePress的特性，推荐采用策略二：

### 策略一：GitHub端构建，推送静态产物
在GitHub Actions中完成 pnpm run docs:build，将生成的 dist 目录推送到另一个静态仓库或分支，服务器只需拉取纯静态文件。这种方式服务器无需安装Node.js环境，拉取速度快，尤其适合国内服务器访问GitHub较慢的场景（可配合CNB、Gitee等国内镜像中转）。
### 策略二：服务器端构建，拉取源码直接编译
GitHub Actions通过SSH通知服务器，服务器执行 git pull 拉取最新源码，随后在服务器内执行 pnpm install 和 pnpm run docs:build。这种方式配置相对简单，不需要处理跨仓库推送和镜像中转的问题。

## 二、 配置服务器SSH免密登录（核心前置）
为了让GitHub Actions能安全地连接到你的服务器执行命令，建议采用密钥对方式进行SSH认证。

在1Panel生成密钥：在1Panel的“主机”-“密钥信息”中生成密码和密钥对。
配置GitHub Secrets：在你的VitePress GitHub仓库中，进入 Settings -> Secrets and variables -> Actions，添加以下变量：

SERVER_IP：你的服务器公网IP
USERNAME：SSH登录用户名（通常为root）
PORT：SSH登录端口（1Panel默认可能不是22，请在1Panel面板安全设置中确认）
KEY：刚刚生成的私钥内容
PASSPHRASE：密钥密码（如果设置了的的话）

## 三、 编写GitHub Actions工作流
在项目根目录创建 .github/workflows/deploy.yml。以下工作流采用了“Actions通过SSH触发服务器命令”的模式，并包含了请求签名验证的安全意识：
```yaml
name: VitePress Auto Deploy

on:
  push:
    branches:
      - main # 监听main分支的推送

jobs:
  deploy:
    name: Trigger Server Deploy
    runs-on: ubuntu-latest
    steps:
      - name: Execute SSH commands on Server
        uses: appleboy/ssh-action@v1.0.3
        with:
          host: ${{ secrets.SERVER_IP }}
          username: ${{ secrets.USERNAME }}
          key: ${{ secrets.KEY }}
          passphrase: ${{ secrets.PASSPHRASE }}
          port: ${{ secrets.PORT }}
          script: |
            echo "🚀 开始拉取最新代码..."
            cd /home/web/project/你的VitePress仓库 # 替换为你的项目实际路径
            
            # 放弃本地修改，强制同步远端（确保一致性）
            git fetch --all
            git reset --hard origin/main
            
            echo "📦 安装依赖并构建..."
            pnpm install
            pnpm run docs:build
            
            echo "✅ 部署完成！"
```


💡 进阶优化：如果选择策略一（GitHub端构建），你需要在Action中先构建，然后利用 git push --force 将产物推送到CNB或Gitee等国内镜像仓库，然后在上述SSH的 script 中，让服务器进入1Panel挂载的网站目录（如包含 .git 的index文件夹）执行 git pull 即可。

## 四、 1Panel目录权限与防坑指南
由于1Panel V1版本对网站目录有特定的管理方式，自动化部署时需特别注意以下两点：

Git仓库与网站根目录的映射
1Panel默认的网站根目录（如 /opt/1panel/apps/openresty/openresty/www/sites/你的域名/index）如果是空的，直接 git clone 会多出一层目录。正确的做法是：先手动克隆一次仓库，将克隆下来的文件夹内的所有文件（包括隐藏的 .git 文件夹），复制到1Panel的 index 文件夹内。这样后续才能直接在 index 文件夹内执行 git pull 实现增量更新。
如果采用服务器端构建，你需要将1Panel网站的根目录软链接或直接指向你项目内的 docs/.vitepress/dist 目录。

Docker容器内外的用户权限（1000:1000准则）
1Panel基于Docker管理应用，其PHP/Nginx等容器默认以 1000:1000 的用户执行进程。如果你的项目需要写入文件（如日志、缓存），或者在容器内执行命令，建议在服务器上也创建一个 uid/gid 为 1000 的普通用户来操作Git，这样可以避免容器内外权限不一致导致的“权限拒绝”问题。虽然VitePress纯静态输出对写权限要求不高，但保持权限一致性是良好的运维习惯。

## 五、 其他自动化方案拓展（Webhook自建服务）
除了通过GitHub Actions主动SSH连接服务器外，另一种主流架构是Git + HTTP钩子模式：

在服务器上使用Node.js搭建一个轻量级的Webhook监听服务（如使用Express）。
该服务验证GitHub发来的 X-Hub-Signature-256 签名以防伪造。
验证通过后，调用服务器内部的 deploy.sh 脚本执行 git fetch --all 和 git reset --hard origin/main 等部署命令。
然而，考虑到这种方式需要额外暴露服务器端口、配置反向代理与HTTPS，且1Panel目前无原生Webhook支持，通过GitHub Actions的SSH Action直连执行脚本仍然是配置最简、安全性最高（无需暴露额外HTTP接口）的优选方案。

一旦配置完成，以后你只需要在本地 git push，大约几十秒后，1Panel上的VitePress站点就会静默完成更新，彻底告别手动登录服务器执行命令的繁琐。