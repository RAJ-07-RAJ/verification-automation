// ============================================================
// Module    : uart_rx
// Function  : UART Receiver
//             - 8 data bits, 1 start bit, 1 stop bit (8N1)
//             - samples at middle of each bit period
//             - rx_valid pulses 1 cycle when byte received
//             - framing error detected if stop bit not HIGH
// ============================================================

module uart_rx #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       rx_in,          // serial input line
    output logic [7:0] rx_data,        // received byte
    output logic       rx_valid,       // 1-cycle pulse — data ready
    output logic       rx_busy,        // receiving in progress
    output logic       rx_error        // framing error — stop bit wrong
);

    localparam BAUD_DIV  = CLK_FREQ / BAUD_RATE;
    localparam HALF_DIV  = BAUD_DIV / 2;  // sample at mid-bit

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state;

    logic [$clog2(BAUD_DIV)-1:0] baud_cnt;
    logic [2:0]                   bit_idx;
    logic [7:0]                   rx_shift;
    logic                         rx_in_sync;  // synchronised input

    // 2-flop synchroniser on rx_in
    // prevents metastability from async input
    logic rx_ff1, rx_ff2;
    always_ff @(posedge clk) begin
        rx_ff1    <= rx_in;
        rx_ff2    <= rx_ff1;
    end
    assign rx_in_sync = rx_ff2;

    logic baud_tick;
    logic half_tick;
    assign baud_tick = (baud_cnt == BAUD_DIV - 1);
    assign half_tick = (baud_cnt == HALF_DIV - 1);

    always_ff @(posedge clk) begin
        if (rst) begin
            state     <= IDLE;
            baud_cnt  <= 0;
            bit_idx   <= 0;
            rx_shift  <= 0;
            rx_data   <= 0;
            rx_valid  <= 0;
            rx_busy   <= 0;
            rx_error  <= 0;
        end
        else begin
            rx_valid <= 0;  // default
            rx_error <= 0;  // default

            case (state)

                IDLE: begin
                    rx_busy  <= 0;
                    baud_cnt <= 0;
                    // detect start bit — falling edge (HIGH to LOW)
                    if (rx_in_sync == 0) begin
                        state   <= START;
                        rx_busy <= 1;
                    end
                end

                START: begin
                    // wait half baud to reach middle of start bit
                    // confirm it is still LOW (not a glitch)
                    if (half_tick) begin
                        if (rx_in_sync == 0) begin
                            baud_cnt <= 0;
                            bit_idx  <= 0;
                            state    <= DATA;
                        end else begin
                            // was a glitch — go back to IDLE
                            state   <= IDLE;
                            rx_busy <= 0;
                        end
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                DATA: begin
                    // sample at full baud period (middle of each bit)
                    if (baud_tick) begin
                        rx_shift[bit_idx] <= rx_in_sync;  // LSB first
                        baud_cnt          <= 0;
                        if (bit_idx == 7)
                            state <= STOP;
                        else
                            bit_idx <= bit_idx + 1;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                STOP: begin
                    if (baud_tick) begin
                        baud_cnt <= 0;
                        if (rx_in_sync == 1) begin
                            // valid stop bit
                            rx_data  <= rx_shift;
                            rx_valid <= 1;
                        end else begin
                            // framing error — stop bit not HIGH
                            rx_error <= 1;
                        end
                        rx_busy <= 0;
                        state   <= IDLE;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

            endcase
        end
    end

endmodule