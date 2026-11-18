```systemverilog
module ppReg1_sva (
    input logic clk,
    input logic rst_n,
    input logic [`instOpCodeLen-1:0] opcodeIn,
    input logic [`instFieldLen-1:0] fieldIn,
    output logic [`instOpCodeLen-1:0] opcodeOut,
    output logic [`instFieldLen-1:0] fieldOut
);
    // Register should hold the last written values after reset
    reset: assert property (
        @(posedge clk) disable iff (!rst_n) (opcodeOut == opcodeIn) && (fieldOut == fieldIn)
    );

    // Register should not change if reset is active
    reset_active: assert property (
        @(posedge clk) disable iff (rst_n) (opcodeOut == opcodeOut) && (fieldOut == fieldOut)
    );

    // Register should update on every positive edge of the clock
    update: assert property (
        @(posedge clk) disable iff (!rst_n) (opcodeOut == opcodeIn) && (fieldOut == fieldIn)
    );

endmodule
```