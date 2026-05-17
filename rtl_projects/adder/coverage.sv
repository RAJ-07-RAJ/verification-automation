// // ============================================================
// // Functional Coverage Model — 4-bit adder
// // ============================================================

// module adder_coverage #(
//     parameter WIDTH = 4
// )(
//     input logic [WIDTH-1:0] a,
//     input logic [WIDTH-1:0] b,
//     input logic             cin,
//     input logic [WIDTH-1:0] sum,
//     input logic             cout,
//     input logic             ovflow
// );

//     covergroup adder_cg;

//         // cover all values of a
//         cp_a: coverpoint a {
//             bins zero        = {0};
//             bins one         = {1};
//             bins mid         = {[2:6]};
//             bins pos_max     = {7};           // max positive signed
//             bins neg_min     = {8};           // min negative signed
//             bins mid_high    = {[9:13]};
//             bins almost_max  = {14};
//             bins max         = {15};
//         }

//         // cover all values of b
//         cp_b: coverpoint b {
//             bins zero        = {0};
//             bins one         = {1};
//             bins mid         = {[2:6]};
//             bins pos_max     = {7};
//             bins neg_min     = {8};
//             bins mid_high    = {[9:13]};
//             bins almost_max  = {14};
//             bins max         = {15};
//         }

//         // carry in
//         cp_cin: coverpoint cin {
//             bins no_carry  = {0};
//             bins carry     = {1};
//         }

//         // carry out
//         cp_cout: coverpoint cout {
//             bins no_cout   = {0};
//             bins cout_set  = {1};
//         }

//         // overflow
//         cp_ovflow: coverpoint ovflow {
//             bins no_ovflow   = {0};
//             bins ovflow_set  = {1};
//         }

//         // sum boundary values
//         cp_sum: coverpoint sum {
//             bins zero        = {0};
//             bins max         = {15};
//             bins pos_max_sgn = {7};
//             bins neg_min_sgn = {8};
//         }

//         // cross: a and b — exhaustive input space
//         cx_ab: cross cp_a, cp_b;

//         // cross: operands with cin
//         cx_ab_cin: cross cp_a, cp_b, cp_cin;

//         // cross: flags — all flag combinations
//         cx_flags: cross cp_cout, cp_ovflow;

//         // equal operands
//         cp_equal: coverpoint (a == b) {
//             bins equal     = {1};
//             bins not_equal = {0};
//         }

//         // zero operand
//         cp_zero_op: coverpoint (a == 0 || b == 0) {
//             bins has_zero  = {1};
//             bins no_zero   = {0};
//         }

//         // same sign operands — where overflow is possible
//         cp_same_sign: coverpoint (a[WIDTH-1] == b[WIDTH-1]) {
//             bins same_sign = {1};
//             bins diff_sign = {0};
//         }

//     endgroup

//     adder_cg cg_inst = new();

//     // sample on any input change — combinational design
//     always @(*) begin
//         cg_inst.sample();
//     end

// endmodule