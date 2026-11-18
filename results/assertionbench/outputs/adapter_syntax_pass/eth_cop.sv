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

    localparam logic [1:0] IDLE = 2'b00;
    localparam logic [1:0] M1   = 2'b01;
    localparam logic [1:0] M2   = 2'b10;
    localparam logic [1:0] BOTH = 2'b11;

    logic [1:0] m1_state;
    logic [1:0] m2_state;
    logic [1:0] m1_next_state;
    logic [1:0] m2_next_state;

    assign m1_next_state = (m1_state == IDLE) ? M1 : (m1_state == M1) ? BOTH : IDLE;
    assign m2_next_state = (m2_state == IDLE) ? M2 : (m2_state == M2) ? BOTH : IDLE;

    // m1_state and m2_state must match the RTL state encoding.
    check_state_encoding: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m1_state == IDLE || m1_state == M1 || m1_state == M2 || m1_state == BOTH) &&
        (m2_state == IDLE || m2_state == M1 || m2_state == M2 || m2_state == BOTH)
    );

    // m1_state must follow the RTL next-state logic.
    check_m1_state_transition: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        1'b1 |=> (m1_state == m1_next_state)
    );

    // m2_state must follow the RTL next-state logic.
    check_m2_state_transition: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        1'b1 |=> (m2_state == m2_next_state)
    );

    // m1_in_progress is high only when m1_state is M1 or BOTH.
    check_m1_in_progress_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m1_in_progress == (m1_state == M1 || m1_state == BOTH))
    );

    // m2_in_progress is high only when m2_state is M2 or BOTH.
    check_m2_in_progress_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (m2_in_progress == (m2_state == M2 || m2_state == BOTH))
    );

    // m1_in_progress and m2_in_progress cannot be high together.
    check_in_progress_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(m1_in_progress && m2_in_progress)
    );

    // m1_in_progress and m2_in_progress cannot be low together.
    check_idle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(~m1_in_progress && ~m2_in_progress)
    );

    // m1_in_progress and m2_in_progress are never high when reset is asserted.
    check_in_progress_during_reset: assert property (
        @(posedge wb_clk_i)
        wb_rst_i |-> (!m1_in_progress && !m2_in_progress)
    );

    // m1_in_progress and m2_in_progress are never high when reset is asserted.
    check_idle_during_reset: assert property (
        @(posedge wb_clk_i)
        wb_rst_i |-> (!m1_in_progress && !m2_in_progress)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_cyc_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s1_wb_stb_o are high only when m1_state is M1 or BOTH.
    check_s1_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o) == (m1_state == M1 || m1_state == BOTH)
    );

    // s2_wb_cyc_o and s2_wb_stb_o are high only when m2_state is M2 or BOTH.
    check_s2_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o) == (m2_state == M2 || m2_state == BOTH)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s1_wb_stb_o are high only when m1_state is M1 or BOTH.
    check_s1_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o) == (m1_state == M1 || m1_state == BOTH)
    );

    // s2_wb_cyc_o and s2_wb_stb_o are high only when m2_state is M2 or BOTH.
    check_s2_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o) == (m2_state == M2 || m2_state == BOTH)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s1_wb_stb_o are high only when m1_state is M1 or BOTH.
    check_s1_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o) == (m1_state == M1 || m1_state == BOTH)
    );

    // s2_wb_cyc_o and s2_wb_stb_o are high only when m2_state is M2 or BOTH.
    check_s2_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o) == (m2_state == M2 || m2_state == BOTH)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s1_wb_stb_o are high only when m1_state is M1 or BOTH.
    check_s1_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o) == (m1_state == M1 || m1_state == BOTH)
    );

    // s2_wb_cyc_o and s2_wb_stb_o are high only when m2_state is M2 or BOTH.
    check_s2_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o) == (m2_state == M2 || m2_state == BOTH)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s1_wb_stb_o are high only when m1_state is M1 or BOTH.
    check_s1_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o) == (m1_state == M1 || m1_state == BOTH)
    );

    // s2_wb_cyc_o and s2_wb_stb_o are high only when m2_state is M2 or BOTH.
    check_s2_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o) == (m2_state == M2 || m2_state == BOTH)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s1_wb_stb_o are high only when m1_state is M1 or BOTH.
    check_s1_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s1_wb_cyc_o && s1_wb_stb_o) == (m1_state == M1 || m1_state == BOTH)
    );

    // s2_wb_cyc_o and s2_wb_stb_o are high only when m2_state is M2 or BOTH.
    check_s2_cycle_decode: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        (s2_wb_cyc_o && s2_wb_stb_o) == (m2_state == M2 || m2_state == BOTH)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_stb_o && s2_wb_stb_o)
    );

    // s1_wb_cyc_o and s2_wb_cyc_o are never high together.
    check_s1_s2_cycle_mutex: assert property (
        @(posedge wb_clk_i) disable iff (wb_rst_i)
        !(s1_wb_cyc_o && s2_wb_cyc_o)
    );

    // s1_wb_stb_o and s2_wb_stb_o are never high together.
    check_s1_s2_stb_mutex: assert property (
        @(posedge wb_clk_i) disable