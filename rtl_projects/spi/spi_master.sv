// ============================================================
// Module    : spi_master
// Function  : SPI Master — Mode 0 (CPOL=0 CPHA=0)
//             - shifts 8 bits out on MOSI, captures on MISO
//             - CS active LOW
//             - SCLK generated internally from clk divider
//             - MSB first
// ============================================================

module spi_master #(
    parameter CLK_DIV = 4    // SCLK = clk / (2 * CLK_DIV)
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       start,         // pulse to begin transfer
    input  logic [7:0] mosi_data,     // byte to send
    input  logic       miso,          // data from slave

    output logic       sclk,          // SPI clock
    output logic       cs_n,          // chip select active LOW
    output logic       mosi,          // master out slave in
    output logic [7:0] miso_data,     // captured byte from slave
    output logic       done           // 1-cycle pulse transfer complete
);

    typedef enum logic [1:0] {
        IDLE     = 2'b00,
        TRANSFER = 2'b01,
        FINISH   = 2'b10
    } state_t;

    state_t state;

    logic [$clog2(CLK_DIV)-1:0] clk_cnt;   // clock divider counter
    logic [2:0]                  bit_cnt;   // bit index 7 downto 0
    logic [7:0]                  shift_out; // MOSI shift register
    logic [7:0]                  shift_in;  // MISO shift register
    logic                        sclk_r;    // registered SCLK

    // sclk output
    assign sclk = (state == TRANSFER) ? sclk_r : 1'b0;

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            cs_n      <= 1'b1;
            mosi      <= 1'b0;
            sclk_r    <= 1'b0;
            clk_cnt   <= 0;
            bit_cnt   <= 7;
            shift_out <= 8'h00;
            shift_in  <= 8'h00;
            miso_data <= 8'h00;
            done      <= 1'b0;
        end
        else begin
            done <= 1'b0;  // default

            case (state)

                IDLE: begin
                    cs_n   <= 1'b1;
                    sclk_r <= 1'b0;
                    mosi   <= 1'b0;
                    if (start) begin
                        shift_out <= mosi_data;
                        bit_cnt   <= 7;
                        clk_cnt   <= 0;
                        cs_n      <= 1'b0;  // assert CS
                        state     <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    clk_cnt <= clk_cnt + 1;

                    if (clk_cnt == CLK_DIV - 1) begin
                        clk_cnt <= 0;
                        sclk_r  <= ~sclk_r;  // toggle SCLK

                        if (!sclk_r) begin
                            // rising edge — sample MISO
                            shift_in <= {shift_in[6:0], miso};
                        end else begin
                            // falling edge — shift out MOSI
                            mosi <= shift_out[bit_cnt];

                            if (bit_cnt == 0) begin
                                state <= FINISH;
                            end else begin
                                bit_cnt <= bit_cnt - 1;
                            end
                        end
                    end
                end

                FINISH: begin
                    // wait one more half-period then deassert
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLK_DIV - 1) begin
                        cs_n      <= 1'b1;
                        sclk_r    <= 1'b0;
                        mosi      <= 1'b0;
                        miso_data <= shift_in;
                        done      <= 1'b1;
                        state     <= IDLE;
                        clk_cnt   <= 0;
                    end
                end

            endcase
        end
    end

endmodule