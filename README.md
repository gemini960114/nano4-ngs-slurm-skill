# Nano4 生醫分析 AI Agent 協同教學

> 🌐 **線上教學網站**：**[https://gemini960114.github.io/nano4-ngs-slurm-skill/](https://gemini960114.github.io/nano4-ngs-slurm-skill/)**

本教材示範如何在國網中心 **Nano4 (`nano4.nchc.org.tw`)** 超級電腦（GP1 生醫分區 `ngs*`）上，使用 **Antigravity IDE** 與 **AI Agent** 協同完成 Slurm 作業排程、定序品質檢查（FastQC / MultiQC）、QIIME 2 腸道菌相分析與報告整理。

---

## 📦 `git clone` 下載後會使用到哪些檔案？

當您在 Nano4 上執行 `git clone` 下載本專案後，**實際上課與分析只會用到以下 4 個核心項目**（都不需要額外下載資料）：

| 項目 | 路徑 | 用途說明 |
| :--- | :--- | :--- |
| **1. AI 規則** | `AGENTS.md` | AI 自動讀取的 Nano4 GP1 排程規範（防止在登入節點運算、漏寫 `--mem` 等錯誤） |
| **2. AI 技能** | `.agents/skills/` | 內含 `nano4-ngs-slurm`（Slurm 排程技能）與 `nano4-ngs-report`（報告整理技能） |
| **3. 練習資料** | `data/` | 內建兩組範例資料：<br>• `data/fastq_4samples/`：4 個輕量 FASTQ 檔案（供第 03 章練習）<br>• `data/qiime2/`：QIIME 2 腸道菌相資料與分類器（供第 04 章練習） |
| **4. 對話範例** | `Example.md` | 整理好的各階段提示詞（Prompt），可直接複製貼給 AI Agent 協同執行 |

---

## 🗺️ 教學章節導覽

請依序參考以下 5 個章節進行操作：

| 章節 | 主題名稱 | 內容說明 |
| :--- | :--- | :--- |
| **[第 01 章](./01-install-antigravity/README.md)** | **安裝 Antigravity 與環境設定** | 安裝 Antigravity IDE、調整操作版面、確認 `Remote - SSH` 套件 |
| **[第 02 章](./02-nano4-login-and-setup/README.md)** | **登入 Nano4 與下載教材** | 透過 2FA（密碼+OTP）連上 Nano4，執行一行指令將教材 `git clone` 到 `/work/$USER/` |
| **[第 03 章](./03-basic-slurm-and-qc/README.md)** | **基礎 Slurm 作業與品質檢查 (Cases 01~05)** | 與 AI 協同執行單一作業、Array Job、FastQC+MultiQC 相依流程與 Apptainer 容器 |
| **[第 04 章](./04-qiime2-microbiome-pipeline/README.md)** | **QIIME 2 腸道菌相分析 (Cases 06~07)** | 與 AI 協同執行上游匯入、樣本篩選與分類、演化樹與多樣性分析，並串接完整流程 |
| **[第 05 章](./05-automated-report-skill/README.md)** | **產出分析報告** | 啟用 `nano4-ngs-report` 技能自動彙整執行日誌與結果，輸出 `.md` 與 `.html` / PDF 報告 |

---

## 🚀 快速開始（3 步驟）

連上 Nano4 並打開終端機後，複製貼上以下指令即可完成教材下載與準備：

```bash
mkdir -p /work/$USER && cd /work/$USER
git clone https://github.com/gemini960114/nano4-ngs-slurm-skill.git
cd /work/$USER/nano4-ngs-slurm-skill
chmod -R a-w AGENTS.md .agents/
```

接著在 Antigravity 點選 **「File → Open Folder...」** 開啟 `/work/<您的帳號>/nano4-ngs-slurm-skill`，即可打開 **[第 03 章](./03-basic-slurm-and-qc/README.md)** 或 **[Example.md](./Example.md)** 複製指令與 AI Agent 協同分析。

---

## 🔒 附註：如何解鎖修改 `AGENTS.md` 或 `.agents/`？

預設透過 `chmod -R a-w AGENTS.md .agents/` 將規則與技能設為唯讀，避免 AI 在排錯時擅自修改規定。若您日後需要手動更新規則，可執行：

```bash
# 解鎖編輯
chmod -R u+w AGENTS.md .agents/

# 編輯完成後重新上鎖
chmod -R a-w AGENTS.md .agents/
```
