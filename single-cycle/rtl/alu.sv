`default_nettype none

module alu
  ( input  var logic [31:0] i_a
  , input  var logic [31:0] i_b

  , input  var logic [1:0]  i_aluControl

  , output var logic [31:0] o_result
  );

  always_comb
    case (i_aluControl)
      2'b00:   o_result = i_a + i_b;         // Add
      2'b01:   o_result = i_a + (~i_b+1'b1); // Subtract
      2'b10:   o_result = i_a & i_b;         // And
      2'b11:   o_result = i_a | i_b;         // Or
      default: o_result = 32'bx;
    endcase

  endmodule

`resetall
