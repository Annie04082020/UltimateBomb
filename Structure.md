# 拆彈遊戲 電路架構圖 (Architecture Block Diagram)

這份架構圖將系統分為：輸入單元、控制單元、記憶單元、運算邏輯單元與輸出單元。
您可以使用支援 Mermaid 的 Markdown 編輯器 (如 VSCode, Obsidian) 或貼到 [Mermaid Live Editor](https://mermaid.live/) 來預覽並匯出成簡報用的圖片。

```mermaid
graph TD
    %% 定義節點顏色風格 (加上 color:#000000 確保白底/黑底都能清楚看到深色字體)
    classDef input fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000000;
    classDef control fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000000;
    classDef memory fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000000;
    classDef alu fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px,color:#000000;
    classDef output fill:#ffebee,stroke:#b71c1c,stroke-width:2px,color:#000000;

    %% 外部輸入
    subgraph Input_Unit ["【 輸入單元 】"]
        I_Confirm["confirm (Button)<br>(確認/開始)"]:::input
        I_Mode["mode (Button)<br>(切換難度)"]:::input
        I_Switch["k0-k7, diff<br>(數值與模式輸入)"]:::input
        I_Ctrl["rst<br>(系統重置)"]:::input
        I_Clk["clk, countdown<br>(系統與倒數時脈)"]:::input
    end

    %% 控制單元
    subgraph Control_Unit ["【 控制單元 】"]
        C_FSM["Game Controller<br>(主狀態機 FSM)"]:::control
        C_Level["Level Manager<br>(關卡與勝利結算)"]:::control
    end

    %% 記憶單元
    subgraph Memory_Unit ["【 記憶單元 】"]
        M_Mode["Mode Selector<br>(模式設定暫存)"]:::memory
        M_Min["Min Register<br>(下限暫存器)"]:::memory
        M_Max["Max Register<br>(上限暫存器)"]:::memory
    end

    %% 運算邏輯單元
    subgraph ALU_Unit ["【 運算邏輯單元 】"]
        A_RNG["Random Generator<br>(亂數密碼產生)"]:::alu
        A_Comp["Password Comparator<br>(數值比較器)"]:::alu
        A_Timer["Countdown Timer<br>(倒數與時間檢查)"]:::alu
    end

    %% 輸出單元
    subgraph Output_Unit ["【 輸出單元 】"]
        O_State["16-SEG Decoder<br>(英文狀態顯示)"]:::output
        O_LED["ROM LED Arranger<br>(進度條顯示)"]:::output
        O_7Seg["7-SEG Displays<br>(上下限/倒數/分數)"]:::output
    end

    %% ---------------- 接線邏輯 ----------------

    %% 輸入 -> 控制與運算
    I_Confirm -->|控制/確認| C_FSM
    I_Confirm -->|切換模式| M_Mode
    I_Switch -->|猜測值| A_Comp
    I_Switch -->|更新範圍| M_Min & M_Max

    %% 記憶 <-> 控制與運算
    M_Mode -- "Mode (00~11)" --> C_Level & O_LED & A_Timer
    C_FSM -- "Load_Min" --> M_Min
    C_FSM -- "Load_Max" --> M_Max
    M_Min -- "Min 值" --> O_7Seg
    M_Max -- "Max 值" --> O_7Seg

    %% 運算 <-> 控制
    C_FSM -- "New_Bomb" --> A_RNG
    A_RNG -- "Target (密碼)" --> A_Comp
    A_Comp -- "Gt/Lt/Eq" --> C_FSM

    C_FSM -- "Game_Run / add_time" --> A_Timer
    A_Timer -- "Time_Out" --> C_FSM
    A_Timer -- "秒數" --> O_7Seg

    %% 控制內部
    C_FSM -- "Next_Level" --> C_Level
    C_Level -- "Win_Flag" --> C_FSM

    %% 控制 -> 輸出
    C_FSM -- "State_Out" --> O_State
    C_Level -- "Progress" --> O_LED
    C_Level -- "Score_BCD" --> O_7Seg
```

### 如何使用這張圖放到簡報？
1. 複製上方 ```mermaid 到 ``` 之間的程式碼。
2. 開啟瀏覽器進入 [Mermaid Live Editor](https://mermaid.live/)。
3. 將程式碼貼在左側編輯區，右側就會立刻生成像簡報上那樣標準且分類清晰的方塊圖！
4. 點擊 `Actions` -> `Download PNG` 即可匯出高畫質圖片貼進 PPT。
