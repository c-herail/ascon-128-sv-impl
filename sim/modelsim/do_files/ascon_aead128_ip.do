set TOP ascon_aead128_ip
set RUNTIME {112 us}

set DUT_PATH /${TOP}_tb/DUT

onerror {resume}

if {$gui_mode} {
    quietly WaveActivateNextPane {} 0

    add wave -noupdate /ascon_aead128_ip_tb/DUT/aclk
    add wave -noupdate /ascon_aead128_ip_tb/DUT/aresetn

    add wave -noupdate -divider {AR CHANNEL}
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.arprot
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/axi.araddr
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.arvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.arready

    add wave -noupdate -divider {R CHANNEL}
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/axi.rdata
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.rresp
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.rvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.rready

    add wave -noupdate -divider {AW CHANNEL}
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.awprot
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/axi.awaddr
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.awvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.awready

    add wave -noupdate -divider {W CHANNEL}
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.wstrb
    add wave -noupdate -radix hexadecimal /ascon_aead128_ip_tb/DUT/axi.wdata
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.wvalid
    add wave -noupdate                    /ascon_aead128_ip_tb/DUT/axi.wready

    add wave -noupdate -divider {B CHANNEL}
    add wave -noupdate /ascon_aead128_ip_tb/DUT/axi.bresp
    add wave -noupdate /ascon_aead128_ip_tb/DUT/axi.bvalid
    add wave -noupdate /ascon_aead128_ip_tb/DUT/axi.bready

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

    WaveRestoreCursors [list {Cursor 1} $RUNTIME 0]
    WaveRestoreZoom {0 ps} $RUNTIME
}

run $RUNTIME