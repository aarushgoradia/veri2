```systemverilog
module eth_l3_checksum_sva (
    input logic MRxClk,
    input logic Reset,
    input logic [7:0] RxData,
    input logic [15:0] ByteCnt,
    output logic [15:0] CheckSum,
    output logic CSready
);
    // Reset assertion
    reset: assert property (
        @(posedge MRxClk) disable iff (!Reset) (CheckSum == 16'd0) && (CSready == 1'd0)
    ) else $error("Reset did not properly initialize CheckSum and CSready");

    // CheckSum calculation starts when ByteCnt is between 17 and 36
    start_calculation: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt >= 16'h17 && ByteCnt < 16'h37) |-> StartCalc[0] == 1'b1
    ) else $error("StartCalc[0] not set when ByteCnt is between 17 and 36");

    // CheckSum calculation starts when ByteCnt is 15
    start_calculation_15: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h15) |-> StartCalc[0] == 1'b1
    ) else $error("StartCalc[0] not set when ByteCnt is 15");

    // CheckSum calculation starts when ByteCnt is 16
    start_calculation_16: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h16) |-> StartCalc[0] == 1'b0
    ) else $error("StartCalc[0] not set when ByteCnt is 16");

    // CheckSum calculation starts when ByteCnt is greater than 17
    start_calculation_greater_17: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt > 16'h17) |-> StartCalc[1] == 1'b1
    ) else $error("StartCalc[1] not set when ByteCnt is greater than 17");

    // CheckSum calculation ends when ByteCnt is 37
    end_calculation: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h37) |-> CSready == 1'b1
    ) else $error("CSready not set when ByteCnt is 37");

    // CheckSum calculation ends when ByteCnt is 38
    end_calculation_38: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h38) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 38");

    // CheckSum calculation ends when ByteCnt is 39
    end_calculation_39: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h39) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 39");

    // CheckSum calculation ends when ByteCnt is 40
    end_calculation_40: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h40) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 40");

    // CheckSum calculation ends when ByteCnt is 41
    end_calculation_41: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h41) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 41");

    // CheckSum calculation ends when ByteCnt is 42
    end_calculation_42: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h42) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 42");

    // CheckSum calculation ends when ByteCnt is 43
    end_calculation_43: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h43) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 43");

    // CheckSum calculation ends when ByteCnt is 44
    end_calculation_44: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h44) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 44");

    // CheckSum calculation ends when ByteCnt is 45
    end_calculation_45: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h45) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 45");

    // CheckSum calculation ends when ByteCnt is 46
    end_calculation_46: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h46) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 46");

    // CheckSum calculation ends when ByteCnt is 47
    end_calculation_47: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h47) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 47");

    // CheckSum calculation ends when ByteCnt is 48
    end_calculation_48: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h48) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 48");

    // CheckSum calculation ends when ByteCnt is 49
    end_calculation_49: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h49) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 49");

    // CheckSum calculation ends when ByteCnt is 50
    end_calculation_50: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h50) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 50");

    // CheckSum calculation ends when ByteCnt is 51
    end_calculation_51: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h51) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 51");

    // CheckSum calculation ends when ByteCnt is 52
    end_calculation_52: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h52) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 52");

    // CheckSum calculation ends when ByteCnt is 53
    end_calculation_53: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h53) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 53");

    // CheckSum calculation ends when ByteCnt is 54
    end_calculation_54: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h54) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 54");

    // CheckSum calculation ends when ByteCnt is 55
    end_calculation_55: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h55) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 55");

    // CheckSum calculation ends when ByteCnt is 56
    end_calculation_56: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h56) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 56");

    // CheckSum calculation ends when ByteCnt is 57
    end_calculation_57: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h57) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 57");

    // CheckSum calculation ends when ByteCnt is 58
    end_calculation_58: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h58) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 58");

    // CheckSum calculation ends when ByteCnt is 59
    end_calculation_59: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h59) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 59");

    // CheckSum calculation ends when ByteCnt is 60
    end_calculation_60: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h60) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 60");

    // CheckSum calculation ends when ByteCnt is 61
    end_calculation_61: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h61) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 61");

    // CheckSum calculation ends when ByteCnt is 62
    end_calculation_62: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h62) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 62");

    // CheckSum calculation ends when ByteCnt is 63
    end_calculation_63: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h63) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 63");

    // CheckSum calculation ends when ByteCnt is 64
    end_calculation_64: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h64) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 64");

    // CheckSum calculation ends when ByteCnt is 65
    end_calculation_65: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h65) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 65");

    // CheckSum calculation ends when ByteCnt is 66
    end_calculation_66: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h66) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 66");

    // CheckSum calculation ends when ByteCnt is 67
    end_calculation_67: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h67) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 67");

    // CheckSum calculation ends when ByteCnt is 68
    end_calculation_68: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h68) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 68");

    // CheckSum calculation ends when ByteCnt is 69
    end_calculation_69: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h69) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 69");

    // CheckSum calculation ends when ByteCnt is 70
    end_calculation_70: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h70) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 70");

    // CheckSum calculation ends when ByteCnt is 71
    end_calculation_71: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h71) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 71");

    // CheckSum calculation ends when ByteCnt is 72
    end_calculation_72: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h72) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 72");

    // CheckSum calculation ends when ByteCnt is 73
    end_calculation_73: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h73) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 73");

    // CheckSum calculation ends when ByteCnt is 74
    end_calculation_74: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h74) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 74");

    // CheckSum calculation ends when ByteCnt is 75
    end_calculation_75: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h75) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 75");

    // CheckSum calculation ends when ByteCnt is 76
    end_calculation_76: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h76) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 76");

    // CheckSum calculation ends when ByteCnt is 77
    end_calculation_77: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h77) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 77");

    // CheckSum calculation ends when ByteCnt is 78
    end_calculation_78: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h78) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 78");

    // CheckSum calculation ends when ByteCnt is 79
    end_calculation_79: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h79) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 79");

    // CheckSum calculation ends when ByteCnt is 80
    end_calculation_80: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h80) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 80");

    // CheckSum calculation ends when ByteCnt is 81
    end_calculation_81: assert property (
        @(posedge MRxClk) disable iff (!Reset) 
        (ByteCnt == 16'h81) |-> CSready == 1'b0
    ) else $error("CSready not set when ByteCnt is 81");

    // Check