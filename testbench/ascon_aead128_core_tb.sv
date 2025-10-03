`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_dpi_pkg::*;
import ascon_aead128_tb_pkg::*;

module ascon_aead128_core_tb ();

    // testbench variables
    localparam DUT_NAME = "ascon_aead128_core";
    bit test_result = TEST_SUCCESS;

    int i, j;

    uint128 ad_arr[];
    uint128 p_arr[];
    uint128 c_arr[];

    ascon_aead128_dpi_pkg::key k;
    ascon_aead128_dpi_pkg::nonce n;
    ascon_aead128_dpi_pkg::tag t;

    byte unsigned ret_val;

    // DUT signals
    logic         clk;
    logic         rst_n;
    logic         start;
    logic         op_mode;
    logic         valid_ad;
    logic         valid_db_in;
    logic [127:0] ad;
    logic [127:0] db;
    logic [127:0] key;
    logic [127:0] nonce;
    logic         ready;
    logic         valid_db_out;
    logic         valid_tag;
    logic [127:0] dout;

    ascon_aead128_core DUT (
        .*
    );

    task display_test_info;
        $display("[%3d, %3d] ====================", i, j);
        $display("key   : %h", {k.msb, k.lsb});
        $display("nonce : %h", {n.msb, n.lsb});
        foreach(ad_arr[k]) begin
            $display("ad : %h", {ad_arr[k].msb, ad_arr[k].lsb});
        end
        foreach(p_arr[k]) begin
            $display("p : %h", {p_arr[k].msb, p_arr[k].lsb});
        end
    endtask

    task randomize_inputs;
        k = '{msb : {$urandom, $urandom}, lsb : {$urandom, $urandom}};
        n = '{msb : {$urandom, $urandom}, lsb : {$urandom, $urandom}};

        foreach(ad_arr[k]) begin
            ad_arr[k] = '{msb : {$urandom, $urandom},
                          lsb : {$urandom, $urandom}};
        end

        foreach(p_arr[k]) begin
            p_arr[k] = '{msb : {$urandom, $urandom},
                         lsb : {$urandom, $urandom}};
        end
    endtask

    task initialisation;
        @(posedge clk);
        start = 1'b1;
        @(posedge clk);
        key = {k.msb, k.lsb};
        nonce = {n.msb, n.lsb};
        @(posedge clk);
        key = '0;
        nonce = '0;
    endtask

    task associated_data;
        foreach (ad_arr[k]) begin
            @(posedge ready);
            valid_ad = 1'b1;
            ad = {ad_arr[k].msb, ad_arr[k].lsb};
            @(posedge clk);
            valid_ad = 1'b0;
            @(posedge clk);
            ad = '0;
        end
    endtask

    task plaintext;
        foreach (p_arr[k]) begin
            if (k == p_arr.size()-1) begin
                @(posedge clk);
                start = 1'b0;
            end
            fork
                begin
                    @(posedge ready);
                    valid_db_in = 1'b1;
                    db = {p_arr[k].msb, p_arr[k].lsb};
                    @(posedge clk);
                    valid_db_in = 1'b0;
                    @(posedge clk);
                    db = '0;
                end
                begin
                    @(posedge valid_db_out);
                    #1;
                    if (dout != {c_arr[k].msb, c_arr[k].lsb}) begin
                        $display("Error : encryption failed (plaintext %d)", k);
                        $display("expected : %h", {c_arr[k].msb, c_arr[k].lsb});
                        $display("actual   : %h", dout);
                        test_result = TEST_FAILED;
                    end
                end
            join
        end
    endtask

    task ciphertext;
        foreach (c_arr[k]) begin
            if (k == c_arr.size()-1) begin
                @(posedge clk);
                start = 1'b0;
            end
            fork
                begin
                    @(posedge ready);
                    valid_db_in = 1'b1;
                    db = {c_arr[k].msb, c_arr[k].lsb};
                    @(posedge clk);
                    valid_db_in = 1'b0;
                    @(posedge clk);
                    db = '0;
                end
                begin
                    @(posedge valid_db_out);
                    #1;
                    if (dout != {p_arr[k].msb, p_arr[k].lsb}) begin
                        $display("Error : decryption failed (ciphertext %d)", k);
                        $display("expected : %h", {p_arr[k].msb, p_arr[k].lsb});
                        $display("actual   : %h", dout);
                        test_result = TEST_FAILED;
                    end
                end
            join
        end
    endtask

    task finalisation;
        automatic string msg =
            (op_mode == AE_MODE)?
            "Error : encryption failed (tag)" :
            "Error : decryption failed (tag)";
        @(posedge valid_tag);
        #1;
        if (dout != {t.msb, t.lsb}) begin
            $display(msg);
            $display("expected : %h", {t.msb, t.lsb});
            $display("actual   : %h", dout);
            test_result = TEST_FAILED;
        end
    endtask

    task aead;
        op_mode = AE_MODE;

        ad_arr = new[i];
        p_arr = new[j];
        c_arr = new[j];

        randomize_inputs();

        ret_val = sv_ascon128_enc(k,
                                  n,
                                  ad_arr.size(),
                                  ad_arr,
                                  p_arr.size(),
                                  p_arr,
                                  c_arr,
                                  t);

        if (ret_val != 1'b0) begin
            $display("Error something went wrong with sv_ascon128_enc");
            $finish;
        end

        display_test_info();

        initialisation();
        associated_data();
        plaintext();
        finalisation();

        op_mode = AD_MODE;

        initialisation();
        associated_data();
        ciphertext();
        finalisation();

        ad_arr.delete();
        p_arr.delete();
        c_arr.delete();
    endtask

    initial begin : gen_clk
        clk = 1'b0;
        forever #10 clk = ~clk;
    end

    initial begin : main
        rst_n = 1'b0;
        start = 1'b0;
        op_mode = 1'b0;
        valid_ad = 1'b0;
        valid_db_in = 1'b0;
        ad = '0;
        db = '0;
        key = '0;
        nonce = '0;
        #40;
        @(posedge clk);
        rst_n = 1'b1;

        for (i = 0; i < 5; i++) begin
            for (j = 1; j < 5; j++) begin
                aead();
            end
        end;

        // return if the test succeeded or failed
        display_result(test_result, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : ascon_aead128_core_tb