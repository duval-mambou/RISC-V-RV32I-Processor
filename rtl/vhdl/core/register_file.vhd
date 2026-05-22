----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/05/2026 10:54:05 AM
-- Design Name: 
-- Module Name: register_file - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.rv32i_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity register_file is
  Port (
        clk, rst            : std_logic;
        rs1, rs2, rd        : in reg_t;
        reg_write           : in std_logic ;
        write_data          : in word_t;
        data_rs1, data_rs2  : out word_t
      );
end register_file;

architecture Behavioral of register_file is
signal rf_data : reg_file_t;
begin
    process(rs1, rs2, rf_data)
    begin
        data_rs1 <= rf_data(to_integer(unsigned(rs1)));
        data_rs2 <= rf_data(to_integer(unsigned(rs2)));
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                rf_data <= (others => (others => '0'));
            elsif reg_write = '1' and rd /= "00000" then
                rf_data(to_integer(unsigned(rd))) <= write_data;
            end if;
        end if;
    end process;

end Behavioral;
