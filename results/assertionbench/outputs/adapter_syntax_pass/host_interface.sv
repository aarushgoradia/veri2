module host_interface_aes_sva (
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
    input logic [31:0] PRDATA,
    input logic [3:0] PADDR,
    input logic [12:0] PWDATA,
    input logic PWRITE,
    input logic PENABLE,
    input logic PSEL,
    input logic PCLK,
    input logic PRESETn,
    input logic [31:0] key_bus,
    input logic [31:0] col_bus,
    input logic [31:0] iv_bus,
    input logic ccf_set
);

    // PRDATA is always zero on the active clock edge.
    check_prdata_zero_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        PRDATA == 32'd0
    );

    // PRDATA is always zero on the active reset edge.
    check_prdata_zero_on_reset: assert property (
        @(negedge PRESETn)
        PRDATA == 32'd0
    );

    // PRDATA is zero on the first active clock after reset release.
    check_prdata_zero_after_reset_release: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        $rose(PRESETn) |-> (PRDATA == 32'd0)
    );

    // PRDATA is zero on the first active reset edge after reset release.
    check_prdata_zero_on_reset_release: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        $rose(PRESETn) |-> (PRDATA == 32'd0)
    );

    // col_addr is always zero on the active clock edge.
    check_col_addr_zero_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        col_addr == 2'd0
    );

    // col_addr is always zero on the active reset edge.
    check_col_addr_zero_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        col_addr == 2'd0
    );

    // col_wr_en is always low on the active clock edge.
    check_col_wr_en_low_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        col_wr_en == 1'b0
    );

    // col_wr_en is always low on the active reset edge.
    check_col_wr_en_low_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        col_wr_en == 1'b0
    );

    // col_rd_en is always low on the active clock edge.
    check_col_rd_en_low_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        col_rd_en == 1'b0
    );

    // col_rd_en is always low on the active reset edge.
    check_col_rd_en_low_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        col_rd_en == 1'b0
    );

    // dma_req_wr is always low on the active clock edge.
    check_dma_req_wr_low_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        dma_req_wr == 1'b0
    );

    // dma_req_wr is always low on the active reset edge.
    check_dma_req_wr_low_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        dma_req_wr == 1'b0
    );

    // dma_req_rd is always low on the active clock edge.
    check_dma_req_rd_low_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        dma_req_rd == 1'b0
    );

    // dma_req_rd is always low on the active reset edge.
    check_dma_req_rd_low_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        dma_req_rd == 1'b0
    );

    // int_ccf is always low on the active clock edge.
    check_int_ccf_low_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        int_ccf == 1'b0
    );

    // int_ccf is always low on the active reset edge.
    check_int_ccf_low_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        int_ccf == 1'b0
    );

    // int_err is always low on the active clock edge.
    check_int_err_low_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        int_err == 1'b0
    );

    // int_err is always low on the active reset edge.
    check_int_err_low_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        int_err == 1'b0
    );

    // disable_core is always high on the active clock edge.
    check_disable_core_high_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        disable_core == 1'b1
    );

    // disable_core is always high on the active reset edge.
    check_disable_core_high_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        disable_core == 1'b1
    );

    // start_core is always low on the active clock edge.
    check_start_core_low_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        start_core == 1'b0
    );

    // start_core is always low on the active reset edge.
    check_start_core_low_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        start_core == 1'b0
    );

    // first_block is always high on the active clock edge.
    check_first_block_high_on_clk: assert property (
        @(posedge PCLK) disable iff (!PRESETn)
        first_block == 1'b1
    );

    // first_block is always high on the active reset edge.
    check_first_block_high_on_reset: assert property (
        @(negedge PCLK) disable iff (!PRESETn)
        first_block == 1'b1
    );

endmodule