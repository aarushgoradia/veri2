module eth_cop_sva (
    input logic        wb_clk_i,
    input logic        wb_rst_i,
    input logic [31:0] m1_wb_adr_i,
    input logic [3:0]  m1_wb_sel_i,
    input logic        m1_wb_we_i,
    input logic [31:0] m1_wb_dat_i,
    input logic        m1_wb_cyc_i,
    input logic        m1_wb_stb_i,
    input logic [31:0] m1_wb_dat_o,
    input logic        m1_wb_ack_o,
    input logic        m1_wb_err_o,
    input logic [31:0] m2_wb_adr_i,
    input logic [3:0]  m2_wb_sel_i,
    input logic        m2_wb_we_i,
    input logic [31:0] m2_wb_dat_i,
    input logic        m2_wb_cyc_i,
    input logic        m2_wb_stb_i,
    input logic [31:0] m2_wb_dat_o,
    input logic        m2_wb_ack_o,
    input logic        m2_wb_err_o,
    input logic [31:0] s1_wb_adr_o,
    input logic [3:0]  s1_wb_sel_o,
    input logic        s1_wb_we_o,
    input logic [31:0] s1_wb_dat_o,
    input logic        s1_wb_cyc_o,
    input logic        s1_wb_stb_o,
    input logic [31:0] s1_wb_dat_i,
    input logic        s1_wb_ack_i,
    input logic        s1_wb_err_i,
    input logic [31:0] s2_wb_adr_o,
    input logic [3:0]  s2_wb_sel_o,
    input logic        s2_wb_we_o,
    input logic [31:0] s2_wb_dat_o,
    input logic        s2_wb_cyc_o,
    input logic        s2_wb_stb_o,
    input logic [31:0] s2_wb_dat_i,
    input logic        s2_wb_ack_i,
    input logic        s2_wb_err_i
);

// Reset clears all in-progress flags and outputs.
    check_reset_clears_progress: assert property (
        @(posedge wb_clk_i) wb_rst_i |-> (m1_in_progress == 1'b0) &&
                                        (m2_in_progress == 1'b0) &&
                                        (s1_wb_cyc_o == 1'b0) &&
                                        (s1_wb_stb_o == 1'b0) &&
                                        (s2_wb_cyc_o == 1'b0) &&
                                        (s2_wb_stb_o == 1'b0)
    );

// A master 1 request to s1 starts s1 arbitration and cycles.
    check_m1_s1_request_starts_s1_cycle: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m1_wb_cyc_i && m1_wb_stb_i && m1_addressed_s1) |=> (s1_wb_cyc_o == 1'b1) &&
                                                         (s1_wb_stb_o == 1'b1) &&
                                                         (s2_wb_cyc_o == 1'b0) &&
                                                         (s2_wb_stb_o == 1'b0)
    );

// A master 1 request to s2 starts s2 arbitration and cycles.
    check_m1_s2_request_starts_s2_cycle: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m1_wb_cyc_i && m1_wb_stb_i && m1_addressed_s2) |=> (s2_wb_cyc_o == 1'b1) &&
                                                         (s2_wb_stb_o == 1'b1) &&
                                                         (s1_wb_cyc_o == 1'b0) &&
                                                         (s1_wb_stb_o == 1'b0)
    );

// A master 2 request to s1 starts s1 arbitration and cycles.
    check_m2_s1_request_starts_s1_cycle: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m2_wb_cyc_i && m2_wb_stb_i && m2_addressed_s1) |=> (s1_wb_cyc_o == 1'b1) &&
                                                         (s1_wb_stb_o == 1'b1) &&
                                                         (s2_wb_cyc_o == 1'b0) &&
                                                         (s2_wb_stb_o == 1'b0)
    );

// A master 2 request to s2 starts s2 arbitration and cycles.
    check_m2_s2_request_starts_s2_cycle: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m2_wb_cyc_i && m2_wb_stb_i && m2_addressed_s2) |=> (s2_wb_cyc_o == 1'b1) &&
                                                         (s2_wb_stb_o == 1'b1) &&
                                                         (s1_wb_cyc_o == 1'b0) &&
                                                         (s1_wb_stb_o == 1'b0)
    );

// A master 1 request to an unmapped address generates an error.
    check_m1_unmapped_request_generates_error: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m1_wb_cyc_i && m1_wb_stb_i && !m1_addressed_s1 && !m1_addressed_s2) |=> (m1_wb_err_o == 1'b1) &&
                                                                             (s1_wb_cyc_o == 1'b0) &&
                                                                             (s1_wb_stb_o == 1'b0) &&
                                                                             (s2_wb_cyc_o == 1'b0) &&
                                                                             (s2_wb_stb_o == 1'b0)
    );

// A master 2 request to an unmapped address generates an error.
    check_m2_unmapped_request_generates_error: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m2_wb_cyc_i && m2_wb_stb_i && !m2_addressed_s1 && !m2_addressed_s2) |=> (m2_wb_err_o == 1'b1) &&
                                                                             (s1_wb_cyc_o == 1'b0) &&
                                                                             (s1_wb_stb_o == 1'b0) &&
                                                                             (s2_wb_cyc_o == 1'b0) &&
                                                                             (s2_wb_stb_o == 1'b0)
    );

// A completed s1 cycle clears s1 cycle and stb.
    check_s1_cycle_completion_clears_s1_cycle: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o && s1_wb_ack_i) |=> (s1_wb_cyc_o == 1'b0) &&
                                                        (s1_wb_stb_o == 1'b0)
    );

// A completed s2 cycle clears s2 cycle and stb.
    check_s2_cycle_completion_clears_s2_cycle: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o && s2_wb_ack_i) |=> (s2_wb_cyc_o == 1'b0) &&
                                                        (s2_wb_stb_o == 1'b0)
    );

// A completed s1 cycle clears m1 ack and data.
    check_s1_cycle_completion_clears_m1_ack: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o && s1_wb_ack_i) |=> (m1_wb_ack_o == 1'b0) &&
                                                        (m1_wb_dat_o == 32'h0)
    );

// A completed s2 cycle clears m2 ack and data.
    check_s2_cycle_completion_clears_m2_ack: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o && s2_wb_ack_i) |=> (m2_wb_ack_o == 1'b0) &&
                                                        (m2_wb_dat_o == 32'h0)
    );

// A completed s1 cycle clears m1 error.
    check_s1_cycle_completion_clears_m1_error: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o && s1_wb_ack_i) |=> (m1_wb_err_o == 1'b0)
    );

// A completed s2 cycle clears m2 error.
    check_s2_cycle_completion_clears_m2_error: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o && s2_wb_ack_i) |=> (m2_wb_err_o == 1'b0)
    );

endmodule
