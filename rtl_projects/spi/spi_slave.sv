// ============================================================
// Module    : spi_slave
// Function  : SPI Slave — Mode 0 (CPOL=0 CPHA=0)
//             - samples MOSI on rising SCLK
//             - shifts MISO out on falling SCLK
//             - CS active LOW enables slave
//             - echoes received byte back (loopback slave)
// ============================================================

module spi_slave (
    input  logic       clk,
    input  logic       rst,
    input  logic       sclk,          // SPI clock from master
    input  logic       cs_n,          // chip select active LOW
    input  logic       mosi,          // data from master

    output logic       miso,          // data to master
    output logic [7:0] rx_data,       // received byte
    output logic       rx_valid       // byte received
);

    logic [7:0] shift_in;
    logic [7:0] shift_out;
    logic [2:0] bit_cnt;
    logic       sclk_prev;
    logic       cs_prev;
    logic       active;

    assign miso   = shift_out[7];  // MSB first out
    assign active = ~cs_n;

    always_ff @(posedge clk) begin
        if (rst) begin
            shift_in  <= 8'h00;
            shift_out <= 8'h00;
            bit_cnt   <= 7;
            sclk_prev <= 1'b0;
            cs_prev   <= 1'b1;
            rx_data   <= 8'h00;
            rx_valid  <= 1'b0;
        end
        else begin
            rx_valid  <= 1'b0;    // default
            sclk_prev <= sclk;
            cs_prev   <= cs_n;

            // CS falling edge — prepare for transfer
            if (cs_prev && !cs_n) begin
                bit_cnt   <= 7;
                shift_in  <= 8'h00;
            end

            if (active) begin
                // rising SCLK — sample MOSI
                if (!sclk_prev && sclk) begin
                    shift_in <= {shift_in[6:0], mosi};
                end

                // falling SCLK — shift out MISO
                if (sclk_prev && !sclk) begin
                    if (bit_cnt > 0) begin
                        shift_out <= {shift_out[6:0], 1'b0};
                        bit_cnt   <= bit_cnt - 1;
                    end
                end
            end

            // CS rising edge — byte complete
            if (!cs_prev && cs_n) begin
                rx_data   <= shift_in;
                rx_valid  <= 1'b1;
                // echo back received byte for loopback
                shift_out <= shift_in;
            end
        end
    end

endmodule