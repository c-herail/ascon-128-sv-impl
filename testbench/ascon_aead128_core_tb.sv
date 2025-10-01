`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_tb_pkg::*;

module ascon_aead128_core_tb ();

    // testbench variables
    localparam DUT_NAME = "ascon_aead128_core";
    bit test_result = TEST_SUCCESS;

    logic [127:0] ad_arr [] = {
        128'hc43b53b9ae3e79d4b0b68ef461faf02a,
        128'h0cf8da070e9a9da06ceff8ce9d027ff7
    };

    logic [127:0] db_arr [] = {
        128'h646e1113491d4c46c643983a577d3715,
        128'hd2c0d745500bc624046d6a82e04c8a65,
        128'h668d5b345d38a8ec4966fcb2671004b9
    };

    logic [127:0] expected_db_arr [] = {
        128'h3D98B5066CDE919F05AACFC9847F0B30,
        128'hDEBAF030B9936D1550D74F001A72AF56,
        128'h7146BCC68D4C06E2351447F53B5B765B
    };

    logic [127:0] expected_tag = 128'h6908668BE524A3D2DA40EEA44C75FE1C;

    // DUT signals
    logic         clk;
    logic         rst_n;
    logic         start;
    logic         valid_ad;
    logic         valid_db_in;
    logic [127:0] ad;
    logic [127:0] db;
    logic [127:0] din;
    logic [127:0] key;
    logic [127:0] nonce;
    logic         ready;
    logic         valid_db_out;
    logic         valid_tag;
    logic [127:0] dout;

    ascon_aead128_core DUT (
        .*
    );

    initial begin : gen_clk
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin : main
        rst_n = 1'b0;
        start = 1'b0;
        valid_ad = 1'b0;
        valid_db_in = 1'b0;
        ad = '0;
        db = '0;
        din = '0;
        key = '0;
        nonce = '0;
        #40;
        @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        key = 128'hc39e3493a00ca3b5c583e117ee7d70c0;
        nonce = 128'h159cc4b98f3d40696558313154c08196;
        @(posedge clk);
        key = '0;
        nonce = '0;
        @(posedge ready);
        valid_ad = 1'b1;
        ad = ad_arr[0];
        @(posedge clk);
        valid_ad = 1'b0;
        @(posedge clk);
        ad = '0;
        @(posedge ready);
        valid_ad = 1'b1;
        ad = ad_arr[1];
        @(posedge clk);
        valid_ad = 1'b0;
        @(posedge clk);
        ad = '0;
        @(posedge ready);
        valid_db_in = 1'b1;
        db = db_arr[0];
        @(posedge clk);
        valid_db_in = 1'b0;
        @(posedge clk);
        db = '0;
        @(posedge ready);
        valid_db_in = 1'b1;
        db = db_arr[1];
        @(posedge clk);
        valid_db_in = 1'b0;
        @(posedge clk);
        db = '0;
        @(posedge clk);
        start = 1'b0;
        @(posedge ready);
        valid_db_in = 1'b1;
        db = db_arr[2];
        @(posedge clk);
        valid_db_in = 1'b0;
        @(posedge clk);
        db = '0;
        // return if the test succeeded or failed
        display_result(test_result, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

    initial begin
        @(posedge valid_db_out);
        #1;
        if (dout != expected_db_arr[0]) begin
            $display("expected : %h", dout);
            $display("actual   : %h", expected_db_arr[0]);
        end
        @(posedge valid_db_out);
        #1;
        if (dout != expected_db_arr[1]) begin
            $display("expected : %h", dout);
            $display("actual   : %h", expected_db_arr[1]);
        end
        @(posedge valid_db_out);
        #1;
        if (dout != expected_db_arr[2]) begin
            $display("expected : %h", dout);
            $display("actual   : %h", expected_db_arr[2]);
        end
        @(posedge valid_tag);
        #1;
        if (dout != expected_tag) begin
            $display("expected : %h", dout);
            $display("actual   : %h", expected_tag);
        end
    end

endmodule : ascon_aead128_core_tb