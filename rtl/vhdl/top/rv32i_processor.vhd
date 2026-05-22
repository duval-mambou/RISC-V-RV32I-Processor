----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Duval MAMBOU
-- 
-- Create Date: 05/13/2026 06:08:26 PM
-- Design Name: 
-- Module Name: rv32i_processor - Behavioral
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
use work.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rv32i_processor is
  Port ( 
        Clk, Reset_n        : in std_logic ;
        instr               : in word_t;
        read_data           : in word_t;
        pc                  : out word_t;
        address_data        : out word_t;
        mem_write, mem_read : out std_logic ;
        write_data          : out word_t 
        );
end rv32i_processor;

architecture Behavioral of rv32i_processor is

-- Signals for reset resynchronization 
signal SynRst_n, SynRst_n0 : std_logic;


----------------------------------------------------------------
------------- Pipeline registers signals -----------------------
----------------------------------------------------------------

signal if_id_reg_s  : if_id_reg_t;
signal id_ex_reg_s  : id_ex_reg_t;
signal ex_mem_reg_s : ex_mem_reg_t;
signal mem_wb_reg_s : mem_wb_reg_t;


----------------------------------------------------------------
------------- Fetch stage signals -----------------------------
----------------------------------------------------------------

-- Signal to enable or disable stall when an hazard is detected
signal stall_s       : std_logic ;
signal pc_next_sel_s : std_logic;

signal pc_s        : word_t;
signal pc_next_s   : word_t;
signal pc_plus_4_s : word_t;

----------------------------------------------------------------
------------- Decode stage signals -----------------------------
----------------------------------------------------------------
signal opcode_s : std_logic_vector(6 downto 0);
signal funct3_s : std_logic_vector(2 downto 0);
signal funct7_s : std_logic_vector(6 downto 0);

signal id_wb_sel_s      : std_logic_vector(1 downto 0);
signal id_mem_width_s   : std_logic_vector(1 downto 0);
signal id_branch_op_s   : std_logic_vector(2 downto 0);
signal id_alu_opcode_s  : std_logic_vector(3 downto 0);

signal id_rs1_s, id_rs2_s, id_rd_s : reg_t;
signal id_mem_write_s, id_mem_read_s, id_reg_write_s, id_branch_s, id_jump_s, id_alu_a_src_s, id_alu_b_src_s, id_mem_unsigned_s : std_logic;

signal write_data_s  : word_t;      -- got from write_back
signal id_data_rs1_s, id_data_rs2_s  : word_t;

signal id_imm_s : word_t;

----------------------------------------------------------------
------------- Execute stage signals ----------------------------
----------------------------------------------------------------
signal alu_a_in_s : word_t;
signal alu_b_in_s : word_t;
signal mux_1_alu_a_src_s : word_t;
signal mux_1_alu_b_src_s : word_t;

signal ex_alu_out_s : word_t;
signal ex_zero_s, ex_negative_s : std_logic;

signal branch_target_s : word_t;


----------------------------------------------------------------
------------- Memory stage signals -----------------------------
----------------------------------------------------------------
signal mem_read_data_s : word_t;

-- Forwarding Unit signals
signal fwd_a_s, fwd_b_s : std_logic_vector (1 downto 0);


begin

-- Reset synchronization
Reset : process(Reset_n, Clk)
begin
	if(Reset_n = '0') then
		SynRst_n0 <= '0';
		SynRst_n <= '0';
	elsif(rising_edge(Clk)) then
		SynRst_n0 <= '1';
		SynRst_n <= SynRst_n0;
	end if;
end process Reset;

--------------------------------------------------------------
------ STAGE FETCH -----------------------------------------
--------------------------------------------------------------

-- Program counter
U_PC : entity work.pc
    port map ( clk      => Clk,
                rst     => SynRst_n,
                stall   => stall_s,
                pc_next => pc_next_s,
                pc      => pc_s
                );
 
 pc <= pc_s;
 
 -- Theoritical next value of PC
 pc_plus_4_s <= std_logic_vector (unsigned (pc_s) + 4);
 
 -- PC Mux
 PC_Mux : process (pc_next_sel_s, pc_plus_4_s, branch_target_s)
 begin
    if pc_next_sel_s = '1' then
        pc_next_s <= branch_target_s;
    else 
        pc_next_s <= pc_plus_4_s;
    end if;
 end process;
 
IF_ID : process(Clk)
begin
    if SynRst_n = '0' then
        if_id_reg_s.instr       <= (others => '0');
        if_id_reg_s.pc          <= (others => '0');
        if_id_reg_s.pc_plus_4   <= (others => '0');
    else
        if rising_edge(Clk) then
            if pc_next_sel_s = '1' or stall_s = '1' then
                -- flush 
                if_id_reg_s.instr       <= (others => '0');
                if_id_reg_s.pc          <= (others => '0');
                if_id_reg_s.pc_plus_4   <= (others => '0');
            else
                if_id_reg_s.instr       <= instr;
                if_id_reg_s.pc          <= pc_s;
                if_id_reg_s.pc_plus_4   <= pc_plus_4_s;
            end if;
        end if;
    end if;
end process;


 
--------------------------------------------------------------
------ STAGE DECODE   -----------------------------------------
--------------------------------------------------------------
U_Decoder : entity work.decoder
    port map (  instr  => if_id_reg_s.instr,
                opcode => opcode_s,
                funct3 => funct3_s,
                funct7 => funct7_s,
                rs1    => id_rs1_s,
                rs2    => id_rs2_s,
                rd     => id_rd_s
            );
  
 U_RF : entity work.register_file 
    port map (  clk         => Clk,
                rst         => SynRst_n,
                rs1         => id_rs1_s, 
                rs2         => id_rs2_s, 
                rd          => id_rd_s, 
                reg_write   => id_reg_write_s,
                write_data  => write_data_s,
                data_rs1    => id_data_rs1_s, 
                data_rs2    => id_data_rs2_s
              );
   
 U_IE : entity work.imm_extractor 
    port map (  instr_i => if_id_reg_s.instr,
                imm_o   => id_imm_s
              );
              
 U_CU : entity work.control_unit
        port map (  opcode          => opcode_s,
                    funct3          => funct3_s,
                    funct7          => funct7_s,   
                    wb_sel          => id_wb_sel_s,
                    mem_width       => id_mem_width_s,
                    branch_op       => id_branch_op_s,
                    alu_opcode      => id_alu_opcode_s,
                    mem_write       => id_mem_write_s,
                    mem_read        => id_mem_read_s,
                    reg_write       => id_reg_write_s,
                    branch          => id_branch_s,
                    jump            => id_jump_s,
                    alu_a_src       => id_alu_a_src_s,
                    alu_b_src       => id_alu_b_src_s,
                    mem_unsigned    => id_mem_unsigned_s
                  );                                      

ID_EX : process(Clk)
begin
    if SynRst_n = '0' then
        id_ex_reg_s.pc         <= (others => '0');   
        id_ex_reg_s.pc_plus_4  <= (others => '0');
        id_ex_reg_s.data_rs1   <= (others => '0');   
        id_ex_reg_s.data_rs2   <= (others => '0');   
        id_ex_reg_s.imm        <= (others => '0');   
        id_ex_reg_s.rd         <= (others => '0');   
        id_ex_reg_s.rs1        <= (others => '0');   
        id_ex_reg_s.rs2        <= (others => '0');   
        id_ex_reg_s.alu_op     <= (others => '0');  
        id_ex_reg_s.alu_src_a  <= '0';   
        id_ex_reg_s.alu_src_b  <= '0';   
        id_ex_reg_s.reg_write  <= '0';   
        id_ex_reg_s.mem_write  <= '0';   
        id_ex_reg_s.mem_read   <= '0';   
        id_ex_reg_s.wb_sel     <= (others => '0');
    else
        if rising_edge(Clk) then
            if pc_next_sel_s = '1' or stall_s = '1' then
                -- flush
                 id_ex_reg_s.pc         <= (others => '0');   
                 id_ex_reg_s.pc_plus_4  <= (others => '0');
                 id_ex_reg_s.data_rs1   <= (others => '0');   
                 id_ex_reg_s.data_rs2   <= (others => '0');   
                 id_ex_reg_s.imm        <= (others => '0');   
                 id_ex_reg_s.rd         <= (others => '0');   
                 id_ex_reg_s.rs1        <= (others => '0');   
                 id_ex_reg_s.rs2        <= (others => '0');   
                 id_ex_reg_s.alu_op     <= (others => '0');  
                 id_ex_reg_s.alu_src_a  <= '0';   
                 id_ex_reg_s.alu_src_b  <= '0';   
                 id_ex_reg_s.reg_write  <= '0';   
                 id_ex_reg_s.mem_write  <= '0';   
                 id_ex_reg_s.mem_read   <= '0';   
                 id_ex_reg_s.wb_sel     <= (others => '0');
            else
                 id_ex_reg_s.pc         <= if_id_reg_s.pc;   
                 id_ex_reg_s.pc_plus_4  <= if_id_reg_s.pc_plus_4;
                 id_ex_reg_s.data_rs1   <= id_data_rs1_s;   
                 id_ex_reg_s.data_rs2   <= id_data_rs2_s;   
                 id_ex_reg_s.imm        <= id_imm_s;   
                 id_ex_reg_s.rd         <= id_rd_s;   
                 id_ex_reg_s.rs1        <= id_rs1_s;   
                 id_ex_reg_s.rs2        <= id_rs2_s;   
                 id_ex_reg_s.alu_op     <= id_alu_opcode_s;  
                 id_ex_reg_s.alu_src_a  <= id_alu_a_src_s;   
                 id_ex_reg_s.alu_src_b  <= id_alu_b_src_s;   
                 id_ex_reg_s.reg_write  <= id_reg_write_s;   
                 id_ex_reg_s.mem_write  <= id_mem_write_s;   
                 id_ex_reg_s.mem_read   <= id_mem_read_s;   
                 id_ex_reg_s.wb_sel     <= id_wb_sel_s; 
           end if;             
        end if;
    end if;
