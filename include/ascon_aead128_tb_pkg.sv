package ascon_aead128_tb_pkg;

import ascon_aead128_pkg::*;
import ascon_aead128_dpi_pkg::*;

/** testbench *****************************************************************/

localparam bit TEST_SUCCESS = 1'b1;
localparam bit TEST_FAILED  = 1'b0;

function void display_states(ascon_state actual, ascon_state expected);
    $display("---------------------------------------------------------------");
    if (actual != expected) begin
        $display("Error : actual state different from expected state");
    end

    $display("expected: [s0: %h] [s1: %h] [s2: %h] [s3: %h] [s4: %h]",
              expected.s0, expected.s1, expected.s2, expected.s3, expected.s4 );
    $display("  actual: [s0: %h] [s1: %h] [s2: %h] [s3: %h] [s4: %h]",
                         actual.s0, actual.s1, actual.s2, actual.s3, actual.s4);
endfunction

function void display_result(bit result, string dut_name);
    if (result == TEST_SUCCESS) $display("Test success (%s)", dut_name);
    else $display("Test failed (%s)", dut_name);
endfunction

function void stop_simulation;
    if ($test$plusargs("console_mode")) begin
        $finish;
    end
endfunction

/** extended class types ******************************************************/

class state_ex;

    state _state;

    function new;
        this._state = '{s0 : 0, s1 : 0, s2 : 0, s3 : 0, s4 : 0};
    endfunction

    function void urandomize;
        this._state = '{
            s0 : {$urandom(), $urandom()},
            s1 : {$urandom(), $urandom()},
            s2 : {$urandom(), $urandom()},
            s3 : {$urandom(), $urandom()},
            s4 : {$urandom(), $urandom()}
        };
    endfunction

    function ascon_state get;
        ascon_state s = '{s0 : this._state.s0,
                          s1 : this._state.s1,
                          s2 : this._state.s2,
                          s3 : this._state.s3,
                          s4 : this._state.s4};
        return s;
    endfunction

    function string get_as_string;
        string s;
        $sformat(s, "%h%h%h%h%h", this._state.s0, this._state.s1,
                                  this._state.s2, this._state.s3,
                                  this._state.s4);
        return s;
    endfunction

    function void set(ascon_state new_val);
        $cast(this._state.s0, new_val.s0);
        $cast(this._state.s1, new_val.s1);
        $cast(this._state.s2, new_val.s2);
        $cast(this._state.s3, new_val.s3);
        $cast(this._state.s4, new_val.s4);
    endfunction

    function state_ex pc(round rnd);
        byte unsigned r;
        $cast(r, {4'h0, rnd});
        ascon_aead128_dpi_pkg::pc(this._state, r);
        return this;
    endfunction

    function state_ex ps;
        ascon_aead128_dpi_pkg::ps(this._state);
        return this;
    endfunction

    function state_ex pl;
        ascon_aead128_dpi_pkg::pl(this._state);
        return this;
    endfunction

    function state_ex permutation(round rnd);
        byte unsigned r;
        $cast(r, {4'h0, rnd});
        ascon_aead128_dpi_pkg::permutation(this._state, r);
        return this;
    endfunction

    function state_ex p8;
        ascon_aead128_dpi_pkg::p8(this._state);
        return this;
    endfunction

    function state_ex p12;
        ascon_aead128_dpi_pkg::p12(this._state);
        return this;
    endfunction

    function void display;
        $display("s0 : %h, s1 : %h, s2 : %h, s3 : %h, s4 : %h\n",
                    this._state.s0, this._state.s1, this._state.s2,
                    this._state.s3, this._state.s4);
    endfunction

endclass

endpackage : ascon_aead128_tb_pkg