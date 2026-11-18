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
    input logic check_reset_internal,
    input logic [4:0] rxstate,
    input logic [4:0] rxstate_next
);

    localparam logic [4:0] IDLE = 5'b00000;
    localparam logic [4:0] rxReceiveDA = 5'b00001;
    localparam logic [4:0] rxReceiveLT = 5'b00010;
    localparam logic [4:0] rxReceiveData = 5'b00100;
    localparam logic [4:0] rxGetError = 5'b01000;
    localparam logic [4:0] rxIFGWait = 5'b10000;

    // Reset drives the state machine to IDLE.
    check_reset_state: assert property (
        @(posedge rxclk) reset |-> (rxstate == IDLE)
    );

    // Reset drives the state register to IDLE.
    check_reset_state_reg: assert property (
        @(posedge rxclk) reset |-> (rxstate == IDLE)
    );

    // Reset clears the receiving flag.
    check_reset_receiving: assert property (
        @(posedge rxclk) reset |-> (receiving == 1'b0)
    );

    // Reset clears the receiving delayed flag.
    check_reset_receiving_d1: assert property (
        @(posedge rxclk) reset |-> (receiving_d1 == 1'b0)
    );

    // Reset clears the wait CRC check flag.
    check_reset_wait_crc_check: assert property (
        @(posedge rxclk) reset |-> (wait_crc_check == 1'b0)
    );

    // Reset clears the good and bad frame flags.
    check_reset_frame_flags: assert property (
        @(posedge rxclk) reset |-> ((good_frame_get == 1'b0) && (bad_frame_get == 1'b0))
    );

    // Start DA is asserted only in rxReceiveDA state.
    check_start_da_decode: assert property (
        @(posedge rxclk) disable iff (reset) (start_da == (rxstate == rxReceiveDA))
    );

    // Start LT is asserted only in rxReceiveLT state.
    check_start_lt_decode: assert property (
        @(posedge rxclk) disable iff (reset) (start_lt == (rxstate == rxReceiveLT))
    );

    // Receiving is asserted only in the three active states.
    check_receiving_decode: assert property (
        @(posedge rxclk) disable iff (reset) (receiving == (rxstate inside {rxReceiveDA, rxReceiveLT, rxReceiveData}))
    );

    // Receiving delayed follows the previous cycle's receiving value.
    check_receiving_d1_follows_receiving: assert property (
        @(posedge rxclk) disable iff (reset) $past(!reset) |-> (receiving_d1 == $past(receiving))
    );

    // wait_crc_check is asserted only in rxReceiveData state.
    check_wait_crc_check_decode: assert property (
        @(posedge rxclk) disable iff (reset) (wait_crc_check == (rxstate == rxReceiveData))
    );

    // good_frame_get is asserted only in rxReceiveData state with no errors.
    check_good_frame_get_decode: assert property (
        @(posedge rxclk) disable iff (reset) (good_frame_get == ((rxstate == rxReceiveData) && !local_invalid && !length_error && !get_error_code))
    );

    // bad_frame_get is asserted only in rxReceiveData state with an error.
    check_bad_frame_get_decode: assert property (
        @(posedge rxclk) disable iff (reset) (bad_frame_get == ((rxstate == rxReceiveData) && (local_invalid || length_error || get_error_code)))
    );

    // good_frame_get and bad_frame_get are never asserted together.
    check_frame_flags_mutex: assert property (
        @(posedge rxclk) disable iff (reset) !(good_frame_get && bad_frame_get)
    );

    // check_reset_internal is a direct copy of check_reset.
    check_check_reset_internal: assert property (
        @(posedge rxclk) disable iff (reset) (check_reset_internal == check_reset)
    );

    // IDLE holds when no SFD is detected and recv_enable is low.
    check_idle_hold_no_sfd: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == IDLE && !get_sfd && !recv_enable) |=> (rxstate == IDLE)
    );

    // IDLE advances to rxReceiveDA on a valid SFD with recv_enable high.
    check_idle_advance_on_sfd: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == IDLE && get_sfd && recv_enable) |=> (rxstate == rxReceiveDA)
    );

    // rxReceiveDA advances to rxReceiveLT on the next cycle.
    check_rxReceiveDA_advance: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveDA) |=> (rxstate == rxReceiveLT)
    );

    // rxReceiveLT advances to rxReceiveData on the next cycle.
    check_rxReceiveLT_advance: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveLT) |=> (rxstate == rxReceiveData)
    );

    // rxReceiveData holds when no error, terminator, or reset is detected.
    check_rxReceiveData_hold: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && !local_invalid && !length_error && !get_error_code && !get_terminator && !check_reset) |=> (rxstate == rxReceiveData)
    );

    // rxReceiveData advances to rxGetError on a data error.
    check_rxReceiveData_error_advance: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && (local_invalid || length_error || get_error_code)) |=> (rxstate == rxGetError)
    );

    // rxReceiveData advances to rxIFGWait on a terminator.
    check_rxReceiveData_terminator_advance: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && get_terminator) |=> (rxstate == rxIFGWait)
    );

    // rxGetError holds when no SFD is detected and recv_enable is low.
    check_rxGetError_hold_no_sfd: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxGetError && !get_sfd && !recv_enable) |=> (rxstate == rxGetError)
    );

    // rxGetError advances to rxReceiveDA on a valid SFD with recv_enable high.
    check_rxGetError_advance_on_sfd: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxGetError && get_sfd && recv_enable) |=> (rxstate == rxReceiveDA)
    );

    // rxIFGWait holds when no SFD is detected and recv_enable is low.
    check_rxIFGWait_hold_no_sfd: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxIFGWait && !get_sfd && !recv_enable) |=> (rxstate == rxIFGWait)
    );

    // rxIFGWait advances to rxReceiveDA on a valid SFD with recv_enable high.
    check_rxIFGWait_advance_on_sfd: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxIFGWait && get_sfd && recv_enable) |=> (rxstate == rxReceiveDA)
    );

    // wait_crc_check is cleared by a valid CRC result.
    check_wait_crc_check_clear_on_valid_crc: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && crc_check_valid) |=> (wait_crc_check == 1'b0)
    );

    // wait_crc_check is cleared by an invalid CRC result.
    check_wait_crc_check_clear_on_invalid_crc: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && crc_check_invalid) |=> (wait_crc_check == 1'b0)
    );

    // wait_crc_check is cleared by a length error.
    check_wait_crc_check_clear_on_length_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && length_error) |=> (wait_crc_check == 1'b0)
    );

    // wait_crc_check holds when no CRC-related event occurs.
    check_wait_crc_check_hold_without_crc_event: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && !crc_check_valid && !crc_check_invalid && !length_error) |=> (wait_crc_check == $past(wait_crc_check))
    );

    // good_frame_get is cleared by a data error.
    check_good_frame_get_clear_on_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && (local_invalid || length_error || get_error_code)) |=> (good_frame_get == 1'b0)
    );

    // good_frame_get is cleared by a CRC error.
    check_good_frame_get_clear_on_crc_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && crc_check_invalid) |=> (good_frame_get == 1'b0)
    );

    // good_frame_get is cleared by a length error.
    check_good_frame_get_clear_on_length_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && length_error) |=> (good_frame_get == 1'b0)
    );

    // good_frame_get holds when no error occurs.
    check_good_frame_get_hold_on_no_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && !local_invalid && !length_error && !get_error_code && !crc_check_invalid) |=> (good_frame_get == $past(good_frame_get))
    );

    // bad_frame_get is asserted by a data error.
    check_bad_frame_get_set_on_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && (local_invalid || length_error || get_error_code)) |=> (bad_frame_get == 1'b1)
    );

    // bad_frame_get is asserted by a CRC error.
    check_bad_frame_get_set_on_crc_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && crc_check_invalid) |=> (bad_frame_get == 1'b1)
    );

    // bad_frame_get is asserted by a length error.
    check_bad_frame_get_set_on_length_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && length_error) |=> (bad_frame_get == 1'b1)
    );

    // bad_frame_get holds when no error occurs.
    check_bad_frame_get_hold_on_no_error: assert property (
        @(posedge rxclk) disable iff (reset) (rxstate == rxReceiveData && !local_invalid && !length_error && !get_error_code && !crc_check_invalid) |=> (bad_frame_get == $past(bad_frame_get))
    );

    // check_reset clears both frame flags.
    check_check_reset_clears_frame_flags: assert property (
        @(posedge rxclk) disable iff (reset) check_reset |=> ((good_frame_get == 1'b0) && (bad_frame_get == 1'b0))
    );

endmodule