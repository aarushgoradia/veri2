```systemverilog
module can_crc_sva (
    input logic clk,
    input logic data,
    input logic enable,
    input logic initialize,
    output logic [14:0] crc
);
    // CRC calculation logic must be enabled to update the CRC value.
    crc_update: assert property (
        @(posedge clk) disable iff (!initialize) (enable |-> crc_next == crc_tmp)
    );

    // CRC must be reset to 0 when initialize is asserted.
    crc_reset: assert property (
        @(posedge clk) disable iff (!initialize) (initialize |-> crc == 15'h0)
    );

    // CRC calculation logic must be disabled when initialize is asserted.
    crc_disable: assert property (
        @(posedge clk) disable iff (!initialize) (initialize |-> !enable)
    );

    // CRC calculation logic must be enabled when enable is asserted.
    crc_enable: assert property (
        @(posedge clk) disable iff (!initialize) (enable |-> !initialize)
    );

    // CRC calculation logic must be updated only when enable is asserted.
    crc_update_enable: assert property (
        @(posedge clk) disable iff (!initialize) (enable |-> crc_next == crc_tmp)
    );

    // CRC calculation logic must not be updated when enable is not asserted.
    crc_no_update_disable: assert property (
        @(posedge clk) disable iff (!initialize) (!enable |-> crc == crc)
    );

    // CRC calculation logic must be updated only when data changes.
    crc_update_data: assert property (
        @(posedge clk) disable iff (!initialize) (data |-> crc_next == crc_tmp)
    );

    // CRC calculation logic must not be updated when data does not change.
    crc_no_update_data: assert property (
        @(posedge clk) disable iff (!initialize) (!data |-> crc == crc)
    );

    // CRC calculation logic must be updated only when initialize is not asserted.
    crc_update_initialize: assert property (
        @(posedge clk) disable iff (!initialize) (!initialize |-> crc_next == crc_tmp)
    );

    // CRC calculation logic must not be updated when initialize is asserted.
    crc_no_update_initialize: assert property (
        @(posedge clk) disable iff (!initialize) (initialize |-> crc == crc)
    );
endmodule
```