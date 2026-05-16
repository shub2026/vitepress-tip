import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid' // 1. 引入插件


// https://vitepress.dev/reference/site-config
export default withMermaid(
  defineConfig({
    vite: {
      build: {
        chunkSizeWarningLimit: 1500, // 4. 提高 chunk 大小警告阈值到 1500kB（消除警告）
      }
    },
    head: [
      ['link', { rel: 'icon', href: '/favicon.ico' }],
    ],
    base: '/',
    title: "知行笔记",
    description: "Starter template for Vitepress documentation sites, especially for tutorials and academic documentation.",
    lang: 'zh-CN',
    // 3. 这里可以添加 Mermaid 的专属配置（可选）
    mermaid: {
      theme: 'default' // 可以设置主题，例如 'dark', 'forest' 等
    },
    themeConfig: {
      logo: '/images/logo.png',
// 搜索框
      search: {
        provider: 'local',
        options: {
          translations: {
            button: {
              buttonText: '搜索',
              buttonAriaLabel: '搜索文档'
            },
            modal: {
              noResultsText: '无法找到相关结果',
              resetButtonTitle: '清除搜索条件',
              footer: {
                selectText: '选择',
                navigateText: '切换',
                closeText: '关闭'
              }
            }
          }
        }
      },
// 导航栏
      nav: [
        { text: '首页', link: '/' },
        { text: '指南', link: '/content_A/基本构建' },
        { text: '导航', link: 'https://my.sntip.cn' },
        { text: '网盘', link: 'https://p.sntip.cn' }
      ],
// 侧边栏
      sidebar: [
        {
          text: ' 构建指南',
          items: [
            { text: '基本构建', link: '/content_A/基本构建' },
            { text: '远程关联', link: '/content_A/远程关联' },
            { text: 'Git常用命令', link: '/content_A/Git常用命令' },            
            { text: '模版手册', link: '/content_A/模版手册' },
            { text: '1Panel部署', link: '/content_A/1Panel部署' },   
            { text: 'Markdown语法', link: '/content_A/Markdown语法' },
          ]
        },
        {
          text: ' VitePress',
          items: [
            { text: '内容示例', link: '/content_B/B1' }
          ]
        },
        {
          text: ' 其他示例',
          items: [
            { text: '模型对比', link: '/content_C/C1' },
            { text: '示例展示', link: '/content_C/2-示例展示' },
            { text: '链接添加动态渐变色', link: '/content_C/3-链接添加动态渐变色' },
          ]
        }
      ],
// 导航GIT图标
      socialLinks: [
        { icon: 'github', link: 'https://gitee.com/shub77/Vitepress-tip/' }
        // 提示：请将上面的GitHub链接替换为您自己的GitHub仓库链接
      ],
// 页脚
      footer: {
        message: '© 2026 知行笔记 Sntip.cn',
        copyright: `
          <a href="https://beian.miit.gov.cn/" target="_blank" rel="noopener">滇ICP备2025076967号</a>
          &nbsp;|&nbsp;
          <a href="http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=53000002000001" target="_blank" rel="noopener">滇公网安备53000002000001号</a>
        `
      }
    }
  })
)