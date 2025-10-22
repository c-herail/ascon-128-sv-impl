`timescale 1ns/1ps

import ascon_aead128_pkg::*;
import ascon_aead128_tb_pkg::*;

module ascon_aead128_ip_tb ();

    axi4_lite #(
        .ADDRESS_WIDTH(32),
        .DATA_WIDTH(32)
    )
    axi();

    ascon_aead128_ip #(
        .ADDRESS_WIDTH(32),
        .DATA_WIDTH(32)
    ) DUT (
        .axi(axi.s)
    );

    initial begin
        axi.ack = 1'b0;
        forever #10 axi.ack = ~axi.ack;
    end

    initial begin
        axi.aresetn = 1'b0;
        axi.arvalid = 1'b0;
        axi.rready = 1'b0;
        axi.araddr = '0;
        #20;
        @(posedge axi.ack);
        axi.aresetn = 1'b1;
        @(posedge axi.ack);
        axi.arvalid = 1'b1;
        axi.araddr = 32'h1;
        @(posedge axi.ack);
        axi.arvalid = 1'b0;
        axi.rready = 1'b1;
        axi.araddr = '0;
        @(posedge axi.ack);
        axi.rready = 1'b0;
    end

endmodule : ascon_aead128_ip_tb