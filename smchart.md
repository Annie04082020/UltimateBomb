
## 🧠 硬體核心狀態機 (Algorithmic State Machine Chart)

本專案採用 **ASM Chart** 進行時序與資料路徑規劃，確保每一個「狀態方塊」與其附帶的「判斷條件」皆嚴格收斂於**單一 Clock 週期**內執行完畢。

```mermaid
graph TD
    %% 樣式定義 (GitHub 原生配色優化)
    classDef state fill:#E1F5FE,stroke:#03A9F4,stroke-width:2px,color:#000;
    classDef decision fill:#FFF9C4,stroke:#FBC02D,stroke-width:2px,color:#000;
    classDef mealy fill:#E8F5E9,stroke:#4CAF50,stroke-width:2px,color:#000;

    %% --- [ 區塊 0: 設定準備期 ] ---
    S_SETUP["[ 狀態: S_SETUP ]<br/>等待玩家設定門檻與難度"]:::state --> Q_Confirm{"Confirm == '1'?"}:::decision
    Q_Confirm -- No --> S_SETUP
    Q_Confirm -- Yes --> Latch_Settings([寫入 Fin / Diff / Time=99s / Solve=0]):::mealy --> S_NEW_BOMB

    %% --- [ 區塊 1: 產生新炸彈 ] ---
    S_NEW_BOMB["[ 狀態: S_NEW_BOMB ]<br/>Load_PWD &lt;- '1'<br/>Max &lt;- 99, Min &lt;- 00"]:::state --> S_WAIT_START

    %% --- [ 區塊 2: 等待按開始 ] ---
    S_WAIT_START["[ 狀態: S_WAIT_START ]"]:::state --> Q_Start{"Start == '1'?"}:::decision
    Q_Start -- No --> S_WAIT_START
    Q_Start -- Yes --> S_PLAY

    %% --- [ 區塊 3: 倒數計時中 ] ---
    S_PLAY["[ 狀態: S_PLAY ]<br/>Timer_EN &lt;- '1'"]:::state --> Q_TimeZero{"Time == 0s?"}:::decision
    Q_TimeZero -- Yes --> S_LOSE
    Q_TimeZero -- No --> Q_Enter{"Enter == '1'?"}:::decision
    Q_Enter -- No --> S_PLAY
    Q_Enter -- Yes --> S_EVAL

    %% --- [ 區塊 4: 判定輸入大小 ] ---
    S_EVAL["[ 狀態: S_EVAL ]<br/>Timer_EN &lt;- '0' (時間暫停)"]:::state --> Q_Match{"NUM == PWD?"}:::decision
    
    Q_Match -- Yes (拆彈成功!) --> Inc_Solve([Solve &lt;- Solve + 1]):::mealy --> S_CHECK_WIN
    Q_Match -- No --> Q_Greater{"NUM &gt; PWD?"}:::decision

    Q_Greater -- Yes (猜太大) --> S_UPDATE_MAX
    Q_Greater -- No (猜太小) --> S_UPDATE_MIN

    %% --- [ 區塊 5 & 6: 更新上下限 ] ---
    S_UPDATE_MAX["[ 狀態: S_UPDATE_MAX ]<br/>Load_Max &lt;- '1'"]:::state --> S_PLAY
    S_UPDATE_MIN["[ 狀態: S_UPDATE_MIN ]<br/>Load_Min &lt;- '1'"]:::state --> S_PLAY

    %% --- [ 區塊 7: 勝利門檻結算 ] ---
    S_CHECK_WIN["[ 狀態: S_CHECK_WIN ]"]:::state --> Q_Win{"Solve == Fin?"}:::decision
    Q_Win -- Yes (達標獲勝) --> S_WIN
    Q_Win -- No (續命抽下一題) --> Add_Time([獎勵時間 Time + 30s]):::mealy --> S_NEW_BOMB

    %% --- [ 區塊 8 & 9: 終局結算 ] ---
    S_WIN["[ 狀態: S_WIN ]<br/>觸發勝利燈光秀"]:::state --> Q_ResetWin{"Reset == '1'?"}:::decision
    Q_ResetWin -- No --> S_WIN
    Q_ResetWin -- Yes --> S_SETUP

    S_LOSE["[ 狀態: S_LOSE ]<br/>顯示 DEAD 失敗畫面"]:::state --> Q_ResetLose{"Reset == '1'?"}:::decision
    Q_ResetLose -- No --> S_LOSE
    Q_ResetLose -- Yes --> S_SETUP
