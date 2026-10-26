# 第 01 章：安裝 Antigravity 與環境設定

本教學使用 **Antigravity IDE** 作為開發環境並與 AI Agent 協同分析。請依下方 **3 個步驟** 完成安裝與基本設定。

| 步驟 | 內容 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [下載並安裝 Antigravity IDE](#第-1-步下載並安裝-antigravity-ide) | 3 分鐘 |
| **第 2 步** | [登入帳號與測試 AI 對話面板](#第-2-步登入帳號與測試-ai-對話面板) | 2 分鐘 |
| **第 3 步** | [調整操作版面與確認 Remote-SSH 擴充功能](#第-3-步調整操作版面與確認-remote-ssh-擴充功能) | 2 分鐘 |

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

## 第 2 步：登入帳號與測試 AI 對話面板

1. 啟動 **Antigravity IDE**，使用您的 **Google 帳號** 登入。
2. 在側邊的 **AI 對話面板** 輸入 `你好`，確認 AI Agent 可正常回應。

---

## 第 3 步：調整操作版面與確認 Remote-SSH 擴充功能

建議將介面調整為「**左側檔案總管、中間編輯檢視、右側 AI 對話面板**」：

### 1. 將 AI 面板與終端機固定在右側（建議）
1. 點選上方選單「**檢視 → 外觀**」（`View → Appearance`），勾選 **Secondary Side Bar**。
2. 如需移動「**終端機 (Terminal)**」分頁，可在分頁標題按右鍵 → **Move → Secondary Side Bar**。

### 2. 確認安裝 Remote - SSH 擴充功能
1. 點擊左側活動列的「**擴充功能 (Extensions)**」圖示（快捷鍵 `Ctrl + Shift + X` / `Cmd + Shift + X`）。
2. 搜尋 **`Remote - SSH`**，確認已安裝（若未安裝請點擊 **Install**）。
3. *(選用)* 若您同時使用 **Claude Code** 或 **Codex**，也可在此搜尋安裝並移至右側邊欄。

---

👉 完成後，請進入 **[第 02 章：登入 Nano4 與下載教材](../02-nano4-login-and-setup/README.md)**。
