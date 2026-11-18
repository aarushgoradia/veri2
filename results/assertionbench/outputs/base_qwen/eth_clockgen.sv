```systemverilog
module eth_clockgen_sva (
    input logic Clk,
    input logic Reset,
    input logic [7:0] Divider,
    output logic Mdc,
    output logic MdcEn,
    output logic MdcEn_n
);
    // Reset assertion: Mdc, MdcEn, MdcEn_n should be low at reset
    reset: assert property (
        @(posedge Clk) disable iff (!Reset) (Mdc == 1'b0) && (MdcEn == 1'b0) && (MdcEn_n == 1'b0)
    );

    // Mdc should toggle every other half period
    mdc_toggle: assert property (
        @(posedge Clk) disable iff (!Reset) (MdcEn |-> MdcEn_n)
    );

    // MdcEn should be asserted when Mdc is low and MdcEn_n should be asserted when Mdc is high
    mdc_en_n_toggle: assert property (
        @(posedge Clk) disable iff (!Reset) (MdcEn_n |-> Mdc) && (MdcEn |-> ~Mdc)
    );

    // Counter should count down to 0 and then reset to CounterPreset
    counter_behavior: assert property (
        @(posedge Clk) disable iff (!Reset) (Counter == 8'h0) |-> Counter == CounterPreset
    );

    // CounterPreset should be half of the Divider value
    counter_preset_value: assert property (
        @(posedge Clk) disable iff (!Reset) (Divider < 2) |-> CounterPreset == 8'h02
    );

    // CounterPreset should be half of the Divider value minus one
    counter_preset_value2: assert property (
        @(posedge Clk) disable iff (!Reset) (Divider >= 2) |-> CounterPreset == (Divider >> 1) - 1
    );

    // Mdc should be low when Counter is 0
    mdc_low_when_counter_zero: assert property (
        @(posedge Clk) disable iff (!Reset) (Counter == 8'h0) |-> Mdc == 1'b0
    );

    // Mdc should be high when Counter is not 0
    mdc_high_when_counter_not_zero: assert property (
        @(posedge Clk) disable iff (!Reset) (Counter != 8'h0) |-> Mdc == 1'b1
    );

    // MdcEn should be asserted when Counter is 0 and Mdc is low
    mdc_en_when_counter_zero_and_mdc_low: assert property (
        @(posedge Clk) disable iff (!Reset) (Counter == 8'h0) && (Mdc == 1'b0) |-> MdcEn == 1'b1
    );

    // MdcEn_n should be asserted when Counter is 0 and Mdc is high
    mdc_en_n_when_counter_zero_and_mdc_high: assert property (
        @(posedge Clk) disable iff (!Reset) (Counter == 8'h0) && (Mdc == 1'b1) |-> MdcEn_n == 1'b1
    );

    // Divider should be at least 2
    divider_value: assert property (
        @(posedge Clk) disable iff (!Reset) (Divider < 2) |-> $error("Divider should be at least 2")
    );
endmodule
```