end process;


--------------------------------------------------------------
------ STAGE EXECUTE -----------------------------------------
--------------------------------------------------------------

-- Mux 1 ALU A input
process(fwd_a_s, id_ex_reg_s, mem_wb_reg_s, ex_mem_reg_s)
begin
    case fwd_a_s is
        when "00"   => mux_1_alu_a_src_s <= id_ex_reg_s.data_rs1;
        when "01"   => mux_1_alu_a_src_s <= mem_wb_reg_s.alu_out;
        when "10"   => mux_1_alu_a_src_s <= ex_mem_reg_s.alu_out;
        when others => mux_1_alu_a_src_s <= id_ex_reg_s.data_rs1;
    end case;
end process;

-- Mux 2 ALU A input
process(id_ex_reg_s, mux_1_alu_a_src_s)
begin
    if id_ex_reg_s.alu_src_a = '1' then
        alu_a_in_s <= id_ex_reg_s.pc;
    else
        alu_a_in_s <= mux_1_alu_a_src_s;
    end if;
end process;

-- Mux 1 ALU B input
process(fwd_b_s, id_ex_reg_s, mem_wb_reg_s, ex_mem_reg_s)
begin
    case fwd_b_s is
        when "00"   => mux_1_alu_b_src_s <= id_ex_reg_s.data_rs2;
        when "01"   => mux_1_alu_b_src_s <= mem_wb_reg_s.alu_out;
        when "10"   => mux_1_alu_b_src_s <= ex_mem_reg_s.alu_out;
        when others => mux_1_alu_b_src_s <= id_ex_reg_s.data_rs2;
    end case;
end process;

-- Mux 2 ALU B input
process(id_ex_reg_s, mux_1_alu_b_src_s)
begin
    if id_ex_reg_s.alu_src_b = '1' then
        alu_b_in_s <= id_ex_reg_s.imm;
    else
        alu_b_in_s <= mux_1_alu_b_src_s;
    end if;
end process;

U_ALU : entity work.alu
    port map (  A   => alu_a_in_s,
                B   => alu_b_in_s,
                alu_opcode  => id_ex_reg_s.alu_op,
                alu_out     => ex_alu_out_s,
                zero        => ex_zero_s,
                negative    => ex_negative_s
            );
            
 -- Branch adder
 branch_target_s <= std_logic_vector(unsigned (id_ex_reg_s.pc) + unsigned (id_ex_reg_s.imm) ); 

 -- Branch condition evaluation
process(id_ex_reg_s, ex_zero_s, ex_negative_s)
begin
    pc_next_sel_s <= '0';
    if id_ex_reg_s.branch = '1' then
        case id_ex_reg_s.branch_op is
            when "000" => pc_next_sel_s <= ex_zero_s;           -- BEQ
            when "001" => pc_next_sel_s <= not ex_zero_s;       -- BNE
            when "100" => pc_next_sel_s <= ex_negative_s;       -- BLT
            when "101" => pc_next_sel_s <= not ex_negative_s;   -- BGE
            when "110" => pc_next_sel_s <= ex_alu_out_s(0);     -- BLTU
            when "111" => pc_next_sel_s <= not ex_alu_out_s(0); -- BGEU
            when others => pc_next_sel_s <= '0';
        end case;
    elsif id_ex_reg_s.jump = '1' then
        pc_next_sel_s <= '1';                                   -- JAL, JALR
    end if;
end process;

