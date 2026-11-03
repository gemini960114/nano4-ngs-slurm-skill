---
layout: home

hero:
  name: "AI Agent 上國網 HPC：生醫運算與分析實作"
  text: "把指令、排程、監控與報告交給 AI 協助，研究人員負責判斷和確認"
  actions:
    - theme: brand
      text: 開始課程（環境建置）
      link: /guide/01_install_antigravity
    - theme: alt
      text: 課程總覽與資料說明
      link: /guide/00_overview
    - theme: alt
      text: 全部指令速查表
      link: /guide/examples_all

features:
  - icon: 💻
    title: 1. 環境建置：本機暖身與連線 Nano4
    details: 先在本機用自然語言安裝 Git、uv 並完成 4 個 FASTQ 檔的小分析，再用 Antigravity 連線 Nano4。預設使用內建模型，也可自備 Claude/GPT，或用 Zoo Code 串接國網地端模型。
    link: /guide/01_install_antigravity
    linkText: 進入環境建置
  - icon: 🛠️
    title: 2. Slurm 練習與自訂 Skill
    details: 先練習 Linux 與 Slurm 基本指令並親手派送第一個作業，再把 Nano4 的 Slurm 使用規範寫成 Skill，讓 AI 產生單一作業、Array 平行作業、FastQC/MultiQC 與容器批次腳本。
    link: /guide/03_basic_slurm_and_qc
    linkText: 進入 Slurm 練習與自訂 Skill
  - icon: 🦠
    title: 3. 管線派送與監控：QIIME 2 腸道菌相分析
    details: 以 QIIME 2 為例，AI 先讀懂分析腳本，研究人員確認後才送出，以 afterok 串接相依階段，之後每 5 分鐘自動檢查作業狀態。
    link: /guide/04_qiime2_microbiome_pipeline
    linkText: 進入管線派送與監控
  - icon: 📊
    title: 4. 結果解讀與報告：自動整理圖文報告
    details: 讓 AI 讀取範例 3 QIIME 2 分析的日誌與結果，自動彙整成包含流程圖、數據圖表與方法結果解讀的 Markdown 與 HTML/PDF 報告。
    link: /guide/05_automated_report_skill
    linkText: 進入結果解讀與報告
---
