module host_interface_aes_sva (
    input logic [31:0] key_bus,
    input logic [31:0] col_bus,
    input logic [31:0] iv_bus,
    input logic ccf_set,
    input logic [31:0] PRDATA,
    input logic [3:0] key_en,
    input logic [1:0] col_addr,
    input logic [1:0] chmod,
    input logic [1:0] mode,
    input logic [1:0] data_type,
    input logic col_wr_en,
    input logic col_rd_en,
    input logic [1:0] key_sel,
    input logic [3:0] iv_en,
    input logic [3:0] iv_sel,
    input logic int_ccf,
    input logic int_err,
    input logic disable_core,
    input logic first_block,
    input logic dma_req_wr,
    input logic dma_req_rd,
    input logic start_core,
    input logic [10:0] aes_cr,
    input logic wr_err,
    input logic rd_err,
    input logic ccf,
    input logic [2:0] state,
    input logic [1:0] cnt,
    input logic dma_req,
    input logic PCLK,
    input logic PRESETn
);

// AES_CR[0] is cleared on the next cycle when enable_clear is asserted.
    check_aes_cr_enable_clear: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        enable_clear |=> (aes_cr[0] == 1'b0)
    );

// AES_CR[0] is set on the next cycle when aes_cr_wr_en is asserted and access_permission is high.
    check_aes_cr_enable_set: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (aes_cr_wr_en && access_permission) |=> (aes_cr[0] == 1'b1)
    );

// AES_CR[2:1] is updated on the next cycle when aes_cr_wr_en is asserted and access_permission is high.
    check_aes_cr_data_type_update: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (aes_cr_wr_en && access_permission) |=> (aes_cr[2:1] == $past(PWDATA[2:1]))
    );

// AES_CR[4:3] is DECRYPTION when mode_in is DECRYP_W_DERIV and chmod_in is CTR.
    check_aes_cr_mode_decryption_ctr: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (aes_cr_wr_en && access_permission && (mode_in == DECRYP_W_DERIV) && (chmod_in == CTR)) |=> (aes_cr[4:3] == DECRYPTION)
    );

// AES_CR[4:3] is mode_in otherwise.
    check_aes_cr_mode_default: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (aes_cr_wr_en && access_permission && !(mode_in == DECRYP_W_DERIV && chmod_in == CTR)) |=> (aes_cr[4:3] == $past(mode_in))
    );

// AES_CR[6:5] is updated on the next cycle when aes_cr_wr_en is asserted and access_permission is high.
    check_aes_cr_chmod_update: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (aes_cr_wr_en && access_permission) |=> (aes_cr[6:5] == $past(PWDATA[6:5]))
    );

// AES_CR[10:7] is updated on the next cycle when aes_cr_wr_en is asserted.
    check_aes_cr_dma_update: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        aes_cr_wr_en |=> (aes_cr[10:7] == $past(PWDATA[12:9]))
    );

// WR_ERR is asserted on the next cycle when wr_err_en is asserted and errc is high.
    check_wr_err_assert: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (wr_err_en && errc) |=> (wr_err == 1'b1)
    );

// WR_ERR is cleared on the next cycle when wr_err_en is not asserted and errc is high.
    check_wr_err_deassert: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (!wr_err_en && errc) |=> (wr_err == 1'b0)
    );

// RD_ERR is asserted on the next cycle when rd_err_en is asserted and errc is high.
    check_rd_err_assert: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (rd_err_en && errc) |=> (rd_err == 1'b1)
    );

// RD_ERR is cleared on the next cycle when rd_err_en is not asserted and errc is high.
    check_rd_err_deassert: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (!rd_err_en && errc) |=> (rd_err == 1'b0)
    );

// CCF is asserted on the next cycle when ccf_set is asserted.
    check_ccf_assert: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        ccf_set |=> (ccf == 1'b1)
    );

