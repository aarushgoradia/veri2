module eth_l3_checksum_sva (
    input logic        MRxClk,
    input logic        Reset,
    input logic [7:0]  RxData,
    input logic [15:0] ByteCnt,
    input logic [15:0] CheckSum,
    input logic        CSready
);

// Reset drives CheckSum and CSready low on the next clock.
    reset_clears_outputs: assert property (
        @(posedge MRxClk) Reset |=> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

// Byte count 15 starts checksum calculation.
    start_calc_15: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h000F) |=> (StartCalc[0] == 1'b1)
    );

// Byte count 16 clears the checksum and prepares for the next 20 bytes.
    start_calc_16: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h0010) |=> (StartCalc[0] == 1'b0) &&
                                  (StartCalc[1] == 1'b0) &&
                                  (CheckSum == 16'h0000) &&
                                  (Sum == 32'h00000000)
    );

// Byte counts 17 through 26 use the previous 16-byte block.
    start_calc_17_to_26: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0011) && (ByteCnt <= 16'h001A) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b0)
    );

// Byte counts 27 through 36 use the current 16-byte block.
    start_calc_27_to_36: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h001B) && (ByteCnt <= 16'h0024) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 37 through 46 use the current 16-byte block.
    start_calc_37_to_46: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0025) && (ByteCnt <= 16'h002E) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 47 through 56 use the current 16-byte block.
    start_calc_47_to_56: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h002F) && (ByteCnt <= 16'h0038) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 57 through 66 use the current 16-byte block.
    start_calc_57_to_66: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0039) && (ByteCnt <= 16'h0042) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 67 through 76 use the current 16-byte block.
    start_calc_67_to_76: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0043) && (ByteCnt <= 16'h004C) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 77 through 86 use the current 16-byte block.
    start_calc_77_to_86: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h004D) && (ByteCnt <= 16'h0056) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 87 through 96 use the current 16-byte block.
    start_calc_87_to_96: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0057) && (ByteCnt <= 16'h0060) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 97 through 106 use the current 16-byte block.
    start_calc_97_to_106: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0061) && (ByteCnt <= 16'h006A) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 107 through 116 use the current 16-byte block.
    start_calc_107_to_116: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h006B) && (ByteCnt <= 16'h0074) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 117 through 126 use the current 16-byte block.
    start_calc_117_to_126: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0075) && (ByteCnt <= 16'h007E) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 127 through 136 use the current 16-byte block.
    start_calc_127_to_136: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h007F) && (ByteCnt <= 16'h0088) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 137 through 146 use the current 16-byte block.
    start_calc_137_to_146: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0089) && (ByteCnt <= 16'h0092) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 147 through 156 use the current 16-byte block.
    start_calc_147_to_156: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0093) && (ByteCnt <= 16'h009C) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 157 through 166 use the current 16-byte block.
    start_calc_157_to_166: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h009D) && (ByteCnt <= 16'h00A6) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 167 through 176 use the current 16-byte block.
    start_calc_167_to_176: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00A7) && (ByteCnt <= 16'h00AE) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 177 through 186 use the current 16-byte block.
    start_calc_177_to_186: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00AF) && (ByteCnt <= 16'h00B8) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 187 through 196 use the current 16-byte block.
    start_calc_187_to_196: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00B9) && (ByteCnt <= 16'h00C2) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 197 through 206 use the current 16-byte block.
    start_calc_197_to_206: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00C3) && (ByteCnt <= 16'h00CC) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 207 through 216 use the current 16-byte block.
    start_calc_207_to_216: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00CD) && (ByteCnt <= 16'h00D6) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 217 through 226 use the current 16-byte block.
    start_calc_217_to_226: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00D7) && (ByteCnt <= 16'h00DE) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 227 through 236 use the current 16-byte block.
    start_calc_227_to_236: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00DF) && (ByteCnt <= 16'h00E8) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 237 through 246 use the current 16-byte block.
    start_calc_237_to_246: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00E9) && (ByteCnt <= 16'h00F2) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 247 through 256 use the current 16-byte block.
    start_calc_247_to_256: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00F3) && (ByteCnt <= 16'h00FC) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 257 through 266 use the current 16-byte block.
    start_calc_257_to_266: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00FD) && (ByteCnt <= 16'h0106) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 267 through 276 use the current 16-byte block.
    start_calc_267_to_276: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0107) && (ByteCnt <= 16'h0110) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 277 through 286 use the current 16-byte block.
    start_calc_277_to_286: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0111) && (ByteCnt <= 16'h011A) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 287 through 296 use the current 16-byte block.
    start_calc_287_to_296: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h011B) && (ByteCnt <= 16'h0124) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 297 through 306 use the current 16-byte block.
    start_calc_297_to_306: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0125) && (ByteCnt <= 16'h012E) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 307 through 316 use the current 16-byte block.
    start_calc_307_to_316: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h012F) && (ByteCnt <= 16'h0138) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 317 through 326 use the current 16-byte block.
    start_calc_317_to_326: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0139) && (ByteCnt <= 16'h0142) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 327 through 336 use the current 16-byte block.
    start_calc_327_to_336: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0143) && (ByteCnt <= 16'h014C) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 337 through 346 use the current 16-byte block.
    start_calc_337_to_346: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h014D) && (ByteCnt <= 16'h0156) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 347 through 356 use the current 16-byte block.
    start_calc_347_to_356: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0157) && (ByteCnt <= 16'h0160) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 357 through 366 use the current 16-byte block.
    start_calc_357_to_366: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0161) && (ByteCnt <= 16'h016A) |=> (StartCalc[0] == 1'b1) &&
                                                            (StartCalc[1] == 1'b1)
    );

// Byte counts 367 through 376