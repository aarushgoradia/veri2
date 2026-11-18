##### Parameters #####
# Cmd: jg -no_gui -proj <proj_dir> driver.tcl --- <config>   (see run_quality_checks.py)

set checker_file [lindex $argv end-3]
set clock [lindex $argv end-2]
set reset [lindex $argv end-1]
set work_dir [lindex $argv end]

set excluded_props_file "${work_dir}/excluded_props.txt"

set output_file "${work_dir}/redundant_props.txt"

##### Set up #####

analyze -sv12 ${checker_file}
elaborate -sv09_strong_embedding -top $::CHECK_TOP

clock $clock {*}$::CHECK_CLOCK_OPTIONS
reset -formal $reset -bound 3

set top_module [get_top_module]
check_prepare_exclusions $top_module

# Disable the excluded properties (tautologies and incorrect properties)
if {[file exists $excluded_props_file]} {
    set f [open $excluded_props_file "r"]
    set excluded_props [split [read -nonewline $f] " "]
    close $f

    foreach prop $excluded_props {
        # assume/assert -disable <prop>
        [get_property_info -list command "${top_module}.$prop"] -disable "${top_module}.$prop"
    }
}

##### Procedures #####

source [file join [file dirname [info script]] utils.tcl]

proc get_redundant_props {prop_list} {
    if {[llength $prop_list] == 0} { return }
    
    check_record redundancy_input $prop_list

    # Create a new task for the redundancy check
    task -create <redundancy_chk> -copy $prop_list

    # Convert each assertion to an assumption
    # foreach prop [get_property_list -include "task <redundancy_chk> type assert"] {
    #     assume -from_assert $prop
    #     assert -remove $prop
    #     assume -rename $prop:assume $prop
    # }
    
    # Constuct an assumption/assertion pair for each property
    foreach prop [get_property_list -include "task <redundancy_chk>"] {
        if {[get_property_info $prop -list type] == "assume"} {
            assert -from_assume $prop
            assume -enable $prop
        } else {
            assume -from_assert $prop
            assert -enable $prop
        }
    }

    set redundant_props [list]
    # Note: This algorithm computes a minimal set of non-redundant properties,
    #       but the order of checking may affect which properties are marked redundant.
    
    # foreach prop [get_property_list -include "task <redundancy_chk> type assume"] {
    #     # Assert the target property and disable its assume
    #     assert -from_assume $prop
    #     prove -property ${prop}:assert -silent

    #     if {[get_property_info ${prop}:assert -list status] == "proven"} {
    #         # Redundant property
    #         lappend redundant_props $prop
    #     } else {
    #         # Not redundant: Add back the assume
    #         assume -enable $prop
    #     }
    #     assert -remove ${prop}:assert
    # }

    foreach prop_assume [get_property_list -include "task <redundancy_chk> type assume"] {
        if {[get_property_info $prop_assume -list converted] == 0} {
            set prop $prop_assume
            set prop_assert ${prop}:assert
        } else {
            set prop [string range $prop_assume 0 end-7]
            set prop_assert ${prop}
        }

        assume -disable $prop_assume
        prove -property $prop_assert -silent
        check_record redundancy_step [list $prop_assert]
        
        if {[get_property_info $prop_assert -list status] == "proven"} {
            # Redundant property
            lappend redundant_props $prop
        } else {
            # Not redundant: Add back the assume
            assume -enable $prop_assume
        }
    }

    task -remove <redundancy_chk>
    return [prop_get_short_name $redundant_props]
}

##### Redundancy check #####

# Extract properties from the checker
# Note: Separate environment (assume) and design (assert) constraints
set assume_list [get_property_list -include "type assume name ${top_module}.* disabled 0"]
set assert_list [get_property_list -include "type assert name ${top_module}.* disabled 0"]

set redundant_assume_props [get_redundant_props $assume_list]
set redundant_assert_props [get_redundant_props $assert_list]
set redundant_props [concat $redundant_assume_props $redundant_assert_props]

# task -create <redundancy_chk_assume>

# # Assume all properties
# foreach prop $assume_list {
#     set name [get_property_info -list {name} $prop]
#     set expr [get_property_info -list {expression} $prop]

#     assume -name <redundancy_chk_assume>::${name} $expr
# }

# set assume_redundant_list [list]
# # Note: This algorithm computes a minimal set of non-redundant properties,
# #       but the order of checking may affect which properties are marked redundant.
# foreach prop $assume_list {
#     set name [get_property_info -list {name} $prop]

#     # Assert the target property and disable its assume
#     assert -from_assume <redundancy_chk_assume>::${name}
#     prove -property <redundancy_chk_assume>::${name}:assert -silent

#     if {[get_property_info <redundancy_chk_assume>::${name}:assert -list status] == "proven"} {
#         # Redundant property
#         lappend assume_redundant_list $name
#     } else {
#         # Not redundant: Add back the assume
#         assume -enable <redundancy_chk_assume>::${name}
#     }
#     assert -remove <redundancy_chk_assume>::${name}:assert
# }

# set assume_redundant_list [prop_get_short_name $assume_redundant_list]

# task -remove <redundancy_chk_assume>

# task -create <redundancy_chk_assert>

# # Assume all properties
# foreach prop $assert_list {
#     set name [get_property_info -list {name} $prop]
#     set expr [get_property_info -list {expression} $prop]

#     assume -name <redundancy_chk_assert>::${name} $expr
# }

# set assert_redundant_list [list]
# foreach prop $assert_list {
#     set name [get_property_info -list {name} $prop]

#     # Assert the target property and disable its assume
#     assert -from_assume <redundancy_chk_assert>::${name}
#     prove -property <redundancy_chk_assert>::${name}:assert -silent

#     if {[get_property_info <redundancy_chk_assert>::${name}:assert -list status] == "proven"} {
#         # Redundant property
#         lappend assert_redundant_list $name
#     } else {
#         # Not redundant: Add back the assume
#         assume -enable <redundancy_chk_assert>::${name}
#     }
#     assert -remove <redundancy_chk_assert>::${name}:assert
# }

# set assert_redundant_list [prop_get_short_name $assert_redundant_list]

# task -remove <redundancy_chk_assert>

# set redundant_list [concat $assume_redundant_list $assert_redundant_list]

##### Report results #####

set f [open $output_file "w"]
puts $f $redundant_props
close $f

exit
