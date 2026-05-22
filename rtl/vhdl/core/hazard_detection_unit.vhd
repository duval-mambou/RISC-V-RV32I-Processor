----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/13/2026 05:24:25 PM
-- Design Name: 
-- Module Name: hazard_detection_unit - Behavioral
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

entity hazard_detection_unit is
  Port ( 
        id_rs1, id_rs2  : in reg_t;
        ex_rd           : in reg_t;
        ex_mem_read     : in std_logic;
        stall           : out std_logic 
        );
end hazard_detection_unit;

architecture Behavioral of hazard_detection_unit is

begin    
    process (ex_mem_read, ex_rd, id_rs1, id_rs2)
    begin
        stall <= '0';

        if ex_mem_read = '1' then
            if ex_rd = id_rs1 or ex_rd = id_rs2 then
                stall <= '1';
            end if;
         end if;  
    end process;

end Behavioral;
