// // ============================================================
// // Assertions for 4-bit adder
// // Bind these into the DUT or include in TB
// // ============================================================

// module adder_assertions #(
//     parameter WIDTH = 4
// )(
//     input logic [WIDTH-1:0] a,
//     input logic [WIDTH-1:0] b,
//     input logic             cin,
//     input logic [WIDTH-1:0] sum,
//     input logic             cout,
//     input logic             ovflow
// );

//     // ── Assertion 1 ──────────────────────────────────────
//     // sum must always equal lower WIDTH bits of a+b+cin
//     // this is the fundamental correctness check
//     property sum_correct;
//         (sum == (a + b + cin) % (2**WIDTH));
//     endproperty
//     assert_sum_correct: assert property (sum_correct)
//         else $display("ASSERTION FAILED: sum_correct — a=%0h b=%0h cin=%0b sum=%0h expected=%0h",
//                        a, b, cin, sum, (a+b+cin) % (2**WIDTH));

//     // ── Assertion 2 ──────────────────────────────────────
//     // cout must be 1 when full result exceeds WIDTH bits
//     property cout_correct;
//         (cout == ((a + b + cin) >= (2**WIDTH)));
//     endproperty
//     assert_cout_correct: assert property (cout_correct)
//         else $display("ASSERTION FAILED: cout_correct — a=%0h b=%0h cin=%0b cout=%0b",
//                        a, b, cin, cout);

//     // ── Assertion 3 ──────────────────────────────────────
//     // overflow: both inputs same sign, result different sign
//     property ovflow_correct;
//         logic signed_a, signed_b, signed_sum;
//         (ovflow == (
//             (~a[WIDTH-1] & ~b[WIDTH-1] &  sum[WIDTH-1]) |
//             ( a[WIDTH-1] &  b[WIDTH-1] & ~sum[WIDTH-1])
//         ));
//     endproperty
//     assert_ovflow_correct: assert property (ovflow_correct)
//         else $display("ASSERTION FAILED: ovflow — a=%0h b=%0h sum=%0h ovflow=%0b",
//                        a, b, sum, ovflow);

//     // ── Assertion 4 ──────────────────────────────────────
//     // when a=0 and b=0 and cin=0 — sum must be 0
//     property zero_add;
//         (a == 0 && b == 0 && cin == 0) |-> (sum == 0 && cout == 0 && ovflow == 0);
//     endproperty
//     assert_zero_add: assert property (zero_add)
//         else $display("ASSERTION FAILED: zero_add — sum=%0h cout=%0b ovflow=%0b",
//                        sum, cout, ovflow);

//     // ── Assertion 5 ──────────────────────────────────────
//     // ovflow and cout are independent — no forced relationship
//     // this assertion just monitors when both are high simultaneously
//     // (not an error but worth tracking)
//     property both_flags;
//         (cout == 1 && ovflow == 1);
//     endproperty
//     cover_both_flags: cover property (both_flags)
//         $display("COVERAGE HIT: both cout and ovflow asserted — a=%0h b=%0h cin=%0b",
//                   a, b, cin);

// endmodule