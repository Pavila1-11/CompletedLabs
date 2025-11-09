module mux2to1_8 (
    input  wire [7:0] in0,   // Input 0
    input  wire [7:0] in1,   // Input 1
    input  wire       sel,   // Select signal
    output reg  [7:0] out    // Output
);

// This combinational block runs whenever an input (in0, in1, sel) changes.
always @(*) begin
    // If the select line is high, pass input 1 to the output.
    if (sel == 1'b1) begin
        out = in1;
    end
    // Otherwise, pass input 0 to the output.
    else begin
        out = in0;
    end
end

endmodule