EX_MEM : process(Clk)
begin
    if SynRst_n = '0' then
        ex_mem_reg_s.pc_plus_4  <= (others => '0');
        ex_mem_reg_s.alu_out    <= (others => '0');
        ex_mem_reg_s.data_rs2   <= (others => '0');
        ex_mem_reg_s.rd         <= (others => '0');
        ex_mem_reg_s.reg_write  <= '0';
        ex_mem_reg_s.mem_write  <= '0';
        ex_mem_reg_s.mem_read   <= '0';
        ex_mem_reg_s.wb_sel     <= (others => '0');
    else
        if rising_edge(Clk) then
            ex_mem_reg_s.pc_plus_4  <= id_ex_reg_s.pc_plus_4;
            ex_mem_reg_s.alu_out    <= ex_alu_out_s;
            ex_mem_reg_s.data_rs2   <= id_ex_reg_s.data_rs2;
            ex_mem_reg_s.rd         <= id_ex_reg_s.rd;
            ex_mem_reg_s.reg_write  <= id_ex_reg_s.reg_write;
            ex_mem_reg_s.mem_write  <= id_ex_reg_s.mem_write;
            ex_mem_reg_s.mem_read   <= id_ex_reg_s.mem_read;
            ex_mem_reg_s.wb_sel     <= id_ex_reg_s.wb_sel;
        end if;
    end if;
end process;


--------------------------------------------------------------
------ STAGE MEMORY ------------------------------------------
--------------------------------------------------------------

address_data    <= ex_mem_reg_s.alu_out;
mem_write       <= ex_mem_reg_s.mem_write;
mem_read        <= ex_mem_reg_s.mem_read;
write_data      <= ex_mem_reg_s.data_rs2;

mem_read_data_s   <= read_data;

MEM_WB : process(Clk)
begin
    if SynRst_n = '0' then
        mem_wb_reg_s.read_data  <= (others => '0');
        mem_wb_reg_s.pc_plus_4  <= (others => '0');
        mem_wb_reg_s.alu_out    <= (others => '0');
        mem_wb_reg_s.rd         <= (others => '0');
        mem_wb_reg_s.reg_write  <= '0';
        mem_wb_reg_s.mem_read   <= '0';
        mem_wb_reg_s.wb_sel     <= (others => '0');
    else
        if rising_edge(Clk) then
            mem_wb_reg_s.read_data  <= mem_read_data_s;
            mem_wb_reg_s.pc_plus_4  <= ex_mem_reg_s.pc_plus_4;
            mem_wb_reg_s.alu_out    <= ex_mem_reg_s.alu_out;
            mem_wb_reg_s.rd         <= ex_mem_reg_s.rd;
            mem_wb_reg_s.reg_write  <= ex_mem_reg_s.reg_write;
            mem_wb_reg_s.mem_read   <= ex_mem_reg_s.mem_read;
            mem_wb_reg_s.wb_sel     <= ex_mem_reg_s.wb_sel;
        end if;
    end if;
end process;

--------------------------------------------------------------
------ WRITE BACK STAGE --------------------------------------
--------------------------------------------------------------

--Write back mux selector
WB_MUX : process(mem_wb_reg_s)
begin
    case mem_wb_reg_s.wb_sel is 
        when "00" => write_data_s <= mem_wb_reg_s.alu_out;
        when "01" => write_data_s <= mem_wb_reg_s.read_data;
        when "10" => write_data_s <= mem_wb_reg_s.pc_plus_4;
        when others => write_data_s <= mem_wb_reg_s.alu_out;
    end case;
end process;


--------------------------------------------------------------
------ FORWARDING UNIT ---------------------------------------
--------------------------------------------------------------
U_FU : entity work.forwarding_unit
    port map (  ex_rs1          => id_ex_reg_s.rs1,
                ex_rs2          => id_ex_reg_s.rs2,
                mem_rd          => ex_mem_reg_s.rd,
                wb_rd           => mem_wb_reg_s.rd,
                mem_reg_write   => ex_mem_reg_s.reg_write,
                wb_reg_write    => mem_wb_reg_s.reg_write,
                fwd_A           => fwd_a_s,
                fwd_B           => fwd_b_s
            );
    
    
--------------------------------------------------------------
------ HAZARD DETECTION UNIT ---------------------------------
--------------------------------------------------------------
U_HAZARD : entity work.hazard_detection_unit
    port map (  id_rs1      => id_rs1_s,
                id_rs2      => id_rs2_s,
                ex_rd       => id_ex_reg_s.rd,
                ex_mem_read => id_ex_reg_s.mem_read,
                stall       => stall_s
              );


end Behavioral;
