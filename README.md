# Nano4 (晶創26) GP1 生醫專用分區 (`ngs*`) AI Agent 規則與技能包

> 🌐 **線上互動式教學網站 (GitHub Pages)**：**[https://gemini960114.github.io/nano4-ngs-slurm-skill/](https://gemini960114.github.io/nano4-ngs-slurm-skill/)**

本儲存庫提供國網中心 **Nano4 (`nano4.nchc.org.tw`)** 超級電腦上，專為 **GP1 生醫核心設施 (`ngs*` 分區)** 設計的 AI Agent 專案規則（`AGENTS.md`）、標準排程技能（`nano4-ngs-slurm` Skill）與通用型專業報告生成技能（`nano4-ngs-report` Skill）。

透過本套件，使用者只需用簡單的日常自然語言（參考 [Example.md](./Example.md) 或下方五章節網站導覽），AI Agent（支援 **Antigravity (AGY)**、**Claude Code**、**Codex**）即可自動產出符合國網官方 QoS 限制的 Slurm 腳本、批次陣列作業（Array Jobs）、相依性流水線（Job Dependencies）、Apptainer 容器作業，並將分析日誌與結果一鍵彙整為專業 Markdown 與單一獨立 HTML/PDF 報告，避免誤踩「登入節點運算」、「漏寫 `--mem` 預設申請 1024G 卡死」或「高頻輪詢 `squeue`」等常見大坑。

---

## 🗺️ 課程章節導覽（從零安裝到自動化生醫報告）

如果您是第一次上課的學員，請依序點選以下 **5 個章節**（每個步驟皆設計為可直接複製貼上）：

| 章節 | 主題名稱 | 核心學習內容 |
| :--- | :--- | :--- |
| **[第 01 章](./01-install-antigravity/README.md)** | **安裝 Antigravity IDE 與介面設定** | 下載獨立軟體 Antigravity、調整三欄式 Agent 視窗、安裝 `Remote - SSH` 套件 |
| **[第 02 章](./02-nano4-login-and-setup/README.md)** | **Nano4 雙因子登入與開啟教材目錄** | 2FA（密碼+OTP）認證、連線 Nano4 並一鍵 `git clone` 教材至 `/work/$USER/` 與上鎖規則 |
| **[第 03 章](./03-basic-slurm-and-qc/README.md)** | **基礎 Slurm 排程與品質檢查 (Cases 01~05)** | 自然語言派送單一作業、Array Job、FastQC+MultiQC 相依流水線、`seff` 診斷與 Apptainer 容器 |
| **[第 04 章](./04-qiime2-microbiome-pipeline/README.md)** | **QIIME 2 腸道菌相四輪分析 (Cases 06~07)** | 拆解 41 個臨床檢體之上游匯入、分類器註解、演化樹與縱向 LME 分析，並串接全自動 Pipeline |
| **[第 05 章](./05-automated-report-skill/README.md)** | **一鍵產出專業技術與生醫雙軌報告** | 啟用 `nano4-ngs-report` 技能自動盤點日誌、產出 `.md` 與獨立 `.html` 報告，並用瀏覽器 `Ctrl+P` 轉存 PDF |

---

## 🎓 學生上課實作：30 秒快速開始 (Quick Start)

如果您已經完成第 01、02 章並在 **Antigravity (或 VS Code)** 開啟了本資料夾，**不需要做任何額外設定**，直接照以下 3 步開始：

1. **打開範例講義**：點擊左側檔案總管的 **[03-basic-slurm-and-qc/README.md](./03-basic-slurm-and-qc/README.md)** 或總表 **[Example.md](./Example.md)**。
2. **複製自然語言指令**：複製一段提示詞（Prompt）貼給右側的 AI Agent。
3. **確認計畫並檢視結果**：
   - **步驟一**：AI 會先告訴您它預計使用的計畫（`GOV115088`）、佇列（`ngs62g`）與資源（8 核心 / 62G），您只需回覆 **「好，請送出」**。
   - **步驟二**：等幾秒鐘後，問 AI：**「跑完了嗎？請用 `seff` 幫我看資源使用率並用白話解釋結果。」**

---

## 📁 檔案結構說明

```text
.
├── AGENTS.md                           # [核心規則] AI 每次對話自動載入的安全鐵律 (Always-on Rule，唯讀保護)
├── Example.md                          # [完整總表] 基礎 5 範例 + QIIME 2 多輪拆解 + 自動化報告生成 Prompt 總表
├── README.md                           # [說明文件] 專案導覽、安裝、設定與權限鎖定指南
├── 01-install-antigravity/             # [第 01 章] 安裝 Antigravity IDE 與 Remote-SSH 設定
├── 02-nano4-login-and-setup/           # [第 02 章] Nano4 雙因子登入與一鍵下載課程教材
├── 03-basic-slurm-and-qc/              # [第 03 章] 基礎 Slurm 排程與生醫品質檢查實作 (Cases 01~05)
├── 04-qiime2-microbiome-pipeline/      # [第 04 章] QIIME 2 腸道菌相四輪對話分析流水線 (Cases 06~07)
├── 05-automated-report-skill/          # [第 05 章] 一鍵產出專業技術與生醫雙軌報告 (nano4-ngs-report)
├── data/                               # [內建資料] 已整理好的定序樣本與 QIIME 2 完整教材資料
│   ├── test.fastq                      # 單一測試 FASTQ (1,000 reads)
│   ├── fastq_4samples/                 # 4 個輕量雙端樣本 (每檔 1,000 reads, 秒級練習 Array/FastQC)
│   └── qiime2/                         # 完整 QIIME 2 臨床試驗套件 (82 個 fastq.gz + 分類器 + 上下游 .qza)
├── .agents/
│   └── skills/
│       ├── nano4-ngs-slurm/            # [核心技能 1] 按需載入的 Slurm 排程技能包 (On-demand Skill)
│       │   ├── SKILL.md                # 技能主檔：提交流程、Lmod 防呆、生醫模組眉角、seff 診斷與排錯表
│       │   ├── references/
│       │   │   └── ngs_partitions.md   # 實機驗證的 27 個 ngs* 分區規格、QoS 與 AllowAccounts 總表
│       │   └── templates/              # 標準 Slurm 可執行範本
│       │       ├── standard_ngs62g.slurm
│       │       ├── array_ngs62g.slurm
│       │       ├── workflow_dependency.sh
│       │       └── apptainer_ngs62g.slurm
│       └── nano4-ngs-report/           # [核心技能 2] 通用型技術操作手冊與科研分析報告撰寫技能
│           ├── SKILL.md                # 技能主檔：證據盤點、Runbook/Scientific 雙軌框架與視覺化排版規範
│           ├── scripts/
│           │   └── md_to_html.py       # 零外部依賴之獨立 HTML/PDF 報告轉換器 (支援 TOC、Mermaid、列印轉 PDF)
│           └── templates/
│               └── report_skeleton.md  # 通用技術與科研報告標準骨架範本
├── docs/                               # [GitHub Pages] VitePress 靜態網站設定與首頁
├── scripts/                            # [GitHub Pages] 自動將各章節 README.md 同步為網站頁面之腳本
└── .github/workflows/deploy.yml        # [GitHub Pages] Push 後自動建置並部署網頁之 GitHub Actions
```

---

## 🚀 用戶下載後的設定步驟

### 方式一：放入個別分析專案目錄（Project-Level，最推薦）

如果您希望在某個特定的生醫分析工作目錄（例如 `/work/$USER/my_bio_project`）中使用本規則與技能：

1. **複製規則與技能至您的專案工作目錄**：
   ```bash
   mkdir -p /work/$USER/my_bio_project
   cp -r AGENTS.md .agents /work/$USER/my_bio_project/
   ```
   *(若您同時使用 Claude Code 或 Gemini CLI，也可在專案目錄下建立符號連結：`ln -s AGENTS.md CLAUDE.md`、`ln -s AGENTS.md GEMINI.md`)*

2. **檢查或調整您的預設國網計畫代號（Account）**：
   - 範本預設使用課程計畫 `GOV115088`（僅能派送至 `ngs62g`）。
   - 若您使用的是自己實驗室的生醫平台計畫（如 `MST109178` 或 `ENT109430`），可在對話時直接告訴 AI：「請用計畫 `MST109178`」，或先解鎖修改範本中的 `--account=`。

3. **鎖定規則與技能檔為「唯讀」（防止 AI 自作聰明偷改規則）**：
   複製完成後，執行以下指令上鎖：
   ```bash
   cd /work/$USER/my_bio_project
   chmod -R a-w AGENTS.md .agents/
   ```

4. **開始使用**：
   在 Antigravity / VS Code 開啟 `/work/$USER/my_bio_project` 資料夾，開一個新對話即可直接用自然語言下指令（參考 [Example.md](./Example.md)）！

---

### 方式二：安裝為全域技能（Global-Level，所有資料夾皆可用）

如果您希望在 Nano4 上的**任何資料夾**開新對話都能自動擁有 `nano4-ngs-slurm` 技能，可將技能複製到各 AI Agent 的全域設定目錄：

```bash
# 1. Antigravity (AGY) 全域技能目錄
mkdir -p ~/.gemini/config/skills
cp -r .agents/skills/nano4-ngs-* ~/.gemini/config/skills/

# 2. Codex / 通用 Agent 全域技能目錄
mkdir -p ~/.agents/skills
cp -r .agents/skills/nano4-ngs-* ~/.agents/skills/

# 3. Claude Code 全域技能目錄
mkdir -p ~/.claude/skills
cp -r .agents/skills/nano4-ngs-* ~/.claude/skills/
```
> **注意**：安裝全域技能後，請**重新開啟一個新的對話視窗（New Conversation）**，Agent 才會讀取到新安裝的 Skill。此外，全域技能僅包含 `.agents/skills/nano4-ngs-slurm`，建議在新的工作資料夾仍放一份 `AGENTS.md` 以確保最高優先級的安全鐵律永遠生效。

---

## 🔒 關於防竄改唯讀鎖（`chmod -R a-w`）的維護說明

為了避免 AI Agent 在遇到排程錯誤或使用者提出違規要求（如「把 `ngs62g` 記憶體改小以省點數」）時，自作聰明去修改 `AGENTS.md` 或 `.agents/skills/` 內的規定，本目錄預設已透過以下雙重機制保護：

1. **文字鐵律**：在 `AGENTS.md` 第 4 節明文禁止 AI 擅自修改或執行 `chmod`。
2. **系統權限鎖**：透過 `chmod -R a-w AGENTS.md .agents/` 移除寫入權限。

### 日後您自己想要修改或更新內容時怎麼辦？
- **方法 A（手動指令解鎖）**：
  ```bash
  # 解鎖以進行編輯
  chmod -R u+w AGENTS.md .agents/

  # 編輯完成後，重新上鎖
  chmod -R a-w AGENTS.md .agents/
  ```
- **方法 B（直接口頭授權 AI 修改）**：
  直接在對話中明確告訴 AI：
  > 「請幫我解鎖並更新 `AGENTS.md`（或 `nano4-ngs-slurm` skill），加入...，改完後幫我重新鎖回去。」
