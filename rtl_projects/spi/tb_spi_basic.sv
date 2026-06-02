`timescale 1ns/1ps
module tb_spi_basic;

    parameter CLK_DIV = 2;

    logic       clk, rst;
    logic       start;
    logic [7:0] mosi_data;
    logic       sclk, cs_n, mosi;
    logic [7:0] miso_data;
    logic       done;

    // slave signals
    logic       miso;
    logic [7:0] slave_rx;
    logic       slave_valid;

    // master instance
    spi_master #(.CLK_DIV(CLK_DIV)) master (
        .clk(clk), .rst(rst),
        .start(start), .mosi_data(mosi_data), .miso(miso),
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi),
        .miso_data(miso_data), .done(done)
    );

    // slave instance — wired to master
    spi_slave slave (
        .clk(clk), .rst(rst),
        .sclk(sclk), .cs_n(cs_n), .mosi(mosi),
        .miso(miso), .rx_data(slave_rx), .rx_valid(slave_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task tick; @(posedge clk); #1; endtask

    task check(input [7:0] exp, input [7:0] got, input string name);
        if (got === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | got=0x%0h exp=0x%0h", name, got, exp);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=0x%0h exp=0x%0h", name, got, exp);
        end
    endtask

    task check1(input exp, input got, input string name);
        if (got === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s", name);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=%0b exp=%0b", name, got, exp);
        end
    endtask

    // send one byte and wait for done
    task send_byte(input [7:0] data, input string name);
        integer timeout;
        mosi_data = data;
        start     = 1;
        tick;
        start     = 0;
        // wait for done
        timeout   = 0;
        while (!done && timeout < 10000) begin
            tick; timeout++;
        end
        if (!done) begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s — TIMEOUT waiting for done", name);
        end
    endtask

    initial begin
        $display("=========================================");
        $display("  SPI Basic Test");
        $display("=========================================");

        $dumpfile("rtl_projects/spi/logs/spi_basic.vcd");
        $dumpvars(0, tb_spi_basic);

        rst=1; start=0; mosi_data=0;
        tick; tick;
        check1(1, cs_n,  "idle_cs_deasserted");
        check1(0, sclk,  "idle_sclk_low");
        rst = 0; tick;

        // test 1 — send 0x55
        $display("\n--- Send 0x55 ---");
        send_byte(8'h55, "tx_0x55");
        tick;
        check(8'h55, slave_rx, "slave_received_0x55");
        check1(1, slave_valid, "slave_valid_0x55");

        // test 2 — send 0xAA
        $display("\n--- Send 0xAA ---");
        send_byte(8'hAA, "tx_0xAA");
        tick;
        check(8'hAA, slave_rx, "slave_received_0xAA");

        // test 3 — send 0x00
        $display("\n--- Send 0x00 ---");
        send_byte(8'h00, "tx_0x00");
        tick;
        check(8'h00, slave_rx, "slave_received_0x00");

        // test 4 — send 0xFF
        $display("\n--- Send 0xFF ---");
        send_byte(8'hFF, "tx_0xFF");
        tick;
        check(8'hFF, slave_rx, "slave_received_0xFF");

        // test 5 — MSB first check
        // send 0x80 — first MOSI bit must be 1
        $display("\n--- MSB first check ---");
        mosi_data = 8'h80;
        start     = 1; tick; start = 0;
        // sample MOSI right after CS goes low
        repeat(3) tick;
        check1(1, mosi, "msb_first_0x80");
        while (!done) tick;

        // send 0x01 — first MOSI bit must be 0
        mosi_data = 8'h01;
        start     = 1; tick; start = 0;
        repeat(3) tick;
        check1(0, mosi, "msb_first_0x01_lsb_last");
        while (!done) tick;

        // test 6 — CS_N LOW during transfer
        $display("\n--- CS protocol check ---");
        mosi_data = 8'hA5;
        start     = 1; tick; start = 0;
        repeat(5) tick;
        check1(0, cs_n, "cs_low_during_transfer");
        while (!done) tick;
        check1(1, cs_n, "cs_high_after_done");

        // test 7 — done is 1 cycle pulse
        $display("\n--- done pulse check ---");
        send_byte(8'h42, "tx_for_done_check");
        check1(1, done, "done_asserted");
        tick;
        check1(0, done, "done_cleared");

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule