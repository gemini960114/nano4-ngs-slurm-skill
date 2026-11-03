# 附錄：用 AI 把教材做成 PPTX 簡報 —— 安裝 pptx Skill 與工具，一句話產生上課簡報

本附錄是課後延伸，主要給講師備課使用，不影響範例 1–4 的課程進度。前面五個單元（範例 1-1 到範例 4）都寫成 Markdown 教材，這裡示範用 Anthropic 的 **pptx Skill**，請 AI 把每個單元的 `README.md` 做成上課用的 **PPTX 簡報**：文字可在 PowerPoint 編輯、物件逐一淡入、換頁淡入，並附講者備註。

> 📥 **本單元上課簡報**：[下載 附錄_用AI把教材做成PPTX簡報.pptx](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/%E9%99%84%E9%8C%84_%E7%94%A8AI%E6%8A%8A%E6%95%99%E6%9D%90%E5%81%9A%E6%88%90PPTX%E7%B0%A1%E5%A0%B1.pptx)（13 頁，含講者備註）

| 步驟 | 內容 | 預估時間 |
| :--- | :--- | :---: |
| **第 1 步** | [下載 Anthropic pptx Skill](#第-1-步下載-anthropic-pptx-skill) | 2 分鐘 |
| **第 2 步** | [用自然語言安裝 pptx Skill 需要的工具](#第-2-步用自然語言安裝-pptx-skill-需要的工具) | 15 分鐘 |
| **第 3 步** | [參考現有簡報與影片，產生範例 1-1 的簡報](#第-3-步參考現有簡報與影片產生範例-1-1-的簡報) | 10 分鐘 |
| **第 4 步** | [依序產生其餘四份簡報](#第-4-步依序產生其餘四份簡報) | 每份約 10 分鐘 |
| **第 5 步** | [在 PowerPoint 檢查與微調](#第-5-步在-powerpoint-檢查與微調) | 5 分鐘 |

```mermaid
flowchart LR
    S1["第 1 步：下載 pptx Skill"] --> S2["第 2 步：安裝工具"]
    S2 --> S3["第 3 步：範例 1-1 簡報（含影片）"]
    S3 --> S4["第 4 步：其餘四份簡報"]
    S4 --> S5["第 5 步：PowerPoint 檢查"]
```

> [!NOTE]
> **pptx Skill 的授權**：Anthropic 的 pptx Skill 不是開源授權，只能在 Anthropic 服務中使用，不可再散布或修改。請各自下載到自己的專案，**不要 commit 到 Git**（教材的 `.gitignore` 已排除 `.agents/skills/pptx/`）。

---

## 第 1 步：下載 Anthropic pptx Skill

在 Nano4 終端機、教材根目錄執行，只下載 [anthropics/skills](https://github.com/anthropics/skills) 裡的 `skills/pptx`，放進 `.agents/skills/pptx/`：

```bash
cd /work/$USER/nano4-ngs-slurm-skill
git clone --depth 1 --filter=blob:none --sparse https://github.com/anthropics/skills.git /work/$USER/anthropic-skills
git -C /work/$USER/anthropic-skills sparse-checkout set skills/pptx
cp -r /work/$USER/anthropic-skills/skills/pptx .agents/skills/pptx
ls .agents/skills
```

看到 `nano4-ngs-report`、`nano4-ngs-slurm` 與 `pptx` 三個資料夾即完成。

> [!TIP]
> 部分 Agent 不會自動載入 `.agents/skills/` 下的新 Skill。若之後 AI 沒有照 pptx Skill 的方式產生簡報，在 Prompt 開頭加一句「請先閱讀 .agents/skills/pptx/SKILL.md」即可。

---

## 第 2 步：用自然語言安裝 pptx Skill 需要的工具

pptx Skill 會用到 pptxgenjs（產生簡報）、markitdown（讀取簡報文字）、ffmpeg（處理影片）、LibreOffice（轉 PDF）與 pdftoppm（產生縮圖）。Nano4 沒有 sudo，以下 Prompt 把工具都裝在 `/work/$USER/tools`，並避免影響原本的 Python、Node 與 Slurm 環境：

```text
請在 Nano4 上安裝 Anthropic pptx skill 需要的工具（不需 sudo，全部放在 /work/$USER/tools，不要裝在 /home，也不要動到教材專案的 package.json）：
1. pptxgenjs：npm 安裝到 /work/$USER/tools/node（不是專案目錄），用 NODE_PATH 指過去。
2. markitdown：用 uv 安裝到專案根目錄的 .venv。
3. ffmpeg：下載官方靜態編譯版，只把 ffmpeg、ffprobe 兩個執行檔連結到 /work/$USER/tools/bin。
4. LibreOffice：用 AppImage 解開或 apptainer 容器，只在 /work/$USER/tools/bin 放一個 soffice 包裝腳本；不要把它的目錄或函式庫加進全域 PATH 或 LD_LIBRARY_PATH。
5. pdftoppm : 用在 pptx skill 的 thumbnail.py，把每一頁投影片排成預覽縮圖。

環境設定：
- 修改前先備份 ~/.bashrc。
- PATH 用「附加在後面」（PATH=$PATH:/work/$USER/tools/bin），不要放在最前面，避免蓋過系統指令。
- 設定寫成一個有標記的區塊（例如 # >>> pptx tools >>>），重複執行不會重複加入。
安裝前先跟我說明每項要下載什麼、放在哪裡、大約多大，我確認後再開始；
裝完逐一檢查版本，並確認 which python、which node、module 與 sbatch 都和安裝前一樣，最後用 soffice 把 PPTX/01_Antigravity入門.pptx 轉成 PDF 試跑一次。
```

- **AI 會先列出下載清單等您確認**：LibreOffice 解開後約 700 MB，全部工具合計約 1 GB，都在 `/work/$USER/tools`。
- **LibreOffice 的下載來源**：若 AppImage 下載站從 Nano4 連不上，可請 AI 改用官方 documentfoundation.org 的 RPM 壓縮檔，以 `rpm2cpio` 解開（不安裝到系統）。
- **pdftoppm**：Nano4 沒有內建，可請 AI 用 micromamba 從 conda-forge 安裝 poppler，只把 `pdftoppm` 連結到 `/work/$USER/tools/bin`。
- **最後的試跑轉檔**：Prompt 用講師的 `PPTX/01_Antigravity入門.pptx`；若您沒有這個檔案，請換成手邊任一份 `.pptx`。
- **安裝與轉檔屬於輕量工作**，可在登入節點進行（見 `AGENTS.md`）。日後要移除，刪掉 `/work/$USER/tools` 與 `~/.bashrc` 中標記的區塊即可。

---

## 第 3 步：參考現有簡報與影片，產生範例 1-1 的簡報

如果手邊已有一份風格滿意、含操作影片的簡報（以下以講師的 `PPTX/01_Antigravity入門.pptx` 為例，請換成您自己的檔案），可以請 AI 參考它的配色、版面與影片：

```text
參考01_Antigravity入門.pptx,
參考簡報裡的影片也要一起放進對應的頁面（不要只放截圖），播放方式照參考簡報。
將 01-install-antigravity/README.md 做成 PPTX 簡報 存放在目錄PPTX/。
文字都要能在 PowerPoint 裡編輯（不要做成圖片）
每頁物件依序逐一出現（按一下出現一個），用淡入效果
換頁用淡入效果，慢一點
要講者備註
```

沒有參考簡報時，刪掉前兩行即可，AI 會自行設計版面。

> [!TIP]
> **「參考簡報裡的影片也要一起放進對應的頁面」這句不能省**：只寫「參考」時，AI 常只取影片的封面圖當截圖。加上這句，影片會嵌入對應頁面，並照參考簡報的方式播放（說明逐一出現後再按一下播放，點影片可暫停）。

---

## 第 4 步：依序產生其餘四份簡報

其餘單元不指定參考簡報。在**同一個對話**中依序貼上，AI 會沿用第 3 步的風格，讓整套簡報一致；若開了新對話，可在 Prompt 開頭加一句「風格與 PPTX 目錄裡範例 1-1 的簡報一致」。請一次貼一段，完成一份再貼下一份：

**範例 1-2：連上 Nano4 與下載教材**

```text
將 02-nano4-login-and-setup/README.md 做成 PPTX 簡報 存放在目錄PPTX/。
文字都要能在 PowerPoint 裡編輯（不要做成圖片）
每頁物件依序逐一出現（按一下出現一個），用淡入效果
換頁用淡入效果，慢一點
要講者備註
```

**範例 2：Slurm 基礎練習與自訂 Skill**

```text
將 03-basic-slurm-and-qc/README.md 做成 PPTX 簡報 存放在目錄PPTX/。
文字都要能在 PowerPoint 裡編輯（不要做成圖片）
每頁物件依序逐一出現（按一下出現一個），用淡入效果
換頁用淡入效果，慢一點
要講者備註
```

**範例 3：QIIME 2 管線派送與監控**

```text
將 04-qiime2-microbiome-pipeline/README.md 做成 PPTX 簡報 存放在目錄PPTX/。
文字都要能在 PowerPoint 裡編輯（不要做成圖片）
每頁物件依序逐一出現（按一下出現一個），用淡入效果
換頁用淡入效果，慢一點
要講者備註
```

**範例 4：結果解讀與圖文報告**

```text
將 05-automated-report-skill/README.md 做成 PPTX 簡報 存放在目錄PPTX/。
文字都要能在 PowerPoint 裡編輯（不要做成圖片）
每頁物件依序逐一出現（按一下出現一個），用淡入效果
換頁用淡入效果，慢一點
要講者備註
```

完成後 `PPTX/` 會有五份簡報（講師實測的頁數供參考）。講師產生的這五份簡報與本附錄的簡報，已隨教材放在 `PPTX/`，可以先打開對照：

| 簡報 | 來源單元 | 頁數 |
| :--- | :--- | :---: |
| [1-1_安裝Antigravity與模型設定.pptx](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/1-1_%E5%AE%89%E8%A3%9DAntigravity%E8%88%87%E6%A8%A1%E5%9E%8B%E8%A8%AD%E5%AE%9A.pptx) | 範例 1-1（含 5 段操作影片） | 15 |
| [1-2_連上Nano4與下載教材.pptx](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/1-2_%E9%80%A3%E4%B8%8ANano4%E8%88%87%E4%B8%8B%E8%BC%89%E6%95%99%E6%9D%90.pptx) | 範例 1-2（含 7 段操作影片） | 22 |
| [2_Slurm基礎練習與自訂Skill.pptx](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/2_Slurm%E5%9F%BA%E7%A4%8E%E7%B7%B4%E7%BF%92%E8%88%87%E8%87%AA%E8%A8%82Skill.pptx) | 範例 2 | 19 |
| [3_QIIME2管線派送與監控.pptx](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/3_QIIME2%E7%AE%A1%E7%B7%9A%E6%B4%BE%E9%80%81%E8%88%87%E7%9B%A3%E6%8E%A7.pptx) | 範例 3（含 6 段操作影片） | 20 |
| [4_結果解讀與圖文報告.pptx](https://github.com/gemini960114/nano4-ngs-slurm-skill/raw/main/PPTX/4_%E7%B5%90%E6%9E%9C%E8%A7%A3%E8%AE%80%E8%88%87%E5%9C%96%E6%96%87%E5%A0%B1%E5%91%8A.pptx) | 範例 4 | 10 |

---

## 第 5 步：在 PowerPoint 檢查與微調

把 `.pptx` 下載到自己的電腦（檔案總管按右鍵 → **Download...**），用 PowerPoint 播放一次，檢查：

1. **文字是否溢出**：AI 在 Nano4 上用 LibreOffice 預覽，沒有「微軟正黑體」等字型，實際在 PowerPoint 顯示時字會略大。
2. **動畫與影片**：每按一下出現一個物件；有影片的頁面，說明出現後再按一下會播放。
3. **講者備註**：在「備忘稿」檢視確認每頁都有。

需要修改時，直接用自然語言告訴 AI，例如：

```text
第 9 頁的影片截圖和 Prompt 不一致，請換成新錄的 PPTX/prompt1.mp4，播放方式不變。
```

> [!TIP]
> **想換成學校或單位的樣板？** 把樣板放進 `PPTX/`，在 Prompt 開頭改寫成：「用 PPTX/樣板名稱.pptx 當樣板（沿用它的母片、版面配置、配色與字型，不要重新設計），每段內容挑樣板中最適合的版面，樣板裡的範例文字與圖片要清掉。」只寫「參考」時，AI 會模仿風格重新設計，而不是直接使用樣板。
