/*******************************************************************************
 * module name : ascon_aead128_core
 * version     : 1.0
 * description :
 *      input(s):
 *        - clk         : clock
 *        - rst_n       : asynchronous active-low reset
 *        - start       : tart encryption/decryption, deassert before sending
 *                        last data block
 *        - op_mode     : operation mode (encryption/decryption)
 *        - valid_ad    : validity signal of associated data
 *        - valid_db_in : validity signal of input data block
 *        - ad          : associated data
 *        - db          : input data block
 *        - key         : key
 *        - nonce       : nonce
 *      output(s):
 *        - ready        : ready signal
 *        - valid_db_out : validity signal of output data block
 *        - valid_tag    : validity signal of tag
 *        - dout         : output data block or tag
 ******************************************************************************/

import ascon_aead128_pkg::round;

module ascon_aead128_core (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,
    input  logic         op_mode,
    input  logic         valid_ad,
    input  logic         valid_db_in,
    input  logic [127:0] ad,
    input  logic [127:0] db,
    input  logic [127:0] key,
    input  logic [127:0] nonce,
    output logic         ready,
    output logic         valid_db_out,
    output logic         valid_tag,
    output logic [127:0] dout );

    logic en_internal_s;
    logic en_new_aead_s;

    logic       sel_state_s;
    logic       sel_din_s;
    logic       sel_dout_s;
    logic       sel_xor_data_s;
    logic [1:0] sel_xor_key_s;

    logic end_ad_s;

    logic rnd_cnt_mode_s;
    logic rnd_cnt_incr_s;

    round rnd_s;

    fsm FSM (
        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),
        .valid_ad    (valid_ad),
        .valid_db_in (valid_db_in),
        .rnd         (rnd_s),
        .rnd_cnt_mode(rnd_cnt_mode_s),
        .rnd_cnt_incr(rnd_cnt_incr_s),
        .en_internal (en_internal_s),
        .en_new_aead (en_new_aead_s),
        .sel_state   (sel_state_s),
        .sel_din     (sel_din_s),
        .sel_dout    (sel_dout_s),
        .sel_xor_data(sel_xor_data_s),
        .sel_xor_key (sel_xor_key_s),
        .end_ad      (end_ad_s),
        .ready       (ready),
        .valid_db_out(valid_db_out),
        .valid_tag   (valid_tag)
    );

    round_counter ROUND_COUNTER (
        .clk  (clk),
        .rst_n(rst_n),
        .mode (rnd_cnt_mode_s),
        .incr (rnd_cnt_incr_s),
        .rnd  (rnd_s)
    );

    data_path DATA_PATH (
        .clk         (clk),
        .rst_n       (rst_n),
        .op_mode     (op_mode),
        .rnd         (rnd_s),
        .en_internal (en_internal_s),
        .en_new_aead (en_new_aead_s),
        .sel_state   (sel_state_s),
        .sel_din     (sel_din_s),
        .sel_dout    (sel_dout_s),
        .sel_xor_data(sel_xor_data_s),
        .sel_xor_key (sel_xor_key_s),
        .end_ad      (end_ad_s),
        .ad          (ad),
        .db          (db),
        .key         (key),
        .nonce       (nonce),
        .dout        (dout)
    );

endmodule : ascon_aead128_core