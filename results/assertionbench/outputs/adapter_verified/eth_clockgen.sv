module eth_clockgen_sva (
    input logic       Clk,
    input logic       Reset,
    input logic [7:0] Divider,
    input logic       Mdc,
    input logic       MdcEn,
    input logic       MdcEn_n
);

// Reset drives Mdc low.
    check_reset_mdc_low: assert property (
        @(posedge Clk) Reset |-> (Mdc == 1'b0)
    );

// Reset drives MdcEn low.
    check_reset_mdcen_low: assert property (
        @(posedge Clk) Reset |-> (MdcEn == 1'b0)
    );

// Reset drives MdcEn_n low.
    check_reset_mdcen_n_low: assert property (
        @(posedge Clk) Reset |-> (MdcEn_n == 1'b0)
    );

// MdcEn and MdcEn_n are never asserted together.
    check_mdcen_mdcen_n_mutex: assert property (
        @(posedge Clk) disable iff (Reset) !(MdcEn && MdcEn_n)
    );

// MdcEn is asserted exactly when Mdc is low and the counter is at zero.
    check_mdcen_definition: assert property (
        @(posedge Clk) disable iff (Reset)
            (MdcEn == (Mdc == 1'b0) && (Counter == 8'h00))
    );

// MdcEn_n is asserted exactly when Mdc is high and the counter is at zero.
    check_mdcen_n_definition: assert property (
        @(posedge Clk) disable iff (Reset)
            (MdcEn_n == (Mdc == 1'b1) && (Counter == 8'h00))
    );

// Mdc toggles every time the counter reaches zero.
    check_mdc_toggle_on_zero: assert property (
        @(posedge Clk) disable iff (Reset)
            (Counter == 8'h00) |=> (Mdc == ~$past(Mdc))
    );

// Mdc is low when the counter is not at zero.
    check_mdc_low_when_counter_nonzero: assert property (
        @(posedge Clk) disable iff (Reset)
            (Counter != 8'h00) |-> (Mdc == 1'b0)
    );

// Mdc is high when the counter is at zero.
    check_mdc_high_when_counter_zero: assert property (
        @(posedge Clk) disable iff (Reset)
            (Counter == 8'h00) |-> (Mdc == 1'b1)
    );

endmodule
