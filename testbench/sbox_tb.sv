`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_tb_pkg::*;

module sbox_tb();

    // testbench variables
    localparam DUT_NAME = "sbox";
    bit      test_pass = TEST_SUCCESS;

    // DUT variables
    logic [4:0] source_column;
	logic [4:0] transformed_column;

    sbox DUT (
        .*
    );

    initial begin
        for(int i = 0; i < 32; i++) begin
            source_column = i;
            #0;
            if (transformed_column != s_box[i]) begin
                test_pass = TEST_FAILED;
                $display("Error, expected : 0x%02h, actual: 0x%02h",
                                                s_box[i], transformed_column);
            end
            #20;
        end

        // return if the test succeeded or failed
        display_result(test_pass, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : sbox_tb