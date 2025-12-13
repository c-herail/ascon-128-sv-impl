package ascon_aead128_pkg;

// constant initial value
const logic [63:0] IV = 64'h00001000808c0001;

// constants for pc() operation
const logic [7:0] const_add[16] = '{
    8'h3C, 8'h2D, 8'h1E, 8'h0F,
    8'hF0, 8'hE1, 8'hD2, 8'hC3,
    8'hB4, 8'hA5, 8'h96, 8'h87,
    8'h78, 8'h69, 8'h5A, 8'h4B
};

// substitution box constants
const logic [4:0] s_box[32] = '{
    5'h04, 5'h0B, 5'h1F, 5'h14,
    5'h1A, 5'h15, 5'h09, 5'h02,
    5'h1B, 5'h05, 5'h08, 5'h12,
    5'h1D, 5'h03, 5'h06, 5'h1C,
    5'h1E, 5'h13, 5'h07, 5'h0E,
    5'h00, 5'h0D, 5'h11, 5'h18,
    5'h10, 5'h0C, 5'h01, 5'h19,
    5'h16, 5'h0A, 5'h0F, 5'h17
};

// representation of Ascon 5x64 bits state
typedef struct packed {
    logic [63:0] s0;
    logic [63:0] s1;
    logic [63:0] s2;
    logic [63:0] s3;
    logic [63:0] s4;
} ascon_state;

typedef logic [3:0] round;

// states for Ascon FSM
typedef enum {
    idle,
    startup,
    initialisation,
    transition1,
    xor_ad1,
    p8_ad1,
    xor_ad2,
    p8_ad2,
    transition2,
    xor_db1,
    xor_db2,
    p8_db,
    transition3,
    xor_finalisation,
    finalisation,
    tag
} ascon_fsm_state;

/** parameters for round_counter control **************************************/

// round counter mode signal values
localparam logic P8_MODE  = 1'b1;
localparam logic P12_MODE = 1'b0;

// round counter incr signal values
localparam logic DO_INCR = 1'b1;
localparam logic NO_INCR = 1'b0;

// round counter init counter values
localparam round P8_INIT  = 4'h8;
localparam round P12_INIT = 4'h4;

/** parameters for data_path control ******************************************/

// op_mode/sel_mode values
localparam logic AD_MODE = 1'b1;
localparam logic AE_MODE = 1'b0;

// sel_din sel values
localparam logic SEL_DB = 1'b1;
localparam logic SEL_AD = 1'b0;

// sel_state values
localparam logic SEL_INPUT_STATE = 1'b1;
localparam logic SEL_LOOP_STATE  = 1'b0;

// sel_xor_data values
localparam logic SEL_DATA_XOR    = 1'b1;
localparam logic SEL_DATA_NO_XOR = 1'b0;

// sel_xor_key values
localparam logic [1:0] SEL_KEY_KEY    = 2'd3;
localparam logic [1:0] SEL_KEY_0      = 2'd2;
localparam logic [1:0] SEL_0_KEY      = 2'd1;
localparam logic [1:0] SEL_KEY_NO_XOR = 2'd0;

// sel_dout sel values
localparam logic SEL_TAG  = 1'b1;
localparam logic SEL_DATA = 1'b0;

/** parameters for axi4-lite interface ****************************************/

function int byte_offset_to_index(int byte_offset);
    return byte_offset >> 2;
endfunction

function int index_to_byte_offset(int index);
    return 4*index;
endfunction

// AXI4-Lite responses
localparam logic [1:0] OKAY   = 2'b00;
localparam logic [1:0] SLVERR = 2'b10;

localparam logic READ_ONLY  = 1'b0;
localparam logic READ_WRITE = 1'b1;

// nonce registers
localparam int unsigned NONCE0 = 0;
localparam int unsigned NONCE1 = 1;
localparam int unsigned NONCE2 = 2;
localparam int unsigned NONCE3 = 3;

localparam int unsigned NONCE0_OFFSET = index_to_byte_offset(NONCE0);
localparam int unsigned NONCE1_OFFSET = index_to_byte_offset(NONCE1);
localparam int unsigned NONCE2_OFFSET = index_to_byte_offset(NONCE2);
localparam int unsigned NONCE3_OFFSET = index_to_byte_offset(NONCE3);

