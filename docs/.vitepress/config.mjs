import { defineConfig } from 'vitepress'
import { withMermaid } from 'vitepress-plugin-mermaid'
import { githubSlugify } from '../../scripts/slugify.mjs'

export default withMermaid(defineConfig({
  title: "AI Agent 上國網 HPC：生醫運算與分析實作",
  description: "示範用 AI Agent 連上國網 Nano4 生醫節點，協助完成 Slurm 排程、管線監控與結果報告整理",
  head: [
    ['link', { rel: 'icon', type: 'image/x-icon', href: 'https://www.nchc.org.tw/img/favicon.ico' }],
    ['link', { rel: 'shortcut icon', type: 'image/x-icon', href: 'https://www.nchc.org.tw/img/favicon.ico' }],
    ['meta', { name: 'theme-color', content: '#0284c7' }]
  ],
  base: '/nano4-ngs-slurm-skill/',
  ignoreDeadLinks: true,
  mermaid: {
    suppressErrorRendering: true
  },
  markdown: {
    anchor: { slugify: githubSlugify }
  },
  themeConfig: {
    logo: 'https://www.nchc.org.tw/img/favicon.ico',
    nav: [
      { text: '首頁', link: '/' },
      { text: '課程總覽', link: '/guide/00_overview' },
      {
        text: '四大實作單元',
        items: [
          { text: '1-1. 安裝 Antigravity 與模型設定', link: '/guide/01_install_antigravity' },
          { text: '1-2. 連線 Nano4 與下載教材', link: '/guide/02_nano4_login_and_setup' },
          { text: '2. 自訂 Skill 與基礎批次腳本', link: '/guide/03_basic_slurm_and_qc' },
          { text: '3. 管線派送與監控 (QIIME 2)', link: '/guide/04_qiime2_microbiome_pipeline' },
          { text: '4. 結果解讀與圖文報告', link: '/guide/05_automated_report_skill' }
        ]
      },
      { text: '指令速查表', link: '/guide/examples_all' },
      { text: 'Slurm 規則 (AGENTS.md)', link: '/guide/agents_governance' },
      { text: 'GP1 官方說明', link: 'https://man.twcc.ai/xOYzPATVS_aDlbuqMrwhyg' }
    ],
    sidebar: [
      {
        text: '課程介紹',
        items: [
          { text: '課程總覽與教材資料說明', link: '/guide/00_overview' }
        ]
      },
      {
        text: '範例 1：環境建置',
        items: [
          { text: '1-1. 安裝 Antigravity 與模型選擇', link: '/guide/01_install_antigravity' },
          { text: '1-2. 連線 Nano4 與準備教材', link: '/guide/02_nano4_login_and_setup' }
        ]
      },
      {
        text: '範例 2：自訂 Skill 與批次排程',
        items: [
          { text: '2. 把 Slurm 規則寫成 Skill (Case 01~05)', link: '/guide/03_basic_slurm_and_qc' }
        ]
      },
      {
        text: '範例 3：管線派送與監控',
        items: [
          { text: '3. QIIME 2 腸道菌相分析與定時監控 (Case 06~07)', link: '/guide/04_qiime2_microbiome_pipeline' }
        ]
      },
      {
        text: '範例 4：結果解讀與報告',
        items: [
          { text: '4. 自動整理圖文報告與換上自有資料', link: '/guide/05_automated_report_skill' }
        ]
      },
      {
        text: '附錄參考',
        items: [
          { text: '全部指令範例總表 (Example.md)', link: '/guide/examples_all' },
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
      message: 'AI Agent 上國網 HPC：生醫運算與分析實作',
      copyright: 'Copyright © 2026 NCHC Nano4 HPC Bio-Analysis Tutorial'
    }
  }
}))
