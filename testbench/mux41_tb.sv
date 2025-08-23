`timescale 1ns/1ps

import ascon_aead128_tb_pkg::*;

module mux41_tb();

    // testbench variables
    localparam DUT_NAME = "mux41";
    localparam SEL_A = 2'b00;
    localparam SEL_B = 2'b01;
    localparam SEL_C = 2'b10;
    localparam SEL_D = 2'b11;
    bit test_result = TEST_SUCCESS;

    // DUT variables
    localparam WIDTH = 8;
    logic [1:0]       sel;
    logic [WIDTH-1:0] a;
    logic [WIDTH-1:0] b;
    logic [WIDTH-1:0] c;
    logic [WIDTH-1:0] d;
    logic [WIDTH-1:0] s;

    mux41 #(.WIDTH(WIDTH))
    DUT (
        .*
    );

    function void check_equal(logic [WIDTH-1:0] expected,
                              logic [WIDTH-1:0] actual);
        if (expected != actual) begin
            $display("expected: %h, actual: %h\n", expected, actual);
            test_result = TEST_FAILED;
        end
    endfunction

    initial begin
        // init
        a = '0;
        b = '0;
        c = '0;
        d = '0;
        sel = 2'b0;

        // test mux() operation over random values
        for (int i = 0; i < 100; i++) begin
            // randomize inputs
            a = $urandom();
            b = $urandom();
            c = $urandom();
            d = $urandom();
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
                SEL_C : begin
                    check_equal(s, c);
                end
                SEL_D : begin
                    check_equal(s, d);
                end
            endcase
            #20;
        end

        // return if the test succeeded or failed
        display_result(test_pass, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : mux41_tb