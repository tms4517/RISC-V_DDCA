`default_nettype none

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

  logic       regWrite;
  logic       memWrite;
  logic       aluInputBSel;
  logic [3:0] aluLogicOperation;

  controller u_controller
  ( .i_operand           (operand)
  , .i_funct3            (funct3)
  , .i_funct7bit5        (funct7[5])

  , .o_regWrite          (regWrite)          // Write to register file.
  , .o_aluInputBSel      (aluInputBSel)      // Select the ALU input B.
  , .o_aluLogicOperation (aluLogicOperation) // Select the ALU logical operation.
  , .o_memWrite          (memWrite)          // Write to memory.
  );

  // }}} Main controller

  // {{{ PC

  logic [31:0] nextPc;

  // Next address in the instruction memory.
  always_comb nextPc = pc + 32'h4;

  pc u_pc
  ( .i_clk
  , .i_srst

  , .i_nextPc (nextPc)
  , .o_pc     (pc)
  );

  // }}} PC

  // {{{ Instruction Memory

  instructionMemory u_instructionMemory
  ( .i_address     (pc)
  , .o_instruction (instruction)
  );

  // }}} Instruction Memory

  // {{{ Extend Immediate

  logic [31:0] addressOffset;

  // Extract the immediate from the instruction and sign extend to 32 bits.
  extend u_extend
  ( .i_instruction       (instruction)

  , .o_immediateExtended (addressOffset)
  );

  // }}} Extend Immediate

  // {{{ Register File

  logic [31:0] baseAddress;
  logic [31:0] regReadData2;

  // I-Type: Find the base address of the data memory stored in rs1 and
  //         write to rd, rd <= mem[rs1 + immediate].
  // S-Type: Find the base address of the data memory stored in rs1 and read rs2
  //         which contains the data to write to memory.
  // R-Type: Read rs1 and rs2 and store the result of the logical/arithmetic
  //         operation on them in rd. rd <= rs1 op rs2.
  registerFile u_registerFile
  ( .i_clk

  , .i_readAddress1 (rs1)
  , .i_readAddress2 (rs2)

  , .i_writeEnable  (regWrite)
  , .i_writeAddress (rd)
  , .i_writeData    (dataFromMemory)

  , .o_readData1    (baseAddress)
  , .o_readData2    (regReadData2)
  );

  // }}} Register File

  // {{{ ALU

  logic [31:0] dataAddress;
  logic [31:0] aluInputB;

  always_comb aluInputB = aluInputBSel ? addressOffset : regReadData2;

  // I-Type: Calculate the base address of data memory: rs1 + immediate.
  // R-Type: Perform logical/arithmetic operation: rs1 op rs2
  alu u_alu
  ( .i_a                 (baseAddress)
  , .i_b                 (aluInputB)

  , .i_aluLogicOperation (aluLogicOperation)

  , .o_result            (dataAddress)
  );

  // }}} ALU

  // {{{ Data Memory

  logic [31:0] dataFromMemory;

  // I-Type: Output data stored in location: mem[rs1 + immediate]
  // S-Type: Store data in memory location given by rs2 <= mem[rs1 + immediate].
  dataMemory u_dataMemory
  ( .i_clk

  , .i_rwAddress   (dataAddress)

  , .i_writeEnable (memWrite)
  , .i_writeData   (regReadData2)

  , .o_readData    (dataFromMemory)
  );

  // }}} Data Memory

endmodule

`resetall
