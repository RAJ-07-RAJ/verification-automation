`timescale 1ns/1ps

module tb_adder;

    parameter WIDTH = 4;

    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic             cin;
    logic [WIDTH-1:0] sum;
    logic             cout;
    logic             ovflow;

    // DUT
    adder #(.WIDTH(WIDTH)) dut (
        .a(a), .b(b), .cin(cin),
        .sum(sum), .cout(cout), .ovflow(ovflow)
    );

    // scoreboard counters
    integer pass_count  = 0;
    integer fail_count  = 0;
    integer test_count  = 0;

    // coverage counters (manual — Icarus has no covergroup)
    integer cov_cout_hit    = 0;
    integer cov_ovflow_hit  = 0;
    integer cov_cin_hit     = 0;
    integer cov_zero_hit    = 0;
    integer cov_max_hit     = 0;
    integer cov_both_flags  = 0;

    // reference model + scoreboard task
    task automatic check_result(
        input [WIDTH-1:0] in_a,
        input [WIDTH-1:0] in_b,
        input             in_cin,
        input string      test_name
    );
        logic [WIDTH:0]   full_result;
        logic [WIDTH-1:0] exp_sum;
        logic             exp_cout;
        logic             exp_ovflow;

        // reference model
        full_result = {1'b0,in_a} + {1'b0,in_b} + in_cin;
        exp_sum     = full_result[WIDTH-1:0];
        exp_cout    = full_result[WIDTH];
        exp_ovflow  = (~in_a[WIDTH-1] & ~in_b[WIDTH-1] &  exp_sum[WIDTH-1]) |
                      ( in_a[WIDTH-1] &  in_b[WIDTH-1] & ~exp_sum[WIDTH-1]);

        #1; // combinational settle

        test_count++;

        // ── assertion checks (manual) ───────────────────
        if (sum !== exp_sum || cout !== exp_cout || ovflow !== exp_ovflow) begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | a=%0h b=%0h cin=%0b", test_name, in_a, in_b, in_cin);
            if (sum !== exp_sum)
                $display("  sum    : got=%0h  exp=%0h", sum, exp_sum);
            if (cout !== exp_cout)
                $display("  cout   : got=%0b  exp=%0b", cout, exp_cout);
            if (ovflow !== exp_ovflow)
                $display("  ovflow : got=%0b  exp=%0b", ovflow, exp_ovflow);
        end else begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | a=%0h b=%0h cin=%0b | sum=%0h cout=%0b ovflow=%0b",
                      test_name, in_a, in_b, in_cin, sum, cout, ovflow);
        end

        // ── manual coverage sampling ────────────────────
        if (cout   == 1) cov_cout_hit++;
        if (ovflow == 1) cov_ovflow_hit++;
        if (in_cin == 1) cov_cin_hit++;
        if (in_a   == 0 || in_b == 0) cov_zero_hit++;
        if (in_a   == 4'hF || in_b == 4'hF) cov_max_hit++;
        if (cout   == 1 && ovflow == 1) cov_both_flags++;

    endtask

    initial begin
        $display("=============================================");
        $display("  4-bit Adder Self-Checking Testbench");
        $display("=============================================");

        // ── directed tests ────────────────────────────────
        $display("\n--- Directed Tests ---");
        a=4'h0; b=4'h0; cin=0; check_result(a,b,cin,"zero_add");
        a=4'h3; b=4'h4; cin=0; check_result(a,b,cin,"basic_add");
        a=4'h0; b=4'h0; cin=1; check_result(a,b,cin,"cin_only");
        a=4'hF; b=4'hF; cin=0; check_result(a,b,cin,"max_no_cin");
        a=4'hF; b=4'hF; cin=1; check_result(a,b,cin,"max_with_cin");
        a=4'b0111; b=4'b0001; cin=0; check_result(a,b,cin,"signed_ovflow_pos");
        a=4'b1000; b=4'b1000; cin=0; check_result(a,b,cin,"signed_ovflow_neg");
        a=4'hF; b=4'h1; cin=0; check_result(a,b,cin,"no_ovflow_mixed");
        a=4'b1000; b=4'b0111; cin=0; check_result(a,b,cin,"boundary_msb");
        a=4'hF; b=4'h0; cin=1; check_result(a,b,cin,"cin_at_max");
        a=4'h5; b=4'h5; cin=0; check_result(a,b,cin,"identical_ops");

        // ── exhaustive — all 512 combinations ────────────
        $display("\n--- Exhaustive (all 512 combinations) ---");
        begin
            integer ia, ib, ic;
            for (ia=0; ia<16; ia++) begin
                for (ib=0; ib<16; ib++) begin
                    for (ic=0; ic<2; ic++) begin
                        a   = ia[WIDTH-1:0];
                        b   = ib[WIDTH-1:0];
                        cin = ic[0];
                        check_result(a,b,cin,
                            $sformatf("exhaustive_a%0h_b%0h_c%0b",ia,ib,ic));
                    end
                end
            end
        end

        // ── scoreboard summary ────────────────────────────
        $display("\n=============================================");
        $display("  SCOREBOARD SUMMARY");
        $display("=============================================");
        $display("  Total   : %0d", test_count);
        $display("  Passed  : %0d", pass_count);
        $display("  Failed  : %0d", fail_count);

        // ── manual coverage report ────────────────────────
        $display("\n  COVERAGE SUMMARY");
        $display("  cout=1 hit       : %0d times", cov_cout_hit);
        $display("  ovflow=1 hit     : %0d times", cov_ovflow_hit);
        $display("  cin=1 hit        : %0d times", cov_cin_hit);
        $display("  zero operand hit : %0d times", cov_zero_hit);
        $display("  max operand hit  : %0d times", cov_max_hit);
        $display("  both flags hit   : %0d times", cov_both_flags);

        if (fail_count == 0)
            $display("\n  UVM_INFO: TEST PASSED - all %0d checks clean", test_count);
        else
            $display("\n  UVM_ERROR: TEST FAILED - %0d failures", fail_count);
        $display("=============================================");

        $finish;
    end

endmodule