/*******************************************************************************
 * module name : mux41
 * version     : 1.0
 * description : the module is a multiplexer with 4 inputs and 1 output.
 *      parameter(s):
 *        - WIDTH : width of data input in bits
 *      input(s):
 *        - a   : first input
 *        - b   : second input
 *        - c   : third input
 *        - d   : fourth input
 *        - sel : select bits
 *      output(s):
 *        - s : multiplexer output
 ******************************************************************************/

module mux41 #(parameter WIDTH = 32)(
    input  logic [1:0]       sel,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [WIDTH-1:0] c,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] s );

    always_comb begin
        unique case(sel)
            2'b00 : s = a;
            2'b01 : s = b;
            2'b10 : s = c;
            2'b11 : s = d;
        endcase
    end

endmodule : mux41