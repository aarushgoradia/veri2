module encoder_8b10b_sva (
    input logic reset,
    input logic SBYTECLK,
    input logic K,
    input logic [7:0] ebi,
    input logic [9:0] tbi,
    input logic disparity,
    input logic L40,
    input logic L04,
    input logic L13,
    input logic L31,
    input logic L22,
    input logic AeqB,
    input logic CeqD,
    input logic PD_1S6,
    input logic NDOS6,
    input logic PDOS6,
    input logic ND_1S6,
    input logic ND_1S4,
    input logic NDOS4,
    input logic PD_1S4,
    input logic PDOS4,
    input logic illegalk,
    input logic DISPARITY6,
    input logic COMPLS6,
    input logic COMPLS4,
    input logic NAO,
    input logic NBO,
    input logic NCO,
    input logic NDO,
    input logic NEO,
    input logic NIO,
    input logic NFO,
    input logic NGO,
    input logic NHO,
    input logic NJO
);

    // Reset clears the registered outputs and disparity.
    check_reset_clears_outputs: assert property (
        @(posedge SBYTECLK) reset |=> (tbi == 10'b0000000000) && (disparity == 1'b0)
    );

    // Reset clears the registered disparity control and complement state.
    check_reset_clears_control_state: assert property (
        @(posedge SBYTECLK) reset |=> (disparity == 1'b0) && (COMPLS6 == 1'b0) && (COMPLS4 == 1'b0)
    );

    // Reset clears the registered 5B/6B encoding state.
    check_reset_clears_5b6b_state: assert property (
        @(posedge SBYTECLK) reset |=> (NAO == 1'b0) && (NBO == 1'b0) && (NCO == 1'b0) && (NDO == 1'b0) &&
                                     (NEO == 1'b0) && (NIO == 1'b0)
    );

    // Reset clears the registered 3B/4B encoding state.
    check_reset_clears_3b4b_state: assert property (
        @(posedge SBYTECLK) reset |=> (NFO == 1'b0) && (NGO == 1'b0) && (NHO == 1'b0) && (NJO == 1'b0)
    );

    // L40 is asserted only for A & B & C & D.
    check_l40_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) L40 == (A & B & C & D)
    );

    // L04 is asserted only for !A & !B & !C & !D.
    check_l04_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) L04 == (!A & !B & !C & !D)
    );

    // L13 is asserted only for (!AeqB & !C & !D) | (!CeqD & !A & !B).
    check_l13_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) L13 == ((!AeqB & !C & !D) | (!CeqD & !A & !B))
    );

    // L31 is asserted only for (!AeqB & C & D) | (!CeqD & A & B).
    check_l31_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) L31 == ((!AeqB & C & D) | (!CeqD & A & B))
    );

    // L22 is asserted only for A & B & !C & !D | C & D & !A & !B | !AeqB & !CeqD.
    check_l22_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) L22 == ((A & B & !C & !D) | (C & D & !A & !B) | (!AeqB & !CeqD))
    );

    // AeqB is asserted only for A & B | !A & !B.
    check_aeqb_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) AeqB == ((A & B) | (!A & !B))
    );

    // CeqD is asserted only for C & D | !C & !D.
    check_ceqd_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) CeqD == ((C & D) | (!C & !D))
    );

    // PD_1S6 matches its implemented definition.
    check_pd_1s6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) PD_1S6 == ((E & D & !C & !B & !A) | (!E & !L22 & !L31))
    );

    // NDOS6 matches its implemented definition.
    check_ndos6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NDOS6 == PD_1S6
    );

    // PDOS6 matches its implemented definition.
    check_pdos6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) PDOS6 == (K | (E & !L22 & !L13))
    );

    // ND_1S6 matches its implemented definition.
    check_nd_1s6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) ND_1S6 == (K | (E & !L22 & !L13) | (!E & !D & C & B & A))
    );

    // ND_1S4 matches its implemented definition.
    check_nd_1s4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) ND_1S4 == (F & G)
    );

    // NDOS4 matches its implemented definition.
    check_ndos4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NDOS4 == ((!F & !G))
    );

    // PD_1S4 matches its implemented definition.
    check_pd_1s4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) PD_1S4 == ((!F & !G) | (K & ((F & !G) | (!F & G))))
    );

    // PDOS4 matches its implemented definition.
    check_pdos4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) PDOS4 == (F & G & H)
    );

    // illegalk matches its implemented definition.
    check_illegalk_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) illegalk == (K & (A | B | !C | !D | !E) & (!F | !G | !H | !E | !L31))
    );

    // DISPARITY6 matches its implemented definition.
    check_disparity6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) DISPARITY6 == (disparity ^ (NDOS6 | PDOS6))
    );

    // COMPLS6 matches its implemented definition.
    check_compl6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) COMPLS6 == ((PD_1S6 & !disparity) | (ND_1S6 & disparity))
    );

    // COMPLS4 matches its implemented definition.
    check_compl4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) COMPLS4 == ((PD_1S4 & !DISPARITY6) | (ND_1S4 & DISPARITY6))
    );

    // NAO is directly driven from A.
    check_nao_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NAO == A
    );

    // NBO is the OR of B & !L40 and L04.
    check_nbo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NBO == ((B & !L40) | L04)
    );

    // NCO is the OR of L04 | C.
    check_nco_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NCO == (L04 | C)
    );

    // NDO is directly driven from D & ! (A & B & C).
    check_ndo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NDO == (D & !(A & B & C))
    );

    // NEO is the AND of E | L13 and !(E & D & !C & !B & !A).
    check_neo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NEO == ((E | L13) & !(E & D & !C & !B & !A))
    );

    // NIO is the OR of L22 & !E | E & L40 | E & !D & !C & !(A & B) | E & !D & C & !B & !A.
    check_nio_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NIO == ((L22 & !E) | (E & L40) | (E & !D & !C & !(A & B)) | (E & !D & C & !B & !A))
    );

    // NFO is directly driven from F.
    check_nfo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NFO == F
    );

    // NGO is directly driven from G | (!F & !G & !H).
    check_ng_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NGO == (G | (!F & !G & !H))
    );

    // NHO is directly driven from H.
    check_nho_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NHO == H
    );

    // NJO is the OR of !H & (G ^ F) and alt7.
    check_njo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset) NJO == ((!H & (G ^ F)) | alt7)
    );

    // The TB output bus matches the registered encoder state.
    check_tbi_matches_registered_state: assert property (
        @(posedge SBYTECLK) disable iff (reset) tbi == {NAO ^ COMPLS6, NBO ^ COMPLS6, NCO ^ COMPLS6, NDO ^ COMPLS6, NEO ^ COMPLS6, NIO ^ COMPLS6, NFO ^ COMPLS4, NGO ^ COMPLS4, NHO ^ COMPLS4, NJO ^ COMPLS4}
    );

endmodule