import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
import { githubSlugify } from '../../scripts/slugify.mjs'

export default withMermaid(defineConfig({
  title: "Nano4 GP1 生醫 NGS 自然語言排程實戰",
  description: "以 Antigravity IDE 與 AI Agent 為核心，用自然語言完成國網 Nano4 Slurm 排程、QIIME 2 菌相分析與專業報告",
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
      { text: '專案總覽', link: '/guide/00_overview' },
      {
        text: '章節導覽',
        items: [
          { text: '第 01 章：安裝 Antigravity IDE 與版面設定', link: '/guide/01_install_antigravity' },
          { text: '第 02 章：連上 Nano4 超算與取得教材', link: '/guide/02_nano4_login_and_setup' },
          { text: '第 03 章：基礎實戰 (Slurm / FastQC / 容器)', link: '/guide/03_basic_slurm_and_qc' },
          { text: '第 04 章：進階實戰 (QIIME 2 四輪對話)', link: '/guide/04_qiime2_microbiome_pipeline' },
          { text: '第 05 章：成果收斂 (一鍵產出 HTML/PDF 報告)', link: '/guide/05_automated_report_skill' }
        ]
      },
      { text: 'Prompt 速查表', link: '/guide/examples_all' },
      { text: 'AI 規範 (AGENTS.md)', link: '/guide/agents_governance' },
      { text: 'GP1 官方說明', link: 'https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg' }
    ],
    sidebar: [
      {
        text: '🚀 第一階段：環境準備與連上超算',
        items: [
          { text: '📌 課程總覽與檔案架構', link: '/guide/00_overview' },
          { text: '💻 第 01 章：安裝 Antigravity IDE 與版面設定', link: '/guide/01_install_antigravity' },
          { text: '🔑 第 02 章：連上 Nano4 超算 (2FA) 與取得教材', link: '/guide/02_nano4_login_and_setup' }
        ]
      },
      {
        text: '⚡ 第二階段：複製貼上 Prompt 跑生醫分析',
        items: [
          { text: '🧬 第 03 章：基礎實戰 —— Slurm 排程與生醫質控 (Case 01~05)', link: '/guide/03_basic_slurm_and_qc' },
          { text: '🦠 第 04 章：進階實戰 —— 四輪對話完成 QIIME 2 (Case 06~07)', link: '/guide/04_qiime2_microbiome_pipeline' }
        ]
      },
      {
        text: '📊 第三階段：自動產出報告與規則參考',
        items: [
          { text: '📑 第 05 章：成果收斂 —— 一鍵生成 HTML/PDF 報告', link: '/guide/05_automated_report_skill' },
          { text: '📋 全部自然語言 Prompt 速查表 (Example.md)', link: '/guide/examples_all' },
          { text: '🛡️ Nano4 GP1 專屬 AGENTS.md 安全鐵律', link: '/guide/agents_governance' }
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
      message: '國網中心晶創26 (Nano4) GP1 生醫專用分區 AI Agent 實戰教材',
      copyright: 'Copyright © 2026 NCHC Nano4 NGS Tutorial'
    }
  }
}))
