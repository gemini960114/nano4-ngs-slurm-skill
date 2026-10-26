---
layout: home

hero:
  name: "AI Agent 上國網 HPC：生醫運算與分析實作"
  text: "把指令、排程、監控與報告交給 AI 協助，研究人員負責判斷和確認"
  tagline: "給你釣竿，不是魚。QIIME 2 只是示範，學會整套做法後，換上自己的資料和研究問題，就能用你的專業在 Nano4 上自己做分析。"
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
    title: 1. 環境建置：Antigravity 連線 Nano4
    details: 用 Antigravity IDE 連線國網 Nano4 生醫節點。模型可直接使用國網地端模型，也可自備 Gemini、Claude、GPT 等模型。
    link: /guide/01_install_antigravity
    linkText: 進入環境建置
  - icon: 🛠️
    title: 2. 自訂 Skill：把 Slurm 規則寫成技能
    details: 把 Nano4 的 Slurm 使用規範寫成 AGENTS.md 與 Skill，直接產生單一作業、Array 平行作業、FastQC/MultiQC 與容器批次腳本。
    link: /guide/03_basic_slurm_and_qc
    linkText: 進入自訂 Skill 與排程
  - icon: 🦠
    title: 3. 管線派送與監控：QIIME 2 腸道菌相分析
    details: 以 QIIME 2 為例，AI 先說明腳本內容，研究人員確認後才送出，之後每 5 分鐘自動檢查作業狀態並回報進度。
    link: /guide/04_qiime2_microbiome_pipeline
    linkText: 進入管線派送與監控
  - icon: 📊
    title: 4. 結果解讀與報告：自動整理圖文報告
    details: 讓 AI 讀取日誌與分析結果，自動彙整成包含流程圖、數據表格與方法結果解讀的 Markdown 與 HTML/PDF 報告。
    link: /guide/05_automated_report_skill
    linkText: 進入結果解讀與報告
---

## 🎯 為什麼需要這堂課？

用 HPC 跑生醫分析，常卡在幾個地方：
- **Linux 指令記不住**、路徑與模組環境容易出錯
- **Slurm 參數不好調**（例如漏寫記憶體參數導致工作卡死在排隊佇列）
- **作業送出後要一直回來看狀態**，不知道什麼時候跑完
- **跑完還得自己整理結果寫報告**，花費大量時間彙整數據與日誌

這套教材示範如何用 **AI Agent** 連上國網 **Nano4 (`nano4.nchc.org.tw`)** 生醫節點，把這些繁瑣步驟交給 AI 協助，**研究人員專注於研究設計、參數判斷與結果確認**。

> **適用對象**：生醫研究人員、醫師、生資分析師、資料科學團隊（具備基本 Linux 概念即可）。
