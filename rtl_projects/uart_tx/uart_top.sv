// ============================================================
// Module    : uart_top
// Function  : UART top-level — TX and RX as one IP block
//             Internal loopback connect for testing
//             In real use: tx_out goes to pin, rx_in from pin
// ============================================================

module uart_top #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  logic       clk,
    input  logic       rst,

    // TX interface
    input  logic       tx_start,
    input  logic [7:0] tx_data,
    output logic       tx_out,
    output logic       tx_busy,
    output logic       tx_done,

    // RX interface
    input  logic       rx_in,
    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       rx_busy,
    output logic       rx_error
);

    uart_tx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .clk      (clk),
        .rst      (rst),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx_out   (tx_out),
        .tx_busy  (tx_busy),
        .tx_done  (tx_done)
    );

    uart_rx #(
        .CLK_FREQ (CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .clk      (clk),
        .rst      (rst),
        .rx_in    (rx_in),
        .rx_data  (rx_data),
        .rx_valid (rx_valid),
        .rx_busy  (rx_busy),
        .rx_error (rx_error)
    );

endmodule