module encoder_8b10b_sva (
    input logic SBYTECLK,
    input logic reset,
    input logic K,
    input logic [7:0] ebi,
    input logic [9:0] tbi,
    input logic disparity,
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
    input logic COMPLS6,
    input logic COMPLS4,
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
    input logic AeqB,
    input logic CeqD,
    input logic L40,
    input logic L04,
    input logic L13,
    input logic L31,
    input logic L22
);

// Reset clears all state and outputs.
    check_reset_clears_state: assert property (
        @(posedge SBYTECLK) reset |-> (tbi == 10'b0) &&
                                   (disparity == 1'b0) &&
                                   (NAO == 1'b0) &&
                                   (NBO == 1'b0) &&
                                   (NCO == 1'b0) &&
                                   (NDO == 1'b0) &&
                                   (NEO == 1'b0) &&
                                   (NIO == 1'b0) &&
                                   (NFO == 1'b0) &&
                                   (NGO == 1'b0) &&
                                   (NHO == 1'b0) &&
                                   (NJO == 1'b0) &&
                                   (COMPLS6 == 1'b0) &&
                                   (COMPLS4 == 1'b0) &&
                                   (PD_1S6 == 1'b0) &&
                                   (NDOS6 == 1'b0) &&
                                   (PDOS6 == 1'b0) &&
                                   (ND_1S6 == 1'b0) &&
                                   (ND_1S4 == 1'b0) &&
                                   (PD_1S4 == 1'b0) &&
                                   (NDOS4 == 1'b0) &&
                                   (PDOS4 == 1'b0) &&
                                   (illegalk == 1'b0) &&
                                   (DISPARITY6 == 1'b0) &&
                                   (AeqB == 1'b0) &&
                                   (CeqD == 1'b0) &&
                                   (L40 == 1'b0) &&
                                   (L04 == 1'b0) &&
                                   (L13 == 1'b0) &&
                                   (L31 == 1'b0) &&
                                   (L22 == 1'b0)
    );

// NAO is a direct capture of A.
    check_nao_captures_a: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NAO == A)
    );

// NBO is the OR of B and the L04 condition.
    check_nbo_captures_b_or_l04: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NBO == (B | L04))
    );

// NCO is the OR of L04 and C.
    check_nco_captures_l04_or_c: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NCO == (L04 | C))
    );

// NDO is D AND NOT (A&B&C).
    check_ndo_captures_d_and_not_abc: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NDO == (D & ~(A & B & C)))
    );

// NEO is E OR L13.
    check_neo_captures_e_or_l13: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NEO == (E | L13))
    );

// NIO is the OR of L22, E, and the K condition.
    check_nio_captures_l22_or_e_or_k: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NIO == (L22 | E | K))
    );

// NFO is F AND NOT alt7.
    check_nfo_captures_f_and_not_alt7: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NFO == (F & ~alt7))
    );

// NGO is G OR (NOT F AND NOT G AND NOT H).
    check_ng_captures_g_or_not_fgh: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NGO == (G | (~F & ~G & ~H)))
    );

// NHO is H.
    check_nho_captures_h: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NHO == H)
    );

// NJO is NOT H OR (G XOR F).
    check_njo_captures_not_h_or_gxorf: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NJO == (~H | (G ^ F)))
    );

// ND_1S4 is F AND G.
    check_nd_1s4_captures_fg: assert property (
        @(posedge SBYTECLK) disable iff (reset) (ND_1S4 == (F & G))
    );

// NDOS4 is NOT (F AND G).
    check_ndos4_captures_not_fg: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NDOS4 == ~(F & G))
    );

// PD_1S4 is (NOT (F AND G)) OR (K AND ((F AND NOT G) OR (NOT F AND G))).
    check_pd_1s4_captures_not_fg_or_k_cond: assert property (
        @(posedge SBYTECLK) disable iff (reset) (PD_1S4 == ((~(F & G)) | (K & ((F & ~G) | (~F & G)))))
    );

// PDOS4 is F AND G AND H.
    check_pdos4_captures_fgh: assert property (
        @(posedge SBYTECLK) disable iff (reset) (PDOS4 == (F & G & H))
    );

// ND_1S6 is (E AND D AND NOT C AND NOT B AND NOT A) OR (NOT E AND NOT L22 AND NOT L31).
    check_nd_1s6_captures_edcba_or_not_e_and_not_l22_l31: assert property (
        @(posedge SBYTECLK) disable iff (reset) (ND_1S6 == ((E & D & ~C & ~B & ~A) | (~E & ~L22 & ~L31)))
    );

// PD_1S6 is (NOT (E AND D AND NOT C AND NOT B AND NOT A)) OR K.
    check_pd_1s6_captures_not_edcba_or_k: assert property (
        @(posedge SBYTECLK) disable iff (reset) (PD_1S6 == ((~(E & D & ~C & ~B & ~A)) | K))
    );

// PDOS6 is K OR (E AND NOT L22 AND NOT L13).
    check_pdos6_captures_k_or_e_and_not_l22_l13: assert property (
        @(posedge SBYTECLK) disable iff (reset) (PDOS6 == (K | (E & ~L22 & ~L13)))
    );

// NDOS6 is PD_1S6.
    check_ndos6_captures_pd_1s6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (NDOS6 == PD_1S6)
    );

// DISPARITY6 is disparity XOR (NDOS6 OR PDOS6).
    check_disparity6_captures_disparity_xor_ndos6_or_pdos6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (DISPARITY6 == (disparity ^ (NDOS6 | PDOS6)))
    );

// COMPLS4 is (PD_1S4 AND NOT DISPARITY6) OR (ND_1S4 AND DISPARITY6).
    check_compls4_captures_pd_1s4_and_not_disp_or_nd_1s4_and_disp: assert property (
        @(posedge SBYTECLK) disable iff (reset) (COMPLS4 == ((PD_1S4 & ~DISPARITY6) | (ND_1S4 & DISPARITY6)))
    );

// COMPLS6 is (PD_1S6 AND NOT disparity) OR (ND_1S6 AND disparity).
    check_compls6_captures_pd_1s6_and_not_disp_or_nd_1s6_and_disp: assert property (
        @(posedge SBYTECLK) disable iff (reset) (COMPLS6 == ((PD_1S6 & ~disparity) | (ND_1S6 & disparity)))
    );

// illegalk is K AND (A OR B OR NOT C OR NOT D OR NOT E) AND (NOT F OR NOT G OR NOT H OR NOT E OR NOT L31).
    check_illegalk_captures_k_and_aorbnotcnotdnote_and_notfnotgnothnote_notl31: assert property (
        @(posedge SBYTECLK) disable iff (reset) (illegalk == (K & (A | B | ~C | ~D | ~E) & (~F | ~G | ~H | ~E | ~L31)))
    );

// AeqB is (A AND B) OR (NOT A AND NOT B).
    check_aeqb_captures_a_and_b_or_not_a_not_b: assert property (
        @(posedge SBYTECLK) disable iff (reset) (AeqB == (A & B) | (~A & ~B))
    );

// CeqD is (C AND D) OR (NOT C AND NOT D).
    check_ceqd_captures_c_and_d_or_not_c_not_d: assert property (
        @(posedge SBYTECLK) disable iff (reset) (CeqD == (C & D) | (~C & ~D))
    );

// L40 is A AND B AND C AND D.
    check_l40_captures_abcd: assert property (
        @(posedge SBYTECLK) disable iff (reset) (L40 == (A & B & C & D))
    );

// L04 is NOT A AND NOT B AND NOT C AND NOT D.
    check_l04_captures_not_abcd: assert property (
        @(posedge SBYTECLK) disable iff (reset) (L04 == (~A & ~B & ~C & ~D))
    );

// L13 is (NOT AeqB AND NOT C AND NOT D) OR (NOT CeqD AND NOT A AND NOT B).
    check_l13_captures_not_aeqb_not_c_not_d_or_not_ceqd_not_a_not_b: assert property (
        @(posedge SBYTECLK) disable iff (reset) (L13 == ((~AeqB & ~C & ~D) | (~CeqD & ~A & ~B)))
    );

// L31 is (NOT AeqB AND C AND D) OR (NOT CeqD AND A AND B).
    check_l31_captures_not_aeqb_c_d_or_not_ceqd_a_b: assert property (
        @(posedge SBYTECLK) disable iff (reset) (L31 == ((~AeqB & C & D) | (~CeqD & A & B)))
    );

// L22 is (A AND B AND NOT C AND NOT D) OR (C AND D AND NOT A AND NOT B) OR (NOT AeqB AND NOT CeqD).
    check_l22_captures_ab_not_c_not_d_or_cd_not_a_not_b_or_not_aeqb_not_ceqd: assert property (
        @(posedge SBYTECLK) disable iff (reset) (L22 == ((A & B & ~C & ~D) | (C & D & ~A & ~B) | (~AeqB & ~CeqD)))
    );

// alt7 is F AND G AND H AND (K OR (disparity ? (NOT E AND D AND L31) : (E AND NOT D AND L13))).
    check_alt7_captures_fgh_and_k_or_disparity_cond: assert property (
        @(posedge SBYTECLK) disable iff (reset) (alt7 == (F & G & H & (K | (disparity ? (~E & D & L31) : (E & ~D & L13)))))
    );

// tbi[9] is NAO XOR COMPLS6.
    check_tbi9_is_nao_xor_compl6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[9] == (NAO ^ COMPLS6))
    );

// tbi[8] is NBO XOR COMPLS6.
    check_tbi8_is_nbo_xor_compl6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[8] == (NBO ^ COMPLS6))
    );

// tbi[7] is NCO XOR COMPLS6.
    check_tbi7_is_nco_xor_compl6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[7] == (NCO ^ COMPLS6))
    );

// tbi[6] is NDO XOR COMPLS6.
    check_tbi6_is_ndo_xor_compl6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[6] == (NDO ^ COMPLS6))
    );

// tbi[5] is NEO XOR COMPLS6.
    check_tbi5_is_neo_xor_compl6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[5] == (NEO ^ COMPLS6))
    );

// tbi[4] is NIO XOR COMPLS6.
    check_tbi4_is_nio_xor_compl6: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[4] == (NIO ^ COMPLS6))
    );

// tbi[3] is NFO XOR COMPLS4.
    check_tbi3_is_nfo_xor_compl4: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[3] == (NFO ^ COMPLS4))
    );

// tbi[2] is NGO XOR COMPLS4.
    check_tbi2_is_ng_xor_compl4: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[2] == (NGO ^ COMPLS4))
    );

// tbi[1] is NHO XOR COMPLS4.
    check_tbi1_is_nho_xor_compl4: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[1] == (NHO ^ COMPLS4))
    );

// tbi[0] is NJO XOR COMPLS4.
    check_tbi0_is_njo_xor_compl4: assert property (
        @(posedge SBYTECLK) disable iff (reset) (tbi[0] == (NJO ^ COMPLS4))
    );

endmodule
