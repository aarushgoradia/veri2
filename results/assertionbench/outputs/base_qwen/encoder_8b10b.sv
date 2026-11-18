```systemverilog
module encoder_8b10b_sva (
    input logic SBYTECLK,
    input logic reset,
    input logic K,
    input logic [7:0] ebi,
    output logic [9:0] tbi,
    output logic disparity
);

    // Reset polarity is active low
    // Logic is sequential

    // Key signals:
    // SBYTECLK - System byte clock
    // reset - Active low reset
    // K - Control (K) input
    // ebi - Eight bit input bus
    // tbi - Ten bit output bus
    // disparity - Disparity signal

    // Disparity should be 0 at reset
    reset_disparity: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (reset |-> disparity == 1'b0)
    );

    // Disparity should toggle based on PDOS4, NDOS4, and DISPARITY6
    disparity_toggle: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (disparity == (PDOS4 | NDOS4) ^ DISPARITY6))
    );

    // TBI[9] should be the XOR of NAO, NBO, NCO, NDO, NEO, NIO, NFO, NGO, NHO, NJO
    tbi_9_xor: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (tbi[9] == (NAO ^ NBO ^ NCO ^ NDO ^ NEO ^ NIO ^ NFO ^ NGO ^ NHO ^ NJO)))
    );

    // NAO should be equal to A
    nao_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NAO == A))
    );

    // NBO should be equal to B & !L40 or L04
    nbo_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NBO == (B & !L40) | L04))
    );

    // NCO should be equal to L04 | C or E & D & !C & !B & !A
    nco_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NCO == (L04 | C) | (E & D & !C & !B & !A)))
    );

    // NDO should be equal to D & !(A & B & C)
    ndo_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NDO == (D & !(A & B & C))))
    );

    // NEO should be equal to E | L13 and !(E & D & !C & !B & !A)
    neo_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NEO == (E | L13) & !(E & D & !C & !B & !A)))
    );

    // NIO should be equal to (L22 & !E) | (E & L40) or E & !D & !C & !(A & B) or K & E & D & C & !B & !A or E & !D & C & !B & !A
    nio_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NIO == ((L22 & !E) | (E & L40) | (E & !D & !C & !(A & B)) | (K & E & D & C & !B & !A) | (E & !D & C & !B & !A))))
    );

    // NFO should be equal to F & !alt7
    nfo_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NFO == (F & !alt7)))
    );

    // NGO should be equal to G | (!F & !G & !H)
    ngo_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NGO == (G | (!F & !G & !H))))
    );

    // NHO should be equal to H
    nho_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NHO == H))
    );

    // NJO should be equal to !H & (G ^ F) or alt7
    njo_check: assert property (
        @(posedge SBYTECLK) disable iff (!reset) (tbi[9] |-> (NJO == (!H & (G ^ F)) | alt7))
    );

endmodule
```