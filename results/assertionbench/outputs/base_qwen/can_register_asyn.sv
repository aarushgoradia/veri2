```systemverilog
module can_register_asyn_sva (
    input logic clk,
    input logic rst,
    input logic [WIDTH-1:0] data_in,
    input logic we,
    output logic [WIDTH-1:0] data_out
);
    parameter WIDTH = 8;
    parameter RESET_VALUE = 0;

    // Asynchronous reset behavior
    reset_behavior: assert property (
        @(posedge clk) disable iff (!rst) rst |-> (data_out == RESET_VALUE)
    ) else $error("Asynchronous reset did not drive data_out to RESET_VALUE");

    // Write operation behavior
    write_behavior: assert property (
        @(posedge clk) disable iff (!rst) we |-> (data_out == data_in)
    ) else $error("Write operation did not update data_out");

    // Data_out should not change when not writing
    no_write_behavior: assert property (
        @(posedge clk) disable iff (!rst) !we |-> ##1 data_out == data_out
    ) else $error("data_out changed during a non-write cycle");

endmodule
```