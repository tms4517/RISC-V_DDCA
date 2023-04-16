// Single-cycle implementation of RISC-V (RV32I)
// User-level Instruction Set Architecture V2.2
// Implements a subset of the base integer instructions:
//    lw, sw
//    add, sub, and, or, slt,
//    addi, andi, ori, slti
//    beq
//    jal
// Exceptions, traps, and interrupts not implemented
// little-endian memory

// 31 32-bit registers x1-x31, x0 hardwired to 0
// R-Type instructions
//   add, sub, and, or, slt
//   INSTR rd, rs1, rs2
//   Instr[31:25] = funct7 (funct7b5 & opb5 = 1 for sub, 0 for others)
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// I-Type Instructions
//   lw, I-type ALU (addi, andi, ori, slti)
//   lw:         INSTR rd, imm(rs1)
//   I-type ALU: INSTR rd, rs1, imm (12-bit signed)
//   Instr[31:20] = imm[11:0]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode
// S-Type Instruction
//   sw rs2, imm(rs1) (store rs2 into address specified by rs1 + immm)
//   Instr[31:25] = imm[11:5] (offset[11:5])
//   Instr[24:20] = rs2 (src)
//   Instr[19:15] = rs1 (base)
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:0]  (offset[4:0])
//   Instr[6:0]   = opcode
// B-Type Instruction
//   beq rs1, rs2, imm (PCTarget = PC + (signed imm x 2))
//   Instr[31:25] = imm[12], imm[10:5]
//   Instr[24:20] = rs2
//   Instr[19:15] = rs1
//   Instr[14:12] = funct3
//   Instr[11:7]  = imm[4:1], imm[11]
//   Instr[6:0]   = opcode
// J-Type Instruction
//   jal rd, imm  (signed imm is multiplied by 2 and added to PC, rd = PC+4)
//   Instr[31:12] = imm[20], imm[10:1], imm[11], imm[19:12]
//   Instr[11:7]  = rd
//   Instr[6:0]   = opcode

//   Instruction  opcode    funct3    funct7
//   add          0110011   000       0000000
//   sub          0110011   000       0100000
//   and          0110011   111       0000000
//   or           0110011   110       0000000
//   slt          0110011   010       0000000
//   addi         0010011   000       immediate
//   andi         0010011   111       immediate
//   ori          0010011   110       immediate
//   slti         0010011   010       immediate
//   beq          1100011   000       immediate
//   lw	          0000011   010       immediate
//   sw           0100011   010       immediate
//   jal          1101111   immediate immediate

