/*******************************************************************************
 * module name : data_reg
 * version     : 1.0
 * description : the module is a d flip-flop with a configurable input width.
 *      parameter(s):
 *        WIDTH : width of the input in bits
 *      input(s):
 *        - clk   : clock
 *        - rst_n : asynchronous active-low reset
 *        - en    : enable signal
 *        - d     : input data
 *      output(s):
 *        - q : output data
 ******************************************************************************/

module data_reg #(parameter WIDTH = 32)(
    input  logic             clk,
    input  logic             rst_n,
    input  logic             en,
    input  logic [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q );

    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            q <= '0;
        end
        else begin
            if (en == 1'b1) begin
                q <= d;
            end
        end
    end

endmodule : data_reg