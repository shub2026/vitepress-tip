---
layout: home

hero:
  name: 'KEC'
  text: '课程管理平台'
  tagline: '面向职业院校的轻量级教务编排系统 — 基础数据 · 培养方案 · 查询报表，一站式解决'
  actions:
    - theme: brand
      text: 快速入门
      link: /kec/kec-manager
    - theme: alt
      text: 部署指南
      link: /kec/deploy-1panel
    - theme: alt
      text: GitHub
      link: https://github.com/shub2026/kec-manager

features:
  - title: 📋 基础数据管理
    details: 学院、专业、培养层次、课程、教材一站式维护，支持 Excel 批量导入，数据骨架一次搭建长期复用
    link: /kec/kec-manager
  - title: 🎓 智能培养方案
    details: 课程矩阵视图直观展示学期开课分布，自动匹配专业与层次，学期课时教材一目了然
    link: /kec/plan
  - title: 📊 查询报表导出
    details: 一键查看当前及历史学期开课情况，按学院/专业/层次筛选，直接导出 Excel 统计报表
    link: /kec/kec-readme
  - title: 🔐 三级权限体系
    details: 超级管理员 / 管理员 / 访客角色分级控制，JWT 认证 + 操作审计日志，数据安全可追溯
    link: /kec/auth-design
  - title: 🏫 学期自动推算
    details: 根据入学年份与学制自动计算年级和学期序号，班级在校/毕业状态实时判定，无需手动维护
    link: /kec/semester-calculation
  - title: ⚡ 轻量部署
    details: SQLite 开箱即用，MySQL 生产无忧，1Panel + PM2 + Nginx 一键上线，前后端分离架构
    link: /kec/deploy-1panel
---
