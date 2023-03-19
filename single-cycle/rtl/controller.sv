`default_nettype none

import pa_riscv::*;

module controller
  ( input  var logic [6:0] i_operand
  , input  var logic [2:0] i_funct3
  , input  var logic       i_funct7bit5

  , output var logic       o_regWriteEn
  , output var logic       o_aluInputBSel
  , output var logic [3:0] o_aluLogicOperation
  , output var logic       o_memWriteEn
  , output var logic       o_regWriteDataSel
  );

  // Decode operand to determine if the instruction involves a register write.
  always_comb
    case (i_operand)
      I:       o_regWriteEn = '1;
      S:       o_regWriteEn = '0;
      B:       o_regWriteEn = '0;
      default: o_regWriteEn = 'x;
    endcase

  // Decode operand to determine the input of the ALU i_b port.
  always_comb
    case (i_operand)
      I:       o_aluInputBSel = '1; // Select o_immediateExtended from extend module.
      S:       o_aluInputBSel = '1;
      R:       o_aluInputBSel = '0; // Select o_readData2 from register file.
      default: o_aluInputBSel = 'x;
    endcase

  logic [3:0] rTypeOperation;

  // Bit 5 of funct7 and funct3 are used for R-Type instructions to determine
  // the operation.
  always_comb rTypeOperation = {i_funct7bit5, i_funct3};

  // Decode operand to determine the logical operation performed by the ALU for
  // the instruction.
  always_comb
    case (i_operand)
      I:       o_aluLogicOperation = 4'b0000;
      S:       o_aluLogicOperation = 4'b0000;
      R:       o_aluLogicOperation = rTypeOperation;
      B:       o_aluLogicOperation = 4'b0000; // Doesnt matter.
      default: o_aluLogicOperation = 4'bxxxx;
    endcase

  // Decode operand to determine if the instruction involves a memory write.
  always_comb
    case (i_operand)
      I:       o_memWriteEn = '0;
      S:       o_memWriteEn = '1;
      B:       o_memWriteEn = '0;
      default: o_memWriteEn = 'x;
    endcase

  // Decode operand to determine if the input to the write data port of the
  // register file should come from the data memory or output from the ALU.
  always_comb
    case (i_operand)
      I:       o_regWriteDataSel = '1; // Select the output from data memory.
      S:       o_regWriteDataSel = '1; // Doesn't matter.
      R:       o_regWriteDataSel = '0; // Select the output from the ALU.
      B:       o_regWriteDataSel = '0; // Doesn't matter.
      default: o_regWriteDataSel = 'x;
    endcase

  endmodule

`resetall
