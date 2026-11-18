##### Parameters #####
# Cmd: jg -no_gui -proj <proj_dir> driver.tcl --- <config>   (see run_quality_checks.py)

set checker_file [lindex $argv end-3]
set clock [lindex $argv end-2]
set reset [lindex $argv end-1]
set work_dir [lindex $argv end]

set output_file "${work_dir}/tautologies.txt"

##### Set up #####

analyze -sv12 ${checker_file}
elaborate -sv09_strong_embedding -top $::CHECK_TOP

clock $clock {*}$::CHECK_CLOCK_OPTIONS
reset -formal $reset -bound 3

##### Tautology Check #####

source [file join [file dirname [info script]] utils.tcl]

# Create a new task for the tautology check
check_record checker_input [concat [get_property_list -include {type assert}] [get_property_list -include {type assume}]]
task -create <tautology_chk> -copy_assumes -copy_asserts

# Convert all assumptions to assertions
foreach prop [get_property_list -include "task <tautology_chk> type assume"] {
    assert -from_assume $prop
    assume -remove $prop
    assert -rename $prop:assert $prop
}

# Obtain tautologies (assertions that are proven without any assumptions)
prove -task <tautology_chk> -asserts -silent
set tautologies [prop_get_short_name [get_property_list -include "task <tautology_chk> type assert status proven"]]

check_record tautology [get_property_list -include "task <tautology_chk> type assert"]

task -remove <tautology_chk>

##### Report results #####

set f [open $output_file "w"]
puts $f $tautologies
close $f

exit
