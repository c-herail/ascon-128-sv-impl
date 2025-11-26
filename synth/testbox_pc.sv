import ascon_aead128_pkg::*;

module testbox_pc (
    input logic clk,
    input logic rst,
    input logic [2:0] sel,
    output logic [63:0] dout
);

    ascon_state s_state = '{
        s0 : 64'h9043340012005440,
        s1 : 64'h4925669902022042,
        s2 : 64'h5532006940392211,
        s3 : 64'h0011134445600600,
        s4 : 64'h1112223333444555
    };
    round s_rnd = 4'h4;

    always_ff @(posedge clk) begin
        if (rst == 1'b1) begin
            s_rnd <= 4'h4;
        end
        else begin
            if (s_rnd != 4'hF) begin
                s_rnd <= s_rnd + 4'b1;
            end
            else begin
                s_rnd <= 4'h4;
            end
        end
    end

    pc PC (
        .rnd(s_rnd),
        .current_state(s_state),
        .next_state(s_state)
    );

    always_ff @(posedge clk) begin
        if sel == 3'h0 begin
            dout <= s_state.s0;
        end
        else if sel == 3'h1 begin
            dout <= s_state.s1;
        end
        else if sel == 3'h2 begin
            dout <= s_state.s2;
        end
        else if sel == 3'h3 begin
            dout <= s_state.s3;
        end
        else begin
            dout <= s_state.s4;
        end
    end

endmodule