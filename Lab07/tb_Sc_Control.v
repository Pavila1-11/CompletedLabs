`timescale 1ns/1ps

// Updated control-unit testbench: checks MOVZ also asserts MovZ=1.
module SC_Control_tb;

    // Outputs
    wire       Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Uncondbranch;
    wire [3:0] ALUOp;
    wire [1:0] SignOp;
    wire       MovZ;

    // Input
    reg  [10:0] opcode;

    integer test_count, pass_count, fail_count;
    integer i;

    SC_Control uut(
        .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite),
        .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Uncondbranch(Uncondbranch),
        .ALUOp(ALUOp), .SignOp(SignOp), .MovZ(MovZ), .opcode(opcode)
    );

    task check_output;
        input [10:0] test_opcode;
        input [127:0] name;
        input exp_Reg2Loc, exp_ALUSrc, exp_MemtoReg, exp_RegWrite, exp_MemRead, exp_MemWrite;
        input exp_Branch, exp_Uncondbranch;
        input [3:0] exp_ALUOp;
        input [1:0] exp_SignOp;
        input       exp_MovZ;
        begin
            opcode = test_opcode; #1;
            test_count = test_count + 1;
            if (Reg2Loc!==exp_Reg2Loc || ALUSrc!==exp_ALUSrc ||
                MemtoReg!==exp_MemtoReg || RegWrite!==exp_RegWrite ||
                MemRead!==exp_MemRead || MemWrite!==exp_MemWrite ||
                Branch!==exp_Branch || Uncondbranch!==exp_Uncondbranch ||
                ALUOp!==exp_ALUOp || SignOp!==exp_SignOp || MovZ!==exp_MovZ) begin
                $display("ERROR T%0d: %s opcode=%b", test_count, name, test_opcode);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS  T%0d: %s", test_count, name);
                pass_count = pass_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("SC_Control_tb.vcd");
        $dumpvars(0, SC_Control_tb);

        test_count=0; pass_count=0; fail_count=0;

 // R-format
        check_output(11'b10001010000,"AND",0,0,0,1,0,0,0,0,4'b0000,2'b00,0);
        check_output(11'b10101010000,"ORR",0,0,0,1,0,0,0,0,4'b0001,2'b00,0);
        check_output(11'b10001011000,"ADD",0,0,0,1,0,0,0,0,4'b0010,2'b00,0);
        check_output(11'b11001011000,"SUB",0,0,0,1,0,0,0,0,4'b0110,2'b00,0);

        // I-format
        for (i=0;i<2;i=i+1) check_output(11'b10010001000|i,"ADDIMM",0,1,0,1,0,0,0,0,4'b0010,2'b00,0);
        for (i=0;i<2;i=i+1) check_output(11'b11010001000|i,"SUBIMM",0,1,0,1,0,0,0,0,4'b0110,2'b00,0);

        // MOVZ (4 variants)
        for (i=0;i<4;i=i+1) check_output(11'b11010010100|i,"MOVZ",0,1,0,1,0,0,0,0,4'b0111,2'b00,1);

        // B (32 variants)
        for (i=0;i<32;i=i+1) check_output(11'b00010100000|i,"B",0,0,0,0,0,0,0,1,4'b0000,2'b11,0);

        // CBZ (8 variants)
        for (i=0;i<8;i=i+1) check_output(11'b10110100000|i,"CBZ",1,0,0,0,0,0,1,0,4'b0111,2'b10,0);

        // LDUR/STUR
        check_output(11'b11111000010,"LDUR",0,1,1,1,1,0,0,0,4'b0010,2'b01,0);
        check_output(11'b11111000000,"STUR",1,1,0,0,0,1,0,0,4'b0010,2'b01,0);

        // Undefined samples
        check_output(11'b00000000000,"UNDEF",0,0,0,0,0,0,0,0,4'b0000,2'b00,0);
        check_output(11'b11111111111,"UNDEF",0,0,0,0,0,0,0,0,4'b0000,2'b00,0);

        $display("=== Summary: Total=%0d Pass=%0d Fail=%0d ===", test_count, pass_count, fail_count);
        if (fail_count==0) $display("ALL TESTS PASSED"); else $display("SOME TESTS FAILED");
        $finish;
    end
endmodule

