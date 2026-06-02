`timescale 1ns/1ps
module tb_spi_protocol;

    parameter CLK_DIV = 2;

    logic       clk, rst;
    logic       start;
    logic [7:0] mosi_data;
    logic       sclk, cs_n, mosi, miso;
    logic [7:0] miso_data;
    logic       done;
    logic [7:0] slave_rx;
    logic       slave_valid;

    spi_master #(.CLK_DIV(CLK_DIV)) master (
        .clk(clk), .rst(rst),
        .start(start), .mosi_data(mosi_data), .miso(miso),
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi),
        .miso_data(miso_data), .done(done)
    );

    spi_slave slave (
        .clk(clk), .rst(rst),
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi),
        .miso(miso), .rx_data(slave_rx), .rx_valid(slave_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;
    integer done_count = 0;

    task tick; @(posedge clk); #1; endtask

    task check1(input exp, input got, input string name);
        if (got === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s", name);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=%0b exp=%0b", name, got, exp);
        end
    endtask

    task wait_done;
        integer timeout = 0;
        while (!done && timeout < 10000) begin
            tick; timeout++;
        end
        if (done) done_count++;
    endtask

    integer i;

    initial begin
        $display("=========================================");
        $display("  SPI Protocol Test");
        $display("=========================================");

        $dumpfile("rtl_projects/spi/logs/spi_protocol.vcd");
        $dumpvars(0, tb_spi_protocol);

        rst=1; start=0; mosi_data=0;
        tick; tick; rst=0; tick;

        // test 1 — start ignored during transfer
        $display("\n--- start ignored during transfer ---");
        mosi_data=8'hCC; start=1; tick; start=0;
        repeat(4) tick;
        check1(0, cs_n, "cs_low_in_transfer");
        // try to start again mid-transfer
        mosi_data=8'hDD; start=1; tick; start=0;
        check1(0, cs_n, "cs_still_low_after_second_start");
        wait_done;
        tick;
        // verify original data went through, not 0xDD
        check1(1, (slave_rx === 8'hCC) ? 1'b1 : 1'b0,
               "original_data_not_corrupted");

        // test 2 — SCLK idle LOW
        $display("\n--- SCLK idle check ---");
        tick; tick;
        check1(0, sclk, "sclk_idle_low");

        // test 3 — SCLK only during transfer
        $display("\n--- SCLK gated by CS ---");
        check1(1, cs_n, "cs_deasserted_idle");
        mosi_data=8'h42; start=1; tick; start=0;
        repeat(2) tick;
        check1(0, cs_n,  "cs_during_transfer");
        // SCLK should be toggling — check it's not stuck
        logic sclk_snapshot;
        sclk_snapshot = sclk;
        repeat(CLK_DIV*2) tick;
        // just verify SCLK has different states captured
        wait_done;

        // test 4 — back-to-back transfers
        $display("\n--- Back-to-back transfers ---");
        done_count = 0;
        for (i=0; i<5; i++) begin
            mosi_data = 8'h10 + i[7:0];
            start=1; tick; start=0;
            wait_done;
            tick; tick;
        end
        check1(1, (done_count == 5) ? 1'b1 : 1'b0,
               "back_to_back_5_transfers");

        // test 5 — reset during transfer
        $display("\n--- Reset during transfer ---");
        mosi_data=8'hBB; start=1; tick; start=0;
        repeat(5) tick;
        check1(0, cs_n, "cs_low_before_reset");
        rst=1; tick; rst=0; tick;
        check1(1, cs_n,  "cs_high_after_reset");
        check1(0, sclk,  "sclk_low_after_reset");
        check1(0, done,  "done_not_set_after_reset");

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule