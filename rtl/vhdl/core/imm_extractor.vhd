----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/04/2026 02:05:30 PM
-- Design Name: 
-- Module Name: imm_extractor - Behavioral
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

entity imm_extractor is
    port (
        instr_i : in  word_t;   -- 32 bits instructions recieved from the Instruction Memory
        imm_o   : out word_t    -- immediate extracted outputed on 32 bits
    );
end imm_extractor;

architecture Behavioral of imm_extractor is

begin   
    process(instr_i)
    begin
        case instr_i(6 downto 0) is   -- opcode <= instr_i(6 downto 0);
            when OPCODE_OP_IMM | OPCODE_LOAD | 
                 OPCODE_JALR   | OPCODE_SYSTEM => -- I-type
                 imm_o <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 20);
                 
            when OPCODE_STORE =>                  -- S-type
                 imm_o <= (31 downto 12 => instr_i(31)) & instr_i(31 downto 25) & instr_i(11 downto 7);
                 
            when OPCODE_BRANCH =>                 -- B-type
                 imm_o <= (31 downto 12 => instr_i(31)) & instr_i(7) & instr_i(30 downto 25) & instr_i(11 downto 8) & '0';
                 
            when OPCODE_LUI | OPCODE_AUIPC =>     -- U-type
                 imm_o <= instr_i(31 downto 12) & (11 downto 0 => '0');
                 
            when OPCODE_JAL =>                    -- J-type
                 imm_o <= (31 downto 20 => instr_i(31)) & instr_i(20) & instr_i(30 downto 21) & instr_i(19 downto 12) & '0';
                 
            when others => -- R-type, no immediate
                 imm_o <= (31 downto 0 => '0');
        end case;
    end process;

end Behavioral;
