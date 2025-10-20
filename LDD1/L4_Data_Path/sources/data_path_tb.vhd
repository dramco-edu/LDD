----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: data_path_tb - Behavioral
-- Course Name: Lab Digital Design
-- 
-- Description: 
--  Testbench for the processor datapath module.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

library WORK;
use work.processor_pkg.all;

library STD;
use STD.TEXTIO.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity data_path_tb is
end data_path_tb;

architecture Behavioral of data_path_tb is
    -- constants
    constant clk_period : time := 10 ns;
    
    constant C_DATA_WIDTH : natural := 8;
    constant C_NR_FLAGS : natural := 5;
    
    -- inputs
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal alu_op : std_logic_vector(3 downto 0) := (others=>'0');
    signal y_le : std_logic := '0';
    signal z_le : std_logic := '0';
    signal flags_le : std_logic := '0';
    signal reg_file_le : std_logic := '0';
    signal Rsource : std_logic_vector(2 downto 0) := (others=>'0');
    signal Rdestination : std_logic_vector(2 downto 0) := (others=>'0');
    signal cpu_bus_sel : std_logic_vector(3 downto 0) := (others=>'0');
    signal dibr : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal pc : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal sp : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');
    signal ir_l : std_logic_vector(C_DATA_WIDTH-1 downto 0) := (others=>'0');

    -- outputs
    signal cpu_bus : std_logic_vector(C_DATA_WIDTH-1 downto 0);
    signal flags : std_logic_vector(4 downto 0);
    
    
    --debug information
    type debug_t is (resetting, DIBR_to_R0, PC_to_R2, SP_to_R4, IR_to_R6, IV_to_R7, SWAP_R7, NOT_R1, SL_R1, SR_R2, 
                     CMP_R6_R4, CMP_R4_R6, SUB_R6_R4, MOV_R4_TO_R3, ended);
    signal debug : debug_t;
    
    -- DUT
    component data_path is
    generic(
        C_DATA_WIDTH : natural := 8;
          C_NR_FLAGS : natural := 5
    );
    port(
                 clk : in  std_logic;
               reset : in  std_logic;
         -- ALU-related control inputs 
              alu_op : in  std_logic_vector(3 downto 0);
                y_le : in  std_logic;
                z_le : in  std_logic;
            flags_le : in  std_logic;
         -- Regsiter File control inputs
         reg_file_le : in  std_logic;
             Rsource : in  std_logic_vector(2 downto 0);
        Rdestination : in  std_logic_vector(2 downto 0);
         -- CPU bus control and inputs
         cpu_bus_sel : in  std_logic_vector(3 downto 0);
                dibr : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
                  pc : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
                  sp : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
                ir_l : in  std_logic_vector(C_DATA_WIDTH-1 downto 0);
         -- Data path outputs
             cpu_bus : out std_logic_vector(C_DATA_WIDTH-1 downto 0);
               flags : out std_logic_vector(C_NR_FLAGS-1 downto 0)
          
    );
    end component;

begin

    DUT : data_path
    generic map(
       C_DATA_WIDTH => C_DATA_WIDTH,
         C_NR_FLAGS => C_NR_FLAGS
    )
    port map(
                 clk => clk,
               reset => reset,
              alu_op => alu_op,
                y_le => y_le,
                z_le => z_le,
            flags_le => flags_le,
         reg_file_le => reg_file_le,
             Rsource => Rsource,
        Rdestination => Rdestination,
         cpu_bus_sel => cpu_bus_sel,
                dibr => dibr,
                  pc => pc,
                  sp => sp,
                ir_l => ir_l,
             cpu_bus => cpu_bus,
               flags => flags
    );
    
    CLK_PROC: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process CLK_PROC;
    
    STIM_PROC: process
        variable s: line;
    begin
        reset <= '1';
        wait for clk_period*2;
        reset <= '0';
        
        -- first we test register file operation in combination with cpu bus operation ---------
        -- write to register 0 via dibr input
        debug <= DIBR_to_R0;
        dibr <= x"FF";
        cpu_bus_sel <= SFR_DBR;
        Rdestination <= REGFILE_R0;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"FF"
            report "cpu bus selection error (dibr)"
            severity ERROR;
        if cpu_bus = x"FF" then
            write (s, string'("SUCCESS: cpu bus selection (dibr)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R0;
        wait for 2 ns;
        assert cpu_bus = x"FF"
            report "cpu bus selection error (register 0)"
            severity ERROR;
        if cpu_bus = x"FF" then
            write (s, string'("SUCCESS: cpu bus selection (register 0)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
        -- write to register 2 via pc input
        debug <= PC_to_R2;
        pc <= x"01";
        cpu_bus_sel <= SFR_PC;
        Rdestination <= REGFILE_R2;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"01"
            report "cpu bus selection error (pc)"
            severity ERROR;
        if cpu_bus = x"01" then
            write (s, string'("SUCCESS: cpu bus selection (pc)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R2;
        wait for 2 ns;
        assert cpu_bus = x"01"
            report "cpu bus selection error (register 2)"
            severity ERROR;
        if cpu_bus = x"01" then
            write (s, string'("SUCCESS: cpu bus selection (register 2)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);

        -- write to register 4 via sp input
        debug <= SP_to_R4;
        sp <= x"55";
        cpu_bus_sel <= SFR_SP;
        Rdestination <= REGFILE_R4;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"55"
            report "cpu bus selection error (sp)"
            severity ERROR;
        if cpu_bus = x"55" then
            write (s, string'("SUCCESS: cpu bus selection (sp)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R4;
        wait for 2 ns;
        assert cpu_bus = x"55"
            report "cpu bus selection error (register 4)"
            severity ERROR;
        if cpu_bus = x"55" then
            write (s, string'("SUCCESS: cpu bus selection (register 4)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
        -- write to register 6 via ir input
        debug <= IR_to_R6;
        ir_l <= x"77";
        cpu_bus_sel <= SFR_IR_L;
        Rdestination <= REGFILE_R6;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"77"
            report "cpu bus selection error (ir_l)"
            severity ERROR;
        if cpu_bus = x"77" then
            write (s, string'("SUCCESS: cpu bus selection (ir_l)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R6;
        wait for 2 ns;
        assert cpu_bus = x"77"
            report "cpu bus selection error (register 6)"
            severity ERROR;
        if cpu_bus = x"77" then
            write (s, string'("SUCCESS: cpu bus selection (register 6)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);  

        -- write IV(=2) to register 7
        debug <= IV_to_R7;
        cpu_bus_sel <= SFR_IV;
        Rdestination <= REGFILE_R7;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"02"
            report "cpu bus selection error (iv)"
            severity ERROR;
        if cpu_bus = x"02" then
            write (s, string'("SUCCESS: cpu bus selection (iv)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R7;
        wait for 2 ns;
        assert cpu_bus = x"02"
            report "cpu bus selection error (register 7)"
            severity ERROR;
        if cpu_bus = x"02" then
            write (s, string'("SUCCESS: cpu bus selection (register 7)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
        -- now we combine with alu single operand operations ---------
        -- swap R7
        debug <= SWAP_R7;
        alu_op <= ALU_OP_SWAP;
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R7;
        flags_le <= '1';
        z_le <= '1';
        wait until falling_edge(clk);
        z_le <= '0';
        flags_le <= '0';
        -- write back to R7
        cpu_bus_sel <= SFR_Z;
        Rdestination <= REGFILE_R7;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"20"
            report "cpu bus selection error (alu output) or alu operation error (SWAP)"
            severity ERROR;
        if cpu_bus = x"20" then
            write (s, string'("SUCCESS: alu SWAP operation and cpu bus selection (alu output)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        
        -- not R1
        debug <= NOT_R1;
        alu_op <= ALU_OP_NOT;
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R1;
        flags_le <= '1';
        z_le <= '1';
        wait until falling_edge(clk);
        z_le <= '0';
        flags_le <= '0';
        -- write back to R1
        cpu_bus_sel <= SFR_Z;
        Rdestination <= REGFILE_R1;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"FF"
            report "cpu bus selection error (alu output) or alu operation error (NOT)"
            severity ERROR;
        if cpu_bus = x"FF" then
            write (s, string'("SUCCESS: alu NOT operation and cpu bus selection (alu output)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        
        -- rl R1
        debug <= SL_R1;
        alu_op <= ALU_OP_SL;
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R1;
        flags_le <= '1';
        z_le <= '1';
        wait until falling_edge(clk);
        z_le <= '0';
        flags_le <= '0';
        -- write back to R1
        cpu_bus_sel <= SFR_Z;
        Rdestination <= REGFILE_R1;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"FE"
            report "cpu bus selection error (alu output) or alu operation error (SL)"
            severity ERROR;
        assert flags(3) = '1'
            report "carry flag not set on alu operation (SL)"
            severity ERROR;
        if (cpu_bus = x"FE") and (flags(3)='1') then
            write (s, string'("SUCCESS: alu SL operation and cpu bus selection (alu output)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        
        -- rr R2
        debug <= SR_R2;
        alu_op <= ALU_OP_SR;
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R2;
        flags_le <= '1';
        z_le <= '1';
        wait until falling_edge(clk);
        z_le <= '0';
        flags_le <= '0';
        -- write back to R2
        cpu_bus_sel <= SFR_Z;
        Rdestination <= REGFILE_R2;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"00"
            report "cpu bus selection error (alu output) or alu operation error (SR)"
            severity ERROR;
        assert flags(3) = '1'
            report "carry flag not set on alu operation (SR)"
            severity ERROR;
        assert flags(4) = '1'
            report "zero flag not set on alu operation (SR)"
            severity ERROR;
        if (cpu_bus = x"00") and (flags(3)='1') and (flags(4)='1') then
            write (s, string'("SUCCESS: alu SR operation and cpu bus selection (alu output)"));
            writeline (output, s);
        end if;
        wait until falling_edge(clk);
        reg_file_le <= '0';
        
        -- dual operand (no register writeback)
        -- cmp R6, R4
        debug <= CMP_R6_R4;
            -- load y
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R4;
        y_le <= '1';
        wait until falling_edge(clk);
        y_le <= '0';
            -- alu op
        alu_op <= ALU_OP_CMP;
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R6;
        flags_le <= '1';
        wait until falling_edge(clk);
        flags_le <= '0';
        
        assert (flags(2) = '0') and (flags(1) = '1') and (flags(0) = '0')
           report "wrong flag set (expected gf) on alu operation (CMP), check y register"
           severity ERROR;
        if (flags(2) = '0') and (flags(1)='1') and (flags(0)='0') then
           write (s, string'("SUCCESS: alu CMP operation"));
           writeline (output, s);
        end if;
        wait until falling_edge(clk);
        
         -- cmp R4, R6
         debug <= CMP_R4_R6;
             -- load y
         cpu_bus_sel <= GP_REG;
         Rsource <= REGFILE_R6;
         y_le <= '1';
         wait until falling_edge(clk);
         y_le <= '0';
             -- alu op
         alu_op <= ALU_OP_CMP;
         cpu_bus_sel <= GP_REG;
         Rsource <= REGFILE_R4;
         flags_le <= '1';
         wait until falling_edge(clk);
         flags_le <= '0';
         
         assert (flags(2) = '0') and (flags(1) = '0') and (flags(0) = '1')
            report "wrong flag set (expected sf) on alu operation (CMP), check y register"
            severity ERROR;
         if (flags(2) = '0') and (flags(0)='1') and (flags(1)='0') then
            write (s, string'("SUCCESS: alu CMP operation"));
            writeline (output, s);
         end if;
         wait until falling_edge(clk);
           
         -- sub R6, R4
         debug <= SUB_R6_R4;
              -- load y
          cpu_bus_sel <= GP_REG;
          Rsource <= REGFILE_R4;
          y_le <= '1';
          wait until falling_edge(clk);
          y_le <= '0';
              -- alu op
          alu_op <= ALU_OP_SUB;
          cpu_bus_sel <= GP_REG;
          Rsource <= REGFILE_R6;
          flags_le <= '1';
          z_le <= '1';
          wait until falling_edge(clk);
          flags_le <= '0';
          z_le <= '0';
          
          -- write back to R6
          cpu_bus_sel <= SFR_Z;
          Rdestination <= REGFILE_R6;
          reg_file_le <= '1';
          wait for 2 ns;
          assert cpu_bus = x"22"
              report "cpu bus selection error (alu output) or alu operation error (SUB)"
              severity ERROR;
          assert (flags(4) = '0') and (flags(3) = '0')
             report "wrong flags set (zf & cf) on alu operation (SUB)"
             severity ERROR;
          if (cpu_bus = x"22") and (flags(4) = '0') and (flags(3)='0') then
             write (s, string'("SUCCESS: alu SUB operation"));
             writeline (output, s);
          end if;
          wait until falling_edge(clk);
          reg_file_le <= '0';
         
        -- move reg to reg
        debug <= MOV_R4_TO_R3;
        cpu_bus_sel <= GP_REG;
        Rsource <= REGFILE_R4;
        Rdestination <= REGFILE_R3;
        reg_file_le <= '1';
        wait for 2 ns;
        assert cpu_bus = x"55"
            report "wrong value in R4, or register/bus selection error"
            severity ERROR;
        wait until falling_edge(clk);
        Rsource <= REGFILE_R3;
        wait for 2 ns;
        assert cpu_bus = x"55"
            report "error in move from register file to register file "
            severity ERROR;
        if (cpu_bus = x"55") then
            write (s, string'("SUCCESS: move R4 -> R3"));
            writeline (output, s);
        end if;
        
        -- End simulation
        debug <= ended;  
        assert false
            report "Simulation ended."
            severity NOTE;
        
        wait;
    end process STIM_PROC;
    
end Behavioral;

