---
layout: home

hero:
  name: "Nano4 生醫分析 AI Agent 協同教學"
  text: "使用 Antigravity 與 AI Agent 協同進行生醫排程與分析"
  tagline: "涵蓋 Antigravity 安裝、Nano4 登入、Slurm 排程、FastQC/MultiQC、QIIME 2 菌相分析與報告整理"
  actions:
    - theme: brand
      text: 開始第 01 章教學
      link: /guide/01_install_antigravity
    - theme: alt
      text: 指令範例總表
      link: /guide/examples_all
    - theme: alt
      text: 教材與資料說明
      link: /guide/00_overview

features:
  - icon: 💻
    title: 01｜安裝 Antigravity 與環境設定
    details: 安裝 Antigravity IDE、調整三欄式操作版面，並確認安裝 Remote-SSH 擴充功能。
    link: /guide/01_install_antigravity
    linkText: 前往第 01 章
  - icon: 🔑
    title: 02｜登入 Nano4 與下載教材
    details: 透過雙因子認證 (密碼 + OTP) 連上 Nano4，並執行 git clone 下載教材與範例資料至 /work。
    link: /guide/02_nano4_login_and_setup
    linkText: 前往第 02 章
  - icon: ⚡
    title: 03｜基礎 Slurm 作業與品質檢查
    details: 與 AI Agent 協同完成單一 FASTQ 統計、Array 平行作業、FastQC/MultiQC 流程與 Apptainer 容器作業。
    link: /guide/03_basic_slurm_and_qc
    linkText: 前往第 03 章
  - icon: 🦠
    title: 04｜QIIME 2 腸道菌相分析
    details: 分階段與 AI Agent 協同執行上游匯入、臨床樣本篩選、物種分類、演化樹與多樣性分析。
    link: /guide/04_qiime2_microbiome_pipeline
    linkText: 前往第 04 章
  - icon: 📊
    title: 05｜產出分析報告
    details: 使用 nano4-ngs-report 技能自動彙整執行日誌與分析結果，輸出 Markdown 與 HTML/PDF 報告。
    link: /guide/05_automated_report_skill
    linkText: 前往第 05 章
  - icon: 🛡️
    title: 附錄｜Nano4 GP1 規範 (AGENTS.md)
    details: AI Agent 自動載入的排程規則，防止在登入節點運算、漏寫記憶體參數或高頻輪詢 squeue。
    link: /guide/agents_governance
    linkText: 查看規則
---
