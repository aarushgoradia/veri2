module qtwosComp_sva (
    input logic        clk,
    input logic [30:0] a,
    input logic [63:0] b
);

// b must equal the 64-bit two's complement of a.
    check_twos_complement: assert property (
        @(posedge clk) b == {34'b0, ~a + 31'b1}
    );

// The low 31 bits of b must equal the bitwise inversion of a.
    check_low31_inversion: assert property (
        @(posedge clk) b[30:0] == ~a
    );

// The MSB of b must be 0 (zero-extended from the 31-bit result).
    check_msb_zero: assert property (
        @(posedge clk) b[63] == 1'b0
    );

// The low 31 bits of b must sum with a to zero modulo 31 bits.
    check_low31_sum_zero: assert property (
        @(posedge clk) (b[30:0] + a) == 31'b0
    );

// The full 64-bit b must sum with a to zero modulo 64 bits.
    check_full64_sum_zero: assert property (
        @(posedge clk) (b + {34'b0, a}) == 64'b0
    );

// Zero input must produce zero output.
    check_zero_input: assert property (
        @(posedge clk) (a == 31'b0) |-> (b == 64'b0)
    );

// The maximum 31-bit input must produce the minimum 32-bit two's complement value.
    check_max_input: assert property (
        @(posedge clk) (a == 31'h7FFFFFFF) |-> (b == 64'h8000000000000000)
    );

// The minimum 31-bit input must produce the maximum 32-bit two's complement value.
    check_min_input: assert property (
        @(posedge clk) (a == 31'h80000000) |-> (b == 64'h7FFFFFFF)
    );

endmodule
