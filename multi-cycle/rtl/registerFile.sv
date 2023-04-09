`default_nettype none

module registerFile
  ( input  var logic        i_clk

  , input  var logic [4:0]  i_readAddress1
  , input  var logic [4:0]  i_readAddress2

  , input  var logic        i_writeEnable
  , input  var logic [4:0]  i_writeAddress
  , input  var logic [31:0] i_writeData

  , output var logic [31:0] o_readData1
  , output var logic [31:0] o_readData2
  );

  logic [31:0] registerFile [31:0]; // Should be stored on SRAM.

  // TODO: Check if synth tools inerpret 'always_ff' as DFF or memory blocks.
  // No need of explicit else statement for memory blocks.
  always_ff @(posedge i_clk)
    if (i_writeEnable)
      registerFile[i_writeAddress] <= i_writeData;

  // x0 has been hardwired to 32'h0.
  always_comb o_readData1 = (i_readAddress1 != '0) ? registerFile[i_readAddress1] : '0;
  always_comb o_readData2 = (i_readAddress2 != '0) ? registerFile[i_readAddress2] : '0;

endmodule

`resetall
