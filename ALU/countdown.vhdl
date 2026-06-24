LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY two_bit_counter is
    PORT (  clk     : in     STD_LOGIC;
            rst     : in     STD_LOGIC;
            add     : in     STD_LOGIC;
            en      : in     STD_LOGIC;  -- Game_Run
            Mode    : in     STD_LOGIC_VECTOR(1 downto 0);
            ten_out : out    STD_LOGIC_VECTOR (3 downto 0);
            one_out : out    STD_LOGIC_VECTOR (3 downto 0)
         );
END two_bit_counter;

ARCHITECTURE Behavioral of two_bit_counter is
    signal tens : unsigned(3 downto 0) := "1001";
    signal ones : unsigned(3 downto 0) := "1001";
    signal add_flag : std_logic := '0';
begin

    -- 捕捉來自高速時脈的 add 脈衝 (Pulse Catcher)
    process(clk, rst, add)
    begin
        if rst = '1' then
            add_flag <= '0';
        elsif add = '1' then
            add_flag <= '1';
        elsif rising_edge(clk) then
            add_flag <= '0';
        end if;
    end process;

    process(clk, rst)
        variable bonus_tens : unsigned(3 downto 0);
    begin
        if rst = '1' then
            tens <= "1001";
            ones <= "1001";
        elsif rising_edge(clk) then
            if add_flag = '1' then                
              if Mode = "00" then
                  bonus_tens := "0011"; -- 入門: +30秒
              elsif Mode = "10" then
                  bonus_tens := "0001"; -- 挑戰: +10秒
              else
                  bonus_tens := "0010"; -- 進階與無盡: +20秒
              end if;
              
              if (tens + bonus_tens) >= 9 then                  
                 tens <= "1001";
                 ones <= "1001";
              else
                 tens <= tens + bonus_tens;
              end if;
            elsif en = '1' then   -- 如果你目前全場只用一個 1Hz 時鐘，就直接這樣寫
                if tens = 0 and ones = 0 then
                    -- 已經是 00，保持不變
                    tens <= "0000";
                    ones <= "0000";
                elsif ones = 0 then
                    -- 個位數為 0，向十位數借位
                    ones <= "1001";
                    tens <= tens - 1;
                else
                    -- 正常個位數減 1
                    ones <= ones - 1;
                end if;
            end if;
        end if;
    end process;
    ten_out <= std_logic_vector(tens);
    one_out <= std_logic_vector(ones);

end Behavioral;