localparam logic NONCE0_RW = READ_WRITE;
localparam logic NONCE1_RW = READ_WRITE;
localparam logic NONCE2_RW = READ_WRITE;
localparam logic NONCE3_RW = READ_WRITE;

// key registers
localparam int unsigned KEY0 = 4;
localparam int unsigned KEY1 = 5;
localparam int unsigned KEY2 = 6;
localparam int unsigned KEY3 = 7;

localparam int unsigned KEY0_OFFSET = index_to_byte_offset(KEY0);
localparam int unsigned KEY1_OFFSET = index_to_byte_offset(KEY1);
localparam int unsigned KEY2_OFFSET = index_to_byte_offset(KEY2);
localparam int unsigned KEY3_OFFSET = index_to_byte_offset(KEY3);

localparam logic KEY0_RW = READ_WRITE;
localparam logic KEY1_RW = READ_WRITE;
localparam logic KEY2_RW = READ_WRITE;
localparam logic KEY3_RW = READ_WRITE;

// data input registers
localparam int unsigned DIN0 = 8;
localparam int unsigned DIN1 = 9;
localparam int unsigned DIN2 = 10;
localparam int unsigned DIN3 = 11;

localparam int unsigned DIN0_OFFSET = index_to_byte_offset(DIN0);
localparam int unsigned DIN1_OFFSET = index_to_byte_offset(DIN1);
localparam int unsigned DIN2_OFFSET = index_to_byte_offset(DIN2);
localparam int unsigned DIN3_OFFSET = index_to_byte_offset(DIN3);

localparam logic DIN0_RW = READ_WRITE;
localparam logic DIN1_RW = READ_WRITE;
localparam logic DIN2_RW = READ_WRITE;
localparam logic DIN3_RW = READ_WRITE;

// associated data registers
localparam int unsigned AD0 = 12;
localparam int unsigned AD1 = 13;
localparam int unsigned AD2 = 14;
localparam int unsigned AD3 = 15;

localparam int unsigned AD0_ADDR = index_to_byte_offset(AD0);
localparam int unsigned AD1_ADDR = index_to_byte_offset(AD1);
localparam int unsigned AD2_ADDR = index_to_byte_offset(AD2);
localparam int unsigned AD3_ADDR = index_to_byte_offset(AD3);

localparam logic AD0_RW = READ_WRITE;
localparam logic AD1_RW = READ_WRITE;
localparam logic AD2_RW = READ_WRITE;
localparam logic AD3_RW = READ_WRITE;

// control register
localparam int unsigned CONTROL = 16;

localparam int unsigned CONTROL_ADDR = index_to_byte_offset(CONTROL);

localparam logic CONTROL_RW = READ_WRITE;

// data output registers
localparam int unsigned DOUT0 = 17;
localparam int unsigned DOUT1 = 18;
localparam int unsigned DOUT2 = 19;
localparam int unsigned DOUT3 = 20;

localparam int unsigned DOUT0_ADDR = index_to_byte_offset(DOUT0);
localparam int unsigned DOUT1_ADDR = index_to_byte_offset(DOUT1);
localparam int unsigned DOUT2_ADDR = index_to_byte_offset(DOUT2);
localparam int unsigned DOUT3_ADDR = index_to_byte_offset(DOUT3);

localparam logic DOUT0_RW = READ_ONLY;
localparam logic DOUT1_RW = READ_ONLY;
localparam logic DOUT2_RW = READ_ONLY;
localparam logic DOUT3_RW = READ_ONLY;

// tag registers
localparam int unsigned TAG0 = 21;
localparam int unsigned TAG1 = 22;
localparam int unsigned TAG2 = 23;
localparam int unsigned TAG3 = 24;

localparam int unsigned TAG0_ADDR = index_to_byte_offset(TAG0);
localparam int unsigned TAG1_ADDR = index_to_byte_offset(TAG1);
localparam int unsigned TAG2_ADDR = index_to_byte_offset(TAG2);
localparam int unsigned TAG3_ADDR = index_to_byte_offset(TAG3);

localparam logic TAG0_RW = READ_ONLY;
localparam logic TAG1_RW = READ_ONLY;
localparam logic TAG2_RW = READ_ONLY;
localparam logic TAG3_RW = READ_ONLY;

// status register
localparam int unsigned STATUS = 25;

localparam int unsigned STATUS_ADDR = index_to_byte_offset(STATUS);

localparam logic STATUS_RW = READ_ONLY;

endpackage