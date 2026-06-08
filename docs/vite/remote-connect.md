# 远程关联同步项目手册

多台电脑（公司、家中、笔记本）协同编辑同一 VitePress 项目的完整指南。

---

## 核心原则

> **每次切换电脑前：** `git push` 确保远端最新  
> **每次开始工作前：** `git pull` 获取最新代码  
> **不要同时改同一个文件** — 否则会触发合并冲突

---

## 一、SSH 密钥配置（一次性）

在多台电脑间同步，推荐使用 SSH 方式连接 GitHub，免去每次输入密码。

### 1.1 生成密钥

在**每台电脑**上执行一次：

```sh
# 生成 ED25519 密钥（推荐）
ssh-keygen -t ed25519 -C "your_email@example.com"

# 一路回车即可（不要设置密码短语）
# 默认保存在 ~/.ssh/id_ed25519
```

### 1.2 添加公钥到 GitHub

```sh
# 查看公钥内容
cat ~/.ssh/id_ed25519.pub
```

1. 复制输出的全部内容
2. 打开 [GitHub SSH 设置](https://github.com/settings/keys)
3. 点击 **New SSH Key**
4. 粘贴公钥，Title 填电脑名称（如"公司台式机"）
5. 保存

:::tip 多台电脑命名建议

- 公司台式机
- 家用笔记本
- MacBook Pro
  :::

### 1.3 测试连接

```sh
ssh -T git@github.com
# 成功输出：Hi shub2026! You've successfully authenticated...
```

---

## 二、首次克隆（每台新电脑）

```sh
# SSH 方式（推荐，免密）
git clone git@github.com:shub2026/vitepress-tip.git
cd vitepress-tip
npm install
```

---

## 三、查看与修改远程仓库

**添加并关联远程仓库**
使用` git remote add `命令将本地仓库与你在 GitHub、GitLab 或 Gitee 等平台上创建的远程仓库关联起来
```sh
git remote add origin git@github.com:shub2026/vitepress-tip.git
```
### 3.1 查看当前关联

```sh
git remote -v
# origin  git@github.com:shub2026/vitepress-tip.git (fetch)
# origin  git@github.com:shub2026/vitepress-tip.git (push)
```

### 3.2 常用 remote 命令

| 操作     | 命令                                 |
| -------- | ------------------------------------ |
| 查看关联 | `git remote -v`                      |
| 修改地址 | `git remote set-url origin <新地址>` |
| 添加关联 | `git remote add origin <地址>`       |
| 删除关联 | `git remote remove origin`           |

### 3.3 配置 Git 用户信息

每台电脑可能需要不同的用户名区分提交者：

```sh
# 公司电脑
git config user.name "shub2026"
git config user.email "work@example.com"

# 家用电脑
git config user.name "shub2026"
git config user.email "home@example.com"
```

:::tip
去掉 `--global` 仅在当前项目生效，不影响电脑上其他 Git 项目。
:::

---

## 四、日常同步工作流

### 场景 A：正常切换

```
公司电脑                          家用电脑
────────                          ────────
编辑文档                           git pull
git add .                         npm run docs:dev
git commit -m "更新"              编辑文档
git push         ───────────→     ...
                 (远端最新)
```

### 场景 B：忘记 push 就换了电脑

```sh
# 在家用电脑上，先拉取远程最新（虽然这次没用，但养成习惯）
git pull origin main

# 直接编辑新内容，然后提交推送
git add .
git commit -m "家中更新"
git push origin main

# 回到公司后
git pull origin main # 拉取家中提交的内容
```

### 场景 C：两端同时改了同一文件

```sh
git pull origin main
# 如果出现 CONFLICT 提示，手动编辑冲突文件
# 保留需要的内容，删除 <<<<<<< ======= >>>>>>> 标记
git add .
git commit -m "解决合并冲突"
git push origin main
```

---

## 五、完整命令速查

### 工作开始

```sh
cd vitepress-tip
git pull origin main # 拉取最新
npm run docs:dev     # 启动开发
```

### 工作结束

```sh
npm run format # 格式化
git add .
git commit -m "本次修改说明"
git push origin main # 推送到 GitHub
```

### 紧急情况

```sh
# 查看当前状态
git status

# 查看未推送的提交
git log origin/main..main

# 放弃本地修改（危险操作）
git checkout -- .
```

---

## 六、双仓库同步（GitHub + Gitee）

项目同时托管于两个平台，以 GitHub 为主：

```sh
# 查看所有远程仓库
git remote -v

# 添加 Gitee 作为第二远程
git remote add gitee git@gitee.com:shub77/vitepress-tip.git

# 推送到 GitHub
git push origin main

# 同时推送到 Gitee
git push gitee main
```

---

## 七、推荐配置

### .gitignore 确认

以下内容已配置在项目中，确保不会被意外提交：

```
node_modules/
docs/.vitepress/dist/
docs/.vitepress/cache/
```

### VS Code 推荐插件

| 插件                | 用途                   |
| ------------------- | ---------------------- |
| Vue - Official      | Vue/VitePress 语法支持 |
| Prettier            | 代码格式化             |
| Markdown All in One | Markdown 编辑增强      |

---

## 八、常见问题

### Q: `git pull` 报错 "Please commit your changes"

```sh
# 先暂存本地修改
git stash
git pull origin main
git stash pop # 恢复本地修改
```

### Q: SSH 连接失败

```sh
# 检查密钥是否加载
ssh-add -l

# 如果没有，手动添加
ssh-add ~/.ssh/id_ed25519
```

### Q: 想完全重置到远程版本

```sh
git fetch origin
git reset --hard origin/main
```
