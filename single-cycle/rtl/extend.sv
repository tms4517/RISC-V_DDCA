`default_nettype none

module extend
  ( input  var logic [31:0] i_instruction

  , output var logic [31:0] o_immediateExtended
  );

  // Decode opcode to find the immediate bits to concatenate, and sign extend
  // to 32 bits.
  always_comb
    case (i_instruction[6:0])
      // LW
      7'b0000011: o_immediateExtended =
                    {{20{i_instruction[31]}}, i_instruction[31:20]};
      // SW
      7'b0100011: o_immediateExtended =
                    {{20{instr[31]}}, instr[31:25], instr[11:7]};
      default:    o_immediateExtended = 32'bx;
    endcase

  endmodule

`resetall
