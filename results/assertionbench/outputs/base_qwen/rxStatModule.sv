```systemverilog
module rxStatModule_assertions(
    input logic rxclk,
    input logic reset,
    input logic good_frame_get, 
    input logic crc_check_invalid,
    input logic large_error,
    input logic small_error,
    input logic receiving,
    input logic padded_frame,
    input logic pause_frame,
    input logic broad_valid,
    input logic multi_valid,
    input logic length_65_127,
    input logic length_128_255,
    input logic length_256_511,
    input logic length_512_1023,
    input logic length_1024_max,
    input logic jumbo_frame,
    input logic get_error_code,
    output logic [17:0] rxStatRegPlus
);
    // Count for Frames Received OK
    count_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) good_frame_get |-> rxStatRegPlus[0] == 1'b1
    );

    // Count for FCS check error
    count_fcs_check_error: assert property (
        @(posedge rxclk) disable iff (!reset) crc_check_invalid |-> rxStatRegPlus[1] == 1'b1
    );

    // Count for BroadCast Frame Received OK
    count_broadcast_frame_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (broad_valid && good_frame_get) |-> rxStatRegPlus[2] == 1'b1
    );

    // Count for Multicast Frame Received OK
    count_multicast_frame_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (multi_valid && good_frame_get) |-> rxStatRegPlus[3] == 1'b1
    );

    // Count for 64 byte Frame Received OK
    count_64_byte_frame_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (padded_frame && good_frame_get) |-> rxStatRegPlus[4] == 1'b1
    );

    // Count for 65-127 byte Frames Received OK
    count_65_127_byte_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (length_65_127 && good_frame_get) |-> rxStatRegPlus[5] == 1'b1
    );

    // Count for 128-255 byte Frames Received OK
    count_128_255_byte_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (length_128_255 && good_frame_get) |-> rxStatRegPlus[6] == 1'b1
    );

    // Count for 256-511 byte Frames Received OK
    count_256_511_byte_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (length_256_511 && good_frame_get) |-> rxStatRegPlus[7] == 1'b1
    );

    // Count for 512-1023 byte Frames Received OK
    count_512_1023_byte_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (length_512_1023 && good_frame_get) |-> rxStatRegPlus[8] == 1'b1
    );

    // Count for 1024-1518 byte Frames Received OK
    count_1024_1518_byte_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (length_1024_max && good_frame_get) |-> rxStatRegPlus[9] == 1'b1
    );

    // Count for Control Frames Received OK
    count_control_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (pause_frame && good_frame_get) |-> rxStatRegPlus[10] == 1'b1
    );

    // Count for Length/Type Out of Range
    count_length_type_out_of_range: assert property (
        @(posedge rxclk) disable iff (!reset) large_error |-> rxStatRegPlus[11] == 1'b1
    );

    // Count for Oversize Frames Received OK
    count_oversize_frames_received_ok: assert property (
        @(posedge rxclk) disable iff (!reset) (jumbo_frame && good_frame_get) |-> rxStatRegPlus[14] == 1'b1
    );

    // Count for Undersized Frames Received
    count_undersized_frames_received: assert property (
        @(posedge rxclk) disable iff (!reset) small_error |-> rxStatRegPlus[15] == 1'b1
    );

    // Count for Fragment Frames Received
    count_fragment_frames_received: assert property (
        @(posedge rxclk) disable iff (!reset) (receiving && get_error_code) |-> rxStatRegPlus[16] == 1'b1
    );

    // Count for Number of Bytes Received
    count_number_of_bytes_received: assert property (
        @(posedge rxclk) disable iff (!reset) receiving |-> rxStatRegPlus[17] == 1'b1
    );

endmodule
```