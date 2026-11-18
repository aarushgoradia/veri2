module rxLinkFaultState_sva (
    input logic        rxclk,
    input logic        reset,
    input logic        local_fault,
    input logic        remote_fault,
    input logic [1:0]  link_fault,
    input logic [2:0]  linkstate,
    input logic [5:0]  col_cnt,
    input logic        seq_cnt,
    input logic [1:0]  seq_type,
    input logic [1:0]  last_seq_type,
    input logic        reset_col_cnt,
    input logic        seq_cnt_3,
    input logic        col_cnt_64
);

    localparam logic [2:0] IDLE            = 3'd0;
    localparam logic [2:0] LinkFaultDetect = 3'd1;
    localparam logic [2:0] NewFaultType    = 3'd2;
    localparam logic [2:0] GetFault        = 3'd3;

    // Reset clears all state and outputs.
    check_reset_clears_state: assert property (
        @(posedge rxclk) reset |-> (
            (seq_type == 2'b00) &&
            (seq_cnt == 1'b0) &&
            (last_seq_type == 2'b00) &&
            (reset_col_cnt == 1'b1) &&
            (link_fault == 2'b00) &&
            (linkstate == IDLE) &&
            (col_cnt == 6'd0)
        )
    );

    // seq_cnt_3 is the 3-bit MSB of seq_cnt.
    check_seq_cnt_3_definition: assert property (
        @(posedge rxclk) disable iff (reset) seq_cnt_3 == seq_cnt
    );

    // col_cnt_64 is the 6-bit MSB of col_cnt.
    check_col_cnt_64_definition: assert property (
        @(posedge rxclk) disable iff (reset) col_cnt_64 == col_cnt[5]
    );

    // seq_type captures the current fault_type on each clock.
    check_seq_type_captures_fault_type: assert property (
        @(posedge rxclk) disable iff (reset) seq_type == {local_fault, remote_fault}
    );

    // last_seq_type holds the previous seq_type value.
    check_last_seq_type_tracks_previous_seq_type: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> last_seq_type == $past(seq_type)
    );

    // reset_col_cnt is asserted whenever the previous state was IDLE.
    check_reset_col_cnt_asserts_on_idle: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (reset_col_cnt == ($past(linkstate) == IDLE))
    );

    // reset_col_cnt is asserted whenever the previous state was GetFault.
    check_reset_col_cnt_asserts_on_getfault: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (reset_col_cnt == ($past(linkstate) == GetFault))
    );

    // reset_col_cnt is deasserted in all other previous states.
    check_reset_col_cnt_deasserts_elsewhere: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            (reset_col_cnt == 1'b0) ||
            ($past(linkstate) == LinkFaultDetect) ||
            ($past(linkstate) == NewFaultType)
        )
    );

    // link_fault holds its value whenever the previous state was not IDLE.
    check_link_fault_holds_outside_idle: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) != IDLE) |-> (link_fault == $past(link_fault))
        )
    );

    // link_fault loads the previous seq_type whenever the previous state was IDLE.
    check_link_fault_loads_seq_type_on_idle: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == IDLE) |-> (link_fault == $past(seq_type))
        )
    );

    // link_fault loads the previous seq_type whenever the previous state was GetFault.
    check_link_fault_loads_seq_type_on_getfault: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == GetFault) |-> (link_fault == $past(seq_type))
        )
    );

    // seq_cnt is cleared whenever the previous state was IDLE.
    check_seq_cnt_clears_on_idle: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == IDLE) |-> (seq_cnt == 1'b0)
        )
    );

    // seq_cnt increments by one whenever the previous state was LinkFaultDetect and seq_cnt was non-zero.
    check_seq_cnt_increments_on_linkfaultdetect: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == LinkFaultDetect && $past(seq_cnt) == 1'b1) |-> (seq_cnt == $past(seq_cnt) + 1'b1)
        )
    );

    // seq_cnt holds its value whenever the previous state was not LinkFaultDetect or seq_cnt was zero.
    check_seq_cnt_holds_elsewhere: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            (($past(linkstate) != LinkFaultDetect) || ($past(seq_cnt) == 1'b0)) |-> (seq_cnt == $past(seq_cnt))
        )
    );

    // col_cnt is cleared whenever reset_col_cnt was asserted.
    check_col_cnt_clears_on_reset: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            reset_col_cnt |-> (col_cnt == 6'd0)
        )
    );

    // col_cnt increments by one whenever reset_col_cnt was deasserted.
    check_col_cnt_increments_on_count: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            !reset_col_cnt |-> (col_cnt == $past(col_cnt) + 6'd1)
        )
    );

    // linkstate holds its value whenever the previous state was not IDLE.
    check_linkstate_holds_outside_idle: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) != IDLE) |-> (linkstate == $past(linkstate))
        )
    );

    // linkstate holds its value whenever the previous state was GetFault.
    check_linkstate_holds_on_getfault: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == GetFault) |-> (linkstate == $past(linkstate))
        )
    );

    // linkstate transitions from IDLE to LinkFaultDetect on a detected fault.
    check_linkstate_idle_to_linkfaultdetect: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == IDLE && $past(local_fault | remote_fault)) |-> (linkstate == LinkFaultDetect)
        )
    );

    // linkstate transitions from LinkFaultDetect to NewFaultType on a new fault type.
    check_linkstate_linkfaultdetect_to_newfaulttype: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == LinkFaultDetect && $past(local_fault | remote_fault) && !$past(local_fault == remote_fault)) |-> (linkstate == NewFaultType)
        )
    );

    // linkstate transitions from LinkFaultDetect to IDLE on a detected fault with no new type and non-zero seq_cnt.
    check_linkstate_linkfaultdetect_to_idle: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == LinkFaultDetect && $past(local_fault | remote_fault) && $past(local_fault == remote_fault) && $past(seq_cnt)) |-> (linkstate == IDLE)
        )
    );

    // linkstate transitions from LinkFaultDetect to itself on a detected fault with no new type and zero seq_cnt.
    check_linkstate_linkfaultdetect_stays_on_zero_seq_cnt: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == LinkFaultDetect && $past(local_fault | remote_fault) && $past(local_fault == remote_fault) && !$past(seq_cnt)) |-> (linkstate == LinkFaultDetect)
        )
    );

    // linkstate transitions from LinkFaultDetect to IDLE when the previous count reached 64.
    check_linkstate_linkfaultdetect_to_idle_on_col_cnt_64: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == LinkFaultDetect && !$past(local_fault | remote_fault) && $past(col_cnt_64)) |-> (linkstate == IDLE)
        )
    );

    // linkstate transitions from LinkFaultDetect to itself when the previous count did not reach 64.
    check_linkstate_linkfaultdetect_stays_on_no_col_cnt_64: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == LinkFaultDetect && !$past(local_fault | remote_fault) && !$past(col_cnt_64)) |-> (linkstate == LinkFaultDetect)
        )
    );

    // linkstate transitions from NewFaultType to LinkFaultDetect on the next cycle.
    check_linkstate_newfaulttype_to_linkfaultdetect: assert property (
        @(posedge rxclk) disable iff (reset) 1'b1 |=> (
            ($past(linkstate) == NewFaultType) |-> (linkstate == LinkFaultDetect)
        )
    );

endmodule