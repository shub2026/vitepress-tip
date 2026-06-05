---
title: 知行书签
---

<script setup>
import BookmarkNav from './.vitepress/components/BookmarkNav.vue'

const groups = [
  {
    title: '🎨 资源',
    items: [
      { name: 'Isorepublic', desc: '高清壁纸图片', url: 'https://isorepublic.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/79d56885f47617bcfc28a247b857f795.ico' },
      { name: 'Colorhub', desc: '高清图片', url: 'https://colorhub.me', icon: 'https://my.sntip.cn/uploads/2026/5/22/a5e699a6f09f8f68e85ea0d6f8b21832.png' },
      { name: 'Iconify', desc: '可编辑图标', url: 'https://iconify.design', icon: 'https://images.icon-icons.com/364/PNG/256/Font_A_36900.png' },
      { name: 'IconPark', desc: '字节跳动图标库', url: 'https://iconpark.oceanengine.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/9a42f2046f6e8b33258d217c130ee122.svg' },
      { name: 'Iconfont', desc: '阿里矢量图标', url: 'https://www.iconfont.cn', icon: 'https://img.alicdn.com/imgextra/i4/O1CN01Z5paLz1O0zuCC7osS_!!6000000001644-55-tps-83-82.svg' },
      { name: 'Icon-Icons', desc: '优质图标', url: 'https://icon-icons.com', icon: 'https://icon-icons.com/images/icon-icons.svg' },
      { name: 'Font Awesome', desc: '字体图标', url: 'https://fontawesome.p2hp.com/', icon: 'https://images.icon-icons.com/2963/PNG/512/macos_bigsur_fonts_folder_icon_186060.png' },
      { name: '软仓', desc: '软件资源', url: 'https://www.ruancang.net', icon: 'https://www.ruancang.net/wp-content/uploads/attachment/2025/04/20250428035000_cang-yuan-512.png' },
      { name: '藏宝阁', desc: '软件集合', url: 'https://www.cangbaoge.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/180c5bba8368f5e3b3996ed8b1a59020.ico' },
      { name: 'Flaticon', desc: '图标资源', url: 'https://www.flaticon.com', icon: 'https://images.icon-icons.com/849/PNG/512/email_communication_icon-icons.com_67276.png' },
    ]
  },
  {
    title: '📂 集合',
    items: [
      { name: '爱达杂货铺', desc: '导航站', url: 'https://adzhp.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/7b3aeeae0fa6b97db335a6ddcbb97fae.ico' },
      { name: '图欧导航', desc: '资源导航', url: 'https://tuostudy.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/2f6e8a28b090840fd7bf2d522f6ad3aa.png' },
      { name: 'Mfsc123', desc: '素材导航', url: 'https://www.mfsc123.com', icon: 'https://my.sntip.cn/uploads/2026/5/26/dce4c6eb803f5a25842b33b5ae9fb54f.png' },
      { name: 'Sfeii', desc: '资源导航', url: 'https://www.sfeii.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/eca96f9b82ad608dcef3867416a225ef.ico' },
      { name: 'up云搜', desc: '网盘搜索', url: 'https://www.upyunso.com', icon: 'https://my.sntip.cn/uploads/2026/5/24/743d38e68c57b1c4ba74fe03847215bb.ico' },
    ]
  },
  {
    title: '🔧 工具',
    items: [
      { name: '在线工具', desc: '工具集合', url: 'https://www.ostools.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/5f186a603c7e502d0469695611c1ca5f.png' },
      { name: 'ITdog', desc: '运维工具', url: 'https://www.itdog.cn',icon:'https://www.itdog.cn/frame/images/logo_2023.png' },
      { name: '懒人Excel', desc: 'Excel教程', url: 'https://www.lanrenexcel.com', icon: 'https://my.sntip.cn/uploads/2026/5/22/87d0c37928b39186ffc617dd9706e6ea.jpg' },
      { name: 'UU在线工具', desc: '在线工具集', url: 'https://uutool.cn', icon: 'https://uutool.cn/assets/images/favicon.jpg' },
      { name: '纸由', desc: '纸由我A4', url: 'https://paper.cooeo.cn/', icon: 'https://images.icon-icons.com/1572/PNG/512/3592873-document-general-letter-note-office-page-paper_107755.png' },
      { name: 'W3School', desc: '前端教程', url: 'https://www.w3school.com.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/fa7af42047066db762cd99e250ce2928.svg' },
      { name: 'PDF工具', desc: 'PDF在线处理', url: 'https://www.pdf24.org',icon:'https://images.icon-icons.com/1504/PNG/512/applicationpdf_103614.png' },
      { name: 'MD在线文档', desc: 'Markdown编辑器', url: 'https://mkzhou.com/', icon: 'https://images.icon-icons.com/1526/PNG/512/labeltag_106578.png' },
      { name: '刘明野工具箱', desc: '在线工具', url: 'https://tool.liumingye.cn', icon:'https://tool.liumingye.cn/usr/themes/ITEM/assets/image/apple-touch-icon.png' },
      { name: 'KMS', desc: '系统激活', url: 'https://kms.cx',icon:'https://ks.302.pub/favicon.svg' },
      { name: 'IPv6测试', desc: '网络测试', url: 'https://test-ipv6.com' ,icon:'https://images.icon-icons.com/1858/PNG/512/iconfinder-dedicatedipaddress-4263513_117864.png'},
      { name: '毫秒镜像', desc: '系统镜像', url: 'https://1ms.run/',icon:'https://1ms.run/logo-light.svg' },
      { name: '茂茂前端', desc: '前端博客', url: 'https://fe-nav.netlify.app/', icon: 'https://my.sntip.cn/uploads/2026/5/22/f68aba4079f5ae2bc2762a4b17ed189e.ico' },
      { name: '菜园前端', desc: '前端教程', url: 'https://note.noxussj.top/', icon: 'https://note.noxussj.top/logo.png' },
      { name: 'VitePress中文教程', desc: 'VitePress文档', url: 'https://vitepress.dev/zh', icon: 'https://vitepress.dev/vitepress-logo-mini.svg' },
    ]
  },
  {
    title: '🤖 AI',
    items: [
      { name: 'AI工具集', desc: 'AI工具导航', url: 'https://ai-bot.cn', icon: 'https://my.sntip.cn/uploads/2026/5/22/96ddac91752cd369568de258a35ed621.png' },
      { name: 'AiShort', desc: 'AI提示词', url: 'https://www.aishort.top', icon: 'https://www.aishort.top/img/logo.svg' },
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
