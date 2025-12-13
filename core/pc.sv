/*******************************************************************************
 * module name : pc
 * version     : 1.0
 * description : the module performs the constant addition of the round function
 *  permutation.
 *      input(s):
 *        - rnd           : permutation round value
 *        - current_state : 320-bit internal state before pc() operation
 *      output(s):
 *        - next_state : 320-bit internal state after pc() operation
 ******************************************************************************/

import ascon_aead128_pkg::ascon_state;
import ascon_aead128_pkg::const_add;
import ascon_aead128_pkg::round;

module pc (
    input  round       rnd,
    input  ascon_state current_state,
    output ascon_state next_state );

    always_comb begin
        next_state.s0 = current_state.s0;
        next_state.s1 = current_state.s1;
        next_state.s3 = current_state.s3;
        next_state.s4 = current_state.s4;
        unique case (rnd)
            4'h4 : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'h5 : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'h6 : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'h7 : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'h8 : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'h9 : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'hA : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'hB : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'hC : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'hD : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'hE : next_state.s2 = current_state.s2 ^ const_add[rnd];
            4'hF : next_state.s2 = current_state.s2 ^ const_add[rnd];
        endcase
    end

endmodule : pc