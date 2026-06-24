# 拆彈遊戲 狀態機圖 (State Diagram)

本圖為 `Ultimate_Bomb_controller` 的核心狀態機轉換圖。
您可以使用支援 Mermaid 的 Markdown 編輯器 (如 VSCode, Obsidian) 或貼到 [Mermaid Live Editor](https://mermaid.live/) 來預覽並匯出圖片。

```mermaid
stateDiagram-v2
    %% 定義狀態節點
    state "待機 (IDLE)" as idle
    state "產生新密碼 (NEXT_BOMB)" as next_bomb
    state "生死倒數 (GAME)" as game
    state "檢查密碼 (CHECK_PASS)" as check_pass
    state "遊戲勝利 (GAME_WIN)" as game_win
    state "爆炸失敗 (GAME_LOSE)" as game_lose

    %% 進入點
    [*] --> idle : 開機或 Reset

    %% 正常遊戲流程
    idle --> next_bomb : EN=1 (按下 Confirm 開始遊戲)
    next_bomb --> game : EN=1 (按下 Confirm 進入倒數)
    game --> check_pass : EN=1 (玩家輸入並送出猜測)

    %% 密碼比對邏輯
    check_pass --> game : Pass_Gt=1 或 Pass_Lt=1 \n (猜錯，更新上下限繼續猜)
    check_pass --> next_bomb : Pass_Match=1 且 Win_Flag=0 \n (猜中，但關卡還沒滿，繼續下一顆)
    check_pass --> game_win : Pass_Match=1 且 Win_Flag=1 \n (猜中，且達成通關條件)

    %% 時間超時邏輯 (涵蓋所有遊戲中狀態)
    game --> game_lose : Time_Out=1
    next_bomb --> game_lose : Time_Out=1
    check_pass --> game_lose : Time_Out=1

    %% 結束狀態重置
    game_win --> idle : Reset=1
    game_lose --> idle : Reset=1
```

### 狀態動作說明：
* **`IDLE`**：清除所有狀態 (`WIN`, `LOSE`, `Game_Run` = 0)，等待玩家選擇難度。
* **`NEXT_BOMB`**：發送 `New_Bomb` 脈衝，觸發 RNG 產生新目標密碼，並將 Min/Max 重置為 00 與 99。
* **`GAME`**：發送 `Game_Run` = 1，啟動外部的 1Hz 倒數計時器。
* **`CHECK_PASS`**：
  * 若大於/小於目標，發送 `Load_Max` 或 `Load_Min` 給暫存器。
  * 若等於目標，發送 `add_time` (加秒數) 與 `Next_Level` (關卡進度+1)。
* **`GAME_WIN`**：輸出 `WIN=1`，關閉計時器。
* **`GAME_LOSE`**：輸出 `LOSE=1`，關閉計時器。
