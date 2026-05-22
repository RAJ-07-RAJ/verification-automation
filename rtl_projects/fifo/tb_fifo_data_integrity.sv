`timescale 1ns/1ps
module tb_fifo_data_integrity;
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

    task check_data(input [WIDTH-1:0] exp, input string name);
        if (rd_data === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | rd_data=%0h exp=%0h", name, rd_data, exp);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=%0h exp=%0h", name, rd_data, exp);
        end
    endtask

    // write queue for reference model
    logic [WIDTH-1:0] ref_queue [0:DEPTH-1];
    integer ref_wr = 0;
    integer ref_rd = 0;
    integer i;

    initial begin
        $display("=========================================");
        $display("  FIFO Data Integrity Test");
        $display("=========================================");

        rst=1; wr_en=0; rd_en=0; wr_data=0;
        tick; tick; rst=0;

        // write known sequence 0x01 to 0x08
        $display("\n--- Write sequence 1 to 8 ---");
        wr_en = 1;
        for (i=1; i<=DEPTH; i++) begin
            wr_data       = i[WIDTH-1:0];
            ref_queue[ref_wr % DEPTH] = wr_data;
            ref_wr++;
            tick;
        end
        wr_en = 0;

        // read back and verify order
        $display("\n--- Read and verify order ---");
        rd_en = 1;
        for (i=0; i<DEPTH; i++) begin
            tick;
            check_data(ref_queue[ref_rd % DEPTH],
                       $sformatf("order_check_%0d", i));
            ref_rd++;
        end
        rd_en = 0;

        // pointer wrap test — fill again after drain
        $display("\n--- Pointer wrap test ---");
        ref_wr = 0; ref_rd = 0;
        wr_en = 1;
        for (i=0; i<DEPTH; i++) begin
            wr_data = 8'hA0 + i[7:0];
            ref_queue[ref_wr % DEPTH] = wr_data;
            ref_wr++;
            tick;
        end
        wr_en = 0;

        rd_en = 1;
        for (i=0; i<DEPTH; i++) begin
            tick;
            check_data(ref_queue[ref_rd % DEPTH],
                       $sformatf("wrap_check_%0d", i));
            ref_rd++;
        end
        rd_en = 0;

        // simultaneous read and write — data integrity
        $display("\n--- Simultaneous read/write ---");
        // prime with one entry
        wr_en=1; wr_data=8'h11; tick; wr_en=0;
        // now write and read simultaneously
        wr_en=1; rd_en=1; wr_data=8'h22;
        tick;
        // read should give 8'h11 (first in)
        rd_en=0; wr_en=0;
        check_data(8'h11, "simul_rw_read");
        // now read the 8'h22
        rd_en=1; tick; rd_en=0;
        check_data(8'h22, "simul_rw_second");

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule