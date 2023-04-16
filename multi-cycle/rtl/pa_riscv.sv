`ifndef PA_RISCV
  `define PA_RISCV

`default_nettype none

package pa_riscv;

  // Decode operand.
  typedef enum logic [6:0]
  { LW         = 7'b0000011
  , I_TYPE_ALU = 7'b0010011
  , SW         = 7'b0100011
  , R_TYPE_ALU = 7'b0110011
  , B_TYPE     = 7'b1100011
  , JAL        = 7'b1101111
  } ty_OPERAND;

  // Alu operations {funct7b5, funct3}.
  typedef enum logic [3:0]
  { ADD = 4'b0000
  , SLT = 4'b0010
  , XOR = 4'b0100
  , OR  = 4'b0110
  , AND = 4'b0111
  , SUB = 4'b1000
  } ty_ALU_OP;

  // Select input to the write data port of the ALU.
  typedef enum logic [1:0]
  { ALU        = 2'b00
  , DATAMEMORY = 2'b01
  , PCPLUS4    = 2'b10
  } ty_INPUT_TO_WRITEDATA;

  // Select ALU input A.
  typedef enum logic [1:0]
  { PC              = 2'b00
  , OTHER           = 2'b01
  , REG_READ_DATA_1 = 2'b10
  } ty_INPUT_TO_WRITEDATA;

  // Select ALU input B.
  typedef enum logic [1:0]
  { REG_READ_DATA_2    = 2'b00
  , IMMEDIATE_EXTENDED = 2'b01
  , FOUR               = 2'b10
  } ty_INPUT_TO_WRITEDATA;

endpackage

`resetall

`endif
