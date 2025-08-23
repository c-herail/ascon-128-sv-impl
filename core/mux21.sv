/*******************************************************************************
 * module name : mux21
 * version     : 1.0
 * description : the module is a multiplexer with 2 inputs and 1 output.
 *      parameter(s):
 *        WIDTH : width of each inputs in bits
 *      input(s):
 *        - a   : first input
 *        - b   : second input
 *        - sel : select bits
 *      output(s):
 *        - s : multiplexer output
 ******************************************************************************/

module mux21 #(parameter WIDTH = 32)(
    input  logic             sel,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    output logic [WIDTH-1:0] s );

    assign s = (sel == 1'b1)? b : a;

endmodule : mux21