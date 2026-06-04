`timescale 1ns/1ps
module tb_uart_tx;

    parameter CLK_FREQ  = 100;
    parameter BAUD_RATE = 10;
    parameter BAUD_DIV  = CLK_FREQ / BAUD_RATE;

    logic       clk, rst;
    logic       tx_start;
    logic [7:0] tx_data;
    logic       tx_out, tx_busy, tx_done;

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk), .rst(rst),
        .tx_start(tx_start), .tx_data(tx_data),
        .tx_out(tx_out), .tx_busy(tx_busy), .tx_done(tx_done)
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

    // send one byte, capture the frame bit by bit, verify
    task send_and_verify(input [7:0] data, input string name);
        integer i;
        logic [9:0] frame;  // start + 8 data + stop

        // start transmission
        tx_data  = data;
        tx_start = 1;
        tick;
        tx_start = 0;

        check(1, tx_busy, {name,"_busy_high"});

        // sample start bit
        frame[0] = tx_out;
        repeat(BAUD_DIV) tick;

        // sample 8 data bits
        for (i = 0; i < 8; i++) begin
            frame[i+1] = tx_out;
            repeat(BAUD_DIV) tick;
        end

        // sample stop bit
        frame[9] = tx_out;
        repeat(BAUD_DIV) tick;

        // verify frame structure
        check(0, frame[0], {name,"_start_bit_low"});
        check(1, frame[9], {name,"_stop_bit_high"});

        // verify each data bit LSB first
        for (i = 0; i < 8; i++) begin
            check(data[i], frame[i+1],
                  $sformatf("%s_bit%0d", name, i));
        end

        // verify done and busy cleared
        check(1, tx_done,  {name,"_done_pulse"});
        check(0, tx_busy,  {name,"_busy_cleared"});
    endtask

    initial begin
        $display("=========================================");
        $display("  UART TX Unit Test");
        $display("=========================================");

        $dumpfile("rtl_projects/uart_tx/logs/uart_tx_unit.vcd");
        $dumpvars(0, tb_uart_tx);

        // reset
        rst=1; tx_start=0; tx_data=0;
        tick; tick;
        check(1, tx_out,  "idle_line_high");
        check(0, tx_busy, "idle_busy_low");
        check(0, tx_done, "idle_done_low");
        rst=0; tick;

        // ── directed frame tests ──────────────────────────
        $display("\n--- Frame verification ---");
        send_and_verify(8'h55, "tx_0x55");  // 01010101
        send_and_verify(8'hAA, "tx_0xAA");  // 10101010
        send_and_verify(8'h00, "tx_0x00");  // all zeros
        send_and_verify(8'hFF, "tx_0xFF");  // all ones
        send_and_verify(8'h01, "tx_0x01");  // only LSB
        send_and_verify(8'h80, "tx_0x80");  // only MSB

        // ── tx_done is exactly 1 cycle ────────────────────
        $display("\n--- tx_done pulse width ---");
        tx_data=8'hA5; tx_start=1; tick; tx_start=0;
        begin
            integer timeout    = 0;
            integer done_cycles = 0;
            while (!tx_done && timeout < 10000) begin
                tick; timeout++;
            end
            while (tx_done) begin
                done_cycles++;
                tick;
            end
            if (done_cycles == 1) begin
                pass_count++;
                $display("UVM_INFO: [PASS] tx_done_single_cycle");
            end else begin
                fail_count++;
                $display("UVM_ERROR: [FAIL] tx_done_single_cycle | %0d cycles", done_cycles);
            end
        end

        // ── tx_start ignored during transmission ─────────
        $display("\n--- tx_start ignored during busy ---");
        tx_data=8'hCC; tx_start=1; tick; tx_start=0;
        repeat(BAUD_DIV * 2) tick;
        // try to hijack with new data
        tx_data=8'hDD; tx_start=1; tick; tx_start=0;
        check(1, tx_busy, "still_busy_after_second_start");
        begin
            integer timeout = 0;
            while (!tx_done && timeout < 10000) begin
                tick; timeout++;
            end
        end
        tick;
        // send 0xDD properly now and verify it goes through clean
        send_and_verify(8'hDD, "after_busy_clears");

        // ── reset during transmission ─────────────────────
        $display("\n--- Reset mid-transmission ---");
        tx_data=8'hBB; tx_start=1; tick; tx_start=0;
        repeat(BAUD_DIV * 3) tick;
        check(1, tx_busy, "busy_before_reset");
        rst=1; tick; rst=0; tick;
        check(1, tx_out,  "tx_high_after_reset");
        check(0, tx_busy, "busy_cleared_by_reset");
        check(0, tx_done, "done_not_set_by_reset");

        $display("\n=========================================");
        $display("  TX UNIT TEST SUMMARY");
        $display("  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule