# Git常用命令

## 初始化仓库

```sh
git init
```

## `git add` 添加到暂存区

`git add <file>` 命令用于将文件添加到暂存区。暂存区是一个中间区域，你在这里选择哪些文件的更改将会被提交到本地仓库。你可以一次性添加多个文件，或者使用通配符来选择文件。

```sh
# 添加单个文件
git add file.txt

# 添加当前所有更改的文件
git add .
```

## `git commit` 提交到本地

```sh
git commit -m "Fix bug in user authentication"
```

## `git status` 查看状态

`git status` 命令用于查看当前工作目录和暂存区的状态。它会显示哪些文件已修改但尚未提交，以及哪些文件已添加到暂存区等信息。

```sh
git status
```

## `git pull` 从远程拉取代码

`git pull` 用于从远程仓库获取最新的提交，并将它们合并到本地分支。这个命令将帮助你保持本地代码库与远程代码库同步。

```sh
git pull origin main
```

## `git push` 推送代码到远程

git push 命令用于将本地的提交推送到远程仓库。通常在你完成了一些本地更改并进行了提交后，你会使用此命令将这些更改共享给其他开发者。

```sh
git push origin main
```

## `git branch` 查看或创建分支

`git branch <name>` 命令用于列出所有分支，或者创建新分支。它是管理项目中的不同开发线路的关键命令。

```sh
# 列出所有分支
git branch

# 创建新分支
git branch branchName
```

---

## `git remote`仓库管理

```sh
# 查看远程仓库的简写名
git remote

# 查看远程仓库的简写名和 URL
git remote -v

# 查看某个仓库 git remote show <remote>
git remote show origin
```

## 添加仓库

```sh
# git remote add <shortname> <url>
git remote add origin xxx.git
```

## 修改仓库地址

```sh
# git remote set-url <remote> <new url>
git remote set-url origin xxx2.git
```

## 仓库重命名和删除

```sh
# git remote rename <old remote> <new remote> 重命名仓库
git remote rename origin pb

# git remote remove <remote> 删除仓库
git remote remove origin
```

## `git tag` 打标签

`git tag` 主要用于给特定的代码版本打上标记。你可以把标签想象成一种便捷的书签，它帮助你在代码的历史记录中找到重要的点。比如，你可以用标签来标记一个项目的发布版本，如 v1.0 或 v2.1，这样你就能很快找到这些关键的发布点

```sh
# 列出所有标签
git tag

# 创建一个新的标签
git tag v1.0

# 删除本地标签
git tag -d v1.0

# 将本地标签推送到远程仓库
git push origin v1.0
```

## `Git`学习

> [!tip]
> 更多`Git`命令查询学习
> [菜园前端](https://note.noxussj.top/documents/part1/git/git.html)
