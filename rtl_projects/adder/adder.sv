// ============================================================
// Module    : adder
// Function  : Parameterised N-bit adder with carry-out
// Engineer  : (your name)
// ============================================================

module adder #(
    parameter WIDTH = 4
)(
    input  logic [WIDTH-1:0]  a,      // operand A
    input  logic [WIDTH-1:0]  b,      // operand B
    input  logic              cin,    // carry in
    output logic [WIDTH-1:0]  sum,    // sum result
    output logic              cout,   // carry out
    output logic              ovflow  // signed overflow flag
);

    // one extra bit captures carry out
    logic [WIDTH:0] result;

    assign result = {1'b0, a} + {1'b0, b} + cin;

    assign sum    = result[WIDTH-1:0];
    assign cout   = result[WIDTH];

    // signed overflow:
    // occurs when two positives produce negative
    // or two negatives produce positive
    assign ovflow = (~a[WIDTH-1] & ~b[WIDTH-1] &  sum[WIDTH-1]) |
                    ( a[WIDTH-1] &  b[WIDTH-1] & ~sum[WIDTH-1]);

endmodule