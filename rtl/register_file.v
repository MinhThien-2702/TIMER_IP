module register_file( 
    input wire clk, 
    input wire rst_n, 
    input wire [3:0] pstrb, 
    input wire [11:0] addr, 
    input wire [31:0] wdata, 
    input wire wr_en, rd_en, 
    output wire [31:0] rdata, //control counter
    output reg div_en, timer_en, 
    output reg [3:0] div_val, 
    input wire [63:0] cnt_value, 
    output reg int_st,
    output wire int_st_set,
    output wire int_st_clear,
    input wire halt_ack,
    //counter
    output wire tdr0_wr_sel, tdr1_wr_sel,
    output wire timer_en_H_L,
    output reg [31:0] TDR0,
    output reg [31:0] TDR1,
    output reg [31:0] TCMP0, TCMP1,
    //interrupt
    output reg halt_req,
    output reg int_en,
    output wire pslverr_reg, 
    output wire pslverr_control
);
    parameter TCR_ADD = 12'h0; 
    parameter TDR0_ADD = 12'h4;
    parameter TDR1_ADD = 12'h8; 
    parameter TCMP0_ADD = 12'hC; 
    parameter TCMP1_ADD = 12'h10;
    parameter TIER_ADD = 12'h14;
    parameter TISR_ADD = 12'h18; 
    parameter THCSR_ADD = 12'h1C;

    initial begin
        div_val = 4'b0001; 
        div_en = 1'b0; 
        timer_en = 1'b0; 
    end
    wire [31:0] TCR, TIER, TISR, THCSR;
    wire tcr_wr_sel, tcmp0_wr_sel, tcmpl_wr_sel, tier_wr_sel, tisr_wr_sel, thcsr_wr_sel;
    wire add_valid_tcr, add_valid_tdr0, add_valid_tdrl, add_valid_tcmp0, add_valid_tcmpl, add_valid_tier, add_valid_tisr, add_valid_thcsr;
    
    assign add_valid_tcr = (addr == TCR_ADD) ? 1'b1: 1'b0; 
    assign add_valid_tdr0 = (addr == TDR0_ADD) ? 1'b1 : 1'b0; 
    assign add_valid_tdrl = (addr == TDR1_ADD) ? 1'b1: 1'b0; 
    assign add_valid_tcmp0 = (addr == TCMP0_ADD) ? 1'b1: 1'b0; 
    assign add_valid_tcmpl = (addr == TCMP1_ADD) ? 1'b1 : 1'b0; 
    assign add_valid_tier = (addr == TIER_ADD) ? 1'b1 : 1'b0; 
    assign add_valid_tisr = (addr == TISR_ADD) ? 1'b1 : 1'b0; 
    assign add_valid_thcsr = (addr == THCSR_ADD) ? 1'b1 : 1'b0;
    assign tcr_wr_sel = wr_en & add_valid_tcr; 
    assign tdr0_wr_sel = wr_en & add_valid_tdr0;
    assign tdrl_wr_sel = wr_en & add_valid_tdrl;
    assign tcmp0_wr_sel = wr_en & add_valid_tcmp0;
    assign tcmpl_wr_sel = wr_en & add_valid_tcmpl; 
    assign tier_wr_sel = wr_en & add_valid_tier; 
    assign tisr_wr_sel = wr_en & add_valid_tisr; 
    assign thcsr_wr_sel = wr_en & add_valid_thcsr;

////TCR WRITE/////
wire timer_en_prev, div_en_prev;
wire [3:0] div_val_prev;
    assign timer_en_prev = (!pslverr_reg & !pslverr_control & tcr_wr_sel & pstrb[0]) ? wdata[0]: timer_en;
    assign div_en_prev = (tcr_wr_sel & !pslverr_control & !pslverr_reg & pstrb[0]) ? wdata[1]: div_en;
    assign div_val_prev = (tcr_wr_sel & !pslverr_control & pstrb[1]) ? ((wdata[11:8] < 4'd9) ? wdata[11:8] : div_val) : div_val;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            timer_en <= 1'b0;
            div_en <= 1'b0;
            div_val <= 4'h1;
        end else begin
            timer_en <= timer_en_prev;
            div_en <= div_en_prev;
            div_val<= div_val_prev;
        end
    end
    
    assign pslverr_reg = (tcr_wr_sel & pstrb[1]) & (wdata[11:8] > 4'd8); 
    assign TCR = {20'h0, div_val, 6'h0, div_en, timer_en};
    reg div_val_d, div_en_d;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            div_en_d <= 1'b0;
            div_val_d <= 4'b0;
        end else begin
            div_en_d <= div_en; 
            div_val_d <= div_val;
        end
    end

    assign pslverr_control = (timer_en) & (((tcr_wr_sel & pstrb[1]) & (div_val != wdata[11:8])) || ((tcr_wr_sel & pstrb[0]) & (div_en != wdata[1])));
    reg timer_en_d;
    //TDRO WRITE///
    assign timer_en_H_L = timer_en_d & (!timer_en); 
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin
            timer_en_d <= 1'b0;
            end else begin
            timer_en_d <= timer_en; 
            end
        end
wire [31:0] pwdata_cnt0_pre; 
wire [31:0] pwdata_cnt1_pre; 
reg tdr0_wr_sel_d;
reg [31:0] wdata_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tdr0_wr_sel_d <= 1'b0;
            wdata_d<= 32'h0;
        end else begin
            wdata_d <= wdata;
            tdr0_wr_sel_d <= tdr0_wr_sel;
        end
    end
assign pwdata_cnt0_pre[7:0] = (tdr0_wr_sel_d & pstrb[0]) ? wdata_d[7:0]: cnt_value[7:0]; 
assign pwdata_cnt0_pre[15:8] = (tdr0_wr_sel_d & pstrb[1]) ? wdata_d[15:8]: cnt_value[15:8]; 
assign pwdata_cnt0_pre[23:16] = (tdr0_wr_sel_d & pstrb[2]) ? wdata_d[23:16]: cnt_value[23:16]; 
assign pwdata_cnt0_pre[31:24] = (tdr0_wr_sel_d & pstrb[3]) ? wdata_d[31:24]: cnt_value[31:24];


    always @* begin
        if (!rst_n) begin 
            TDR0 = 32'h0;
        end else 
            if (timer_en_H_L) begin 
                TDR0 = 32'h0;
            end else begin
                TDR0 = pwdata_cnt0_pre;
            end
    end

//////TDR1 WRITE/////
reg tdr1_wr_sel_d;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tdr1_wr_sel_d <= 1'b0;
        end else begin
            tdr1_wr_sel_d <= tdr1_wr_sel;
        end
    end

assign pwdata_cnt1_pre[7:0] = (tdr1_wr_sel_d & pstrb[0]) ? wdata_d[7:0] : cnt_value [39:32]; 
assign pwdata_cnt1_pre[15:8] = (tdr1_wr_sel_d & pstrb[1]) ? wdata_d[15:8]: cnt_value[47:40]; 
assign pwdata_cnt1_pre[23:16] = (tdr1_wr_sel_d & pstrb[2]) ? wdata_d[23:16]: cnt_value[55:48]; 
assign pwdata_cnt1_pre[31:24] = (tdr1_wr_sel_d & pstrb[3]) ? wdata_d[31:24] : cnt_value[63:56]; 

    
always @* begin
    if (!rst_n) begin
        TDR1 = 32'h0;
    end else 
        if (timer_en_H_L) begin 
            TDR1 = 32'h0;
        end else begin
            TDR1 = pwdata_cnt1_pre;
    end
end


///tcmpo and tcmpl/
wire [31:0] tcmp0_prev;
wire [31:0] tcmp1_prev;

assign tcmp0_prev[7:0] = (tcmp0_wr_sel & pstrb[0]) ? wdata[7:0]: TCMP0 [7:0]; 
assign tcmp0_prev[15:8] = (tcmp0_wr_sel & pstrb[1]) ? wdata[15:8] : TCMP0 [15:8];
assign tcmp0_prev[23:16] = (tcmp0_wr_sel & pstrb[2]) ? wdata[23:16]: TCMP0 [23:16];
assign tcmp0_prev[31:24] = (tcmp0_wr_sel & pstrb[3]) ? wdata[31:24]: TCMP0 [31:24];

assign tcmp1_prev[7:0] = (tcmpl_wr_sel & pstrb[0]) ? wdata[7:0]: TCMP1[7:0];
assign tcmp1_prev[15:8] = (tcmpl_wr_sel & pstrb[1]) ? wdata[15:8] : TCMP1[15:8];
assign tcmp1_prev[23:16] = (tcmpl_wr_sel & pstrb[2]) ? wdata[23:16] : TCMP1[23:16]; 
assign tcmp1_prev[31:24] = (tcmpl_wr_sel & pstrb[3]) ? wdata [31:24]: TCMP1[31:24];

  
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            TCMP0 <= 32'hFFFF_FFFF;
            TCMP1 <= 32'hFFFF_FFFF;
        end else begin
            TCMP0<= tcmp0_prev; 
            TCMP1 <= tcmp1_prev;
        end
    end
/////TIER - int_en/////
wire int_en_prev;
assign int_en_prev = (tier_wr_sel & pstrb[0]) ? wdata[0] : int_en; 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int_en <= 1'h0;
        end else begin
            int_en <= int_en_prev;
        end
    end
assign TIER = {31'h0, int_en};

/////////TISR - int_st///////
wire int_st_prev;
wire [63:0] counter, compare;
assign counter = {TDR1, TDR0}; 
assign compare = {TCMP1, TCMP0}; 

assign int_st_clear = (tisr_wr_sel & pstrb[0] & wdata[0]==1'b1);
assign int_st_prev = (int_st_clear & int_st) ? 1'b0: (int_st_set ? 1'b1 : int_st); 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            int_st <= 1'b0;
        end else
            int_st <= int_st_prev;
    end
assign int_st_set = (counter == compare);
assign TISR = {31'h0, int_st};
////// THCSR ///////
wire halt_req_prev;
assign halt_req_prev = (thcsr_wr_sel & pstrb[0]) ? wdata[0] : halt_req; 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            halt_req <= 1'b0;
        end else begin
            halt_req <= halt_req_prev;
        end
    end

assign THCSR = {30'h0, halt_ack, halt_req}; 
/// READ /////
reg [31:0] rd;
assign rdata = rd;
    always @* begin
        if (rd_en) begin
            case (addr)
                TCR_ADD: rd = TCR; 
                TDR0_ADD: rd = TDR0;
                TDR1_ADD: rd = TDR1;
                TCMP0_ADD: rd = TCMP0; 
                TCMP1_ADD: rd = TCMP1; 
                TIER_ADD: rd = TIER;
                TISR_ADD: rd = TISR;
                THCSR_ADD: rd = THCSR;
                default: rd = 32'h0;
            endcase
        end else begin
            rd = 32'h0;
        end
    end
endmodule
