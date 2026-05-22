----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/06/2026 06:48:44 PM
-- Design Name: 
-- Module Name: control_unit - Behavioral
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

entity control_unit is
    Port (
            funct3      : in std_logic_vector(2 downto 0);
            funct7      : in std_logic_vector(6 downto 0);
            opcode      : in std_logic_vector(6 downto 0); 
            wb_sel      : out std_logic_vector(1 downto 0);
            mem_width   : out std_logic_vector(1 downto 0);
            branch_op   : out std_logic_vector(2 downto 0);
            alu_opcode  : out std_logic_vector(3 downto 0);
            mem_write, mem_read, reg_write, branch, jump, alu_a_src, alu_b_src, mem_unsigned : out std_logic 
          );
end control_unit;

architecture Behavioral of control_unit is

begin
    process(opcode, funct3, funct7)
    begin
        -- Default values
        reg_write    <= '0';
        mem_read     <= '0';
        mem_write    <= '0';
        branch       <= '0';
        jump         <= '0';
        alu_a_src    <= '0';
        alu_b_src    <= '0';
        mem_unsigned <= '0';
        mem_width    <= "00";
        wb_sel       <= "00";
        branch_op    <= "000";
        alu_opcode   <= ALU_ADD;
    
        case opcode is
            when OPCODE_OP =>        -- ADD, SUB, AND...
                reg_write <= '1';
                case funct3 is
                    when FUNCT3_ADD =>
                        case funct7 is
                            when FUNCT7_NORMAL => alu_opcode <= ALU_ADD;
                            when FUNCT7_ALT    => alu_opcode <= ALU_SUB;
                            when others        => null;
                        end case;
                    when FUNCT3_AND  => alu_opcode <= ALU_AND;
                    when FUNCT3_OR   => alu_opcode <= ALU_OR;
                    when FUNCT3_XOR  => alu_opcode <= ALU_XOR;
                    when FUNCT3_SRL  => alu_opcode <= ALU_SRL;
                    when FUNCT3_SRA  => alu_opcode <= ALU_SRA;
                    when FUNCT3_SLT  => alu_opcode <= ALU_SLT;
                    when FUNCT3_SLL  => alu_opcode <= ALU_SLL;
                    when FUNCT3_SLTU => alu_opcode <= ALU_SLTU;
                    when others => null;
                end case;
    
            when OPCODE_OP_IMM =>    -- ADDI, ANDI...
                reg_write <= '1';
                alu_b_src <= '1';    -- immediate entrance in B
                case funct3 is
                    when FUNCT3_ADD   => alu_opcode <= ALU_ADD;
                    when FUNCT3_ANDI  => alu_opcode <= ALU_AND;
                    when FUNCT3_ORI   => alu_opcode <= ALU_OR;
                    when FUNCT3_XORI  => alu_opcode <= ALU_XOR;
                    when FUNCT3_SRLI  => alu_opcode <= ALU_SRL;
                    when FUNCT3_SRLI  =>   
                        case funct7 is
                            when FUNCT7_NORMAL => alu_opcode <= ALU_SRL;
                            when FUNCT7_ALT    => alu_opcode <= ALU_SRA;
                            when others        => null;
                        end case;
                    when FUNCT3_SLTI  => alu_opcode <= ALU_SLT;
                    when FUNCT3_SLLI  => alu_opcode <= ALU_SLL;
                    when FUNCT3_SLTIU => alu_opcode <= ALU_SLTU;
                    when others => null;
                end case;
    
            when OPCODE_LOAD =>
                reg_write <= '1';
                mem_read  <= '1';
                wb_sel    <= "01";
                alu_b_src <= '1';    -- immediate entrance in B
                alu_opcode <= ALU_ADD;
                case funct3 is
                    when FUNCT3_LB  => mem_width <= "00";
                    when FUNCT3_LH  => mem_width <= "01";
                    when FUNCT3_LW  => mem_width <= "10";
                    when FUNCT3_LBU => mem_width <= "00"; mem_unsigned <= '1';
                    when FUNCT3_LHU => mem_width <= "01"; mem_unsigned <= '1';
                    when others => null;
                end case;

            when OPCODE_STORE =>
                mem_write <= '1';
                alu_b_src <= '1';    -- immediate entrance in B
                alu_opcode <= ALU_ADD;
                case funct3 is
                    when FUNCT3_SB  => mem_width <= "00";
                    when FUNCT3_SH  => mem_width <= "01";
                    when FUNCT3_SW  => mem_width <= "10";
                    when others => null;
                end case;
                
             when OPCODE_BRANCH =>
                branch     <= '1';
                alu_opcode <= ALU_SLTU;
                case funct3 is
                    when FUNCT3_BEQ  => branch_op  <= "000";
                    when FUNCT3_BNE  => branch_op  <= "001";
                    when FUNCT3_BLT  => branch_op  <= "100";
                    when FUNCT3_BGE  => branch_op  <= "101";
                    when FUNCT3_BLTU => branch_op  <= "110";
                    when FUNCT3_BGEU => branch_op  <= "111";
                    when others => null;
                end case;
            
            when OPCODE_JAL =>
                jump      <= '1';
                reg_write <= '1';
                alu_a_src <= '1';   -- PC en entrée A
                alu_b_src <= '1';   -- immédiat en entrée B
                wb_sel    <= "10";  -- "PC+4" is written into rd 
            
            when OPCODE_JALR =>
                jump     <= '1';
                reg_write <= '1';
                wb_sel    <= "10";  -- "PC+4" is written into rd 
                
            when OPCODE_LUI =>
                reg_write  <= '1';
                alu_opcode <= ALU_PASS;  -- alu_out = immediate
                alu_b_src  <= '1';       -- immediate entrance in B
            
            when OPCODE_AUIPC =>
                reg_write  <= '1';
                alu_a_src  <= '1';   -- PC en entrée A
                alu_b_src  <= '1';   -- immédiat en entrée B
                alu_opcode <= ALU_ADD;
                
            when OPCODE_SYSTEM | OPCODE_FENCE =>  -- handled like NOPE
                null;   -- keep outputs at thier defaults values
    
            when others => null;
        end case;
    end process;

end Behavioral;
