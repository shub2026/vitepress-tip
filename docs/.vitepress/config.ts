import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'

// 根据部署目标动态设置 base 路径
const base = process.env.DEPLOY_TARGET === 'github' ? '/Vitepress-tip/' : '/'

// https://vitepress.dev/reference/site-config
export default withMermaid(
  defineConfig({
    vite: {
      build: {
        chunkSizeWarningLimit: 1500,
      }
    },
    lastUpdated: true, //首次配置不会立即生效，需git提交后爬取时间戳
    head: [
      ['link', { rel: 'icon', href: `${base}favicon.ico` }],
      ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: `${base}images/logo.png` }],
      ['meta', { name: 'keywords', content: 'VitePress,文档,知识分享,知行笔记,教程' }],
      ['meta', { property: 'og:title', content: '知行笔记' }],
      ['meta', { property: 'og:description', content: '基于 VitePress 的极简风格知识分享平台' }],
    ],
    base: base,
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
      logo: `${base}images/logo.png`,
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
        //上次更新时间
    lastUpdated: {
      text: '最后更新于',
      formatOptions: {
        dateStyle: 'short', // 可选值full、long、medium、short
        timeStyle: 'medium' // 可选值full、long、medium、short
      },
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
            { text: '1Panel部署', link: '/content_A/1Panel部署' },
            { text: '1Panel脚本', link: '/content_A/1Panel脚本' },
            { text: 'Markdown语法', link: '/content_A/Markdown语法' },
          ]
        },
        {
          text: ' 收藏',
          items: [
            { text: '示例展示', link: '/content_B/示例展示' },
            { text: '证件照尺寸', link: '/content_B/证件照常用尺寸' },
            { text: '证件照美白', link: '/content_B/证件照美白教程' },
            { text: '页面样式示例', link: '/content_B/page' },
          ]
        },
        {
          text: ' AI提示词指南',
          collapsed: false,
          items: [
            { text: '提示词说明', link: '/content_D/提示词说明' },
            { text: 'OpenAI GPT', link: '/content_D/openai-gpt-prompts' },
            { text: 'Anthropic Claude', link: '/content_D/anthropic-claude-prompts' },
            { text: 'Google Gemini', link: '/content_D/google-gemini-prompts' },
            { text: 'Meta Llama', link: '/content_D/meta-llama-prompts' },
            { text: 'Mistral AI', link: '/content_D/mistral-prompts' },
            { text: 'DeepSeek', link: '/content_D/deepseek-prompts' },
            { text: '千问(Qwen)', link: '/content_D/qwen-prompts' },
            { text: '智谱AI GLM', link: '/content_D/glm-prompts' },
          ]
        }
      ],
      socialLinks: [
        { icon: 'github', link: 'https://gitee.com/shub77/vitepress-tip' }
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
