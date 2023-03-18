`default_nettype none

import pa_riscv::*;

module extend
  ( input  var logic [31:0] i_instruction

  , output var logic [31:0] o_immediateExtended
  );

  // Decode opcode to find the immediate bits to concatenate, and sign extend
  // to 32 bits. For the B-Type instruction, the LSB is 0 so that the branch
  // target address is aligned to a 2-byte boundary.
  always_comb
    case (i_instruction[6:0])
      I:       o_immediateExtended =
                {{20{i_instruction[31]}}, i_instruction[31:20]};
      S:       o_immediateExtended =
                {{20{i_instruction[31]}}, i_instruction[31:25], i_instruction[11:7]};
      B:       o_immediateExtended =
                {{20{i_instruction[31]}}, i_instruction[7], i_instruction[30:25],
                  i_instruction[11:8], 1'b0};
      default: o_immediateExtended = 32'bx;
    endcase

  endmodule

`resetall
