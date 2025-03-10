module SPad#(
    parameter d_width = 32,
    parameter a_width = 8
)
(
    input clk, rst_n, 
    input wen, ren,
    input [a_width -1 : 0] w_addr,
    input [d_width -1 : 0] w_data,
    input [a_width -1 : 0] r_addr,
    output reg [d_width - 1: 0] r_data 
);

    integer i;
    reg [d_width -1 : 0] mem [0:256];


    always @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            for(i = 0; i < 256; i = i + 1) begin
                mem[i] <= 32'd0;
            end
        end
        else 
            if(wen) begin
                mem[w_addr] <= w_data;
            end
    end

    always @(posedge clk) begin
        if (ren) begin
            r_data <= mem[r_addr]; // Đọc dữ liệu từ bộ nhớ
        end
    end

endmodule