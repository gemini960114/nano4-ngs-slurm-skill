# 範例 1-1：環境建置 —— 安裝 Antigravity 與模型設定

本單元先在個人電腦安裝 **Antigravity IDE**、調整三欄操作介面，並說明如何選擇 AI 模型（**可直接使用國網提供的地端模型，也可自備 Gemini、Claude、GPT 等雲端模型**）。

| 步驟 | 內容 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [下載並安裝 Antigravity IDE](#第-1-步下載並安裝-antigravity-ide) | 3 分鐘 |
| **第 2 步** | [調整操作版面與確認 Remote-SSH 擴充功能](#第-2-步調整操作版面與確認-remote-ssh-擴充功能) | 2 分鐘 |
| **第 3 步** | [選擇 AI 模型：國網地端模型 vs. 自備雲端模型](#第-3-步選擇-ai-模型國網地端模型-vs-自備雲端模型) | 2 分鐘 |

---

## 第 1 步：下載並安裝 Antigravity IDE

開啟官方下載頁：**https://antigravity.google/download**

> [!WARNING]
> **請勿選擇頁面上方的「Antigravity app」。**
> 請向下捲動至 **「Antigravity IDE (Standalone)」** 區塊，依您的作業系統下載：

| 您的作業系統 | 選擇下載版本 | 如何確認系統規格？ |
| :--- | :--- | :--- |
| **Windows 10 / 11** | 大多數選 **x64**<br>*(ARM 筆電選 ARM64)* | 「設定 → 系統 → 關於」查看「系統類型」 |
| **macOS (Apple Silicon)** | **Apple Silicon**（M1 / M2 / M3 / M4） | 左上角蘋果選單  →「關於這台 Mac」查看晶片型號 |

- **Windows**：執行下載的 `.exe` 安裝檔完成安裝。
- **macOS**：打開下載檔案，將 **Antigravity IDE** 拖曳至「應用程式 (Applications)」資料夾。

---

## 第 2 步：調整操作版面與確認 Remote-SSH 擴充功能

為了方便待會連上 Nano4 超級電腦，建議將版面調整為「**左邊看檔案、中間看腳本與結果、右邊跟 AI Agent 對話**」：

### 1. 將 AI 對話面板放在右側
1. 點選上方選單「**檢視 → 外觀**」（`View → Appearance`），勾選 **Secondary Side Bar**。
2. 如需將「**終端機 (Terminal)**」也移到右側，可在終端機分頁標題按右鍵 → **Move → Secondary Side Bar**。

### 2. 確認安裝 Remote - SSH 擴充功能（連超算必備）
1. 點擊左側活動列的「**擴充功能 (Extensions)**」圖示（快捷鍵 `Ctrl + Shift + X` / `Cmd + Shift + X`）。
2. 搜尋 **`Remote - SSH`**，確認已安裝（若未安裝請點擊 **Install**）。

---

## 第 3 步：選擇 AI 模型：國網地端模型 vs. 自備雲端模型

本教材設計的 `AGENTS.md` 與 `.agents/skills/` 採用開放標準格式，您可以依需求自由選擇以下任一種模型來源：

| 模型來源 | 適用情境 | 設定方式 |
| :--- | :--- | :--- |
| **選項 A：國網地端模型**<br>*(NCHC Local LLM / API)* | 機敏生醫數據不希望離開國網內部環境、或課程統一提供地端端點時 | 於擴充套件或 Agent 設定中，填入國網提供的 **OpenAI-Compatible API Base URL 與 API Key**，即可直接呼叫國網地端大模型 |
| **選項 B：Antigravity 內建模型**<br>*(Gemini 等)* | 免額外設定 API Key，開箱即用 | 啟動 Antigravity IDE 後，直接使用 **Google 帳號** 登入即可在右側對話框使用 |
| **選項 C：自備 Claude / GPT 模型**<br>*(Claude Code / Codex)* | 已有個人 Claude Pro / ChatGPT Plus 或 API 帳號 | 在左側「擴充功能 (Extensions)」搜尋安裝 **Claude Code** 或 **Codex**，將圖示拖至右側邊欄登入即可（同樣會自動讀取專案內的規則與技能） |

---

👉 完成後，請進入 **[範例 1-2：連線 Nano4 與下載教材](../02-nano4-login-and-setup/README.md)**。
