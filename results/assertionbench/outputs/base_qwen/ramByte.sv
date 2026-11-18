```systemverilog
module manual (
    input logic CLK,
    input logic RESETn,
    input logic byteRamEn,
    input logic byteRamRw,
    input logic [`byteRamLen-1:0] byteRamIn,
    input logic [`byteRamAddrLen-1:0] byteRamAddr,
    output logic [`byteRamLen-1:0] byteRamOut
);
    ///// Byte RAM behavior /////
    // Byte RAM output should be high impedance when byteRamEn is LOW.
    byte_ram_enable_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteRamEn == 1'b0) |-> (byteRamOut == `byteRamLen'bz)
    );
    // Byte RAM output should match the read data when byteRamEn is HIGH and byteRamRw is HIGH.
    byte_ram_read_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteRamEn == 1'b1) && (byteRamRw == 1'b1) |-> (byteRamOut == byteRam[byteRamAddr])
    );
    // Byte RAM should update the memory location when byteRamEn is HIGH and byteRamRw is LOW.
    byte_ram_write_check: assert property (
        @(posedge CLK) disable iff (!RESETn) (byteRamEn == 1'b1) && (byteRamRw == 1'b0) |-> (byteRam[byteRamAddr] == byteRamIn)
    );
    // Byte RAM output should be zero when reset is asserted.
    byte_ram_reset_check: assert property (
        @(posedge CLK) !RESETn |-> (byteRamOut == `byteRamLen'b0)
    );
endmodule
```