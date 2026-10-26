# 範例 1-2：環境建置 —— 連上 Nano4 (Antigravity / VS Code Remote-SSH) 與下載教材

本單元說明如何透過 **Antigravity（或 VS Code）Remote-SSH** 連上國網中心 **晶創26 (`nano4.nchc.org.tw`)**（包含 **IDExpert 雙因子認證** 與免重複認證的 **`ssh-proxy`** 設定），並將教材下載至高速工作區 `/work/$USER/`。

| 步驟 | 內容 |
| :--- | :--- |
| **步驟 A** | [在個人電腦安裝 Antigravity 與 Remote-SSH](#步驟-a在個人電腦安裝-antigravity) |
| **步驟 B** | [確認本機 SSH Config 已配置 (`~/.ssh/config`)](#步驟-b確認本機-ssh-config-已配置) |
| **步驟 C** | [一鍵連入 Nano4 (IDExpert 2FA 驗證)](#步驟-c一鍵連入-nano4) |
| **步驟 D** | [下載教材並開啟遠端工作區 (`/work/your_account`)](#步驟-d下載教材並開啟遠端工作區) |
| **步驟 E** | [（強烈建議）用 `ssh-proxy` 只做一次 2FA 認證](#步驟-e強烈建議用-ssh-proxy-只做一次-2fa-認證) |

---

## 步驟 A：在個人電腦安裝 Antigravity

1. 前往 [Antigravity 官網](https://antigravity.google/) 下載安裝，並以 Google 帳號登入。
2. 在擴充套件面板（`Ctrl + Shift + X`，macOS 為 `Cmd + Shift + X`）確認已有 **Remote - SSH** 套件（若已內建則略過安裝）。
3. 首次連線時，Antigravity 會在 Nano4 的 `~/.antigravity-ide-server` 安裝伺服器端。

> [!TIP]
> **使用 VS Code**：到 [VS Code 官網](https://code.visualstudio.com/) 下載安裝，在擴充套件市場搜尋 **`Remote - SSH`**（Microsoft 官方發行）並安裝。首次連線會在 Nano4 的 `~/.vscode-server` 安裝伺服器端。VS Code 可以使用 Codex 與 Claude Code，但沒有 Antigravity 內建 Agent。

---

## 步驟 B：確認本機 SSH Config 已配置

請在您個人電腦本機的 `~/.ssh/config` 中加入 `nano4` 設定（請將 `your_account` 替換為您的國網主機帳號）：

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
```

---

## 步驟 C：一鍵連入 Nano4

1. 點擊視窗左下角的遠端按鈕（圖示 `><`），在上方彈出的選單中選擇：  
   👉 **`Connect to Host... (連線至主機...)`**
2. 清單中會自動列出 **`nano4`**，點擊選取它。
3. 系統會開啟新視窗並提示連線。在上方提示列選擇連線平台（選擇 **`Linux`**）。
4. 終端機或上方輸入框會彈出 2FA 選項：
   ```text
   Login method (1: Mobile APP OTP, 2: Mobile APP PUSH, 3: Email OTP): 
   ```
   輸入 **`2`** 按 Enter，解鎖手機在 **IDExpert App** 點擊「同意」；隨後輸入您的主機密碼。
5. 驗證通過後，左下角會顯示 **`SSH: nano4`**，表示您已成功連進晶創26！

---

## 步驟 D：下載教材並開啟遠端工作區

1. 連上 Nano4 後，按下 **``Ctrl + ` ``**（或點選上方選單 `Terminal ➔ New Terminal`）開啟遠端終端機，將以下指令**整段複製貼入終端機**執行，把課程教材下載至 WekaFS 高速工作區 `/work/$USER/`：
   ```bash
   mkdir -p /work/$USER && cd /work/$USER
   git clone https://github.com/gemini960114/nano4-ngs-slurm-skill.git
   cd /work/$USER/nano4-ngs-slurm-skill
   pwd
   ```
2. 點擊左側選單的「檔案總管 (Explorer)」➔ 點擊 **Open Folder (開啟資料夾)**（或點選 `File ➔ Open Folder...`）。
3. 在上方輸入框填入剛剛下載的教材工作區路徑（請將 `your_account` 換成您的帳號）：
   ```text
   /work/your_account/nano4-ngs-slurm-skill
   ```
4. 按下確定，您就能在左側清單中看到教材檔案，且 AI Agent 會自動載入資料夾內的 `AGENTS.md` 與 `.agents/skills/`！

### 📦 下載下來的資料夾裡有哪些東西會用到？

上課與分析只會用到以下 **4 個核心項目**（所有範例數據皆已內建，不需另外下載）：

| 項目 | 路徑 | 用途說明 |
| :--- | :--- | :--- |
| **1. 內建範例資料** | `data/fastq_4samples/`<br>`data/qiime2/` | • **範例 2 使用**：`data/fastq_4samples/`（4 個輕量 FASTQ 樣本）<br>• **範例 3 使用**：`data/qiime2/`（82 個雙端 FASTQ、Metadata 與分類器） |
| **2. 對話指令總表** | `Example.md` | 整理好的各階段提示詞（Prompt），可直接複製貼給 AI Agent |
| **3. AI 核心規則** | `AGENTS.md` | 定義 Nano4 GP1 排程安全規範 |
| **4. 自訂 Skills** | `.agents/skills/` | 內含 `nano4-ngs-slurm`（Slurm 排程技能）與 `nano4-ngs-report`（圖文報告技能） |

---

## 步驟 E（強烈建議）：用 ssh-proxy 只做一次 2FA 認證

Nano4 的**每一條新 SSH 連線**都要輸入密碼與 OTP。Antigravity / VS Code 的 Remote-SSH 在「連線」、「Open Folder 選目錄」、「切換資料夾或重新載入視窗」時都會開新連線，所以同一堂課可能要認證好幾次。

[`ssh-proxy`](https://github.com/gemini960114/ssh-proxy) 是在**您個人電腦上**執行的小工具：它先用密碼 + OTP 連上 Nano4 並保持連線，再在本機 `127.0.0.1:2222` 開一個入口。之後 Antigravity 改連 `nano4-proxy`，所有連線都走這條已認證的通道，不必再輸入 OTP。

```text
Antigravity / VS Code / 終端機
        │  連 nano4-proxy（不需 OTP）
        ▼
127.0.0.1:2222   ← ssh-proxy（在您的電腦上執行，視窗保持開著）
        │  已完成密碼 + OTP 的連線
        ▼
nano4.nchc.org.tw:22
```

**1. 下載執行檔**（[Releases 頁面](https://github.com/gemini960114/ssh-proxy/releases/latest)，免安裝 Python）：

| 您的電腦 | 下載檔案 |
| :--- | :--- |
| Windows 10 / 11 | `ssh-proxy-windows-x64.exe` |
| macOS Apple Silicon (M1–M4) | `ssh-proxy-macos-arm64` |
| Linux x64 | `ssh-proxy-linux-x64` |

Intel Mac 沒有預先編譯的檔案，請依 ssh-proxy README 的「Run from Source with uv」方式執行。

**2. 在本機 `~/.ssh/config` 加入 proxy 專用的主機**（保留上面的 `Host nano4`，ssh-proxy 會從它讀取主機名稱與帳號；完整範本見 [`01-nano4-ssh-and-2fa/config/ssh_config_example`](https://github.com/gemini960114/Nano4-Docs/blob/main/01-nano4-ssh-and-2fa/config/ssh_config_example)，已包含下面這段）：

```ssh-config
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

**3. 啟動 proxy，完成一次認證**（在本機終端機 / PowerShell 執行，並讓這個視窗保持開著）：

```bash
# Windows (PowerShell)
.\ssh-proxy-windows-x64.exe nano4

# macOS Apple Silicon（第一次需加執行權限並解除下載隔離）
chmod +x ssh-proxy-macos-arm64
xattr -d com.apple.quarantine ssh-proxy-macos-arm64
./ssh-proxy-macos-arm64 nano4
```

- 第一次連線會顯示 Nano4 的主機金鑰指紋，確認後輸入完整的 `yes`；之後依提示輸入密碼與 OTP。
- 若之後出現 `REMOTE HOST IDENTIFICATION HAS CHANGED`，proxy 會在送出密碼前停止；請先向國網中心確認，不要直接刪除舊金鑰。

**4. 改連 `nano4-proxy`**：

- 終端機：`ssh nano4-proxy`，應直接進入 Nano4，不再要求 OTP。
- Antigravity / VS Code：`Connect to Host...` 時選 **`nano4-proxy`**（不是 `nano4`），之後 Open Folder、切換資料夾都不必再認證。

**5. 使用注意**

- 預設**沒有任何連線 60 分鐘**或**總執行 8 小時**後，proxy 會自動停止；整天的課程可在啟動時加上 `--max-lifetime 10h`。proxy 停止後 Antigravity 會斷線，重新啟動 proxy（再認證一次）並重新連線即可。
- 只在**自己的電腦**上使用：proxy 在執行期間，同一台電腦上的其他程式也能透過它連進您的帳號。使用共用電腦或離開座位前，請在 proxy 視窗按 `Ctrl+C` 停止。
- 若出現 `Address already in use`，表示已有另一個 proxy 在使用 2222 埠，請先關閉它。

---

👉 連線與工作區準備完成後，請進入 **[範例 2：自訂 Skill —— 讀取官方文件、練習派送 Slurm，最後濃縮成專屬技能](../03-basic-slurm-and-qc/README.md)**。
