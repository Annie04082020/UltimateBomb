library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Password_Comparator is
    Port (
        EnterWord : in  STD_LOGIC_VECTOR(7 downto 0);
        Password  : in  STD_LOGIC_VECTOR(7 downto 0);
        Invalid   : in  STD_LOGIC;  -- 密碼是否無效
        Pass_Gt   : out STD_LOGIC;  -- EnterWord > Password
        Pass_Match: out STD_LOGIC;  -- EnterWord = Password
        Pass_Lt   : out STD_LOGIC   -- EnterWord < Password
    );
end Password_Comparator;

architecture Behavioral of Password_Comparator is
begin
    process(EnterWord, Password, Invalid)
        variable val_A : integer;
        variable val_B : integer;
    begin
        val_A := to_integer(unsigned(EnterWord));
        val_B := to_integer(unsigned(Password));
        
        -- 預設歸零
        Pass_Gt <= '0';
        Pass_Match <= '0';
        Pass_Lt <= '0';
        
        if Invalid = '0' then
            if val_A > val_B then
                Pass_Gt <= '1';
            elsif val_A < val_B then
                Pass_Lt <= '1';
            else
                Pass_Match <= '1';
            end if;
        end if;
    end process;
end Behavioral;
