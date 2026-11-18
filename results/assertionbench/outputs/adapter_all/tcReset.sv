module tcReset_sva (
    input logic tcResetEn,
    input logic resetIn,
    input logic [`tcAddrLen-1:0] tcAddr,
    input logic [`tcNumbers-1:0] resetOut
);
    // Clock: tcResetEn; no reset in RTL; logic is sequential (resetOut is a registered vector).

    // resetOut must equal the previous cycle's resetIn indexed by tcAddr.
    check_resetout_matches_prev_cycle: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        resetOut == $past(resetIn)[tcAddr]
    );

    // If tcAddr is unchanged across two cycles, resetOut must be unchanged.
    check_resetout_stable_when_addr_stable: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (tcAddr == $past(tcAddr)) |-> (resetOut == $past(resetOut))
    );

    // If tcAddr changes across two cycles, resetOut must change.
    check_resetout_changes_when_addr_changes: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (tcAddr != $past(tcAddr)) |-> (resetOut != $past(resetOut))
    );

    // If resetIn is unchanged across two cycles, resetOut must be unchanged.
    check_resetout_stable_when_resetin_stable: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (resetIn == $past(resetIn)) |-> (resetOut == $past(resetOut))
    );

    // If resetIn changes across two cycles, resetOut must change.
    check_resetout_changes_when_resetin_changes: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (resetIn != $past(resetIn)) |-> (resetOut != $past(resetOut))
    );

    // If resetOut changes, tcAddr must have changed in the prior cycle.
    check_addr_change_required_when_resetout_changes: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (resetOut != $past(resetOut)) |-> ($past(tcAddr) != $past(tcAddr,2))
    );

    // If tcAddr changes, resetOut must change in the prior cycle.
    check_resetout_change_required_when_addr_changes: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (tcAddr != $past(tcAddr)) |-> ($past(resetOut) != $past(resetOut,2))
    );

    // If resetOut is unchanged, resetIn must have been unchanged in the prior cycle.
    check_resetin_stable_required_when_resetout_stable: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (resetOut == $past(resetOut)) |-> ($past(resetIn) == $past(resetIn,2))
    );

    // If resetOut changes, resetIn must have changed in the prior cycle.
    check_resetin_change_required_when_resetout_changes: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (resetOut != $past(resetOut)) |-> ($past(resetIn) != $past(resetIn,2))
    );

    // If resetIn changes, resetOut must change in the prior cycle.
    check_resetout_change_required_when_resetin_changes: assert property (
        @(posedge tcResetEn) disable iff ($initstate)
        (resetIn != $past(resetIn)) |-> ($past(resetOut) != $past(resetOut,2))
    );

endmodule