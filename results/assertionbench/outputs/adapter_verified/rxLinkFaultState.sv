module rxLinkFaultState_sva (
    input logic rxclk,
    input logic reset,
    input logic local_fault,
    input logic remote_fault,
    input logic [1:0] link_fault
);

// Reset drives link_fault to 00 on the next clock.
    check_reset_clears_link_fault: assert property (
        @(posedge rxclk) reset |=> (link_fault == 2'b00)
    );

// In IDLE with no faults, link_fault remains 00 on the next clock.
    check_idle_no_faults_hold_zero: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b00) && !local_fault && !remote_fault |=> (link_fault == 2'b00)
    );

// In IDLE with any fault, link_fault becomes 01 on the next clock.
    check_idle_any_fault_sets_one: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b00) && (local_fault || remote_fault) |=> (link_fault == 2'b01)
    );

// In LinkFaultDetect with no new fault type, link_fault becomes 01 on the next clock.
    check_linkfaultdetect_no_newtype_sets_one: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b01) && !local_fault && !remote_fault |=> (link_fault == 2'b01)
    );

// In LinkFaultDetect with a new fault type, link_fault becomes 10 on the next clock.
    check_linkfaultdetect_newtype_sets_two: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b01) && (local_fault || remote_fault) |=> (link_fault == 2'b10)
    );

// In NewFaultType, link_fault becomes 01 on the next clock.
    check_newfaulttype_sets_one: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b10) |=> (link_fault == 2'b01)
    );

// In IDLE with any fault, link_fault becomes 01 on the next clock.
    check_idle_any_fault_sets_one: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b00) && (local_fault || remote_fault) |=> (link_fault == 2'b01)
    );

// In LinkFaultDetect with a new fault type, link_fault becomes 10 on the next clock.
    check_linkfaultdetect_newtype_sets_two: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b01) && (local_fault || remote_fault) |=> (link_fault == 2'b10)
    );

// In NewFaultType, link_fault becomes 01 on the next clock.
    check_newfaulttype_sets_one: assert property (
        @(posedge rxclk) disable iff (reset)
        (link_fault == 2'b10) |=> (link_fault == 2'b01)
    );

endmodule
