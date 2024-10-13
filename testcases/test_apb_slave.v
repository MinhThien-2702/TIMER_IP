
///initialization///////
task initialization_test; 
    begin
        @(posedge test_bench.sys_clk); 
        test_bench.sys_rst_n = 0;
        @(posedge test_bench.sys_clk);
        if (u_dut.u_apb_slave.wr_en !== 1'b0 || u_dut.u_apb_slave.rd_en !== 1'b0 || test_bench.tim_pready !== 1'b0) begin
        $display ("=-Initialization Test FAILED --");
        end else begin
        $display ("--Initialization Test PASSED---");
        end
        @(posedge test_bench.sys_clk); 
        test_bench.sys_rst_n = 1;
    end
endtask
////write operation test///////
task write_operation_test();
    begin
        @(posedge test_bench.sys_clk); 
        test_bench.tim_pwrite = 1; 
        test_bench.tim_psel = 1; 
        test_bench.tim_penable = 0; 
        @(posedge test_bench.sys_clk); 
        test_bench.tim_penable = 1; 
        @(posedge test_bench.sys_clk);
        /////checker tim_pready////
        @(negedge test_bench.sys_clk);
        if (test_bench.tim_pready !== 1) begin
        $display ("tim_pready does not asserted"); 
        repeat (5) @(posedge test_bench.sys_clk); 
        $finish;
        end else
        if (u_dut.u_apb_slave.wr_en == 1) begin
        $display("=--Write operation Test FAILED--");
        end else begin
        $display("=--Write operation Test PASSED--");
        end
        @(posedge test_bench.sys_clk);
        test_bench.tim_pwrite = 0;
        test_bench.tim_psel = 0;
        test_bench.tim_penable = 0;
        /////////write completion test////
        @(posedge test_bench.sys_clk);
        if (u_dut.u_apb_slave.wr_en != 0 || test_bench.tim_pready!==0) begin
        $display("---Write conpletion Test FAILED--");
        end else begin
        $display("--Write completion Test PASSED--");
        end
    end
endtask
//////read operation test//// //////////////////
task read_operation_test;
    begin
        @(posedge test_bench.sys_clk); 
        test_bench.tim_pwrite = 0; 
        test_bench.tim_psel = 1;
        test_bench.tim_penable = 0;
        @(posedge test_bench.sys_clk); 
        test_bench.tim_penable = 1; @(posedge test_bench.sys_clk);
        /////checker tim pready//
        @(negedge test_bench.sys_clk);
        if (test_bench.tim_pready !== 1) begin 
        $display ("tim_pready does not asserted"); 
        repeat (5) @(posedge test_bench.sys_clk); 
        $finish;
        end else
        if (u_dut.u_apb_slave.rd_en !== 1) begin
        $display ("-Read operation Test FAILED-");
        end else begin
        $display("- -Read operation Test PASSED--");
        end
        @(posedge test_bench.sys_clk); test_bench.tim_pwrite = 0;
        test_bench.tim_psel = 0;
        test_bench.tim_penable = 0;
        @(posedge test_bench.sys_clk);
        if (u_dut.u_apb_slave.rd_en !== 0 | test_bench.tim_pready != 0) begin
        $display("-Read completion Test FAILED-");
        end else begin
        $display("-Read completion Test PASSED-");
        end
    end
endtask
 
//////PREADY timing check/////// 
task pready_timing_check;
    begin
        @(posedge test_bench.sys_clk); 
        test_bench.tim_pwrite = 1; 
        test_bench.tim_psel = 1; 
        test_bench.tim_penable = 0; 
        @(posedge test_bench.sys_clk); 
        test_bench.tim_penable = 1; 
        @(posedge test_bench.sys_clk); 
        @(negedge test_bench.sys_clk);
        if (test_bench.tim_pready !== 1) begin
        $display("-PREADY timing check FAILED-");
        end else begin
        $display("--PREADY timing check PASSED-");
        end
        @(posedge test_bench.sys_clk); 
        test_bench.tim_pwrite = 0; 
        test_bench.tim_psel = 0; 
        test_bench.tim_penable = 0;
    end
endtask

task run_test();
    begin
        initialization_test;
        @(posedge test_bench.sys_clk);
        write_operation_test;
        @(posedge test_bench.sys_clk);
        read_operation_test;
        @(posedge test_bench.sys_clk);
        pready_timing_check;
        @(posedge test_bench.sys_clk); 
        idle_state_check;
        @(posedge test_bench.sys_clk);
        reset_behavior_test;
    end
endtask