----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy, Sylvain Ieri
-- 
-- Module Name: ControlUnit - Behavioral
-- Course Name: Lab Digital Design
--
-- Description: 
--  LDD processor Control Unit
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library work;
use work.processor_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ControlUnit is
    generic(
        C_DATA_WIDTH : natural := 8
    );
    port(
             clk : in  std_logic;
           reset : in  std_logic;
             irq : in  std_logic;
          ir_msb : in  std_logic_vector(C_DATA_WIDTH-1 downto 0); --
           flags : in  std_logic_vector(4 downto 0);
           ready : in  std_logic;
        controls : out std_logic_vector(31 downto 0);
           error : out std_logic
    );
end ControlUnit;

architecture Behavioral of ControlUnit is
    -- these should match the constants defined in Processor
    constant C_NR_FLAGS : natural := 5;
    constant C_ZF : natural := 4;
    constant C_CF : natural := 3;
    constant C_EF : natural := 2;
    constant C_GF : natural := 1;
    constant C_SF : natural := 0;
    constant C_CTRL_MEM_ADDR_WIDTH : natural := 6;
    constant C_CTRL_MEM_DATA_WIDTH : natural := 32;
    --microcode addresses
    constant C_FC_ADDR   : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "000000"; -- 0    | fetch sequence 
    constant C_IC_ADDR   : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "111000"; -- 56   | interrupt treatment sequence
    constant C_ARC_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "010010"; -- 18   | alu result sequence
    constant C_AXC_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "001111"; -- 15   | alu x load sequence
    constant C_EC1_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "000110"; -- 06   | EC1 sequence
    constant C_EC2_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "000111"; -- 07   | EC2 sequence
    constant C_EC3_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "001000"; -- 08   | EC3 sequence
    constant C_EC4_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "001011"; -- 11   | EC4 sequence
    constant C_EC5_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "001111"; -- 15   | EC5 sequence
    constant C_EC6_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "010000"; -- 16   | EC6 sequence
    constant C_EC7_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "010001"; -- 17   | EC7 sequence
    constant C_EC8_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "010011"; -- 19   | EC8 sequence
    constant C_EC9_ADDR  : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "010101"; -- 21   | EC9 sequence
    constant C_EC10_ADDR : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "010111"; -- 23   | EC10 sequence
    constant C_EC11_ADDR : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "011000"; -- 24   | EC11 sequence
    constant C_EC12_ADDR : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "011100"; -- 28   | EC12 sequence
    constant C_EC13_ADDR : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "100000"; -- 32   | EC13 sequence
    constant C_EC14_ADDR : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "100100"; -- 36   | EC14 sequence
    constant C_EC15_ADDR : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "101000"; -- 40   | EC15 sequence
    constant C_EC16_ADDR : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "101011"; -- 43   | EC16 sequence
    constant C_NOP       : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := "101111"; -- 47   | EC16 sequence

    
    constant C_OPCODE_JUMP : std_logic_vector((8-1) downto 0) := "01000000";
    
    constant C_INCR_SP : std_logic_vector((8-1) downto 0) := "00000001";
    constant C_DECR_SP : std_logic_vector((8-1) downto 0) := "00000010"; 
    
    constant C_INCR_PC : std_logic_vector((8-1) downto 0) := "00100000";
    constant C_WRITE_EN : std_logic_vector((8-1) downto 0) := "00000001";
    constant C_READ_EN : std_logic_vector((8-1) downto 0) := "00000010";
    constant C_DATA_IN_LE : std_logic_vector((8-1) downto 0) := "00000100";
    constant C_I_REG_LE : std_logic_vector((8-1) downto 0) := "00001000";
    constant C_ALU_STORE : std_logic_vector((8-1) downto 0) := "00010000";
    constant C_REGSWAP : std_logic_vector((8-1) downto 0) := "01000000";


    signal ctrl_mem_data_i : std_logic_vector((C_CTRL_MEM_DATA_WIDTH-1) downto 0) := (others=>'0');
    signal ctrl_mem_addr_i : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := (others=>'0');

    signal flags_i : std_logic_vector((C_NR_FLAGS-1) downto 0) := (others=>'0');
    signal opcode_i : std_logic_vector(4 downto 0) := (others=>'0');
    signal operand_1_i : std_logic_vector(2 downto 0) := (others=>'0');
    signal flag_jump_i : std_logic := '0';
    signal jump_control_i : std_logic := '0';
    signal pc_le_unmasked_i : std_logic := '0';
    signal pc_le_jump_i : std_logic := '0';
    
    signal no_branch_i : std_logic := '0';
    signal next_opcode_addr_i : std_logic_vector((C_CTRL_MEM_ADDR_WIDTH-1) downto 0) := (others=>'0');
    signal next_micro_addr_i : std_logic_vector(5 downto 0) := (others => '0'); 
    
    signal hold_microcode_i : std_logic;
   
    -- control outputs
    signal alu_op_i : std_logic_vector(3 downto 0) := (others=>'0');
    signal cpu_bus_sel_i : std_logic_vector(3 downto 0) := (others=>'0');
    signal flags_le_i : std_logic := '0';
    signal pc_le_i : std_logic := '0';
    signal inc_pc_i : std_logic := '0';
    signal y_le_i : std_logic := '0';
    signal z_le_i : std_logic := '0';
    signal mar_le_i : std_logic := '0';
    signal ir_h_le_i : std_logic := '0';
    signal ir_l_le_i : std_logic := '0';
    signal dbri_le_i : std_logic := '0';
    signal dbro_le_i : std_logic := '0';
    signal reg_file_le_i : std_logic := '0';
    signal system_bus_write_enable_i : std_logic := '0';
    signal system_bus_read_enable_i : std_logic := '0';
    signal sp_up_i : std_logic := '0';
    signal sp_down_i : std_logic := '0'; 
    
    -- interrupt handling
    signal start_ic_i : std_logic := '0';
    signal end_ic_i : std_logic := '0';
    signal interrupt_cycle_i : std_logic := '0';
    signal handle_irq_i : std_logic := '0';
    signal irq_handled_i : std_logic := '0';
    signal pc_le_irq_i : std_logic := '0';
       
    -- error signals
    signal sequencing_error_i : std_logic := '0';
    
    -- Build a 2-D array type for the ROM
    subtype word_t is std_logic_vector((C_CTRL_MEM_DATA_WIDTH-1) downto 0);
    type memory_t is array(2**C_CTRL_MEM_ADDR_WIDTH-1 downto 0) of word_t;

    -- micro code fields
    -- byte 3
    alias cpu_bus_source_i : std_logic_vector(3 downto 0) is ctrl_mem_data_i(27 downto 24);
    alias cpu_bus_dest_i : std_logic_vector(3 downto 0) is ctrl_mem_data_i(31 downto 28);
    -- byte 2
    alias source_destination_swap_i : std_logic is ctrl_mem_data_i(22);
    alias increment_pc_i : std_logic is ctrl_mem_data_i(21);
    alias alu_out_le_i : std_logic is ctrl_mem_data_i(20);
    alias cpu_reg_le_i : std_logic is ctrl_mem_data_i(19);
    alias dbr_in_le_i : std_logic is ctrl_mem_data_i(18);
    alias bus_read_enable_i : std_logic is ctrl_mem_data_i(17);
    alias bus_write_enable_i : std_logic is ctrl_mem_data_i(16);
    -- byte 1
    alias dec_sp_i : std_logic is ctrl_mem_data_i(9);
    alias inc_sp_i : std_logic is ctrl_mem_data_i(8);
    -- byte 0
    alias branch_microcode_i : std_logic is ctrl_mem_data_i(7);
    alias branch_opcode_i : std_logic is ctrl_mem_data_i(6);
    alias microcode_addr_i : std_logic_vector(5 downto 0) is ctrl_mem_data_i(5 downto 0);
    


	-- Initialize all memory locations with the desired data
	signal ctrl_memory_i : memory_t := (
         -- Byte 0 bits (0 to 7) = microcode address sequencing:
         --  0 - 5: next microprogram address
         --    6  : branch based on opcode
         --    7  : branch based on microcode
         -- Byte 1 bits (8 to 15) = stack pointer + irq handling:
         --    8  : increment stack pointer
         --    9  : decrement stack pointer
         --  10-15: RFU
         -- Byte 2 bits (16 to 23) = read write enables
         --   16  : system bus write enable
         --   17  : system bus read enable
         --   18  : data buffer in load enable (from bus to DBR)
         --   19  : internal register load enable
         --   20  : alu outputs load enable (both flags and result)
         --   21  : increment PC
         --   22  : source destination swap
         --   23  : RFU
         -- Byte 3 bits (24 to 31) = CPU bus source and destination:
         --  24-27: bus source
         --  28-31: bus destination 
         -- FETCH CYCLE (FC)
		  0 => SFR_MAR  & SFR_PC   & (C_INCR_PC OR C_I_REG_LE)              & "00000000" & "00000000", -- PC -> MAR, PC + 1
          1 => SFR_MAR  & SFR_PC   & (C_INCR_PC OR C_I_REG_LE OR C_READ_EN) & "00000000" & "00000000", -- PC -> MAR, PC + 1, read_en
          2 => "00000000"          & (C_DATA_IN_LE OR C_READ_EN)            & "00000000" & "00000000", -- data_bus -> DIBR, read_en
          3 => SFR_IR_H & SFR_DBR  & (C_DATA_IN_LE OR C_I_REG_LE)           & "00000000" & "00000000", -- data_bus -> DIBR, DIBR -> IR (msb) (opcode contained here)
          4 => SFR_IR_L & SFR_DBR  & (C_I_REG_LE)                           & "00000000" & C_OPCODE_JUMP, -- DIBR -> IR (lsb) Jump to opcode EC on next cycle
          
          5 => "00000000"          & "00000000"                             & "00000000" & "00000000", 
          
         -- EXECUTE CYCLE (EC)
         -- EC1 - MOVL (IR(lsb) -> Rd)
          6 => GP_REG   & SFR_IR_L & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- IR (lsb) -> regfile, micro branch to IC
          
         -- EC2 - MOVR (Rs -> Rd)
          7 => GP_REG   & GP_REG   & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- regfile -> regfile, micro branch to IC
          
         -- EC3 - STR (Rs -> memory/io)
          8 => SFR_MAR  & SFR_IR_L & (C_I_REG_LE)                           & "00000000" & "00000000", -- IR (lsb) -> MAR
          9 => SFR_DBR  & GP_REG   & (C_I_REG_LE OR C_REGSWAP)              & "00000000" & "00000000", -- regfile -> DOBR, regswap
         10 => "00000000"          & (C_WRITE_EN)                           & "00000000" & "10" & C_IC_ADDR, -- write_en, micro branch to IC
         
         -- EC4 - LDR (memory/io -> Rd)
         11 => SFR_MAR  & SFR_IR_L & (C_I_REG_LE)                           & "00000000" & "00000000", -- IR (lsb) -> MAR
         12 => "00000000"          & (C_READ_EN)                            & "00000000" & "00000000", -- read_en
         13 => "00000000"          & (C_DATA_IN_LE)                         & "00000000" & "00000000", -- data_bus -> DIBR
         14 => GP_REG   & SFR_DBR  & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- DIBR -> regfile, micro branch to IC
                  

         -- EC5 - NOT, SWAP, RR, RL (Rd -> alu -> Rd)
         15 => "0000"   & GP_REG   & (C_ALU_STORE OR C_REGSWAP)             & "00000000" & "10" & C_ARC_ADDR, -- regfile -> alu_x (=cpu bus) => regswap!!, store alu results, jump to storing results
         
         -- EC6 - ANDL, ORL, XORL, ADDL (Rd & IR(lsb) -> alu -> Rd)
         16 => SFR_Y    & SFR_IR_L & (C_I_REG_LE)                           & "00000000" & "10" & C_AXC_ADDR, -- IR (lsb) -> Y, jump to loading x
             
         -- EC7 - ANDR, ORR, XORR, ADDR (Rd & Rs -> alu -> Rd)
         17 => SFR_Y    & GP_REG   & (C_I_REG_LE)                           & "00000000" & "10" & C_AXC_ADDR, -- regfile -> Y, junp to loading x
                      
         -- alu factorisation        
         18 => GP_REG   & SFR_Z    & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- z -> regfile, micro branch to IC
          
         -- EC8 - CMPL (Rd & IR(lsb) -> alu) (only flags updated)
         19 => SFR_Y    & SFR_IR_L & (C_I_REG_LE)                           & "00000000" & "00000000", -- IR (lsb) -> Y
         20 => "0000"   & GP_REG   & (C_ALU_STORE OR C_REGSWAP)             & "00000000" & "10" & C_IC_ADDR, -- regfile -> alu_x (=cpu bus) => regswap!!, store alu results, micro branch to IC
         
         -- EC9 - CMR (Rd & Rs -> alu) (only flags updated)
         21 => SFR_Y    & GP_REG   & (C_I_REG_LE)                           & "00000000" & "00000000", -- regfile -> Y
         22 => "0000"   & GP_REG   & (C_ALU_STORE OR C_REGSWAP)             & "00000000" & "10" & C_IC_ADDR, -- regfile -> alu_x (=cpu bus) => regswap!!, store alu results,  micro branch to IC
         
         -- EC10 - JMP (IR(lsb) -> PC)
         23 => SFR_PC   & SFR_IR_L & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- IR (lsb) -> PC, branch to addr IC
         
         -- EC11 - RETI, RETC (stack -> PC)
		 24 => SFR_MAR  & SFR_SP   & (C_I_REG_LE)                           & "00000000" & "00000000", -- SP -> MAR
		 25 => "00000000"          & (C_READ_EN)                            & C_DECR_SP  & "00000000", -- read_en, SP - 1
         26 => "00000000"          & (C_DATA_IN_LE)                         & "00000000" & "00000000", -- data_bus -> DIBR
		 27 => SFR_PC   & SFR_DBR  & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- DIBR -> PC, micro branch to IC
		 
		 -- EC12 - PUSH (Rs -> stack)
         28 => "00000000"          & "00000000"                             & C_INCR_SP  & "00000000", -- SP + 1
         29 => SFR_MAR  & SFR_SP   & (C_I_REG_LE)                           & "00000000" & "00000000", -- SP -> MAR
		 30 => SFR_DBR  & GP_REG   & (C_I_REG_LE OR C_REGSWAP)              & "00000000" & "00000000", -- regfile -> DOBR, regswap
		 31 => "00000000"          & (C_WRITE_EN)                           & "00000000" & "10" & C_IC_ADDR, -- write_en, micro branch to IC
		 
		 -- EC13 - POP (stack -> Rd)
		 32 => SFR_MAR  & SFR_SP   & (C_I_REG_LE)                           & "00000000" & "00000000", -- SP -> MAR
         33 => "00000000"          & (C_READ_EN)                            & C_DECR_SP  & "00000000", -- read_en, SP - 1
		 34 => "00000000"          & (C_DATA_IN_LE)                         & "00000000" & "00000000", -- data_bus -> DIBR
		 35 => GP_REG   & SFR_DBR  & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- DIBR -> regfile, micro branch to IC
		 
		 -- EC14 - CALL (PC-> stack, IR(lsb) -> PC)
		 36 => "00000000"          & "00000000"                             & C_INCR_SP  & "00000000", -- SP + 1
         37 => SFR_MAR  & SFR_SP   & (C_I_REG_LE)                           & "00000000" & "00000000", -- SP -> MAR
         38 => SFR_DBR  & SFR_PC   & (C_I_REG_LE)                           & "00000000" & "00000000", -- PC -> DOBR
         39 => SFR_PC   & SFR_IR_L & (C_I_REG_LE OR C_WRITE_EN)             & "00000000" & "10" & C_IC_ADDR, -- write_enable, IR(lsb) -> PC, micro branch to FC
         
         -- EC15 STRR
         40 => SFR_MAR  & GP_REG   & (C_I_REG_LE OR C_REGSWAP  )            & "00000000" & "00000000", -- regfile -> MAR
         41 => SFR_DBR  & GP_REG   & (C_I_REG_LE)                           & "00000000" & "00000000", -- regfile -> DOBR, regswap
         42 => "00000000"          & (C_WRITE_EN)                           & "00000000" & "10" & C_IC_ADDR, -- write_en, micro branch to IC
		 
		 -- EC16 LDRR
		 43 => SFR_MAR  & GP_REG   & (C_I_REG_LE)                           & "00000000" & "00000000", -- regfile -> MAR
         44 => "00000000"          & (C_READ_EN)                            & "00000000" & "00000000", -- read_en
         45 => "00000000"          & (C_DATA_IN_LE)                         & "00000000" & "00000000", -- data_bus -> DIBR
         46 => GP_REG   & SFR_DBR  & (C_I_REG_LE)                           & "00000000" & "10" & C_IC_ADDR, -- DIBR -> regfile, micro branch to IC
         
         --NOP
         47 => "00000000"          & "00000000"                             & "00000000" & "10" & C_IC_ADDR, -- micro branch to IC, can't be done directly at operand decode as it would bypass interupt managment circuit
		 
		 48 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 49 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 50 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 51 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 52 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 53 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 54 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 55 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 
		 -- INTERRUPT CYCLE (IC) (PC-> stack, IV -> PC)
         56 => "00000000"          & "00000000"                             & C_INCR_SP  & "00000000", -- SP + 1
         57 => SFR_MAR  & SFR_SP   & (C_I_REG_LE)                           & "00000000" & "00000000", -- SP -> MAR
         58 => SFR_DBR  & SFR_PC   & (C_I_REG_LE)                           & "00000000" & "00000000", -- PC -> DOBR
         59 => SFR_PC   & SFR_IV   & (C_I_REG_LE OR C_WRITE_EN)             & "00000000" & "10" & C_FC_ADDR, -- write_enable, IV -> PC, micro branch to FC
		 
		 -- RFU
		 60 => "00000000"          & "00000000"                             & "00000000" & "00000000",
         61 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 62 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 63 => "00000000"          & "00000000"                             & "00000000" & "00000000",
		 
		 others => "00000000000000000000000000000000"
	);

    component Interrupt_Control is
    port(
               clk : in  std_logic;
             reset : in  std_logic;
          start_ic : in  std_logic;
            end_ic : in  std_logic;
               irq : in  std_logic;
        handle_irq : out std_logic;
         int_cycle : out std_logic
    );
    end component;

