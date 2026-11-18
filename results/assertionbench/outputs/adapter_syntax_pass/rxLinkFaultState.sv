module rxLinkFaultState_sva (
    input logic rxclk,
    input logic reset,
    input logic local_fault,
    input logic remote_fault,
    input logic [1:0] link_fault,
    input logic [2:0] linkstate,
    input logic [5:0] col_cnt,
    input logic seq_cnt,
    input logic [1:0] seq_type,
    input logic [1:0] last_seq_type,
    input logic reset_col_cnt
);

    // Reset clears all state and outputs by the next clock.
    check_reset_clears_state: assert property (
        @(posedge rxclk)
        reset |=> (
            (seq_type == 2'b00) &&
            (seq_cnt == 1'b0) &&
            (last_seq_type == 2'b00) &&
            (reset_col_cnt == 1'b1) &&
            (link_fault == 2'b00) &&
            (linkstate == 3'b000) &&
            (col_cnt == 6'd0)
        )
    );

    // IDLE clears the counter and fault state on the next clock.
    check_idle_clears_state: assert property (
        @(posedge rxclk) disable iff (reset)
        (linkstate == 3'b000) |=> (
            (seq_type == 2'b00) &&
            (seq_cnt == 1'b0) &&
            (last_seq_type == 2'b00) &&
            (reset_col_cnt == 1'b1) &&
            (link_fault == 2'b00) &&
            (col_cnt == 6'd0)
        )
    );

    // IDLE advances to LinkFaultDetect when any fault is detected.
    check_idle_to_detect_on_any_fault: assert property (
        @(posedge rxclk) disable iff (reset)
        ((linkstate == 3'b000) && (local_fault || remote_fault)) |=> (linkstate == 3'b001)
    );

    // IDLE holds when no fault is detected.
    check_idle_holds_without_fault: assert property (
        @(posedge rxclk) disable iff (reset)
        ((linkstate == 3'b000) && !(local_fault || remote_fault)) |=> (linkstate == 3'b000)
    );

    // LinkFaultDetect increments the counter while waiting for a 64-cycle idle.
    check_detect_counter_increments: assert property (
        @(posedge rxclk) disable iff (reset)
        ((linkstate == 3'b001) && !(local_fault || remote_fault)) |=> (col_cnt == ($past(col_cnt) + 6'd1))
    );

    // LinkFaultDetect clears the counter on a 64-cycle idle.
    check_detect_counter_resets_on_64: assert property (
        @(posedge rxclk) disable iff (reset)
        ((linkstate == 3'b001) && !(local_fault || remote_fault) && (&col_cnt)) |=> (col_cnt == 6'd0)
    );

    // LinkFaultDetect returns to IDLE when the counter is zero.
    check_detect_returns_to_idle_on_zero_count: assert property (
        @(posedge rxclk) disable iff (reset)
        ((linkstate == 3'b001) && !(local_fault || remote_fault) && (col_cnt == 6'd0)) |=> (linkstate == 3'b000)
    );

    // LinkFaultDetect holds when a new fault type is detected.
    check_detect_holds_on_new_type: assert property (
        @(posedge rxclk) disable iff (reset)
        ((linkstate == 3'b001) && (local_fault || remote_fault) && (seq_type != last_seq_type)) |=> (linkstate == 3'b001)
    );

    // LinkFaultDetect advances to NewFaultType when a new fault type is not detected.
    check_detect_to_new_type_on_no_new_type: assert property (
        @(posedge rxclk) disable iff (reset)
        ((linkstate == 3'b001) && (local_fault || remote_fault) && (seq_type == last_seq_type)) |=> (linkstate == 3'b010)
    );

    // NewFaultType clears the counter and returns to LinkFaultDetect.
    check_new_type_clears_counter_and_returns_to_detect: assert property (
        @(posedge rxclk) disable iff (reset)
        (linkstate == 3'b010) |=> (
            (seq_cnt == 1'b0) &&
            (linkstate == 3'b001)
        )
    );

endmodule