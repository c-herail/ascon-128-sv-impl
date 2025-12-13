set TOP mux41
set RUNTIME {2000 ns}

set DUT_PATH /${TOP}_tb/DUT

onerror {resume}

if {$gui_mode} {
    quietly WaveActivateNextPane {} 0

    add wave -noupdate -divider INPUTS
    add wave -noupdate -radix hexadecimal $DUT_PATH/sel
    add wave -noupdate -radix hexadecimal $DUT_PATH/a
    add wave -noupdate -radix hexadecimal $DUT_PATH/b
    add wave -noupdate -radix hexadecimal $DUT_PATH/c
    add wave -noupdate -radix hexadecimal $DUT_PATH/d

    add wave -noupdate -divider OUTPUTS
    add wave -noupdate -radix hexadecimal $DUT_PATH/s

    TreeUpdate [SetDefaultTree]
    WaveRestoreCursors {{Cursor 1} $RUNTIME 0}
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