# 範例 1-1：環境建置 —— 安裝 Antigravity 與模型設定

本單元先在個人電腦安裝 **Antigravity IDE**、調整三欄操作介面，並說明如何選擇 AI 模型（**預設使用 Antigravity 內建模型，也可自備 Claude / GPT，或使用 OpenCode Agent 串接國網地端模型**）。

| 步驟 | 內容 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [下載並安裝 Antigravity IDE](#第-1-步下載並安裝-antigravity-ide) | 3 分鐘 |
| **第 2 步** | [調整操作版面與確認 Remote-SSH 擴充功能](#第-2-步調整操作版面與確認-remote-ssh-擴充功能) | 2 分鐘 |
| **第 3 步** | [選擇 AI 模型與 Agent（注意：連上 HPC 後遠端需再安裝一次）](#第-3-步選擇-ai-模型與-agent) | 2 分鐘 |
| **第 4 步** | [本機暖身：用自然語言安裝工具並跑一個小分析](#第-4-步本機暖身用自然語言安裝工具並跑一個小分析) | 15 分鐘 |

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

> [!TIP]
> **若您習慣使用 VS Code**：也可至 [VS Code 官網](https://code.visualstudio.com/) 下載安裝，並在擴充功能市場安裝 Microsoft 官方的 **`Remote - SSH`**。VS Code 可安裝下方的選項 B（Claude Code / Codex）與選項 C（OpenCode），但沒有 Antigravity 內建 Agent。

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

## 第 3 步：選擇 AI 模型與 Agent

本教材設計的 `AGENTS.md` 與 `.agents/skills/` 採用通用標準格式，您可以依需求選擇以下任一種 Agent 與模型：

| 選項 | 模型與 Agent 來源 | 適用情境 | 設定方式 |
| :--- | :--- | :--- | :--- |
| **選項 A（預設）** | **Antigravity 內建模型**<br>*(Gemini 等內建模型)* | **最簡單，免額外設定 API Key**，開箱即用 | 啟動 Antigravity IDE 後，直接使用 **Google 帳號** 登入，即可在右側對話面板直接使用 |
| **選項 B** | **自備 Claude / GPT 模型**<br>*(Claude Code / Codex)* | 已有個人 Claude Pro/Max、ChatGPT Plus 或 API 帳號 | 在左側「擴充功能 (Extensions)」搜尋安裝 **Claude Code**（`anthropic.claude-code`）或 **Codex**（`openai.chatgpt`），登入個人帳號即可使用 |
| **選項 C** | **國網地端模型**<br>*(使用 **OpenCode** Agent)* | 機敏生醫數據不希望離開國網內部環境、或使用國網提供之地端模型 | 安裝並使用 **OpenCode** Agent，於設定中填入國網提供的地端模型端點（Base URL）與 API Key，即可直接呼叫國網地端模型 |

> [!IMPORTANT]
> **⚠️ 關鍵觀念：本地電腦裝過的外掛 Agent，連上 Remote-SSH (HPC) 後還要再安裝一次！**
> - **Antigravity 內建 Agent（選項 A）**：連上 Nano4 後可直接運作，不需重裝。
> - **外掛型 Agent（選項 B 的 Claude Code / Codex，或選項 C 的 OpenCode）**：
>   因為連上超算後，Agent 必須在 **Nano4 遠端主機 (`~/.antigravity-ide-server` 或遠端環境)** 執行，才能直接讀取 `/work/$USER` 的生醫檔案並派送 `sbatch`。
>   因此，即使您在自己的筆電（本地端 Local）已經裝過這些擴充功能，**待會範例 1-2 透過 `Remote - SSH` 連進 Nano4 後，請務必打開左側 Extensions 面板，點選 `Install in SSH: nano4-proxy`（直連則為 `nano4`，或在遠端終端機）再安裝一次！** 未來若換另一台電腦或連另一台 HPC 主機，也同樣需要在該遠端環境安裝一次。

---

## 第 4 步：本機暖身：用自然語言安裝工具並跑一個小分析

連上超算前，先在自己的電腦確認 Agent 能正常執行指令。之後範例 1-2 若出問題，就能確定是連線問題，而不是 Agent 的問題。

1. 選單「**檔案 → 開啟資料夾**」（`File → Open Folder`），開啟一個空資料夾（例如「文件」裡新建的 `ngs-local-demo`）。
2. 在右側對話面板依序貼上以下兩段 Prompt。AI 要執行指令時會先詢問權限，請點擊 **Accept / Run**（這是正常的安全確認，不是卡住）：

**Prompt 1：安裝工具**

```text
請判斷我的作業系統，檢查 Git 與 uv 是否已安裝，缺少的請安裝：
- Windows：用 WinGet 安裝。
- macOS：Git 用系統內建的命令列開發者工具，uv 用官方安裝指令（不需 Homebrew）。
安裝後若找不到指令，請開新的終端機再確認，最後回報版本。
```

安裝過程若跳出系統權限或安裝視窗（Windows 的「使用者帳戶控制」、macOS 的「命令列開發者工具」），請點擊 **是 / 安裝**。

**Prompt 2：4 個 FASTQ 檔的小型分析**

這 4 個檔案來自 2 個檢體（`FMT.0093C`、`FMT.0093D`），各有正向 R1 與反向 R2 讀序，每檔 1,000 reads。

```text
請從 https://github.com/gemini960114/nano4-ngs-slurm-skill/tree/main/data/fastq_4samples 下載 4 個 FASTQ 檔到 data/，
用 uv 在這個資料夾建立 .venv 並安裝需要的套件，對每個檔案計算 read 數、平均長度與 GC 含量，
整理成一張 CSV 表格，再畫一張 4 個檔案的比較圖存成 PNG。
```

這個練習讓您體驗三件事：

1. **用自然語言安裝 Python 套件**：不必自己打 `pip install`，uv 會自動建立環境。
2. **請 AI 寫並執行分析程式**：觀察 Agent 如何撰寫、執行與修正程式碼。
3. **拿到表格和圖**：在左側檔案總管點開 CSV 與 PNG 檢查結果。

> [!TIP]
> 範例 2 會在 Nano4 上使用**同樣這 4 個檔案**：練習 1、2 把類似的統計改用 Slurm 作業派送到計算節點，練習 3 再執行 FastQC + MultiQC，屆時可以對照本機的簡易統計與超算的正式品管報告。

> [!NOTE]
> **本機與遠端是兩個獨立環境**：這裡裝的工具只存在您的電腦上。Nano4 是 Linux 系統，安裝方式和您的 Windows / macOS 不同；連上後再用自然語言請 AI 安裝一次即可（見範例 1-2）。
> 本機適合跑這種幾秒鐘的小分析；正式資料請送到 Nano4 計算節點執行。

---

👉 完成後，請進入 **[範例 1-2：連線 Nano4 與下載教材](../02-nano4-login-and-setup/README.md)**。
