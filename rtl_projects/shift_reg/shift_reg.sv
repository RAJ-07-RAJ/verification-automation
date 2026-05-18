// ============================================================
// Module    : shift_reg
// Function  : Parameterised N-bit shift register
//             - shift left or right based on direction
//             - serial input on shift
//             - parallel load capability
//             - synchronous reset
// ============================================================

module shift_reg #(
    parameter WIDTH = 4
)(
    input  logic              clk,
    input  logic              rst,
    input  logic              enable,
    input  logic              direction,  // 0=left  1=right
    input  logic              serial_in,  // bit shifted in
    input  logic              load,       // parallel load enable
    input  logic [WIDTH-1:0]  load_data,  // parallel load data
    output logic [WIDTH-1:0]  data_out
);

    always_ff @(posedge clk) begin
        if (rst) begin
            data_out <= {WIDTH{1'b0}};
        end
        else if (load) begin
            // parallel load takes priority over shift
            data_out <= load_data;
        end
        else if (enable) begin
            if (direction == 1'b0)
                // shift left — MSB shifts out, serial_in enters LSB
                data_out <= {data_out[WIDTH-2:0], serial_in};
            else
                // shift right — LSB shifts out, serial_in enters MSB
                data_out <= {serial_in, data_out[WIDTH-1:1]};
        end
        // if enable=0 and load=0 — hold value
    end

endmodule