// CCF is cleared on the next cycle when ccfc is high and aes_cr_wr_en is asserted.
    check_ccf_deassert: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (ccfc && aes_cr_wr_en) |=> (ccf == 1'b0)
    );

// INT_CCF is high when ccf_ie is high and ccf_set is asserted.
    check_int_ccf_high: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (ccf_ie && ccf_set) |-> (int_ccf == 1'b1)
    );

// INT_CCF is low when ccf_ie is low.
    check_int_ccf_low_when_ie_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !ccf_ie |-> (int_ccf == 1'b0)
    );

// INT_ERR is high when (wr_err_en or rd_err_en) is high and err_ie is high.
    check_int_err_high: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (err_ie && (wr_err_en || rd_err_en)) |-> (int_err == 1'b1)
    );

// INT_ERR is low when err_ie is low.
    check_int_err_low_when_ie_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !err_ie |-> (int_err == 1'b0)
    );

// KEY_EN is zero when PADDR[3:2] is not 00.
    check_key_en_zero_when_addr_not_00: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] != 2'b00) |-> (key_en == 4'b0000)
    );

// KEY_EN is 1000 when PADDR[3:2] is 00 and PADDR[1:0] is 00.
    check_key_en_1000_when_addr_0000: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b00 && PADDR[1:0] == 2'b00) |-> (key_en == 4'b1000)
    );

// KEY_EN is 0100 when PADDR[3:2] is 00 and PADDR[1:0] is 01.
    check_key_en_0100_when_addr_0001: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b00 && PADDR[1:0] == 2'b01) |-> (key_en == 4'b0100)
    );

// KEY_EN is 0010 when PADDR[3:2] is 00 and PADDR[1:0] is 10.
    check_key_en_0010_when_addr_0010: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b00 && PADDR[1:0] == 2'b10) |-> (key_en == 4'b0010)
    );

// KEY_EN is 0001 when PADDR[3:2] is 00 and PADDR[1:0] is 11.
    check_key_en_0001_when_addr_0011: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b00 && PADDR[1:0] == 2'b11) |-> (key_en == 4'b0001)
    );

// KEY_SEL is 00 when PADDR[1:0] is 00.
    check_key_sel_zero_when_addr_00: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[1:0] == 2'b00) |-> (key_sel == 2'b00)
    );

// KEY_SEL is 01 when PADDR[1:0] is 01.
    check_key_sel_one_when_addr_01: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[1:0] == 2'b01) |-> (key_sel == 2'b01)
    );

// IV_EN is zero when PADDR[3:2] is not 10.
    check_iv_en_zero_when_addr_not_10: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] != 2'b10) |-> (iv_en == 4'b0000)
    );

// IV_EN is 1000 when PADDR[3:2] is 10 and PADDR[1:0] is 00.
    check_iv_en_1000_when_addr_1000: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b10 && PADDR[1:0] == 2'b00) |-> (iv_en == 4'b1000)
    );

// IV_EN is 0100 when PADDR[3:2] is 10 and PADDR[1:0] is 01.
    check_iv_en_0100_when_addr_1001: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b10 && PADDR[1:0] == 2'b01) |-> (iv_en == 4'b0100)
    );

// IV_EN is 0010 when PADDR[3:2] is 10 and PADDR[1:0] is 10.
    check_iv_en_0010_when_addr_1010: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b10 && PADDR[1:0] == 2'b10) |-> (iv_en == 4'b0010)
    );

// IV_EN is 0001 when PADDR[3:2] is 10 and PADDR[1:0] is 11.
    check_iv_en_0001_when_addr_1011: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[3:2] == 2'b10 && PADDR[1:0] == 2'b11) |-> (iv_en == 4'b0001)
    );

// IV_SEL is 00 when PADDR[1:0] is 00.
    check_iv_sel_zero_when_addr_00: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[1:0] == 2'b00) |-> (iv_sel == 2'b00)
    );

