`default_nettype none

import pa_riscv::*;

module controller
  ( input  var logic [6:0] i_operand
  , input  var logic [2:0] i_funct3
  , input  var logic       i_funct7bit5

  , input  var logic       i_zeroFlag

  , output var logic       o_branchCondition
  , output var logic       o_regWriteEn
  , output var logic       o_aluInputBSel
  , output var logic [3:0] o_aluLogicOperation
  , output var logic       o_memWriteEn
  , output var logic [1:0] o_regWriteDataSel
  );

  // Branch condition is met if there is a branch instruction and the zero flag
  // is asserted.
  always_comb o_branchCondition = (i_operand == B_TYPE) && i_zeroFlag;

  // Decode operand to determine if the instruction involves a register write.
  always_comb
    case (i_operand)
      LW:         o_regWriteEn = '1;
      I_TYPE_ALU: o_regWriteEn = '1;
      JAL:        o_regWriteEn = '1;
      R_TYPE_ALU: o_regWriteEn = '1;
      SW:         o_regWriteEn = '0;
      B_TYPE:     o_regWriteEn = '0;
      default:    o_regWriteEn = 'x;
    endcase

  // Decode operand to determine the input of the ALU i_b port.
  // 1 -> Select o_immediateExtended from extend module.
  // 0 -> Select o_readData2 from register file.
  always_comb
    case (i_operand)
      LW:         o_aluInputBSel = '1;
      SW:         o_aluInputBSel = '1;
      I_TYPE_ALU: o_aluInputBSel = '1;
      R_TYPE_ALU: o_aluInputBSel = '0;
      B_TYPE:     o_aluInputBSel = '0;
      JAL:        o_aluInputBSel = '0;
      default:    o_aluInputBSel = 'x;
    endcase

  logic [3:0] rTypeOperation;
  logic [3:0] iTypeOperation;

  // Bit 5 of funct7 and funct3 are used for R-Type instructions to determine
  // the operation.
  always_comb rTypeOperation = {i_funct7bit5, i_funct3};

  // Only funct3 is used for I-Type ALU instructions to determine the operation.
  always_comb iTypeOperation = {1'b0, i_funct3};

  // Decode operand to determine the logical operation performed by the ALU for
  // the instruction.
  always_comb
    case (i_operand)
      LW:         o_aluLogicOperation = ADD;
      SW:         o_aluLogicOperation = ADD;
      JAL:        o_aluLogicOperation = ADD;
      B_TYPE:     o_aluLogicOperation = SUB;
      R_TYPE_ALU: o_aluLogicOperation = rTypeOperation;
      I_TYPE_ALU: o_aluLogicOperation = iTypeOperation;
      default:    o_aluLogicOperation = 4'bxxxx;
    endcase

  // Decode operand to determine if the instruction involves a memory write.
  always_comb
    case (i_operand)
      SW:         o_memWriteEn = '1;
      LW:         o_memWriteEn = '0;
      R_TYPE_ALU: o_memWriteEn = '0;
      B_TYPE:     o_memWriteEn = '0;
      I_TYPE_ALU: o_memWriteEn = '0;
      JAL:        o_memWriteEn = '0;
      default:    o_memWriteEn = 'x;
    endcase

  // Decode operand to determine if the input to the write data port of the
  // register file should come from the data memory or output from the ALU.
  always_comb
    case (i_operand)
      LW:         o_regWriteDataSel = DATAMEMORY;
      SW:         o_regWriteDataSel = DATAMEMORY;
      R_TYPE_ALU: o_regWriteDataSel = ALU;
      B_TYPE:     o_regWriteDataSel = ALU;
      I_TYPE_ALU: o_regWriteDataSel = ALU;
      JAL:        o_regWriteDataSel = PCPLUS4;
      default:    o_regWriteDataSel = 'x;
    endcase

  endmodule

`resetall
