`timescale 1ns/1ps
`include "PE.v"

module PE_tb;
    parameter d_width = 32;
    parameter iact_size = 5;
    parameter kernel_size = 3;

    reg clk, rst_n, start;
    reg [d_width-1:0] weight, iact;
    wire done;
    wire load_iact, load_weight;
    wire [d_width-1:0] pe_out;

    // Instantiate the PE module
    PE #(.d_width(d_width), .iact_size(iact_size), .kernel_size(kernel_size)) 
    uut (
        .start(start),
        .clk(clk),
        .rst_n(rst_n),
        .weight(weight),
        .iact(iact),
        .done(done),
        .load_iact(load_iact),
        .load_weight(load_weight),
        .pe_out(pe_out)
    );

    // Clock generation
    always #5 clk = ~clk; // 10ns period (100MHz)

    initial begin
        // Initialize signals

        $dumpfile("PE_tb.vcd");
        $dumpvars(0, PE_tb);
        
        clk = 0;
        rst_n = 0;
        start = 0;
        weight = 0;
        iact = 0;

        // Apply reset
        #10 
        rst_n = 1;
        #10 
        start = 1;
        // Load iact values (2, 4, 6, 8, 10)
        #10;
        start = 0;
        iact = 2; 
        #10;
        iact = 4; 
        #10;
        iact = 6; 
        #10;
        iact = 8; 
        #10;
        iact = 10; 
        wait(load_iact == 1);

        #10;
        weight = 1; 
        #10;
        weight = 2; 
        #10;
        weight = 3; 
        wait(load_weight == 1);
        
        // Wait for done signal
        #200
        // Display output values
        // End simulation
        #20 $finish;
    end
endmodule
