`timescale 1ns / 1ps

module singlecycle(
    input             reset, // Active High
    input  [63:0]     startpc,
    output reg [63:0] currentpc,
    output [63:0]     MemtoRegOut,
    input             CLK
);
   // Fetch
   wire [63:0] nextpc;
   wire [31:0] instruction;

   // Decode fields
   wire [4:0]  rd     = instruction[4:0];
   wire [4:0]  rm     = instruction[9:5];
   wire [4:0]  rn_sel = instruction[20:16];
   wire [10:0] opcode = instruction[31:21];

   // Control
   wire Reg2Loc, ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, Uncondbranch;
   wire [3:0] ALUop;
   wire [1:0] SignOp;
   wire       MovZ; // NEW

   // Register file
   wire [63:0] regoutA, regoutB;

   // Sign extender
   wire [63:0] extimm;

   // ALU
   wire [63:0] aluin2 = ALUSrc ? extimm : regoutB;
   wire [63:0] aluout;
   wire        zero;

   // Data memory
   wire [63:0] memout;

   // Update PC
   always @(posedge CLK) begin
      if (reset) currentpc <= #3 startpc;
      else       currentpc <= #3 nextpc;
   end

   // Debug (expand view beyond 0x30 so you can see Program 2; adjust limit if desired)
   always @(negedge CLK) begin
      if (currentpc >= 64'h0 && currentpc <= 64'h60)
        $display("  [negedge] PC=%h X9=%h X10=%h X11=%h X12=%h X13=%h BusA=%h BusB=%h ALUOut=%h",
                 currentpc, rf.rf[9], rf.rf[10], rf.rf[11], rf.rf[12], rf.rf[13], regoutA, regoutB, aluout);
   end
// Instruction memory
   InstructionMemory imem(.Data(instruction), .Address(currentpc));

   // Control
   SC_Control SingleCycleControl(
      .Reg2Loc(Reg2Loc), .ALUSrc(ALUSrc), .MemtoReg(MemtoReg), .RegWrite(RegWrite),
      .MemRead(MemRead), .MemWrite(MemWrite), .Branch(Branch), .Uncondbranch(Uncondbranch),
      .ALUOp(ALUop), .SignOp(SignOp), .MovZ(MovZ), .opcode(opcode)
   );

   // Register file (keep instance name rf for your debug prints)
   RegisterFile rf(
      .BusA(regoutA), .BusB(regoutB), .BusW(MemtoRegOut),
      .RA(rm), .RB(Reg2Loc ? rd : rn_sel), .RW(rd),
      .RegWr(RegWrite), .Clk(CLK)
   );

   // Sign extender (now with MovZ)
   SignExtender signext(
      .SignExOut(extimm), .Instruction(instruction[25:0]), .SignOp(SignOp), .MovZ(MovZ)
   );

   // ALU
   ALU alu(.BusW(aluout), .BusA(regoutA), .BusB(aluin2), .ALUCtrl(ALUop), .Zero(zero));

   // Data memory
   DataMemory datamem(
      .ReadData(memout), .Address(aluout), .WriteData(regoutB),
      .MemoryRead(MemRead), .MemoryWrite(MemWrite), .Clock(CLK)
   );

   // Writeback mux
   assign MemtoRegOut = MemtoReg ? memout : aluout;

   // Next PC logic
   NextPClogic nextpclogic(
      .NextPC(nextpc), .CurrentPC(currentpc), .SignExtImm64(extimm),
      .Branch(Branch), .ALUZero(zero), .Uncondbranch(Uncondbranch)
   );
endmodule

