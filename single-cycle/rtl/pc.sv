`default_nettype none

module pc
  ( input  var logic        i_clk
  , input  var logic        i_srst

  , input  var logic [31:0] i_nextPc

  , output var logic [31:0] o_pc
  );

  logic [31:0] pc_q, pc_d;

  always_comb pc_d = i_nextPc;
  always_comb o_pc = pc_q;

  // Increment the PC value at every clock cycle so that it points to
  // the next address in the instuction memory.
  always_ff @(posedge i_clk)
    if (i_srst)
      pc_q <= 32'h1000; // As defined in the Sample program, Figure 7.2 of DDCA.
    else
      pc_q <= pc_d;

endmodule

`resetall
