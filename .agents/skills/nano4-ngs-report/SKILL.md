---
name: nano4-ngs-report
description: >-
  General-purpose technical, scientific, and HPC/bioinformatics report writing
  skill. Use this skill whenever the user asks to summarize, document, or
  generate a structured report (Runbook, SOP, Technical Guide, Scientific
  Methods & Results, or Comprehensive Project Report) from code, scripts,
  execution logs, Slurm outputs, or analytical artifacts, and compile them into
  Markdown (.md) and standalone printable HTML (.html) formats.
---

# 專業技術與科研分析報告撰寫技能 (`nano4-ngs-report`)

本技能為**通用型專業報告產生器（General-Purpose Technical & Scientific Report Skill）**，適用於任何資料科學、生物資訊（NGS / 多體學）、高效能計算（HPC / Slurm）或軟體工程實作。能自動盤點實驗目錄下的真實證據，並產出符合國際技術手冊與學術發表規範的 `.md` 與單一自包含 `.html` 報告（可直接透過瀏覽器列印為高品質 PDF）。

---

## 1. 自動化上下文與證據盤點 (Evidence Discovery & Zero-Hallucination)

在動筆撰寫報告前，Agent **必須**先對目標目錄執行證據盤點，嚴格遵守 **「有幾分證據說幾分話（Zero-Hallucination）」** 原則：

1. **掃描程式碼與設定檔**：
   - 盤點目標目錄下的執行腳本（`.py`, `.sh`, `.R`, `.slurm`, `.nf`, `.smk` 等）與設定檔。
   - 擷取實際使用的軟體模組版本（如 `module load`、容器 `.sif` 標籤、套件版本）、核心演算法參數與運算資源配置（CPU、Memory、GPU、Partition、Account）。
2. **解析執行日誌與計費紀錄 (Logs & Accounting)**：
   - 讀取標準輸出與錯誤日誌（`*.out`, `*.err`, `*.log`）。
   - 擷取真實的 Job ID、執行節點（Hostname）、開始與結束時間（Elapsed Time）、退出狀態碼（ExitCode）與關鍵系統訊息。
3. **盤點數據統計與產物 (Artifacts & Metrics)**：
   - 讀取實際產出的統計報表（如 TSV/CSV 摘要表、`multiqc_general_stats.txt`、JSON 統計檔）與視覺化產物檔案大小（`ls -lh`）。
   - **嚴禁捏造數據**：所有樣本數、統計指標、過濾前後的數量變化，必須 100% 來自實際檔案或日誌。若某步驟使用預先算好的現成檔案（Pre-computed Data），須於報告中誠實註明。

---

## 2. 雙軌結構化寫作框架 (Dual-Mode Report Architecture)

根據任務性質與讀者對象，Agent 可單獨採用 **模式 A**、**模式 B**，或融合成 **綜合雙軌報告（Hybrid Report）**：

### 模式 A：技術實作與操作手冊 (Runbook & Technical Guide)
適用於：**課程講義、實驗室標準作業程序 (SOP)、系統部署與排程管線指南**。
- **1. 執行摘要 (Executive Summary)**：一句話總結任務目標、核心架構與最終完成狀態。
- **2. 系統架構與流程圖 (Architecture & Workflow)**：使用 Mermaid 圖表視覺化整體資料流向與任務相依關係。
- **3. 環境與資源配置表 (Environment & Resource Spec)**：以結構化表格列出軟硬體環境、排程參數、儲存路徑與快取設定。
- **4. 分步實作與邏輯解析 (Step-by-Step Implementation)**：逐一拆解各階段腳本設計、關鍵指令參數與平行化加速技巧。
- **5. 驗證結果與效能表現 (Verification & Performance)**：列出各作業的 Job ID、耗時、資源利用率與狀態驗證。
- **6. 常見踩坑與排錯指南 (Troubleshooting & Best Practices)**：總結實作過程中的防呆設計（如記憶體陷阱、目錄預建、快取導向等）。

