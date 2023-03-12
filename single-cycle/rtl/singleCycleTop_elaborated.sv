`default_nettype none

module singleCycleTop_elaborated
  ( input var logic i_clk
  , input var logic i_srst
  );

  // {{{ Main controller
  // Decode the operand to determine the state elements and ALU control signals.

  logic       registerWrite;
  logic       memoryWrite;
  logic [1:0] aluControl;
  logic [1:0] immediateSelect;

  controller u_controller
  ( .i_operand         (operand)

  , .o_regWrite        (regWrite)        // Write to register file.
  , .o_immediateSelect (immediateSelect) // Extract immediate bits of instruction.
  , .o_aluControl      (aluControl)      // ALU logical operation.
  , .o_memWrite        (memWrite)        // Write to memory.
  );

  // }}} Main controller

  // {{{ PC

  logic [31:0] pc, nextPc;

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

  logic [31:0] instruction;

  instructionMemory u_instructionMemory
  ( .i_address     (pc)
  , .o_instruction (instruction)
  );

  // }}} Instruction Memory

  logic [11:0] immediate;
  logic [4:0]  rs1;
  logic [4:0]  rd;

  logic [31:0] addressOffset;

  logic [31:0] baseAddress;
  logic [31:0] dataFromMemory;
  logic [31:0] dataToMemory;

  logic [31:0] dataAddress;

  // Extract fields from instruction.
  always_comb operand = instruction[6:0];
  always_comb rs1     = instruction[19:15];
  always_comb rs2     = instruction[24:20];
  always_comb rd      = instruction[11:7];

  // Extract the immediate from the instruction and sign extend to 32 bits.
  extend u_extend
  ( .i_instruction       (instruction)
    .i_immediateSelect   (immediateSelect)
  , .o_immediateExtended (addressOffset)
  );

  // I-Type: Find the base address of the data memory stored in rs1 and
  //         write to rd, rd <= mem[rs1 + immediate].
  // S-Type: Find the base address of the data memory stored in rs1 and read rs2
  //         which contains the data to write to memory.
  registerFile u_registerFile
  ( .i_clk

  , .i_readAddress1 (rs1)
  , .i_readAddress2 (rs2)

  , .i_writeEnable  (regWrite)
  , .i_writeAddress (rd)
  , .i_writeData    (dataFromMemory)

  , .o_readData1    (baseAddress)
  , .o_readData2    (dataToMemory)
  );

  // I-Type: Calculate the base address of data memory: rs1 + immediate.
  alu u_alu
  ( .i_a          (baseAddress)
  , .i_b          (addressOffset)

  , .i_aluControl (aluControl)

  , .o_result     (dataAddress)
  );

  // {{{ Data Memory

  // I-Type: Output data stored in location: mem[rs1 + immediate]
  // S-Type: Store data in memory location given by rs2 <= mem[rs1 + immediate].
  dataMemory u_dataMemory
  ( .i_clk

  , .i_rwAddress   (dataAddress)

  , .i_writeEnable (memWrite)
  , .i_writeData   (dataToMemory)

  , .o_readData    (dataFromMemory)
  );

  // }}} Data Memory

endmodule

`resetall
