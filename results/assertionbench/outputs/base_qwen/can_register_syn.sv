```systemverilog
module can_register_syn_sva (
    input logic clk,
    input logic rst_sync,
    input logic [WIDTH-1:0] data_in,
    input logic we,
    output logic [WIDTH-1:0] data_out
);
    parameter WIDTH = 8;
    parameter RESET_VALUE = 0;

    // At reset, data_out should be driven to the reset value
    reset: assert property (
        @(posedge clk) disable iff (!rst_sync) (data_out == RESET_VALUE)
    ) else $error("data_out not reset to %0d at reset", RESET_VALUE);

    // When write enable is high, data_out should be updated to data_in
    write_enable: assert property (
        @(posedge clk) disable iff (!rst_sync) (we |-> (data_out == data_in))
    ) else $error("data_out not updated to data_in when we is high");

    // When write enable is low, data_out should remain unchanged
    write_disable: assert property (
        @(posedge clk) disable iff (!rst_sync) (!we |-> (data_out == data_out))
    ) else $error("data_out changed when we is low");

    // data_out should not change when reset is high
    reset_hold: assert property (
        @(posedge clk) disable iff (!rst_sync) (rst_sync |-> (data_out == data_out))
    ) else $error("data_out changed when reset is high");

endmodule
```