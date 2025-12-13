/*******************************************************************************
 * module name : ascon_aead128_core_fsm
 * version     : 1.0
 * description : the finite state machine of ascon_aead128_core.
 *      input(s):
 *        - clk         : clock
 *        - rst_n       : asynchronous active-low reset
 *        - start       : start encryption/decryption, deassert before sending
 *                        last data block
 *        - valid_ad    : validity signal of associated data
 *        - valid_db_in : validity signal of input data block
 *        - rnd         : round value
 *      output(s):
 *        - rnd_cnt_mode : mode of round counter
 *        - rnd_cnt_incr : increment round counter
 *        - en_internal  : store new internal state
 *        - en_new_aead  : store new key and operation mode
 *        - sel_state    : select state (loop or new input)
 *        - sel_din      : select input data (data block or associated data)
 *        - sel_dout     : select output data (data block or tag)
 *        - sel_xor_data : select if state is xored with input data
 *        - sel_xor_key  : select if state is xored with key
 *        - end_ad       : end associated data
 *        - ready        : ready signal
 *        - valid_db_out : validity signal of output data block
 *        - valid_tag    : validity signal of tag
 ******************************************************************************/

import ascon_aead128_pkg::*;

module fsm (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       valid_ad,
    input  logic       valid_db_in,
    input  round       rnd,
    output logic       rnd_cnt_mode,
    output logic       rnd_cnt_incr,
    output logic       en_internal,
    output logic       en_new_aead,
    output logic       sel_state,
    output logic       sel_din,
    output logic       sel_dout,
    output logic       sel_xor_data,
    output logic [1:0] sel_xor_key,
    output logic       end_ad,
    output logic       ready,
    output logic       valid_db_out,
    output logic       valid_tag );

    ascon_fsm_state current_state_s;
    ascon_fsm_state next_state_s;

    logic end_ad_s;
    logic ad_s;
    logic db_s;

    // current_state seq
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            current_state_s <= idle;
        end
        else begin
            current_state_s <= next_state_s;
        end
    end

    // next_stage comb
    always_comb begin
        // hold state by default
        next_state_s = current_state_s;
        case (current_state_s)
            idle : begin
                if (start) begin
                    next_state_s = startup;
                end
            end
            startup : begin
                next_state_s = initialisation;
            end
            initialisation : begin
                if (rnd == 4'd14) begin
                    next_state_s = transition1;
                end
            end
            transition1 : begin
                if (valid_ad)
                    next_state_s = xor_ad1;
                else if (valid_db_in)
                    if(!start)
                        next_state_s = xor_finalisation;
                    else
                        next_state_s = xor_db1;
                else begin
                    next_state_s = transition1;
                end
            end
            xor_ad1 : begin
                next_state_s = p8_ad1;
            end
            p8_ad1 : begin
                if (rnd == 4'd14) begin
                    next_state_s = transition2;
                end
            end
            transition2 : begin
                if (valid_ad)
                    next_state_s = xor_ad2;
                else if (valid_db_in) begin
                    if (!start)
                        next_state_s = xor_finalisation;
                    else
                        next_state_s = xor_db1;
                end
                else begin
                    next_state_s = transition2;
                end
            end
            xor_ad2 : begin
                next_state_s = p8_ad2;
            end
            p8_ad2 : begin
                if (rnd == 4'd14) begin
                    next_state_s = transition2;
                end
            end
            xor_db1,
            xor_db2 : begin
                next_state_s = p8_db;
            end
            p8_db : begin
                if (rnd == 4'd14) begin
                    next_state_s = transition3;
                end
            end
            transition3 : begin
                if (valid_db_in) begin
                    if (!start)
                        next_state_s = xor_finalisation;
                    else
                        next_state_s = xor_db2;
                end
                else begin
                    next_state_s = transition3;
                end
            end
            xor_finalisation : begin
                next_state_s = finalisation;
            end
            finalisation : begin
                if (rnd == 4'd14) begin
                    next_state_s = tag;
                end
            end
            tag : begin
                next_state_s = idle;
            end
            default : begin
                next_state_s = idle;
            end
        endcase
    end

    // outputs comb
    always_comb begin

        // default outputs
        rnd_cnt_mode = P12_MODE;
        rnd_cnt_incr = NO_INCR;

        en_internal = 1'b0;
        en_new_aead = 1'b0;

        sel_state    = SEL_LOOP_STATE;
        sel_din      = SEL_AD;
        sel_dout     = SEL_DATA;
        sel_xor_data = SEL_DATA_NO_XOR;
        sel_xor_key  = SEL_KEY_NO_XOR;

        end_ad = 1'b0;

        ready = 1'b0;

        valid_db_out = 1'b0;
        valid_tag    = 1'b0;

        case (current_state_s)
            startup : begin
                en_internal = 1'b1;
                en_new_aead = 1'b1;

                sel_state = SEL_INPUT_STATE;
            end
            initialisation,
            finalisation : begin
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;
            end
            transition1,
            transition2,
            transition3 : begin
                ready = 1'b1;
            end
            xor_ad1 : begin
                rnd_cnt_mode = P8_MODE;
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;

                sel_xor_data = SEL_DATA_XOR;
                sel_xor_key  = SEL_0_KEY;
            end
            xor_ad2 : begin
                rnd_cnt_mode = P8_MODE;
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;

                sel_xor_data = SEL_DATA_XOR;
            end
            p8_ad1,
            p8_ad2,
            p8_db : begin
                rnd_cnt_mode = P8_MODE;
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;
            end
            xor_db1 : begin
                rnd_cnt_mode = P8_MODE;
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;

                sel_din      = SEL_DB;
                sel_xor_data = SEL_DATA_XOR;
                sel_xor_key  = (ad_s)? SEL_KEY_NO_XOR : SEL_0_KEY;

                end_ad = 1'b1;

                valid_db_out = 1'b1;
            end
            xor_db2 : begin
                rnd_cnt_mode = P8_MODE;
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;

                sel_din      = SEL_DB;
                sel_xor_data = SEL_DATA_XOR;

                valid_db_out = 1'b1;
            end
            xor_finalisation : begin
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;

                sel_din      = SEL_DB;
                sel_xor_data = SEL_DATA_XOR;
                sel_xor_key  = (ad_s)? SEL_KEY_0 :
                               (db_s)? SEL_KEY_0 : SEL_KEY_KEY;

                end_ad = (end_ad_s)? 1'b0 : 1'b1;

                valid_db_out = 1'b1;
            end
            tag : begin
                rnd_cnt_incr = DO_INCR;

                en_internal = 1'b1;

                sel_xor_key = SEL_0_KEY;
                sel_dout    = SEL_TAG;

                valid_tag = 1'b1;
            end
        endcase
    end

    always_ff @(posedge clk) begin
        end_ad_s = end_ad_s;
        ad_s = ad_s;
        db_s = db_s;
        case (current_state_s)
            idle : begin
                end_ad_s = 1'b0;
                ad_s     = 1'b0;
                db_s     = 1'b0;
            end
            xor_ad1,
            xor_ad2 : begin
                ad_s = 1'b1;
            end
            xor_db1,
            xor_db2 : begin
                end_ad_s = 1'b1;
                db_s = 1'b1;
            end
        endcase
    end

endmodule : fsm