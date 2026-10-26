import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
import { githubSlugify } from '../../scripts/slugify.mjs'

export default withMermaid(defineConfig({
  title: "Nano4 生醫分析 AI Agent 協同教學",
  description: "在國網 Nano4 使用 Antigravity 與 AI Agent 協同執行 Slurm 排程、QIIME 2 菌相分析與報告整理",
  head: [
    ['link', { rel: 'icon', type: 'image/x-icon', href: 'https://www.nchc.org.tw/img/favicon.ico' }],
    ['link', { rel: 'shortcut icon', type: 'image/x-icon', href: 'https://www.nchc.org.tw/img/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#0284c7' }]
  ],
  base: '/nano4-ngs-slurm-skill/',
  ignoreDeadLinks: ['localhostLinks'],
  markdown: {
    anchor: { slugify: githubSlugify }
  },
  themeConfig: {
    logo: 'https://www.nchc.org.tw/img/favicon.ico',
    nav: [
      { text: '首頁', link: '/' },
      { text: '教材說明', link: '/guide/00_overview' },
      {
        text: '教學章節',
        items: [
          { text: '01. 安裝 Antigravity 與環境設定', link: '/guide/01_install_antigravity' },
          { text: '02. 登入 Nano4 與下載教材', link: '/guide/02_nano4_login_and_setup' },
          { text: '03. 基礎 Slurm 作業與品質檢查', link: '/guide/03_basic_slurm_and_qc' },
          { text: '04. QIIME 2 腸道菌相分析', link: '/guide/04_qiime2_microbiome_pipeline' },
          { text: '05. 產出分析報告', link: '/guide/05_automated_report_skill' }
        ]
      },
      { text: '指令範例總表', link: '/guide/examples_all' },
      { text: 'AI 規範 (AGENTS.md)', link: '/guide/agents_governance' },
      { text: 'GP1 官方說明', link: 'https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg' }
    ],
    sidebar: [
      {
        text: '一、環境準備與登入',
        items: [
          { text: '教材說明與檔案清單', link: '/guide/00_overview' },
          { text: '01. 安裝 Antigravity 與環境設定', link: '/guide/01_install_antigravity' },
          { text: '02. 登入 Nano4 與下載教材', link: '/guide/02_nano4_login_and_setup' }
        ]
      },
      {
        text: '二、AI Agent 協同分析教學',
        items: [
          { text: '03. 基礎 Slurm 作業與品質檢查 (Case 01~05)', link: '/guide/03_basic_slurm_and_qc' },
          { text: '04. QIIME 2 腸道菌相分析 (Case 06~07)', link: '/guide/04_qiime2_microbiome_pipeline' },
          { text: '05. 產出分析報告', link: '/guide/05_automated_report_skill' }
        ]
      },
      {
        text: '三、附錄與規範',
        items: [
          { text: '指令範例總表 (Example.md)', link: '/guide/examples_all' },
          { text: 'Nano4 GP1 規範 (AGENTS.md)', link: '/guide/agents_governance' }
        ]
      }
    ],
    search: {
      provider: 'local'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/gemini960114/nano4-ngs-slurm-skill' }
    ],
    footer: {
      message: '國網中心 Nano4 (GP1) 生醫分析 AI Agent 協同教學',
      copyright: 'Copyright © 2026 NCHC Nano4 NGS Tutorial'
    }
  }
}))
