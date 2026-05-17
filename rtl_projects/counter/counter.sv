// 4-bit Up Counter
// - counts from 0 to 15
// - wraps back to 0 after 15
// - synchronous reset — resets to 0 on clock edge when rst is high

module counter (
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    output logic [3:0]  count
);

    always_ff @(posedge clk) begin
        if (rst)
            count <= 4'b0000;
        else if (enable)
            count <= count + 1;
    end

endmodule