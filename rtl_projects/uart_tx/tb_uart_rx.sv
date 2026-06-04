`timescale 1ns/1ps
module tb_uart_rx;

    parameter CLK_FREQ  = 100;
    parameter BAUD_RATE = 10;
    parameter BAUD_DIV  = CLK_FREQ / BAUD_RATE;

    logic       clk, rst;
    logic       rx_in;
    logic [7:0] rx_data;
    logic       rx_valid, rx_busy, rx_error;

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk), .rst(rst),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .rx_busy(rx_busy),
        .rx_error(rx_error)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task tick; @(posedge clk); #1; endtask

    task check(input exp, input got, input string name);
        if (got === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s", name);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=%0b exp=%0b", name, got, exp);
        end
    endtask

    task check_data(input [7:0] exp, input string name);
        if (rx_data === exp) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | rx_data=0x%0h", name, rx_data);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=0x%0h exp=0x%0h",
                      name, rx_data, exp);
        end
    endtask

    // drive a valid UART frame onto rx_in manually
    // this is the TB acting as a software TX driver
    task drive_frame(input [7:0] data);
        integer i;
        rx_in = 0;                   // start bit
        repeat(BAUD_DIV) tick;
        for (i = 0; i < 8; i++) begin // data bits LSB first
            rx_in = data[i];
            repeat(BAUD_DIV) tick;
        end
        rx_in = 1;                   // stop bit
        repeat(BAUD_DIV) tick;
    endtask

    // drive frame with corrupted stop bit
    task drive_bad_frame(input [7:0] data);
        integer i;
        rx_in = 0;
        repeat(BAUD_DIV) tick;
        for (i = 0; i < 8; i++) begin
            rx_in = data[i];
            repeat(BAUD_DIV) tick;
        end
        rx_in = 0;                   // bad stop bit — LOW
        repeat(BAUD_DIV) tick;
        rx_in = 1;
        repeat(BAUD_DIV) tick;
    endtask

    // wait for rx_valid with timeout
    task wait_valid;
        integer timeout = 0;
        while (!rx_valid && timeout < 5000) begin
            tick; timeout++;
        end
    endtask

    initial begin
        $display("=========================================");
        $display("  UART RX Unit Test");
        $display("=========================================");

        $dumpfile("rtl_projects/uart_tx/logs/uart_rx_unit.vcd");
        $dumpvars(0, tb_uart_rx);

        rst=1; rx_in=1;
        tick; tick;
        check(0, rx_busy,  "idle_busy_low");
        check(0, rx_valid, "idle_valid_low");
        rst=0; tick;

        // ── receive known bytes ───────────────────────────
        $display("\n--- Receive directed bytes ---");
        fork
            drive_frame(8'h55);
            begin wait_valid; check_data(8'h55, "rx_0x55"); end
        join
        tick;
        check(0, rx_valid, "rx_valid_cleared_0x55");

        fork
            drive_frame(8'hAA);
            begin wait_valid; check_data(8'hAA, "rx_0xAA"); end
        join

        fork
            drive_frame(8'h00);
            begin wait_valid; check_data(8'h00, "rx_0x00"); end
        join

        fork
            drive_frame(8'hFF);
            begin wait_valid; check_data(8'hFF, "rx_0xFF"); end
        join

        fork
            drive_frame(8'h01);
            begin wait_valid; check_data(8'h01, "rx_0x01"); end
        join

        fork
            drive_frame(8'h80);
            begin wait_valid; check_data(8'h80, "rx_0x80"); end
        join

        // ── rx_valid is 1 cycle only ──────────────────────
        $display("\n--- rx_valid pulse width ---");
        fork
            drive_frame(8'hA5);
            begin
                integer done_cycles = 0;
                wait_valid;
                while (rx_valid) begin
                    done_cycles++; tick;
                end
                if (done_cycles == 1) begin
                    pass_count++;
                    $display("UVM_INFO: [PASS] rx_valid_single_cycle");
                end else begin
                    fail_count++;
                    $display("UVM_ERROR: [FAIL] rx_valid_single_cycle | %0d cycles",
                              done_cycles);
                end
            end
        join

        // ── glitch rejection ──────────────────────────────
        $display("\n--- Glitch rejection ---");
        rx_in = 0; repeat(2) tick;   // short glitch < HALF_DIV
        rx_in = 1; repeat(BAUD_DIV * 3) tick;
        check(0, rx_valid, "glitch_rejected");
        check(0, rx_busy,  "no_busy_on_glitch");

        // ── framing error ────────────────────────────────
        $display("\n--- Framing error (bad stop bit) ---");
        fork
            drive_bad_frame(8'hAB);
            begin
                integer timeout = 0;
                while (!rx_error && !rx_valid && timeout < 5000) begin
                    tick; timeout++;
                end
                check(1, rx_error,  "framing_error_detected");
                check(0, rx_valid,  "no_valid_on_framing_error");
            end
        join

        // ── reset during reception ────────────────────────
        $display("\n--- Reset during reception ---");
        rx_in = 0; repeat(BAUD_DIV) tick;
        rx_in = 1; repeat(BAUD_DIV/2) tick;
        rst=1; tick; rst=0; rx_in=1; tick;
        check(0, rx_busy,  "reset_clears_busy");
        check(0, rx_valid, "reset_no_spurious_valid");

        // ── back-to-back frames ───────────────────────────
        $display("\n--- Back-to-back frames ---");
        fork
            begin
                drive_frame(8'h12);
                drive_frame(8'h34);
                drive_frame(8'h56);
            end
            begin
                wait_valid; check_data(8'h12, "back2back_1");
                wait_valid; check_data(8'h34, "back2back_2");
                wait_valid; check_data(8'h56, "back2back_3");
            end
        join

        $display("\n=========================================");
        $display("  RX UNIT TEST SUMMARY");
        $display("  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule