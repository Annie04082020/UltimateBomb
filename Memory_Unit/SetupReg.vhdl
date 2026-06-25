library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_setup is
    Port ( 
        clk : in  STD_LOGIC;
        rst : in  STD_LOGIC;
        diff_in  : in  STD_LOGIC;                   
        mode_in  : in  STD_LOGIC_VECTOR(1 downto 0);                   
        en  : in  STD_LOGIC;                   
        mode_out  : out  STD_LOGIC_VECTOR(1 downto 0);                   
        diff_out  : out  STD_LOGIC                   
    );
end reg_setup;

architecture Behavioral of reg_setup is
signal tmp_diff: STD_LOGIC:= '0';
signal tmp_mode: STD_LOGIC_VECTOR(1 downto 0):= "00";
begin
    process(clk, rst)
    begin
        tmp_diff <= diff_in;
        tmp_mode <= mode_in;
        if rst = '1' then
            tmp_mode <= "00";
            tmp_diff <= '0';
        elsif rising_edge(clk) then
            if en = '1' then
                mode_out <= tmp_mode;
                diff_out <= tmp_diff;
            end if;
        end if;
    end process;
end Behavioral;
