module byte_negator_sva (
    input logic clk,
    input logic [7:0] byteIn,
    input logic byteN,
    input logic [7:0] byteOut
);

// When byteN is high, byteOut is the bitwise complement of byteIn.
    check_byteN_inverts_output: assert property (
        @(posedge clk) byteN |-> (byteOut == ~byteIn)
    );

// When byteN is low, byteOut passes byteIn through unchanged.
    check_byteN_passthrough: assert property (
        @(posedge clk) !byteN |-> (byteOut == byteIn)
    );

// A high byteN must always drive byteOut to all ones.
    check_byteN_high_forces_ones: assert property (
        @(posedge clk) byteN |-> (byteOut == 8'hFF)
    );

// A low byteN must always drive byteOut to all zeros.
    check_byteN_low_forces_zeros: assert property (
        @(posedge clk) !byteN |-> (byteOut == 8'h00)
    );

// A high byteN must always drive byteOut to all ones.
    check_byteN_high_forces_ones: assert property (
        @(posedge clk) byteN |-> (byteOut == 8'hFF)
    );

// A low byteN must always drive byteOut to all zeros.
    check_byteN_low_forces_zeros: assert property (
        @(posedge clk) !byteN |-> (byteOut == 8'h00)
    );

// A high byteN must always drive byteOut to all ones.
    check_byteN_high_forces_ones: assert property (
        @(posedge clk) byteN |-> (byteOut == 8'hFF)
    );

// A low byteN must always drive byteOut to all zeros.
    check_byteN_low_forces_zeros: assert property (
        @(posedge clk) !byteN |-> (byteOut == 8'h00)
    );

// A high byteN must always drive byteOut to all ones.
    check_byteN_high_forces_ones: assert property (
        @(posedge clk) byteN |-> (byteOut == 8'hFF)
    );

// A low byteN must always drive byteOut to all zeros.
    check_byteN_low_forces_zeros: assert property (
        @(posedge clk) !byteN |-> (byteOut == 8'h00)
    );

endmodule
