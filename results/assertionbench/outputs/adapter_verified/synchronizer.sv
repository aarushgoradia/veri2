module synchronizer_sva (
    input logic clk,
    input logic rst_n,
    input logic [2:0] d_in,
    input logic [2:0] d_out
);

// d_out is zero whenever reset is asserted.
    check_reset_clears_dout: assert property (
        @(posedge clk) !rst_n |-> (d_out == 3'b000)
    );

// d_out equals d_in from the previous clock sample.
    check_dout_follows_din: assert property (
        @(posedge clk) disable iff (!rst_n) 1'b1 |=> (d_out == $past(d_in))
    );

// A high d_in is captured on the next clock.
    check_capture_high: assert property (
        @(posedge clk) disable iff (!rst_n) d_in[2] |=> (d_out[2] == 1'b1)
    );

// A low d_in is captured on the next clock.
    check_capture_low: assert property (
        @(posedge clk) disable iff (!rst_n) !d_in[2] |=> (d_out[2] == 1'b0)
    );

// A high d_in is captured on the next clock.
    check_capture_high: assert property (
        @(posedge clk) disable iff (!rst_n) d_in[1] |=> (d_out[1] == 1'b1)
    );

// A low d_in is captured on the next clock.
    check_capture_low: assert property (
        @(posedge clk) disable iff (!rst_n) !d_in[1] |=> (d_out[1] == 1'b0)
    );

// A high d_in is captured on the next clock.
    check_capture_high: assert property (
        @(posedge clk) disable iff (!rst_n) d_in[0] |=> (d_out[0] == 1'b1)
    );

// A low d_in is captured on the next clock.
    check_capture_low: assert property (
        @(posedge clk) disable iff (!rst_n) !d_in[0] |=> (d_out[0] == 1'b0)
    );

endmodule
