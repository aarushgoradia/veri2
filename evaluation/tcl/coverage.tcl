# Proof and coverage replay for one design. Called by run_formal_analysis.py.
# No source rewriting, auto-binding, or inferred clock/reset environment.
source [file normalize [lindex $argv end]]

proc write_list {path values} {
    set f [open $path w]
    foreach value $values { puts $f $value }
    close $f
}

proc select_proven {assertions} {
    set proven {}
    set unresolved {}
    set failed {}
    set rows {}
    foreach p $assertions {
        # Fail loudly if verdict extraction is unsupported; never infer success.
        set status [lindex [get_property_info -list validity_status $p] 0]
        lappend rows [list $p $status]
        if {$status eq "proven"} {
            lappend proven $p
        } elseif {$status eq "cex" || $status eq "ar_cex"} {
            lappend failed $p
        } else {
            lappend unresolved $p
        }
    }
    return [list $proven $failed $unresolved $rows]
}

proc json_string {value} {
    set result "\""
    foreach character [split $value ""] {
        scan $character %c code
        if {$code == 34 || $code == 92} {
            append result \\ $character
        } elseif {$code < 32} {
            append result [format {\u%04x} $code]
        } else {
            append result $character
        }
    }
    append result "\""
    return $result
}

proc write_property_details {path properties} {
    set f [open $path w]
    puts $f "\["
    set separator ""
    foreach p $properties {
        set fields [list "\"name\": [json_string $p]"]
        foreach attribute {type status validity_status run_status expression} {
            lappend fields "[json_string $attribute]: [json_string [lindex [get_property_info -list $attribute $p] 0]]"
        }
        if {[get_property_info -list type $p] eq "assert"} {
            set related {}
            # -list returns one element per requested attribute. related_covers
            # is itself a list, so unwrap the attribute before iterating it.
            foreach cover [lindex [get_property_info -list related_covers $p] 0] {
                lappend related [json_string $cover]
            }
            lappend fields "\"related_covers\": \[[join $related {, }]\]"
        } elseif {[get_property_info -list type $p] eq "cover"} {
            lappend fields "\"precondition\": [json_string [lindex [get_property_info -list precondition $p] 0]]"
        }
        puts -nonewline $f "$separator  \{[join $fields {, }]\}"
        set separator ",\n"
    }
    puts $f "\n\]"
    close $f
}

proc restrict_coverage {assertions proven} {
    foreach p $assertions {
        if {[lsearch -exact $proven $p] < 0} { assert -disable $p }
    }
    set enabled [get_property_list -include {type assert disabled 0}]
    if {[lsort $enabled] ne [lsort $proven]} {
        error "Coverage assertion set does not match the proven allowlist"
    }
}

# Unit tests load the procedures without invoking proprietary commands.
if {[info exists TEST_ONLY] && $TEST_ONLY} { return }

proc run_analysis {} {
global OUT_DIR COVERAGE DUT_INSTANCE RTL_FILES SVA_FILES BIND_FILES TOP CLOCK RESET_EXPR TIME_LIMIT PROVE_COVERS DUMP_TRACES
file mkdir $OUT_DIR
if {$COVERAGE ne ""} {
    check_cov -init -type $COVERAGE -exclude_bind_hierarchies -exclude_instance {*} \
        -include_instance [list $DUT_INSTANCE ${DUT_INSTANCE}.*]
}
foreach f $RTL_FILES { analyze -sv12 $f }
foreach f $SVA_FILES { analyze -sv12 $f }
foreach f $BIND_FILES { analyze -sv12 $f }
elaborate -sv09_strong_embedding -top $TOP
if {$CLOCK eq ""} { clock -none } else { clock $CLOCK }
if {$RESET_EXPR eq ""} { reset -none } else { reset -expression $RESET_EXPR }
set_prove_time_limit $TIME_LIMIT

set assertions [get_property_list -include {type assert disabled 0}]
if {[llength $assertions] == 0} { error "No enabled assertions: check top and binding" }
write_list [file join $OUT_DIR assumptions.txt] [get_property_list -include {type assume disabled 0}]
write_property_details [file join $OUT_DIR assumption_details.json] [get_property_list -include {type assume disabled 0}]
redirect -file [file join $OUT_DIR clock_report.txt] -force {clock -list}
redirect -file [file join $OUT_DIR reset_report.txt] -force {reset -list}
set trace_options {}
if {$DUMP_TRACES} {
    file mkdir [file join $OUT_DIR traces]
    set_trace_optimization standard
    set trace_options [list -dump_trace -dump_trace_type vcd -dump_trace_dir [file join $OUT_DIR traces]]
}
prove -all -asserts -silent {*}$trace_options
lassign [select_proven $assertions] proven failed unresolved rows
write_list [file join $OUT_DIR property_status.tcllist] $rows
write_list [file join $OUT_DIR proven.txt] $proven
write_list [file join $OUT_DIR failed.txt] $failed
write_list [file join $OUT_DIR unresolved.txt] $unresolved
set f [open [file join $OUT_DIR summary.txt] w]
puts $f "ASSERT_COUNT=[llength $assertions]"
puts $f "PROVEN_COUNT=[llength $proven]"
puts $f "FAILED_COUNT=[llength $failed]"
puts $f "UNRESOLVED_COUNT=[llength $unresolved]"
close $f

if {$PROVE_COVERS} {
    set covers [get_property_list -include {type cover disabled 0}]
    if {[llength $covers] == 0} { error "No enabled covers: check input and binding" }
    prove -all -covers -silent {*}$trace_options
    set rows {}
    foreach p $covers {
        lappend rows [list $p [lindex [get_property_info -list validity_status $p] 0]]
    }
    write_list [file join $OUT_DIR cover_status.tcllist] $rows
}
write_property_details [file join $OUT_DIR property_details.json] [get_property_list -include {disabled 0}]
report -all -file [file join $OUT_DIR property_report.txt] -force

if {$COVERAGE ne ""} {
    restrict_coverage $assertions $proven
    write_list [file join $OUT_DIR coverage_targets.txt] $proven
    # Do not report a misleading zero/percentage when there are no targets.
    if {[llength $proven] == 0} {
        write_list [file join $OUT_DIR coverage_status.txt] {NO_PROVEN_TARGETS}
    } else {
        check_cov -measure
        check_cov -report -report_file [file join $OUT_DIR coverage_report.txt] -force
        write_list [file join $OUT_DIR coverage_status.txt] {REPORT_WRITTEN}
    }
}
write_list [file join $OUT_DIR completed.txt] {COMPLETED}
}

# -no_gui keeps accepting commands after a Tcl error unless we explicitly exit.
# Record the error and return failure to Slurm instead of leaving an idle session.
if {[catch {run_analysis} message options]} {
    puts stderr [dict get $options -errorinfo]
    write_list [file join $OUT_DIR error.txt] [list $message [dict get $options -errorinfo]]
    exit 1
}
exit 0
