`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_dpi_pkg::*;
import ascon_aead128_tb_pkg::*;

module ascon_aead128_ip_tb ();

    // testbench variables
    localparam DUT_NAME = "ascon_aead128_ip";

    localparam MAX_NB_AD = 5;
    localparam MAX_NB_DB = 5;

    bit test_result = TEST_SUCCESS;

    int i, j;

    uint128 ad_arr[];
    uint128 p_arr[];
    uint128 c_arr[];

    ascon_aead128_dpi_pkg::key k;
    ascon_aead128_dpi_pkg::nonce n;
    ascon_aead128_dpi_pkg::tag t;

    byte unsigned ret_val;

    logic [31:0] ctrl_reg = '0;
    logic [127:0] rd_val = '0;

    // DUT signals
    logic aclk;
    logic aresetn;

    axi4_lite_if #(
        .ADDRESS_WIDTH(7),
        .DATA_WIDTH(32)
    ) axi();

    ascon_aead128_ip DUT (
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

    task perform_reset;
        aresetn = 1'b0;
        axi.awaddr  = '0;
        axi.awprot  = 3'b0;
        axi.awvalid = 1'b0;
        axi.wdata   = '0;
        axi.wstrb   = 4'b0;
        axi.wvalid  = 1'b0;
        axi.bready  = 1'b0;
        axi.araddr  = '0;
        axi.arprot  = 3'b0;
        axi.arvalid = 1'b0;
        axi.rready  = 1'b0;
        @(posedge aclk);
        @(posedge aclk);
        aresetn = 1'b1;
    endtask

    task write(int index, logic [31:0] value, logic [3:0] mask = 4'b1111);
        fork
            begin
                axi.awaddr  = index_to_byte_offset(index);
                axi.awvalid = 1'b1;
                do begin
                    @(posedge aclk);
                end while (axi.awready != 1'b1);
                axi.awaddr  = '0;
                axi.awvalid = 1'b0;
            end
            begin
                axi.wdata  = value;
                axi.wstrb  = mask;
                axi.wvalid = 1'b1;
                do begin
                    @(posedge aclk);
                end while (axi.wready != 1'b1);
                axi.wdata  = '0;
                axi.wstrb  = 4'b0;
                axi.wvalid = 1'b0;
            end
        join
        axi.bready = 1'b1;
        do begin
            @(posedge aclk);
        end while (axi.bvalid != 1'b1);
        axi.bready = 1'b0;
    endtask

    task write_128(int index, logic [127:0] value);
        write(index,   value[31:0]);
        write(index+1, value[63:32]);
        write(index+2, value[95:64]);
        write(index+3, value[127:96]);
    endtask

    task read(int index);
        axi.araddr = index_to_byte_offset(index);
        axi.arvalid = 1'b1;
        do begin
            @(posedge aclk);
        end while (axi.arready != 1'b1);
        axi.araddr = '0;
        axi.arvalid = 1'b0;
        axi.rready = 1'b1;
        do begin
            @(posedge aclk);
        end while (axi.rvalid != 1'b1);
        axi.rready = 1'b0;
    endtask

    task read_128(int index, output logic [127:0] read_val);
        read(index);
        read_val[31:0] = axi.rdata;
        read(index+1);
        read_val[63:32] = axi.rdata;
        read(index+2);
        read_val[95:64] = axi.rdata;
        read(index+3);
        read_val[127:96] = axi.rdata;
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

    task wait_ready;
        do read(STATUS); while (axi.rdata[0] != 1'b1);
    endtask

    task wait_end_aead;
        do read(STATUS); while (axi.rdata[1] != 1'b1);
    endtask

    task initialisation(bit mode);
        write_128(KEY0, {k.msb, k.lsb});
        write_128(NONCE0, {n.msb, n.lsb});
        // set start and sel mode
        ctrl_reg = {30'b0, mode, 1'b1};
        write(CONTROL, ctrl_reg);
        write(16, ctrl_reg);
    endtask

   task associated_data;
        wait_ready();
        foreach (ad_arr[k]) begin
            // write ad
            write_128(AD0, {ad_arr[k].msb, ad_arr[k].lsb});
        end
    endtask

    task plaintext;
        wait_ready();
        foreach (p_arr[k]) begin
            if (k == p_arr.size()-1) begin
                // set start bit to zero
                ctrl_reg = ctrl_reg & {{31{1'b1}}, 1'b0};
                write(CONTROL, ctrl_reg);
            end
                // write db
                write_128(DIN0, {p_arr[k].msb, p_arr[k].lsb});
                // read ciphertext
                read_128(DOUT0, rd_val);
                // check ciphertext
                if (rd_val != {c_arr[k].msb, c_arr[k].lsb}) begin
                    $display("Error : encryption failed (plaintext %d)", k);
                    $display("expected : %h", {c_arr[k].msb, c_arr[k].lsb});
                    $display("actual   : %h", rd_val);
                    test_result = TEST_FAILED;
                end
        end
    endtask

    task ciphertext;
        wait_ready();
        foreach (c_arr[k]) begin
            if (k == c_arr.size()-1) begin
                // set start bit to zero
                ctrl_reg = ctrl_reg & {{31{1'b1}}, 1'b0};
                write(CONTROL, ctrl_reg);
            end
                // write db
                write_128(DIN0, {c_arr[k].msb, c_arr[k].lsb});
                // read plaintext
                read_128(DOUT0, rd_val);
                // check plaintext
                if (rd_val != {p_arr[k].msb, p_arr[k].lsb}) begin
                    $display("Error : decryption failed (ciphertext %d)", k);
                    $display("expected : %h", {p_arr[k].msb, p_arr[k].lsb});
                    $display("actual   : %h", rd_val);
                    test_result = TEST_FAILED;
                end
        end
    endtask

    task finalisation(bit op_mode);
        // wait for valid_tag
        wait_end_aead();
        // read tag
        read_128(TAG0, rd_val);
        // check tag
        if (rd_val != {t.msb, t.lsb}) begin
            if (op_mode == AE_MODE) begin
                $display("Error : encryption failed (tag)");
            end
            else begin
                $display("Error : decryption failed (tag)");
            end
            $display("expected : %h", {t.msb, t.lsb});
            $display("actual   : %h", rd_val);
            test_result = TEST_FAILED;
        end
    endtask

    task aead;
        ad_arr = new[i];
        p_arr  = new[j];
        c_arr  = new[j];

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

        // perform advanced encryption
        initialisation(AE_MODE);
        associated_data();
        plaintext();
        finalisation(AE_MODE);

        // perform advanced decryption
        initialisation(AD_MODE);
        associated_data();
        ciphertext();
        finalisation(AD_MODE);

        ad_arr.delete();
        p_arr.delete();
        c_arr.delete();
    endtask

    initial begin : gen_clk
        aclk = 1'b0;
        forever #10 aclk = ~aclk;
    end

    initial begin : main
        perform_reset();

        for (i = 0; i < MAX_NB_AD; i++) begin
            for (j = 1; j < MAX_NB_DB; j++) begin
                aead();
            end
        end

        // return if the test succeeded or failed
        display_result(test_result, DUT_NAME);

        // stop simulation if run without GUI
        stop_simulation();
    end

endmodule : ascon_aead128_ip_tb