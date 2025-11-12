`timescale 1ns / 1ps

// Read-only instruction memory (case-based).
// Program 1: original test (ends at 0x30).
// Program 2: MOVZ + ORR building 0x123456789ABCDEF0 (ends at 0x54).

module InstructionMemory(
    output reg [31:0] Data,
    input      [63:0] Address
);

    always @(*) begin
        case (Address)
            // ===== Program 1 =====
            64'h000: Data = 32'hF84003E9;
            64'h004: Data = 32'hF84083EA;
            64'h008: Data = 32'hF84103EB;
            64'h00C: Data = 32'hF84183EC;
            64'h010: Data = 32'hF84203ED;
            64'h014: Data = 32'hAA0B014A; // ORR X10,X10,X11
            64'h018: Data = 32'h8A0A018C; // AND X12,X12,X10
            64'h01C: Data = 32'hB400008C; // CBZ X12,end
            64'h020: Data = 32'h8B0901AD; // ADD X13,X13,X9
            64'h024: Data = 32'hCB09018C; // SUB X12,X12,X9
            64'h028: Data = 32'h17FFFFFD; // B loop
            64'h02C: Data = 32'hF80203EA; // STUR X10,[XZR,#0x20]
            64'h030: Data = 32'hF84203ED; // LDUR X13,[XZR,#0x20]

            // ===== Program 2 (MOVZ build constant) =====
            // MOVZ X9,  #0xDEF0, LSL #0   (corrected encoding)
            64'h034: Data = 32'hD29BDE09;
            // MOVZ X10, #0x9ABC, LSL #16
            64'h038: Data = 32'hD2B3578A;
            // ORR  X9,  X9, X10
            64'h03C: Data = 32'hAA0A0129;
            // MOVZ X10, #0x5678, LSL #32
            64'h040: Data = 32'hD2CACF0A;
            // ORR  X9,  X9, X10
            64'h044: Data = 32'hAA0A0129;
            // MOVZ X10, #0x1234, LSL #48
            64'h048: Data = 32'hD2E2468A;
            // ORR  X9,  X9, X10
            64'h04C: Data = 32'hAA0A0129;
            // STUR X9,  [XZR,#0x28]
            64'h050: Data = 32'hF80283E9;
            // LDUR X10, [XZR,#0x28]
            64'h054: Data = 32'hF84283EA;

            default: Data = 32'hXXXXXXXX; // undefined
        endcase
    end

endmodule

                                               [ Read 53 li