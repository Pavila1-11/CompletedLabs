`timescale 1ns / 1ps

`define Itype   2'b00
`define Dtype   2'b01
`define CBtype  2'b10
`define Btype   2'b11

// Adds a MOVZ path: imm16 = Instruction[20:5], HW = Instruction[22:21], result = zero-extended imm16 << (16*H>
module SignExtender(
    output reg [63:0] SignExOut,
    input      [25:0] Instruction,
    input      [1:0]  SignOp,
    input             MovZ      // NEW
);
    // Existing formats
    wire [11:0] imm12 = Instruction[21:10];
    wire [8:0]  imm9  = Instruction[20:12];
    wire [18:0] imm19 = Instruction[23:5];
    wire [25:0] imm26 = Instruction[25:0];

    wire [63:0] extI  = {52'b0, imm12};
    wire [63:0] extD  = {{55{imm9[8]}}, imm9};
    wire [63:0] extCB = {{43{imm19[18]}}, imm19, 2'b00};
    wire [63:0] extB  = {{36{imm26[25]}}, imm26, 2'b00};

    // MOVZ fields
    wire [15:0] movz_imm16 = Instruction[20:5];
    wire [1:0]  movz_hw    = Instruction[22:21];
    wire [63:0] extMOVZ    = ({{48{1'b0}}, movz_imm16}) << (movz_hw * 16);

    always @(*) begin
        if (MovZ) begin
            SignExOut = extMOVZ;
        end else begin
            case (SignOp)
                `Itype:  SignExOut = extI;
                `Dtype:  SignExOut = extD;
                `CBtype: SignExOut = extCB;
                `Btype:  SignExOut = extB;
                default: SignExOut = 64'b0;
            endcase
        end
    end
endmodule

