`timescale 1ns / 1ps

`define SIZE 1024

// Byte-addressed memory; big-endian word packing maintained exactly.
// Asynchronous read, synchronous write with #3 delay kept.
module DataMemory(
    output reg [63:0] ReadData,
    input      [63:0] Address,
    input      [63:0] WriteData,
    input             MemoryRead,
    input             MemoryWrite,
    input             Clock
);

    reg [7:0] memBank [`SIZE-1:0];

    // Task remains identical (style: aligned)
    task initset;
        input [63:0] addr;
        input [63:0] data;
        begin
            memBank[addr+0] = data[63:56];
            memBank[addr+1] = data[55:48];
            memBank[addr+2] = data[47:40];
            memBank[addr+3] = data[39:32];
            memBank[addr+4] = data[31:24];
            memBank[addr+5] = data[23:16];
            memBank[addr+6] = data[15:8];
            memBank[addr+7] = data[7:0];
        end
    endtask

    // Initialization (unchanged data)
    initial begin
        initset(64'h0 , 64'h1);
        initset(64'h8 , 64'ha);
        initset(64'h10, 64'h5);
        initset(64'h18, 64'h0ffbea7deadbeeff);
        initset(64'h20, 64'h0);
        // Extend with more initset calls if needed.
    end


 // Asynchronous read
    always @(*) begin
        if (MemoryRead) begin
            ReadData[63:56] = memBank[Address+0];
            ReadData[55:48] = memBank[Address+1];
            ReadData[47:40] = memBank[Address+2];
            ReadData[39:32] = memBank[Address+3];
            ReadData[31:24] = memBank[Address+4];
            ReadData[23:16] = memBank[Address+5];
            ReadData[15:8]  = memBank[Address+6];
            ReadData[7:0]   = memBank[Address+7];
        end else begin
            ReadData = 64'd0;
        end
    end

    // Synchronous write (maintain #3 delay and big-endian packing)
    always @(posedge Clock) begin
        if (MemoryWrite) begin
            memBank[Address+0] <= #3 WriteData[63:56];
            memBank[Address+1] <= #3 WriteData[55:48];
            memBank[Address+2] <= #3 WriteData[47:40];
            memBank[Address+3] <= #3 WriteData[39:32];
            memBank[Address+4] <= #3 WriteData[31:24];
            memBank[Address+5] <= #3 WriteData[23:16];
            memBank[Address+6] <= #3 WriteData[15:8];
            memBank[Address+7] <= #3 WriteData[7:0];
        end
    end

endmodule
