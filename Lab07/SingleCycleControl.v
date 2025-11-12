`timescale 1ns / 1ps

`define OPCODE_ANDREG 11'b10001010000
`define OPCODE_ORRREG 11'b10101010000
`define OPCODE_ADDREG 11'b10001011000
`define OPCODE_SUBREG 11'b11001011000
`define OPCODE_ADDIMM 11'b1001000100?
`define OPCODE_SUBIMM 11'b1101000100?
`define OPCODE_MOVZ   11'b110100101??  // Move wide with zero (64-bit)
`define OPCODE_B      11'b000101?????
`define OPCODE_CBZ    11'b10110100???
`define OPCODE_LDUR   11'b11111000010
`define OPCODE_STUR   11'b11111000000

// Adds a 1-bit MovZ control so the SignExtender can select the MOVZ path.
// Rest of the control behavior is unchanged.
module SC_Control(
    output reg       Reg2Loc,
    output reg       ALUSrc,
    output reg       MemtoReg,
    output reg       RegWrite,
    output reg       MemRead,
    output reg       MemWrite,
    output reg       Branch,
    output reg       Uncondbranch,
    output reg [3:0] ALUOp,
    output reg [1:0] SignOp,
    output reg       MovZ,         // NEW: asserted only for MOVZ
    input      [10:0] opcode
);

    always @(*) begin
        // Defaults (NOP)
        Reg2Loc      = 1'b0;
        ALUSrc       = 1'b0;
        MemtoReg     = 1'b0;
        RegWrite     = 1'b0;
        MemRead      = 1'b0;
        MemWrite     = 1'b0;
        Branch       = 1'b0;
        Uncondbranch = 1'b0;
        ALUOp        = 4'b0000;
        SignOp       = 2'b00;
        MovZ         = 1'b0;

        casez (opcode)
            // R-format
            `OPCODE_ADDREG: begin RegWrite=1; ALUOp=4'b0010; end
            `OPCODE_SUBREG: begin RegWrite=1; ALUOp=4'b0110; end
            `OPCODE_ANDREG: begin RegWrite=1; ALUOp=4'b0000; end
            `OPCODE_ORRREG: begin RegWrite=1; ALUOp=4'b0001; end

            // I-format
            `OPCODE_ADDIMM: begin RegWrite=1; ALUSrc=1; ALUOp=4'b0010; SignOp=2'b00; end
            `OPCODE_SUBIMM: begin RegWrite=1; ALUSrc=1; ALUOp=4'b0110; SignOp=2'b00; end

            // D-format
            `OPCODE_LDUR: begin
                RegWrite=1; ALUSrc=1; MemtoReg=1; MemRead=1; ALUOp=4'b0010; SignOp=2'b01;
            end
            `OPCODE_STUR: begin
                Reg2Loc=1; ALUSrc=1; MemWrite=1; ALUOp=4'b0010; SignOp=2'b01;
            end

            // CBZ
            `OPCODE_CBZ: begin
                Reg2Loc=1; Branch=1; ALUOp=4'b0111; SignOp=2'b10;
            end

            // B (unconditional)
            `OPCODE_B: begin
                Uncondbranch=1; SignOp=2'b11;
            end

            // MOVZ
            `OPCODE_MOVZ: begin
                RegWrite=1; ALUSrc=1; ALUOp=4'b0111; // pass B
                MovZ=1; // select MOVZ path in SignExtender
                SignOp=2'b00; // ignored when MovZ=1
            end

            default: ; // keep defaults
        endcase
    end
endmodule


