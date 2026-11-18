module node_sva #(
    parameter DATA_WIDTH = 8,
    parameter LOW_MUX = 1,
    parameter HI_MUX = 1
)(
    input logic [DATA_WIDTH-1:0] data_a,
    input logic [DATA_WIDTH-1:0] data_b,
    input logic [DATA_WIDTH-1:0] data_hi,
    input logic [DATA_WIDTH-1:0] data_lo
);

    // No RTL clock or reset; sample combinational behavior on the global clock.

    // When data_a is less than data_b, the comparator selects data_a as low and data_b as high.
    check_select_a_when_a_lt_b: assert property (
        @($global_clock)
        (data_a < data_b) |-> ((data_lo == data_a) && (data_hi == data_b))
    );

    // When data_a is greater than or equal to data_b, the comparator selects data_b as low and data_a as high.
    check_select_b_when_a_ge_b: assert property (
        @($global_clock)
        (data_a >= data_b) |-> ((data_lo == data_b) && (data_hi == data_a))
    );

    // When data_a equals data_b, both outputs reflect the same value.
    check_equal_inputs_same_outputs: assert property (
        @($global_clock)
        (data_a == data_b) |-> ((data_lo == data_a) && (data_hi == data_a))
    );

    // With both muxes enabled, the outputs are the exact comparator result.
    generate
        if (LOW_MUX && HI_MUX) begin : gen_full_mux
            check_full_mux_behavior: assert property (
                @($global_clock)
                1'b1 |-> ((data_lo == (data_a < data_b ? data_a : data_b)) &&
                          (data_hi == (data_a < data_b ? data_b : data_a)))
            );
        end
    endgenerate

    // With only the low mux enabled, the low output is the comparator result and the high output is zero.
    generate
        if (LOW_MUX && !HI_MUX) begin : gen_low_mux_only
            check_low_mux_only_behavior: assert property (
                @($global_clock)
                1'b1 |-> ((data_lo == (data_a < data_b ? data_a : data_b)) &&
                          (data_hi == {DATA_WIDTH{1'b0}}))
            );
        end
    endgenerate

    // With only the high mux enabled, the high output is the comparator result and the low output is zero.
    generate
        if (!LOW_MUX && HI_MUX) begin : gen_hi_mux_only
            check_hi_mux_only_behavior: assert property (
                @($global_clock)
                1'b1 |-> ((data_hi == (data_a < data_b ? data_b : data_a)) &&
                          (data_lo == {DATA_WIDTH{1'b0}}))
            );
        end
    endgenerate

    // With both muxes disabled, both outputs are zero.
    generate
        if (!LOW_MUX && !HI_MUX) begin : gen_disabled_muxes
            check_disabled_muxes_behavior: assert property (
                @($global_clock)
                1'b1 |-> ((data_lo == {DATA_WIDTH{1'b0}}) &&
                          (data_hi == {DATA_WIDTH{1'b0}}))
            );
        end
    endgenerate

endmodule