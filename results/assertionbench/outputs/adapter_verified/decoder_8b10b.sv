module decoder_8b10b_sva (
    input logic reset,
    input logic RBYTECLK,
    input logic [9:0] tbi,
    input logic K_out,
    input logic [7:0] ebi,
    input logic coding_err,
    input logic disparity,
    input logic disparity_err
);

// K_out is registered and follows the prior-cycle K value.
    check_k_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (K_out == $past(K))
    );

// ebi is registered and follows the prior-cycle 5B/6B decoded value.
    check_ebi_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (ebi == $past({H, G, F, E, D, C, B, A}))
    );

// coding_err is registered and follows the prior-cycle coding error condition.
    check_coding_err_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (coding_err == $past(cerr | zerr | xerr))
    );

// disparity is registered and follows the prior-cycle disparity condition.
    check_disparity_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (disparity == $past(fghjP31 | (DISPARITY6b & fghj22)))
    );

// disparity_err is registered and follows the prior-cycle disparity error condition.
    check_disparity_err_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (disparity_err == $past(derr12 | derr34 | derr56 | derr78))
    );

// A is the registered XOR of the prior-cycle 5B/6B decoded value and OR12_7.
    check_a_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (A == $past({H, G, F, E, D, C, B, A}) ^ OR12_7)
    );

// B is the registered XOR of the prior-cycle 5B/6B decoded value and OR12_2.
    check_b_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (B == $past({H, G, F, E, D, C, B, A}) ^ OR12_2)
    );

// C is the registered XOR of the prior-cycle 5B/6B decoded value and OR12_1.
    check_c_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (C == $past({H, G, F, E, D, C, B, A}) ^ OR12_1)
    );

// D is the registered XOR of the prior-cycle 5B/6B decoded value and OR12_4.
    check_d_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (D == $past({H, G, F, E, D, C, B, A}) ^ OR12_4)
    );

// E is the registered XOR of the prior-cycle 5B/6B decoded value and OR12_5.
    check_e_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (E == $past({H, G, F, E, D, C, B, A}) ^ OR12_5)
    );

// F is the registered 3B/4B decoded value.
    check_f_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (F == $past((j & !f & (h | !g | K28p)) | (f & !j & (!h | g | !K28p)) | (K28p & g & h) | (!K28p & !g & !h)))
    );

// G is the registered 3B/4B decoded value.
    check_g_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (G == $past((j & !f & (h | !g | !K28p)) | (f & !j & (!h | g | K28p)) | (!K28p & g & h) | (K28p & !g & !h)))
    );

// H is the registered 3B/4B decoded value.
    check_h_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (H == $past(((j ^ h) & ! ((!f & g & !h & j & !K28p) | (!f & g & h & !j & K28p) | (f & !g & !h & j & !K28p) | (f & !g & h & !j & K28p))) | (!f & g & h & j) | (f & !g & !h & !j)))
    );

// K28p is the registered 3B/4B decoded value.
    check_k28p_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (K28p == $past(! (c | d | e | i)))
    );

// K is the registered 3B/4B decoded value.
    check_k_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (K == $past(KA | KB | KC))
    );

// KA is the registered 3B/4B decoded value.
    check_ka_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (KA == $past(c_d_e_i | cn_dn_en_in))
    );

// KB is the registered 3B/4B decoded value.
    check_kb_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (KB == $past(P13 & (!e & i & g & h & j)))
    );

// KC is the registered 3B/4B decoded value.
    check_kc_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (KC == $past(P31 & (e & !i & !g & !h & !j)))
    );

// OR12_1 is the registered 5B/6B decoded value.
    check_or12_1_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (OR12_1 == $past(P22_an_cn_eeqi | P13_en))
    );

// OR12_2 is the registered 5B/6B decoded value.
    check_or12_2_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (OR12_2 == $past(a_b_e_i | cn_dn_en_in | P31_i))
    );

// OR12_3 is the registered 5B/6B decoded value.
    check_or12_3_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (OR12_3 == $past(P31_i | P22_b_c_eeqi | P13_d_e_i))
    );

// OR12_4 is the registered 5B/6B decoded value.
    check_or12_4_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (OR12_4 == $past(P22_a_c_eeqi | P13_en))
    );

// OR12_5 is the registered 5B/6B decoded value.
    check_or12_5_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (OR12_5 == $past(P13_en | cn_dn_en_in | an_bn_en_in))
    );

// OR12_6 is the registered 5B/6B decoded value.
    check_or12_6_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (OR12_6 == $past(P22_an_cn_eeqi | P13_in))
    );

