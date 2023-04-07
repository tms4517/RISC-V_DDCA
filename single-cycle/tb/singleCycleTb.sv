// # Test the RISC-V processor.
// #  add, sub, and, or, slt, addi, lw, sw, beq, jal
// # If successful, it should write the value 25 to address 100

// #       RISC-V Assembly         Description               Address   Machine Code
// main:   addi x2, x0, 5          # x2 = 5                  0         00500113
//         addi x3, x0, 12         # x3 = 12                 4         00C00193
//         addi x7, x3, -9         # x7 = (12 - 9) = 3       8         FF718393
//         or   x4, x7, x2         # x4 = (3 OR 5) = 7       C         0023E233
//         and  x5, x3, x4         # x5 = (12 AND 7) = 4     10        0041F2B3
//         add  x5, x5, x4         # x5 = (4 + 7) = 11       14        004282B3
//         beq  x5, x7, end        # shouldn't be taken      18        02728863
//         slt  x4, x3, x4         # x4 = (12 < 7) = 0       1C        0041A233
//         beq  x4, x0, around     # should be taken         20        00020463
//         addi x5, x0, 0          # shouldn't happen        24        00000293
// around: slt  x4, x7, x2         # x4 = (3 < 5)  = 1       28        0023A233
//         add  x7, x4, x5         # x7 = (1 + 11) = 12      2C        005203B3
//         sub  x7, x7, x2         # x7 = (12 - 5) = 7       30        402383B3
//         sw   x7, 84(x3)         # [96] = 7                34        0471AA23
//         lw   x2, 96(x0)         # x2 = [96] = 7           38        06002103
//         add  x9, x2, x5         # x9 = (7 + 11) = 18      3C        005104B3
//         jal  x3, end            # jump to end, x3 = 0x44  40        008001EF
//         addi x2, x0, 1          # shouldn't happen        44        00100113
// end:    add  x2, x2, x9         # x2 = (7 + 18)  = 25     48        00910133
//         sw   x2, 0x20(x3)       # mem[100] = 25           4C        0221A023
// done:   beq  x2, x2, done       # infinite loop           50        00210063

`default_nettype none

module testbench();

  logic        clk;
  logic        rst;

  // Initialize test.
  initial
    begin
      rst <= 1;
      # 22;
      rst <= 0;
    end

  // Generate clock to sequence tests.
  always
    begin
      clk <= 1;
      # 5;
      clk <= 0;
      # 5;
    end

  // Instantiate device to be tested.
  singleCycleTop u_dut
  ( .i_clk  (clk)
  , .i_srst (rst)
  );

  // Probe DUT.
  logic memWriteEn;
  logic [31:0] memWriteData;
  logic [31:0] memWriteAddress;

  always_comb memWriteEn      = u_dut.u_dataMemory.i_writeEnable;
  always_comb memWriteData    = u_dut.u_dataMemory.i_writeData;
  always_comb memWriteAddress = u_dut.u_dataMemory.i_rwAddress;

  // Check results.
  always @(negedge clk)
    begin
      if(memWriteEn) begin
        if(memWriteAddress === 100 & memWriteData === 25) begin
          $display("Simulation succeeded");
          $stop;
        end else if (memWriteAddress !== 96) begin
          $display("Simulation failed");
          $stop;
        end
      end
    end
endmodule
