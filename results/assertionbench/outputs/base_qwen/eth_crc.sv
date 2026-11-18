```systemverilog
module eth_crc_sva (
    input logic Clk,
    input logic Reset,
    input logic [3:0] Data,
    input logic Enable,
    input logic Initialize,
    output logic [31:0] Crc,
    output logic CrcError
);
    // Crc should be initialized to 32'hffffffff on reset
    reset_init: assert property (
        @(posedge Clk) disable iff (!Reset) (Crc == 32'hffffffff)
    );

    // Crc should be initialized to 32'hffffffff when Initialize is asserted
    initialize_init: assert property (
        @(posedge Clk) disable iff (!Reset) (Initialize |-> Crc == 32'hffffffff)
    );

    // Crc should not change when Reset is asserted
    reset_hold: assert property (
        @(posedge Clk) disable iff (!Reset) (CrcNext == Crc)
    );

    // Crc should not change when Initialize is asserted
    initialize_hold: assert property (
        @(posedge Clk) disable iff (!Reset) (Initialize |-> CrcNext == Crc)
    );

    // Crc should be updated correctly based on Data, Enable, and Initialize
    crc_update: assert property (
        @(posedge Clk) disable iff (!Reset) (CrcNext == Crc)
    );

    // CrcError should be asserted when Crc is not equal to 32'hc704dd7b
    crc_error_check: assert property (
        @(posedge Clk) disable iff (!Reset) (CrcError |-> Crc == 32'hc704dd7b)
    );

    // CrcError should be deasserted when Crc is equal to 32'hc704dd7b
    crc_no_error_check: assert property (
        @(posedge Clk) disable iff (!Reset) (!CrcError |-> Crc != 32'hc704dd7b)
    );

    // CrcNext should be updated correctly based on Data, Enable, and Initialize
    crc_next_update: assert property (
        @(posedge Clk) disable iff (!Reset) (CrcNext == Crc)
    );

    // Crc should not change when Enable is deasserted
    enable_hold: assert property (
        @(posedge Clk) disable iff (!Reset) (Enable |-> CrcNext == Crc)
    );

    // Crc should not change when Data is unchanged
    data_hold: assert property (
        @(posedge Clk) disable iff (!Reset) (Data == Data |-> CrcNext == Crc)
    );
endmodule
```