import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
import { devDependencies } from '../../package.json'

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
        //上次更新时间
    lastUpdated: {
      text: '最后更新于',
      formatOptions: {
        dateStyle: 'short', // 可选值full、long、medium、short
        timeStyle: 'medium' // 可选值full、long、medium、short
      },
    },
      outline: { 
      level: [2,3], // 显示2-4级标题
      // level: 'deep', // 显示2-6级标题
      label: '当前页大纲' // 文字显示
      },
      nav: [
        { text: '首页', link: '/' },
        { text: '构建指南', link: '/vite/basic-setup' },
        { text: 'AI提示词', link: '/AI_about/ai-about' },
        { text: '书签', link: 'https://my.sntip.cn' },
              // vitepress版本号
        { text: `VitePress ${ devDependencies.vitepress.replace('^','') }`, link: 'https://vitepress.dev/zh/', noIcon: true },
      ],
      sidebar: [
        {
          text: ' 构建指南',
          items: [
            { text: '基本构建', link: '/vite/basic-setup' },
            { text: '远程关联', link: '/vite/remote-connect' },
            { text: 'Git常用命令', link: '/vite/git-commands' },
            { text: '1Panel部署', link: '/vite/1panel-deploy' },
            { text: '1Panel脚本', link: '/vite/1panel-script' },
            { text: 'Markdown语法', link: '/vite/markdown-syntax' },
          ]
        },
        {
          text: ' AI提示词指南',
          collapsed: false,
          items: [
            { text: '提示词说明', link: '/AI_about/ai-about' },
            { text: 'OpenAI GPT', link: '/AI_about/openai-gpt-prompts' },
            { text: 'Anthropic Claude', link: '/AI_about/anthropic-claude-prompts' },
            { text: 'Google Gemini', link: '/AI_about/google-gemini-prompts' },
            { text: 'Meta Llama', link: '/AI_about/meta-llama-prompts' },
            { text: 'Mistral AI', link: '/AI_about/mistral-prompts' },
            { text: 'DeepSeek', link: '/AI_about/deepseek-prompts' },
            { text: '千问(Qwen)', link: '/AI_about/qwen-prompts' },
            { text: '智谱AI GLM', link: '/AI_about/glm-prompts' },
          ]
        },
        {
          text: ' 其他',
          collapsed: true,
          items: [
            { text: '示例展示', link: '/other/eg/list' },
            { text: '页面样式', link: '/other/eg/page' },
            { text: '证件照尺寸', link: '/other/id-photo-sizes' },
            { text: '证件照美白', link: '/other/id-photo-whitening' },
            { text: '证件照灯光部署方案', link: '/other/id-photo-lighting' },
            { text: 'Lightroom处理流程与技巧', link: '/other/lightroom-workflow-and-tips' },
            { text: 'Lightroom预设使用指南', link: '/other/lightroom-preset-guide' },
          ]
        },
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
