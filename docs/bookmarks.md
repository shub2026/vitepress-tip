---
title: 知行书签
---

<script setup>
import BookmarkNav from './.vitepress/components/BookmarkNav.vue'

const groups = [
  {
    title: '🏠 APP',
    items: [
      { name: '知行笔记', desc: 'VitePress知识站', url: 'https://sntip.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/d0aefcb8661b5e5405ce37684a0b010a.png' },
      { name: '1Panel', desc: '服务器管理面板', url: 'https://1panel.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/d0aefcb8661b5e5405ce37684a0b010a.png' },
      { name: 'Frps', desc: '内网穿透', url: 'https://github.com/fatedier/frp', icon: 'https://my.sntip.cn/uploads/2026/5/22/9e137cb3477df4cbc7f08a6fcf297675.ico' },
      { name: '今日热榜', desc: '聚合热搜', url: 'https://tophub.today', icon: 'https://my.sntip.cn/uploads/2026/5/22/9e137cb3477df4cbc7f08a6fcf297675.ico' },
    ]
  },
  {
    title: '🎬 影视',
    items: [
      { name: 'SeedHub', desc: '种子资源', url: 'https://seedhub.one' },
      { name: 'BT之家', desc: 'BT资源', url: 'https://btbtt12.com' },
      { name: 'BT影视', desc: 'BT影视资源', url: 'https://www.btmeiju.com' },
      { name: '音丝范', desc: '影视资源', url: 'https://www.yinsifen.com' },
      { name: 'rarbt', desc: 'BT磁力', url: 'https://www.rarbt.com' },
      { name: '4Kbt', desc: '4K影视', url: 'https://www.4kbt.net', icon: 'https://my.sntip.cn/uploads/2026/5/22/4445a59f44d77eee806f5997376d0298.png' },
      { name: '迅雷下载', desc: '下载工具', url: 'https://www.xunlei.com' },
      { name: '磁力熊', desc: '磁力搜索', url: 'https://www.cilixiong.com' },
      { name: '夸克影视', desc: '在线影视', url: 'https://pan.quark.cn' },
      { name: '迷客电影', desc: '在线观影', url: 'https://www.mikefilm.com' },
      { name: '悠悠MP4', desc: '在线影视', url: 'https://www.uump4.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/d2b4dc25753d10ddbbea37640b55eed4.ico' },
      { name: '4K指南', desc: '4K资源导航', url: 'https://www.4kzn.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/cf72db1be1a1c1776baf81ef4f4b942a.png' },
      { name: 'Alger Music', desc: '音乐播放', url: 'https://alger.fun', icon: 'https://my.sntip.cn/uploads/2026/5/22/6f31b2ab99ce79c9352c9555c571afd0.ico' },
      { name: '布谷音乐', desc: '在线音乐', url: 'https://buge.fun' },
      { name: '片库', desc: '影视合集', url: 'https://www.pianku.li' },
      { name: 'BT世界', desc: 'BT资源站', url: 'https://www.btsj8.com' },
      { name: '一刻电影', desc: '影视资源', url: 'https://www.ykdy.com' },
    ]
  },
  {
    title: '🎨 资源',
    items: [
      { name: 'Isorepublic', desc: '高清壁纸图片', url: 'https://isorepublic.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/79d56885f47617bcfc28a247b857f795.ico' },
      { name: 'Colorhub', desc: '高清图片', url: 'https://colorhub.me', icon: 'https://my.sntip.cn/uploads/2026/5/22/a5e699a6f09f8f68e85ea0d6f8b21832.png' },
      { name: 'Iconify', desc: '可编辑图标', url: 'https://iconify.design' },
      { name: 'IconPark', desc: '字节跳动图标库', url: 'https://iconpark.oceanengine.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/9a42f2046f6e8b33258d217c130ee122.svg' },
      { name: 'Iconfont', desc: '阿里矢量图标', url: 'https://www.iconfont.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/84a666b26ff7d64481c17215b67c58ad.svg' },
      { name: 'Icon-Icons', desc: '优质图标', url: 'https://icon-icons.com' },
      { name: 'Font Awesome', desc: '字体图标', url: 'https://fontawesome.com' },
      { name: '软仓', desc: '软件资源', url: 'https://www.ruancang.net', icon: 'https://www.ruancang.net/wp-content/uploads/attachment/2025/04/20250428035000_cang-yuan-512.png' },
      { name: '藏宝阁', desc: '软件集合', url: 'https://www.cangbaoge.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/180c5bba8368f5e3b3996ed8b1a59020.ico' },
      { name: 'Flaticon', desc: '图标资源', url: 'https://www.flaticon.com' },
    ]
  },
  {
    title: '📂 集合',
    items: [
      { name: '盘搜搜', desc: '网盘搜索', url: 'https://www.pansoso.org', icon: 'https://my.sntip.cn/uploads/2026/5/22/ca112c1690376b86f6c16b9731bc0c0b.png' },
      { name: '百度盘搜', desc: '百度网盘搜索', url: 'https://www.pansearch.me' },
      { name: '盘搜', desc: '夸克网盘搜索', url: 'https://pansou.com' },
      { name: '小云搜索', desc: '网盘搜索', url: 'https://www.yunpan.net', icon: 'https://pic.616pic.com/ys_bnew_img/00/23/94/rTHSD0tRrh.jpg' },
      { name: '闪电搜索', desc: '网盘搜索', url: 'https://www.shandianpan.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/e842beee715e4bf2a104102f71ba0ef0.png' },
      { name: '网盘之家', desc: '网盘资源', url: 'https://www.wangpanzhijia.net', icon: 'https://my.sntip.cn/uploads/2026/5/22/ca112c1690376b86f6c16b9731bc0c0b.png' },
      { name: '爱达杂货铺', desc: '导航站', url: 'https://adzhp.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/7b3aeeae0fa6b97db335a6ddcbb97fae.ico' },
      { name: '图欧导航', desc: '资源导航', url: 'https://tuostudy.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/2f6e8a28b090840fd7bf2d522f6ad3aa.png' },
      { name: '夸克资源导航', desc: '夸克资源', url: 'https://www.quark001.com' },
      { name: '黑洞书签', desc: '书签导航', url: 'https://www.heidong.top', icon: 'https://my.sntip.cn/uploads/2026/5/22/32ea915e1f2bb9753d6e29c1a766dcfa.ico' },
      { name: '学习仓', desc: '学习资源', url: 'https://www.xuexicang.com' },
      { name: 'Mfsc123', desc: '素材导航', url: 'https://www.mfsc123.com' },
      { name: 'Sfeii', desc: '资源导航', url: 'https://www.sfeii.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/eca96f9b82ad608dcef3867416a225ef.ico' },
      { name: 'up云搜', desc: '网盘搜索', url: 'https://www.upyunso.com', icon: 'https://my.sntip.cn/uploads/2026/5/24/743d38e68c57b1c4ba74fe03847215bb.ico' },
    ]
  },
  {
    title: '🔧 工具',
    items: [
      { name: '在线工具', desc: '工具集合', url: 'https://www.ostools.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/5f186a603c7e502d0469695611c1ca5f.png' },
      { name: 'ITdog', desc: '运维工具', url: 'https://www.itdog.cn' },
      { name: '懒人Excel', desc: 'Excel教程', url: 'https://www.lanrenexcel.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/87d0c37928b39186ffc617dd9706e6ea.jpg' },
      { name: 'UU在线工具', desc: '在线工具集', url: 'https://uutool.cn' },
      { name: '纸由', desc: '在线笔记', url: 'https://www.zhiyou.net' },
      { name: 'W3School', desc: '前端教程', url: 'https://www.w3school.com.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/fa7af42047066db762cd99e250ce2928.svg' },
      { name: 'PDF工具', desc: 'PDF在线处理', url: 'https://www.pdf24.org' },
      { name: 'MD在线文档', desc: 'Markdown编辑器', url: 'https://markdown.love' },
      { name: '刘明野工具箱', desc: '在线工具', url: 'https://tool.liumingye.cn' },
      { name: 'KMS', desc: '系统激活', url: 'https://kms.cx' },
      { name: 'IPv6测试', desc: '网络测试', url: 'https://test-ipv6.com' },
      { name: '毫秒镜像', desc: '系统镜像', url: 'https://msddd.com' },
      { name: '安安稳稳', desc: '安全工具', url: 'https://www.anansec.com' },
      { name: 'Shub77', desc: 'Gitee仓库', url: 'https://gitee.com/shub77', icon: 'https://my.sntip.cn/uploads/2026/5/22/f68aba4079f5ae2bc2762a4b17ed189e.ico' },
      { name: '茂茂前端', desc: '前端博客', url: 'https://maomao.femmma.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/f68aba4079f5ae2bc2762a4b17ed189e.ico' },
      { name: '菜园前端', desc: '前端教程', url: 'https://www.cyfe.vip', icon: 'https://my.sntip.cn/uploads/2026/5/22/06bc25b8cda3f33c4edb6d41e898292d.png' },
      { name: 'VitePress中文教程', desc: 'VitePress文档', url: 'https://vitepress.dev/zh', icon: 'https://my.sntip.cn/uploads/2026/5/22/6a2d01f394029f8e66785d5104762140.png' },
    ]
  },
  {
    title: '🤖 AI',
    items: [
      { name: 'AI工具集', desc: 'AI工具导航', url: 'https://ai-bot.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/96ddac91752cd369568de258a35ed621.png' },
      { name: 'AiShort', desc: 'AI提示词', url: 'https://www.aishort.top', icon: 'https://my.sntip.cn/uploads/2026/4/14/ebd7986e48f0196211c3e80bf830181f.ico' },
      { name: '开源工具导航', desc: 'AI开源工具', url: 'https://www.opennav.work', icon: 'https://my.sntip.cn/uploads/2026/5/22/e81fab249bae145cf522b05b482704ef.svg' },
      { name: 'Edui123', desc: '教育AI导航', url: 'https://www.edui123.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/38d593460123129292bb852a0da9db73.png' },
      { name: '导航侠', desc: 'AI工具导航', url: 'https://www.daohtong.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/b022ce211859383da16229cffcc0ee49.png' },
    ]
  },
]
</script>

# 知行书签

常用网站导航，数据来源 [my.sntip.cn](https://my.sntip.cn)

<BookmarkNav :groups="groups" />
