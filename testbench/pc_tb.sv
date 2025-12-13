`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_tb_pkg::*;

module pc_tb();

    // testbench variables
    localparam DUT_NAME = "pc";
    bit      test_pass = TEST_SUCCESS;
    state_ex expected;

    // DUT variables
    round       rnd;
    ascon_state current_state;
    ascon_state next_state;

    pc DUT (
        .*
    );

    initial begin
        // init
        expected = new();

        // perform pc() operation over random values
        for (int i = 0; i < 100; i++) begin
            rnd = $urandom() % 16;
            if (rnd < 4'h4) rnd = ~rnd;
            expected.urandomize();
            current_state = expected.get();
            #0;
            if (expected.pc(rnd).get() != next_state) begin
                test_pass = TEST_FAILED;
                display_states(next_state, expected.get());
            end
            #10;
        end

        // return if the test succeeded or failed
        display_result(test_pass, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : pc_tb