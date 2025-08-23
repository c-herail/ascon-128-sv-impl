`timescale 1ns/1ps

import ascon_aead128_tb_pkg::*;

module mux21_tb();

    // testbench variables
    localparam DUT_NAME = "mux21";
    localparam SEL_A = 1'b0;
    localparam SEL_B = 1'b1;
    bit test_result = TEST_SUCCESS;

    // DUT variables
    localparam WIDTH = 8;
    logic             sel;
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [WIDTH-1:0] s;

    mux21 #(.WIDTH(WIDTH))
    DUT (
        .*
    );

    function void check_equal(logic [WIDTH-1:0] expected,
                              logic [WIDTH-1:0] actual);
        if (expected != actual) begin
            $display("Error, expected: %h, actual: %h\n", expected, actual);
            test_result = TEST_FAILED;
        end
    endfunction

    initial begin
        // init
        a = '0;
        b = '0;
        sel = 1'b0;

        // test mux() operation over random values
        for (int i = 0; i < 100; i++) begin
            // randomize inputs
            a = $urandom();
            b = $urandom();
            sel = $urandom();
            #0;
            // check output
            unique case (sel)
                SEL_A : begin
                    check_equal(s, a);
                end
                SEL_B : begin
                    check_equal(s, b);
                end
            endcase
            #20;
        end

        // return if the test succeeded or failed
        display_result(test_pass, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : mux21_tb