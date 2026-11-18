module eth_l3_checksum_sva (
    input logic        MRxClk,
    input logic        Reset,
    input logic [7:0]  RxData,
    input logic [15:0] ByteCnt,
    input logic [15:0] CheckSum,
    input logic        CSready
);

    // Reset clears the checksum and ready output.
    reset_clears_outputs: assert property (
        @(posedge MRxClk) Reset |-> (CheckSum == 16'h0000) && (CSready == 1'b0)
    );

    // Byte count 15 loads the start-of-header flag from RxData[7:0].
    start_of_header_load: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h0015) |=> (CheckSum == $past(CheckSum)) &&
                                  (CSready == $past(CSready)) &&
                                  (CheckSum[15:0] == {14'b0, $past(RxData[7])})
    );

    // Byte count 16 clears the checksum and ready output.
    end_of_header_clears_outputs: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h0016) |=> (CheckSum == 16'h0000) &&
                                  (CSready == 1'b0) &&
                                  (CheckSum[15:0] == 16'h0000)
    );

    // Byte counts 17 through 26 load the ready flag from the previous cycle.
    ready_loads_from_prev_cycle: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0017 && ByteCnt < 16'h0017 + 16'd20) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte count 37 sets ready and computes the checksum from the previous 20 bytes.
    ready_and_checksum_at_37: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt == 16'h0025) |=> (CheckSum == ~($past(Sum[15:0]) + $past(Sum[31:16]))) &&
                                  (CSready == 1'b1)
    );

    // Byte counts 27 through 36 hold the checksum and ready output.
    hold_outputs_between_27_and_36: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h001B && ByteCnt < 16'h0025) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 38 through 46 hold the checksum and ready output.
    hold_outputs_between_38_and_46: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0026 && ByteCnt < 16'h002E) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 47 through 55 hold the checksum and ready output.
    hold_outputs_between_47_and_55: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h002F && ByteCnt < 16'h0037) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 56 through 64 hold the checksum and ready output.
    hold_outputs_between_56_and_64: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0038 && ByteCnt < 16'h0040) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 65 through 73 hold the checksum and ready output.
    hold_outputs_between_65_and_73: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0041 && ByteCnt < 16'h0049) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 74 through 82 hold the checksum and ready output.
    hold_outputs_between_74_and_82: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h004D && ByteCnt < 16'h0055) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 83 through 91 hold the checksum and ready output.
    hold_outputs_between_83_and_91: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0059 && ByteCnt < 16'h0061) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 92 through 100 hold the checksum and ready output.
    hold_outputs_between_92_and_100: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0065 && ByteCnt < 16'h006D) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 101 through 109 hold the checksum and ready output.
    hold_outputs_between_101_and_109: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h006F && ByteCnt < 16'h0077) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 110 through 118 hold the checksum and ready output.
    hold_outputs_between_110_and_118: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h007B && ByteCnt < 16'h0083) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 119 through 127 hold the checksum and ready output.
    hold_outputs_between_119_and_127: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0087 && ByteCnt < 16'h008F) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 128 through 136 hold the checksum and ready output.
    hold_outputs_between_128_and_136: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0093 && ByteCnt < 16'h009B) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 137 through 145 hold the checksum and ready output.
    hold_outputs_between_137_and_145: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h009F && ByteCnt < 16'h00A7) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 146 through 154 hold the checksum and ready output.
    hold_outputs_between_146_and_154: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00AD && ByteCnt < 16'h00B5) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 155 through 163 hold the checksum and ready output.
    hold_outputs_between_155_and_163: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00BD && ByteCnt < 16'h00C5) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 164 through 172 hold the checksum and ready output.
    hold_outputs_between_164_and_172: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00CF && ByteCnt < 16'h00D7) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 173 through 181 hold the checksum and ready output.
    hold_outputs_between_173_and_181: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00E3 && ByteCnt < 16'h00EB) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 182 through 190 hold the checksum and ready output.
    hold_outputs_between_182_and_190: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00EF && ByteCnt < 16'h00F7) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 191 through 199 hold the checksum and ready output.
    hold_outputs_between_191_and_199: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h00FF && ByteCnt < 16'h0107) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 200 through 208 hold the checksum and ready output.
    hold_outputs_between_200_and_208: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h010B && ByteCnt < 16'h0113) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 209 through 217 hold the checksum and ready output.
    hold_outputs_between_209_and_217: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0117 && ByteCnt < 16'h011F) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 218 through 226 hold the checksum and ready output.
    hold_outputs_between_218_and_226: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0123 && ByteCnt < 16'h012B) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 227 through 235 hold the checksum and ready output.
    hold_outputs_between_227_and_235: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h012F && ByteCnt < 16'h0137) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 236 through 244 hold the checksum and ready output.
    hold_outputs_between_236_and_244: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h013B && ByteCnt < 16'h0143) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 245 through 253 hold the checksum and ready output.
    hold_outputs_between_245_and_253: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0147 && ByteCnt < 16'h014F) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 254 through 262 hold the checksum and ready output.
    hold_outputs_between_254_and_262: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0153 && ByteCnt < 16'h015B) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 263 through 271 hold the checksum and ready output.
    hold_outputs_between_263_and_271: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h015F && ByteCnt < 16'h0167) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 272 through 280 hold the checksum and ready output.
    hold_outputs_between_272_and_280: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h016B && ByteCnt < 16'h0173) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 281 through 289 hold the checksum and ready output.
    hold_outputs_between_281_and_289: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0177 && ByteCnt < 16'h017F) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 290 through 298 hold the checksum and ready output.
    hold_outputs_between_290_and_298: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h0183 && ByteCnt < 16'h018B) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 299 through 307 hold the checksum and ready output.
    hold_outputs_between_299_and_307: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h018F && ByteCnt < 16'h0197) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 308 through 316 hold the checksum and ready output.
    hold_outputs_between_308_and_316: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h019B && ByteCnt < 16'h01A3) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 317 through 325 hold the checksum and ready output.
    hold_outputs_between_317_and_325: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h01A7 && ByteCnt < 16'h01AF) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 326 through 334 hold the checksum and ready output.
    hold_outputs_between_326_and_334: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h01B3 && ByteCnt < 16'h01BB) |=> (CheckSum == $past(CheckSum)) &&
                                                                  (CSready == $past(CSready))
    );

    // Byte counts 335 through 343 hold the checksum and ready output.
    hold_outputs_between_335_and_343: assert property (
        @(posedge MRxClk) disable iff (Reset)
        (ByteCnt >= 16'h01BF && ByteCnt < 16'h01C7) |=> (CheckSum == $past(CheckSum)) &&
