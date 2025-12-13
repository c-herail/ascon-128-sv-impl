package ascon_aead128_dpi_pkg;

/** data types for DPI-C ******************************************************/

typedef struct {
    longint unsigned s0;
    longint unsigned s1;
    longint unsigned s2;
    longint unsigned s3;
    longint unsigned s4;
} state;

typedef struct {
    longint unsigned msb;
    longint unsigned lsb;
} uint128;

typedef struct {
    longint unsigned size;
    uint128 arr[];
} data;

typedef uint128 key;
typedef uint128 nonce;
typedef uint128 tag;

typedef data plaintext;
typedef data ciphertext;

typedef struct {
    ciphertext ciphertext;
    tag tag;
} encryption_result;

typedef struct {
    plaintext plaintext;
    bit valid;
} decryption_result;

/** DPI-C functions ***********************************************************/

import "DPI-C" function void pc(inout state s, input byte unsigned rnd);
import "DPI-C" function void ps(inout state s);
import "DPI-C" function void pl(inout state s);
import "DPI-C" function void permutation(inout state s, input byte unsigned rnd);
import "DPI-C" function void p8(inout state s);
import "DPI-C" function void p12(inout state s);

import "DPI-C" function byte unsigned sv_ascon128_enc(input key k,
                                                      input nonce n,
                                                      input longint unsigned ad_size,
                                                      input uint128 ad_arr[],
                                                      input longint unsigned p_size,
                                                      input uint128 p_arr[],
                                                      output uint128 c_arr[],
                                                      output tag t);

import "DPI-C" function byte unsigned sv_ascon128_dec(input key k,
                                                      input nonce n,
                                                      input longint unsigned ad_size,
                                                      input uint128 ad_arr[],
                                                      input tag t,
                                                      input longint unsigned c_size,
                                                      input uint128 c_arr[],
                                                      output uint128 p_arr[],
                                                      output byte unsigned dec_valid);

endpackage : ascon_aead128_dpi_pkg