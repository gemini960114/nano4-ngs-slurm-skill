# 範例 1-2：環境建置 —— 登入 Nano4 HPC (2FA) 與下載教材

本單元說明如何使用剛安裝好的 **Antigravity IDE** 遠端連線至國網中心 **Nano4 (`nano4.nchc.org.tw`)** 超級電腦，並將本課程的範例資料下載至高速工作區 `/work/$USER/`。

| 步驟 | 內容 | 說明 |
| :--- | :--- | :--- |
| **第 1 步** | [認識 Nano4 雙因子登入 (密碼 + 6 位數 OTP)](#第-1-步認識-nano4-雙因子登入-2fa) | 登入前必備資訊與儲存空間規則 |
| **第 2 步** | [使用 Antigravity Remote-SSH 連上 Nano4](#第-2-步使用-antigravity-remote-ssh-連上-nano4) | 圖形化連線步驟 |
| **第 3 步** | [下載課程範例資料至 `/work/$USER/`](#第-3-步下載課程範例資料至-workuser) | 一行指令完成 `git clone` |
| **第 4 步** | [在 Antigravity 開啟工作資料夾](#第-4-步在-antigravity-開啟工作資料夾) | 準備開始與 AI Agent 協同分析 |

---

## 第 1 步：認識 Nano4 雙因子登入 (2FA)

連線至國網中心 Nano4（主機位址：`nano4.nchc.org.tw`）需要通過**兩道驗證**：
1. **第一道（Password）**：輸入您的國網 iService 主機密碼（可於 iService「會員中心 → 會員資訊 → 主機帳號資訊」查詢或修改）。
2. **第二道（Verification code / OTP）**：打開手機上的認證 App（如 Google Authenticator 或 Microsoft Authenticator），輸入當下顯示的 **6 位數動態驗證碼**。

> [!IMPORTANT]
> **Nano4 兩大儲存空間規則**：
> - **`/home/$USER`（家目錄，容量上限僅 100 GB）**：僅供存放個人設定檔與小型腳本，請勿存放大型定序資料或容器映像檔。
> - **`/work/$USER`（高速工作區，大容量）**：**上課教材、定序樣本、容器快取與所有分析結果，請一律放在 `/work/$USER` 下！**

---

## 第 2 步：使用 Antigravity Remote-SSH 連上 Nano4

1. 在 Antigravity IDE 按下快捷鍵 **`F1`**（或 `Ctrl + Shift + P` / Mac 按 `Cmd + Shift + P`）。
2. 輸入並點選：**`Remote-SSH: Connect to Host...`**
3. 點選 **`+ Add New SSH Host...`**，輸入以下連線指令（請將 `<您的國網帳號>` 替換為實際帳號，例如 `u00cjz00`）：
   ```bash
   ssh <您的國網帳號>@nano4.nchc.org.tw
   ```
4. 按 Enter 儲存至預設的 SSH 設定檔後，在右下角跳出的通知點選 **`Connect`**。
5. 依視窗上方提示框依序輸入：
   - 若詢問遠端平台類型，選擇 **`Linux`**
   - 輸入您的 **主機密碼 (Password)**
   - 輸入手機 App 上的 **6 位數驗證碼 (OTP)**
6. 當左下角狀態列顯示綠色的 **`SSH: nano4.nchc.org.tw`**，即代表您已成功連進 Nano4 登入節點！

---

## 第 3 步：下載課程範例資料至 `/work/$USER/`

連上 Nano4 後，點選上方選單「**終端機 → 新增終端機**」（`Terminal → New Terminal`），將下方指令**整段複製貼入終端機**按 Enter 執行：

```bash
mkdir -p /work/$USER && cd /work/$USER
git clone https://github.com/gemini960114/nano4-ngs-slurm-skill.git
cd /work/$USER/nano4-ngs-slurm-skill
pwd
```

### 📦 下載下來的資料夾裡有哪些東西會用到？

本專案結構非常單純，上課與分析只會用到以下 **4 個核心項目**（所有練習資料皆已內建，不需另外上網下載）：

| 項目 | 路徑 | 用途說明 |
| :--- | :--- | :--- |
| **1. 內建範例資料** | `data/fastq_4samples/`<br>`data/qiime2/` | • **範例 2 使用**：`data/fastq_4samples/`（4 個輕量 FASTQ 定序樣本）<br>• **範例 3 使用**：`data/qiime2/`（82 個雙端 FASTQ、Metadata 與分類器） |
| **2. 對話指令總表** | `Example.md` | 整理好的各階段提示詞（Prompt），可直接複製貼給 AI Agent |
| **3. AI 核心規則** | `AGENTS.md` | 定義 Nano4 GP1 排程安全規範（下個單元將示範如何讓 AI 自動整理並產生此規則） |
| **4. 自訂 Skills** | `.agents/skills/` | 內含 `nano4-ngs-slurm`（Slurm 排程技能）與 `nano4-ngs-report`（圖文報告技能） |

---

## 第 4 步：在 Antigravity 開啟工作資料夾

請讓 Antigravity 直接開啟剛剛下載的資料夾：

1. 點選上方選單「**檔案 → 開啟資料夾...**」（`File → Open Folder...`）。
2. 輸入剛剛終端機最後印出的路徑：`/work/<您的帳號>/nano4-ngs-slurm-skill`，點擊 **OK / 確定**。
3. 重新載入視窗後，若詢問是否信任此資料夾，請勾選並點擊 **Yes, I trust the authors**。

---

👉 環境與資料準備完成！請進入 **[範例 2：自訂 Skill —— 讀取國網官方文件、練習 Slurm 排程並濃縮成專屬 Skill](../03-basic-slurm-and-qc/README.md)**。
