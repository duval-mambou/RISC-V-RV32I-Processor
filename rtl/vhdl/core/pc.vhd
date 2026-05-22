----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/13/2026 05:48:14 PM
-- Design Name: 
-- Module Name: pc - Behavioral
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

entity pc is
  Port ( 
        clk, rst : in std_logic;
        stall    : in std_logic;
        pc_next  : in word_t;
        pc       : out word_t
        );
end pc;

architecture Behavioral of pc is

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc <= (others => '0');
            elsif stall = '0' then
                pc <= pc_next;
            end if;
        end if;
    end process;

end Behavioral;
