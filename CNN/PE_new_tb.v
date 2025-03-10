`timescale 1ns/1ps
`include "PE_new.v"
`timescale 1ns/1ps

module PE_new_tb;

    // Thông số của PE
    parameter d_width = 32;
    parameter a_width = 8;

    // Tín hiệu testbench
    reg clk, rst_n;
    reg [3:0] kernel_size;
    reg [3:0] iact_size;
    reg [d_width - 1 : 0] weight;
    reg [d_width - 1 : 0] iact;
    
    wire load_iact, load_weight;
    wire [d_width - 1 : 0] psum0, psum1, psum2;
    wire [d_width - 1 : 0] weight0, weight1, weight2, iact0, iact1, iact2, iact3, iact4;

    // Gọi module PE
    PE_new#(
        .d_width(d_width),
        .a_width(a_width)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .kernel_size(kernel_size),
        .iact_size(iact_size),
        .weight(weight),
        .iact(iact),
        .load_iact(load_iact),
        .load_weight(load_weight),
        .psum0(psum0),
        .psum1(psum1),
        .psum2(psum2),
        .weight0(weight0),
        .weight1(weight1),
        .weight2(weight2),
        .iact0(iact0),
        .iact1(iact1),
        .iact2(iact2),
        .iact3(iact3),
        .iact4(iact4)
    );

    // Clock 10ns (100MHz)
    always #5 clk = ~clk;

    initial begin
    // Khởi tạo tín hiệu
    $dumpfile("PE_new_tb.vcd");
    $dumpvars(0, PE_new_tb);
    clk = 0;
    rst_n = 1;
    kernel_size = 3;
    iact_size = 5;
    weight = 0;
    iact = 0;

    // Reset hệ thống
    #5 rst_n = 0;
    #5 rst_n = 1;

    // Cấp dữ liệu weight
    #5 weight = 32'd2; iact = 32'd1;
    #10 weight = 32'd3; iact = 32'd2;
    #10 weight = 32'd4; iact = 32'd3; 
    // Cấp dữ liệu iact
    #10 iact = 32'd4; 
    #10 iact = 32'd5; 

    // Chờ tính toán hoàn tất
    #200;
    // Kiểm tra đầu ra
    $display("Iact buffer:");
    $display("%d %d %d %d %d", iact0, iact1, iact2, iact3, iact4);

    $display("Weight buffer:");
    $display("%d %d %d", weight0, weight1, weight2);

    $display(psum0, psum1, psum2);

    // Kết thúc mô phỏng
    $finish;
end

endmodule

