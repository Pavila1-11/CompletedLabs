`timescale 1ns / 1ps

`define STRLEN 32
`define HalfClockPeriod 60
`define ClockPeriod `HalfClockPeriod * 2

module SingleCycleProcTest_v;

   initial begin
      $dumpfile("singlecycle.vcd");
      $dumpvars;
   end

   task passTest;
      input [63:0] actualOut, expectedOut;
      input [`STRLEN*8:0] testType;
      inout [7:0]         passed;
      if(actualOut == expectedOut) begin
         $display ("%s passed", testType); passed = passed + 1;
      end else begin
         $display ("%s failed: 0x%016h should be 0x%016h", testType, actualOut, expectedOut);
      end
   endtask

   task allPassed;
      input [7:0] passed;
      input [7:0] numTests;
      if(passed == numTests) $display ("All tests passed");
      else $display("Some tests failed: %0d of %0d passed", passed, numTests);
   endtask

   // Stimulus
   reg        CLK;
   reg        Reset;
   reg [63:0] startPC;
   reg [7:0]  passed;
   reg [15:0] watchdog;

   // DUT outputs
   wire [63:0] MemtoRegOut;
   wire [63:0] currentPC;

   // DUT
   singlecycle uut (
      .CLK(CLK),
      .reset(Reset),
      .startpc(startPC),
      .currentpc(currentPC),
      .MemtoRegOut(MemtoRegOut)
   );
 // Hold the final Program 2 value captured at PC=0x54
   reg [63:0] p2_last_out;

   initial begin
      // Init
      Reset = 0;
      startPC = 0;
      passed = 0;
      watchdog = 0;
      p2_last_out = 64'd0;

      // Wait for global reset
      #(1 * `ClockPeriod);

      // Program 1 reset/launch
      #1 Reset = 1; startPC = 0;
      @(posedge CLK);
      @(negedge CLK);
      @(posedge CLK);
      Reset = 0;

      // Run Program 1 (ends at 0x30)
      while (currentPC < 64'h30) begin
         @(posedge CLK); @(negedge CLK);
         $display("CurrentPC:%h Instruction:%h MemtoRegOut:%h", currentPC, uut.instruction, MemtoRegOut);
      end
      passTest(MemtoRegOut, 64'h000000000000000F, "Results of Program 1", passed);

      // Program 2: run through 0x54 (capture value there), then stop by 0x58
      while (currentPC < 64'h58) begin
         @(posedge CLK); @(negedge CLK);
         $display("CurrentPC:%h Instruction:%h MemtoRegOut:%h", currentPC, uut.instruction, MemtoRegOut);
         if (currentPC == 64'h54) begin
            p2_last_out = MemtoRegOut; // capture LDUR result before PC advances to 0x58
         end
      end

      // Check Program 2 using the captured value at 0x54
      passTest(p2_last_out, 64'h123456789ABCDEF0, "Results of MOVZ program", passed);

      // Done
      allPassed(passed, 2);
      $finish;
   end

   // Clock
   initial CLK = 0;
   always begin
      #`HalfClockPeriod CLK = ~CLK;
      #`HalfClockPeriod CLK = ~CLK;
      watchdog = watchdog +1;
   end


   // Watchdog
   always @* if (watchdog == 16'hFF) begin
      $display("Watchdog Timer Expired.");
      $finish;
   end
endmodule


