/*******************************************************************************
 * module name : data_path
 * version     : 1.0
 * description : data path of ascon_aead128_core.
 *      input(s):
 *        - clk          : clock
 *        - rst_n        : asynchronous active-low reset
 *        - op_mode      : operation mode (encryption/decryption)
 *        - rnd          : round value
 *        - en_internal  : store new internal state
 *        - en_new_aead  : store new key and operation mode
 *        - sel_state    : select state (loop or new input)
 *        - sel_din      : select input data (data block or associated data)
 *        - sel_dout     : select output data (data block or tag)
 *        - sel_xor_data : select if state is xored with input data
 *        - sel_xor_key  : select if state is xored with key
 *        - end_ad       : end associated data
 *        - ad           : associated data
 *        - db           : input data block
 *        - key          : key
 *        - nonce        : nonce
 *      output(s):
 *        - dout : output data block or tag
 ******************************************************************************/

import ascon_aead128_pkg::ascon_state;
import ascon_aead128_pkg::round;
import ascon_aead128_pkg::IV;

module data_path (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         op_mode,
    input  round         rnd,
    input  logic         en_internal,
    input  logic         en_new_aead,
    input  logic         sel_state,
    input  logic         sel_din,
    input  logic         sel_dout,
    input  logic         sel_xor_data,
    input  logic [1:0]   sel_xor_key,
    input  logic         end_ad,
    input  logic [127:0] ad,
    input  logic [127:0] db,
    input  logic [127:0] key,
    input  logic [127:0] nonce,
    output logic [127:0] dout );

    ascon_state input_state_s;
    ascon_state state_s;
    ascon_state internal_state_s;
    ascon_state p_s;
    ascon_state loop_s;

    logic sel_mode_s;

    logic [127:0] din_s;
    logic [127:0] key_s;
    logic [127:0] db_s;
    logic [127:0] tag_s;

    // input_state_s = {IV||K||N}
    always_comb begin : input_state
        input_state_s.s0 = IV;
        input_state_s.s1 = key[127:64];
        input_state_s.s2 = key[63:0];
        input_state_s.s3 = nonce[127:64];
        input_state_s.s4 = nonce[63:0];
    end

    mux21 #(.WIDTH(128))
    DIN_MUX (
        .sel(sel_din),
        .a  (ad),
        .b  (db),
        .s  (din_s)
    );

    mux21 #(.WIDTH($bits(ascon_state)))
    INPUT_MUX (
        .sel(sel_state),
        .a  (loop_s ^ end_ad),
        .b  (input_state_s),
        .s  (state_s)
    );

    data_reg #(.WIDTH(128))
    KEY_REG (
        .clk  (clk),
        .rst_n(rst_n),
        .en   (en_new_aead),
        .d    (key),
        .q    (key_s)
    );

    data_reg #(.WIDTH(1))
    AEAD_REG (
        .clk  (clk),
        .rst_n(rst_n),
        .en   (en_new_aead),
        .d    (op_mode),
        .q    (sel_mode_s)
    );

    data_reg #(.WIDTH($bits(ascon_state)))
    STATE_REG (
        .clk  (clk),
        .rst_n(rst_n),
        .en   (en_internal),
        .d    (state_s),
        .q    (internal_state_s)
    );

    permutation PERMUTATION (
        .rnd          (rnd),
        .current_state(internal_state_s),
        .next_state   (p_s)
    );

    mux41 #(.WIDTH(128))
    DATA_XOR_MUX (
        .sel({sel_xor_data, sel_mode_s & sel_din}),
        .a  ({p_s.s0, p_s.s1}),
        .b  ({p_s.s0, p_s.s1}),
        .c  ({p_s.s0, p_s.s1} ^ din_s),
        .d  (din_s),
        .s  ({loop_s.s0, loop_s.s1})
    );

    mux41 #(.WIDTH(192))
    KEY_XOR_MUX (
        .sel(sel_xor_key),
        .a  ({p_s.s2, p_s.s3,  p_s.s4}),
        .b  ({p_s.s2, p_s.s3,  p_s.s4} ^ key_s),
        .c  ({p_s.s2, p_s.s3,  p_s.s4} ^ {key_s, 64'b0}),
        .d  ({p_s.s2, p_s.s3,  p_s.s4} ^ {key_s, 64'b0} ^ key_s),
        .s  ({loop_s.s2, loop_s.s3, loop_s.s4})
    );

    always_comb begin : db_and_tag
        db_s  = {p_s.s0, p_s.s1} ^ din_s;
        tag_s = {loop_s.s3, loop_s.s4};
    end

    mux21 #(.WIDTH(128))
    DOUT_MUX (
        .sel(sel_dout),
        .a  (db_s),
        .b  (tag_s),
        .s  (dout)
    );

endmodule : data_path