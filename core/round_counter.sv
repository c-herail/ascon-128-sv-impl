/*******************************************************************************
 * module name : round_counter
 * version     : 1.0
 * description : counter to produce round values.
 *      input(s):
 *        - clk   : clock
 *        - rst_n : asynchronous active-low reset
 *        - mode  : mode (P8 or P12)
 *        - incr  : increment counter
 *      output(s):
 *        - rnd : permutation round value
 ******************************************************************************/

import ascon_aead128_pkg::round;
// mode signal values
import ascon_aead128_pkg::P12_MODE;
import ascon_aead128_pkg::P8_MODE;
// incr signal values
import ascon_aead128_pkg::DO_INCR;
import ascon_aead128_pkg::NO_INCR;
// round initial values
import ascon_aead128_pkg::P12_INIT;
import ascon_aead128_pkg::P8_INIT;

module round_counter (
    input  logic clk,
    input  logic rst_n,
    input  logic mode,
    input  logic incr,
    output round rnd );

    round rnd_s;

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            rnd_s <= P12_INIT;
        end
        else begin
            unique case({mode, incr})
                {P12_MODE, DO_INCR} : begin
                    // increment round value
                    // on overflow start at P12_INIT
                    if (rnd_s == 4'hF) begin
                        rnd_s <= P12_INIT;
                    end
                    else begin
                        rnd_s <= rnd_s + 1;
                    end
                end
                {P8_MODE, DO_INCR} : begin
                    // increment round value
                    // on overflow start at P8_INIT
                    if (rnd_s == 4'hF) begin
                        rnd_s <= P8_INIT;
                    end
                    else begin
                        rnd_s <= rnd_s + 1;
                    end
                end
                {P12_MODE, NO_INCR},
                {P8_MODE, NO_INCR} : begin
                    // keep round value constant
                    rnd_s <= rnd_s;
                end
            endcase
        end
    end

    assign rnd = rnd_s;

endmodule : round_counter