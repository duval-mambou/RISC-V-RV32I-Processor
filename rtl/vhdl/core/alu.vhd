----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/13/2026 03:36:24 PM
-- Design Name: 
-- Module Name: alu - Behavioral
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

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv32i_pkg.all;

entity alu is
  Port (
        A, B            : in word_t;
        alu_opcode      : in std_logic_vector(3 downto 0);
        alu_out         : out word_t;
        zero, negative  : out std_logic  
        );
end alu;

architecture Behavioral of alu is
begin
    process(A, B, alu_opcode)
        variable result : signed(31 downto 0);
    begin
        result := (others => '0');
        
        case alu_opcode is
            when ALU_ADD  => result := signed(A) + signed(B);
            when ALU_SUB  => result := signed(A) - signed(B);
            when ALU_AND  => result := signed(A) and signed(B);
            when ALU_OR   => result := signed(A) or  signed(B);
            when ALU_XOR  => result := signed(A) xor signed(B);
            when ALU_SLL  => result := signed(shift_left (unsigned(A), to_integer(unsigned(B(4 downto 0)))));
            when ALU_SRL  => result := signed(shift_right(unsigned(A), to_integer(unsigned(B(4 downto 0)))));
            when ALU_SRA  => result := shift_right(signed(A), to_integer(unsigned(B(4 downto 0))));
            when ALU_SLT  =>
                if signed(A) < signed(B) then
                    result := to_signed(1, 32);
                else
                    result := to_signed(0, 32);
                end if;
            when ALU_SLTU =>
                if unsigned(A) < unsigned(B) then
                    result := to_signed(1, 32);
                else
                    result := to_signed(0, 32);
                end if;
            when ALU_PASS => result := signed(B);
            when others   => result := (others => '0');
        end case;
        
        alu_out  <= std_logic_vector(result);
        if result = 0 then 
            zero <= '1';
        else 
            zero <= '0';
        end if;
        negative <= result(31);
        
    end process;
end Behavioral;
