`default_nettype none

module pc
  ( input  var logic        i_clk
  , input  var logic        i_srst

  , input  var logic [31:0] i_nextPc
  , input  var logic        pcWriteEn

  , output var logic [31:0] o_pc
  );

  logic [31:0] pc_q, pc_d;

  always_comb pc_d = i_nextPc;
  always_comb o_pc = pc_q;

  // Increment the PC value at every clock cycle so that it points to
  // the next address in the instuction memory.
  always_ff @(posedge i_clk)
    if (i_srst)
      pc_q <= '0; // Set to 0 initially to be in accordance with Tb.
    else if (pcWriteEn)
      pc_q <= pc_d;
    else
      pc_q <= pc_q;

endmodule

`resetall
