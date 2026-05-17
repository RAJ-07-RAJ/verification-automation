// Testbench for 4-bit counter
// Tests: reset, counting, enable/disable, wrap-around

`timescale 1ns/1ps

module tb_counter;

    // signals
    logic        clk;
    logic        rst;
    logic        enable;
    logic [3:0]  count;

    // instantiate the DUT (Device Under Test)
    counter dut (
        .clk    (clk),
        .rst    (rst),
        .enable (enable),
        .count  (count)
    );

    // clock generation — 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // test sequence
    integer errors = 0;

    initial begin
        $display("===========================================");
        $display("  4-bit Counter Testbench");
        $display("===========================================");

        // apply reset
        rst    = 1;
        enable = 0;
        @(posedge clk); #1;
        @(posedge clk); #1;

        $display("[%0t] Reset applied. Count = %0d", $time, count);

        if (count !== 4'd0)
            $display("UVM_ERROR: Reset check FAILED. Expected=0 Got=%0d", count);
        else
            $display("UVM_INFO: Reset check PASSED. Count=%0d", count);

        // release reset, enable counting
        rst    = 0;
        enable = 1;
        $display("[%0t] Reset released. Counting enabled.", $time);

        // count from 0 to 15 and check each value
        repeat(16) begin
            @(posedge clk); #1;
            $display("[%0t] UVM_INFO: Count = %0d", $time, count);
        end

        // check wrap-around — after 15 should go back to 0
        // count is now at some value after 16 clocks
        // let it run 3 more and verify
        @(posedge clk); #1;
        @(posedge clk); #1;
        @(posedge clk); #1;

        // test enable = 0 — counter should freeze
        enable = 0;
        @(posedge clk); #1;
        $display("[%0t] UVM_INFO: Enable disabled. Count should freeze at %0d", $time, count);
        @(posedge clk); #1;
        $display("[%0t] UVM_INFO: After one clock with enable=0. Count = %0d", $time, count);

        // re-enable
        enable = 1;
        @(posedge clk); #1;
        $display("[%0t] UVM_INFO: Enable re-asserted. Count = %0d", $time, count);

        // test reset mid-count
        rst = 1;
        @(posedge clk); #1;
        $display("[%0t] UVM_INFO: Mid-count reset. Count = %0d", $time, count);

        if (count !== 4'd0) begin
            $display("UVM_ERROR: Mid-count reset FAILED. Expected=0 Got=%0d", count);
            errors = errors + 1;
        end else
            $display("UVM_INFO: Mid-count reset PASSED. Count=%0d", count);

        rst = 0;

        $display("===========================================");
        if (errors == 0)
            $display("UVM_INFO: TEST PASSED - 0 errors");
        else
            $display("UVM_ERROR: TEST FAILED - %0d errors", errors);
        $display("===========================================");
        $finish;
       
    end

endmodule