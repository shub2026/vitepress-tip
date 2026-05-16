import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

// https://vitepress.dev/reference/site-config
export default withMermaid(
  defineConfig({
    vite: {
      build: {
        chunkSizeWarningLimit: 1500,
      }
    },
    head: [
      ['link', { rel: 'icon', href: '/favicon.ico' }],
      ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/images/logo.png' }],
      ['meta', { name: 'keywords', content: 'VitePress,文档,知识分享,知行笔记,教程' }],
      ['meta', { property: 'og:title', content: '知行笔记' }],
      ['meta', { property: 'og:description', content: '基于 VitePress 的极简风格知识分享平台' }],
    ],
    base: '/',
    title: "知行笔记",
    description: "基于 VitePress 的极简风格知识分享平台，知行合一，止于至善",
    lang: 'zh-CN',
    sitemap: {
      hostname: 'https://sntip.cn'
    },
    mermaid: {
      theme: 'default'
    },
    themeConfig: {
      logo: '/images/logo.png',
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
      nav: [
        { text: '首页', link: '/' },
        { text: '指南', link: '/content_A/基本构建' },
        { text: '导航', link: 'https://my.sntip.cn' },
        { text: '网盘', link: 'https://p.sntip.cn' }
      ],
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
      socialLinks: [
        { icon: 'github', link: 'https://github.com/shub2026/Vitepress-tip' },
        {
          icon: {
            svg: '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12" fill="currentColor"/></svg>'
          },
          link: 'https://gitee.com/shub77/vitepress-tip/'
        }
      ],
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
