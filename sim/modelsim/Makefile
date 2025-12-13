RTL_DIR      = ../../core
TB_DIR       = ../../testbench
INC_DIR      = ../../include
DO_FILES_DIR = ./do_files
ASCON_C_DIR  = ../../../ascon-128-c-impl
DPI_C        = -sv_lib $(ASCON_C_DIR)/build/lib_sv_ascon_aead128

# run simulation without GUI
# a simulation once over returns either "Test success" or "Test failed"
run-%: %_tb
	vsim -c $(DPI_C) -L rtl_lib -do "set gui_mode 0" -do $(DO_FILES_DIR)/$*.do tb_lib.$*_tb +console_mode=1

# run simulation with GUI
run_gui-%: %_tb
	vsim -gui $(DPI_C) -L rtl_lib -do "set gui_mode 1" -do $(DO_FILES_DIR)/$*.do tb_lib.$*_tb

# run available testbenches
run_all:
	make run-pc                 | grep Test
	make run-sbox               | grep Test
	make run-ps                 | grep Test
	make run-pl                 | grep Test
	make run-permutation        | grep Test
	make run-mux21              | grep Test
	make run-mux41              | grep Test
	make run-data_reg           | grep Test
	make run-round_counter      | grep Test
	make run-ascon_aead128_core | grep Test
	make run-ascon_aead128_ip   | grep Test

# git helper
git_add-%:
	git add $(INC_DIR)/*.sv
	git add $(RTL_DIR)/$*.sv
	git add $(TB_DIR)/$*_tb.sv
	git add $(DO_FILES_DIR)/$*.do

# compile dpi .so library
compile_dpi_lib:
	cd $(ASCON_C_DIR) && make mrproper lib_sv_ascon_aead128

init:
	rm -rf ./ascon_lib
	mkdir ./ascon_lib
	mkdir ./ascon_lib/rtl_lib
	mkdir ./ascon_lib/tb_lib
	vlib ./ascon_lib/rtl_lib
	vlib ./ascon_lib/tb_lib
	vmap rtl_lib ./ascon_lib/rtl_lib
	vmap tb_lib ./ascon_lib/tb_lib

#========== INCLUDE ============================================================

ascon_aead128_pkg: init
	vlog -sv +acc -svinputport=net -work rtl_lib $(INC_DIR)/$@.sv

ascon_aead128_dpi_pkg: init
	vlog -sv +acc -L rtl_lib -svinputport=net -work tb_lib $(INC_DIR)/$@.sv

ascon_aead128_tb_pkg: ascon_aead128_pkg ascon_aead128_dpi_pkg
	vlog -sv +acc -L rtl_lib -svinputport=net -work tb_lib $(INC_DIR)/$@.sv

#========== CORE ===============================================================

pc: ascon_aead128_pkg
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

sbox: ascon_aead128_pkg
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

ps: sbox
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

pl: ascon_aead128_pkg
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

permutation: pc ps pl
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

mux21: init
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

mux41: init
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

data_reg: init
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

data_path: permutation data_reg mux21 mux41
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

round_counter: init ascon_aead128_pkg
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

fsm: init ascon_aead128_pkg
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

ascon_aead128_core: data_path fsm round_counter
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

ascon_aead128_ip: ascon_aead128_core
	vlog -sv +acc -svinputport=net -work rtl_lib $(RTL_DIR)/$@.sv

#========== TESTBENCH ==========================================================

%_tb: ascon_aead128_tb_pkg %
	vlog -sv +acc -L rtl_lib -svinputport=net -work tb_lib $(TB_DIR)/$@.sv