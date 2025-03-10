`timescale 1ns/1ps
`include "SPad.v"

module SPad_tb;

    parameter d_width = 32;
    parameter a_width = 8;

    reg clk, rst_n, wen, ren;
    reg [a_width - 1:0] w_addr, r_addr;
    reg [d_width - 1:0] w_data;
    wire [d_width - 1:0] r_data;

    // Gọi module SPad
    SPad #(.d_width(d_width), .a_width(a_width)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .wen(wen),
        .ren(ren),
        .w_addr(w_addr),
        .w_data(w_data),
        .r_addr(r_addr),
        .r_data(r_data)
    );

    // Tạo clock có chu kỳ 10ns
    always #5 clk = ~clk;

    initial begin
        $dumpfile("SPad_tb.vcd");
        $dumpvars(0, SPad_tb);

        // Khởi tạo tín hiệu
        clk = 0;
        rst_n = 1;
        wen = 0;
        ren = 0;
        w_addr = 0;
        w_data = 0;
        r_addr = 0;

        // Reset hệ thống
        #3 rst_n = 0;
        #10 rst_n = 1; // Reset xong, bộ nhớ sẽ khởi tạo 0

        // Kiểm tra bộ nhớ sau reset
        #10 ren = 1; r_addr = 8'd0; 
        #10 $display("Time: %0t | Read Addr: %d | Read Data: %d", $time, r_addr, r_data);
        
        #10 ren = 1; r_addr = 8'd1;
        #10 $display("Time: %0t | Read Addr: %d | Read Data: %d", $time, r_addr, r_data);
        ren = 0;

        // Ghi dữ liệu vào bộ nhớ
        #10 wen = 1; w_addr = 8'd0; w_data = 32'd100; 
        #10 wen = 1; w_addr = 8'd20; w_data = 32'd200;
        #10 wen = 0; // Dừng ghi

        // Đọc lại giá trị để kiểm tra
        #10 ren = 1; r_addr = 8'd0;
        #10 $display("Time: %0t | Read Addr: %d | Read Data: %d", $time, r_addr, r_data);

        #10 ren = 1; r_addr = 8'd20;
        #10 $display("Time: %0t | Read Addr: %d | Read Data: %d", $time, r_addr, r_data);

        #10 ren = 1; r_addr = 8'd5;
        #10 $display("Time: %0t | Read Addr: %d | Read Data: %d", $time, r_addr, r_data);
        ren = 0;

        // Kết thúc mô phỏng
        #50;
        $finish;
    end

endmodule
