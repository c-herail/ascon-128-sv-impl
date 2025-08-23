/*******************************************************************************
 * module name : permutation
 * version     : 1.0
 * description : the module performs the round function p.
 *      input(s):
 *        - rnd           : permutation round value
 *        - current_state : 320-bit internal state before p() operation
 *      output(s):
 *        - next_state : 320-bit internal state before p() operation
 ******************************************************************************/

import ascon_aead128_pkg::ascon_state;
import ascon_aead128_pkg::round;

module permutation (
    input  round       rnd,
    input  ascon_state current_state,
    output ascon_state next_state );

    ascon_state pc_out_s;
    ascon_state ps_out_s;

    pc PC (
        .current_state(current_state),
        .rnd(rnd),
        .next_state(pc_out_s)
    );

    ps PS (
        .current_state(pc_out_s),
        .next_state(ps_out_s)
    );

    pl PL (
        .current_state(ps_out_s),
        .next_state(next_state)
    );

endmodule : permutation