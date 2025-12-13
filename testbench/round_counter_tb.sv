`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_tb_pkg::*;

module round_counter_tb();

    // testbench variables
    localparam DUT_NAME = "round_counter";
    bit test_result = TEST_SUCCESS;

    // DUT signals
    logic clk;
    logic rst_n;
    logic mode;
    logic incr;
    round rnd;

    round_counter DUT (
        .*
    );

    initial begin : clk_gen
        clk = 1'b0;
        forever #20 clk = ~clk;
    end

    initial begin : main
        // init
        rst_n = 1'b0;
        mode = P12_MODE;
        incr = NO_INCR;

        @(posedge clk);
        rst_n = 1'b1;
        incr = DO_INCR;

        @(posedge clk);
        for (int r = P12_INIT; r < 16; r++) begin
            if (rnd != r) begin
                $display("expected: %h actual : %h", r, rnd);
                test_result = TEST_FAILED;
            end
            if (r == 14)
                mode = P8_MODE;
            @(posedge clk);
        end

        for (int r = P8_INIT; r < 16; r++) begin
            if (rnd != r) begin
                $display("expected: %h actual : %h", r, rnd);
                test_result = TEST_FAILED;
            end
            @(posedge clk);
        end

        // return if the test succeeded or failed
        display_result(test_result, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : round_counter_tb