`default_nettype none

import pa_riscv::*;

module singleCycleTop
  ( input var logic i_clk
  , input var logic i_srst
  );

  logic [31:0] pc;

  logic [31:0] instruction;

  logic [6:0]  operand;
  logic [4:0]  rs1;
  logic [4:0]  rs2;
  logic [4:0]  rd;
  logic [6:0]  funct7;
  logic [2:0]  funct3;

  // Extract fields from instruction.
  always_comb operand = instruction_q[6:0];
  always_comb rs1     = instruction_q[19:15];
  always_comb rs2     = instruction_q[24:20];
  always_comb rd      = instruction_q[11:7];
  always_comb funct3  = instruction_q[14:12];
  always_comb funct7  = instruction_q[31:25];

  // {{{ Main controller
  // Decode the operand to determine the state elements and ALU control signals.

  logic       regWriteEn;
  logic       memWriteEn;
  logic       aluInputASel;
  logic       aluInputBSel;
  logic [3:0] aluLogicOperation;
  logic [1:0] regWriteDataSel;
  logic       branchCondition;
  logic       jump;

  controller u_controller
  ( .i_operand           (operand)
  , .i_funct3            (funct3)
  , .i_funct7bit5        (funct7[5])

  , .i_zeroFlag          (zeroFlag)

  , .o_branchCondition   (branchCondition)
  , .o_regWriteEn        (regWriteEn)        // Enable write to register file.
  , .o_aluInputBSel      (aluInputBSel)      // Select the ALU input B.
  , .o_aluLogicOperation (aluLogicOperation) // Select the ALU logical operation.
  , .o_memWriteEn        (memWriteEn)        // Enable write to memory write.
  , .o_regWriteDataSel   (regWriteDataSel)   // Select data to write to register file.
  );

  // }}} Main controller

  // {{{ PC

  logic [31:0] nextPc;
  logic [31:0] pcTarget;
  logic [31:0] pcPlus4;

  always_comb pcPlus4 = pc + 32'h4;

  always_comb pcTarget = pc + immediateExtended;

  always_comb nextPc = (branchCondition || (operand == JAL)) ?
                        pcTarget : pcPlus4;

  pc u_pc
  ( .i_clk
  , .i_srst

  , .i_nextPc (nextPc)
  , .o_pc     (pc)
  );

  // }}} PC

  // {{{ Instruction and Data Memory

  logic addressSrc;
  logic [31:0] instructionOrDataAddress;

  // MUX to decode address input to instructionAndDataMemory.
  always_comb instructionOrDataAddress = addressSrc ? aluOutput_q : pc;

  instructionAndDataMemory u_instructionAndDataMemory
  ( .i_clk

  , .i_rwAddress                (instructionOrDataAddress)

  , .i_writeEnable              ()
  , .i_writeData                ()

  , .o_readDataOrInstruction    ()
  );

  logic [31:0] instruction_d, instruction_q;
  logic instructionRegWrite;

  // Store the instruction so that it is available in future cycles and to break
  // critical timing path.
  always_ff @(posedge i_clk)
    if (i_srst)
      instruction_q <= '0;
    else if (instructionRegWrite)
      instruction_q <= instruction_d;
    else
      instruction_q <= instruction_q;

  logic [31:0] data_d, data_q;

  // Store the data so that it is available in future cycles and to break
  // critical timing path.
  always_ff @(posedge i_clk)
    if (i_srst)
      data_q <= '0;
    else
      data_q <= data_d;

  // }}} Instruction and Data Memory

  // {{{ Extend Immediate

  logic [31:0] immediateExtended;

  // Extract the immediate from the instruction and sign extend to 32 bits.
  // LW:         immediateExtended is the address offset of the base address from
  //             which data is read from memory.
  // SW:         immediateExtended is the address offset of the base address to
  //             which data is written to.
  // R-Type ALU: Not used.
  // B-Type:     immediateExtended is the value the PC is incremented by to
  //             calculate the new branch address.
  // I-Type ALU: immediateExtended is the second input to the ALU.
  // JAL:        immediateExtended is added to the PC to get the jump address.
  extend u_extend
  ( .i_instruction       (instruction_q)

  , .o_immediateExtended (immediateExtended)
  );

  // }}} Extend Immediate

  // {{{ Register File

  logic [31:0] regReadData1_d, regReadData1_q;
  logic [31:0] regReadData2;
  logic [31:0] regWriteData;

  // Depending on the instruction, select the data to be written to reg file.
  always_comb
    case (regWriteDataSel)
      DATAMEMORY: regWriteData = data_q;
      ALU:        regWriteData = aluOutput;
      PCPLUS4:    regWriteData = pcPlus4;
      default:    regWriteData = 'x;
    endcase

  // LW:         Read the base address of the data memory stored in rs1 and
  //             write to rd, rd <= mem[rs1 + immediate].
  // SW:         Read the base address of the data memory stored in rs1 and read
  //             rs2 which contains the data to write to memory.
  // R-Type ALU: Read rs1 and rs2 and store the result of the logical/arithmetic
  //             operation on them in rd. rd <= rs1 op rs2.
  // B-Type:     Read rs1 and rs2. No write takes place.
  // I-Type ALU: A logical operation is performed on the data read from rs1 and
  //             the immediate. The result is stored in rd. rs2 output is not used.
  // JAL:        Store the link address in rd. rd <= pc + 4.
  registerFile u_registerFile
  ( .i_clk

  , .i_readAddress1 (rs1)
  , .i_readAddress2 (rs2)

  , .i_writeEnable  (regWriteEn)
  , .i_writeAddress (rd)
  , .i_writeData    (regWriteData)

  , .o_readData1    (regReadData1_d)
  , .o_readData2    (regReadData2)
  );

  // Store RD1 in a register to break critical timing path.
  always_ff @(posedge i_clk)
    if (i_srst)
      regReadData1_q <= '0;
    else
      regReadData1_q <= regReadData1_d;

  // }}} Register File

  // {{{ ALU

  logic [31:0] aluOutput_d, aluOutput_q;
  logic [31:0] aluInputA;
  logic [31:0] aluInputB;
  logic        zeroFlag;

  // MUX to select ALU input A.
  always_comb
    case (aluInputASel)
      PC:              aluInputA = pc;
      OTHER:           aluInputA = ;
      REG_READ_DATA_1: aluInputA = regReadData1_q;
      default:         aluInputA = 'x;
    endcase

  // MUX to select ALU input B.
  always_comb
    case (aluInputBSel)
      OTHER:              aluInputB = ;
      IMMEDIATE_EXTENDED: aluInputB = immediateExtended;
      FOUR:               aluInputB = 4;
      default:            aluInputB = 'x;
    endcase

  // LW:         Calculate the data memory address:
  //             base address (rs1) + address offset (immediate).
  // SW:         Calculate the data memory address:
  //             base address (rs1) + address offset (immediate).
  // R-Type ALU: Perform logical/arithmetic operation: rs1 op rs2
  // B-Type:     Subtract, rs1 - rs2 to determine if equal. Result is not used.
  // I-Type ALU: Perform logical/arithmetic operation: rs1 op immediate
  // JAL:        No operation takes place.
  alu u_alu
  ( .i_a                 (aluInputA)
  , .i_b                 (aluInputB)
  , .i_aluLogicOperation (aluLogicOperation)

  , .o_result            (aluOutput_d)

  , .o_zeroFlag          (zeroFlag)
  );

  // Store ALU output in a register to break critical timing path.
  always_ff @(posedge i_clk)
    if (i_srst)
      aluOutput_q <= '0;
    else
      aluOutput_q <= aluOutput_d;

  // }}} ALU

endmodule

`resetall
