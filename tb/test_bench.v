`timescale 1ns/100ps 
module test_bench;
reg sys_clk;
reg sys_rst_n; 
reg tim_psel; 
reg tim_pwrite; 
reg tim_penable;
reg [11:0] tim_paddr; 
reg [31:0] tim_pwdata; 
wire [31:0] tim_prdata; 
reg [3:0] tim_pstrb; 
wire tim_pready; 
wire tim_pslverr; 
wire tim_int;
reg dbg_mode;

timer_top u_dut(.*);

`include "run_test.v"

    initial begin
        sys_clk = 0;
        forever #2.5 sys_clk = ~sys_clk;
    end

    initial begin
        sys_rst_n = 1;
        tim_pstrb = 4'b1111;
        tim_paddr = 0;
        tim_psel 0;
        tim_pwrite = 0;
        tim_penable = 0;
        tim_pwdata = 0;
        dbg_mode = 0;
        run_test();
        #2.5;
        $finish; 
    end
endmodule