----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/04/2026 12:04:45 PM
-- Design Name: 
-- Module Name: rv32i_pkg - Behavioral
-- Project Name: RISC-V RV32I Processor
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package rv32i_pkg is
-- Opcodes 7 bits
    constant OPCODE_OP          : std_logic_vector(6 downto 0) := "0110011";
    constant OPCODE_OP_IMM      : std_logic_vector(6 downto 0) := "0010011";
    constant OPCODE_LOAD        : std_logic_vector(6 downto 0) := "0000011";
    constant OPCODE_STORE       : std_logic_vector(6 downto 0) := "0100011";
    constant OPCODE_BRANCH      : std_logic_vector(6 downto 0) := "1100011";
    constant OPCODE_JAL         : std_logic_vector(6 downto 0) := "1101111";
    constant OPCODE_JALR        : std_logic_vector(6 downto 0) := "1100111";
    constant OPCODE_LUI         : std_logic_vector(6 downto 0) := "0110111";
    constant OPCODE_AUIPC       : std_logic_vector(6 downto 0) := "0010111";
    constant OPCODE_SYSTEM      : std_logic_vector(6 downto 0) := "1110011";
    constant OPCODE_FENCE       : std_logic_vector(6 downto 0) := "0001111";
    
-- BRANCH funct3
    constant FUNCT3_BEQ   : std_logic_vector(2 downto 0) := "000"; 
    constant FUNCT3_BNE   : std_logic_vector(2 downto 0) := "001"; 
    constant FUNCT3_BLT   : std_logic_vector(2 downto 0) := "100"; 
    constant FUNCT3_BGE   : std_logic_vector(2 downto 0) := "101"; 
    constant FUNCT3_BLTU  : std_logic_vector(2 downto 0) := "110"; 
    constant FUNCT3_BGEU  : std_logic_vector(2 downto 0) := "111"; 
    
 -- JUMP AND LINK funct3
    constant FUNCT3_JALR    : std_logic_vector(2 downto 0) := "000";  
    
 -- LOAD funct3
    constant FUNCT3_LB      : std_logic_vector(2 downto 0) := "000"; 
    constant FUNCT3_LH      : std_logic_vector(2 downto 0) := "001"; 
    constant FUNCT3_LW      : std_logic_vector(2 downto 0) := "010"; 
    constant FUNCT3_LBU     : std_logic_vector(2 downto 0) := "100"; 
    constant FUNCT3_LHU     : std_logic_vector(2 downto 0) := "101"; 
    
 -- STORE funct3
    constant FUNCT3_SB      : std_logic_vector(2 downto 0) := "000"; 
    constant FUNCT3_SH      : std_logic_vector(2 downto 0) := "001"; 
    constant FUNCT3_SW      : std_logic_vector(2 downto 0) := "010"; 

-- OP funct3
    constant FUNCT3_ADD     : std_logic_vector(2 downto 0) := "000";   
    constant FUNCT3_SLL     : std_logic_vector(2 downto 0) := "001";  
    constant FUNCT3_SLT     : std_logic_vector(2 downto 0) := "010";  
    constant FUNCT3_SLTU    : std_logic_vector(2 downto 0) := "011";  
    constant FUNCT3_XOR     : std_logic_vector(2 downto 0) := "100";  
    constant FUNCT3_SRL     : std_logic_vector(2 downto 0) := "101";  
    constant FUNCT3_SRA     : std_logic_vector(2 downto 0) := "101";  
    constant FUNCT3_OR      : std_logic_vector(2 downto 0) := "110";  
    constant FUNCT3_AND     : std_logic_vector(2 downto 0) := "111";  
    
-- OP_IMM funct3
    constant FUNCT3_ADDI    : std_logic_vector(2 downto 0) := "000";
    constant FUNCT3_SLTI    : std_logic_vector(2 downto 0) := "010";
    constant FUNCT3_SLTIU   : std_logic_vector(2 downto 0) := "011";
    constant FUNCT3_XORI    : std_logic_vector(2 downto 0) := "100";
    constant FUNCT3_ORI     : std_logic_vector(2 downto 0) := "110";
    constant FUNCT3_ANDI    : std_logic_vector(2 downto 0) := "111";
    constant FUNCT3_SLLI    : std_logic_vector(2 downto 0) := "001";
    constant FUNCT3_SRLI    : std_logic_vector(2 downto 0) := "101";
    constant FUNCT3_SRAI    : std_logic_vector(2 downto 0) := "101";  
    
