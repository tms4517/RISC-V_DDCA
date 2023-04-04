`default_nettype none

import pa_riscv::*;

module alu
  ( input  var logic [31:0] i_a
  , input  var logic [31:0] i_b
  , input  var logic [3:0]  i_aluLogicOperation

  , output var logic [31:0] o_result

  , output var logic        o_zeroFlag
  );

  logic isSub;

  logic [31:0] adder;
  logic [31:0] b;

  // Use a common adder for ADD and SUB. If the operation is subtract, the input
  // to the adder is -b.
  always_comb isSub = (i_aluLogicOperation[3] == '1);
  always_comb b = isSub ? (~i_b+1'b1) : i_b;
  always_comb adder = i_a + b;

  // TODO: Add more logical operations.
  always_comb
    case (i_aluLogicOperation)
      ADD:     o_result = adder;
      SUB:     o_result = adder;
      AND:     o_result = i_a & i_b;
      OR:      o_result = i_a | i_b;
      XOR:     o_result = i_a ^ i_b;
      default: o_result = 32'bx;
    endcase

  always_comb o_zeroFlag = (o_result == '0);

  endmodule

`resetall
