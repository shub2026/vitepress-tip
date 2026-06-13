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
            { text: '1Panel 部署指南', link: '/kec/deploy-1panel' },
            { text: '初始化流程', link: '/kec/初始化流程' },
            // 设计
            { text: '权限管理设计方案', link: '/kec/auth-design' },
            { text: '详细实施方案', link: '/kec/plan' },
            { text: '项目深度分析', link: '/kec/project-analysis' },
            // 专题
            { text: '学期计算逻辑', link: '/kec/semester-calculation' },
            { text: '班级状态修复', link: '/kec/class-status-fix' },
            { text: '子系统分析', link: '/kec/subsystem-analysis' },
            { text: '系统重置功能', link: '/kec/system-reset-feature' },
            { text: '教材查询性能优化', link: '/kec/textbook-query-optimization' },
            // 质量保障
            { text: '代码审计报告', link: '/kec/code-audit-report' },
            { text: '代码审计报告 V2', link: '/kec/code-audit-report-v2' },
            { text: '全面检查分析报告 V3', link: '/kec/code-audit-report-v3' },
            { text: '全面检查分析报告 V4', link: '/kec/code-audit-report-v4' },
            { text: '生产部署成熟度评估', link: '/kec/deploy-readiness-report' },
            { text: '全功能测试报告', link: '/kec/test-report' },
            { text: '开发进度说明', link: '/kec/development-progress' },
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
            { text: 'Gitee Go流水线', link: '/vite/gitee-go-deploy' },
            { text: 'Gitee Go优化V2', link: '/vite/gitee-go-deploy-v2' },
            { text: 'GitHub Actions + SSH部署', link: '/vite/github-actions-ssh-deploy' },
            { text: 'Markdown语法', link: '/vite/markdown-syntax' },
          ],
        },
        {
          text: 'Linux 学习',
          collapsed: false,
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
