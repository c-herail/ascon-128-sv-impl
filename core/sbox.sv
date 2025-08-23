/*******************************************************************************
 * module name : sbox
 * version     : 1.0
 * description : the module is an implementation of a substitution box for
 *  Ascon-AEAD128.
 *      input(s):
 *        - source_column : 5-bit column made from the five 64-bit words of the
              internal state
 *      output(s):
 *        - transformed_column : 5-bit column after the substitution
 ******************************************************************************/

import ascon_aead128_pkg::s_box;

module sbox (
    input  logic [4:0] source_column,
    output logic [4:0] transformed_column );

    always_comb begin
        transformed_column = s_box[source_column];
    end

endmodule : sbox