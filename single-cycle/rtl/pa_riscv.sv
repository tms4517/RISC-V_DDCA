`ifndef PA_RISCV
  `define PA_RISCV

`default_nettype none

package pa_riscv;

  typedef enum logic [6:0]
  { I = 7'b0000011
  , S = 7'b0100011
  } ty_INSTRUCTION_TYPE;

endpackage

`resetall

`endif
