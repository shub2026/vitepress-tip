import { defineConfig } from 'vitepress';
import { withMermaid } from 'vitepress-plugin-mermaid';
import { devDependencies } from '../../package.json';

// https://vitepress.dev/reference/site-config
export default withMermaid(
  defineConfig({
    vite: {
      build: {
        chunkSizeWarningLimit: 800,
      },
    },
    head: [
      ['link', { rel: 'icon', type: 'image/png', sizes: '32x32', href: '/logo.svg' }],
      ['meta', { name: 'keywords', content: 'VitePress,文档,知识分享,知行笔记,教程' }],
      ['meta', { property: 'og:title', content: '知行笔记' }],
      ['meta', { property: 'og:description', content: '基于 VitePress 的极简风格知识分享平台' }],
      ['meta', { property: 'og:type', content: 'website' }],
      ['meta', { property: 'og:locale', content: 'zh_CN' }],
      ['meta', { name: 'twitter:card', content: 'summary' }],
    ],
    base: '/',
    title: '知行笔记',
    description: '基于 VitePress 的极简风格知识分享平台，知行合一，止于至善',
    lang: 'zh-CN',
    sitemap: {
      hostname: 'https://sntip.cn',
    },
    mermaid: {
      // 参考 https://mermaid.js.org/config/theming.html
      // 插件自动跟随 VitePress 深浅模式切换 dark 主题
      theme: 'default',
      themeVariables: {
        fontFamily:
          '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans SC", sans-serif',
      },
    },
    themeConfig: {
      logo: '/logo.svg',
      darkModeSwitchLabel: '主题',
      lightModeSwitchTitle: '切换到浅色模式',
      darkModeSwitchTitle: '切换到深色模式',
      sidebarMenuLabel: '菜单',
      returnToTopLabel: '回到顶部',
      skipToContentLabel: '跳转到内容',
      docFooter: {
        prev: '上一页',
        next: '下一页',
      },
      search: {
        provider: 'local',
        options: {
          translations: {
            button: {
              buttonText: '搜索',
              buttonAriaLabel: '搜索文档',
            },
            modal: {
              noResultsText: '无法找到相关结果',
              resetButtonTitle: '清除搜索条件',
              footer: {
                selectText: '选择',
                navigateText: '切换',
                closeText: '关闭',
              },
            },
          },
        },
      },
      // 上次更新时间
      lastUpdated: {
        text: '最后更新于',
        formatOptions: {
          dateStyle: 'short', // 可选值full、long、medium、short
          timeStyle: 'medium', // 可选值full、long、medium、short
        },
      },
      // 编辑链接配置
      editLink: {
        pattern: 'https://github.com/shub2026/vitepress-tip/edit/main/docs/:path',
        text: '在 GitHub 上编辑此页面',
      },
      outline: {
        level: [2, 3],
        label: '当前页大纲',
      },
      nav: [
        { text: '首页', link: '/' },
        { text: '书签', link: 'https://my.sntip.cn' },
        // VitePress 版本号
        {
          text: `VitePress ${devDependencies.vitepress.replace('^', '')}`,
          link: 'https://vitepress.dev/zh/',
          noIcon: true,
        },
      ],
      sidebar: [
        {
          text: 'KEC平台',
          collapsed: false,
          items: [
            // 入门
            { text: '平台说明', link: '/kec/kec-manager' },
            { text: 'KEC 说明文档', link: '/kec/kec-readme' },
            { text: '登录指南', link: '/kec/login-guide' },
            { text: '初始化流程', link: '/kec/init-flow' },
            // 部署
            { text: '1Panel 部署指南 (PM2)', link: '/kec/deploy-1panel' },
            { text: '1Panel Docker 部署', link: '/kec/1panel-docker-deploy' },
            { text: '生产环境部署指南', link: '/kec/DEPLOYMENT_GUIDE' },
            { text: '更新操作指南', link: '/kec/update-operations-guide' },
            { text: '故障排查指南', link: '/kec/troubleshooting' },
            // 设计
            { text: '权限管理设计方案', link: '/kec/auth-design' },
            // 开发
            { text: '代码重构指南', link: '/kec/refactoring-guide' },
            { text: '版本管理指南', link: '/kec/version-management' },
            // 技术专题
            { text: '学期计算逻辑', link: '/kec/semester-calculation' },
            { text: '班级状态修复', link: '/kec/class-status-fix' },
            { text: '子系统分析', link: '/kec/subsystem-analysis' },
            { text: '系统重置功能', link: '/kec/system-reset-feature' },
            { text: '教材查询性能优化', link: '/kec/textbook-query-optimization' },
            { text: '种子数据使用指南', link: '/kec/seed-usage' },
            // 质量
            { text: '最新代码审计报告', link: '/kec/code-audit-latest' },
            { text: '项目合规检查报告', link: '/kec/project-compliance-check' },
            { text: '测试体系与报告', link: '/kec/testing' },
            // 历史
            { text: '重构总结', link: '/kec/refactoring-summary' },
            { text: '前端修复总结', link: '/kec/frontend-fix-summary' },
            { text: '验证中间件修复总结', link: '/kec/validation-fix-summary' },
            { text: '变更日志', link: '/kec/changelog' },
          ],
        },
        {
          text: '构建指南',
          collapsed: true,
          items: [
            { text: '基本构建指令', link: '/vite/basic-setup' },
            { text: '远程同步关联', link: '/vite/remote-connect' },
            { text: 'Git常用命令', link: '/vite/git-commands' },
            { text: '1Panel拉取脚本', link: '/vite/1panel-script' },
            { text: '配置优化报告', link: '/vite/config-optimization-report' },
            { text: 'Gitee Go流水线', link: '/vite/gitee-go-deploy' },
            { text: 'Gitee Go优化V2', link: '/vite/gitee-go-deploy-v2' },
            { text: 'GitHub Actions + SSH部署', link: '/vite/github-actions-ssh-deploy' },
            { text: 'Markdown语法', link: '/vite/markdown-syntax' },
          ],
        },
        {
          text: 'AI 提示词',
          collapsed: true,
          items: [
            { text: 'AI 提示词索引', link: '/AI_about/ai-index' },
            { text: 'OpenAI GPT 提示词', link: '/AI_about/openai-gpt-prompts' },
            { text: 'Anthropic Claude 提示词', link: '/AI_about/anthropic-claude-prompts' },
            { text: 'Google Gemini 提示词', link: '/AI_about/google-gemini-prompts' },
            { text: 'Meta LLaMA 提示词', link: '/AI_about/meta-llama-prompts' },
            { text: 'Mistral 提示词', link: '/AI_about/mistral-prompts' },
            { text: 'DeepSeek 提示词', link: '/AI_about/deepseek-prompts' },
            { text: 'Qwen 通义千问 提示词', link: '/AI_about/qwen-prompts' },
            { text: 'GLM 智谱 提示词', link: '/AI_about/glm-prompts' },
            { text: 'Kimi 提示词', link: '/AI_about/kimi-prompts' },
            { text: 'MiniMax 提示词', link: '/AI_about/minimax-prompts' },
            { text: 'ERNIE 文心一言 提示词', link: '/AI_about/ernie-prompts' },
            { text: '混元3 提示词', link: '/AI_about/hy3-prompts' },
            { text: '国产大模型选型指南', link: '/AI_about/domestic-llm-guide' },
          ],
        },
        {
          text: 'Linux 学习',
          collapsed: true,
          items: [
            {
              text: 'Ubuntu 文件系统架构与挂载详解',
              link: '/linux/ubuntu-filesystem-architecture',
            },
            { text: 'Ubuntu 日常使用说明', link: '/linux/ubuntu-daily-usage' },
          ],
        },
        {
          text: '其他',
          collapsed: true,
          items: [
            { text: '示例展示', link: '/other/eg/list' },
            { text: '页面样式', link: '/other/eg/page' },
            { text: '证件照尺寸对照表', link: '/other/id-photo-sizes' },
            { text: '证件照皮肤美白教程', link: '/other/id-photo-whitening' },
            { text: '证件照灯光部署方案', link: '/other/id-photo-lighting' },
            { text: 'Lightroom处理流程与技巧', link: '/other/lightroom-workflow-and-tips' },
            { text: 'Lightroom预设使用指南', link: '/other/lightroom-preset-guide' },
            { text: 'WPS删除右键新建旧版菜单', link: '/other/wps-del' },
          ],
        },
      ],
      socialLinks: [{ icon: 'github', link: 'https://github.com/shub2026/vitepress-tip' }],
      footer: {
        message: '© 2026 知行笔记 Sntip.cn',
        copyright: `
          <a href="https://beian.miit.gov.cn/" target="_blank" rel="noopener">滇ICP备2025076967号</a>
          &nbsp;|&nbsp;
          <a href="http://www.beian.gov.cn/portal/registerSystemInfo?recordcode=53000002000001" target="_blank" rel="noopener">滇公网安备53000002000001号</a>
        `,
      },
    },
  })
);
