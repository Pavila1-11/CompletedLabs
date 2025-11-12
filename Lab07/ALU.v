`timescale 1ns / 1ps

// Operation codes (unchanged)
`define AND   4'b0000
`define OR    4'b0001
`define ADD   4'b0010
`define SUB   4'b0110
`define PassB 4'b0111

// ALU: Pure combinational. Zero flag asserted when result is 0.
module ALU(
    output reg [63:0] BusW,
    input      [63:0] BusA,
    input      [63:0] BusB,
    input      [3:0]  ALUCtrl,
    output            Zero
);

    // Local wires for each candidate result (precompute, style choice)
    wire [63:0] res_and   = BusA & BusB;
    wire [63:0] res_or    = BusA | BusB;
    wire [63:0] res_add   = BusA + BusB;
    wire [63:0] res_sub   = BusA - BusB;
    wire [63:0] res_passB = BusB;

    // Use priority case (same functionality)
    always @(*) begin
        BusW = 64'b0; // default
        case (ALUCtrl)
            `AND:   BusW = res_and;
            `OR:    BusW = res_or;
            `ADD:   BusW = res_add;
            `SUB:   BusW = res_sub;
            `PassB: BusW = res_passB;
            default: BusW = 64'b0;
        endcase
    end

    assign Zero = (BusW == 64'd0);

endmodule
