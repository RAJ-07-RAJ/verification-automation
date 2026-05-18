`timescale 1ns/1ps
module tb_boundary;
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
        $display("  Boundary Test");
        $display("=========================================");

        rst=1; enable=0; direction=0; serial_in=0; load=0; load_data=0;
        tick; tick;
        rst = 0;

        // test 1 — full left shift with serial_in=0
        // load all ones, shift left 4 times with serial_in=0
        // after 4 shifts — all zeros
        load=1; load_data=4'hF; tick; load=0;
        enable=1; direction=0; serial_in=0;
        tick; tick; tick; tick;
        check(4'h0, "full_left_shift_zeros");

        // test 2 — full right shift with serial_in=1
        // load all zeros, shift right 4 times with serial_in=1
        // after 4 shifts — all ones
        enable=0; load=1; load_data=4'h0; tick; load=0;
        enable=1; direction=1; serial_in=1;
        tick; tick; tick; tick;
        check(4'hF, "full_right_shift_ones");

        // test 3 — MSB boundary left shift
        // data=4'b1000, shift left — MSB must disappear
        enable=0; load=1; load_data=4'b1000; tick; load=0;
        enable=1; direction=0; serial_in=0;
        tick;
        check(4'b0000, "msb_boundary_left");

        // test 4 — LSB boundary right shift
        // data=4'b0001, shift right — LSB must disappear
        enable=0; load=1; load_data=4'b0001; tick; load=0;
        enable=1; direction=1; serial_in=0;
        tick;
        check(4'b0000, "lsb_boundary_right");

        // test 5 — alternating serial_in left shift
        // load 0, shift in 1,0,1,0
        enable=0; load=1; load_data=4'h0; tick; load=0;
        enable=1; direction=0;
        serial_in=1; tick; check(4'b0001, "alt_left_1");
        serial_in=0; tick; check(4'b0010, "alt_left_2");
        serial_in=1; tick; check(4'b0101, "alt_left_3");
        serial_in=0; tick; check(4'b1010, "alt_left_4");

        // test 6 — direction change mid shift
        enable=0; load=1; load_data=4'b1100; tick; load=0;
        enable=1; direction=0; serial_in=0;
        tick;
        check(4'b1000, "dir_change_before");
        direction = 1; serial_in = 0;
        tick;
        check(4'b0100, "dir_change_after");

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule