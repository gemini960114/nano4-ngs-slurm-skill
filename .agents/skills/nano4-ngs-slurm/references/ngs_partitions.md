# Nano4 GP1 生醫專用分區 (`ngs*`) 規格與 QoS 限制總表

以下資料已透過 Nano4 實機 `sinfo`、`scontrol show partition` 與 `sacctmgr show qos` 驗證校正。

> [!IMPORTANT]
> 1. 除跨節點分區 `ngs248c`（`-N 2`）與 `ngs496c`（`-N 4`）外，**所有 `ngs*` 分區皆限制單節點（`MaxNodes=1`）**，不可跨節點使用。
> 2. 除 `ngs248c` 與 `ngs496c` 外，所有 CPU 與大記憶體分區在 `sbatch` 時**必須明確指定 `--cpus-per-task` (`-c`) 與 `--mem`**。
> 3. `squeue` 顯示的 QOS 欄位通常為 `normal`，但背後實際受 Partition 綁定的 `QoS=p_ngs*` 限制。

## 1. NGS 一般 CPU 分區 (節點：`25a-cpn[01-10,16-18]`，單節點 128C / 1000G)

| Partition | 核心數 (`-c`) | 記憶體 (`--mem`) | 時間上限 (`MaxTime`) | 個人同時執行上限 (`MaxJobsPU`) | 對應 QoS | 實機允許計畫 (`AllowAccounts`) | 適用場景 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`ngstest`** | `1` | `8G` | 10 分鐘 (`10:00`) | 2 | `p_ngstest` | `mst109178,ent109430,gov115089` | 快速語法除錯、微型測試 |
| **`ngsconsole`** | `1` | `8G` | 無限制 (`infinite`) | 2 | `p_ngsconsole` | `mst109178,ent109430,gov115089` | 互動式命令列操作 |
| **`ngs8g`** | `1` | `8G` | 48 小時 (`2-00:00:00`) | 1000 | `p_ngs8g` | `mst109178,ent109430,gov115089` | 單核心大量批次小任務 |
| **`ngs16g`** | `2` | `16G` | 48 小時 (`2-00:00:00`) | 500 | `p_ngs16g` | `mst109178,ent109430,gov115089` | 雙核心輕量分析 |
| **`ngs32g`** | `4` | `32G` | 96 小時 (`4-00:00:00`) | 250 | `p_ngs32g` | `mst109178,ent109430,gov115089` | 四核心中小型分析 |
| **`ngs62g`** ★ | `8` | `62G` | 96 小時 (`4-00:00:00`) | 120 | `p_ngs62g` | `mst109178,ent109430,gov115088,gov115089` | **課程唯一可用佇列** (FASTQ QC, Amplicon) |
| **`ngs125g`** | `16` | `125G` | 無限制 (`infinite`) | 60 | `p_ngs125g` | `mst109178,ent109430,gov115089` | 中型基因體分析 |
| **`ngs250g`** | `32` | `250G` | 無限制 (`infinite`) | 30 | `p_ngs250g` | `mst109178,ent109430,gov115089` | 基因體比對、Variant Calling |
| **`ngs500g`** | `64` | `500G` | 無限制 (`infinite`) | 15 | `p_ngs500g` | `mst109178,ent109430,gov115089` | 大型基因體深度運算 |
| **`ngs1000g`** | `124` | `1000G` | 無限制 (`infinite`) | 8 | `p_ngs1000g` | `mst109178,ent109430,gov115089` | 單節點滿載 CPU 運算 |
| **`ngs248c`** | `124`×2 (`-N 2`) | **不指定** | 無限制 (`infinite`) | 4 | `p_ngs248c` | `mst109178,ent109430,gov115089` | 跨 2 節點大規模平行運算 |
| **`ngs496c`** | `124`×4 (`-N 4`) | **不指定** | 無限制 (`infinite`) | 2 | `p_ngs496c` | `mst109178,ent109430,gov115089` | 跨 4 節點大規模平行運算 |

## 2. NGS 超大記憶體分區 Fat Node (節點：`25a-mpn[01-02]`，單節點 128C / 6000G)

| Partition | 核心數 (`-c`) | 記憶體 (`--mem`) | 時間上限 (`MaxTime`) | 個人同時執行上限 (`MaxJobsPU`) | 對應 QoS | 實機允許計畫 (`AllowAccounts`) | 適用場景 |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`ngs1500g`** | `32` | `1500G` | 無限制 (`infinite`) | 4 | `p_ngs1500g` | `mst109178,ent109430` | De novo 組裝、大記憶體分析 |
| **`ngs2t`** | `42` | `2000G` | 無限制 (`infinite`) | 3 | `p_ngs2t` | `mst109178,ent109430` | 2TB 巨量記憶體組裝 |
| **`ngs3t`** | `64` | `3000G` | 無限制 (`infinite`) | 2 | `p_ngs3t` | `mst109178,ent109430` | 3TB 巨量記憶體組裝 |
| **`ngs6t`** | `124` | `6000G` | 無限制 (`infinite`) | 1 | `p_ngs6t` | `mst109178,ent109430` | 6TB 單節點極限記憶體組裝 |

## 3. NGS 生醫專屬 GPU 分區 (節點：`25a-hgpn[170-177]`，NVIDIA H200)

> [!WARNING]
> 1. 實機 QoS 名稱在 `ngs2gpu`、`ngs4gpu`、`ngs8gpu` 帶有字尾 `s`（即 `p_ngs2gpus`、`p_ngs4gpus`、`p_ngs8gpus`），且強制檢查 `MinTRES=gres/gpu=N`。
> 2. 課程若採 CPU-only 配置，請勿使用此區。

| Partition | GPU 配置 (`--gres`) | 建議核心數 (`-c`) | 建議記憶體 (`--mem`) | 時間上限 (`MaxTime`) | 個人上限 (`MaxJobsPU`) | 對應 QoS | 實機允許計畫 (`AllowAccounts`) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`ngs1gpu`** | `--gres=gpu:1` | `12` | `200G` | 14 天 (`14-00:00:00`) | 8 | `p_ngs1gpu` | `mst109178,ent109430` |
| **`ngs2gpu`** | `--gres=gpu:2` | `24` | `400G` | 14 天 (`14-00:00:00`) | 4 | `p_ngs2gpus` | `mst109178,ent109430` |
| **`ngs4gpu`** | `--gres=gpu:4` | `48` | `800G` | 14 天 (`14-00:00:00`) | 2 | `p_ngs4gpus` | `mst109178,ent109430` |
| **`ngs8gpu`** | `--gres=gpu:8` | `96` | `1600G` | 14 天 (`14-00:00:00`) | 1 | `p_ngs8gpus` | `mst109178,ent109430` |

## 4. NGS 課程專用分區 (`ngscourse*`，節點：`25a-cpn[01-10,16-18]`)

| Partition | 核心數 (`-c`) | 記憶體 (`--mem`) | 時間上限 (`MaxTime`) | 個人同時執行上限 (`MaxJobsPU`) | 對應 QoS | 實機允許計畫 (`AllowAccounts`) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **`ngscourseconsole`** | `1` | `8G` | 無限制 (`infinite`) | 1 | `p_ngscourseconsole` | `ent109430,acd115209,gov115148` |
| **`ngscourse8g`** | `1` | `8G` | 2 小時 (`02:00:00`) | 10 | `p_ngscourse8g` | `ent109430,acd115209,gov115148` |
| **`ngscourse16g`** | `2` | `16G` | 3 小時 (`03:00:00`) | 5 | `p_ngscourse16g` | `ent109430,acd115209,gov115148` |
| **`ngscourse32g`** | `4` | `32G` | 4 小時 (`04:00:00`) | 5 | `p_ngscourse32g` | `ent109430,acd115209,gov115148` |
| **`ngscourse62g`** | `8` | `62G` | 8 小時 (`08:00:00`) | 4 | `p_ngscourse62g` | `ent109430,acd115209,gov115148` |
| **`ngscourse125g`** | `16` | `125G` | 24 小時 (`1-00:00:00`) | 2 | `p_ngscourse125g` | `ent109430,acd115209,gov115148` |
| **`ngscourse250g`** | `32` | `250G` | 24 小時 (`1-00:00:00`) | 1 | `p_ngscourse250g` | `ent109430,acd115209,gov115148` |
