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

endpackage