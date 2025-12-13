`timescale 1ns/1ps

import ascon_aead128_tb_pkg::*;

module data_reg_tb();

    // DUT variables
    localparam WIDTH = 8;
    logic             clk;
    logic             rst_n;
    logic             en;
    logic [WIDTH-1:0] d;
    logic [WIDTH-1:0] q;

    // testbench variables
    localparam DUT_NAME = "data_reg";
    logic [WIDTH-1:0] previous_d;
    bit test_result = TEST_SUCCESS;

    data_reg #(
        .WIDTH(WIDTH)
    ) DUT (
        .*
    );

    function void check_equal(logic [WIDTH-1:0] expected,
                              logic [WIDTH-1:0] actual);
        if (expected != actual) begin
            $display("expected: %d, actual: %d\n", expected, actual);
            test_result = TEST_FAILED;
        end
    endfunction

    initial begin : clk_gen
        clk = 1'b0;
        forever #20 clk = ~clk;
    end

    initial begin : main
        // init
        previous_d = '0;
        rst_n = 1'b0;
        en = 1'b0;
        d = '0;

        @(posedge clk);
        rst_n = 1'b1;

        // test data_reg over random values
        for (int i = 0; i < 50; i++) begin
            en = $urandom();
            d  = $urandom();

            if (en == 1'b1) begin
                previous_d = d;
            end

            @(posedge clk);
            #1;

            if (q != previous_d) begin
                test_result = TEST_FAILED;
                $display("time: %d expected : %h, actual : %h", $time, previous_d, q);
            end
        end

        // return if the test succeeded or failed
        display_result(test_result, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : data_reg_tb