### 模式 B：科研實驗與數據分析報告 (Scientific & Analytical Report)
適用於：**研究計畫結案報告、生醫數據分析報告、學術論文初稿 (Methods & Results)**。
- **1. 研究背景與分析目標 (Background & Objectives)**：闡述資料集背景、實驗設計與欲解答之科學問題。
- **2. 資料來源與研究方法 (Materials & Methods)**：
  - 詳細記錄樣本規模、檔案格式與前處理流程。
  - **參數選擇依據 (Parameter Justification)**：不僅列出參數（如 `--p-sampling-depth 10000`、`--p-min-samples 2`），更須說明其統計或生物學意義。
  - 明確標註軟體與資料庫版本（如 SILVA 138.2、FastQC 0.11.9、QIIME 2 2026.7）以確保可重現性（Reproducibility）。
- **3. 分析結果與數據解讀 (Results & Statistical Findings)**：
  - 將原始數據轉化為清晰的 Markdown 比較表（如各樣本讀數、讀長、GC 含量、過濾前後保留比例）。
  - 解讀統計檢定與多樣性/模型分析結果的實質意義。
- **4. 核心圖表與產物導讀 (Visual Artifacts Guide)**：
  - 列出所有產出之互動式圖表（如 `.html`, `.qzv`）與資料檔（`.qza`, `.tsv`），提供檔案路徑、大小與檢視重點說明。
- **5. 結論與後續研究建議 (Conclusions & Next Steps)**：總結主要發現並提出下游實驗或進階分析建議。

---

## 3. 視覺化排版規範 (Visual & Formatting Standards)

1. **善用 GitHub Alerts 強調重點**：
   - `> [!NOTE]`：補充背景知識、環境特性或預設行為說明。
   - `> [!TIP]`：效能加速技巧（如多執行緒平行化、快取重用）或檢視工具建議。
   - `> [!IMPORTANT]`：關鍵參數決策或必須遵守的硬性規定。
   - `> [!WARNING]`：常見錯誤陷阱（如 OOM、家目錄配額爆滿、覆寫防護）。
2. **強制繪製 Mermaid 架構/流程圖**：
   - 凡涉及 2 個以上步驟的流水線、陣列作業或資料篩選漏斗（Filtering Funnel），必須繪製 `mermaid` 圖表（`flowchart TD`、`flowchart LR` 或 `sequenceDiagram`）。
   - 節點標籤若含括號或特殊字元，務必使用雙引號包覆（例如 `A["Step 1: FastQC (4 Samples)"]`）。
3. **結構化對照表**：
   - 避免大段純文字堆砌，凡有 3 個以上同類項目（如樣本統計、階段任務、產出檔案清單），一律整理為 Markdown 表格。

---

## 4. 零外部依賴之獨立 HTML/PDF 報告編譯器 (Standalone HTML Exporter)

在無 `node`、`pandoc` 或 `libreoffice` 的受限環境（如 HPC 叢集登入節點）中，撰寫完 `.md` 報告後，**必須**執行本技能內建的純 Python 轉換器，同步產出單一自包含（Self-contained）的 `.html` 報告檔：

```bash
python3 /work/u00cjz00/nano4-ngs-slurm-skill/.agents/skills/nano4-ngs-report/scripts/md_to_html.py \
  <輸入報告.md> \
  <輸出報告.html> \
  --title "報告標題"
```

### 內建轉換器特點：
- **零外部套件依賴**：僅使用 Python 3 標準函式庫（`re`, `html`, `sys`, `pathlib`, `datetime`），在任何 Linux 節點皆可 100% 穩定執行。
- **完整語法支援**：支援 YAML Frontmatter、自動生成側邊/頂部章節導覽目錄 (TOC)、GitHub Alerts (`[!NOTE]` 等彩色提示框)、表格美化、程式碼區塊語法框、行內數學公式與前端 **Mermaid.js 向量流程圖自動渲染**。
- **一鍵列印轉 PDF 最佳化**：內建 `@media print` 專用樣式與頂部「🖨️ 列印 / 另存 PDF」按鈕，使用者將 `.html` 下載至個人電腦用瀏覽器開啟後，按 `Ctrl + P` 即可輸出排版完美的正式 PDF 報告。
