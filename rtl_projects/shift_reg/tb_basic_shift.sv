`timescale 1ns/1ps
module tb_basic_shift;
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
        $display("  Basic Shift Test");
        $display("=========================================");

        // initialise
        rst=1; enable=0; direction=0; serial_in=0; load=0; load_data=0;
        tick; tick;
        check(4'h0, "reset_check");
        rst = 0;

        // parallel load 4'hA = 4'b1010
        load=1; load_data=4'hA;
        tick;
        check(4'hA, "parallel_load");
        load = 0;

        // shift left, serial_in=0 — 4'b1010 → 4'b0100
        enable=1; direction=0; serial_in=0;
        tick;
        check(4'h4, "shift_left_0");

        // shift left again — 4'b0100 → 4'b1000
        tick;
        check(4'h8, "shift_left_1");

        // shift left, serial_in=1 — 4'b1000 → 4'b0001
        serial_in = 1;
        tick;
        check(4'h1, "shift_left_serial1");

        // load 4'hA again for right shift test
        enable=0; load=1; load_data=4'hA;
        tick;
        check(4'hA, "reload_for_right");
        load=0;

        // shift right, serial_in=0 — 4'b1010 → 4'b0101
        enable=1; direction=1; serial_in=0;
        tick;
        check(4'h5, "shift_right_0");

        // shift right again — 4'b0101 → 4'b0010
        tick;
        check(4'h2, "shift_right_1");

        // shift right, serial_in=1 — 4'b0010 → 4'b1001
        serial_in = 1;
        tick;
        check(4'h9, "shift_right_serial1");

        // hold — enable=0, data should not change
        enable = 0;
        tick;
        check(4'h9, "hold_check");
        tick;
        check(4'h9, "hold_check2");

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule