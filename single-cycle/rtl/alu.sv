`default_nettype none

import pa_riscv::*;

module alu
  ( input  var logic [31:0] i_a
  , input  var logic [31:0] i_b

  , input  var logic [3:0]  i_aluLogicalOperation

  , output var logic [31:0] o_result
  );

  // TODO: Add more logical operations.
  always_comb
    case (i_aluLogicalOperation)
      ADD:     o_result = i_a + i_b;
      SUB:     o_result = i_a + (~i_b+1'b1);
      AND:     o_result = i_a & i_b;
      OR:      o_result = i_a | i_b;
      XOR:     o_result = i_a ^ i_b;
      default: o_result = 32'bx;
    endcase

  endmodule

`resetall
