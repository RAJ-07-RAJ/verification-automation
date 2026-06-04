`timescale 1ns/1ps
module tb_uart_top;

    parameter CLK_FREQ  = 100;
    parameter BAUD_RATE = 10;

    logic       clk, rst;
    logic       tx_start;
    logic [7:0] tx_data;
    logic       tx_out, tx_busy, tx_done;
    logic [7:0] rx_data;
    logic       rx_valid, rx_busy, rx_error;

    // instantiate top — this is integration level
    uart_top #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk      (clk),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx_out   (tx_out),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done),
        .rx_in    (tx_out),    // LOOPBACK: tx_out → rx_in
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .rx_busy  (rx_busy),
        .rx_error (rx_error)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count  = 0;
    integer fail_count  = 0;
    integer error_count = 0;

    task tick; @(posedge clk); #1; endtask

    task wait_rx_valid;
        integer timeout = 0;
        while (!rx_valid && timeout < 10000) begin
            if (rx_error) begin
                error_count++;
                $display("UVM_ERROR: rx_error during wait");
            end
            tick; timeout++;
        end
    endtask

    // send one byte, wait for RX to receive it, compare
    task loopback_byte(input [7:0] data, input string name);
        tx_data  = data;
        tx_start = 1;
        tick;
        tx_start = 0;

        wait_rx_valid;

        if (rx_data === data) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | sent=0x%0h rcvd=0x%0h",
                      name, data, rx_data);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | sent=0x%0h rcvd=0x%0h",
                      name, data, rx_data);
        end

        tick; tick; // settle before next
    endtask

    integer i;

    initial begin
        $display("=========================================");
        $display("  UART Top Integration Test");
        $display("  TX looped back to RX internally");
        $display("=========================================");

        $dumpfile("rtl_projects/uart_tx/logs/uart_top.vcd");
        $dumpvars(0, tb_uart_top);

        rst=1; tx_start=0; tx_data=0;
        tick; tick; rst=0; tick;

        // ── corner case bytes first ───────────────────────
        $display("\n--- Corner case bytes ---");
        loopback_byte(8'h00, "loopback_0x00");
        loopback_byte(8'hFF, "loopback_0xFF");
        loopback_byte(8'h55, "loopback_0x55");
        loopback_byte(8'hAA, "loopback_0xAA");
        loopback_byte(8'h01, "loopback_0x01");
        loopback_byte(8'h80, "loopback_0x80");
        loopback_byte(8'hA5, "loopback_0xA5");
        loopback_byte(8'h5A, "loopback_0x5A");

        // ── random loopback — 50 bytes ────────────────────
        $display("\n--- Random loopback (50 bytes) ---");
        for (i = 0; i < 50; i++) begin
            loopback_byte(
                $urandom_range(0, 255),
                $sformatf("random_%0d", i)
            );
        end

        // ── verify no framing errors ──────────────────────
        if (error_count == 0) begin
            pass_count++;
            $display("UVM_INFO: [PASS] no_framing_errors");
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] framing_errors=%0d", error_count);
        end

        // ── tx_done and rx_valid both fire ────────────────
        $display("\n--- Flag integrity ---");
        tx_data=8'h42; tx_start=1; tick; tx_start=0;
        begin
            integer timeout = 0;
            integer td = 0;
            integer rv = 0;
            while ((td==0 || rv==0) && timeout < 10000) begin
                if (tx_done)  td = 1;
                if (rx_valid) rv = 1;
                tick; timeout++;
            end
            if (td) begin
                pass_count++;
                $display("UVM_INFO: [PASS] tx_done_observed");
            end else begin
                fail_count++;
                $display("UVM_ERROR: [FAIL] tx_done_never_observed");
            end
            if (rv) begin
                pass_count++;
                $display("UVM_INFO: [PASS] rx_valid_observed");
            end else begin
                fail_count++;
                $display("UVM_ERROR: [FAIL] rx_valid_never_observed");
            end
        end

        $display("\n=========================================");
        $display("  UART TOP INTEGRATION SUMMARY");
        $display("  Passed        : %0d", pass_count);
        $display("  Failed        : %0d", fail_count);
        $display("  Framing errors: %0d", error_count);
        if (fail_count == 0 && error_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule