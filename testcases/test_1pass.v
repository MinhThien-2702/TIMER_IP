/////write_register//////////
task write_register;
    input [11:0] address;
    input [31:0] data;
    begin
        @(posedge test_bench.sys_clk);
        test_bench.tim_psel = 1;
        test_bench.tim_penable = 0;
        test_bench.tim_paddr = address;
        test_bench.tim_pwdata = data;
        test_bench.tim_pwrite = 1;
        @(posedge test_bench.sys_clk); 
        test_bench.tim_penable = 1;
        repeat (2) @(posedge test_bench.sys_clk); 
        test_bench.tim_psel = 0; 
        test_bench.tim_penable = 0; 
        test_bench.tim_pwrite = 0;
    end
endtask
////////read register///////////
task read_register;
    input [11:0] address;
    output [31:0] data;
    begin
        @(posedge test_bench.sys_clk); 
        test_bench.tim_psel = 1;
        test_bench.tim_penable = 0;
        test_bench.tim_paddr = address;
        test_bench.tim_pwrite = 0;
        @(posedge test_bench.sys_clk); 
        test_bench.tim_penable = 1;
        repeat (2) @(posedge test_bench.sys_clk); 
        data= tim_prdata;
        test_bench.tim_psel = 0; 
        test_bench.tim_penable = 0;
    end
endtask
////reset register//////////
task reset_register;
    begin
        test_bench.sys_rst_n = 0; 
        @(posedge test_bench.sys_clk); 
        test_bench.sys_rst_n = 1;
    end
endtask

begin
task run_test;
    reg [31:0] read_data;
    begin
        reset_register;
        @(posedge test_bench.sys_clk); 
        $display ("--ENABLE INTERRUPT-");
        write_register(12'h14, 32'h1);
        @(posedge test_bench.sys_clk); 
        $display ("---WRITE TO TDRO--");
        write_register(12'h04, 32'de);
        @(posedge test_bench.sys_clk);
        read_register(12'h04, read_data); 
        $display ("-----WRITE TO TDR1-");
        write_register(12'h08, 32'hffff_ffff);
        @(posedge test_bench.sys_clk); 
        $display ("----WRITE TO TCMPO----");
        write_register(12'h0C, 32'd10);
        @(posedge test_bench.sys_clk); 
        $display ("-------ENABLE TIMER_EN--");
        write_register(12'h00, 32'd257);
        repeat (11) @(posedge test_bench.sys_clk); 
        @(negedge test_bench.sys_clk);
        if (test_bench.tim_int == 1'b1) begin
        $display ("---PASSED: INTERRUPT ASSERTED---");
        end else begin
        $display ("----FAILED: INTERRUPT DOES NOT ASSERTED-----");
        end
        repeat (10) @(posedge test_bench.sys_clk); 
        $finish;
    end
endtask