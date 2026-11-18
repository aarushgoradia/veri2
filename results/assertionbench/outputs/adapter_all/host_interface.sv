module host_interface_aes_sva (
    input logic [3:0]  key_en,
    input logic [1:0]  col_addr,
    input logic [1:0]  chmod,
    input logic [1:0]  mode,
    input logic [1:0]  data_type,
    input logic        col_wr_en,
    input logic        col_rd_en,
    input logic [1:0]  key_sel,
    input logic [3:0]  iv_en,
    input logic        int_ccf,
    input logic        int_err,
    input logic        disable_core,
    input logic        first_block,
    input logic        dma_req_wr,
    input logic        dma_req_rd,
    input logic        start_core,
    input logic [31:0] PRDATA,
    input logic [3:0]  PADDR,
    input logic [12:0] PWDATA,
    input logic        PWRITE,
    input logic        PENABLE,
    input logic        PSEL,
    input logic        PCLK,
    input logic        PRESETn,
    input logic [31:0] key_bus,
    input logic [31:0] col_bus,
    input logic [31:0] iv_bus,
    input logic        ccf_set
);
    ///// Reset behavior /////
    // During reset, disable_core must be HIGH.
    reset_disable_core_high: assert property (
        @(posedge PCLK) !PRESETn |-> disable_core
    );
    // During reset, PRDATA must be zero.
    reset_prdata_zero: assert property (
        @(posedge PCLK) !PRESETn |-> (PRDATA == 32'h0)
    );

    ///// Key/IV select and enable /////
    // key_en is a one-hot decode of PADDR[1:0] masked by PADDR[2]&~PADDR[3].
    check_key_en_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            key_en == ((4'b1000 >> PADDR[1:0]) & {4{(~PADDR[3] & PADDR[2])}})
    );
    // key_sel is the inverse of PADDR[1:0] masked by PADDR[2]&~PADDR[3].
    check_key_sel_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            key_sel == (~PADDR[1:0]) & {2{(PADDR[2] & ~PADDR[3])}}
    );
    // iv_en is a one-hot decode of PADDR[1:0] masked by PADDR[3]&~PADDR[2].
    check_iv_en_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            iv_en == ((4'b1000 >> PADDR[1:0]) & {4{(PADDR[3] & ~PADDR[2])}})
    );

    ///// DMA request behavior /////
    // dma_req_wr is the XOR of dma_req and cnt[0] gated by dma_in_en, enable, and state==INPUT/IDLE.
    check_dma_req_wr_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            dma_req_wr == ((dma_req ^ cnt[0]) & dma_in_en & enable & (state == INPUT || state == IDLE))
    );
    // dma_req_rd is the XOR of dma_req and cnt[0] gated by dma_out_en, enable, and state==OUTPUT.
    check_dma_req_rd_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            dma_req_rd == ((dma_req ^ cnt[0]) & dma_out_en & enable & (state == OUTPUT))
    );
    // dma_req is the LSB of cnt.
    check_dma_req_follows_cnt_lsb: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            dma_req == cnt[0]
    );

    ///// PRDATA decode /////
    // For AES_CR, PRDATA[10:7] reflects aes_cr[10:7], bits[6:0] are zero.
    check_prdata_cr_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (PADDR == 4'd0) |-> (PRDATA[31:7] == 25'h0 && PRDATA[6:0] == aes_cr[10:7])
    );
    // For AES_SR, PRDATA[29:0] reflects {wr_err, rd_err, ccf_set?1:ccf}.
    check_prdata_sr_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (PADDR == 4'd1) |-> (PRDATA[31:3] == 29'h0 && PRDATA[2] == ccf_set && PRDATA[1:0] == (ccf_set ? 2'b10 : (ccf ? 2'b01 : 2'b00)))
    );
    // For AES_DOUTR with ccf_set or ccf, PRDATA reflects col_bus.
    check_prdata_doutr_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            (PADDR == 4'd3 && (ccf_set || ccf)) |-> (PRDATA == col_bus)
    );
    // For AES_KEYR0..AES_KEYR3, PRDATA reflects key_bus when enable is LOW.
    check_prdata_key_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            ((PADDR == 4'd4 || PADDR == 4'd5 || PADDR == 4'd6 || PADDR == 4'd7) && !enable) |-> (PRDATA == key_bus)
    );
    // For AES_IVR0..AES_IVR3, PRDATA reflects iv_bus when enable is LOW.
    check_prdata_iv_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            ((PADDR == 4'd8 || PADDR == 4'd9 || PADDR == 4'd10 || PADDR == 4'd11) && !enable) |-> (PRDATA == iv_bus)
    );
    // For all other addresses, PRDATA is zero.
    check_prdata_default_zero: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            !(PADDR == 4'd0 || PADDR == 4'd1 || PADDR == 4'd3 || (PADDR >= 4'd4 && PADDR <= 4'd7) || (PADDR >= 4'd8 && PADDR <= 4'd11))
            |-> (PRDATA == 32'h0)
    );

    ///// Interrupts /////
    // int_ccf is asserted when ccf_ie and ccf_set are HIGH.
    check_int_ccf_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            int_ccf == (ccf_ie && ccf_set)
    );
    // int_err is asserted when (wr_err_en or rd_err_en) and err_ie are HIGH.
    check_int_err_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            int_err == ((wr_err_en || rd_err_en) && err_ie)
    );

    ///// Combinational decode of aes_cr bits /////
    // chmod reflects aes_cr[6:5].
    check_chmod_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            chmod == aes_cr[6:5]
    );
    // mode reflects aes_cr[4:3].
    check_mode_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            mode == aes_cr[4:3]
    );
    // data_type reflects aes_cr[2:1].
    check_data_type_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            data_type == aes_cr[2:1]
    );
    // col_addr reflects cnt.
    check_col_addr_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            col_addr == cnt
    );

    ///// Combinational decode of state and enable /////
    // disable_core is the inverse of aes_cr[0].
    check_disable_core_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            disable_core == ~aes_cr[0]
    );
    // start_core is asserted only in state START.
    check_start_core_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            start_core == (state == 3'd2)
    );
    // first_block_set is asserted only in state IDLE when enable is HIGH and mode!=KEY_DERIVATION.
    check_first_block_set_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            first_block_set == (state == 3'd0 && enable && (mode != 2'b01))
    );
    // first_block_clear is asserted only in state OUTPUT when enable is HIGH.
    check_first_block_clear_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            first_block_clear == (state == 3'd4 && enable)
    );
    // col_wr_en is asserted only in state INPUT when PADDR==AES_DINR, write_en, and cnt_en.
    check_col_wr_en_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            col_wr_en == (state == 3'd1 && PADDR == 4'd2 && write_en && cnt_en)
    );
    // col_rd_en is asserted only in state OUTPUT when PADDR==AES_DOUTR, read_en, and cnt_en.
    check_col_rd_en_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            col_rd_en == (state == 3'd4 && PADDR == 4'd3 && read_en && cnt_en)
    );
    // cnt_en is asserted in INPUT when PADDR==AES_DINR and write_en; in OUTPUT when PADDR==AES_DOUTR and read_en; in START when ccf_set; in WAIT when ccf_set and mode!=KEY_DERIVATION; else 0.
    check_cnt_en_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            cnt_en == (
                (state == 3'd1 && PADDR == 4'd2 && write_en) ||
                (state == 3'd4 && PADDR == 4'd3 && read_en && PENABLE) ||
                (state == 3'd2 && ccf_set) ||
                (state == 3'd3 && ccf_set && (mode != 2'b01))
            )
    );
    // dma_req is the LSB of cnt.
    check_dma_req_decode: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
            dma_req == cnt[0]
    );
endmodule