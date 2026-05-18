`timescale 1ns/1ps
module tb_reset_load;
    parameter WIDTH = 4;

    logic clk, rst, enable, direction, serial_in, load;
    logic [WIDTH-1:0] load_data, data_out;

    shift_reg #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst(rst), .enable(enable),
        .direction(direction), .serial_in(serial_in),
        .load(load), .load_data(load_data), .data_out(data_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task tick; @(posedge clk); #1; endtask

    task check(input [WIDTH-1:0] exp, input string name);
        if (data_out === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | data_out=%0h", name, data_out);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=%0h exp=%0h", name, data_out, exp);
        end
    endtask

    initial begin
        $display("=========================================");
        $display("  Reset and Load Priority Test");
        $display("=========================================");

        rst=1; enable=0; direction=0; serial_in=0; load=0; load_data=0;
        tick; tick;
        check(4'h0, "initial_reset");
        rst = 0;

        // load data and start shifting
        load=1; load_data=4'hA; tick; load=0;
        enable=1; direction=0; serial_in=1;
        tick;
        check(4'h5, "shift_before_reset");

        // reset during active shift
        rst = 1;
        tick;
        check(4'h0, "reset_during_shift");
        rst = 0;

        // verify shifting works after reset
        load=1; load_data=4'h3; tick; load=0;
        enable=1; direction=0; serial_in=0;
        tick;
        check(4'h6, "shift_after_reset");

        // test load vs enable priority
        // load=1 and enable=1 simultaneously — load must win
        enable=1; load=1; load_data=4'hC; direction=0; serial_in=1;
        tick;
        check(4'hC, "load_priority_over_enable");
        load = 0;

        // test load all zeros
        enable=0; load=1; load_data=4'h0;
        tick;
        check(4'h0, "load_zeros");
        load = 0;

        // test load all ones
        load=1; load_data=4'hF;
        tick;
        check(4'hF, "load_ones");
        load = 0;

        // reset mid-load
        rst=1; load=1; load_data=4'hA;
        tick;
        check(4'h0, "reset_priority_over_load");
        rst=0; load=0;

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule