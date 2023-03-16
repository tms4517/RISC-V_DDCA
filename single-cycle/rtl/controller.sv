`default_nettype none

import pa_riscv::*;

module controller
  ( input  var logic [6:0] i_operand

  , output var logic       o_regWrite
  , output var logic [1:0] o_aluControl
  , output var logic       o_memWrite
  );

  // Decode operand to determine if the instruction involves a register write.
  always_comb
    case (i_operand)
      I:       o_regWrite = '1;
      S:       o_regWrite = '0;
      default: o_regWrite = 'x;
    endcase

  // Decode operand to determine the logical operation performed by the ALU for
  // the instruction.
  always_comb
    case (i_operand)
      I:       o_aluControl = 2'b00;
      S:       o_aluControl = 2'b00;
      default: o_aluControl = 2'bxx;
    endcase

  // Decode operand to determine if the instruction involves a memory write.
  always_comb
    case (i_operand)
      I:       o_memWrite = '0;
      S:       o_memWrite = '1;
      default: o_memWrite = 'x;
    endcase

  endmodule

`resetall