// OR12_7 is the registered 5B/6B decoded value.
    check_or12_7_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (OR12_7 == $past(P13_d_e_i | P22_bn_cn_eeqi))
    );

// feqg is the registered 5B/6B decoded value.
    check_feqg_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (feqg == $past((f & g) | (!f & !g)))
    );

// heqj is the registered 5B/6B decoded value.
    check_heqj_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (heqj == $past((h & j) | (!h & !j)))
    );

// fghjP13 is the registered 5B/6B decoded value.
    check_fghj_p13_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (fghjP13 == $past((!feqg & !h & !j) | (!heqj & !f & !g)))
    );

// fghjP31 is the registered 5B/6B decoded value.
    check_fghj_p31_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (fghjP31 == $past((!feqg & h & j) | (!heqj & f & g)))
    );

// fghj22 is the registered 5B/6B decoded value.
    check_fghj_22_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (fghj22 == $past((f & g & !h & !j) | (!f & !g & h & j) | (!feqg & !heqj)))
    );

// DISPARITY6p is the registered 5B/6B decoded value.
    check_disparity6p_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY6p == $past((P31 & (e | i)) | (P22 & e & i)))
    );

// DISPARITY6n is the registered 5B/6B decoded value.
    check_disparity6n_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY6n == $past((P13 & ! (e & i)) | (P22 & !e & !i)))
    );

// DISPARITY4p is the registered 5B/6B decoded value.
    check_disparity4p_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY4p == $past(fghjP31))
    );

// DISPARITY4n is the registered 5B/6B decoded value.
    check_disparity4n_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY4n == $past(fghjP13))
    );

// DISPARITY6a is the registered 5B/6B decoded value.
    check_disparity6a_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY6a == $past(P31 | (P22 & disparity)))
    );

// DISPARITY6a2 is the registered 5B/6B decoded value.
    check_disparity6a2_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY6a2 == $past(P31 & disparity))
    );

// DISPARITY6a0 is the registered 5B/6B decoded value.
    check_disparity6a0_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY6a0 == $past(P13 & !disparity))
    );

// DISPARITY6b is the registered 5B/6B decoded value.
    check_disparity6b_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (DISPARITY6b == $past((e & i & !DISPARITY6a0) | (DISPARITY6a & (e | i)) | DISPARITY6a2))
    );

// derr1 is the registered 5B/6B decoded value.
    check_derr1_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr1 == $past((disparity & DISPARITY6p) | (DISPARITY6n & !disparity)))
    );

// derr2 is the registered 5B/6B decoded value.
    check_derr2_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr2 == $past((disparity & !DISPARITY6n & f & g)))
    );

// derr3 is the registered 5B/6B decoded value.
    check_derr3_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr3 == $past((disparity & a & b & c)))
    );

// derr4 is the registered 5B/6B decoded value.
    check_derr4_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr4 == $past((disparity & !DISPARITY6n & DISPARITY4p)))
    );

// derr5 is the registered 5B/6B decoded value.
    check_derr5_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr5 == $past((!disparity & !DISPARITY6p & !f & !g)))
    );

// derr6 is the registered 5B/6B decoded value.
    check_derr6_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr6 == $past((!disparity & !a & !b & !c)))
    );

// derr7 is the registered 5B/6B decoded value.
    check_derr7_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr7 == $past((!disparity & !DISPARITY6p & DISPARITY4n)))
    );

// derr8 is the registered 5B/6B decoded value.
    check_derr8_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr8 == $past((DISPARITY6p & DISPARITY4p) | (DISPARITY6n & DISPARITY4n)))
    );

// derr12 is the registered 5B/6B decoded value.
    check_derr12_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr12 == $past(derr1 | derr2))
    );

// derr34 is the registered 5B/6B decoded value.
    check_derr34_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr34 == $past(derr3 | derr4))
    );

// derr56 is the registered 5B/6B decoded value.
    check_derr56_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr56 == $past(derr5 | derr6))
    );

// derr78 is the registered 5B/6B decoded value.
    check_derr78_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (derr78 == $past(derr7 | derr8))
    );

// zerr1 is the registered 5B/6B decoded value.
    check_zerr1_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (zerr1 == $past((DISPARITY6p & DISPARITY4p) | (DISPARITY6n & DISPARITY4n)))
    );

// zerr2 is the registered 5B/6B decoded value.
    check_zerr2_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (zerr2 == $past((f & g & !h & !j & DISPARITY6p)))
    );

// zerr3 is the registered 5B/6B decoded value.
    check_zerr3_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (zerr3 == $past((!f & !g & h & j