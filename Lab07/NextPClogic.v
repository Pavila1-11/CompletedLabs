
`timescale 1ns / 1ps

// Computes next PC: branch (cond + zero) or uncond, otherwise +4.
module NextPClogic(
    output reg [63:0] NextPC,
    input      [63:0] CurrentPC,
    input      [63:0] SignExtImm64,
    input             Branch,
    input             ALUZero,
    input             Uncondbranch
);

    wire take_cond_branch  = Branch && ALUZero;
    wire take_any_branch   = Uncondbranch || take_cond_branch;
    wire [63:0] branch_off = SignExtImm64;
    wire [63:0] seq_off    = 64'd4;

    always @(*) begin
        NextPC = CurrentPC + (take_any_branch ? branch_off : seq_off);
    end

endmodule




