`default_nettype none

import pa_riscv::*;

module singleCycleTop_elaborated
  ( input var logic i_clk
  , input var logic i_srst
  );

  logic [31:0] pc;

  logic [31:0] instruction;

  logic [6:0]  operand;
  logic [11:0] immediate;
  logic [4:0]  rs1;
  logic [4:0]  rs2;
  logic [4:0]  rd;
  logic [6:0]  funct7;
  logic [2:0]  funct3;

  // Extract fields from instruction.
  always_comb operand = instruction[6:0];
  always_comb rs1     = instruction[19:15];
  always_comb rs2     = instruction[24:20];
  always_comb rd      = instruction[11:7];
  always_comb funct3  = instruction[14:12];
  always_comb funct7  = instruction[31:25];

  // {{{ Main controller
  // Decode the operand to determine the state elements and ALU control signals.

  logic       regWriteEn;
  logic       memWriteEn;
  logic       aluInputBSel;
  logic [3:0] aluLogicOperation;
  logic       regWriteDataSel;

  controller u_controller
  ( .i_operand           (operand)
  , .i_funct3            (funct3)
  , .i_funct7bit5        (funct7[5])

  , .o_regWriteEn        (regWriteEn)        // Enable write to register file.
  , .o_aluInputBSel      (aluInputBSel)      // Select the ALU input B.
  , .o_aluLogicOperation (aluLogicOperation) // Select the ALU logical operation.
  , .o_memWriteEn        (memWriteEn)        // Enable write to memory write.
  , .o_regWriteDataSel   (regWriteDataSel)   // Select data to write to register file.
  );

  // }}} Main controller

  // {{{ PC

  logic [31:0] nextPc;
  logic [31:0] branchAddress;
  logic        branchCondition;

  // Branch condition is met if there is a branch instruction and the zero flag
  // is asserted.
  always_comb branchCondition = (operand == B) && zeroFlag;

  always_comb nextPc = branchCondition ? branchAddress : pc + 32'h4;

  pc u_pc
  ( .i_clk
  , .i_srst

  , .i_nextPc (nextPc)
  , .o_pc     (pc)
  );

  always_comb branchAddress = pc + immediateExtended;

  // }}} PC

  // {{{ Instruction Memory

  instructionMemory u_instructionMemory
  ( .i_address     (pc)
  , .o_instruction (instruction)
  );

  // }}} Instruction Memory

  // {{{ Extend Immediate

  logic [31:0] immediateExtended;

  // Extract the immediate from the instruction and sign extend to 32 bits.
  // I-Type: immediateExtended is the address offset of the base address from
  //         which data is read from memory.
  // S-Type: immediateExtended is the address offset of the base address to which
  //         data is written to.
  // R-Type: Not used.
  // B-Type: immediateExtended is the value the PC is incremented by to calculate
  //         the new branch address.
  extend u_extend
  ( .i_instruction       (instruction)

  , .o_immediateExtended (immediateExtended)
  );

  // }}} Extend Immediate

  // {{{ Register File

  logic [31:0] baseAddress;
  logic [31:0] regReadData2;
  logic [31:0] regWriteData;

  // Depending on the instruction type, select the data to be written to reg file.
  always_comb regWriteData = regWriteDataSel ? dataFromMemory : dataAddress;

  // I-Type: Find the base address of the data memory stored in rs1 and
  //         write to rd, rd <= mem[rs1 + immediate].
  // S-Type: Find the base address of the data memory stored in rs1 and read rs2
  //         which contains the data to write to memory.
  // R-Type: Read rs1 and rs2 and store the result of the logical/arithmetic
  //         operation on them in rd. rd <= rs1 op rs2.
  // B-Type: Read rs1 and rs2. No write takes place.
  registerFile u_registerFile
  ( .i_clk

  , .i_readAddress1 (rs1)
  , .i_readAddress2 (rs2)

  , .i_writeEnable  (regWriteEn)
  , .i_writeAddress (rd)
  , .i_writeData    (regWriteData)

  , .o_readData1    (baseAddress)
  , .o_readData2    (regReadData2)
  );

  // }}} Register File

  // {{{ ALU

  logic [31:0] dataAddress;
  logic [31:0] aluInputB;
  logic        zeroFlag;

  always_comb aluInputB = aluInputBSel ? immediateExtended : regReadData2;

  // I-Type: Calculate the address of data memory: rs1 + immediate.
  // S-Type: Calculate the address of data memory: rs1 + immediate.
  // R-Type: Perform logical/arithmetic operation: rs1 op rs2
  // B-Type: Subtract, rs1 - rs2 to determine if equal. Result is not used.
  alu u_alu
  ( .i_a                 (baseAddress)
  , .i_b                 (aluInputB)
  , .i_aluLogicOperation (aluLogicOperation)

  , .o_result            (dataAddress)

  , .o_zeroFlag           (zeroFlag)
  );

  // }}} ALU

  // {{{ Data Memory

  logic [31:0] dataFromMemory;

  // I-Type: Output data stored in location: mem[rs1 + immediate]
  // S-Type: Store data in memory location given by rs2 <= mem[rs1 + immediate].
  // R-Type: No data gets stored in memory.
  // B-Type: No data gets stored in memory. Read data is ignored.
  dataMemory u_dataMemory
  ( .i_clk

  , .i_rwAddress   (dataAddress)

  , .i_writeEnable (memWriteEn)
  , .i_writeData   (regReadData2)

  , .o_readData    (dataFromMemory)
  );

  // }}} Data Memory

endmodule

`resetall
