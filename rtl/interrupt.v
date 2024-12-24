module interrupt (
    input wire clk, 
    input wire rst_n, 
    input wire int_st_set, 
    input wire int_en, 
    input wire int_st,
    input wire int_st_clear,
    output reg tim_int
);
reg int_st_clear_d;
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            int_st_clear_d <= 1'b0;
        end else begin
            int_st_clear_d <= int_st_clear;
        end
    end
    always @* begin
        if (!rst_n) begin
            tim_int = 1'b0;
        end else if (!int_en) begin
            tim_int = 1'b0;
        end else
            if (int_st_clear_d) begin
                tim_int = 1'b0;
            end else if (int_st) begin 
                tim_int = 1'b1;
            end else begin
                tim_int = tim_int;
        end   
    end
endmodule