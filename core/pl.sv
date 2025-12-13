/*******************************************************************************
 * module name : pl
 * version     : 1.0
 * description : the module performs the linear layer of the round function p.
 *      input(s):
 *        - current_state : 320-bit internal state before pl() operation
 *      output(s):
 *        - next_state : 320-bit internal state before pl() operation
 ******************************************************************************/

import ascon_aead128_pkg::ascon_state;

module pl (
    input  ascon_state current_state,
    output ascon_state next_state );

    // S0 = S0 xor (S0 >>> 19) xor (S0 >>> 28)
    // S1 = S1 xor (S1 >>> 61) xor (S1 >>> 39)
    // S2 = S2 xor (S2 >>>  1) xor (S2 >>>  6)
    // S3 = S3 xor (S3 >>> 10) xor (S3 >>> 17)
    // S4 = S4 xor (S4 >>>  7) xor (S4 >>> 41)
    always_comb begin
        next_state.s0 = current_state.s0
                     ^ {current_state.s0[18:0], current_state.s0[63:19]}
                     ^ {current_state.s0[27:0], current_state.s0[63:28]};
        next_state.s1 = current_state.s1
                     ^ {current_state.s1[60:0], current_state.s1[63:61]}
                     ^ {current_state.s1[38:0], current_state.s1[63:39]};
        next_state.s2 = current_state.s2
                     ^ {current_state.s2[   0], current_state.s2[63: 1]}
                     ^ {current_state.s2[ 5:0], current_state.s2[63: 6]};
        next_state.s3 = current_state.s3
                     ^ {current_state.s3[ 9:0], current_state.s3[63:10]}
                     ^ {current_state.s3[16:0], current_state.s3[63:17]};
        next_state.s4 = current_state.s4
                     ^ {current_state.s4[ 6:0], current_state.s4[63: 7]}
                     ^ {current_state.s4[40:0], current_state.s4[63:41]};
    end

endmodule : pl