-- funct7
    constant FUNCT7_NORMAL : std_logic_vector(6 downto 0) := "0000000";
    constant FUNCT7_ALT    : std_logic_vector(6 downto 0) := "0100000"; 
    
-- ALU opcodes
    constant ALU_ADD  : std_logic_vector(3 downto 0) := "0000"; -- A + B
    constant ALU_SUB  : std_logic_vector(3 downto 0) := "0001"; -- A - B
    constant ALU_AND  : std_logic_vector(3 downto 0) := "0010"; -- A & B
    constant ALU_OR   : std_logic_vector(3 downto 0) := "0011"; -- A | B
    constant ALU_XOR  : std_logic_vector(3 downto 0) := "0100"; -- A ^ B
    constant ALU_SLL  : std_logic_vector(3 downto 0) := "0101"; -- A << B
    constant ALU_SRL  : std_logic_vector(3 downto 0) := "0110"; -- A >> B logical
    constant ALU_SRA  : std_logic_vector(3 downto 0) := "0111"; -- A >> B arithmetical
    constant ALU_SLT  : std_logic_vector(3 downto 0) := "1000"; -- A < B signed
    constant ALU_SLTU : std_logic_vector(3 downto 0) := "1001"; -- A < B unsigned
    constant ALU_PASS : std_logic_vector(3 downto 0) := "1010"; -- alu_out = B
    
-- 32 bites subtype
    subtype word_t  is std_logic_vector(31 downto 0);
    
-- number of a register in the registers file   
    subtype reg_t   is std_logic_vector(4  downto 0);

 -- the 32x32 register file type
    type reg_file_t is array(0 to 31) of word_t;
    
-- IF/ID Record
    type if_id_reg_t is record
        instr       : word_t;   -- the instruction fetched from intruction memory
        pc          : word_t;   -- current value of the program counter (PC)
        pc_plus_4   : word_t;   -- theoretical next instruction address
    end record;
    
 -- ID/EX Record
    type id_ex_reg_t is record
        pc          : word_t;   -- current value of the program counter (PC)
        pc_plus_4   : word_t;   -- theoretical next instruction address
        data_rs1    : word_t;   -- value of the data stroed in the register source 1 (rs1)
        data_rs2    : word_t;   -- value of the data stroed in the register source 2 (rs2)
        imm         : word_t;   -- value of the immediate extracted from the instruction
        rd          : reg_t;    -- register of destination number 
        rs1         : reg_t;    -- register source 1 number
        rs2         : reg_t;    -- register source 2 number
        alu_op      : std_logic_vector(3 downto 0);     -- ALU opcode
        alu_src_a   : std_logic;    -- mux selector for ALU A entrance source 
        alu_src_b   : std_logic;    -- mux selector for ALU B entrance source   
        reg_write   : std_logic;    -- control signal to enable or disable writing in rd
        mem_write   : std_logic;    -- control signal to enable or disable writing in Data memory
        mem_read    : std_logic;    -- control signal to enable or disable reading from Data memory
        wb_sel      : std_logic_vector(1 downto 0); -- mux selector for the Write-Back source
        mem_width   : std_logic_vector(1 downto 0);
        branch_op   : std_logic_vector(2 downto 0);
        branch      : std_logic;
        jump        : std_logic;
        mem_unsigned: std_logic;
     end record;
         
         
 -- EX/MEM Record
   type ex_mem_reg_t is record
        pc_plus_4   : word_t;       -- theoretical next instruction address
        alu_out     : word_t;       -- ALU result
        data_rs2    : word_t;       -- value of the data to store in the Data Memory
        rd          : reg_t;        -- register of destination number 
        reg_write   : std_logic;    -- control signal to enable or disable writing in rd
        mem_write   : std_logic;    -- control signal to enable or disable writing in Data memory
        mem_read    : std_logic;    -- control signal to enable or disable reading from Data memory
        wb_sel      : std_logic_vector(1 downto 0); -- mux selector for the Write-Back source
   end record;
   
  -- MEM/WB Record
    type mem_wb_reg_t is record
        read_data   : word_t;
        pc_plus_4   : word_t;       -- theoretical next instruction address
        alu_out     : word_t;       -- ALU result
        rd          : reg_t;        -- register of destination number 
        reg_write   : std_logic;    -- control signal to enable or disable writing in rd
        mem_read    : std_logic;    -- control signal to enable or disable reading from Data memory (for LOAD instructions)
        wb_sel      : std_logic_vector(1 downto 0); -- mux selector for the Write-Back source
   end record;
   
end package rv32i_pkg;



