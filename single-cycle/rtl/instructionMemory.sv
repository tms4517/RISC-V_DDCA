`default_nettype none

module instructionMemory
  ( input  var logic [31:0] i_address

  , output var logic [31:0] o_instruction
  );

  // Declares a memory array of 64 32-bit elements.
  logic [31:0] RAM [63:0];

  // Read and load data from a specified text file into the specified memory array.
  // Executes only once at the start of the simulation.
  initial $readmemh("riscvtest.txt", RAM);

  // Read word at the specific address. Only the first 8 bits are useful since
  // 4*64 = 256 (0x100). Also, the address should be aligned, i.e a multiple of
  // 0x4 since each memory element stores 32 bits rather than 8 bits.
  always_comb o_instruction = RAM[i_address[7:2]];

endmodule

`resetall
