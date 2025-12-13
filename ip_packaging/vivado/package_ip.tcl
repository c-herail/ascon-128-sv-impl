set script_name [file tail [file normalize [info script]]]

set script_dir  [file dirname [file normalize [info script]]]
set root_dir    [file dirname [file dirname $script_dir]]
set core_dir    [file join $root_dir core]
set include_dir [file join $root_dir include]

set project_name    "ascon_aead128"
set project_dir     [file join $script_dir ascon_aead128]
set packaged_ip_dir [file join $project_dir ascon_aead128_ip]

set hdl_files {}

set ip_top ascon_aead128_ip

################################################################################
##### Get HDL files
################################################################################

lappend hdl_files [file join $include_dir ascon_aead128_pkg.sv]

foreach f [glob -nocomplain -directory $core_dir *] {
    if {[file isfile $f]} {
        lappend hdl_files $f
    }
}

################################################################################
##### Remove existing project and IP if any
################################################################################

foreach f [glob -nocomplain -directory $script_dir * .*] {
    set f_name [file tail $f]
    if {$f_name ni {. ..} && $f_name ne $script_name} {
        file delete -force $f
    }
}

################################################################################
##### Create Vivado project
################################################################################

create_project $project_name $project_dir -force
set_property INCREMENTAL false [get_filesets sim_1]

add_files $hdl_files
set_property file_type SystemVerilog [get_files $hdl_files]
set_property top $ip_top [current_fileset]

update_compile_order -fileset sources_1

################################################################################
##### IP packaging
################################################################################

ipx::package_project -root_dir $packaged_ip_dir \
                     -vendor cherail \
                     -library user \
                     -taxonomy /Ascon \
                     -import_files \
                     -set_current true \
                     -force

set_property display_name "Ascon-AEAD128 IP" [ipx::current_core]
set_property vendor_display_name "cherail" [ipx::current_core]
set_property company_url https://github.com/c-herail/ascon-128-sv-impl [ipx::current_core]
set_property description "Ascon-AEAD128 IP with 32-bit AXI4-Lite interface" [ipx::current_core]

ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]

set_property ip_repo_paths $packaged_ip_dir [current_project]
update_ip_catalog

close_project