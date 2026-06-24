library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Time_Out_Checker is
    Port (
        ones     : in  STD_LOGIC_VECTOR(3 downto 0);
        tens     : in  STD_LOGIC_VECTOR(3 downto 0);
        Time_Out : out STD_LOGIC
    );
end Time_Out_Checker;

architecture Behavioral of Time_Out_Checker is
begin
    -- 當十位數和個位數都為 0 時，輸出 Time_Out = '1'
    process(tens, ones)
    begin
        if tens = "0000" and ones = "0000" then
            Time_Out <= '1';
        else
            Time_Out <= '0';
        end if;
    end process;
end Behavioral;
