module counter (
    input wire clk, 
    input wire rst_n, 
    input wire cnt_en,
    input wire timer_en_H_L,
    input wire tdr1_wr_sel, tdr0_wr_sel, 
    input wire [31:0] tdr0, tdr1,
    input wire valid_halt_condition, 
    output reg [63:0] cnt_value
);
reg tdr1_wr_sel_d, tdr0_wr_sel_d;
initial cnt_value = 64'b0;
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            tdr1_wr_sel_d <= 1'b0; 
            tdr0_wr_sel_d <= 1'b0;
    end else begin
            tdr1_wr_sel_d <= tdr1_wr_sel; 
            tdr0_wr_sel_d <= tdr0_wr_sel;
        end
    end
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n || timer_en_H_L) begin
            cnt_value = 64'b0;
        end else
            if (valid_halt_condition) begin 
                cnt_value = cnt_value;
        end else
            if (cnt_en) begin
                cnt_value = cnt_value + 64'b1; 
            end else begin
                cnt_value = cnt_value;
            end
    end 
    always @* begin
        cnt_value = {tdr1,tdr0};
    end
endmodule
