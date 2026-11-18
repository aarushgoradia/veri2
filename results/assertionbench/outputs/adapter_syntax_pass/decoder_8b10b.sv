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

    // K_out is the registered K bit from the previous cycle.
    check_k_out_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (K_out == $past(tbi[4]))
    );

    // ebi is the registered 8-bit decoded bus from the previous cycle.
    check_ebi_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (ebi == $past({tbi[7], tbi[6], tbi[5], tbi[4], tbi[3], tbi[2], tbi[1], tbi[0]}))
    );

    // coding_err is the registered OR of all coding error terms from the previous cycle.
    check_coding_err_registered: assert property (
        @(posedge RBYTECLK) disable iff (reset)
        1'b1 |=> (coding_err == $past(
            (tbi[9] & tbi[8] & tbi[7] & tbi[6]) |
            (!tbi[9] & !tbi[8] & !tbi[7] & !tbi[6]) |
            (tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0]) |
            (!tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) |
            (tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0] & tbi[7] & tbi[6]) |
            (!tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0] & !tbi[7] & !tbi[6]) |
            ((tbi[4] & tbi[3] & !tbi[2] & !tbi[1] & !tbi[0] & tbi[7] & tbi[6]) |
             (!tbi[4] & !tbi[3] & tbi[2] & tbi[1] & tbi[0] & !tbi[7] & !tbi[6])) &
             (!((tbi[9] & tbi[8] & tbi[4]) | (!tbi[9] & !tbi[8] & !tbi[4])))) |
            ((!tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0] & tbi[7] & tbi[6]) &
             (!((tbi[9] & tbi[8] & tbi[4]) | (!tbi[9] & !tbi[8] & !tbi[4])))) |
            ((tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0] & tbi[7] & tbi[6]) &
             (!((tbi[9] & tbi[8] & tbi[4]) | (!tbi[9] & !tbi[8] & !tbi[4])))) |
            ((!tbi[4] & !tbi[3] & tbi[2] & tbi[1] & tbi[0] & !tbi[7] & !tbi[6]) &
             (!((tbi[9] & tbi[8] & tbi[4]) | (!tbi[9] & !tbi[8] & !tbi[4])))) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[7] & tbi[6]) |
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[7] & !tbi[6])) |
            ((tbi[9] & tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & tbi[7] & tbi[6]) |
             (!tbi[9] & !tbi[8] & tbi[4] & tbi[3] & tbi[2] & !tbi[7] & !tbi[6])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & !tbi[2] & !tbi[1] & !tbi[0]) |
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & tbi[2] & tbi[1] & tbi[0])) |
            ((tbi[9] & tbi[8] & !tbi[4] & !tbi[3] & tbi[2] & tbi[1] & tbi[0]) |
             (!tbi[9] & !tbi[8] & tbi[4] & tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0]) |
             (!tbi[9] & !tbi[8] & !tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) |
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9] & tbi[8] & tbi[4] & tbi[3] & tbi[2] & tbi[1] & tbi[0]) &
             (!tbi[9] & !tbi[8] & !tbi[4] & !tbi[3] & !tbi[2] & !tbi[1] & !tbi[0])) |
            ((tbi[9