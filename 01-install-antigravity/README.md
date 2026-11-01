# 範例 1-1：環境建置 —— 安裝 Antigravity 與模型設定

本單元先在個人電腦安裝 **Antigravity IDE**、調整三欄操作介面，並說明如何選擇 AI 模型（**預設使用 Antigravity 內建模型，也可自備 Claude / GPT，或使用 OpenCode Agent 串接國網地端模型**）。

| 步驟 | 內容 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [下載並安裝 Antigravity IDE](#第-1-步下載並安裝-antigravity-ide) | 3 分鐘 |
| **第 2 步** | [調整操作版面](#第-2-步調整操作版面) | 2 分鐘 |
| **第 3 步** | [選擇 AI Agent 與模型](#第-3-步選擇-ai-agent-與模型) | 2 分鐘 |
| **第 4 步** | [本機暖身：用自然語言安裝工具並跑一個小分析](#第-4-步本機暖身用自然語言安裝工具並跑一個小分析) | 20 分鐘 |

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

## 第 2 步：調整操作版面

為了方便待會連上 Nano4 超級電腦，建議將版面調整為「**左邊看檔案、中間看腳本與結果、右邊跟 AI Agent 對話**」：

### 將 AI 對話面板放在右側
1. 點選上方選單「**檢視 → 外觀**」（`View → Appearance`），勾選 **Secondary Side Bar**。
2. 如需將「**終端機 (Terminal)**」也移到右側，可在終端機分頁標題按右鍵 → **Move → Secondary Side Bar**。

---

## 第 3 步：選擇 AI Agent 與模型

本教材的 `AGENTS.md` 與 `.agents/skills/` 採用通用格式，以下三種 Agent 都能讀取。請依自己的需求擇一使用：

| 選項 | Agent 與模型 | 適合對象 | 設定方式 |
| :--- | :--- | :--- | :--- |
| **A（預設）** | **Antigravity 內建 Agent**<br>*(Gemini 等內建模型)* | 第一次使用、想直接上手；**不需 API Key** | 開啟 Antigravity 後以 **Google 帳號**登入，即可在右側對話面板使用 |
| **B** | **Claude Code / Codex**<br>*(自備 Claude / GPT 模型)* | 已有 Claude Pro/Max、ChatGPT Plus 或 API 帳號 | 在左側「擴充功能 (Extensions)」搜尋並安裝 **Claude Code**（`anthropic.claude-code`）或 **Codex**（`openai.chatgpt`），登入個人帳號 |
| **C** | **OpenCode**<br>*(國網地端模型)* | 機敏生醫資料不希望離開國網環境 | 安裝 **OpenCode**，在設定中填入國網提供的模型端點（Base URL）與 API Key |

> [!TIP]
> 不確定要選哪一個？建議先用**選項 A**，免額外設定，最快上手。

---

## 第 4 步：本機暖身：用自然語言安裝工具並跑一個小分析

連上超算前，先在自己的電腦確認 Agent 能正常執行指令。之後範例 1-2 若出問題，就能確定是連線問題，而不是 Agent 的問題。

1. 選單「**檔案 → 開啟資料夾**」（`File → Open Folder`），開啟一個空資料夾（例如「文件」裡新建的 `ngs-local-demo`）。
2. 在右側對話面板依序貼上 Prompt 1、2（Prompt 3 改由另一個 Agent 執行，見下方說明）。AI 要執行指令時會先詢問權限，請點擊 **Accept / Run**（這是正常的安全確認，不是卡住）：

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

**Prompt 3：請另一個 Agent 審查結果**

AI 也會出錯，所以重要的結果最好請**另一個 Agent 審查**，不要讓同一個 Agent 自己檢查自己：

- **有裝第二個 Agent**（選項 B 或 C）：在該 Agent 的對話面板貼上 Prompt 3。
- **只有內建 Agent**：在 Antigravity 開一個**新對話**再貼上（可順便切換成另一個模型），讓它在不知道前面過程的情況下重新審查。

```text
另一個 AI 已在這個資料夾對 data/ 的 4 個 FASTQ 檔計算 read 數、平均長度與 GC 含量，並產生 CSV 表格與比較圖。
請審查它的程式、表格與圖是否正確：要實際驗證，不要只看程式碼下結論；先不要修改任何檔案。
最後用表格列出每項檢查結果（正確／有問題），有問題的請說明原因與修正建議。
```

這個練習讓您體驗四件事：

1. **用自然語言安裝 Python 套件**：不必自己打 `pip install`，uv 會自動建立環境。
2. **請 AI 寫並執行分析程式**：觀察 Agent 如何撰寫、執行與修正程式碼。
3. **拿到表格和圖**：在左側檔案總管點開 CSV 與 PNG 檢查結果。
4. **交叉審查**：請另一個 Agent 評估結果是否正確，養成「AI 的結果要驗證」的習慣。

---

👉 完成後，請進入 **[範例 1-2：連線 Nano4 與下載教材](../02-nano4-login-and-setup/README.md)**。
