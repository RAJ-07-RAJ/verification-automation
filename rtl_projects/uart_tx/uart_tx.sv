// ============================================================
// Module    : uart_tx
// Function  : UART Transmitter
//             - 8 data bits, 1 start bit, 1 stop bit
//             - no parity (8N1 format)
//             - parameterised baud rate and clock frequency
//             - tx_busy signal indicates transmission in progress
// ============================================================

module uart_tx #(
    parameter CLK_FREQ  = 50_000_000,  // 50 MHz
    parameter BAUD_RATE = 115_200
)(
    input  logic       clk,
    input  logic       rst,
    input  logic       tx_start,        // pulse to start transmission
    input  logic [7:0] tx_data,         // byte to transmit
    output logic       tx_out,          // serial output line
    output logic       tx_busy,         // 1 = transmitting
    output logic       tx_done          // 1-cycle pulse when done
);

    // baud tick counter — counts clk cycles per baud period
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    // FSM states
    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        START = 2'b01,
        DATA  = 2'b10,
        STOP  = 2'b11
    } state_t;

    state_t state;

    logic [$clog2(BAUD_DIV)-1:0] baud_cnt;   // baud rate counter
    logic [2:0]                   bit_idx;    // which data bit (0-7)
    logic [7:0]                   tx_shift;   // shift register

    // baud tick — fires once per baud period
    logic baud_tick;
    assign baud_tick = (baud_cnt == BAUD_DIV - 1);

    always_ff @(posedge clk) begin
        if (rst) begin
            state    <= IDLE;
            baud_cnt <= 0;
            bit_idx  <= 0;
            tx_out   <= 1'b1;   // idle line is HIGH
            tx_busy  <= 1'b0;
            tx_done  <= 1'b0;
            tx_shift <= 8'h00;
        end
        else begin
            tx_done <= 1'b0;    // default — pulse only

            case (state)

                IDLE: begin
                    tx_out   <= 1'b1;   // line idle HIGH
                    tx_busy  <= 1'b0;
                    baud_cnt <= 0;
                    if (tx_start) begin
                        tx_shift <= tx_data;
                        state    <= START;
                        tx_busy  <= 1'b1;
                    end
                end

                START: begin
                    tx_out <= 1'b0;     // start bit is LOW
                    if (baud_tick) begin
                        baud_cnt <= 0;
                        bit_idx  <= 0;
                        state    <= DATA;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                DATA: begin
                    tx_out <= tx_shift[bit_idx];  // LSB first
                    if (baud_tick) begin
                        baud_cnt <= 0;
                        if (bit_idx == 7) begin
                            state <= STOP;
                        end else
                            bit_idx <= bit_idx + 1;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

                STOP: begin
                    tx_out <= 1'b1;     // stop bit is HIGH
                    if (baud_tick) begin
                        baud_cnt <= 0;
                        tx_done  <= 1'b1;
                        tx_busy  <= 1'b0;
                        state    <= IDLE;
                    end else
                        baud_cnt <= baud_cnt + 1;
                end

            endcase
        end
    end

endmodule