// ============================================================
// Module    : fifo
// Function  : Synchronous FIFO with full/empty flags
//             - single clock domain
//             - parameterised width and depth
//             - simultaneous read/write supported
//             - registered outputs
// ============================================================

module fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 8
)(
    input  logic              clk,
    input  logic              rst,

    // write port
    input  logic              wr_en,
    input  logic [WIDTH-1:0]  wr_data,

    // read port
    input  logic              rd_en,
    output logic [WIDTH-1:0]  rd_data,

    // status flags
    output logic              full,
    output logic              empty,
    output logic [$clog2(DEPTH):0] count  // number of entries
);

    // memory array
    logic [WIDTH-1:0] mem [0:DEPTH-1];

    // pointers
    logic [$clog2(DEPTH)-1:0] wr_ptr;
    logic [$clog2(DEPTH)-1:0] rd_ptr;

    // count tracks number of valid entries
    logic [$clog2(DEPTH):0] count_r;

    assign count = count_r;
    assign full  = (count_r == DEPTH);
    assign empty = (count_r == 0);

    always_ff @(posedge clk) begin
        if (rst) begin
            wr_ptr  <= 0;
            rd_ptr  <= 0;
            count_r <= 0;
            rd_data <= 0;
        end
        else begin
            // write — only when not full
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr      <= wr_ptr + 1;
            end

            // read — only when not empty
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr  <= rd_ptr + 1;
            end

            // count update
            case ({wr_en && !full, rd_en && !empty})
                2'b10: count_r <= count_r + 1; // write only
                2'b01: count_r <= count_r - 1; // read only
                2'b11: count_r <= count_r;     // simultaneous — no change
                2'b00: count_r <= count_r;     // no operation
            endcase
        end
    end

endmodule