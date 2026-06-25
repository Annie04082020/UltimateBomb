library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BIN_decoder is
    Port (
        EN    : in  STD_LOGIC;
        BIN   : in  STD_LOGIC_VECTOR(7 downto 0);
        Value : out STD_LOGIC_VECTOR(7 downto 0);
        Seg   : out STD_LOGIC_VECTOR(7 downto 0);  -- High 4-bits: Tens, Low 4-bits: Units
        Err   : out STD_LOGIC
    );
end BIN_decoder;

architecture Behavioral of BIN_decoder is
begin
    process(EN, BIN)
        variable bin_val   : integer range 0 to 255;
        variable tens_int  : integer range 0 to 31;
        variable units_int : integer range 0 to 15;
    begin
        bin_val := to_integer(unsigned(BIN));
        
        if bin_val > 99 then
            Err <= '1';
        else
            Err <= '0';
        end if;
        
        if EN = '0' then
            Value <= (others => '0');
            Seg   <= (others => '0');
        else
            Value <= BIN;
            
            tens_int  := bin_val / 10;
            units_int := bin_val mod 10;
            
            Seg <= std_logic_vector(to_unsigned(tens_int, 4)) & std_logic_vector(to_unsigned(units_int, 4));
        end if;
    end process;

end Behavioral;
