module eth_clockgen_sva #(
    parameter int Tp = 1
) (
    input logic       Clk,
    input logic       Reset,
    input logic [7:0] Divider,
    input logic       Mdc,
    input logic       MdcEn,
    input logic       MdcEn_n,
    input logic       Mdc,
    input logic [7:0] Counter
);

    // Reset drives the counter to 1 and Mdc low.
    check_reset_state: assert property (
        @(posedge Clk)
        Reset |-> ((Counter == 8'h01) && (Mdc == 1'b0))
    );

    // Counter is either 1 or the previous value minus one.
    check_counter_update: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ((Counter == 8'h01) || (Counter == ($past(Counter) - 8'h01)))
    );

    // Counter wraps from 1 back to 1.
    check_counter_wrap: assert property (
        @(posedge Clk) disable iff (Reset)
        (Counter == 8'h01) |=> (Counter == 8'h01)
    );

    // Mdc is either 0 or the previous value inverted.
    check_mdc_update: assert property (
        @(posedge Clk) disable iff (Reset)
        1'b1 |=> ((Mdc == 1'b0) || (Mdc == ~$past(Mdc)))
    );

    // MdcEn is asserted exactly when the counter is 1 and Mdc is 0.
    check_mdcen_definition: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn == ((Counter == 8'h01) && (Mdc == 1'b0)))
    );

    // MdcEn_n is asserted exactly when the counter is 1 and Mdc is 1.
    check_mdcen_n_definition: assert property (
        @(posedge Clk) disable iff (Reset)
        (MdcEn_n == ((Counter == 8'h01) && (Mdc == 1'b1)))
    );

    // MdcEn and MdcEn_n are never asserted together.
    check_mdcen_mdcen_n_mutex: assert property (
        @(posedge Clk) disable iff (Reset)
        !(MdcEn && MdcEn_n)
    );

    // MdcEn_n is a single-cycle pulse.
    check_mdcen_n_single_cycle: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn_n |=> !MdcEn_n
    );

    // MdcEn is a single-cycle pulse.
    check_mdcen_single_cycle: assert property (
        @(posedge Clk) disable iff (Reset)
        MdcEn |=> !MdcEn
    );

    // Mdc toggles only when the counter is 1.
    check_mdc_toggle_only_on_count_eq0: assert property (
        @(posedge Clk) disable iff (Reset)
        $changed(Mdc) |-> (Counter == 8'h01)
    );

endmodule