begin
    -- retrieve microprogram instruction
    ctrl_mem_data_i <= ctrl_memory_i(conv_integer(ctrl_mem_addr_i));
    
    -- derived
    no_branch_i <= branch_opcode_i nor branch_microcode_i;
    
    flags_i <= flags;
    opcode_i <= ir_msb(15-8 downto 11-8);
    operand_1_i <= ir_msb(10-8 downto 8-8);

    -- next_opcode_addr_i -- set by address decoder
    with opcode_i select
    next_opcode_addr_i <= C_EC1_ADDR  when OPCODE_MOVL, -- MOVL -> EC1                 
                          C_EC2_ADDR  when OPCODE_MOVR, -- MOVR -> EC2 
                          C_EC3_ADDR  when OPCODE_STR,  -- STR  -> EC3 
                          C_EC4_ADDR  when OPCODE_LDR,  -- LDR  -> EC4 
                          C_EC5_ADDR  when OPCODE_NOT,  -- NOT  -> EC5 
                          C_EC5_ADDR  when OPCODE_SR,   -- SR   -> EC5 
                          C_EC5_ADDR  when OPCODE_SL,   -- SL   -> EC5 
                          C_EC5_ADDR  when OPCODE_SWAP, -- SWAP -> EC5 
                          C_EC6_ADDR  when OPCODE_ANDL, -- ANDL -> EC6 
                          C_EC6_ADDR  when OPCODE_ORL,  -- ORL  -> EC6 
                          C_EC6_ADDR  when OPCODE_XORL, -- XORL -> EC6 
                          C_EC6_ADDR  when OPCODE_ADDL, -- ADDL -> EC6 
                          C_EC6_ADDR  when OPCODE_SUBL, -- ADDL -> EC6 
                          C_EC7_ADDR  when OPCODE_ANDR, -- ANDR -> EC7 
                          C_EC7_ADDR  when OPCODE_ORR,  -- ORR  -> EC7 
                          C_EC7_ADDR  when OPCODE_XORR, -- XORR -> EC7 
                          C_EC7_ADDR  when OPCODE_ADDR, -- ADDR -> EC7 
                          C_EC7_ADDR  when OPCODE_SUBR, -- ADDR -> EC7 
                          C_EC8_ADDR  when OPCODE_CMPL, -- CMPL -> EC8 
                          C_EC9_ADDR  when OPCODE_CMPR, -- CMPR -> EC9 
                          C_EC10_ADDR when OPCODE_JMP,  -- JMP  -> EC10
                          C_EC10_ADDR when OPCODE_JCON, -- JCON -> EC10
                          C_EC11_ADDR when OPCODE_RETI, -- RETI -> EC11
                          C_EC11_ADDR when OPCODE_RETC, -- RETC -> EC11
                          C_EC12_ADDR when OPCODE_PUSH, -- PUSH -> EC12
                          C_EC13_ADDR when OPCODE_POP,  -- POP  -> EC13
                          C_EC14_ADDR when OPCODE_CALL, -- CALL -> EC14
                          C_EC15_ADDR when OPCODE_STRR, -- STRR -> EC15
                          C_EC16_ADDR when OPCODE_LDRR, -- LDRR -> EC16
                          C_NOP       when others;      -- treated as NOP
                          
    MICRO_CODE_SEL: process ( microcode_addr_i, handle_irq_i) is
    begin
        if microcode_addr_i = C_IC_ADDR and handle_irq_i = '0' then --if suposed to jump to interrupt and no interrupt jump back to fetch sequence directly.
            next_micro_addr_i <= C_FC_ADDR;
        else
            next_micro_addr_i <= microcode_addr_i;
        end if;
    end process MICRO_CODE_SEL;  
                          
                              
    -- For the next ctrl_memory address there are 3 options:
    --  1) next address
    --  2) branch (determined by current microinstruction = ctrl_mem_data_i)
    --  3) branch (determined by opcode (in ir_msb))
    ADDR_SEQUENCING_PROC: process (clk, reset) is
    begin
        if reset = '1' then
            ctrl_mem_addr_i <= (others=>'0');
        elsif rising_edge(clk) then
            if hold_microcode_i = '1' then
                ctrl_mem_addr_i <= ctrl_mem_addr_i; -- hold the processor while low        
            elsif no_branch_i = '1' then
                ctrl_mem_addr_i <= ctrl_mem_addr_i + '1';
            elsif branch_opcode_i = '1' then
                ctrl_mem_addr_i <= next_opcode_addr_i;
            elsif branch_microcode_i = '1' then
                ctrl_mem_addr_i <= next_micro_addr_i; 
            else
                ctrl_mem_addr_i <= (others=>'0');
                sequencing_error_i <= '1';
            end if;
        end if;
    end process;

    hold_microcode_i <= not ready when system_bus_read_enable_i = '1'  or system_bus_write_enable_i = '1' else '0'; 
    
    -- control output decoder
    cpu_bus_sel_i <= cpu_bus_source_i;
    
    -- cpu SFR load enables
    flags_le_i    <= alu_out_le_i;
    z_le_i        <= alu_out_le_i;
    y_le_i        <= cpu_reg_le_i when cpu_bus_dest_i = SFR_Y    else '0';
    reg_file_le_i <= cpu_reg_le_i when cpu_bus_dest_i = GP_REG   else '0';
    mar_le_i      <= cpu_reg_le_i when cpu_bus_dest_i = SFR_MAR  else '0';
    dbro_le_i     <= cpu_reg_le_i when cpu_bus_dest_i = SFR_DBR  else '0';
    dbri_le_i     <= dbr_in_le_i;
    ir_h_le_i     <= cpu_reg_le_i when cpu_bus_dest_i = SFR_IR_H else '0';
    ir_l_le_i     <= cpu_reg_le_i when cpu_bus_dest_i = SFR_IR_L else '0';

    -- pc control (conditional branches and interrupt)
    inc_pc_i <= increment_pc_i;
    pc_le_i <= pc_le_jump_i or pc_le_irq_i;
    pc_le_unmasked_i <= cpu_reg_le_i when cpu_bus_dest_i = SFR_PC else '0';
    pc_le_jump_i <= pc_le_unmasked_i and jump_control_i and (not interrupt_cycle_i); -- mask pc_le for (conditional) jumps
    pc_le_irq_i <= pc_le_unmasked_i and handle_irq_i and interrupt_cycle_i; -- mask pc_le for irq handling

    -- detecting conditional jumps
    with operand_1_i select
    flag_jump_i <= flags_i(C_ZF) when FLAG_Z,
                   flags_i(C_CF) when FLAG_C,
                   flags_i(C_EF) when FLAG_E,
                   flags_i(C_GF) when FLAG_G,
                   flags_i(C_SF) when FLAG_S,
                   '0' when others;
    
    with opcode_i select
    jump_control_i <= flag_jump_i   when OPCODE_JCON,            
                      '1'           when OPCODE_JMP,
                      '1'           when OPCODE_RETI,
                      '1'           when OPCODE_RETC,
                      '1'           when OPCODE_CALL,
                      '0'           when others;      
          
    -- interrupt handling
    start_ic_i <= branch_microcode_i when next_micro_addr_i = C_IC_ADDR else '0';
    end_ic_i <= branch_microcode_i when next_micro_addr_i = C_FC_ADDR else '0';
    
    IC : Interrupt_Control
    port map(
                clk => clk,
              reset => reset,
           start_ic => start_ic_i,
             end_ic => end_ic_i,
                irq => irq,
         handle_irq => handle_irq_i,
          int_cycle => interrupt_cycle_i
    );
    
    -- system bus
    system_bus_write_enable_i <= (handle_irq_i and bus_write_enable_i) when interrupt_cycle_i = '1' else
                                  bus_write_enable_i;
    system_bus_read_enable_i <= bus_read_enable_i;
    
    -- alu
    with opcode_i select
    alu_op_i <= ALU_OP_NOT  when OPCODE_NOT,
                ALU_OP_SR   when OPCODE_SR,
                ALU_OP_SL   when OPCODE_SL,
                ALU_OP_AND  when OPCODE_ANDL,
                ALU_OP_AND  when OPCODE_ANDR,
                ALU_OP_OR   when OPCODE_ORL,
                ALU_OP_OR   when OPCODE_ORR,
                ALU_OP_XOR  when OPCODE_XORL,
                ALU_OP_XOR  when OPCODE_XORR,
                ALU_OP_ADD  when OPCODE_ADDL,
                ALU_OP_ADD  when OPCODE_ADDR,
                ALU_OP_SUB  when OPCODE_SUBL,
                ALU_OP_SUB  when OPCODE_SUBR,
                ALU_OP_CMP  when OPCODE_CMPL,
                ALU_OP_CMP  when OPCODE_CMPR,
                ALU_OP_SWAP when OPCODE_SWAP,
                "0000"      when others;
    
    -- stack pointer
    sp_down_i <= dec_sp_i;
    sp_up_i <= (handle_irq_i and inc_sp_i) when interrupt_cycle_i = '1' else -- interrupt cycle masking
                inc_sp_i; -- other conditions e.g. push instruction
    
    -- control output signal
    controls <= "00000000" & sp_down_i & sp_up_i & alu_op_i & source_destination_swap_i & cpu_bus_sel_i & 
        flags_le_i & z_le_i & y_le_i & reg_file_le_i & mar_le_i & dbro_le_i & dbri_le_i & 
        inc_pc_i & pc_le_i & ir_h_le_i & ir_l_le_i & system_bus_write_enable_i & system_bus_read_enable_i;
    
    error <= sequencing_error_i;
end Behavioral;
