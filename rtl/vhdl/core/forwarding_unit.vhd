----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/13/2026 04:33:06 PM
-- Design Name: 
-- Module Name: forwarding_unit - Behavioral
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

entity forwarding_unit is
  Port ( 
        ex_rs1, ex_rs2  : in reg_t;
        mem_rd          : in reg_t;
        wb_rd           : in reg_t;
        mem_reg_write   : in std_logic; 
        wb_reg_write    : in std_logic;
        fwd_A, fwd_B    : out std_logic_vector (1 downto 0)
        );
end forwarding_unit;

architecture Behavioral of forwarding_unit is

begin        
        process(ex_rs1, ex_rs2, mem_rd, wb_rd, mem_reg_write, wb_reg_write)
        begin            
            -- Forwarding A
            if mem_reg_write = '1' and mem_rd /= "00000" and mem_rd = ex_rs1 then
                fwd_A <= "10";  
            elsif wb_reg_write = '1' and wb_rd /= "00000" and wb_rd = ex_rs1 then
                fwd_A <= "01";  
            else
                fwd_A <= "00";
            end if;
            
            -- Forwarding B
            if mem_reg_write = '1' and mem_rd /= "00000" and mem_rd = ex_rs2 then
                fwd_B <= "10";
            elsif wb_reg_write = '1' and wb_rd /= "00000" and wb_rd = ex_rs2 then
                fwd_B <= "01";
            else
                fwd_B <= "00";
            end if; 
        end process;

end Behavioral;
