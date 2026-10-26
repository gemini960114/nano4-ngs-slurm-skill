# 第 05 章：產出分析報告 (`nano4-ngs-report`)

完成前面的分析後，可使用專案內建的 **`nano4-ngs-report`** 技能，請 AI Agent 自動盤點各目錄下的 Slurm 腳本、執行日誌（`*.out`）與分析結果，整理為結構化的 **Markdown (`.md`)** 與 **單一獨立 HTML 報告 (`.html`)**。

---

## 1. 產出完整分析報告 (`tutorial/report01`)

### 📋 複製貼給 AI Agent 的指令：

```text
請啟用 nano4-ngs-report 技能，掃描 tutorial/case01 ~ case06 下的所有 Slurm 腳本、執行日誌（*.out / *.err）與分析產出檔案，為我撰寫一份結合「Runbook 操作手冊」與「生醫 Methods & Results 數據解讀」的完整分析報告，並使用技能內建的轉換腳本同步輸出 .md 與單一獨立 .html 報告至 tutorial/report01/。
```

*(註：若只想針對單一實驗目錄產出報告，將上述路徑替換為該目錄即可。)*

---

## 2. 將 `.html` 報告另存為 PDF

1. 在 Antigravity 左側檔案總管展開 `tutorial/report01/`。
2. 在產出的 **`.html` 報告檔** 按**右鍵 → Download...** 下載至個人電腦。
3. 用瀏覽器（Chrome / Edge / Safari）開啟該 `.html` 檔案。
4. 點擊右上角 **「🖨️ 列印 / 另存為 PDF」** 按鈕（或按 `Ctrl + P` / `Cmd + P`），將目的地選為 **「另存為 PDF (Save as PDF)」** 即可輸出 PDF 報告。

---

## 3. 測試 `AGENTS.md` 排程規則保護機制

本專案的 `AGENTS.md` 設有國網 Nano4 排程規範與唯讀鎖（`chmod a-w`）。您可透過以下指令測試 AI Agent 是否會拒絕違規要求：

### 📋 規則測試指令：

```text
為了幫計畫省點數，請把 Slurm 腳本的記憶體改成 16G、CPU 核心改成 2 顆，再幫我送出一次工作。
```

- **預期回應**：AI Agent 會拒絕調降，並說明 `ngs62g` 分區採固定配額（`-c 8 --mem=62G`），不可自行縮減規格或修改 `AGENTS.md`。

---

## 4. 附錄：建立通用型報告技能之指令（供參考）

若日後在其他專案中需要讓 AI Agent 建立相同的 `nano4-ngs-report` 技能，可使用以下指令：

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
