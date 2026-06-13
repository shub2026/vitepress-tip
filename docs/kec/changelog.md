# 变更日志

所有重要的项目更改都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
版本控制遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.0] - 2026-06-13

### 新增
- 首次正式发布版本
- 完整的课程管理平台功能
  - 基础数据管理（培养层次、专业、学院、课程、教材、班级）
  - 培养方案管理
  - 查询报表功能
  - 用户管理和权限控制
  - 操作日志审计
- 前后端分离架构（Vue 3 + Element Plus + Node.js + Prisma）
- 页脚版本号显示功能

### 技术栈
- 前端：Vue 3.5.34, Element Plus 2.14.1, Vite 5.4.21
- 后端：Node.js, Express 5.1.0, Prisma 6.10.1
- 数据库：支持 Prisma 的多种数据库

---

## 版本说明

- **主版本号** (v1.x.x)：不兼容的 API 修改
- **次版本号** (vx.1.x)：新功能（向后兼容）
- **修订号** (vx.x.1)：Bug 修复（向后兼容）

## 发布流程

1. 更新 `package.json` 中的版本号
2. 在此文件中记录变更内容
3. 提交代码并打标签：`git tag v1.0.0`
4. 推送标签：`git push origin v1.0.0`
