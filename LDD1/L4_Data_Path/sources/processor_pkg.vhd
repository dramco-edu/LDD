----------------------------------------------------------------------------------
-- Company: DRAMCO -- KU Leuven
-- Engineer: Geoffrey Ottoy
-- 
-- Module Name: processor_pkg - Behavioral
-- Course Name: Lab Digital Design
--
-- Description:
--  Package for the Digital Design course lab exercises
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

package processor_pkg is
    -- instruction opcodes (all 32)
    constant OPCODE_NOP  : std_logic_vector(4 downto 0) := "00000";
    constant OPCODE_RETI : std_logic_vector(4 downto 0) := "00001";
    constant OPCODE_RETC : std_logic_vector(4 downto 0) := "00010";
    constant OPCODE_CALL : std_logic_vector(4 downto 0) := "00011";
    constant OPCODE_JMP  : std_logic_vector(4 downto 0) := "00100";
    constant OPCODE_JCON : std_logic_vector(4 downto 0) := "00101"; --regrouping all the conditional jumps
    
    constant OPCODE_MOVL : std_logic_vector(4 downto 0) := "01000";
    constant OPCODE_MOVR : std_logic_vector(4 downto 0) := "01001";
    constant OPCODE_LDR  : std_logic_vector(4 downto 0) := "01010";
    constant OPCODE_STR  : std_logic_vector(4 downto 0) := "01011";
    constant OPCODE_LDRR : std_logic_vector(4 downto 0) := "01100";
    constant OPCODE_STRR : std_logic_vector(4 downto 0) := "01101";
    constant OPCODE_PUSH : std_logic_vector(4 downto 0) := "01110";
    constant OPCODE_POP  : std_logic_vector(4 downto 0) := "01111";
   
    constant OPCODE_NOT  : std_logic_vector(4 downto 0) := "10000";
    constant OPCODE_RR   : std_logic_vector(4 downto 0) := "10001";
    constant OPCODE_RL   : std_logic_vector(4 downto 0) := "10010";
    constant OPCODE_SWAP : std_logic_vector(4 downto 0) := "10011";    
    
    constant OPCODE_ANDL : std_logic_vector(4 downto 0) := "10100";
    constant OPCODE_ANDR : std_logic_vector(4 downto 0) := "10101";
    constant OPCODE_ORL  : std_logic_vector(4 downto 0) := "10110";
    constant OPCODE_ORR  : std_logic_vector(4 downto 0) := "10111";
    constant OPCODE_XORL : std_logic_vector(4 downto 0) := "11000";
    constant OPCODE_XORR : std_logic_vector(4 downto 0) := "11001";
    constant OPCODE_ADDL : std_logic_vector(4 downto 0) := "11010";
    constant OPCODE_ADDR : std_logic_vector(4 downto 0) := "11011";
    constant OPCODE_SUBL : std_logic_vector(4 downto 0) := "11100";
    constant OPCODE_SUBR : std_logic_vector(4 downto 0) := "11101";
    constant OPCODE_CMPL : std_logic_vector(4 downto 0) := "11110";
    constant OPCODE_CMPR : std_logic_vector(4 downto 0) := "11111";
    

    -- alu operation selection
    constant ALU_OP_NOT  : std_logic_vector(3 downto 0) := "0001";
    constant ALU_OP_AND  : std_logic_vector(3 downto 0) := "0010";
    constant ALU_OP_OR   : std_logic_vector(3 downto 0) := "0011";
    constant ALU_OP_XOR  : std_logic_vector(3 downto 0) := "0100";
    constant ALU_OP_ADD  : std_logic_vector(3 downto 0) := "0101";
    constant ALU_OP_SUB  : std_logic_vector(3 downto 0) := "0110";
    constant ALU_OP_CMP  : std_logic_vector(3 downto 0) := "0111";
    constant ALU_OP_RR   : std_logic_vector(3 downto 0) := "1000";
    constant ALU_OP_RL   : std_logic_vector(3 downto 0) := "1001";
    constant ALU_OP_SWAP : std_logic_vector(3 downto 0) := "1010";
        
    -- register file register selection
    constant REGFILE_R0  : std_logic_vector(2 downto 0) := "000";
    constant REGFILE_R1  : std_logic_vector(2 downto 0) := "001";
    constant REGFILE_R2  : std_logic_vector(2 downto 0) := "010";
    constant REGFILE_R3  : std_logic_vector(2 downto 0) := "011";
    constant REGFILE_R4  : std_logic_vector(2 downto 0) := "100";
    constant REGFILE_R5  : std_logic_vector(2 downto 0) := "101";
    constant REGFILE_R6  : std_logic_vector(2 downto 0) := "110";
    constant REGFILE_R7  : std_logic_vector(2 downto 0) := "111";
    
    -- conditional flag selection for jumps
    constant FLAG_Z      : std_logic_vector(2 downto 0) := "000";
    constant FLAG_C      : std_logic_vector(2 downto 0) := "001";
    constant FLAG_E      : std_logic_vector(2 downto 0) := "010";
    constant FLAG_G      : std_logic_vector(2 downto 0) := "011";
    constant FLAG_S      : std_logic_vector(2 downto 0) := "100";
    
    -- CPU register selection (CPU bus source and destination) 
    constant SFR_PC      : std_logic_vector(3 downto 0) := "0000"; -- program counter
    constant SFR_MAR     : std_logic_vector(3 downto 0) := "0001"; -- memory address register
    constant SFR_DBR     : std_logic_vector(3 downto 0) := "0010"; -- data buffer register
    constant SFR_Y       : std_logic_vector(3 downto 0) := "0011"; -- alu input
    constant SFR_Z       : std_logic_vector(3 downto 0) := "0100"; -- alu output
    constant SFR_SP      : std_logic_vector(3 downto 0) := "0101"; -- stack pointer
    constant SFR_IV      : std_logic_vector(3 downto 0) := "0110"; -- interrupt vector
    constant GP_REG      : std_logic_vector(3 downto 0) := "0111"; -- select general purpose register file
    constant SFR_IR_H    : std_logic_vector(3 downto 0) := "1000"; -- instruction register msb
    constant SFR_IR_L    : std_logic_vector(3 downto 0) := "1001"; -- instruction register lsb
    
    
    function nb_bit_req(val : natural) return natural;

end processor_pkg;

package body processor_pkg is
    function zeros(constant matching: std_logic_vector) return std_logic_vector is
        variable z: std_logic_vector(matching'range) := (matching'range=>'0');
    begin
        return z;
    end; 
    
    -- Returns number of bits required to represent val in binary vector
    function nb_bit_req(val : natural) return natural is
      variable nb_bit   : natural;  -- Result
      variable remain : natural;  -- Remainder used in iteration
    begin
      nb_bit := 0;
      remain := val-1;
      while remain > 0 loop  -- Iteration for each bit required
        nb_bit := nb_bit + 1;
        remain := remain / 2;
      end loop;
      return nb_bit;
    end function;

end processor_pkg;
