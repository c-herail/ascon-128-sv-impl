/*******************************************************************************
 * module name : ps
 * version     : 1.0
 * description : the module performs the substitution of the round function p.
 *      input(s):
 *        - current_state : 320-bit internal state before ps() operation
 *      output(s):
 *        - next_state : 320-bit internal state before ps() operation
 ******************************************************************************/

import ascon_aead128_pkg::ascon_state;

module ps (
    input  ascon_state current_state,
    output ascon_state next_state );

    genvar i;
    generate
        for (i = 0; i < 64; i++) begin : gen_sbox
            sbox sbox_inst (
                .source_column({current_state.s0[i],
                                current_state.s1[i],
                                current_state.s2[i],
                                current_state.s3[i],
                                current_state.s4[i]}),
                .transformed_column({next_state.s0[i],
                                     next_state.s1[i],
                                     next_state.s2[i],
                                     next_state.s3[i],
                                     next_state.s4[i]})
            );
        end
    endgenerate

endmodule : ps