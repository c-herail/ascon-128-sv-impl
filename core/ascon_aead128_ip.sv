/*******************************************************************************
 * module name : ascon_aead128_ip
 * version     : 1.0
 * description :

 ******************************************************************************/

import ascon_aead128_pkg::*;

module ascon_aead128_ip (
    input  logic   aclk,
    input  logic   aresetn,
    axi4_lite_if.s axi );

    localparam integer WTSRB_WIDTH = 4;

    localparam integer NB_REG = 26;
    localparam integer NB_REG_RW = 17;

    localparam integer N = $clog2(NB_REG);

    typedef enum {RD_RESET, RD_IDLE, RD_READ} rd_state_t;
    typedef enum {WR_IDLE, WR_WRITE, WR_RESP} wr_state_t;

    /***************************************************************************
     * Ascon-AEAD128 logic
     **************************************************************************/
    logic [3:0] din_status;
    logic [3:0] ad_status;

    logic start_s;
    logic op_mode_s;
    logic end_s;

    logic valid_ad_s;
    logic valid_db_in_s;

    logic ready_s;

    logic valid_db_out_s;
    logic valid_tag_s;

    logic [127:0] dout_s;

    /***************************************************************************
     * registers definition
     **************************************************************************/

    // read-write registers
    logic [31:0] regs_rw [0:NB_REG_RW-1];
    // read-only registers
    logic [31:0] regs_ro [NB_REG_RW:NB_REG-1];
    // all registers (read-write + read-only)
    logic [31:0] regs    [0:NB_REG-1];

    /***************************************************************************
     * write operation signals
     **************************************************************************/
    wr_state_t wr_current_state;
    wr_state_t wr_next_state;

    logic wr_error;

    logic [N-1:0] wr_index;

    /***************************************************************************
     * read operation signals
     **************************************************************************/
    rd_state_t rd_current_state;
    rd_state_t rd_next_state;

    logic [N-1:0] rd_index;

    /***************************************************************************
     * write operations
     **************************************************************************/
    always @(posedge aclk, negedge aresetn) begin : wr_state_seq
        if (!aresetn) begin
            wr_current_state <= WR_IDLE;
        end
        else begin
            wr_current_state <= wr_next_state;
        end
    end

    always_comb begin : wr_state_comb
        wr_next_state = wr_current_state;
        case (wr_current_state)
            WR_IDLE: begin
                if ((axi.awvalid & axi.wvalid) == 1'b1) begin
                    wr_next_state = WR_WRITE;
                end
            end
            WR_WRITE: begin
                wr_next_state = WR_RESP;
            end
            WR_RESP: begin
                if (axi.bready == 1'b1) begin
                    wr_next_state = WR_IDLE;
                end
            end
        endcase
    end

    always_comb begin : wr_output_comb
        // default write outputs
        axi.awready = 1'b0;
        axi.wready  = 1'b0;
        axi.bvalid  = 1'b0;
        axi.bresp   = 2'b0;
        case (wr_current_state)
            WR_WRITE: begin
                axi.awready = 1'b1;
                axi.wready  = 1'b1;
            end
            WR_RESP: begin
                // if wr_error = 1 SLVERROR is returned else OKAY is returned
                axi.bresp = {wr_error, 1'b0};
                axi.bvalid = 1'b1;
            end
        endcase
    end

    always_comb begin : get_wr_index
        wr_index = axi.awaddr >> 2;
    end

    always_ff @(posedge aclk, negedge aresetn) begin : wr
        if (!aresetn) begin
            wr_error <= 1'b0;
            for (int i = 0; i < NB_REG_RW; i++) begin
                // reset read-write registers to default values
                regs_rw[i] <= '0;
            end
        end
        else begin
            if ((axi.awvalid & axi.wvalid) == 1'b1) begin
                if (wr_index > NB_REG_RW-1) begin
                    // error if user try to write in a read-only register
                    wr_error <= 1'b1;
                end
                else begin
                    // no error
                    wr_error <= 1'b0;
                    for (int i = 0; i < WTSRB_WIDTH; i++) begin
                        regs_rw[wr_index][(i*8) +: 8] <= axi.wdata[(i*8) +: 8];
                    end
                end
            end
        end
    end

    /***************************************************************************
     * read operations
     **************************************************************************/
    always_ff @(posedge aclk, negedge aresetn) begin : rd_state_seq
        if (!aresetn) begin
            rd_current_state <= RD_RESET;
        end
        else begin
            rd_current_state <= rd_next_state;
        end
    end

    always_comb begin : rd_state_comb
        rd_next_state = rd_current_state;
        case (rd_current_state)
            RD_RESET: begin
                rd_next_state = RD_IDLE;
            end
            RD_IDLE: begin
                if (axi.arvalid == 1'b1) begin
                    rd_next_state = RD_READ;
                end
            end
            RD_READ: begin
                if (axi.rready == 1'b1) begin
                    rd_next_state = RD_IDLE;
                end
            end
            default: begin
                rd_next_state = RD_RESET;
            end
        endcase
    end

    always_comb begin : rd_output_comb
        // default read outputs
        axi.arready = 1'b0;
        axi.rvalid  = 1'b0;
        axi.rresp   = 2'b0;
        axi.rdata   = '0;
        case (rd_current_state)
            RD_IDLE: begin
                axi.arready = 1'b1;
            end
            RD_READ: begin
                axi.rvalid = 1'b1;
                if (rd_index < NB_REG) begin
                    // valid data is returned
                    axi.rdata = regs[rd_index];
                end
                else begin
                    // SLVERR response "10" is returned
                    axi.rresp = 2'b10;
                end
            end
        endcase
    end

    always_ff @(posedge aclk, negedge aresetn) begin : get_rd_index
        if (!aresetn) begin
            rd_index <= '0;
        end
        else begin
            if (axi.arvalid == 1'b1) begin
                rd_index <= axi.araddr >> 2;
            end
        end
    end

    /***************************************************************************
     * registers mapping
     **************************************************************************/
    always_comb begin : map_regs
        for (int i = 0; i < NB_REG_RW; i++) begin
            regs[i] = regs_rw[i];
        end
        for (int i = NB_REG_RW; i < NB_REG; i++) begin
            regs[i] = regs_ro[i];
        end
    end

    /***************************************************************************
     * Interface with Ascon-AEAD128 core
     **************************************************************************/

    ascon_aead128_core core (
        .clk         (aclk),
        .rst_n       (aresetn),
        .start       (start_s),
        .op_mode     (op_mode_s),
        .valid_ad    (valid_ad_s),
        .valid_db_in (valid_db_in_s),
        .ad          ({regs[AD3], regs[AD2], regs[AD1], regs[AD0]}),
        .db          ({regs[DIN3], regs[DIN2], regs[DIN1], regs[DIN0]}),
        .key         ({regs[KEY3], regs[KEY2], regs[KEY1], regs[KEY0]}),
        .nonce       ({regs[NONCE3], regs[NONCE2], regs[NONCE1], regs[NONCE0]}),
        .ready       (ready_s),
        .valid_db_out(valid_db_out_s),
        .valid_tag   (valid_tag_s),
        .dout        (dout_s)
    );

    always_ff @(posedge aclk, negedge aresetn) begin : valid_gen
        if (!aresetn) begin
            din_status <= '0;
            ad_status  <= '0;
            valid_ad_s    <= 1'b0;
            valid_db_in_s <= 1'b0;
        end
        else begin
            for (int i = 0; i < 4; i++) begin
                if ((wr_index == DIN0 + i) && ((axi.awvalid) == 1'b1) && (axi.wvalid == 1'b1)) begin
                    din_status[i] <= 1'b1;
                end
                if ((wr_index == AD0 + i) && ((axi.awvalid & axi.wvalid) == 1'b1)) begin
                    ad_status[i] <= 1'b1;
                end
            end
            if (din_status == 4'b1111 && ready_s == 1'b1) begin
                din_status <= '0;
                valid_db_in_s <= 1'b1;
            end
            else begin
                valid_db_in_s <= 1'b0;
            end
            if (ad_status == 4'b1111 && ready_s == 1'b1) begin
                ad_status <= '0;
                valid_ad_s <= 1'b1;
            end
            else begin
                valid_ad_s <= 1'b0;
            end
        end
    end

    always_comb begin : map_CSR
        start_s = regs[CONTROL][0];
        op_mode_s = regs[CONTROL][1];
        regs_ro[STATUS] = {30'b0, end_s, ready_s};
    end

    always_ff @(posedge aclk, negedge aresetn) begin
        if (!aresetn) begin
            {regs_ro[DOUT3], regs_ro[DOUT2], regs_ro[DOUT1], regs_ro[DOUT0]} <= '0;
            {regs_ro[TAG3], regs_ro[TAG2], regs_ro[TAG1], regs_ro[TAG0]} <= '0;
            end_s <= 1'b1;
        end
        else begin
            if (valid_db_out_s) begin
                {regs_ro[DOUT3], regs_ro[DOUT2], regs_ro[DOUT1], regs_ro[DOUT0]} <= dout_s;
            end
            if (valid_tag_s) begin
                {regs_ro[TAG3], regs_ro[TAG2], regs_ro[TAG1], regs_ro[TAG0]} <= dout_s;
                end_s <= 1'b1;
            end
            if (start_s) begin
                end_s <= 1'b0;
            end
        end
    end

endmodule : ascon_aead128_ip