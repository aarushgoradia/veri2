```systemverilog
module eth_cop_sva (
    input logic wb_clk_i,
    input logic wb_rst_i,
    input logic [31:0] m1_wb_adr_i,
    input logic [3:0] m1_wb_sel_i,
    input logic m1_wb_we_i,
    input logic [31:0] m1_wb_dat_i,
    input logic m1_wb_cyc_i,
    input logic m1_wb_stb_i,
    output logic [31:0] m1_wb_dat_o,
    output logic m1_wb_ack_o,
    output logic m1_wb_err_o,
    input logic [31:0] m2_wb_adr_i,
    input logic [3:0] m2_wb_sel_i,
    input logic m2_wb_we_i,
    input logic [31:0] m2_wb_dat_i,
    input logic m2_wb_cyc_i,
    input logic m2_wb_stb_i,
    output logic [31:0] m2_wb_dat_o,
    output logic m2_wb_ack_o,
    output logic m2_wb_err_o,
    input logic [31:0] s1_wb_dat_i,
    input logic s1_wb_ack_i,
    input logic s1_wb_err_i,
    output logic [31:0] s1_wb_adr_o,
    output logic [31:0] s1_wb_dat_o,
    output logic [3:0] s1_wb_sel_o,
    output logic s1_wb_we_o,
    output logic s1_wb_cyc_o,
    output logic s1_wb_stb_o,
    input logic [31:0] s2_wb_dat_i,
    input logic s2_wb_ack_i,
    input logic s2_wb_err_i,
    output logic [31:0] s2_wb_adr_o,
    output logic [31:0] s2_wb_dat_o,
    output logic [3:0] s2_wb_sel_o,
    output logic s2_wb_we_o,
    output logic s2_wb_cyc_o,
    output logic s2_wb_stb_o
);
    // WISHBONE master 1 address space
    localparam ETH_BASE = 32'hd0000000;
    localparam ETH_WIDTH = 32'h800;
    localparam MEMORY_BASE = 32'h2000;
    localparam MEMORY_WIDTH = 32'h10000;

    // WISHBONE master 1 address range checks
    wire m1_addressed_s1 = (m1_wb_adr_i >= ETH_BASE) & (m1_wb_adr_i < (ETH_BASE + ETH_WIDTH));
    wire m1_addressed_s2 = (m1_wb_adr_i >= MEMORY_BASE) & (m1_wb_adr_i < (MEMORY_BASE + MEMORY_WIDTH));

    // WISHBONE master 2 address range checks
    wire m2_addressed_s1 = (m2_wb_adr_i >= ETH_BASE) & (m2_wb_adr_i < (ETH_BASE + ETH_WIDTH));
    wire m2_addressed_s2 = (m2_wb_adr_i >= MEMORY_BASE) & (m2_wb_adr_i < (MEMORY_BASE + MEMORY_WIDTH));

    // WISHBONE master 1 request signal
    wire m1_req = m1_wb_cyc_i & m1_wb_stb_i & (m1_addressed_s1 | m1_addressed_s2);

    // WISHBONE master 2 request signal
    wire m2_req = m2_wb_cyc_i & m2_wb_stb_i & (m2_addressed_s1 | m2_addressed_s2);

    // WISHBONE master 1 in progress
    reg m1_in_progress;

    // WISHBONE master 2 in progress
    reg m2_in_progress;

    // WISHBONE slave 1 address and data
    reg [31:0] s1_wb_adr_o;
    reg [3:0] s1_wb_sel_o;
    reg s1_wb_we_o;
    reg [31:0] s1_wb_dat_o;
    reg s1_wb_cyc_o;
    reg s1_wb_stb_o;

    // WISHBONE slave 2 address and data
    reg [31:0] s2_wb_adr_o;
    reg [3:0] s2_wb_sel_o;
    reg s2_wb_we_o;
    reg [31:0] s2_wb_dat_o;
    reg s2_wb_cyc_o;
    reg s2_wb_stb_o;

    // WISHBONE master 1 acknowledge and error
    reg m1_wb_ack_o;
    reg [31:0] m1_wb_dat_o;
    reg m1_wb_err_o;

    // WISHBONE master 2 acknowledge and error
    reg m2_wb_ack_o;
    reg [31:0] m2_wb_dat_o;
    reg m2_wb_err_o;

    // WISHBONE access finished signal
    wire m_wb_access_finished = m1_wb_ack_o | m1_wb_err_o | m2_wb_ack_o | m2_wb_err_o;

    // WISHBONE master 1 state machine
    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            m1_in_progress <= 0;
            m2_in_progress <= 0;
            s1_wb_adr_o <= 0;
            s1_wb_sel_o <= 0;
            s1_wb_we_o <= 0;
            s1_wb_dat_o <= 0;
            s1_wb_cyc_o <= 0;
            s1_wb_stb_o <= 0;
            s2_wb_adr_o <= 0;
            s2_wb_sel_o <= 0;
            s2_wb_we_o <= 0;
            s2_wb_dat_o <= 0;
            s2_wb_cyc_o <= 0;
            s2_wb_stb_o <= 0;
        end else begin
            case ({m1_in_progress, m2_in_progress, m1_req, m2_req, m_wb_access_finished})
                5'b00_10_0, 5'b00_11_0:
                    begin
                        m1_in_progress <= 1'b1;
                        if (m1_addressed_s1) begin
                            s1_wb_adr_o <= m1_wb_adr_i;
                            s1_wb_sel_o <= m1_wb_sel_i;
                            s1_wb_we_o <= m1_wb_we_i;
                            s1_wb_dat_o <= m1_wb_dat_i;
                            s1_wb_cyc_o <= 1'b1;
                            s1_wb_stb_o <= 1'b1;
                        end else if (m1_addressed_s2) begin
                            s2_wb_adr_o <= m1_wb_adr_i;
                            s2_wb_sel_o <= m1_wb_sel_i;
                            s2_wb_we_o <= m1_wb_we_i;
                            s2_wb_dat_o <= m1_wb_dat_i;
                            s2_wb_cyc_o <= 1'b1;
                            s2_wb_stb_o <= 1'b1;
                        end else begin
                            $display("(%t)(%m)WISHBONE ERROR: Unspecified address space accessed", $time);
                        end
                    end
                5'b00_01_0:
                    begin
                        m2_in_progress <= 1'b1;
                        if (m2_addressed_s1) begin
                            s1_wb_adr_o <= m2_wb_adr_i;
                            s1_wb_sel_o <= m2_wb_sel_i;
                            s1_wb_we_o <= m2_wb_we_i;
                            s1_wb_dat_o <= m2_wb_dat_i;
                            s1_wb_cyc_o <= 1'b1;
                            s1_wb_stb_o <= 1'b1;
                        end else if (m2_addressed_s2) begin
                            s2_wb_adr_o <= m2_wb_adr_i;
                            s2_wb_sel_o <= m2_wb_sel_i;
                            s2_wb_we_o <= m2_wb_we_i;
                            s2_wb_dat_o <= m2_wb_dat_i;
                            s2_wb_cyc_o <= 1'b1;
                            s2_wb_stb_o <= 1'b1;
                        end else begin
                            $display("(%t)(%m)WISHBONE ERROR: Unspecified address space accessed", $time);
                        end
                    end
                5'b10_10_1, 5'b10_11_1:
                    begin
                        m1_in_progress <= 1'b0;
                        if (m1_addressed_s1) begin
                            s1_wb_cyc_o <= 1'b0;
                            s1_wb_stb_o <= 1'b0;
                        end else if (m1_addressed_s2) begin
                            s2_wb_cyc_o <= 1'b0;
                            s2_wb_stb_o <= 1'b0;
                        end
                    end
                5'b01_01_1, 5'b01_11_1:
                    begin
                        m2_in_progress <= 1'b0;
                        if (m2_addressed_s1) begin
                            s1_wb_cyc_o <= 1'b0;
                            s1_wb_stb_o <= 1'b0;
                        end else if (m2_addressed_s2) begin
                            s2_wb_cyc_o <= 1'b0;
                            s2_wb_stb_o <= 1'b0;
                        end
                    end
            endcase
        end
    end

    // WISHBONE master 1 acknowledge generation
    always @(m1_in_progress or m1_wb_adr_i or s1_wb_ack_i or s2_wb_ack_i or s1_wb_dat_i or s2_wb_dat_i or m1_addressed_s1 or m1_addressed_s2) begin
        if (m1_in_progress) begin
            if (m1_addressed_s1) begin
                m1_wb_ack_o <= s1_wb_ack_i;
                m1_wb_dat_o <= s1_wb_dat_i;
            end else if (m1_addressed_s2) begin
                m1_wb_ack_o <= s2_wb_ack_i;
                m1_wb_dat_o <= s2_wb_dat_i;
            end
        end else begin
            m1_wb_ack_o <= 0;
        end
    end

    // WISHBONE master 2 acknowledge generation
    always @(m2_in_progress or m2_wb_adr_i or s1_wb_ack_i or s2_wb_ack_i or s1_wb_dat_i or s2_wb_dat_i or m2_addressed_s1 or m2_addressed_s2) begin
        if (m2_in_progress) begin
            if (m2_addressed_s1) begin
                m2_wb_ack_o <= s1_wb_ack_i;
                m2_wb_dat_o <= s1_wb_dat_i;
            end else if (m2_addressed_s2) begin
                m2_wb_ack_o <= s2_wb_ack_i;
                m2_wb_dat_o <= s2_wb_dat_i;
            end
        end else begin
            m2_wb_ack_o <= 0;
        end
    end

    // WISHBONE master 1 error generation
    always @(m1_in_progress or m1_wb_adr_i or s1_wb_err_i or s2_wb_err_i or m2_addressed_s1 or m2_addressed_s2 or m1_wb_cyc_i or m1_wb_stb_i) begin
        if (m1_in_progress) begin
            if (m1_addressed_s1) begin
                m1_wb_err_o <= s1_wb_err_i;
            end else if (m1_addressed_s2) begin
                m1_wb_err_o <= s2_wb_err_i;
            end
        end else if (m1_wb_cyc_i & m1_wb_stb_i & ~m1_addressed_s1 & ~m1_addressed_s2) begin
            m1_wb_err_o <= 1'b1;
        end else begin
            m1_wb_err_o <= 1'b0;
        end
    end

    // WISHBONE master 2 error generation
    always @(m2_in_progress or m2_wb_adr_i or s1_wb_err_i or s2_wb_err_i or m2_addressed_s1 or m2_addressed_s2 or m2_wb_cyc_i or m2_wb_stb_i) begin
        if (m2_in_progress) begin
            if (m2_addressed_s1) begin
                m2_wb_err_o <= s1_wb_err_i;
            end else if (m2_addressed_s2) begin
                m2_wb_err_o <= s2_wb_err_i;
            end
        end else if (m2_wb_cyc_i & m2_wb_stb_i & ~m2_addressed_s1 & ~m2_addressed_s2) begin
            m2_wb_err_o <= 1'b1;
        end else begin
            m2_wb_err_o <= 1'b0;
        end
    end

    // WISHBONE activity monitor
    integer cnt;
    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            cnt <= 0;
        end else if (s1_wb_ack_i | s1_wb_err_i | s2_wb_ack_i | s2_wb_err_i) begin
            cnt <= 0;
        end else if (s1_wb_cyc_o | s2_wb_cyc_o) begin
            cnt <= cnt + 1;
        end
    end

    always @(posedge wb_clk_i) begin
        if (cnt == 1000) begin
            $display("(%0t)(%m) ERROR: WB activity ??? ", $time);
            if (s1_wb_cyc_o) begin
                $display("s1_wb_dat_o = 0x%0x", s1_wb_dat_o);
                $display("s1_wb_adr_o = 0x%0x", s1_wb_adr_o);
                $display("s1_wb_sel_o = 0x%0x", s1_wb_sel_o);
                $display("s1_wb_we_o = 0x%0x", s1_wb_we_o);
            end else if (s2_wb_cyc_o) begin
                $display("s2_wb_dat_o = 0x%0x", s2_wb_dat_o);
                $display("s2_wb_adr_o = 0x%0x", s2_wb_adr_o);
                $display("s2_wb_sel_o = 0x%0x", s2_wb_sel_o);
                $display("s2_wb_we_o = 0x%0x", s2_wb_we_o);
            end
            $stop;
        end
    end

    always @(posedge wb_clk_i) begin
        if (s1_wb_err_i & s1_wb_cyc_o) begin
            $display("(%0t) ERROR: WB cycle finished with error acknowledge ", $time);
            $display("s1_wb_dat_o = 0x%0x", s1_wb_dat_o);
            $display("s1_wb_adr_o = 0x%0x", s1_wb_adr_o);
            $display("s1_wb_sel_o = 0x%0x", s1_wb_sel_o);
            $display("s1_wb_we_o = 0x%0x", s1_wb_we_o);
            $stop;
        end
        if (s2_wb_err_i & s2_wb_cyc_o) begin
            $display("(%0t) ERROR: WB cycle finished with error acknowledge ", $time);
            $display("s2_wb_dat_o = 0x%0x", s2_wb_dat_o);
            $display("s2_wb_adr_o = 0x%0x", s2_wb_adr_o);
            $display("s2_wb_sel_o = 0x%0x", s2_wb_sel_o);
            $display("s2_wb_we_o = 0x%0x", s2_wb_we_o);
            $stop;
        end
    end

    // Assertions
    // WISHBONE master 1 address range check
    wb_addr_range_check_m1: assert property (
        @(posedge wb_clk_i) disable iff (!wb_rst_i) (m1_wb_cyc_i && m1_wb_stb_i) |-> (m1_addressed_s1 || m1_addressed_s2)
    ) else $error("WISHBONE master 1 address out of range");

    // WISHBONE master 2 address range check
    wb_addr_range_check_m2: assert property (
        @(posedge wb_clk_i) disable iff (!wb_rst_i) (m2_wb_cyc_i && m2_wb_stb_i) |-> (m2_addressed_s1 || m2_addressed_s2)
    ) else $error("WISHBONE master 2 address out of range");

    // WISHBONE master 1 acknowledge and error consistency
    wb_ack_err_consistency_m1: assert property (
        @(posedge wb_clk_i) disable iff (!wb_rst_i) (m1_wb_cyc_i && m1_wb_stb_i) |-> (m1_wb_ack_o | m1_wb_err_o)
    ) else $error("WISHBONE master 1 acknowledge and error not consistent");

    // WISHBONE master 2 acknowledge and error consistency
    wb_ack_err_consistency_m2: assert property (
        @(posedge wb_clk_i) disable iff (!wb_r