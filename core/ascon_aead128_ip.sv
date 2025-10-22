/*******************************************************************************
 * module name : ascon_aead128_ip
 * version     : 1.0
 * description :
 *      input(s):
 *        - axi.ack     : global clock signal
 *        - axi.aresetn : global reset signal
 *        - axi.araddr  : read address (issued by master, acceped by slave)
 *        - axi.arvalid : read address valid. This signal indicates that the
 *           channel is signaling valid read address and control information
 *        - axi.rvalid  : read valid. This signal indicates that the channel is
 *           signaling the required read data
 *        - axi.rready  : read ready. This signal indicates that the master can
 *           accept the read data and response information
 *        - axi.awaddr  : write address (issued by master, accepted by slave)
 *        - axi.awvalid : write address valid. This signal indicates that the
 *           master signaling valid write address and control information
 *        - axi.wdata   : write data (issued by master, accepted by slave)
 *        - axi.wstrb   : write strobes. This signal indicates which byte lanes
 *           hold valid data. There is one write strobe bit for each eight bits
 *           of the write data bus
 *        - axi.wvalid  : write valid. This signal indicates that valid write
 *           data and strobes are available
 *        - axi.bready  : response ready. This signal indicates that the master
 *           can accept a write response
 *      output(s):
 *        - axi.arready : read address ready. This signal indicates that the
 *           slave is ready to accept an address and associated control signals
 *        - axi.rdata   : read data (issued by slave)
 *        - axi.rvalid  : read valid. This signal indicates that the channel is
 *           signaling the required read data
 *        - axi.rresp   : read response. This signal indicates the status of the
 *           read transfer
 *        - axi.awready : write address ready. This signal indicates that the
 *           slave is ready to accept an address and associated control signals
 *        - axi.wready  : write ready. This signal indicates that the slave
 *           can accept the write data
 *        - axi.bvalid  : write response valid. This signal indicates that the
 *           channel is signaling a valid write response
 *        - axi.bresp   : write response. This signal indicates the status of
 *           the write transaction
 ******************************************************************************/

import ascon_aead128_pkg::*;

typedef enum {
    S_AXI_RESET,
    S_AXI_WAIT_ARVALID,
    S_AXI_WAIT_RREADY
} axi_r_state;

module ascon_aead128_ip #(
    DATA_WIDTH = 32,
    ADDRESS_WIDTH = 32 ) (
    axi4_lite axi );

    localparam nb_reg = 26;

    logic adr_error;
    logic [DATA_WIDTH-1:0] read_address;
    logic [DATA_WIDTH-1:0] ascon_regs [0:nb_reg-1];

    axi_r_state r_current_state;
    axi_r_state r_next_state;


    // READ ====================================================================
    always_ff @(posedge axi.ack, negedge axi.aresetn) begin
        if (!axi.aresetn) begin
            r_current_state <= S_AXI_RESET;
        end
        else begin
            r_current_state <= r_next_state;
        end
    end

    // next state comb
    always_comb begin
        r_next_state = r_current_state;
        case(r_current_state)
            S_AXI_RESET : begin
                r_next_state = S_AXI_WAIT_ARVALID;
            end
            S_AXI_WAIT_ARVALID : begin
                if (axi.arvalid) begin
                    r_next_state = S_AXI_WAIT_RREADY;
                end
            end
            S_AXI_WAIT_RREADY : begin
                if (axi.rready) begin
                    r_next_state = S_AXI_WAIT_ARVALID;
                end
            end
        endcase
    end

    // output comb
    always_comb begin
        axi.arready = 1'b0;
        axi.rvalid  = 1'b0;
        axi.rresp   = 2'b0;
        axi.rdata   = '0;
        adr_error = 1'b0;
        read_address = '0;
        case(r_current_state)
            S_AXI_WAIT_ARVALID : begin
                axi.arready = 1'b1;
                if (axi.arvalid) begin
                    read_address = (axi.araddr - ASCON_AEAD128_BASE_ADDR > nb_reg)?
                                    axi.araddr - ASCON_AEAD128_BASE_ADDR : '0;
                    adr_error = (axi.araddr - ASCON_AEAD128_BASE_ADDR) > nb_reg;
                end
            end
            S_AXI_WAIT_RREADY : begin
                axi.rvalid = 1'b1;
                if (axi.rready) begin
                    axi.rdata = ascon_regs[read_address[4:0]];
                    axi.rresp = (adr_error)? SLERR_RESPONSE : OKAY_RESPONSE;
                end
            end
        endcase
    end

    // WRITE ===================================================================
    always_ff @(posedge axi.ack, negedge axi.aresetn) begin
        if (!axi.aresetn) begin
            for (int i = 0; i < nb_reg; i++) begin
                ascon_regs[i] <= '0;
            end
        end
        else begin
            for (int i = 0; i < nb_reg; i++) begin
                ascon_regs[i] <= i;
            end
        end
    end

endmodule : ascon_aead128_ip