// IV_SEL is 01 when PADDR[1:0] is 01.
    check_iv_sel_one_when_addr_01: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR[1:0] == 2'b01) |-> (iv_sel == 2'b01)
    );

// DMA_REQ_WR is high when dma_req is high, cnt[0] is low, dma_in_en is high, enable is high, and state is INPUT or IDLE.
    check_dma_req_wr_high: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (dma_req && !cnt[0] && dma_in_en && enable && (state == INPUT || state == IDLE)) |-> (dma_req_wr == 1'b1)
    );

// DMA_REQ_WR is low when dma_req is low.
    check_dma_req_wr_low_when_dma_req_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !dma_req |-> (dma_req_wr == 1'b0)
    );

// DMA_REQ_WR is low when cnt[0] is high.
    check_dma_req_wr_low_when_cnt0_high: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        cnt[0] |-> (dma_req_wr == 1'b0)
    );

// DMA_REQ_WR is low when dma_in_en is low.
    check_dma_req_wr_low_when_dma_in_en_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !dma_in_en |-> (dma_req_wr == 1'b0)
    );

// DMA_REQ_WR is low when enable is low.
    check_dma_req_wr_low_when_enable_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !enable |-> (dma_req_wr == 1'b0)
    );

// DMA_REQ_WR is low when state is not INPUT or IDLE.
    check_dma_req_wr_low_when_not_input_or_idle: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(state == INPUT || state == IDLE) |-> (dma_req_wr == 1'b0)
    );

// DMA_REQ_RD is high when dma_req is high, cnt[0] is low, dma_out_en is high, enable is high, and state is OUTPUT.
    check_dma_req_rd_high: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (dma_req && !cnt[0] && dma_out_en && enable && (state == OUTPUT)) |-> (dma_req_rd == 1'b1)
    );

// DMA_REQ_RD is low when dma_req is low.
    check_dma_req_rd_low_when_dma_req_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !dma_req |-> (dma_req_rd == 1'b0)
    );

// DMA_REQ_RD is low when cnt[0] is high.
    check_dma_req_rd_low_when_cnt0_high: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        cnt[0] |-> (dma_req_rd == 1'b0)
    );

// DMA_REQ_RD is low when dma_out_en is low.
    check_dma_req_rd_low_when_dma_out_en_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !dma_out_en |-> (dma_req_rd == 1'b0)
    );

// DMA_REQ_RD is low when enable is low.
    check_dma_req_rd_low_when_enable_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !enable |-> (dma_req_rd == 1'b0)
    );

// DMA_REQ_RD is low when state is not OUTPUT.
    check_dma_req_rd_low_when_not_output: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !(state == OUTPUT) |-> (dma_req_rd == 1'b0)
    );

// PRDATA is zero when read_en is low.
    check_prdata_zero_when_read_en_low: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        !read_en |-> (PRDATA == 32'h0)
    );

// PRDATA[31:16] is zero for all address values.
    check_prdata_upper_zero: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PRDATA[31:16] == 16'h0)
    );

// PRDATA[15:12] is zero for all address values.
    check_prdata_middle_zero: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PRDATA[15:12] == 4'h0)
    );

// PRDATA[11:10] is zero for all address values.
    check_prdata_low_two_zero: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PRDATA[11:10] == 2'b00)
    );

// PRDATA[9:8] matches aes_cr[10:9] for AES_CR.
    check_prdata_cr_dma: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR == AES_CR) |-> (PRDATA[9:8] == aes_cr[10:9])
    );

// PRDATA[7:6] matches aes_cr[6:5] for AES_CR.
    check_prdata_cr_chmod: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        (PADDR == AES_CR) |-> (PRDATA[7:6] == aes_cr[6:5])
    );

// PRDATA[5:4] matches aes_cr[4:3] for AES_CR.
    check_prdata_cr_mode: assert property (
        @(posedge PCLK) disable iff (!PRESETn