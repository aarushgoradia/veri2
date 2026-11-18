```systemverilog
module mux4to1_sva (
    input logic CLK,
    input logic RESETn,
    input logic e,
    input logic [1:0] s,
    input logic [3:1] i0,
    input logic [3:1] i1,
    input logic [3:1] i2,
    input logic [3:1] z
);
    // Mux output is zero when e is zero
    mux_output_zero: assert property (
        @(posedge CLK) disable iff (!RESETn) (!e |-> z == 4'b0000)
    );

    // Mux output is i0 when s is 00
    mux_output_i0: assert property (
        @(posedge CLK) disable iff (!RESETn) (s == 2'b00 |-> z == i0)
    );

    // Mux output is i1 when s is 01
    mux_output_i1: assert property (
        @(posedge CLK) disable iff (!RESETn) (s == 2'b01 |-> z == i1)
    );

    // Mux output is i2 when s is 10
    mux_output_i2: assert property (
        @(posedge CLK) disable iff (!RESETn) (s == 2'b10 |-> z == i2)
    );

    // Mux output is i3 when s is 11
    mux_output_i3: assert property (
        @(posedge CLK) disable iff (!RESETn) (s == 2'b11 |-> z == i3)
    );

    // Mux output is zero when reset is active
    mux_output_reset: assert property (
        @(posedge CLK) disable iff (RESETn) (z == 4'b0000)
    );
endmodule
```