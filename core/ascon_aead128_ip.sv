/*******************************************************************************
 * module name : ascon_aead128_ip
 * version     : 1.0
 * description : Ascon-AEAD IP with a 32-bit AXI4-Lite interface.
 ******************************************************************************/

import ascon_aead128_pkg::*;

module ascon_aead128_ip (
    input  logic        aclk,
    input  logic        aresetn,
    // AR channel signals
    input  logic [6:0]  araddr,
    input  logic        arvalid,
    output logic        arready,
    input  logic [2:0]  arprot,
    // R channel signals
    output logic [31:0] rdata,
    output logic        rvalid,
    input  logic        rready,
    output logic [1:0]  rresp,
    // AW channel signals
    input  logic [6:0]  awaddr,
    input  logic        awvalid,
    output logic        awready,
    input  logic [2:0]  awprot,
    // W channel signals
    input  logic [31:0] wdata,
    input  logic [3:0]  wstrb,
    input  logic        wvalid,
    output logic        wready,
    // B channel signals
    output logic        bvalid,
    input  logic        bready,
    output logic [1:0]  bresp );

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
                if (awvalid & wvalid) begin
                    wr_next_state = WR_WRITE;
                end
            end
            WR_WRITE: begin
                wr_next_state = WR_RESP;
            end
            WR_RESP: begin
                if (bready) begin
                    wr_next_state = WR_IDLE;
                end
            end
        endcase
    end

    always_comb begin : wr_output_comb
        // default write outputs
        awready = 1'b0;
        wready  = 1'b0;
        bvalid  = 1'b0;
        bresp   = 2'b0;
        case (wr_current_state)
            WR_WRITE: begin
                awready = 1'b1;
                wready  = 1'b1;
            end
            WR_RESP: begin
                // if wr_error = 1 SLVERROR is returned else OKAY is returned
                bresp = {wr_error, 1'b0};
                bvalid = 1'b1;
            end
        endcase
    end

    always_comb begin : get_wr_index
        wr_index = awaddr >> 2;
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
            if (awvalid & wvalid) begin
                if (wr_index > NB_REG_RW-1) begin
                    // error if user try to write in a read-only register
                    wr_error <= 1'b1;
                end
                else begin
                    // no error
                    wr_error <= 1'b0;
                    for (int i = 0; i < 4; i++) begin
                        regs_rw[wr_index][(i*8) +: 8] <= wdata[(i*8) +: 8];
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
                if (arvalid) begin
                    rd_next_state = RD_READ;
                end
            end
            RD_READ: begin
                if (rready) begin
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
        arready = 1'b0;
        rvalid  = 1'b0;
        rresp   = 2'b0;
        rdata   = '0;
        case (rd_current_state)
            RD_IDLE: begin
                arready = 1'b1;
            end
            RD_READ: begin
                rvalid = 1'b1;
                if (rd_index < NB_REG) begin
                    // valid data is returned
                    rdata = regs[rd_index];
                end
                else begin
                    // SLVERR response "10" is returned
                    rresp = 2'b10;
                end
            end
        endcase
    end

    always_ff @(posedge aclk, negedge aresetn) begin : get_rd_index
        if (!aresetn) begin
            rd_index <= '0;
        end
        else begin
            if (arvalid) begin
                rd_index <= araddr >> 2;
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
            din_status    <= '0;
            ad_status     <= '0;
            valid_ad_s    <= 1'b0;
            valid_db_in_s <= 1'b0;
        end
        else begin
            for (int i = 0; i < 4; i++) begin
                if ((wr_index == DIN0 + i) && (awvalid & wvalid)) begin
                    din_status[i] <= 1'b1;
                end
                if ((wr_index == AD0 + i) && (awvalid & wvalid)) begin
                    ad_status[i] <= 1'b1;
                end
            end
            if (din_status == 4'b1111 && ready_s) begin
                din_status <= '0;
                valid_db_in_s <= 1'b1;
            end
            else begin
                valid_db_in_s <= 1'b0;
            end
            if (ad_status == 4'b1111 && ready_s) begin
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