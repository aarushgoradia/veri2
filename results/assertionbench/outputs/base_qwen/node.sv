```systemverilog
module node_sva (
    input logic CLK,
    input logic RESETn,
    input logic [DATA_WIDTH-1:0] data_a,
    input logic [DATA_WIDTH-1:0] data_b,
    output logic [DATA_WIDTH-1:0] data_hi,
    output logic [DATA_WIDTH-1:0] data_lo
);
    parameter DATA_WIDTH = 8;
    parameter LOW_MUX = 1;
    parameter HI_MUX = 1;

    ///// Comparator logic /////
    // Comparator should select the lower value for data_lo and the higher value for data_hi.
    comparator_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (data_a < data_b) |-> (data_lo == data_a && data_hi == data_b)
    ) else $error("Comparator did not select the correct lower and higher values.");

    // If data_a is not less than data_b, the comparator should select the higher value for data_lo and the lower value for data_hi.
    comparator_check_2: assert property (
        @(posedge CLK) disable iff (!RESETn) !(data_a < data_b) |-> (data_lo == data_b && data_hi == data_a)
    ) else $error("Comparator did not select the correct lower and higher values.");

    ///// Mux logic /////
    // If LOW_MUX is disabled, data_lo should be zero.
    mux_lo_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (LOW_MUX == 1'b0) |-> (data_lo == {DATA_WIDTH{1'b0}})
    ) else $error("LOW_MUX disabled but data_lo is not zero.");

    // If HI_MUX is disabled, data_hi should be zero.
    mux_hi_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (HI_MUX == 1'b0) |-> (data_hi == {DATA_WIDTH{1'b0}})
    ) else $error("HI_MUX disabled but data_hi is not zero.");

    // If both LOW_MUX and HI_MUX are disabled, both data_lo and data_hi should be zero.
    mux_both_disabled_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (LOW_MUX == 1'b0) && (HI_MUX == 1'b0) |-> (data_lo == {DATA_WIDTH{1'b0}} && data_hi == {DATA_WIDTH{1'b0}})
    ) else $error("Both LOW_MUX and HI_MUX disabled but data_lo and data_hi are not zero.");

    // If both LOW_MUX and HI_MUX are enabled, data_lo should be the lower value and data_hi should be the higher value.
    mux_both_enabled_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (LOW_MUX == 1'b1) && (HI_MUX == 1'b1) |-> (data_lo == data_a && data_hi == data_b) || (data_lo == data_b && data_hi == data_a)
    ) else $error("Both LOW_MUX and HI_MUX enabled but data_lo and data_hi are not correctly selected.");

    ///// Device reset /////
    // At reset assertion, both data_lo and data_hi should be zero.
    reset_check: assert property (
        @(posedge CLK) !RESETn |-> (data_lo == {DATA_WIDTH{1'b0}} && data_hi == {DATA_WIDTH{1'b0}})
    ) else $error("At reset, data_lo and data_hi are not zero.");
endmodule
```