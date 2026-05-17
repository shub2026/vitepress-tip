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
      outline: { 
      level: [2,4], // 显示2-4级标题
      // level: 'deep', // 显示2-6级标题
      label: '当前页大纲' // 文字显示
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
            svg: '<svg t="1778981679803" class="icon" viewBox="0 0 1024 1024" version="1.1" xmlns="http://www.w3.org/2000/svg" p-id="1638" width="200" height="200"><path d="M512 1024q-104 0-199-40-92-39-163-110T40 711Q0 616 0 512t40-199Q79 221 150 150T313 40q95-40 199-40t199 40q92 39 163 110t110 163q40 95 40 199t-40 199q-39 92-110 163T711 984q-95 40-199 40z m259-569H480q-10 0-17.5 7.5T455 480v64q0 10 7.5 17.5T480 569h177q11 0 18.5 7.5T683 594v13q0 31-22.5 53.5T607 683H367q-11 0-18.5-7.5T341 657V417q0-31 22.5-53.5T417 341h354q11 0 18-7t7-18v-63q0-11-7-18t-18-7H417q-38 0-72.5 14T283 283q-27 27-41 61.5T228 417v354q0 11 7 18t18 7h373q46 0 85.5-22.5t62-62Q796 672 796 626V480q0-10-7-17.5t-18-7.5z" p-id="1639"></path></svg>'
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
