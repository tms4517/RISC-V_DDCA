`default_nettype none

module extend
  ( input  var logic [31:0] i_instruction
  , input  var logic [1:0]  i_immediateSelect

  , output var logic [31:0] o_immediateExtended
  );

  // Decode opcode to find the immediate bits to concatenate, and sign extend
  // to 32 bits.
  always_comb
    case (i_immediateSelect)
      // LW
      2'b00:   o_immediateExtended =
                {{20{i_instruction[31]}}, i_instruction[31:20]};
      // SW
      2'b01:   o_immediateExtended =
                {{20{i_instruction[31]}}, i_instruction[31:25], i_instruction[11:7]};
      default: o_immediateExtended = 32'bx;
    endcase

  endmodule

`resetall
