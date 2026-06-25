## 🧠 終極版演算法狀態機圖 (ASM / SM Chart)

本專案將複雜的遊戲控制與防呆後門邏輯，嚴格依據時脈週期（Clock Cycle）收斂為以下工整的 SM Chart 架構：

```mermaid
%%{ init: { 'flowchart': { 'curve': 'basis', 'htmlLabels': true } } }%%
flowchart TD
    %% 狀態樣式定義 (標準數位邏輯電路配色)
    classDef state fill:#E1F5FE,stroke:#03A9F4,stroke-width:2px,color:#000;
    classDef decision fill:#FFF9C4,stroke:#FBC02D,stroke-width:2px,color:#000;
    classDef mealy fill:#E8F5E9,stroke:#4CAF50,stroke-width:2px,color:#000;

    %% --- [ 階段一：系統設定期 ] ---
    S_SETUP["[ 狀態: S_SETUP ]<br/>顯示: Display Mode / Difficulty"]:::state --> Q_Confirm{"Confirm == '1'?"}:::decision
    Q_Confirm -- No --> S_SETUP
    Q_Confirm -- Yes --> Latch_Setup([寫入 Fin / Diff / Time &lt;= 99s / Solve &lt;= 0]):::mealy --> S_NEW_BOMB

    %% --- [ 階段二：炸彈生成與等待 ] ---
    S_NEW_BOMB["[ 狀態: S_NEW_BOMB ]<br/>動作: 隨機生成 PWD<br/>重置: Max &lt;= 99, Min &lt;= 00"]:::state --> S_WAIT_START
    
    S_WAIT_START["[ 狀態: S_WAIT_START ]"]:::state --> Q_Start{"Start == '1'?"}:::decision
    Q_Start -- No --> S_WAIT_START
    Q_Start -- Yes --> S_PLAY

    %% --- [ 階段三：核心遊戲倒數 ] ---
    S_PLAY["[ 狀態: S_PLAY ]<br/>致能: Timer_EN &lt;= '1'<br/>顯示: Time / Min / Max / Entered"]:::state --> Q_TimeZero{"Time == 0s?"}:::decision
    Q_TimeZero -- Yes --> S_LOSE
    Q_TimeZero -- No --> Q_Enter{"Enter == '1'?"}:::decision
    Q_Enter -- No --> S_PLAY
    Q_Enter -- Yes --> S_EVAL

    %% --- [ 階段四：資料解碼與核心比較 ] ---
    S_EVAL["[ 狀態: S_EVAL ]<br/>致能: Timer_EN &lt;= '0' (時間暫停)"]:::state --> Q_Match{"NUM == PWD?"}:::decision
    
    %% 猜中密碼分支 (Y)
    Q_Match -- Yes (猜中) --> Inc_Solve([Solve &lt;= Solve + 1]):::mealy --> S_CHECK_WIN
    
    %% 猜錯分支 (N) -> 進入防呆與大小檢查
    Q_Match -- No --> Q_Greater{"NUM &gt; PWD?"}:::decision
    
    Q_Greater -- Yes (大於) --> Q_Invalid{"NUM 範圍非法?"}:::decision
    Q_Greater -- No (小於) --> S_UPDATE_MIN
    
    %% 防呆與後門密技邏輯
    Q_Invalid -- No (正常猜大) --> S_UPDATE_MAX
    Q_Invalid -- Yes (超出範圍) --> Q_Cheat{"NUM == 'AA'?"}:::decision
    
    Q_Cheat -- Yes (密技) --> S_CHEAT_DISP
    Q_Cheat -- No (純錯誤) --> S_ERROR_DISP

    %% --- [ 階段五：資料更新狀態處理 ] ---
    S_UPDATE_MAX["[ 狀態: S_UPDATE_MAX ]<br/>動作: Max &lt;= NUM"]:::state --> S_PLAY
    S_UPDATE_MIN["[ 狀態: S_UPDATE_MIN ]<br/>動作: Min &lt;= NUM"]:::state --> S_PLAY
    S_CHEAT_DISP["[ 狀態: S_CHEAT_DISP ]<br/>顯示: 密碼全亮 (後門)"]:::state --> S_PLAY
    S_ERROR_DISP["[ 狀態: S_ERROR_DISP ]<br/>顯示: Display ERROR"]:::state --> S_PLAY

    %% --- [ 階段六：連勝勝利條件判定 ] ---
    S_CHECK_WIN["[ 狀態: S_CHECK_WIN ]"]:::state --> Q_Win{"Solve == Fin?"}:::decision
    Q_Win -- Yes (達標) --> S_WIN
    
    %% 多軌獎勵加時判斷 (No)
    Q_Win -- No --> Q_ModeBonus{"依據 Mode 進行分流"}:::decision
    Q_ModeBonus -- Mode 2 --> Bonus_10([Time &lt;= Time + 10s]):::mealy --> S_NEW_BOMB
    Q_ModeBonus -- Mode 1/3 --> Bonus_20([Time &lt;= Time + 20s]):::mealy --> S_NEW_BOMB
    Q_ModeBonus -- Mode 0 --> Bonus_30([Time &lt;= Time + 30s]):::mealy --> S_NEW_BOMB

    %% --- [ 階段七：遊戲終局結算 ] ---
    S_WIN["[ 狀態: S_WIN ]<br/>顯示: WIN 畫面與進度條燈號"]:::state --> Q_ResetWin{"Reset == '1'?"}:::decision
    Q_ResetWin -- No --> S_WIN
    Q_ResetWin -- Yes --> S_SETUP

    S_LOSE["[ 狀態: S_LOSE ]<br/>顯示: Display LOSE (DEAD)"]:::state --> Q_ResetLose{"Reset == '1'?"}:::decision
    Q_ResetLose -- No --> S_LOSE
    Q_ResetLose -- Yes --> S_SETUP
