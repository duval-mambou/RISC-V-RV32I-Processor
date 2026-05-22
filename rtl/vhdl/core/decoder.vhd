----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/13/2026 03:28:55 PM
-- Design Name: 
-- Module Name: decoder - Behavioral
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

entity decoder is
  Port ( 
        instr        : in word_t;
        opcode       : out std_logic_vector(6 downto 0);
        funct3       : out std_logic_vector(2 downto 0);
        funct7       : out std_logic_vector(6 downto 0);
        rs1, rs2, rd : out reg_t
        );
end decoder;

architecture Behavioral of decoder is

begin
    opcode <= instr(6 downto 0);
    funct3 <= instr(14 downto 12);
    funct7 <= instr(31 downto 25);
    rs1    <= instr(19 downto 15);
    rs2    <= instr(24 downto 20);
    rd     <= instr(11 downto 7);
  
end Behavioral;
