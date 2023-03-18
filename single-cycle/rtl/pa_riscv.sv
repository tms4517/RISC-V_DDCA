`ifndef PA_RISCV
  `define PA_RISCV

`default_nettype none

package pa_riscv;

  typedef enum logic [6:0]
  { I = 7'b0000011
  , S = 7'b0100011
  , R = 7'b0110011
  } ty_INSTRUCTION_TYPE;

  typedef enum logic [3:0]
  { ADD = 4'b0000
  , SUB = 4'b1000
  , AND = 4'b0111
  , OR  = 4'b0110
  , XOR = 4'b0100
  } ty_ALU_OP;

endpackage

`resetall

`endif
