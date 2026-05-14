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
      ['link', { rel: 'icon', type: 'image/png', href: '/images/logo.png' }],
      ['style', {}, `
        /* Hero 布局：标题左，图片右 */
        .VPHero {
          display: flex;
          flex-direction: row;
          align-items: center;
          gap: 40px;
        }

        .VPHero .container { flex: 1; }

        /* 图片容器：1:1 正方形 */
        .VPHero .image-container {
          width: 400px;
          height: 400px;
        }

        /* 图片：圆角显示 */
        .VPImage.image-src {
          width: 100%;
          height: 100%;
          border-radius: 16px;
          object-fit: cover;
        }

        /* 手机端：上下布局 */
        @media (max-width: 768px) {
          .VPHero {
            flex-direction: column;
            gap: 24px;
          }
          .VPHero .image-container {
            width: 280px;
            height: 280px;
          }
        }
      `]
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
        { text: '指南', link: '/content_A/构建命令' },
        { text: '导航', link: 'https://my.sntip.cn' },
        { text: '网盘', link: 'https://p.sntip.cn' }
      ],
      sidebar: [
        {
          text: ' 构建指南',
          items: [
            { text: '构建命令', link: '/content_A/构建命令' },
            { text: '远程关联', link: '/content_A/远程关联' },
            { text: 'Git常用命令', link: '/content_A/Git常用命令' },            
            { text: '模版手册', link: '/content_A/模版手册' },
            { text: '1Panel部署', link: '/content_A/1Panel部署' },
            { text: 'Markdown语法', link: '/content_A/Markdown语法' },
          ]
        },
        {
          text: ' 分类测试',
          items: [
            { text: '产品对比', link: '/content_B/B1' },
          ]
        },
        {
          text: ' 其他示例',
          items: [
            { text: '模型对比', link: '/content_C/C1' },
            { text: '示例展示', link: '/content_C/2-示例展示' },
            { text: '链接添加动态渐变色', link: '/content_C/3-链接添加动态渐变色' },
            { text: 'GitHub emoji表情', link: '/content_C/4-GitHub emoji表情' },
            { text: '模型对比', link: '/content_C/C3' },
          ]
        }
      ],
      socialLinks: [
        { icon: 'github', link: 'https://gitee.com/shub77/Vitepress-tip/' }
        // 提示：请将上面的GitHub链接替换为您自己的GitHub仓库链接
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