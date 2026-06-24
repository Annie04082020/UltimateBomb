library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Level_Manager is
    Port (
        clk        : in  STD_LOGIC;
        rst        : in  STD_LOGIC;
        Mode       : in  STD_LOGIC_VECTOR(1 downto 0);
        Next_Level : in  STD_LOGIC; -- 來自 Controller 的破關脈衝
        
        Score_BCD  : out STD_LOGIC_VECTOR(7 downto 0);  -- 總破關數 (BCD 碼輸出，可以直接接兩顆七段顯示器)
        Win_Flag   : out STD_LOGIC;                   -- 告訴 Controller 破關了沒
        Progress   : out STD_LOGIC_VECTOR(3 downto 0) -- 給 LED 顯示進度
    );
end Level_Manager;

architecture Behavioral of Level_Manager is
    signal Finish_stages : integer range 0 to 15 := 3;
    signal Solved        : integer range 0 to 15 := 0;
    
    -- 用來計數總破關數的變數 (支援到 99 關)
    signal score_tens  : integer range 0 to 9 := 0;
    signal score_units : integer range 0 to 9 := 0;
begin
    
    Progress <= std_logic_vector(to_unsigned(Solved, 4));
    Score_BCD(7 downto 4) <= std_logic_vector(to_unsigned(score_tens, 4));
    Score_BCD(3 downto 0) <= std_logic_vector(to_unsigned(score_units, 4));

    -- Combinational Logic for Finish_stages and Win_Flag
    process(Mode, Solved, Finish_stages)
    begin
        -- 判斷目標關卡數
        if Mode = "00" then
            Finish_stages <= 3;
        elsif Mode = "01" then
            Finish_stages <= 6;
        else -- "10" or "11"
            Finish_stages <= 12;
        end if;
        
        -- 判斷是否達成通關條件 (如果再過一關就達到目標，且不是無盡模式)
        if Mode = "11" then
            Win_Flag <= '0'; -- 無盡模式永遠不觸發 Win_Flag
        elsif (Solved + 1) >= Finish_stages then
            Win_Flag <= '1';
        else
            Win_Flag <= '0';
        end if;
    end process;

    -- Sequential Logic for counting Solved stages
    process(clk, rst)
    begin
        if rst = '1' then
            Solved <= 0;
            score_tens <= 0;
            score_units <= 0;
        elsif rising_edge(clk) then
            if Next_Level = '1' then
                
                -- 更新總分 (Score)
                if score_units = 9 then
                    score_units <= 0;
                    if score_tens /= 9 then
                        score_tens <= score_tens + 1;
                    end if;
                else
                    score_units <= score_units + 1;
                end if;
                if Mode = "11" then
                    -- 無盡模式：不更動關卡進度條 (LED 不動)
                    Solved <= 0;
                elsif Solved < Finish_stages then
                    -- 普通模式：還沒滿就繼續加
                    Solved <= Solved + 1;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
