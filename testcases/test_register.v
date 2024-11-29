///// Write Register Task /////
task write_register;
    input [11:0] address;
    input [31:0] data;
    begin
        @(posedge sys_clk);
        tim_psel = 1;
        tim_penable = 0;
        tim_paddr = address;
        tim_pwdata = data;
        tim_pwrite = 1;
        @(posedge sys_clk);
        tim_penable = 1;
        @(posedge sys_clk);
        tim_psel = 0;
        tim_penable = 0;
        tim_pwrite = 0;
        $display("WRITE: Address %h, Data %h", address, data);
    end
endtask

///// Read Register Task /////
task read_register;
    input [11:0] address;
    output [31:0] data;
    begin
        @(posedge sys_clk);
        tim_psel = 1;
        tim_penable = 0;
        tim_paddr = address;
        tim_pwrite = 0;
        @(posedge sys_clk);
        tim_penable = 1;
        @(posedge sys_clk);
        data = tim_prdata;
        tim_psel = 0;
        tim_penable = 0;
        $display("READ: Address %h, Data %h", address, data);
    end
endtask

///// Reset System Task /////
task reset_register;
    begin
        sys_rst_n = 0;
        @(posedge sys_clk);
        sys_rst_n = 1;
        $display("SYSTEM RESET COMPLETE");
    end
endtask

///// Verify Write-Read Consistency Task /////
task verify_register;
    input [11:0] address;
    input [31:0] expected_data;
    reg [31:0] read_data;
    begin
        read_register(address, read_data);
        if (read_data === expected_data) begin
            $display("PASS: Address %h contains expected value %h", address, expected_data);
        end else begin
            $display("FAIL: Address %h contains value %h, expected %h", address, read_data, expected_data);
        end
    end
endtask

///// Test Default Value Task /////
task check_default_value;
    input [11:0] address;
    input [31:0] default_value;
    reg [31:0] read_data;
    begin
        read_register(address, read_data);
        if (read_data === default_value) begin
            $display("PASS: Default value at address %h is %h", address, default_value);
        end else begin
            $display("FAIL: Default value at address %h is %h, expected %h", address, read_data, default_value);
        end
    end
endtask

///// Test Overwrite Register Task /////
task test_overwrite_register;
    input [11:0] address;
    input [31:0] data1, data2;
    reg [31:0] read_data;
    begin
        // Write first data
        write_register(address, data1);
        verify_register(address, data1);

        // Overwrite with second data
        write_register(address, data2);
        verify_register(address, data2);
    end
endtask

///// Test Invalid Address Access Task /////
task test_invalid_address;
    input [11:0] address;
    reg [31:0] read_data;
    begin
        read_register(address, read_data);
        if (read_data === 32'h0) begin
            $display("PASS: Invalid address %h returned default value 0", address);
        end else begin
            $display("FAIL: Invalid address %h returned unexpected value %h", address, read_data);
        end
    end
endtask

///// Run Test Task /////
task run_test;
    reg [31:0] read_data;
    begin
        // Reset system
        $display("----- RESETTING SYSTEM -----");
        reset_register;

        // Check default values
        $display("----- CHECKING DEFAULT VALUES -----");
        check_default_value(12'h00, 32'h0000_0000); // Control register default
        check_default_value(12'h04, 32'h0000_0000); // Data register 0 default

        // Write and verify register
        $display("----- TEST WRITE/READ TDR0 -----");
        write_register(12'h04, 32'h1234_5678);
        verify_register(12'h04, 32'h1234_5678);

        // Test overwriting data
        $display("----- TEST OVERWRITE DATA -----");
        test_overwrite_register(12'h04, 32'hAAAA_AAAA, 32'h5555_5555);

        // Test invalid write
        $display("----- TEST INVALID WRITE TO RESERVED BITS -----");
        test_invalid_address(12'h20); // Invalid address test

        // Test additional registers
        $display("----- TEST ADDITIONAL REGISTERS -----");
        write_register(12'h08, 32'hDEAD_BEEF);
        verify_register(12'h08, 32'hDEAD_BEEF);

        write_register(12'h0C, 32'hCAFEBABE);
        verify_register(12'h0C, 32'hCAFEBABE);

        // Test timer enable
        $display("----- TEST TIMER ENABLE -----");
        write_register(12'h00, 32'h0000_0001); // Enable timer
        verify_register(12'h00, 32'h0000_0001);

        // Finish tests
        $display("----- ALL TESTS COMPLETED -----");
        $finish;
    end
endtask
