module eth_l3_checksum_sva (
    input logic        MRxClk,
    input logic        Reset,
    input logic [7:0]  RxData,
    input logic [15:0] ByteCnt,
    input logic [15:0] CheckSum,
    input logic        CSready,
    input logic [1:0]  StartCalc,
    input logic        Divided_2_clk,
    input logic        Divided_4_clk,
    input logic [7:0]  prev_latched_Rx,
    input logic [7:0]  prev_latched_Rx1,
    input logic [31:0] Sum
);

    // Reset clears the checksum and ready output.
    check_reset_clears_outputs: assert property (
        @(posedge MRxClk)
        Reset |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte counts below 23 do not update the checksum or ready.
    check_idle_below_23: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt < 16'h17) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 23 clears the checksum and ready.
    check_clear_at_23: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h17) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 24 clears the checksum and ready.
    check_clear_at_24: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h18) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 25 clears the checksum and ready.
    check_clear_at_25: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h19) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 26 clears the checksum and ready.
    check_clear_at_26: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h1A) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 27 clears the checksum and ready.
    check_clear_at_27: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h1B) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 28 clears the checksum and ready.
    check_clear_at_28: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h1C) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 29 clears the checksum and ready.
    check_clear_at_29: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h1D) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 30 clears the checksum and ready.
    check_clear_at_30: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h1E) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 31 clears the checksum and ready.
    check_clear_at_31: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h1F) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 32 clears the checksum and ready.
    check_clear_at_32: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h20) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 33 clears the checksum and ready.
    check_clear_at_33: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h21) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 34 clears the checksum and ready.
    check_clear_at_34: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h22) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 35 clears the checksum and ready.
    check_clear_at_35: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h23) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 36 clears the checksum and ready.
    check_clear_at_36: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h24) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 37 clears the checksum and ready.
    check_clear_at_37: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h25) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 38 clears the checksum and ready.
    check_clear_at_38: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h26) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 39 clears the checksum and ready.
    check_clear_at_39: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h27) |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 40 sets ready and computes the checksum.
    check_ready_and_checksum_at_40: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h28) |=> (CSready == 1'b1) &&
                                (CheckSum == ~({Sum[15:0], Sum[31:16]}))
    );

    // Byte count 41 does not update the checksum or ready.
    check_idle_at_41: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h29) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 42 does not update the checksum or ready.
    check_idle_at_42: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h2A) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 43 does not update the checksum or ready.
    check_idle_at_43: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h2B) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 44 does not update the checksum or ready.
    check_idle_at_44: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h2C) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 45 does not update the checksum or ready.
    check_idle_at_45: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h2D) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 46 does not update the checksum or ready.
    check_idle_at_46: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h2E) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 47 does not update the checksum or ready.
    check_idle_at_47: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h2F) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 48 does not update the checksum or ready.
    check_idle_at_48: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h30) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 49 does not update the checksum or ready.
    check_idle_at_49: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h31) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 50 does not update the checksum or ready.
    check_idle_at_50: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h32) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 51 does not update the checksum or ready.
    check_idle_at_51: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h33) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 52 does not update the checksum or ready.
    check_idle_at_52: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h34) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 53 does not update the checksum or ready.
    check_idle_at_53: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h35) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 54 does not update the checksum or ready.
    check_idle_at_54: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h36) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 55 does not update the checksum or ready.
    check_idle_at_55: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h37) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 56 does not update the checksum or ready.
    check_idle_at_56: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h38) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 57 does not update the checksum or ready.
    check_idle_at_57: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h39) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 58 does not update the checksum or ready.
    check_idle_at_58: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h3A) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 59 does not update the checksum or ready.
    check_idle_at_59: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h3B) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 60 does not update the checksum or ready.
    check_idle_at_60: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h3C) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 61 does not update the checksum or ready.
    check_idle_at_61: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h3D) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 62 does not update the checksum or ready.
    check_idle_at_62: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h3E) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 63 does not update the checksum or ready.
    check_idle_at_63: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h3F) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 64 does not update the checksum or ready.
    check_idle_at_64: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h40) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 65 does not update the checksum or ready.
    check_idle_at_65: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h41) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 66 does not update the checksum or ready.
    check_idle_at_66: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h42) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 67 does not update the checksum or ready.
    check_idle_at_67: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h43) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 68 does not update the checksum or ready.
    check_idle_at_68: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h44) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 69 does not update the checksum or ready.
    check_idle_at_69: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h45) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 70 does not update the checksum or ready.
    check_idle_at_70: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h46) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 71 does not update the checksum or ready.
    check_idle_at_71: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h47) |=> (CheckSum == $past(CheckSum)) && (CSready == $past(CSready))
    );

    // Byte count 72 does not update the checksum or ready.
    check_idle_at_72: assert property (
        @(posedge MRxCl