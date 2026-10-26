# 第 02 章：登入 Nano4 與下載教材

本章說明如何使用 **Antigravity IDE** 連線至國網中心 **Nano4 (`nano4.nchc.org.tw`)**，並將教材與範例資料下載至高速工作區 `/work/$USER/`。

| 步驟 | 內容 |
| :--- | :--- |
| **第 1 步** | [Nano4 雙因子登入說明 (密碼 + 6 位數 OTP)](#第-1-步nano4-雙因子登入說明-2fa) |
| **第 2 步** | [使用 Remote-SSH 連上 Nano4](#第-2-步使用-remote-ssh-連上-nano4) |
| **第 3 步** | [執行 git clone 下載教材至 `/work/$USER/`](#第-3-步執行-git-clone-下載教材至-workuser) |
| **第 4 步** | [在 Antigravity 開啟教材資料夾](#第-4-步在-antigravity-開啟教材資料夾) |

---

## 第 1 步：Nano4 雙因子登入說明 (2FA)

連線至 Nano4（`nano4.nchc.org.tw`）需依序輸入兩項驗證：
1. **Password**：您的國網 iService 主機密碼。
2. **Verification code (OTP)**：手機認證 App（Google / Microsoft Authenticator）顯示的 **6 位數動態驗證碼**。

> [!IMPORTANT]
> **儲存空間說明**：
> - **`/home/$USER`（家目錄，上限 100 GB）**：僅放個人設定檔。
> - **`/work/$USER`（高速工作區，大容量）**：**上課教材、定序資料與分析結果請一律放在 `/work/$USER` 下。**

---

## 第 2 步：使用 Remote-SSH 連上 Nano4

1. 在 Antigravity IDE 按下 **`F1`**（或 `Ctrl + Shift + P` / Mac 按 `Cmd + Shift + P`）。
2. 輸入並點選：**`Remote-SSH: Connect to Host...`**
3. 點選 **`+ Add New SSH Host...`**，輸入連線指令（請將 `<您的國網帳號>` 替換為實際帳號）：
   ```bash
   ssh <您的國網帳號>@nano4.nchc.org.tw
   ```
4. 按 Enter 儲存後，在右下角跳出的通知點選 **`Connect`**。
5. 依上方提示框依序選擇 **`Linux`** → 輸入 **主機密碼 (Password)** → 輸入手機 **6 位數驗證碼 (OTP)**。
6. 左下角顯示 **`SSH: nano4.nchc.org.tw`** 即表示連線成功。

---

## 第 3 步：執行 git clone 下載教材至 `/work/$USER/`

連上 Nano4 後，點選上方選單「**終端機 → 新增終端機**」（`Terminal → New Terminal`），將以下指令**整段複製貼入終端機**執行：

```bash
mkdir -p /work/$USER && cd /work/$USER
git clone https://github.com/gemini960114/nano4-ngs-slurm-skill.git
cd /work/$USER/nano4-ngs-slurm-skill
chmod -R a-w AGENTS.md .agents/
pwd
```

### 📦 下載下來的資料夾裡有哪些東西會用到？

我們實際上課與分析只會用到裡面的 **4 個項目**（所有範例數據皆已內建，不需另外下載）：

| 項目 | 檔案/資料夾路徑 | 用途 |
| :--- | :--- | :--- |
| **1. AI 規則** | `AGENTS.md` | 定義 Nano4 GP1 排程規則，讓 AI 自動遵守 |
| **2. AI 技能** | `.agents/skills/` | 提供 Slurm 排程（`nano4-ngs-slurm`）與報告整理（`nano4-ngs-report`）技能 |
| **3. 範例資料** | `data/fastq_4samples/`<br>`data/qiime2/` | • **第 03 章使用**：`data/fastq_4samples/`（4 個輕量 FASTQ 樣本）<br>• **第 04 章使用**：`data/qiime2/`（82 個雙端 FASTQ、Metadata 與分類器） |
| **4. 對話指令** | `Example.md` | 整理好的各階段提示詞，可直接複製貼給 AI Agent |

---

## 第 4 步：在 Antigravity 開啟教材資料夾

請讓 Antigravity 直接開啟該資料夾，AI Agent 才會自動讀取 `AGENTS.md` 與 `.agents/skills/`：

1. 點選上方選單「**檔案 → 開啟資料夾...**」（`File → Open Folder...`）。
2. 輸入剛剛終端機最後顯示的路徑：`/work/<您的帳號>/nano4-ngs-slurm-skill`，按 **OK / 確定**。

---

👉 完成後，請進入 **[第 03 章：基礎 Slurm 作業與品質檢查](../03-basic-slurm-and-qc/README.md)**。
