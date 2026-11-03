# AI Agent 上國網 HPC：生醫運算與分析實作

> 🌐 **線上教材網站**：**[https://gemini960114.github.io/nano4-ngs-slurm-skill/](https://gemini960114.github.io/nano4-ngs-slurm-skill/)**

用 HPC 跑生醫分析，常卡在幾個地方：**Linux 指令記不住、Slurm 參數不好調、作業送出後要一直回來看狀態、跑完還得自己整理結果寫報告**。

本教材示範用 **AI Agent** 連上國網 **Nano4 (`nano4.nchc.org.tw`)** 生醫節點（`ngs*` 分區），把這些步驟交給 AI 協助，**研究人員負責判斷和確認**。

> **適用對象**：生醫研究人員、醫師、生資分析師、資料科學團隊（有基本 Linux 概念即可）

---

## 🗺️ 課程內容（四個範例）

| 單元 | 主題 | 對應章節連結 | 核心內容 |
| :--- | :--- | :--- | :--- |
| **範例 1** | **環境建置** | • [1-1. 安裝 Antigravity 與模型設定](./01-install-antigravity/README.md)<br>• [1-2. 連線 Nano4 與下載教材](./02-nano4-login-and-setup/README.md) | 先在本機用自然語言安裝 Git、uv 並完成 4 個 FASTQ 檔的小分析，再用 Antigravity 連線 Nano4。預設使用內建模型，也可自備 Claude/GPT，或用 Zoo Code 串接國網地端模型（遠端 HPC 需再安裝一次） |
| **範例 2** | **Slurm 練習與自訂 Skill** | • [2. 把 Slurm 規則寫成 Skill 與基礎排程](./03-basic-slurm-and-qc/README.md) | 先練習 Linux 與 Slurm 基本指令並親手派送第一個作業，再把 Nano4 的 Slurm 使用規則寫成 Skill，讓 AI 產生單一作業、Array Job、FastQC/MultiQC 與容器批次腳本 |
| **範例 3** | **管線派送與監控** | • [3. QIIME 2 腸道菌相分析與定時監控](./04-qiime2-microbiome-pipeline/README.md) | 以 QIIME 2 腸道菌相分析為例，AI 先讀懂分析腳本，確認後才送出，以 afterok 串接相依階段，之後每 5 分鐘自動檢查作業狀態 |
| **範例 4** | **結果解讀與報告** | • [4. 結果解讀、圖文報告與換上自有資料](./05-automated-report-skill/README.md) | 讓 AI 讀取分析結果與日誌，整理成含數據圖表的 Markdown 與 HTML/PDF 圖文報告，並說明如何替換為自己的研究資料 |

**附錄（課後延伸）**：[用 AI 把教材做成 PPTX 簡報](./06-ai-pptx-slides/README.md)：安裝 Anthropic pptx Skill 與所需工具，請 AI 把各單元教材做成文字可編輯、物件逐一淡入並附講者備註的 PPTX 簡報，也能嵌入操作影片。

**📥 上課簡報（PPTX，含講者備註）**：[範例 1-1](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/1-1_%E5%AE%89%E8%A3%9DAntigravity%E8%88%87%E6%A8%A1%E5%9E%8B%E8%A8%AD%E5%AE%9A.pptx)　｜　[範例 1-2](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/1-2_%E9%80%A3%E4%B8%8ANano4%E8%88%87%E4%B8%8B%E8%BC%89%E6%95%99%E6%9D%90.pptx)　｜　[範例 2](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/2_Slurm%E5%9F%BA%E7%A4%8E%E7%B7%B4%E7%BF%92%E8%88%87%E8%87%AA%E8%A8%82Skill.pptx)　｜　[範例 3](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/3_QIIME2%E7%AE%A1%E7%B7%9A%E6%B4%BE%E9%80%81%E8%88%87%E7%9B%A3%E6%8E%A7.pptx)　｜　[範例 4](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/4_%E7%B5%90%E6%9E%9C%E8%A7%A3%E8%AE%80%E8%88%87%E5%9C%96%E6%96%87%E5%A0%B1%E5%91%8A.pptx)　｜　[附錄](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/%E9%99%84%E9%8C%84_%E7%94%A8AI%E6%8A%8A%E6%95%99%E6%9D%90%E5%81%9A%E6%88%90PPTX%E7%B0%A1%E5%A0%B1.pptx)

**🎬 教學影片（YouTube）**：[範例 1-1｜安裝 Antigravity 與 AI Agent 設定](https://youtu.be/ExOsYOF27uw)　｜　[範例 1-2｜連上 Nano4 與下載教材](https://youtu.be/VSkc-0lxrDw)　｜　[範例 3｜QIIME 2 管線派送與監控](https://youtu.be/wmNvs-LdaXI)　｜　[範例 4｜結果解讀與圖文報告](https://youtu.be/UgkCXryBhQ4)

---

## 📦 `git clone` 下載後會用到哪些檔案？

在 Nano4 上執行 `git clone` 後，**實際操作只會用到以下 4 個項目**（所有範例資料皆已內建）：

| 項目 | 路徑 | 用途說明 |
| :--- | :--- | :--- |
| **1. AI 核心規則** | `AGENTS.md` | 定義 Nano4 生醫分區核心鐵律（嚴禁登入節點運算、提交前先請研究人員確認、禁止每秒高頻輪詢 `squeue`） |
| **2. 自訂 Skills** | `.agents/skills/` | • `nano4-ngs-slurm/`：Nano4 Slurm 批次腳本與佇列規格技能<br>• `nano4-ngs-report/`：自動盤點日誌並產出圖文報告技能 |
| **3. 內建範例資料** | `data/` | • `data/fastq_4samples/`：2 個檢體 R1/R2 共 4 個輕量 FASTQ 檔（供範例 2 練習）<br>• `data/qiime2/`：41 個檢體的 82 個雙端 FASTQ、Metadata 與分類器（供範例 3 練習） |
| **4. 對話指令總表** | `Example.md` | 整理好的各階段提示詞（Prompt），可直接複製貼給 AI Agent |

---

## 🚀 快速開始（連上 Nano4 後執行）

在 Antigravity 連上 Nano4 並打開終端機後，複製貼上以下指令即可完成教材準備：

```bash
mkdir -p /work/$USER && cd /work/$USER
git clone https://github.com/gemini960114/nano4-ngs-slurm-skill.git
cd /work/$USER/nano4-ngs-slurm-skill
chmod a-w AGENTS.md
```

接著在 Antigravity 點選 **「File → Open Folder...」** 開啟 `/work/<您的帳號>/nano4-ngs-slurm-skill`，即可開始操作。
