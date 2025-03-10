module PE_new#(
    parameter d_width = 32,
    parameter a_width = 8
)
(
    input clk, rst_n,
    input [3:0] kernel_size,
    input [3:0] iact_size,
    input [d_width - 1 : 0] weight, 
    input [d_width - 1 : 0] iact,

    output reg load_iact, load_weight,
    output [d_width - 1 : 0] psum0, psum1, psum2,
    output [d_width - 1 : 0] weight0, weight1, weight2, iact0, iact1, iact2, iact3, iact4
);

    reg [d_width - 1 : 0] buffer_weight [0 : 4];
    reg [d_width - 1 : 0] buffer_iact [0 : 5];
    reg [d_width - 1 : 0] buffer_out [0 : 2];

    reg [3:0] cnt_weight, cnt_iact;
    reg [3:0] cnt_kernel_size, cnt_iact_size;
    reg [3:0] index_out;

    // Load iact values
    always @(posedge clk, negedge rst_n) begin
    if (~rst_n) begin
        cnt_iact <= 0;
        load_iact <= 0;
    end 
    else begin
        if (cnt_iact < iact_size) begin
            buffer_iact[cnt_iact] <= iact;  // Ghi dữ liệu đúng ngay clk đầu tiên
            cnt_iact <= cnt_iact + 1;
        end
		  else begin
				load_iact <= 1;
		  end
    end 
end

    // Load weight values
    always @(posedge clk, negedge rst_n) begin
        if (rst_n == 0) begin
            cnt_weight <= 0;
            load_weight <= 0;
        end 
        else if (cnt_weight < kernel_size) begin
            buffer_weight[cnt_weight] <= weight;
            cnt_weight <= cnt_weight + 1;
        end 
        else begin
            load_weight <= 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (rst_n == 0) begin
            buffer_out[0] <= 0;
            buffer_out[1] <= 0;
            buffer_out[2] <= 0;
            cnt_kernel_size <= 0;
            cnt_iact_size <= 0;
            index_out <= 0;
        end 
        else if (load_iact && load_weight) begin
            if (cnt_kernel_size < kernel_size) begin
                buffer_out[index_out] <= buffer_out[index_out] + buffer_iact[cnt_iact_size] * buffer_weight[cnt_kernel_size];
                cnt_kernel_size <= cnt_kernel_size + 1;
                cnt_iact_size <= cnt_iact_size + 1;
            end 
            else begin
                if (index_out < (iact_size - kernel_size + 1)) begin
                    index_out <= index_out + 1;
                    cnt_kernel_size <= 0;
                    cnt_iact_size <= index_out + 1;
                end
            end
        end
    end
	 

    assign weight0 = buffer_weight[0];
    assign weight1 = buffer_weight[1];
    assign weight2 = buffer_weight[2];

    assign iact0 = buffer_iact[0];
    assign iact1 = buffer_iact[1];
    assign iact2 = buffer_iact[2];
    assign iact3 = buffer_iact[3];
    assign iact4 = buffer_iact[4];

    assign psum0 = buffer_out[0];
    assign psum1 = buffer_out[1];
    assign psum2 = buffer_out[2];

endmodule
