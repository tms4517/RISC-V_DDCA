`default_nettype none

module dataMemory
  ( input  var logic        i_clk

  , input  var logic [31:0] i_rwAddress

  , input  var logic        i_writeEnable
  , input  var logic [31:0] i_writeData

  , output var logic [31:0] o_readData
  );

  // A memory array of 64 32-bit elements.
  logic [31:0] RAM [63:0];

  // Write data to the specific address. Only the first 8 bits are useful since
  // 4*64 = 256 (0x100). Also, the address should be aligned, i.e a multiple of
  // 0x4 since each memory element stores 32 bits rather than 8 bits.
  always_ff @(posedge i_clk)
    if (i_writeEnable)
      RAM[i_rwAddress[7:2]] <= i_writeData;
    else
      RAM[i_rwAddress[7:2]] <= RAM[i_rwAddress[7:2]];

  // Read data from the specific memory address.
  always_comb o_readData = RAM[i_rwAddress[7:2]];

endmodule

`resetall
