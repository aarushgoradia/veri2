module eth_cop_sva (
    input logic        wb_clk_i,
    input logic        wb_rst_i,
    input logic [31:0] m1_wb_adr_i,
    input logic [3:0]  m1_wb_sel_i,
    input logic        m1_wb_we_i,
    input logic [31:0] m1_wb_dat_o,
    input logic [31:0] m1_wb_dat_i,
    input logic        m1_wb_cyc_i,
    input logic        m1_wb_stb_i,
    input logic        m1_wb_ack_o,
    input logic        m1_wb_err_o,
    input logic [31:0] m2_wb_adr_i,
    input logic [3:0]  m2_wb_sel_i,
    input logic        m2_wb_we_i,
    input logic [31:0] m2_wb_dat_o,
    input logic [31:0] m2_wb_dat_i,
    input logic        m2_wb_cyc_i,
    input logic        m2_wb_stb_i,
    input logic        m2_wb_ack_o,
    input logic        m2_wb_err_o,
    input logic [31:0] s1_wb_adr_o,
    input logic [3:0]  s1_wb_sel_o,
    input logic        s1_wb_we_o,
    input logic [31:0] s1_wb_dat_o,
    input logic        s1_wb_cyc_o,
    input logic        s1_wb_stb_o,
    input logic [31:0] s2_wb_adr_o,
    input logic [3:0]  s2_wb_sel_o,
    input logic        s2_wb_we_o,
    input logic [31:0] s2_wb_dat_o,
    input logic        s2_wb_cyc_o,
    input logic        s2_wb_stb_o
);

    localparam logic [31:0] ETH_BASE     = 32'hd0000000;
    localparam logic [31:0] ETH_WIDTH    = 32'h800;
    localparam logic [31:0] MEMORY_BASE  = 32'h2000;
    localparam logic [31:0] MEMORY_WIDTH = 32'h10000;

    // Reset clears all registered outputs.
    check_reset_clears_outputs: assert property (
        @(posedge wb_clk_i) wb_rst_i |-> (
            (m1_wb_ack_o == 1'b0) &&
            (m1_wb_err_o == 1'b0) &&
            (m2_wb_ack_o == 1'b0) &&
            (m2_wb_err_o == 1'b0) &&
            (s1_wb_adr_o == 32'h00000000) &&
            (s1_wb_sel_o == 4'h0) &&
            (s1_wb_we_o == 1'b0) &&
            (s1_wb_dat_o == 32'h00000000) &&
            (s1_wb_cyc_o == 1'b0) &&
            (s1_wb_stb_o == 1'b0) &&
            (s2_wb_adr_o == 32'h00000000) &&
            (s2_wb_sel_o == 4'h0) &&
            (s2_wb_we_o == 1'b0) &&
            (s2_wb_dat_o == 32'h00000000) &&
            (s2_wb_cyc_o == 1'b0) &&
            (s2_wb_stb_o == 1'b0)
        )
    );

    // A slave ACK or error drives the corresponding master ACK or error.
    check_master_ack_or_err_from_slave: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b0) && (m1_wb_err_o == 1'b0) &&
         (m2_wb_ack_o == 1'b0) && (m2_wb_err_o == 1'b0) &&
         (s1_wb_ack_i == 1'b1) && (s2_wb_ack_i == 1'b1) &&
         (s1_wb_err_i == 1'b1) && (s2_wb_err_i == 1'b1))
        |-> ((m1_wb_ack_o == 1'b1) && (m1_wb_err_o == 1'b0) &&
             (m2_wb_ack_o == 1'b1) && (m2_wb_err_o == 1'b0))
    );

    // A slave ACK or error drives the corresponding master ACK or error.
    check_master_ack_or_err_from_slave: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b0) && (m1_wb_err_o == 1'b0) &&
         (m2_wb_ack_o == 1'b0) && (m2_wb_err_o == 1'b0) &&
         (s1_wb_ack_i == 1'b1) && (s2_wb_ack_i == 1'b1) &&
         (s1_wb_err_i == 1'b1) && (s2_wb_err_i == 1'b1))
        |-> ((m1_wb_ack_o == 1'b1) && (m1_wb_err_o == 1'b0) &&
             (m2_wb_ack_o == 1'b1) && (m2_wb_err_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave cycle.
    check_slave_cycle_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_cyc_o == 1'b0) && (s1_wb_stb_o == 1'b0) &&
             (s2_wb_cyc_o == 1'b0) && (s2_wb_stb_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave cycle.
    check_slave_cycle_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_cyc_o == 1'b0) && (s1_wb_stb_o == 1'b0) &&
             (s2_wb_cyc_o == 1'b0) && (s2_wb_stb_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave data.
    check_slave_data_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_dat_o == 32'h00000000) &&
             (s2_wb_dat_o == 32'h00000000))
    );

    // A master ACK or error clears the corresponding slave select.
    check_slave_select_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_sel_o == 4'h0) &&
             (s2_wb_sel_o == 4'h0))
    );

    // A master ACK or error clears the corresponding slave write enable.
    check_slave_write_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_we_o == 1'b0) &&
             (s2_wb_we_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave address.
    check_slave_address_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_adr_o == 32'h00000000) &&
             (s2_wb_adr_o == 32'h00000000))
    );

    // A master ACK or error clears the corresponding slave cycle.
    check_slave_cycle_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_cyc_o == 1'b0) && (s1_wb_stb_o == 1'b0) &&
             (s2_wb_cyc_o == 1'b0) && (s2_wb_stb_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave data.
    check_slave_data_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_dat_o == 32'h00000000) &&
             (s2_wb_dat_o == 32'h00000000))
    );

    // A master ACK or error clears the corresponding slave select.
    check_slave_select_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_sel_o == 4'h0) &&
             (s2_wb_sel_o == 4'h0))
    );

    // A master ACK or error clears the corresponding slave write enable.
    check_slave_write_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_we_o == 1'b0) &&
             (s2_wb_we_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave address.
    check_slave_address_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_adr_o == 32'h00000000) &&
             (s2_wb_adr_o == 32'h00000000))
    );

    // A master ACK or error clears the corresponding slave cycle.
    check_slave_cycle_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_cyc_o == 1'b0) && (s1_wb_stb_o == 1'b0) &&
             (s2_wb_cyc_o == 1'b0) && (s2_wb_stb_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave data.
    check_slave_data_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_dat_o == 32'h00000000) &&
             (s2_wb_dat_o == 32'h00000000))
    );

    // A master ACK or error clears the corresponding slave select.
    check_slave_select_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_sel_o == 4'h0) &&
             (s2_wb_sel_o == 4'h0))
    );

    // A master ACK or error clears the corresponding slave write enable.
    check_slave_write_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_we_o == 1'b0) &&
             (s2_wb_we_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave address.
    check_slave_address_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_adr_o == 32'h00000000) &&
             (s2_wb_adr_o == 32'h00000000))
    );

    // A master ACK or error clears the corresponding slave cycle.
    check_slave_cycle_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_cyc_o == 1'b0) && (s1_wb_stb_o == 1'b0) &&
             (s2_wb_cyc_o == 1'b0) && (s2_wb_stb_o == 1'b0))
    );

    // A master ACK or error clears the corresponding slave data.
    check_slave_data_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_dat_o == 32'h00000000) &&
             (s2_wb_dat_o == 32'h00000000))
    );

    // A master ACK or error clears the corresponding slave select.
    check_slave_select_clears_on_master_ack_or_err: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        ((m1_wb_ack_o == 1'b1) || (m1_wb_err_o == 1'b1) ||
         (m2_wb_ack_o == 1'b1) || (m2_wb_err_o == 1'b1))
        |-> ((s1_wb_sel_o == 4'h0) &&
            