`include "SPad.v"

module PE#(
    parameter d_width = 32,
    parameter a_width = 8,
    parameter iact_size =  5,
    parameter kernel_size = 3
)
(
    input start,
    input clk, rst_n,
    input [d_width -1 : 0] weight,
    input [d_width -1 : 0] iact,

    output reg load_weight,
    output reg load_iact,
    output reg done,
    output [d_width -1 : 0] pe_out0, pe_out1, pe_out2
);

    reg [2:0] state, next_state;
    parameter S0 = 3'd0;
    parameter S1 = 3'd1;
    parameter S2 = 3'd2;
    parameter S3 = 3'd3;
    parameter S4 = 3'd4;

    reg [d_width -1 : 0] buffer_iact [0:4];
    reg [d_width -1 : 0] buffer_weight[0:4];
    reg [d_width -1 : 0] buffer_out[0:2];

    reg [2:0] cnt_load_iact, cnt_load_weight;
    reg [2:0] cnt_com_iact, cnt_com_weight, index_out;

    integer i;
    always@(posedge clk, negedge rst_n) begin
        if(!rst_n) begin
            state <= S0;
            cnt_com_iact <= 0;
            cnt_com_weight <= 0;
            cnt_load_iact <= 0;
            cnt_load_weight <= 0;
            index_out <= 0;
            done <= 0;
            // Reset buffer_out
            for (i = 0; i < 3; i = i + 1) begin
              buffer_out[i] <= 0;
            end
                
        end
        else begin
            case(state) 
                S0: begin 
                    done <= 0;
                    if(start) state <= S1;

                    else state <= S0;
                end

                S1: begin
                    if(cnt_load_iact < iact_size) begin
                        buffer_iact[cnt_load_iact] <= iact;
                        cnt_load_iact <= cnt_load_iact + 1;
                        state <= S1;
                    end
                    else begin
                        state <= S2;
                        load_iact <= 1;
                        cnt_load_iact <= 0;
                    end
                end

                S2: begin
                    if(cnt_load_weight < kernel_size) begin
                        buffer_weight[cnt_load_weight] <= weight;
                        cnt_load_weight <= cnt_load_weight + 1;
                        state <= S2;
                    end
                    else begin
                        state <= S3;
                        load_weight <= 1;
                        cnt_load_weight <= 0;
                    end
                end

                S3: begin
                    if(cnt_com_weight < kernel_size) begin
                        buffer_out[index_out] <= buffer_out[index_out] + buffer_iact[cnt_com_iact] * buffer_weight[cnt_com_weight];
                        cnt_com_iact <= cnt_com_iact + 1;
                        cnt_com_weight <= cnt_com_weight +1;
                        state <= S3;
                    end
                    else begin
                        if(index_out < (iact_size - kernel_size + 1)) begin
                            index_out <= index_out + 1;
                            cnt_com_weight <= 0;
                            cnt_com_iact <= index_out + 1;
                            state <= S3;
                        end
                        else begin
                            cnt_com_iact <= 0;
                            cnt_com_weight <= 0;
                            index_out <= 0;
                            state <= S4;
                        end
                    end
                end

                S4: begin 
                    state <= S0;
                    done <= 1;
                end

                default: state <= S0;
            endcase
        end
    end

    assign pe_out0 = buffer_out[0];
    assign pe_out1 = buffer_out[1];
    assign pe_out2 = buffer_out[2];

endmodule