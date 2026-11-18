# Execution/reporting adapter. The checking algorithms are in tautology_chk.tcl and redundancy_chk.tcl.
source [file normalize [lindex $argv end]]
if {![info exists CHECK_CLOCK_OPTIONS]} { set CHECK_CLOCK_OPTIONS {} }

proc json_string {value} {
    set result "\""
    foreach c [split $value ""] {
        scan $c %c code
        if {$code == 34 || $code == 92} { append result \\ $c
        } elseif {$code < 32} { append result [format {\u%04x} $code]
        } else { append result $c }
    }
    append result "\""
    return $result
}

proc check_record {phase properties} {
    set f [open [file join $::CHECK_WORK events.jsonl] a]
    foreach p $properties {
        set fields [list "\"phase\": [json_string $phase]" "\"name\": [json_string $p]"]
        array unset details
        array set details [get_property_info $p]
        regsub {^.*::} $p "" local_name
        if {$phase eq "checker_input"} { set ::CHECK_ORIGINAL_TYPE($local_name) $details(type) }
        if {$phase eq "redundancy_input"} { set ::CHECK_GROUP $details(type) }
        set source_type $details(type)
        if {[info exists ::CHECK_GROUP]} {
            set source_type $::CHECK_GROUP
        } elseif {[info exists ::CHECK_ORIGINAL_TYPE($local_name)]} {
            set source_type $::CHECK_ORIGINAL_TYPE($local_name)
        }
        lappend fields "\"source_type\": [json_string $source_type]"
        foreach key {type status validity_status run_status} {
            set value ""
            if {[info exists details($key)]} { set value $details($key) }
            lappend fields "[json_string $key]: [json_string $value]"
        }
        puts $f "\{[join $fields {, }]\}"
    }
    close $f
}

proc check_prepare_exclusions {top} {
    set f [open [file join $::CHECK_WORK excluded_props.txt] w]
    set audit [open [file join $::CHECK_WORK exclusions.jsonl] w]
    set excluded {}
    foreach p [concat [get_property_list -include {type assert}] [get_property_list -include {type assume}]] {
        set name [lindex [get_property_info -list name $p] 0]
        set prefix "${top}."
        if {[string first $prefix $name] != 0} { error "Unexpected checker hierarchy: $name" }
        set suffix [string range $name [string length $prefix] end]
        # Existing proof evidence uses unique source labels. Ambiguous generated
        # labels are excluded explicitly rather than guessing a hierarchy join.
        set label [lindex [split $suffix .] end]
        set reason ""
        if {[lindex [get_property_info -list type $p] 0] eq "assert" &&
            ![dict exists $::BASELINE_PROVEN $label]} { set reason NO_UNIQUE_BASELINE_PROOF }
        if {[lsearch -exact $::TAUTOLOGIES $label] >= 0} { set reason TAUTOLOGY }
        if {$reason ne ""} {
            lappend excluded $suffix
            puts $audit "\{\"name\": [json_string $name], \"reason\": [json_string $reason]\}"
        }
    }
    puts -nonewline $f [join $excluded " "]
    close $f
    close $audit
}

if {[info exists CHECK_TEST_ONLY] && $CHECK_TEST_ONLY} { return }
set_prove_time_limit $CHECK_TIME_LIMIT
set argv [list $CHECK_CHECKER $CHECK_CLOCK $CHECK_RESET $CHECK_WORK]
# The check scripts call exit. Turn that call into a return to this adapter,
# so successful completion can be distinguished from an interrupted/failed run.
rename exit check_real_exit
proc exit {args} { return -code return }
if {[catch {source $CHECK_SCRIPT} message options] == 1} {
    set f [open [file join $CHECK_WORK error.txt] w]
    puts $f [dict get $options -errorinfo]
    close $f
    puts stderr [dict get $options -errorinfo]
    check_real_exit 1
}
set f [open [file join $CHECK_WORK completed.txt] w]
puts $f COMPLETED
close $f
check_real_exit 0
