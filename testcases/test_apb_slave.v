///// Initialization Test /////
task initialization_test;
    begin
        @(posedge test_bench.sys_clk);
        test_bench.sys_rst_n = 0; // Assert reset
        @(posedge test_bench.sys_clk);
        // Check initial states
        if (u_dut.u_apb_slave.wr_en !== 1'b0 || 
            u_dut.u_apb_slave.rd_en !== 1'b0 || 
            test_bench.tim_pready !== 1'b0) 
        begin
            $display("=- Initialization Test FAILED --");
        end else begin
            $display("-- Initialization Test PASSED --");
        end
        @(posedge test_bench.sys_clk);
        test_bench.sys_rst_n = 1; // Deassert reset
    end
endtask

///// Write Operation Test /////
task write_operation_test;
    begin
        @(posedge test_bench.sys_clk);
        // Start write transaction
        test_bench.tim_pwrite = 1;
        test_bench.tim_psel = 1;
        test_bench.tim_penable = 0;
        @(posedge test_bench.sys_clk);
        test_bench.tim_penable = 1;

        @(posedge test_bench.sys_clk);
        // Check PREADY assertion
        @(negedge test_bench.sys_clk);
        if (test_bench.tim_pready !== 1) begin
            $display("PREADY not asserted during write operation");
            repeat (5) @(posedge test_bench.sys_clk);
            $finish;
        end else if (u_dut.u_apb_slave.wr_en !== 1) begin
            $display("=- Write Operation Test FAILED --");
        end else begin
            $display("=- Write Operation Test PASSED --");
        end

        // End write transaction
        @(posedge test_bench.sys_clk);
        test_bench.tim_pwrite = 0;
        test_bench.tim_psel = 0;
        test_bench.tim_penable = 0;

        // Verify write completion
        @(posedge test_bench.sys_clk);
        if (u_dut.u_apb_slave.wr_en !== 0 || test_bench.tim_pready !== 0) begin
            $display("-- Write Completion Test FAILED --");
        end else begin
            $display("-- Write Completion Test PASSED --");
        end
    end
endtask

///// Read Operation Test /////
task read_operation_test;
    begin
        @(posedge test_bench.sys_clk);
        // Start read transaction
        test_bench.tim_pwrite = 0;
        test_bench.tim_psel = 1;
        test_bench.tim_penable = 0;
        @(posedge test_bench.sys_clk);
        test_bench.tim_penable = 1;

        @(posedge test_bench.sys_clk);
        // Check PREADY assertion
        @(negedge test_bench.sys_clk);
        if (test_bench.tim_pready !== 1) begin
            $display("PREADY not asserted during read operation");
            repeat (5) @(posedge test_bench.sys_clk);
            $finish;
        end else if (u_dut.u_apb_slave.rd_en !== 1) begin
            $display("=- Read Operation Test FAILED --");
        end else begin
            $display("-- Read Operation Test PASSED --");
        end

        // End read transaction
        @(posedge test_bench.sys_clk);
        test_bench.tim_pwrite = 0;
        test_bench.tim_psel = 0;
        test_bench.tim_penable = 0;

        // Verify read completion
        @(posedge test_bench.sys_clk);
        if (u_dut.u_apb_slave.rd_en !== 0 || test_bench.tim_pready !== 0) begin
            $display("-- Read Completion Test FAILED --");
        end else begin
            $display("-- Read Completion Test PASSED --");
        end
    end
endtask

///// PREADY Timing Check /////
task pready_timing_check;
    begin
        @(posedge test_bench.sys_clk);
        // Start write transaction
        test_bench.tim_pwrite = 1;
        test_bench.tim_psel = 1;
        test_bench.tim_penable = 0;
        @(posedge test_bench.sys_clk);
        test_bench.tim_penable = 1;

        // Check PREADY timing
        @(posedge test_bench.sys_clk);
        @(negedge test_bench.sys_clk);
        if (test_bench.tim_pready !== 1) begin
            $display("-- PREADY Timing Check FAILED --");
        end else begin
            $display("-- PREADY Timing Check PASSED --");
        end

        // End transaction
        @(posedge test_bench.sys_clk);
        test_bench.tim_pwrite = 0;
        test_bench.tim_psel = 0;
        test_bench.tim_penable = 0;
    end
endtask

///// Idle State Check /////
task idle_state_check;
    begin
        @(posedge test_bench.sys_clk);
        if (u_dut.u_apb_slave.wr_en !== 0 || 
            u_dut.u_apb_slave.rd_en !== 0 || 
            test_bench.tim_psel !== 0 || 
            test_bench.tim_penable !== 0) 
        begin
            $display("-- Idle State Check FAILED --");
        end else begin
            $display("-- Idle State Check PASSED --");
        end
    end
endtask

///// Reset Behavior Test /////
task reset_behavior_test;
    begin
        @(posedge test_bench.sys_clk);
        test_bench.sys_rst_n = 0; // Assert reset
        @(posedge test_bench.sys_clk);
        // Check all signals are in reset state
        if (u_dut.u_apb_slave.wr_en !== 0 || 
            u_dut.u_apb_slave.rd_en !== 0 || 
            test_bench.tim_pready !== 0) 
        begin
            $display("-- Reset Behavior Test FAILED --");
        end else begin
            $display("-- Reset Behavior Test PASSED --");
        end
        test_bench.sys_rst_n = 1; // Deassert reset
    end
endtask

///// Run Test /////
task run_test;
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
