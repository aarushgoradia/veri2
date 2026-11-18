```systemverilog
module aes_key_expander_sva (
    input logic CLK,
    input logic RESETn,
    input logic [31:0] g_out,
    input logic [127:0] key_in,
    input logic [3:0] round,
    input logic add_w_out,
    input logic enc_dec,
    output logic [127:0] key_out,
    output logic [31:0] g_in
);

    // Key Generation
    generate
        genvar i;
        for(i = 0; i < 4; i = i + 1)
        begin:KG
            assign key_out[127 - 32*i : 96 - 32*i] = key_in[127 - 32*i : 96 - 32*i];
        end
    endgenerate

    // Key Out Generation
    generate
        genvar j;
        for(j = 0; j < 4; j = j + 1)
        begin:KGO
            if(j == 0)
                assign key_out[127 - 32*j : 96 - 32*j] = key_in[127 - 32*j : 96 - 32*j] ^ g_out[127 - 32*j : 96 - 32*j];
            else
                if(j == 1)
                    assign key_out[127 - 32*j : 96 - 32*j] = (add_w_out) ? key_in[127 - 32*j : 96 - 32*j] ^ key_in[127 - 64*j : 96 - 64*j] ^ g_out[127 - 32*j : 96 - 32*j] : key_in[127 - 32*j : 96 - 32*j] ^ key_in[127 - 64*j : 96 - 64*j];
                else
                    assign key_out[127 - 32*j : 96 - 32*j] = key_in[127 - 32*j : 96 - 32*j] ^ key_in[127 - 64*j : 96 - 64*j];
        end
    endgenerate

    // G Function Input Generation
    generate
        genvar k;
        for(k = 0; k < 4; k = k + 1)
        begin:GFIG
            assign g_in[31 - 8*k : 24 - 8*k] = (enc_dec) ? key_in[31 - 8*k : 24 - 8*k] : key_in[31 - 8*k : 24 - 8*k] ^ key_in[31 - 16*k : 24 - 16*k];
        end
    endgenerate

    generate
        genvar l;
        for(l = 0; l < 4; l = l + 1)
        begin:GFIG1
            assign g_in[31 - 8*l : 24 - 8*l] = g_in[31 - 8*l : 24 - 8*l] ^ key_in[31 - 8*l : 24 - 8*l];
        end
    endgenerate

    // G Function Output Processing
    assign g_out[127 - 32 : 96] = {g_out[127 - 32 : 96], g_out[63 : 32]};
    assign g_out[63 : 32] = {g_out[63 : 32], g_out[31 : 0]};

    // RC Generation
    logic [7:0] rc_dir, rc_inv;
    always @(*) begin
        if(round == 8)
            rc_dir = 8'h1b;
        else if(round == 9)
            rc_dir = 8'h36;
        else
            rc_dir = 8'h01 << round;
    end

    always @(*) begin
        if(round == 1)
            rc_inv = 8'h1b;
        else if(round == 0)
            rc_inv = 8'h36;
        else
            rc_inv = 8'h80 >> (round - 2);
    end

    // Assertions
    // RC_DIR and RC_INV are correctly generated based on the round
    rc_dir_gen: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 8) |-> (rc_dir == 8'h1b)
    );
    rc_dir_gen_9: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 9) |-> (rc_dir == 8'h36)
    );
    rc_dir_gen_other: assert property (
        @(posedge CLK) disable iff (!RESETn) (round != 8 && round != 9) |-> (rc_dir == 8'h01 << round)
    );
    rc_inv_gen: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 1) |-> (rc_inv == 8'h1b)
    );
    rc_inv_gen_0: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 0) |-> (rc_inv == 8'h36)
    );
    rc_inv_gen_other: assert property (
        @(posedge CLK) disable iff (!RESETn) (round != 1 && round != 0) |-> (rc_inv == 8'h80 >> (round - 2))
    );

    // Key Out Generation is correct
    key_out_gen: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 0) |-> (key_out[127:96] == key_in[127:96] ^ g_out[127:96])
    );
    key_out_gen_add_w_out: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 1 && add_w_out) |-> (key_out[127:96] == key_in[127:96] ^ key_in[63:32] ^ g_out[127:96])
    );
    key_out_gen_no_add_w_out: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 1 && !add_w_out) |-> (key_out[127:96] == key_in[127:96] ^ key_in[63:32])
    );

    // G Function Input Generation is correct
    g_in_gen: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 0) |-> (g_in[31:24] == key_in[31:24] ^ key_in[31:24])
    );
    g_in_gen_enc_dec: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 1 && enc_dec) |-> (g_in[31:24] == key_in[31:24] ^ key_in[31:24])
    );
    g_in_gen_no_enc_dec: assert property (
        @(posedge CLK) disable iff (!RESETn) (round == 1 && !enc_dec) |-> (g_in[31:24] == key_in[31:24] ^ key_in[31:24])
    );

endmodule
```