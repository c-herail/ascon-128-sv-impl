`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_tb_pkg::*;

module permutation_tb();

    // testbench variables
    localparam DUT_NAME = "permutation";
    bit      test_pass = TEST_SUCCESS;
    state_ex expected;

    // DUT variables
    round       rnd;
    ascon_state current_state;
    ascon_state next_state;

    permutation DUT (
        .*
    );

    initial begin
        // init
        expected = new();

        // perform p() operation over random values
        for (int i = 0; i < 100; i++) begin
            rnd = $urandom() % 16;
            if (rnd < 4'h4) rnd = ~rnd;
            expected.urandomize();
            current_state = expected.get();
            #0;
            if (expected.permutation(rnd).get() != next_state) begin
                test_pass = TEST_FAILED;
                display_states(next_state, expected.get());
            end
            #10;
        end

        current_state = '0;
      #100;
        $display("p8 start");

        // perform p8() operation over random initial values
        for (int i = 0; i < 10; i++) begin
            expected.urandomize();
            for (int r = 8; r < 16; r++) begin
                rnd = r;
                current_state = (rnd == 8) ? expected.get() : next_state;
                #10;
            end
            if (expected.p8().get() != next_state) begin
                test_pass = TEST_FAILED;
                display_states(next_state, expected.get());
            end
            #20;
        end

        current_state = '0;
        #100;
        $display("p12 start");

        // perform p12() operation over random initial values
        for (int i = 0; i < 10; i++) begin
            expected.urandomize();
            for (int r = 4; r < 16; r++) begin
                rnd = r;
                current_state = (rnd == 4) ? expected.get() : next_state;
                #10;
            end
            if (expected.p12().get() != next_state) begin
                test_pass = TEST_FAILED;
                display_states(next_state, expected.get());
            end
            #20;
        end

        // return if the test succeeded or failed
        display_result(test_pass, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : permutation_tb