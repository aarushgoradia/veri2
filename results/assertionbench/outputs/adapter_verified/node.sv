module node_sva (
    input logic CLK,
    input logic [7:0] data_a,
    input logic [7:0] data_b,
    input logic [7:0] data_lo,
    input logic [7:0] data_hi
);

// data_lo is the lower of the two inputs when HI_MUX is enabled.
    check_data_lo_selects_lower: assert property (
        @(posedge CLK) HI_MUX |-> (data_lo == ((data_a < data_b) ? data_a : data_b))
    );

// data_hi is the higher of the two inputs when LOW_MUX is enabled.
    check_data_hi_selects_higher: assert property (
        @(posedge CLK) LOW_MUX |-> (data_hi == ((data_a > data_b) ? data_a : data_b))
    );

// When both muxes are enabled, data_lo and data_hi are the two inputs.
    check_full_muxes_pass_through_inputs: assert property (
        @(posedge CLK) (LOW_MUX && HI_MUX) |-> ((data_lo == data_a) && (data_hi == data_b))
    );

// When HI_MUX is disabled, data_hi is zero.
    check_data_hi_zero_when_disabled: assert property (
        @(posedge CLK) !HI_MUX |-> (data_hi == 8'h00)
    );

// When LOW_MUX is disabled, data_lo is zero.
    check_data_lo_zero_when_disabled: assert property (
        @(posedge CLK) !LOW_MUX |-> (data_lo == 8'h00)
    );

// When both muxes are disabled, both outputs are zero.
    check_outputs_zero_when_disabled: assert property (
        @(posedge CLK) (!LOW_MUX && !HI_MUX) |-> ((data_lo == 8'h00) && (data_hi == 8'h00))
    );

// When both inputs are equal, both outputs match that value.
    check_equal_inputs_passthrough: assert property (
        @(posedge CLK) (data_a == data_b) |-> ((data_lo == data_a) && (data_hi == data_a))
    );

endmodule
