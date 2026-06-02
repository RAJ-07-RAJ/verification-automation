`timescale 1ns/1ps
module tb_spi_loopback;

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

    task tick; @(posedge clk); #1; endtask

    task wait_done;
        integer timeout = 0;
        while (!done && timeout < 10000) begin
            tick; timeout++;
        end
    endtask

    // loopback: send byte_a, slave echoes it
    // send byte_b next transfer — master gets byte_a back
    task loopback_test(
        input [7:0] byte_a,
        input [7:0] byte_b,
        input string name
    );
        // transfer 1 — send byte_a, slave latches it
        mosi_data = byte_a;
        start     = 1; tick; start = 0;
        wait_done;
        tick; tick;

        // transfer 2 — send byte_b, master gets byte_a back (echo)
        mosi_data = byte_b;
        start     = 1; tick; start = 0;
        wait_done;
        tick;

        // check slave received byte_b
        if (slave_rx === byte_b) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s_slave | rx=0x%0h", name, slave_rx);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s_slave | got=0x%0h exp=0x%0h",
                      name, slave_rx, byte_b);
        end

        // check master received byte_a back (loopback echo)
        if (miso_data === byte_a) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s_master | echo=0x%0h", name, miso_data);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s_master | got=0x%0h exp=0x%0h",
                      name, miso_data, byte_a);
        end
    endtask

    integer i;
    logic [7:0] prev_sent;

    initial begin
        $display("=========================================");
        $display("  SPI Loopback Test");
        $display("=========================================");

        $dumpfile("rtl_projects/spi/logs/spi_loopback.vcd");
        $dumpvars(0, tb_spi_loopback);

        rst=1; start=0; mosi_data=0;
        tick; tick; rst=0; tick;

        // directed loopback tests
        $display("\n--- Directed loopback ---");
        loopback_test(8'h55, 8'hAA, "loopback_55_AA");
        loopback_test(8'h00, 8'hFF, "loopback_00_FF");
        loopback_test(8'hA5, 8'h5A, "loopback_A5_5A");
        loopback_test(8'h01, 8'h80, "loopback_01_80");
        loopback_test(8'hFF, 8'h00, "loopback_FF_00");

        // random loopback — 30 pairs
        $display("\n--- Random loopback (30 pairs) ---");
        prev_sent = $urandom_range(0,255);
        mosi_data = prev_sent;
        start=1; tick; start=0;
        wait_done; tick; tick;

        for (i=0; i<30; i++) begin
            logic [7:0] curr;
            curr      = $urandom_range(0, 255);
            mosi_data = curr;
            start=1; tick; start=0;
            wait_done; tick;

            if (miso_data === prev_sent) begin
                pass_count++;
                $display("UVM_INFO: [PASS] random_%0d | echo=0x%0h", i, miso_data);
            end else begin
                fail_count++;
                $display("UVM_ERROR: [FAIL] random_%0d | got=0x%0h exp=0x%0h",
                          i, miso_data, prev_sent);
            end
            prev_sent = curr;
            tick;
        end

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule