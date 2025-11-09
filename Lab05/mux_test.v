odule mux_test();

    // Regs for the inputs we will control
    reg  [7:0] in0_t, in1_t;
    reg        sel_t;

    // Wire for the output we will observe from the mux
    wire [7:0] out_t;

    // Create an instance of your mux, connecting our test signals to it.
    // We name it "DUT" for "Device Under Test".
    mux2to1_8 DUT (
       .in0(in0_t),
       .in1(in1_t),
       .sel(sel_t),
       .out(out_t)
    );

    // --- ADD THIS BLOCK ---
    // This initial block sets up the VCD waveform file for GTKWave.
    initial begin
        $dumpfile("mux_test.vcd"); // Sets the output filename
        $dumpvars(0, mux_test);    // Dumps all signals in this module
    end
    // --- END OF ADDED BLOCK ---

    // This block runs once at the start to define our test sequence.
    initial begin
       $display("--- Starting 8-bit MUX Test ---");

       // Test Case 1: Select input 0
       sel_t = 0; in0_t = 8'hAA; in1_t = 8'h55; #10; // Set values and wait 10ns
       if (out_t === 8'hAA)
           $display("[PASSED] sel=0, out=0x%h", out_t);
       else
           $display("[FAILED] sel=0, out=0x%h, Expected=0xAA", out_t);

       // Test Case 2: Select input 1
       sel_t = 1; #10; // Wait another 10ns
       if (out_t === 8'h55)
           $display("[PASSED] sel=1, out=0x%h", out_t);
       else
           $display("[FAILED] sel=1, out=0x%h, Expected=0x55", out_t);

       // Test Case 3: Different data, select input 0 again
       sel_t = 0; in0_t = 8'hF0; in1_t = 8'h0F; #10; // Wait 10ns
       if (out_t === 8'hF0)
           $display("[PASSED] sel=0, out=0x%h", out_t);
       else
           $display("[FAILED] sel=0, out=0x%h, Expected=0xF0", out_t);

       $display("--- Testbench Finished ---");
       $finish; // End the simulation
    end
endmodule
