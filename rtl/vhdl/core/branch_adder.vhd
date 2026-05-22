----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/13/2026 04:25:45 PM
-- Design Name: 
-- Module Name: branch_adder - Behavioral
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

entity branch_adder is
  Port ( 
        pc, imm       : in word_t;
        branch_target : out word_t
        );
end branch_adder;

architecture Behavioral of branch_adder is

begin
    branch_target <= std_logic_vector( unsigned (pc) + unsigned (imm) );
        
end Behavioral;
