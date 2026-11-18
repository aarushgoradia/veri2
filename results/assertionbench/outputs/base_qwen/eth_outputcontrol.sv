```systemverilog
module eth_outputcontrol_sva (
    input logic Clk,
    input logic Reset,
    input logic WriteOp,
    input logic NoPre,
    input logic InProgress,
    input logic ShiftedBit,
    input logic [6:0] BitCounter,
    input logic MdcEn_n,
    output logic Mdo,
    output logic MdoEn
);
    // Generation of the Serial Enable signal (enables the serialization of the data)
    // SerialEn is generated based on WriteOp, InProgress, BitCounter, and NoPre.
    // It is asserted when a write operation is in progress and the bit counter is greater than 31,
    // or when no write operation is in progress and the bit counter is greater than 31 and less than 46.
    // It is also asserted when no write operation is in progress and the bit counter is 0 and NoPre is asserted.
    serial_enable: assert property (
        @(posedge Clk) disable iff (!Reset) 
        (SerialEn == (WriteOp & InProgress & (BitCounter > 31 | ((BitCounter == 0) & NoPre))) | 
         ~WriteOp & InProgress & ((BitCounter > 31 & BitCounter < 46) | ((BitCounter == 0) & NoPre)))
    );

    // Generation of the MdoEn signal
    // MdoEn is generated based on MdcEn_n, SerialEn, and InProgress.
    // It is asserted when MdcEn_n is asserted and SerialEn or InProgress and BitCounter is less than 32.
    mdoen_generation: assert property (
        @(posedge Clk) disable iff (!Reset) 
        (MdoEn == (MdcEn_n & (SerialEn | (InProgress & (BitCounter < 32)))))
    );

    // Generation of the Mdo signal
    // Mdo is generated based on MdcEn_n, SerialEn, ShiftedBit, and BitCounter.
    // It is asserted when MdcEn_n is asserted and ~SerialEn and BitCounter is less than 32.
    // It is also asserted when MdcEn_n is asserted and ShiftedBit or ~SerialEn and BitCounter is less than 32.
    mdo_generation: assert property (
        @(posedge Clk) disable iff (!Reset) 
        (Mdo == (MdcEn_n & (~SerialEn & (BitCounter < 32)) | ShiftedBit | (~SerialEn & (BitCounter < 32))))
    );
endmodule
```