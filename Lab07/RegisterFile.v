`timescale 1ns / 1ps

module RegisterFile(
    output wire [63:0] BusA,
    output wire [63:0] BusB,
    input  wire [63:0] BusW,
    input  wire [4:0]  RA,
    input  wire [4:0]  RB,
    input  wire [4:0]  RW,
    input  wire        RegWr,
    input  wire        Clk
);

  reg [63:0] rf [31:0];
  integer i;
  initial begin
    for (i = 0; i < 32; i = i + 1)
      rf[i] = 64'd0;
  end

  always @(posedge Clk) begin
    if (RegWr && RW != 5'd31)
      rf[RW] <= BusW;
  end

  reg [63:0] a_next, b_next;
  always @* begin
    a_next = (RA == 5'd31) ? 64'd0 : rf[RA];
    b_next = (RB == 5'd31) ? 64'd0 : rf[RB];

    // Break combinational loop with tiny delay on bypass
    if (RegWr && RW == RA && RW != 5'd31) a_next = #1 BusW;
    if (RegWr && RW == RB && RW != 5'd31) b_next = #1 BusW;
  end

  assign BusA = a_next;
  assign BusB = b_next;

endmodule


