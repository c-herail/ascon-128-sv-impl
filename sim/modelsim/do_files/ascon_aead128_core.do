set TOP ascon_aead128_core
set RUNTIME {50000 ns}

set DUT           /${TOP}_tb/DUT
set FSM           ${DUT}/FSM
set ROUND_COUNTER ${DUT}/ROUND_COUNTER
set DATA_PATH     ${DUT}/DATA_PATH

onerror {resume}

if {$gui_mode} {
    quietly WaveActivateNextPane {} 0

    add wave -noupdate -divider INPUTS
    add wave -noupdate                    $DUT/clk
    add wave -noupdate                    $DUT/rst_n
    add wave -noupdate                    $DUT/start
    add wave -noupdate                    $DUT/op_mode
    add wave -noupdate                    $DUT/valid_ad
    add wave -noupdate                    $DUT/valid_db_in
    add wave -noupdate -radix hexadecimal $DUT/ad
    add wave -noupdate -radix hexadecimal $DUT/db
    add wave -noupdate -radix hexadecimal $DUT/key
    add wave -noupdate -radix hexadecimal $DUT/nonce

    add wave -noupdate -divider OUTPUTS
    add wave -noupdate                    $DUT/ready
    add wave -noupdate                    $DUT/valid_db_out
    add wave -noupdate                    $DUT/valid_tag
    add wave -noupdate -radix hexadecimal $DUT/dout

    add wave -noupdate -divider {INTERNAL SIGNALS}
    add wave -noupdate                    $DUT/en_internal_s
    add wave -noupdate                    $DUT/en_new_aead_s
    add wave -noupdate                    $DUT/sel_state_s
    add wave -noupdate                    $DUT/sel_din_s
    add wave -noupdate                    $DUT/sel_dout_s
    add wave -noupdate                    $DUT/sel_xor_data_s
    add wave -noupdate                    $DUT/sel_xor_key_s
    add wave -noupdate                    $DUT/end_ad_s
    add wave -noupdate                    $DUT/rnd_cnt_mode_s
    add wave -noupdate                    $DUT/rnd_cnt_incr_s
    add wave -noupdate -radix hexadecimal $DUT/rnd_s

    add wave -noupdate -divider {FSM I/Os}
    add wave -noupdate                    $FSM/clk
    add wave -noupdate                    $FSM/rst_n
    add wave -noupdate                    $FSM/start
    add wave -noupdate                    $FSM/valid_ad
    add wave -noupdate                    $FSM/valid_db_in
    add wave -noupdate -radix hexadecimal $FSM/rnd
    add wave -noupdate                    $FSM/rnd_cnt_mode
    add wave -noupdate                    $FSM/rnd_cnt_incr
    add wave -noupdate                    $FSM/en_internal
    add wave -noupdate                    $FSM/en_new_aead
    add wave -noupdate                    $FSM/sel_state
    add wave -noupdate                    $FSM/sel_din
    add wave -noupdate                    $FSM/sel_dout
    add wave -noupdate                    $FSM/sel_xor_data
    add wave -noupdate                    $FSM/sel_xor_key
    add wave -noupdate                    $FSM/end_ad
    add wave -noupdate                    $FSM/ready
    add wave -noupdate                    $FSM/valid_db_out
    add wave -noupdate                    $FSM/valid_tag

    add wave -noupdate -divider {FSM internal signals}
    add wave -noupdate $FSM/current_state_s
    add wave -noupdate $FSM/next_state_s
    add wave -noupdate $FSM/end_ad_s
    add wave -noupdate $FSM/ad_s
    add wave -noupdate $FSM/db_s

    add wave -noupdate -divider {DATA_PATH I/Os}
    add wave -noupdate                    $DATA_PATH/clk
    add wave -noupdate                    $DATA_PATH/rst_n
    add wave -noupdate                    $DATA_PATH/op_mode
    add wave -noupdate -radix hexadecimal $DATA_PATH/rnd
    add wave -noupdate                    $DATA_PATH/en_internal
    add wave -noupdate                    $DATA_PATH/en_new_aead
    add wave -noupdate                    $DATA_PATH/sel_state
    add wave -noupdate                    $DATA_PATH/sel_din
    add wave -noupdate                    $DATA_PATH/sel_dout
    add wave -noupdate                    $DATA_PATH/sel_xor_data
    add wave -noupdate                    $DATA_PATH/sel_xor_key
    add wave -noupdate                    $DATA_PATH/end_ad
    add wave -noupdate -radix hexadecimal $DATA_PATH/ad
    add wave -noupdate -radix hexadecimal $DATA_PATH/db
    add wave -noupdate -radix hexadecimal $DATA_PATH/key
    add wave -noupdate -radix hexadecimal $DATA_PATH/nonce
    add wave -noupdate -radix hexadecimal $DATA_PATH/dout

    add wave -noupdate -divider {DATA_PATH internal signals}
    add wave -noupdate -radix hexadecimal $DATA_PATH/input_state_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/state_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/internal_state_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/p_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/loop_s
    add wave -noupdate                    $DATA_PATH/sel_mode_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/din_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/key_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/db_s
    add wave -noupdate -radix hexadecimal $DATA_PATH/tag_s

    add wave -noupdate -divider {ROUND_COUNTER I/Os}
    add wave -noupdate                    $ROUND_COUNTER/clk
    add wave -noupdate                    $ROUND_COUNTER/rst_n
    add wave -noupdate                    $ROUND_COUNTER/mode
    add wave -noupdate                    $ROUND_COUNTER/incr
    add wave -noupdate -radix hexadecimal $ROUND_COUNTER/rnd

    TreeUpdate [SetDefaultTree]
    WaveRestoreCursors [list {Cursor 1} $RUNTIME 0]
    quietly wave cursor active 1
    configure wave -namecolwidth 150
    configure wave -valuecolwidth 100
    configure wave -justifyvalue left
    configure wave -signalnamewidth 0
    configure wave -snapdistance 10
    configure wave -datasetprefix 0
    configure wave -rowmargin 4
    configure wave -childrowmargin 2
    configure wave -gridoffset 0
    configure wave -gridperiod 1
    configure wave -griddelta 40
    configure wave -timeline 0
    configure wave -timelineunits ns
    update
    WaveRestoreZoom {0 ps} $RUNTIME
}

run $RUNTIME