set TOP ascon_aead128_ip
set RUNTIME {112 us}

set DUT_PATH /${TOP}_tb/DUT

onerror {resume}

if {$gui_mode} {
    quietly WaveActivateNextPane {} 0

    add wave -noupdate /ascon_aead128_ip_tb/DUT/aclk
    add wave -noupdate /ascon_aead128_ip_tb/DUT/aresetn

    add wave -noupdate -divider {AR CHANNEL}
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/arprot
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/araddr
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/arvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/arready

    add wave -noupdate -divider {R CHANNEL}
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/rdata
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/rresp
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/rvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/rready

    add wave -noupdate -divider {AW CHANNEL}
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/awprot
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/awaddr
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/awvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/awready

    add wave -noupdate -divider {W CHANNEL}
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/wstrb
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/wdata
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/wvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/wready

    add wave -noupdate -divider {B CHANNEL}
    add wave -noupdate /ascon_aead128_ip_tb/DUT/bresp
    add wave -noupdate /ascon_aead128_ip_tb/DUT/bvalid
    add wave -noupdate /ascon_aead128_ip_tb/DUT/bready

    add wave -noupdate -divider {ASCON REGISTERS}
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/regs

    add wave -noupdate -divider {ASCON CORE}
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/clk
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/rst_n
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/start
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/op_mode
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/valid_ad
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/valid_db_in
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/core/ad
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/core/db
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/core/key
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/core/nonce
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/ready
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/valid_db_out
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/valid_tag
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/core/dout

    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/core/FSM/current_state_s

    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/din_status
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/ad_status

    WaveRestoreCursors [list {Cursor 1} $RUNTIME 0]
    WaveRestoreZoom {0 ps} $RUNTIME
}

run $RUNTIME