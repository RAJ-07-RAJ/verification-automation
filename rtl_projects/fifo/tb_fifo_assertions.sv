`timescale 1ns/1ps
module tb_fifo_assertions;
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
    integer assert_fail = 0;

    task tick; @(posedge clk); #1; endtask

    // manual assertion checker — runs every cycle
    task check_invariants(input string phase);
        // assertion 1: count never exceeds DEPTH
        if (count > DEPTH) begin
            assert_fail++;
            $display("UVM_ERROR: ASSERTION FAIL [count_overflow] count=%0d > DEPTH=%0d at %s",
                      count, DEPTH, phase);
        end
        // assertion 2: full correct
        if (full !== (count == DEPTH)) begin
            assert_fail++;
            $display("UVM_ERROR: ASSERTION FAIL [full_flag] full=%0b count=%0d at %s",
                      full, count, phase);
        end
        // assertion 3: empty correct
        if (empty !== (count == 0)) begin
            assert_fail++;
            $display("UVM_ERROR: ASSERTION FAIL [empty_flag] empty=%0b count=%0d at %s",
                      empty, count, phase);
        end
        // assertion 4: full and empty cannot both be 1
        if (full === 1 && empty === 1) begin
            assert_fail++;
            $display("UVM_ERROR: ASSERTION FAIL [full_and_empty] both asserted at %s", phase);
        end
    endtask

    integer i;

    initial begin
        $display("=========================================");
        $display("  FIFO Assertion Test");
        $display("=========================================");

        rst=1; wr_en=0; rd_en=0; wr_data=0;
        tick; tick;
        check_invariants("after_reset");
        rst = 0;

        // write up to full checking invariants every cycle
        $display("\n--- Fill with assertion checks ---");
        wr_en = 1;
        for (i=0; i<DEPTH; i++) begin
            wr_data = i[WIDTH-1:0];
            tick;
            check_invariants($sformatf("write_%0d", i));
        end
        wr_en = 0;

        // assert full correctly
        if (full === 1) begin
            pass_count++;
            $display("UVM_INFO: [PASS] full_flag_asserted | count=%0d", count);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] full_flag_not_asserted | count=%0d", count);
        end

        // overflow attempt — count must not change
        wr_en=1; wr_data=8'hFF; tick; wr_en=0;
        check_invariants("overflow_attempt");
        if (count === DEPTH) begin
            pass_count++;
            $display("UVM_INFO: [PASS] overflow_blocked | count=%0d", count);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] overflow_not_blocked | count=%0d", count);
        end

        // drain with invariant checks
        $display("\n--- Drain with assertion checks ---");
        rd_en = 1;
        for (i=0; i<DEPTH; i++) begin
            tick;
            check_invariants($sformatf("read_%0d", i));
        end
        rd_en = 0;

        // assert empty correctly
        if (empty === 1) begin
            pass_count++;
            $display("UVM_INFO: [PASS] empty_flag_asserted | count=%0d", count);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] empty_flag_not_asserted | count=%0d", count);
        end

        // underflow attempt — count must stay 0
        rd_en=1; tick; rd_en=0;
        check_invariants("underflow_attempt");
        if (count === 0) begin
            pass_count++;
            $display("UVM_INFO: [PASS] underflow_blocked | count=%0d", count);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] underflow_not_blocked | count=%0d", count);
        end

        // reset mid operation
        $display("\n--- Reset mid operation ---");
        wr_en=1; wr_data=8'hAA; tick;
        wr_en=1; wr_data=8'hBB; tick;
        rst=1; tick; rst=0;
        check_invariants("after_mid_reset");
        if (count===0 && empty===1) begin
            pass_count++;
            $display("UVM_INFO: [PASS] reset_mid_op | count=%0d empty=%0b", count, empty);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] reset_mid_op | count=%0d empty=%0b", count, empty);
        end

        $display("\n=============================================");
        $display("  Functional checks : pass=%0d fail=%0d", pass_count, fail_count);
        $display("  Assertion failures: %0d", assert_fail);
        if (fail_count==0 && assert_fail==0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=============================================");
        $finish;
    end
endmodule