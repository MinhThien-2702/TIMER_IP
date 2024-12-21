module apb_slave (
    input wire clk, 
    input wire rst_n, 
    input wire psel, 
    input wire pwrite, 
    input wire penable, 
    input wire [11:0] paddr, 
    input wire [31:0] pwdata,
    output wire pready,
    output reg wr_en, 
    output reg rd_en
);
    reg penable_d;

    // ??ng b? hóa tín hi?u penable
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            penable_d <= 1'b0;
        end else begin
            penable_d <= penable;
        end
    end

    // Tín hi?u pready ???c xác ??nh d?a trên wr_en và rd_en
    assign pready = wr_en | rd_en;
    
    // Logic ?i?u khi?n tín hi?u wr_en và rd_en
    always @* begin
        wr_en = 1'b0; // M?c ??nh reset
        rd_en = 1'b0;
        if (penable_d && psel && penable) begin
            if (pwrite) begin
                wr_en = 1'b1;
                rd_en = 1'b0;
            end else begin
                wr_en = 1'b0;
                rd_en = 1'b1;
            end
        end
    end
endmodule
