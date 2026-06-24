# 拆彈遊戲 狀態機圖 (State Diagram)

本圖為 `Ultimate_Bomb_controller` 的核心狀態機轉換圖。
您可以使用支援 Mermaid 的 Markdown 編輯器 (如 VSCode, Obsidian) 或貼到 [Mermaid Live Editor](https://mermaid.live/) 來預覽並匯出圖片。

```mermaid
graph TD
    %% 定義狀態節點
    idle(["待機 (IDLE)"])
    next_bomb(["產生新密碼 (NEXT_BOMB)"])
    game(["生死倒數 (GAME)"])
    check_pass(["檢查密碼 (CHECK_PASS)"])
    game_win(["遊戲勝利 (GAME_WIN)"])
    game_lose(["爆炸失敗 (GAME_LOSE)"])

    %% 進入點
    Start(( )) -->|開機或 Reset| idle

    %% 正常遊戲流程
    idle -->|"EN=1<br>(按下 Confirm 開始遊戲)"| next_bomb
    next_bomb -->|"EN=1<br>(按下 Confirm 進入倒數)"| game
    game -->|"EN=1<br>(玩家輸入並送出猜測)"| check_pass

    %% 密碼比對邏輯
    check_pass -->|"Pass_Gt=1 或 Pass_Lt=1<br>(猜錯，更新上下限繼續猜)"| game
    check_pass -->|"Pass_Match=1 且 Win_Flag=0<br>(猜中，但關卡還沒滿，繼續下一顆)"| next_bomb
    check_pass -->|"Pass_Match=1 且 Win_Flag=1<br>(猜中，且達成通關條件)"| game_win

    %% 時間超時邏輯 (涵蓋所有遊戲中狀態)
    game -->|Time_Out=1| game_lose
    next_bomb -->|Time_Out=1| game_lose
    check_pass -->|Time_Out=1| game_lose

    %% 結束狀態重置
    game_win -->|Reset=1| idle
    game_lose -->|Reset=1| idle
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
