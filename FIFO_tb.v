`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.07.2025 19:13:26
// Design Name: 
// Module Name: FIFO_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// Code your testbench here
// or browse Examples
// Code your testbench here
// or browse Examples

module FIFO_tb;

  reg clk, rst;
  reg wr_en, rd_en;
  reg [7:0] buf_in;
  wire [7:0] buf_out;
  wire buf_empty, buf_full;
  wire [3:0] fifo_counter;

  // Instantiate the DUT
  FIFO dut (
    .clk(clk),
    .rst(rst),
    .buf_in(buf_in),
    .buf_out(buf_out),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .buf_empty(buf_empty),
    .buf_full(buf_full),
    .fifo_counter(fifo_counter)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // 10 ns clock period
  end

  // Stimulus
  initial begin
    $dumpfile("fifo.vcd");
    $dumpvars(0, FIFO_tb);

    // Initialize signals
    rst = 1; wr_en = 0; rd_en = 0; buf_in = 8'h00;
    #15;
    rst = 0;

    // Write 8 values to FIFO
    $display("Writing to FIFO...");
    repeat (8) begin
      @(posedge clk);
      wr_en = 1;
      rd_en = 0;
      buf_in = $random % 256;
      $display("Wrote: %h", buf_in);
    end

    // Wait for 1 cycle
    @(posedge clk);
    wr_en = 0;

    // Try writing when full (shouldn't write)
    @(posedge clk);
    wr_en = 1;
    buf_in = 8'hFF;
    $display("Attempt to write when full: %h", buf_in);
    @(posedge clk);
    wr_en = 0;

    // Read 4 values
    $display("Reading 4 values...");
    repeat (4) begin
      @(posedge clk);
      rd_en = 1;
      wr_en = 0;
      $display("Read: %h", buf_out);
    end
    rd_en = 0;

    // Simultaneous write and read
    $display("Simultaneous read/write...");
    repeat (3) begin
      @(posedge clk);
      wr_en = 1;
      rd_en = 1;
      buf_in = $random % 256;
      $display("Simultaneous: Wrote %h, Read %h", buf_in, buf_out);
    end
    wr_en = 0;
    rd_en = 0;

    // Read until empty
    $display("Reading remaining data...");
    while (!buf_empty) begin
      @(posedge clk);
      rd_en = 1;
      $display("Read: %h", buf_out);
    end
    rd_en = 0;

    // Final state
    @(posedge clk);
    $display("FIFO Empty: %b, Full: %b, Counter: %d", buf_empty, buf_full, fifo_counter);

    $display("Simulation complete.");
    $finish;
  end

endmodule
