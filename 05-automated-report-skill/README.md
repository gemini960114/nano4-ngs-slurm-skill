# 範例 4：結果解讀與報告 —— 讓 AI 整理圖文報告，並換上自己的研究資料

跑完生醫分析後，最花時間的往往是翻找各個日誌檔（`*.out`）、統計數據與圖表產物來撰寫實驗紀錄或結案報告。

本單元示範如何利用 **`nano4-ngs-report`** 技能，讓 AI 自動讀取前面所有實驗的腳本、Slurm 紀錄與分析結果，整理成結構化的 **Markdown (`.md`)** 與 **可列印 PDF 的獨立 HTML 圖文報告 (`.html`)**；最後並說明如何將整套做法換上您自己的定序資料與研究問題。

---

## 1. 讓 AI 讀取分析結果，自動整理成圖文報告 (`tutorial/report01`)

### 📋 請複製以下指令貼給 AI Agent：

```text
請啟用 nano4-ngs-report 技能，掃描 tutorial/case01 ~ case06 下的所有 Slurm 腳本、執行日誌（*.out / *.err）與分析產出檔案，為我撰寫一份結合「Runbook 操作手冊」與「生醫 Methods & Results 數據解讀」的完整分析報告，並使用技能內建的轉換腳本同步輸出 .md 與單一獨立 .html 報告至 tutorial/report01/。
```

- **AI 會自動幫您完成**：
  1. **證據盤點（不捏造數據）**：自動讀取實際的 Job ID、CPU/記憶體耗用、執行秒數、樣本數與篩選前後 Reads 數。
  2. **繪製架構圖與表格**：自動生成 Mermaid 管線流程圖、環境模組版本表、統計結果比較表與 `.qzv` 圖表導讀。
  3. **一鍵雙格式輸出**：同時產出 `.md` 原稿與內嵌樣式表的單一自包含 `.html` 網頁報告。

---

## 2. 如何將 `.html` 圖文報告另存為 PDF？

1. 在 Antigravity 左側檔案總管展開 `tutorial/report01/`。
2. 在產出的 **`.html` 報告檔** 上按**右鍵 → Download...** 下載至個人電腦。
3. 在電腦上雙擊該 `.html` 檔（以 Chrome / Edge / Safari 開啟）。
4. 點擊網頁右上角的 **「🖨️ 列印 / 另存為 PDF」** 按鈕（或按 `Ctrl + P` / `Cmd + P`），目標選擇 **「另存為 PDF (Save as PDF)」**，即可輸出一份自動隱藏導覽列、防表格斷頁的正式 PDF 報告。

---

## 3. 如何換上自己的資料與研究問題？

學會這套「**官方文件 ➔ 自訂 Skill ➔ 確認後派送與定時監控 ➔ 自動整理圖文報告**」的工作流後，當您回到實驗室面對自己的研究問題（例如 RNA-seq、WES/WGS 變異偵測、單細胞分析或宏基因體組裝）時，只需照以下 **3 個步驟** 操作：

| 步驟 | 您需要做的事 | 如何跟 AI 協同？ |
| :--- | :--- | :--- |
| **第 1 步：放入您的資料與規則** | 在 `/work/$USER/` 建立新專案資料夾，把本研究室的 FASTQ/BAM 資料放進去，並複製本教材的 `AGENTS.md` 與 `.agents/skills/` | 開啟該資料夾後，AI 已經自動具備「Nano4 Slurm 排程規則」與「圖文報告整理」兩大基本功 |
| **第 2 步：針對新工具擴充 Skill** | 查詢國網 Nano4 上該分析工具的模組（`module spider <軟體名>`）或準備好 Apptainer `.sif` 容器，或貼給 AI 該軟體的官方手冊網址 | 對 AI 說：<br>「*請讀取這份分析流程文件，結合我們專案的 `nano4-ngs-slurm` 規則，幫我設計一套針對 `/work/$USER/my_data/` 的分析管線，送出前先跟我說明每一步的參數，確認後再送出並每 5 分鐘檢查狀態。*」 |
| **第 3 步：判讀結果與產出報告** | 由您（研究人員）運用領域專業檢查關鍵品管指標與統計圖表是否合理 | 對 AI 說：<br>「*請用 `nano4-ngs-report` 技能讀取這次的分析日誌與結果表，幫我整理成一份包含 Methods 與 Results 解讀的 HTML 圖文報告。*」 |

---

## 4. 附錄：這套通用型報告 Skill (`nano4-ngs-report`) 是怎麼寫出來的？

若您想了解或在其他專案中請 AI 從零建立這套「零外部依賴」的通用型報告技能，可參考以下指令：

```text
請解鎖並更新 Skill，在 .agents/skills/nano4-ngs-report/ 建立一個通用的「專業技術與科研分析報告撰寫技能（nano4-ngs-report）」，完成後請立即將 AGENTS.md 與 .agents/ 重新上鎖（chmod a-w）。
請將此 Skill 設計為「通用型報告產生器（General-Purpose Report Skill）」，不綁定特定專案或特定軟體，適用於任何資料科學、生醫資訊、HPC 運算或軟體工程實作。其 SKILL.md 規範與內建工具須包含以下四大通用模組：
1. 【自動化上下文與證據盤點（Evidence Discovery）】：
   - 撰寫報告前，自動掃描目標目錄下的程式碼/腳本、設定檔、執行日誌（Logs）、統計數據表與輸出產物清單。
   - 嚴格遵守「有幾分證據說幾分話（Zero-Hallucination）」原則：所有軟硬體規格、執行時間、參數設定與數據結論，必須100%源自實際日誌與產出檔案，不自行捏造數據。
2. 【雙軌結構化寫作框架（Dual-Mode Structure）】：
   支援依任務性質自由組合或切換以下兩種國際標準框架：
   - 模式 A：技術實作與操作手冊（Runbook & Technical Guide）
     包含：執行摘要（Executive Summary）、系統架構與 Mermaid 流程圖、環境與資源配置表、分步執行邏輯解析、關鍵指令與參數說明、驗證結果與常見排錯（Troubleshooting）。
   - 模式 B：科研實驗與數據分析報告（Scientific & Analytical Report）
     包含：研究背景與目標（Objective）、資料來源與方法論（Materials & Methods，含可重現之軟體版本與參數選擇依據）、實驗結果與統計解讀（Results & Findings，轉化為結構化比較表）、核心圖表與產物導讀（Artifacts Guide）、結論與後續建議（Discussion & Next Steps）。
3. 【視覺化排版規範（Visual & Formatting Standards）】：
   - 善用 GitHub Alert 區塊（NOTE / TIP / IMPORTANT / WARNING）突顯關鍵結論與防呆注意事項。
   - 凡涉及多步驟流程、相依性或系統架構，自動繪製 Mermaid 圖表（flowchart / sequenceDiagram）。
   - 所有提及之腳本、數據檔與圖表產物，必須提供清楚的檔案路徑對照表與格式說明。
4. 【零外部依賴之獨立 HTML/PDF 報告編譯器（Standalone HTML Exporter）】：
   - 於技能目錄內建純 Python 轉換腳本（scripts/md_to_html.py），僅使用系統標準 Python，不依賴 Node.js、Pandoc 或 LibreOffice。
   - 能將產出的 Markdown 報告一鍵封裝為單一自包含（Self-contained）的精美 .html 報告檔（內嵌現代學術/技術 CSS 樣式、RWD 表格、程式碼區塊美化、前端 Mermaid.js 自動渲染，以及針對瀏覽器 Ctrl+P 列印成 PDF 最佳化的 @media print 分頁樣式）。
```
