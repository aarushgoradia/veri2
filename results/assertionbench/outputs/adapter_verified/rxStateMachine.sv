module rxStateMachine_sva (
    input logic rxclk,
    input logic reset,
    input logic recv_enable,
    input logic get_sfd,
    input logic local_invalid,
    input logic length_error,
    input logic crc_check_valid,
    input logic crc_check_invalid,
    input logic get_terminator,
    input logic get_error_code,
    input logic check_reset,
    input logic start_da,
    input logic start_lt,
    input logic receiving,
    input logic receiving_d1,
    input logic good_frame_get,
    input logic bad_frame_get,
    input logic wait_crc_check,
    input logic get_terminator_sync,
    input logic crc_check_valid_sync,
    input logic crc_check_invalid_sync,
    input logic check_reset_sync
);

// Reset drives the state machine to IDLE and clears all status bits.
    check_reset_clears_state_and_status: assert property (
        @(posedge rxclk) reset |-> (rxstate == IDLE) && (start_da == 1'b0) && (start_lt == 1'b0) &&
                                   (receiving == 1'b0) && (receiving_d1 == 1'b0) &&
                                   (good_frame_get == 1'b0) && (bad_frame_get == 1'b0) &&
                                   (wait_crc_check == 1'b0)
    );

// IDLE waits for SFD and recv_enable before entering rxReceiveDA.
    check_idle_to_rxReceiveDA: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == IDLE) && get_sfd && recv_enable |=> (rxstate == rxReceiveDA)
    );

// IDLE holds when SFD or recv_enable is not asserted.
    check_idle_holds_without_trigger: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == IDLE) && !get_sfd && !recv_enable |=> (rxstate == IDLE)
    );

// rxReceiveDA advances to rxReceiveLT on the next cycle.
    check_rxReceiveDA_to_rxReceiveLT: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveDA) |=> (rxstate == rxReceiveLT)
    );

// rxReceiveLT advances to rxReceiveData on the next cycle.
    check_rxReceiveLT_to_rxReceiveData: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveLT) |=> (rxstate == rxReceiveData)
    );

// rxReceiveData with no errors advances to rxReceiveData on the next cycle.
    check_rxReceiveData_no_error_holds: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveData) && !local_invalid && !length_error && !get_error_code && !get_terminator |=> (rxstate == rxReceiveData)
    );

// rxReceiveData with local_invalid or length_error or get_error_code transitions to rxGetError.
    check_rxReceiveData_error_to_rxGetError: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveData) && (local_invalid || length_error || get_error_code) |=> (rxstate == rxGetError)
    );

// rxReceiveData with get_terminator transitions to rxIFGWait.
    check_rxReceiveData_terminator_to_rxIFGWait: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveData) && get_terminator |=> (rxstate == rxIFGWait)
    );

// rxGetError waits for SFD and recv_enable before returning to rxReceiveDA.
    check_rxGetError_to_rxReceiveDA: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxGetError) && get_sfd && recv_enable |=> (rxstate == rxReceiveDA)
    );

// rxGetError holds when SFD or recv_enable is not asserted.
    check_rxGetError_holds_without_trigger: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxGetError) && !get_sfd && !recv_enable |=> (rxstate == rxGetError)
    );

// rxIFGWait waits for SFD and recv_enable before returning to rxReceiveDA.
    check_rxIFGWait_to_rxReceiveDA: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxIFGWait) && get_sfd && recv_enable |=> (rxstate == rxReceiveDA)
    );

// rxIFGWait holds when SFD or recv_enable is not asserted.
    check_rxIFGWait_holds_without_trigger: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxIFGWait) && !get_sfd && !recv_enable |=> (rxstate == rxIFGWait)
    );

// wait_crc_check is asserted only when the previous state was rxReceiveData.
    check_wait_crc_check_only_on_rxReceiveData: assert property (
        @(posedge rxclk) disable iff (reset)
        wait_crc_check |-> (rxstate_prev == rxReceiveData)
    );

// wait_crc_check is cleared when a valid CRC is detected.
    check_wait_crc_check_clears_on_valid_crc: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveData) && crc_check_valid |=> (wait_crc_check == 1'b0)
    );

// wait_crc_check is cleared when an invalid CRC is detected.
    check_wait_crc_check_clears_on_invalid_crc: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveData) && crc_check_invalid |=> (wait_crc_check == 1'b0)
    );

// wait_crc_check is cleared when length_error is asserted.
    check_wait_crc_check_clears_on_length_error: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == rxReceiveData) && length_error |=> (wait_crc_check == 1'b0)
    );

// wait_crc_check is cleared when check_reset is asserted.
    check_wait_crc_check_clears_on_check_reset: assert property (
        @(posedge rxclk) disable iff (reset)
        check_reset |=> (wait_crc_check == 1'b0)
    );

// wait_crc_check is set when the previous state was rxReceiveData.
    check_wait_crc_check_sets_on_rxReceiveData: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate_prev == rxReceiveData) |=> (wait_crc_check == 1'b1)
    );

// wait_crc_check holds when the previous state was not rxReceiveData.
    check_wait_crc_check_holds_on_non_rxReceiveData: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate_prev != rxReceiveData) |=> (wait_crc_check == $past(wait_crc_check))
    );

// good_frame_get is asserted only when crc_check_valid is asserted in the previous cycle.
    check_good_frame_get_only_on_valid_crc: assert property (
        @(posedge rxclk) disable iff (reset)
        good_frame_get |-> (crc_check_valid_sync == 1'b1)
    );

// bad_frame_get is asserted only when an error condition is present in the previous cycle.
    check_bad_frame_get_only_on_error: assert property (
        @(posedge rxclk) disable iff (reset)
        bad_frame_get |-> (local_invalid || length_error || get_error_code || crc_check_invalid || get_terminator)
    );

// good_frame_get and bad_frame_get are never asserted together.
    check_good_bad_mutually_exclusive: assert property (
        @(posedge rxclk) disable iff (reset)
        !(good_frame_get && bad_frame_get)
    );

// check_reset clears both status bits.
    check_check_reset_clears_status: assert property (
        @(posedge rxclk) disable iff (reset)
        check_reset |=> (good_frame_get == 1'b0) && (bad_frame_get == 1'b0)
    );

// receiving is asserted only when the previous state was rxReceiveData, rxReceiveLT, or rxReceiveDA.
    check_receiving_only_on_active_states: assert property (
        @(posedge rxclk) disable iff (reset)
        receiving |-> (rxstate_prev == rxReceiveData) || (rxstate_prev == rxReceiveLT) || (rxstate_prev == rxReceiveDA)
    );

// receiving_d1 captures the previous cycle's receiving value.
    check_receiving_d1_captures_previous_receiving: assert property (
        @(posedge rxclk) disable iff (reset)
        1'b1 |=> (receiving_d1 == $past(receiving))
    );

endmodule
