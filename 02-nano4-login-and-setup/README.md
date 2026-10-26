# 第 02 章：連上 Nano4 超算 (2FA) 與取得教材

本章教您如何用剛剛裝好的 **Antigravity IDE** 遠端連進國網中心 **晶創26 (`nano4.nchc.org.tw`)**，並用**一段複製貼上的指令**把本課程教材與數據下載到您的高速工作區 `/work/$USER/`。

| 步驟 | 做什麼 | 說明 |
| :--- | :--- | :--- |
| **第 1 步** | [了解 Nano4 雙因子登入 (密碼 + 6 位數 OTP)](#第-1-步了解-nano4-雙因子登入-2fa) | 登入前必知規則 |
| **第 2 步** | [用 Antigravity Remote-SSH 連上 Nano4](#第-2-步用-antigravity-remote-ssh-連上-nano4) | 圖形化連線，免記複雜指令 |
| **第 3 步** | [複製貼上一行指令：下載教材與設定唯讀鎖](#第-3-步複製貼上一行指令下載教材與設定唯讀鎖) | 自動放在 `/work/$USER/` |
| **第 4 步** | [開啟專案資料夾，啟動 AI 自動規則](#第-4-步開啟專案資料夾啟動-ai-自動規則) | 讓 AI 讀懂 `AGENTS.md` |

---

## 第 1 步：了解 Nano4 雙因子登入 (2FA)

連線至國網中心 Nano4（主機位址：`nano4.nchc.org.tw`）需要通過**兩道驗證**：
1. **第一道（Password）**：輸入您的國網 iService 主機密碼。
2. **第二道（Verification code / OTP）**：打開手機上的認證 App（如 Google Authenticator / Microsoft Authenticator），輸入當下顯示的 **6 位數動態驗證碼**。

> [!IMPORTANT]
> **Nano4 兩大空間鐵律（千萬別放錯地方）**：
> - **`/home/$USER`（家目錄，上限僅 100 GB）**：只放設定檔，不要放定序資料或容器映像檔。
> - **`/work/$USER`（高速工作區，大容量）**：**本課程所有教材、定序資料與分析結果，一律放在 `/work/$USER`！**

---

## 第 2 步：用 Antigravity Remote-SSH 連上 Nano4

1. 在 Antigravity IDE 按下快捷鍵 **`F1`**（或 `Ctrl + Shift + P` / Mac 按 `Cmd + Shift + P`）。
2. 輸入並點選：**`Remote-SSH: Connect to Host...`**
3. 點選 **`+ Add New SSH Host...`**，輸入以下連線字串（請將 `<您的國網帳號>` 換成您的帳號，例如 `u00cjz00`）：
   ```bash
   ssh <您的國網帳號>@nano4.nchc.org.tw
   ```
4. 按 Enter 儲存至預設的 SSH 設定檔後，在跳出的通知點選 **`Connect`**。
5. 依上方輸入框提示：
   - 若詢問平台類型，選擇 **`Linux`**
   - 輸入您的 **主機密碼 (Password)**
   - 輸入手機 App 上的 **6 位數驗證碼 (OTP)**
6. 左下角狀態列顯示綠色的 **`SSH: nano4.nchc.org.tw`**，就代表您已經成功連進超級電腦了！

---

## 第 3 步：複製貼上一行指令：下載教材與設定唯讀鎖

連上 Nano4 後，請點選上方選單「**終端機 → 新增終端機**」（`Terminal → New Terminal`），把下方這段指令**整段複製貼進終端機**按 Enter 執行：

```bash
mkdir -p /work/$USER && cd /work/$USER
git clone https://github.com/gemini960114/nano4-ngs-slurm-skill.git
cd /work/$USER/nano4-ngs-slurm-skill
chmod -R a-w AGENTS.md .agents/
pwd
```

> [!NOTE]
> **這段指令幫您做了什麼？**
> 1. 自動切換到您的大容量高速工作區 `/work/$USER/`。
> 2. 把包含「AI 規則 (`AGENTS.md`)、排程與報告技能 (`.agents/skills/`)、以及所有練習用 FASTQ 與 QIIME 2 資料 (`data/`)」完整下載下來。
> 3. 將 `AGENTS.md` 與 `.agents/` 上鎖為唯讀（`chmod -R a-w`），防止 AI 在排錯過程中誤改國網安全規範。

---

## 第 4 步：開啟專案資料夾，啟動 AI 自動規則

這一步最關鍵！必須讓 Antigravity 直接打開剛剛下載的資料夾，AI 才會自動載入 `AGENTS.md` 規則與專屬 Skills：

1. 點選上方選單「**檔案 → 開啟資料夾...**」（`File → Open Folder...`）。
2. 在路徑輸入框輸入剛剛終端機最後印出的路徑（即 `/work/<您的帳號>/nano4-ngs-slurm-skill`），點擊 **OK / 確定**。
3. 重新載入視窗後，您會在左側檔案總管看到：
   - `AGENTS.md`（AI 自動遵守的 Nano4 GP1 規範）
   - `Example.md`（所有可直接複製貼上的自然語言提示詞）
   - `data/`（內建的 FASTQ 與 QIIME 2 完整教材數據，免額外下載）

---

🎉 **環境準備完成！** 接下來您不需要自己寫程式碼，請直接進入 **[第 03 章：基礎實戰 —— 用自然語言跑 Slurm 與質控](../03-basic-slurm-and-qc/README.md)**，開始複製貼上 Prompt 讓 AI 幫您跑超級電腦！
