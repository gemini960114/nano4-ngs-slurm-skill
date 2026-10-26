# [報告標題：專案或實驗名稱]

> [!NOTE]
> **執行摘要 (Executive Summary)**：簡述本報告涵蓋之實驗目標、運算環境、工作流架構與核心發現。

---

## 1. 系統架構與分析流程 (Architecture & Workflow)

```mermaid
flowchart LR
    A["原始資料輸入 (Input Data)"] --> B["前處理與質控 (Preprocessing & QC)"]
    B --> C["核心運算與模型分析 (Core Analysis)"]
    C --> D["統計檢定與視覺化報告 (Visualization & Report)"]
```

### 運算環境與資源配置表

| 項目 | 設定值 | 說明 |
| :--- | :--- | :--- |
| **運算叢集 / 節點** | `<Cluster / Node>` | 實際執行之計算節點 |
| **排程分區與計畫** | `<Partition / Account>` | 排程佇列與計畫代號 |
| **硬體資源配額** | `<CPUs / Memory / GPUs>` | 單任務核心數與記憶體配置 |
| **軟體環境 / 容器** | `<Modules / Containers>` | 載入之模組或 `.sif` 映像檔版本 |

---

## 2. 研究方法與實作細節 (Materials, Methods & Implementation)

### 2.1 資料來源與規模
- 詳述輸入資料格式、樣本數與資料路徑。

### 2.2 分析步驟與參數選擇依據
- 說明各階段執行指令、關鍵參數（如過濾門檻、多執行緒設定）及其科學/工程理由。

---

## 3. 執行結果與統計解讀 (Results & Statistical Findings)

### 3.1 作業執行效能統計 (`sacct` / Logs)

| 階段 / 作業名稱 | Job ID | 執行節點 | 核心數 | 執行時間 (Elapsed) | 狀態 (ExitCode) |
| :--- | :---: | :---: | :---: | :---: | :---: |
| `<Job Name>` | `<ID>` | `<Node>` | `<CPUs>` | `<HH:MM:SS>` | `COMPLETED (0:0)` |

### 3.2 關鍵數據分析結果
- 將產出數據彙整為比較表格，並附上統計或生物意義解讀。

---

## 4. 核心產物與視覺化圖表導讀 (Artifacts & Visual Guide)

| 產物檔案路徑 | 檔案大小 | 格式 / 型別 | 內容與檢視重點說明 |
| :--- | :---: | :---: | :--- |
| `<File Path>` | `<Size>` | `<Format>` | 說明如何開啟與判讀該圖表或資料檔 |

---

## 5. 常見排錯與最佳實踐 (Troubleshooting & Best Practices)

> [!TIP]
> 總結本流程中之防呆機制、儲存空間/快取優化與效能調校重點。
