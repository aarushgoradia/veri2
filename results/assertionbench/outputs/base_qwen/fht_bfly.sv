```systemverilog
module fht_bfly_sva (
    input logic rstn,
    input logic clk,
    input logic valid,
    input logic [7:0] a,
    input logic [7:0] b,
    output logic [8:0] c,
    output logic [8:0] d
);
    // Sequential logic for a and b
    reg [7:0] a_reg;
    reg [7:0] b_reg;
    always @(posedge clk) disable iff (!rstn) begin
        a_reg <= 8'b0;
        b_reg <= 8'b0;
    end
    always @(posedge clk) disable iff (!rstn) begin
        if (valid) begin
            a_reg <= a;
            b_reg <= b;
        end
    end

    // Assertions for valid signal
    valid_high: assert property (
        @(posedge clk) disable iff (!rstn) valid |-> (a_reg != 8'b0) && (b_reg != 8'b0)
    ) else $error("Valid signal is high but inputs are zero");

    valid_low: assert property (
        @(posedge clk) disable iff (!rstn) !valid |-> (a_reg == 8'b0) && (b_reg == 8'b0)
    ) else $error("Valid signal is low but inputs are non-zero");

    // Assertions for output c
    c_value: assert property (
        @(posedge clk) disable iff (!rstn) valid |-> (c == rca_N(a_reg, b_reg))
    ) else $error("Output c does not match expected value");

    // Assertions for output d
    d_value: assert property (
        @(posedge clk) disable iff (!rstn) valid |-> (d == rca_N(a_reg, twos_complement(b_reg)))
    ) else $error("Output d does not match expected value");

    // Function definitions for completeness
    function [1:0] full_adder;
        input a, b, ci;
        reg co, s;
        begin
            s  = (a ^ b ^ ci);
            co = (a & b) | (ci & (a ^ b));
            full_adder = {co,s};
        end
    endfunction

    function [1:0] half_adder;
        input a, b;
        reg co, s;
        begin
            s  = (a ^ b);
            co = (a & b);
            half_adder = {co,s};
        end
    endfunction

    function [8:0] rca_N;
        input [7:0] a;
        input [7:0] b;
        reg [7:0] co, sum;
        begin
            integer i;
            for (i = 0; i < 8; i = i + 1) begin
                if (i == 0)
                    {co[i], sum[i]} = half_adder(a[i], b[i]);
                else
                    {co[i], sum[i]} = full_adder(a[i], b[i], co[i-1]);
            end
            rca_N[8:0] = {co[7], sum};
        end
    endfunction

    function [7:0] twos_complement;
        input [7:0] a;
        reg [7:0] ainv;
        reg [8:0] plus1;
        begin
            ainv = ~a;
            plus1 = rca_N(ainv, {8'b0, 1'b1});
            twos_complement = plus1[7:0];
        end
    endfunction
endmodule
```