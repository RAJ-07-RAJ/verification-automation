`timescale 1ns/1ps
module tb_fifo_basic;
    parameter WIDTH = 8;
    parameter DEPTH = 8;

    logic clk, rst, wr_en, rd_en;
    logic [WIDTH-1:0] wr_data, rd_data;
    logic full, empty;
    logic [$clog2(DEPTH):0] count;

    fifo #(.WIDTH(WIDTH),.DEPTH(DEPTH)) dut (
        .clk(clk),.rst(rst),.wr_en(wr_en),.wr_data(wr_data),
        .rd_en(rd_en),.rd_data(rd_data),
        .full(full),.empty(empty),.count(count)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task tick; @(posedge clk); #1; endtask

    task check_flags(
        input exp_full, exp_empty,
        input [$clog2(DEPTH):0] exp_count,
        input string name
    );
        if (full===exp_full && empty===exp_empty && count===exp_count) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | full=%0b empty=%0b count=%0d",
                      name, full, empty, count);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | full=%0b(%0b) empty=%0b(%0b) count=%0d(%0d)",
                      name, full,exp_full, empty,exp_empty, count,exp_count);
        end
    endtask

    task check_data(input [WIDTH-1:0] exp, input string name);
        if (rd_data === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | rd_data=%0h", name, rd_data);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=%0h exp=%0h", name, rd_data, exp);
        end
    endtask

    integer i;
    initial begin
        $display("=========================================");
        $display("  FIFO Basic Test");
        $display("=========================================");

        // reset
        rst=1; wr_en=0; rd_en=0; wr_data=0;
        tick; tick;
        check_flags(0, 1, 0, "after_reset");
        rst = 0;

        // write 1 entry
        wr_en=1; wr_data=8'hAA; rd_en=0;
        tick;
        wr_en = 0;
        check_flags(0, 0, 1, "after_write_1");

        // write until full
        $display("\n--- Fill FIFO ---");
        wr_en = 1;
        for (i=1; i<DEPTH; i++) begin
            wr_data = i;
            tick;
        end
        wr_en = 0;
        check_flags(1, 0, DEPTH, "fifo_full");

        // write to full — must be ignored
        $display("\n--- Overflow attempt ---");
        wr_en=1; wr_data=8'hFF;
        tick;
        wr_en = 0;
        check_flags(1, 0, DEPTH, "overflow_blocked");

        // read first entry (was 0xAA)
        $display("\n--- Read from full ---");
        rd_en = 1;
        tick;
        rd_en = 0;
        check_data(8'hAA, "first_read");
        check_flags(0, 0, DEPTH-1, "after_first_read");

        // drain completely
        $display("\n--- Drain FIFO ---");
        rd_en = 1;
        for (i=0; i<DEPTH-1; i++) begin
            tick;
        end
        rd_en = 0;
        check_flags(0, 1, 0, "fifo_empty");

        // read from empty — must be ignored
        $display("\n--- Underflow attempt ---");
        rd_en = 1;
        tick;
        rd_en = 0;
        check_flags(0, 1, 0, "underflow_blocked");

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule