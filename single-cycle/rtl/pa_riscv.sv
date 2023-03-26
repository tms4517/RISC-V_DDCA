`ifndef PA_RISCV
  `define PA_RISCV

`default_nettype none

package pa_riscv;

  typedef enum logic [6:0]
  { LW         = 7'b0000011
  , SW         = 7'b0100011
  , R_TYPE_ALU = 7'b0110011
  , B_TYPE     = 7'b1100011
  , I_TYPE_ALU = 7'b0010011
  , JAL        = 7'b1101111
  } ty_INSTRUCTION_TYPE;

  typedef enum logic [3:0]
  { ADD = 4'b0000
  , SUB = 4'b1000
  , AND = 4'b0111
  , OR  = 4'b0110
  , XOR = 4'b0100
  } ty_ALU_OP;

  // Select input to the write data port of the ALU.
  typedef enum logic [2:0]
  { DATAMEMORY = 2'b01
  , ALU        = 2'b00
  , PCPLUS4    = 2'b10
  } ty_ALU_OP;

endpackage

`resetall

`endif
