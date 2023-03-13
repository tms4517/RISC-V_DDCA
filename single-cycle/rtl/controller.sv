`default_nettype none

module controller
  ( input  var logic [6:0] i_operand

  , output var logic       o_regWrite
  , output var logic [1:0] o_immediateSelect
  , output var logic [1:0] o_aluControl
  , output var logic       o_memWrite
  );

  // Decode operand to determine if the instruction involves a register write.
  always_comb
    case (i_operand)
      // LW
      7'b0000011: o_regWrite = '1;
      // SW
      7'b0100011: o_regWrite = '0;
      default:    o_regWrite = 'x;
    endcase

  // Decode operand to determine which bits of the instruction represent the
  // immediate field.
  always_comb
    case (i_operand)
      // LW
      7'b0000011: o_immediateSelect = 2'b00;
      // SW
      7'b0100011: o_immediateSelect = 2'b01;
      default:    o_immediateSelect = 2'bxx;
    endcase

  // Decode operand to determine the logical operation performed by the ALU for
  // the instruction.
  always_comb
    case (i_operand)
      // LW
      7'b0000011: o_aluControl = 2'b00;
      // SW
      7'b0100011: o_aluControl = 2'b00;
      default:    o_aluControl = 2'bxx;
    endcase

  // Decode operand to determine if the instruction involves a memory write.
  always_comb
    case (i_operand)
      // LW
      7'b0000011: o_memWrite = '0;
      // SW
      7'b0100011: o_memWrite = '1;
      default:    o_memWrite = 'x;
    endcase

  endmodule

`resetall
