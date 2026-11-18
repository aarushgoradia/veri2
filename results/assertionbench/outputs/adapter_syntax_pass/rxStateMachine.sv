module rxStateMachine_sva (
    input logic rxclk,
    input logic reset,
    input logic recv_enable,
    input logic get_sfd,
    input logic local_invalid,
    input logic length_error,
    input logic crc_check_valid,
    input logic crc_check_invalid,
    input logic get_error_code,
    input logic check_reset,
    input logic start_da,
    input logic start_lt,
    input logic receiving,
    input logic receiving_d1,
    input logic good_frame_get,
    input logic bad_frame_get,
    input logic wait_crc_check,
    input logic get_terminator,
    input logic [4:0] rxstate,
    input logic [4:0] rxstate_next
);

    // Reset forces the state machine into IDLE.
    check_reset_forces_idle: assert property (
        @(posedge rxclk) reset |-> (rxstate == 5'h0)
    );

    // IDLE holds when no SFD is detected.
    check_idle_holds_without_sfd: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h0 && !get_sfd) |=> (rxstate == 5'h0)
    );

    // IDLE advances to rxReceiveDA on a valid SFD.
    check_idle_to_rxReceiveDA: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h0 && get_sfd && recv_enable) |=> (rxstate == 5'h1)
    );

    // rxReceiveDA always advances to rxReceiveLT.
    check_rxReceiveDA_to_rxReceiveLT: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h1) |=> (rxstate == 5'h2)
    );

    // rxReceiveLT always advances to rxReceiveData.
    check_rxReceiveLT_to_rxReceiveData: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h2) |=> (rxstate == 5'h4)
    );

    // rxReceiveData returns to rxReceiveData when no error is detected.
    check_rxReceiveData_holds_on_no_error: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h4 && !local_invalid && !length_error && !get_error_code) |=> (rxstate == 5'h4)
    );

    // rxReceiveData moves to rxGetError on a detected error.
    check_rxReceiveData_to_rxGetError: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h4 && (local_invalid || length_error || get_error_code)) |=> (rxstate == 5'h8)
    );

    // rxGetError returns to rxReceiveDA on a valid SFD.
    check_rxGetError_to_rxReceiveDA: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h8 && get_sfd && recv_enable) |=> (rxstate == 5'h1)
    );

    // rxGetError returns to IDLE when no valid SFD is detected.
    check_rxGetError_to_idle: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h8 && !get_sfd) |=> (rxstate == 5'h0)
    );

    // rxIFGWait returns to rxReceiveDA on a valid SFD.
    check_rxIFGWait_to_rxReceiveDA: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h10 && get_sfd && recv_enable) |=> (rxstate == 5'h1)
    );

    // rxIFGWait returns to IDLE when no valid SFD is detected.
    check_rxIFGWait_to_idle: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h10 && !get_sfd) |=> (rxstate == 5'h0)
    );

    // start_da is asserted only in rxReceiveDA.
    check_start_da_definition: assert property (
        @(posedge rxclk) disable iff (reset)
        (start_da == (rxstate == 5'h1))
    );

    // start_lt is asserted only in rxReceiveLT.
    check_start_lt_definition: assert property (
        @(posedge rxclk) disable iff (reset)
        (start_lt == (rxstate == 5'h2))
    );

    // receiving is asserted in rxReceiveDA, rxReceiveLT, or rxReceiveData.
    check_receiving_definition: assert property (
        @(posedge rxclk) disable iff (reset)
        (receiving == (rxstate[2] || rxstate[1] || rxstate[0]))
    );

    // receiving_d1 is the previous cycle's receiving.
    check_receiving_d1_definition: assert property (
        @(posedge rxclk) disable iff (reset)
        (receiving_d1 == $past(receiving))
    );

    // wait_crc_check is asserted while in rxReceiveData.
    check_wait_crc_check_definition: assert property (
        @(posedge rxclk) disable iff (reset)
        (wait_crc_check == rxstate[4])
    );

    // good_frame_get is asserted only when a valid frame is detected.
    check_good_frame_get_definition: assert property (
        @(posedge rxclk) disable iff (reset)
        (good_frame_get == (crc_check_valid && !rxstate[3] && !length_error))
    );

    // bad_frame_get is asserted only when an error is detected.
    check_bad_frame_get_definition: assert property (
        @(posedge rxclk) disable iff (reset)
        (bad_frame_get == (rxstate[3] || crc_check_invalid || length_error))
    );

    // good_frame_get and bad_frame_get are never asserted together.
    check_good_bad_mutually_exclusive: assert property (
        @(posedge rxclk) disable iff (reset)
        !(good_frame_get && bad_frame_get)
    );

    // good_frame_get is cleared on reset or by check_reset.
    check_good_frame_get_cleared_on_reset_or_check_reset: assert property (
        @(posedge rxclk) disable iff (reset)
        (check_reset || $past(reset)) |=> (good_frame_get == 1'b0)
    );

    // bad_frame_get is cleared on reset or by check_reset.
    check_bad_frame_get_cleared_on_reset_or_check_reset: assert property (
        @(posedge rxclk) disable iff (reset)
        (check_reset || $past(reset)) |=> (bad_frame_get == 1'b0)
    );

    // wait_crc_check is cleared on reset or by check_reset.
    check_wait_crc_check_cleared_on_reset_or_check_reset: assert property (
        @(posedge rxclk) disable iff (reset)
        (check_reset || $past(reset)) |=> (wait_crc_check == 1'b0)
    );

    // wait_crc_check is cleared when a valid CRC is detected.
    check_wait_crc_check_cleared_on_valid_crc: assert property (
        @(posedge rxclk) disable iff (reset)
        crc_check_valid |=> (wait_crc_check == 1'b0)
    );

    // wait_crc_check is cleared when an error is detected.
    check_wait_crc_check_cleared_on_error: assert property (
        @(posedge rxclk) disable iff (reset)
        (crc_check_invalid || length_error) |=> (wait_crc_check == 1'b0)
    );

    // wait_crc_check is set while in rxReceiveData.
    check_wait_crc_check_set_in_rxReceiveData: assert property (
        @(posedge rxclk) disable iff (reset)
        (rxstate == 5'h4) |=> (wait_crc_check == 1'b1)
    );

    // wait_crc_check holds when no valid CRC or error is detected.
    check_wait_crc_check_holds_without_crc_or_error: assert property (
        @(posedge rxclk) disable iff (reset)
        (!crc_check_valid && !crc_check_invalid && !length_error) |=> (wait_crc_check == $past(wait_crc_check))
    );

endmodule