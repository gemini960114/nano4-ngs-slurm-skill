# 第 01 章：安裝 Antigravity IDE 與調整版面

本課程使用 **Antigravity IDE** 當作編輯器與 AI 助手。只要照下方 **3 個步驟** 完成安裝與版面調整，接下來的生醫排程與數據分析都能直接用「自然語言複製貼上」交給 AI 完成！

| 步驟 | 做什麼 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [下載並安裝 Antigravity IDE](#第-1-步下載並安裝-antigravity-ide) | 3 分鐘 |
| **第 2 步** | [登入帳號與測試 AI 對話面板](#第-2-步登入帳號與測試-ai-對話面板) | 2 分鐘 |
| **第 3 步** | [把 AI 面板移到右側，並確認 Remote-SSH 擴充功能](#第-3-步調整版面與確認-remote-ssh-擴充功能) | 2 分鐘 |

---

## 第 1 步：下載並安裝 Antigravity IDE

打開官方下載頁：**https://antigravity.google/download**

> [!WARNING]
> **注意：不要選頁面上方的「Antigravity app」。**
> 請往下捲動，找到 **「Antigravity IDE (Standalone)」** 這一區，再依您的電腦系統選擇下載：

| 您的電腦系統 | 請選擇下載版本 | 怎麼確認自己的電腦是哪一種？ |
| :--- | :--- | :--- |
| **Windows 10 / 11** | 大多數選 **x64**<br>*(少數 ARM 筆電選 ARM64)* | 「設定 → 系統 → 關於」查看「系統類型」：寫「x64」就選 x64 |
| **macOS (Apple Silicon)** | **Apple Silicon**（M1 / M2 / M3 / M4 晶片） | 左上角蘋果選單  →「關於這台 Mac」：顯示「晶片 Apple M…」即可 |

- **Windows 安裝**：雙擊下載好的 `.exe` 安裝檔，依畫面指示下一步完成。
- **macOS 安裝**：打開下載好的檔案，將 **Antigravity IDE** 拖進「應用程式 (Applications)」資料夾。

---

## 第 2 步：登入帳號與測試 AI 對話面板

1. 啟動 **Antigravity IDE**，依畫面指示使用您的 **Google 帳號** 登入。
2. 看到右側（或側邊）的 **AI 對話面板** 後，輸入一句 `你好`，確認 AI 能正常回應。

---

## 第 3 步：調整版面與確認 Remote-SSH 擴充功能

為了方便待會連上國網 Nano4 超級電腦，建議把版面調成「**左邊看檔案、中間看結果、右邊跟 AI 對話**」：

### 1. 把 AI 面板與終端機放在右側（建議）
1. 打開上方選單「**檢視 → 外觀**」（`View → Appearance`），勾選 **Secondary Side Bar**。
2. 在畫面下方若看到「**終端機 (Terminal)**」分頁，也可以在分頁標題上按滑鼠右鍵 → **Move → Secondary Side Bar**。

### 2. 確認安裝 Remote - SSH 擴充功能（連超算必備）
1. 點擊左側活動列的「**擴充功能 (Extensions)**」圖示（或按 `Ctrl + Shift + X` / `Cmd + Shift + X`）。
2. 在搜尋框輸入 **`Remote - SSH`**，確認已安裝（若未安裝，點擊 **Install** 即可）。
3. *(選用)* 如果您自己也有購買 **Claude Pro** 或 **ChatGPT Plus** 方案，也可以順便在擴充功能搜尋安裝 **Claude Code** 或 **Codex**，並將圖示拖到右側邊欄一起使用。

---

👉 完成後，請直接進入 **[第 02 章：連上 Nano4 超算與取得教材](../02-nano4-login-and-setup/README.md)**！
