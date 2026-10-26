# 範例 1-2：環境建置 —— 連上 Nano4 (Remote-SSH) 與下載教材

完成前一單元的 Antigravity IDE 安裝後，本單元說明如何設定本機 SSH Config、透過 **IDExpert 雙因子認證**（或搭配 **`ssh-proxy` 免重複認證**）連上國網中心 **晶創26 (`nano4.nchc.org.tw`)**，最後將課程教材下載至高速工作區 `/work/$USER/` 並開啟。

| 步驟 | 內容 |
| :--- | :--- |
| **步驟 A** | [前置確認：iService 主機帳號與手機 IDExpert 2FA App](#步驟-a前置確認iservice-主機帳號與手機-idexpert-2fa-app) |
| **步驟 B** | [設定本機 SSH Config（一次加入 `nano4` 與 `nano4-proxy`）](#步驟-b設定本機-ssh-config) |
| **步驟 C** | [（強烈建議）啟動 `ssh-proxy`：整堂課只做一次 2FA 認證](#步驟-c強烈建議啟動-ssh-proxy整堂課只做一次-2fa-認證) |
| **步驟 D** | [在 Antigravity 連入 Nano4](#步驟-d在-antigravity-連入-nano4) |
| **步驟 E** | [下載教材並開啟遠端工作區 (`/work/your_account/nano4-ngs-slurm-skill`)](#步驟-e下載教材並開啟遠端工作區) |

---

## 步驟 A：前置確認：iService 主機帳號與手機 IDExpert 2FA App

在連線前，請確認您已完成以下準備：
1. **國網主機帳號與密碼**：已於 [iService 會員系統](https://iservice.nchc.org.tw/nchc_service/index.php)（會員中心 ➔ 會員資訊 ➔ 主機帳號資訊）確認您的主機帳號與密碼，並加入課程或生醫計畫（本課程使用 **`GOV115088`**）。
2. **手機綁定 IDExpert App（雙因子認證 2FA）**：晶創26強制要求雙因子認證，請確認手機已安裝 **IDExpert** App 並完成帳號綁定。
3. **首次啟用提醒**：若是全新申請的國網帳號，第一次透過 SSH 成功登入 `nano4.nchc.org.tw` 時，系統會自動為您初始化建立 `$HOME` 家目錄；登入成功後，後續的 `~/.antigravity-ide-server` 安裝與 Slurm 排程才能正常運作。

---

## 步驟 B：設定本機 SSH Config

我們先在您個人電腦本機的 `~/.ssh/config` 一次加入 `nano4`（直連用）與 `nano4-proxy`（免重複輸入 2FA 代理用）兩組設定，之後就不必再回頭改設定檔：

1. 在 Antigravity IDE 按下快捷鍵 **`F1`**（或 `Ctrl + Shift + P` / Mac 按 `Cmd + Shift + P`）。
2. 輸入並點選：**`Remote-SSH: Open SSH Configuration File...`**，接著點選清單中的第一個路徑（即您個人電腦的 `C:\Users\<使用者>\.ssh\config` 或 `~/.ssh/config`）。
3. 在開啟的設定檔中貼上以下內容並存檔（`Ctrl + S` / `Cmd + S`，**請將兩處 `your_account` 皆替換為您的國網主機帳號**）：

```ssh-config
Host nano4
  #HostName nano4.nchc.org.tw
  HostName 140.110.109.162
  User your_account

  # 直接進入 OTP / MFA 驗證流程
  PubkeyAuthentication no
  KbdInteractiveAuthentication yes
  PreferredAuthentications keyboard-interactive,password

  # 維持及偵測連線狀態
  ServerAliveInterval 30
  ServerAliveCountMax 3

  # 如果目前網路確實需要，再保留
  IPQoS none

Host nano4-proxy
  HostName 127.0.0.1
  Port 2222
  User your_account
  # 本機 proxy 每次啟動都會產生新的暫時金鑰；這兩行只能用在這個 127.0.0.1 別名，
  # 絕對不要加到 nano4 或其他遠端主機
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel ERROR
  ServerAliveInterval 30
  ServerAliveCountMax 3
```

---

## 步驟 C（強烈建議）：啟動 `ssh-proxy`：整堂課只做一次 2FA 認證

Nano4 的**每一條新 SSH 連線**都要輸入密碼與 OTP。Antigravity / VS Code 的 Remote-SSH 在「第一次連線」、「點選 Open Folder 開啟教材資料夾」、「切換資料夾或重新載入視窗」時都會開新連線，若直接連 `nano4`，同一堂課要重複認證好幾次。

[`ssh-proxy`](https://github.com/gemini960114/ssh-proxy) 是在**您個人電腦上**執行的小工具：它先用密碼 + OTP 連上 Nano4 並保持連線，再在本機 `127.0.0.1:2222` 開一個入口。之後 Antigravity 改連 `nano4-proxy`，所有連線都走這條已認證的通道，不必再輸入 OTP。

```text
Antigravity / VS Code / 終端機
        │  連 nano4-proxy（不需重複 OTP）
        ▼
127.0.0.1:2222   ← ssh-proxy（在您的電腦上執行，視窗保持開著）
        │  已完成密碼 + OTP 的連線
        ▼
nano4.nchc.org.tw:22
```

1. **下載執行檔**（前往 [Releases 頁面](https://github.com/gemini960114/ssh-proxy/releases/latest) 下載，免安裝 Python）：

   | 您的電腦 | 下載檔案 |
   | :--- | :--- |
   | Windows 10 / 11 | `ssh-proxy-windows-x64.exe` |
   | macOS Apple Silicon (M1–M4) | `ssh-proxy-macos-arm64` |
   | Linux x64 | `ssh-proxy-linux-x64` |

   *(註：Intel Mac 無預編譯檔，請依 ssh-proxy README 的「Run from Source with uv」方式執行；若不想使用 `ssh-proxy`，也可略過本步驟，直接在下一步選 `nano4` 連線。)*

2. **在本機終端機 / PowerShell 啟動 proxy，完成一次認證**（執行後**請讓這個視窗保持開著**）：

   ```bash
   # Windows (PowerShell，請先 cd 到下載目錄)
   .\ssh-proxy-windows-x64.exe nano4

   # macOS Apple Silicon（第一次需加執行權限並解除下載隔離）
   chmod +x ssh-proxy-macos-arm64
   xattr -d com.apple.quarantine ssh-proxy-macos-arm64
   ./ssh-proxy-macos-arm64 nano4
   ```
   - 第一次連線會顯示 Nano4 的主機金鑰指紋，確認後輸入完整的 `yes`。
   - 當出現 `Login method (1: Mobile APP OTP, 2: Mobile APP PUSH, 3: Email OTP):` 時，輸入 **`2`** 按 Enter，解鎖手機在 **IDExpert App** 點擊「同意」（或輸入 `1` 並填入 6 位數 OTP），再輸入您的主機密碼。
   - 看到 `Proxy listening on 127.0.0.1:2222` 即代表通道已建立！（離開座位或下課時，在此視窗按 `Ctrl + C` 即可關閉。）

---

## 步驟 D：在 Antigravity 連入 Nano4

1. 點擊 Antigravity 視窗左下角的遠端按鈕（圖示 `><`），在上方彈出的選單中選擇：  
   👉 **`Connect to Host... (連線至主機...)`**
2. 選擇連線目標：
   - **有啟動步驟 C 的 `ssh-proxy`（推薦）**：點擊選取 **`nano4-proxy`**（直接進入，**不需再輸入密碼與 2FA**！）。
   - **未啟動 `ssh-proxy`（直連）**：點擊選取 **`nano4`**，依上方提示框選擇 `Linux` ➔ 輸入 `2` 在手機 **IDExpert App** 點擊「同意」➔ 輸入主機密碼。
3. 連線成功後，視窗左下角會顯示綠色的 **`SSH: nano4-proxy`**（或 **`SSH: nano4`**）！

> [!IMPORTANT]
> **若您使用外掛型 Agent（選項 B 的 Claude Code / Codex，或選項 C 的 OpenCode）**：
> 連上 Nano4 後，請打開左側「擴充功能 (Extensions)」，在該套件旁點擊 **`Install in SSH: nano4-proxy`**（或在遠端終端機安裝 OpenCode），將 Agent 安裝至 Nano4 遠端環境！若您使用預設的 **Antigravity 內建 Agent（選項 A）** 則不需額外安裝。

---

## 步驟 E：下載教材並開啟遠端工作區

> [!NOTE]
> **儲存空間規則**：Nano4 的家目錄 `/home/$USER` 上限僅 100 GB；**所有課程教材、定序資料與分析結果請一律放在高速工作區 `/work/$USER/` 下！**

1. 在已連上 Nano4 的 Antigravity 視窗中，按下 **``Ctrl + ` ``**（或點選上方選單 `Terminal ➔ New Terminal`）開啟遠端終端機，將以下指令**整段複製貼入終端機**執行：
   ```bash
   mkdir -p /work/$USER && cd /work/$USER
   git clone https://github.com/gemini960114/nano4-ngs-slurm-skill.git
   cd /work/$USER/nano4-ngs-slurm-skill
   pwd
   ```
2. 點擊左側選單的「檔案總管 (Explorer)」➔ 點擊 **Open Folder (開啟資料夾)**（或點選上方選單 `File ➔ Open Folder...`）。
3. 在上方輸入框填入剛剛終端機最後印出的路徑（請將 `your_account` 換成您的國網帳號）：
   ```text
   /work/your_account/nano4-ngs-slurm-skill
   ```
4. 按下 **OK / 確定**（若詢問是否信任此資料夾，請點擊 **Yes, I trust the authors**）。

### 📦 下載下來的資料夾裡有哪些東西會用到？

上課與分析只會用到以下 **4 個核心項目**（所有範例數據皆已內建，不需另外下載）：

| 項目 | 路徑 | 用途說明 |
| :--- | :--- | :--- |
| **1. 內建範例資料** | `data/fastq_4samples/`<br>`data/qiime2/` | • **範例 2 使用**：`data/fastq_4samples/`（4 個輕量 FASTQ 樣本）<br>• **範例 3 使用**：`data/qiime2/`（82 個雙端 FASTQ、Metadata 與分類器） |
| **2. 對話指令總表** | `Example.md` | 整理好的各階段提示詞（Prompt），可直接複製貼給 AI Agent |
| **3. AI 核心規則** | `AGENTS.md` | 定義 Nano4 GP1 排程安全規範（下個單元將示範這份規則是如何讓 AI 自動產生的） |
| **4. 自訂 Skills** | `.agents/skills/` | 內含 `nano4-ngs-slurm`（Slurm 排程技能）與 `nano4-ngs-report`（圖文報告技能） |

---

👉 連線與工作區準備完成後，請進入 **[範例 2：自訂 Skill —— 讀取官方文件、練習派送 Slurm，最後濃縮成專屬技能](../03-basic-slurm-and-qc/README.md)**。
