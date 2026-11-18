##### Variables #####

##### Procedures #####

proc prop_get_short_name {prop_list} {
    lmap prop $prop_list {
        # prop: <task>::<module/instance path>.<short name>
        lindex [split $prop "."] end
    }
}

proc prop_get_hierarchy_name {prop_list} {
    lmap prop $prop_list {
        # prop: <task>::compare.<u0/1>.<short name>
        # hierarchy name: <u0/1>.<short name>
        regsub {^.*compare\.} $prop ""
    }
}

proc prop_id_to_name {id_list prop_list} {
    lmap id $id_list {
        lindex $prop_list $id
    }
}

proc prop_id_to_short_name {id_list prop_list} {
    lmap id $id_list {
        lindex [split [lindex $prop_list $id] "."] end
    }
}

# proc prop_id_to_hierarchy_name {id_list prop_list} {
#     lmap id $id_list {
#         regsub {^.*compare\.} [lindex $prop_list $id] ""
#     }
# }

proc signal_get_short_name {signal_list} {
    lmap signal $signal_list {
        # signal: <module/instance path>.<short name>
        lindex [split $signal "."] end
    }
}
