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
    input logic PD_1S4,
    input logic NDOS4,
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
    input logic NJO,
    input logic tNAO,
    input logic tNBOx,
    input logic tNBOy,
    input logic tNCOx,
    input logic tNCOy,
    input logic tNDO,
    input logic tNEOx,
    input logic tNEOy,
    input logic tNIOw,
    input logic tNIOx,
    input logic tNIOy,
    input logic tNIOz,
    input logic alt7
);

    // Reset clears the registered outputs and disparity.
    check_reset_clears_outputs: assert property (
        @(posedge SBYTECLK)
        reset |=> ((tbi == 10'b0) && (disparity == 1'b0))
    );

    // Reset clears the registered disparity control state.
    check_reset_clears_disparity_state: assert property (
        @(posedge SBYTECLK)
        reset |=> ((COMPLS6 == 1'b0) && (COMPLS4 == 1'b0))
    );

    // Reset clears the registered 5B/6B encoder state.
    check_reset_clears_5b6b_state: assert property (
        @(posedge SBYTECLK)
        reset |=> ((tNAO == 1'b0) && (tNBOx == 1'b0) && (tNBOy == 1'b0) &&
                   (tNCOx == 1'b0) && (tNCOy == 1'b0) && (tNDO == 1'b0) &&
                   (tNEOx == 1'b0) && (tNEOy == 1'b0) && (tNIOw == 1'b0) &&
                   (tNIOx == 1'b0) && (tNIOy == 1'b0) && (tNIOz == 1'b0))
    );

    // Reset clears the registered 3B/4B encoder state.
    check_reset_clears_3b4b_state: assert property (
        @(posedge SBYTECLK)
        reset |=> ((alt7 == 1'b0) && (tNFO == 1'b0) && (tNGO == 1'b0) &&
                   (tNHO == 1'b0) && (tNJO == 1'b0))
    );

    // AeqB is high when A and B are equal.
    check_aeqb_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        AeqB == ((A & B) | (!A & !B))
    );

    // CeqD is high when C and D are equal.
    check_ceqd_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        CeqD == ((C & D) | (!C & !D))
    );

    // L40 is high when all four input bits are high.
    check_l40_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        L40 == (A & B & C & D)
    );

    // L04 is high when all four input bits are low.
    check_l04_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        L04 == (!A & !B & !C & !D)
    );

    // L13 is high when the A/B and C/D pairs differ.
    check_l13_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        L13 == ((!AeqB & !C & !D) | (!CeqD & !A & !B))
    );

    // L31 is high when the A/B and C/D pairs match.
    check_l31_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        L31 == ((!AeqB & C & D) | (!CeqD & A & B))
    );

    // L22 is high when the two 2-bit pairs differ.
    check_l22_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        L22 == ((A & B & !C & !D) | (C & D & !A & !B) | (!AeqB & !CeqD))
    );

    // PD_1S6 is high for the 5B/6B positive disparity state.
    check_pd_1s6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        PD_1S6 == ((E & D & !C & !B & !A) | (!E & !L22 & !L31))
    );

    // NDOS6 is the inverse of PD_1S6.
    check_ndos6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NDOS6 == !PD_1S6
    );

    // PDOS6 is high when K is high or the negative disparity state is active.
    check_pdos6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        PDOS6 == (K | (!PD_1S6))
    );

    // ND_1S6 is high when K is high or the negative disparity state is active.
    check_nd_1s6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        ND_1S6 == (K | (!PD_1S6))
    );

    // ND_1S4 is high when F and G are both high.
    check_nd_1s4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        ND_1S4 == (F & G)
    );

    // NDOS4 is high when F and G are both low.
    check_ndos4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NDOS4 == (!F & !G)
    );

    // PD_1S4 is high when NDOS4 is low or K is high.
    check_pd_1s4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        PD_1S4 == ((!NDOS4) | K)
    );

    // PDOS4 is high when F, G, and H are all high.
    check_pdos4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        PDOS4 == (F & G & H)
    );

    // DISPARITY6 is the XOR of the 5B/6B disparity classifications.
    check_disparity6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        DISPARITY6 == (NDOS6 ^ PDOS6)
    );

    // COMPLS6 is high when PDOS6 is high and disparity is low.
    check_compls6_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        COMPLS6 == (PDOS6 & !disparity)
    );

    // COMPLS4 is high when PDOS4 is high and disparity is low.
    check_compls4_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        COMPLS4 == (PDOS4 & !disparity)
    );

    // NAO is a direct copy of A.
    check_nao_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NAO == A
    );

    // NBO is the OR of the two 5B/6B B-related terms.
    check_nbo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NBO == (tNBOx | tNBOy)
    );

    // NCO is the OR of the two 5B/6B C-related terms.
    check_nco_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NCO == (tNCOx | tNCOy)
    );

    // NDO is a direct copy of D.
    check_ndo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NDO == D
    );

    // NEO is the AND of the two 5B/6B E-related terms.
    check_neo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NEO == (tNEOx & tNEOy)
    );

    // NIO is the OR of all 5B/6B I/O-related terms.
    check_nio_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NIO == (tNIOw | tNIOx | tNIOy | tNIOz)
    );

    // NFO is a direct copy of F.
    check_nfo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NFO == F
    );

    // NGO is the OR of the two 3B/4B G-related terms.
    check_ng_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NGO == (tNGO | (!F & !G & !H))
    );

    // NHO is a direct copy of H.
    check_nho_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NHO == H
    );

    // NJO is the OR of the two 3B/4B J-related terms.
    check_njo_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        NJO == (tNJO | alt7)
    );

    // alt7 is high when F, G, and H are all high and K is high.
    check_alt7_definition: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        alt7 == (F & G & H & K)
    );

    // The 5B/6B encoder state is stable when the input control and data bits are stable.
    check_5b6b_state_stable_when_inputs_stable: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        (!$changed(K) && !$changed({A,B,C,D,E})) |-> !$changed({tNAO,tNBOx,tNBOy,tNCOx,tNCOy,tNDO,tNEOx,tNEOy,tNIOw,tNIOx,tNIOy,tNIOz})
    );

    // The 3B/4B encoder state is stable when the input control and data bits are stable.
    check_3b4b_state_stable_when_inputs_stable: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        (!$changed(K) && !$changed({F,G,H})) |-> !$changed({alt7,tNFO,tNGO,tNHO,tNJO})
    );

    // The 5B/6B output bits are the XOR of the encoder terms and the complement controls.
    check_5b6b_output_mapping: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        tbi == { (NAO ^ COMPLS6),
                 (NBO ^ COMPLS6),
                 (NCO ^ COMPLS6),
                 (NDO ^ COMPLS6),
                 (NEO ^ COMPLS6),
                 (NIO ^ COMPLS6),
                 (NFO ^ COMPLS4),
                 (NGO ^ COMPLS4),
                 (NHO ^ COMPLS4),
                 (NJO ^ COMPLS4) }
    );

    // The 3B/4B output bits are the XOR of the encoder terms and the complement controls.
    check_3b4b_output_mapping: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        tbi == { (NAO ^ COMPLS6),
                 (NBO ^ COMPLS6),
                 (NCO ^ COMPLS6),
                 (NDO ^ COMPLS6),
                 (NEO ^ COMPLS6),
                 (NIO ^ COMPLS6),
                 (NFO ^ COMPLS4),
                 (NGO ^ COMPLS4),
                 (NHO ^ COMPLS4),
                 (NJO ^ COMPLS4) }
    );

    // The 5B/6B disparity state is stable when the input control and data bits are stable.
    check_5b6b_disparity_state_stable_when_inputs_stable: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        (!$changed(K) && !$changed({A,B,C,D,E})) |-> !$changed({COMPLS6,disparity})
    );

    // The 3B/4B disparity state is stable when the input control and data bits are stable.
    check_3b4b_disparity_state_stable_when_inputs_stable: assert property (
        @(posedge SBYTECLK) disable iff (reset)
        (!$changed(K) && !$changed({F,G,H})) |-> !$changed({COMPLS4,disparity})
    );

endmodule