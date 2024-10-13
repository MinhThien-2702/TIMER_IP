module control_counter(
    input wire clk, 
    input wire rst_n, 
    input wire div_en, 
    input wire [3:0] div_val,
    input wire halt_req, 
    input wire dbg_mode, 
    input wire timer_en,
    output wire cnt_en, 
    output reg halt_ack,
    output wire valid_halt_condition
);
reg [8:0] div_factor;
reg [7:0] int_cnt;

always @* begin
    if (div_en && timer_en) begin 
        case (div_val)
            4'b0000: div_factor = 32'd1; 
            4'b0001: div factor = 32'd2;
            4'b0010: div_factor = 32'd4; 
            4'b0011: div_factor = 32'd8; 
            4'b0100: div_factor = 32'd16; 
            4'b0101: div_factor = 32'd32; 
            4'b0110: div_factor = 32'd64; 
            4'b0111: div factor 32'd128; 
            default: div_factor = 32'd256;
        endcase
    end else if (!div_en && timer_en) begin 
        div_factor = 32'd1;
    end else begin
        div_factor = 32'd1;
    end
end

assign cnt_en = (!valid_halt_condition) && ((timer_en && !div_en) || (timer_en && div_en && (div_val==4'b0000)) || (timer_en && div_en && (int_cnt == div_factor - 1)));

wire [7:0] int_cnt_prev;
wire int_cnt_condition;
wire cnt_rst;
assign int_cnt_condition = !(dbg_mode & halt_req) & (div_en & timer_en & (div_val != 4'b0)); 
assign int_cnt_prev = int_cnt_condition? (int_cnt + 1'b1) : int_cnt;
assign cnt_rst = (!timer_en) | (!div_en) | ((int_cnt == (div_factor - 1'b1)) & (!valid_halt_condition));
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int_cnt <= 8'b0;
    end else begin
        if (cnt_rst) 
            int_cnt <= 8'b0; 
        else 
            int_cnt <= int_cnt_prev; 
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        halt ack <= 1'b0;
    end else begin
        halt_ack <= valid_halt_condition;
    end
end
endmodule