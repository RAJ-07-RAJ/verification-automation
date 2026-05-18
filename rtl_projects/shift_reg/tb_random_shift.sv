`timescale 1ns/1ps
module tb_random_shift;
    parameter WIDTH = 4;

    logic clk, rst, enable, direction, serial_in, load;
    logic [WIDTH-1:0] load_data, data_out;

    shift_reg #(.WIDTH(WIDTH)) dut (
        .clk(clk), .rst(rst), .enable(enable),
        .direction(direction), .serial_in(serial_in),
        .load(load), .load_data(load_data), .data_out(data_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    // reference model — tracks expected state in software
    logic [WIDTH-1:0] ref_model;

    task tick; @(posedge clk); #1; endtask

    task check(input string name);
        if (data_out === ref_model) begin
            pass_count++;
            $display("UVM_INFO: [PASS] %s | data_out=%0h ref=%0h",
                      name, data_out, ref_model);
        end else begin
            fail_count++;
            $display("UVM_ERROR: [FAIL] %s | got=%0h exp=%0h",
                      name, data_out, ref_model);
        end
    endtask

    // apply one random stimulus and update reference model
    task random_stimulus(input integer iter);
        logic rand_en, rand_dir, rand_sin, rand_load;
        logic [WIDTH-1:0] rand_load_data;

        rand_en        = $urandom_range(0,1);
        rand_dir       = $urandom_range(0,1);
        rand_sin       = $urandom_range(0,1);
        rand_load      = $urandom_range(0,1);
        rand_load_data = $urandom_range(0,15);

        enable    = rand_en;
        direction = rand_dir;
        serial_in = rand_sin;
        load      = rand_load;
        load_data = rand_load_data;

        // update reference model to match RTL priority
        if (rand_load)
            ref_model = rand_load_data;
        else if (rand_en) begin
            if (rand_dir == 0)
                ref_model = {ref_model[WIDTH-2:0], rand_sin};
            else
                ref_model = {rand_sin, ref_model[WIDTH-1:1]};
        end
        // else hold — ref_model unchanged

        tick;
        check($sformatf("random_%0d", iter));
    endtask

    initial begin
        $display("=========================================");
        $display("  Random Shift Test (200 iterations)");
        $display("=========================================");

        // reset
        rst=1; enable=0; direction=0;
        serial_in=0; load=0; load_data=0;
        ref_model = 0;
        tick; tick;
        rst = 0;

        // run 200 random stimulus cycles
        begin
            integer i;
            for (i=0; i<200; i++) begin
                random_stimulus(i);
            end
        end

        $display("\n  Passed: %0d  Failed: %0d", pass_count, fail_count);
        if (fail_count == 0)
            $display("  UVM_INFO: TEST PASSED");
        else
            $display("  UVM_ERROR: TEST FAILED");
        $display("=========================================");
        $finish;
    end
endmodule