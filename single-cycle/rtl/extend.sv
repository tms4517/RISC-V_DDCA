`default_nettype none

module alu
  ( input  var logic [11:0] i_immediate

  , output var logic [31:0] o_immediateExtended
  );

  always_comb o_immediateExtended = {{20{i_immediate[11]}}, i_immediate[11:0]};

  endmodule

`resetall
