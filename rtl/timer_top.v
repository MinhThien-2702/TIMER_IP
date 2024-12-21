module timer_top(
input wire sys_clk, 
input wire sys_rst_n, 
input wire tim_psel, 
input wire tim_pwrite, 
input wire tim_penable, 
input wire [11:0] tim_paddr, 
input wire [31:0] tim_pwdata, 
input wire [3:0] tim_pstrb, 
input wire dbg_mode,
output wire [31:0] tim_prdata, 
output wire tim_pready, 
output wire tim_pslverr,
output wire tim_int
);
wire [31:0] wdata; 
wire wr_en, rd_en; 
wire [63:0] cnt_value; 
wire div_en, timer_en; 
wire [3:0] div_val; 
wire cnt_en;
wire halt_req, halt_ack;
wire [31:0] tdr0;
wire [31:0] tdr1;
wire [31:0] tcmp0, tcmp1; 
wire int_st, int_en;
wire int_st_set;
wire pslverr_control, pslverr_reg;
wire tdr0_wr_sel; 
wire tdrl_wr_sel;
wire timer_en_H_L;
wire int_st_clear;
wire valid_halt_condition;
apb_slave u_apb_slave(
.clk(sys_clk), 
.rst_n(sys_rst_n), 
.psel (tim_psel),
.pwrite(tim_pwrite), 
.penable(tim_penable),
.paddr(tim_paddr), 
//.pstrb(tim_pstrb),
.pwdata (tim_pwdata), 
//.wdata(wdata),
.pready(tim_pready), 
.wr_en (wr_en), 
.rd_en (rd_en)
);
register_file u_register_file (
.clk(sys_clk),
.rst_n (sys_rst_n), 
.wr_en (wr_en), 
.rd_en (rd_en), 
.addr(tim_paddr), 
.pstrb(tim_pstrb),
.wdata (tim_pwdata), 
.rdata (tim_prdata), 
.tdr1_wr_sel (tdr1_wr_sel), 
.tdr0_wr_sel (tdr0_wr_sel), 
.cnt_value (cnt_value), 
//.pwdata_cnt0(pwdata_cnt0),
//.pwdata_cntl(pwdata_cnt1), 
.int_st (int_st),
.int_en (int_en), 
.int_st_set(int_st_set),
.int_st_clear(int_st_clear),
.halt_ack (halt_ack),
.div_en (div_en),
.div_val (div_val),
.timer_en (timer_en),
.timer_en_H_L(timer_en_H_L),
.TDR0 (tdr0),
.TDR1 (tdr1),
.TCMP0(tcmp0),
.TCMP1(tcmp1),
.halt_req(halt_req),
.pslverr_reg (pslverr_reg),
.pslverr_control(pslverr_control)
);
control_counter u_control_counter (
.clk(sys_clk), 
.rst_n(sys_rst_n), 
.div_en(div_en), 
.div_val(div_val), 
.halt_req(halt_req), 
.dbg_mode (dbg_mode), 
.timer_en (timer_en),
.cnt_en (cnt_en),
.valid_halt_condition (valid_halt_condition),
.halt_ack (halt_ack)
);
counter u_counter (
.clk(sys_clk),
.rst_n(sys_rst_n),
.tdr1_wr_sel (tdr1_wr_sel), 
.tdr0_wr_sel (tdr0_wr_sel), 
.cnt_en (cnt_en),
.timer_en_H_L(timer_en_H_L),
.tdr0 (tdr0),
.tdr1 (tdr1),
.valid_halt_condition(valid_halt_condition),
.cnt_value(cnt_value)
);

interrupt u_interrupt (
.clk(sys_clk),
.rst_n (sys_rst_n),
.int_st_set(int_st_set),
.int_st_clear (int_st_clear), 
.int_en(int_en),
.int_st(int_st),
.tim_int (tim_int)
);

assign pslverr = pslverr_control | pslverr_reg;
endmodule