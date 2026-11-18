```systemverilog
module aes_host_interface_sva (
    input logic PCLK,
    input logic PRESETn,
    input logic PWRITE,
    input logic PENABLE,
    input logic PSEL,
    input logic [31:0] PWDATA,
    input logic [31:0] key_bus,
    input logic [31:0] col_bus,
    input logic [31:0] iv_bus,
    input logic ccf_set,
    output logic [3:0] key_en,
    output logic [1:0] col_addr,
    output logic [1:0] chmod,
    output logic [1:0] mode,
    output logic [1:0] data_type,
    output logic col_wr_en,
    output logic col_rd_en,
    output logic [1:0] key_sel,
    output logic [3:0] iv_en,
    output logic [3:0] iv_sel,
    output logic int_ccf,
    output logic int_err,
    output logic disable_core,
    output logic first_block,
    output logic dma_req_wr,
    output logic dma_req_rd,
    output logic start_core,
    output logic [31:0] PRDATA
);
    // Configuration Register Logic
    logic [10:0] aes_cr;
    logic wr_err;
    logic rd_err;
    logic ccf;
    logic [2:0] state;
    logic [1:0] cnt;
    logic dma_req;
    logic enable;
    logic access_permission;
    logic start_core_reg;
    logic first_block_reg;
    logic [1:0] cnt_reg;
    logic [31:0] bus_out_mux;

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            aes_cr <= 13'd0;
            wr_err <= 1'b0;
            rd_err <= 1'b0;
            ccf <= 1'b0;
            state <= 3'd0;
            cnt <= 2'b11;
            dma_req <= 1'b0;
            enable <= 1'b0;
            access_permission <= 1'b0;
            start_core_reg <= 1'b0;
            first_block_reg <= 1'b1;
            cnt_reg <= 2'b11;
            bus_out_mux <= 32'd0;
        end else begin
            aes_cr <= aes_cr;
            wr_err <= wr_err;
            rd_err <= rd_err;
            ccf <= ccf;
            state <= state;
            cnt <= cnt;
            dma_req <= dma_req;
            enable <= enable;
            access_permission <= access_permission;
            start_core_reg <= start_core_reg;
            first_block_reg <= first_block_reg;
            cnt_reg <= cnt_reg;
            bus_out_mux <= bus_out_mux;
        end
    end

    // Configuration Register Logic
    assign aes_cr_wr_en = (PADDR == AES_CR) & PWRITE & PSEL & PENABLE;
    assign mode = aes_cr[4:3];
    assign chmod = aes_cr[6:5];
    assign enable = aes_cr[0];
    assign dma_out_en = aes_cr[10];
    assign dma_in_en = aes_cr[9];
    assign err_ie = aes_cr[8];
    assign ccf_ie = aes_cr[7];
    assign errc = PWDATA[8];
    assign ccfc = PWDATA[7];

    // State Register
    assign next_state = state;
    always @(*) begin
        case(state)
            IDLE: next_state = (enable && !key_deriv) ? START : INPUT;
            INPUT: next_state = (write_completed && cnt_en) ? START : INPUT;
            START: next_state = WAIT;
            WAIT: next_state = (ccf_set) ? (key_deriv ? IDLE : OUTPUT) : next_state;
            OUTPUT: next_state = (read_completed && cnt_en) ? INPUT : OUTPUT;
        endcase
    end

    // Output Logic
    assign disable_core = ~enable;
    assign col_addr = cnt_reg;
    assign col_wr_en = (PADDR == AES_DINR && write_en && state == INPUT);
    assign col_rd_en = (PADDR == AES_DOUTR && read_en && state == OUTPUT);
    assign wr_err_en = (PADDR == AES_DINR && write_en && (state != INPUT && state != IDLE));
    assign rd_err_en = (PADDR == AES_DOUTR && read_en && (state != OUTPUT && state != IDLE));

    // DMA Requests Logic
    assign dma_req_wr = (dma_req ^ cnt_reg[0]) & dma_in_en & enable & (state == INPUT || state == IDLE);
    assign dma_req_rd = (dma_req ^ cnt_reg[0]) & dma_out_en & enable & (state == OUTPUT);

    // APB Read Signal
    assign PRDATA = bus_out_mux;

    // Output Mux
    always @(*) begin
        bus_out_mux = 32'd0;
        case(PADDR)
            AES_CR: bus_out_mux = {{19{1'b0}}, aes_cr[10:7], 2'b00, aes_cr[6:0]};
            AES_SR: bus_out_mux = {{29{1'b0}}, wr_err, rd_err, (ccf_set && ~PENABLE) ? 1'b1 : (ccfc && aes_cr_wr_en) ? 1'b0 : ccf};
            AES_DINR, AES_DOUTR: begin if (~PWRITE && PADDR == AES_DOUTR && (ccf_set || ccf)) bus_out_mux = col_bus; end
            AES_KEYR0, AES_KEYR1, AES_KEYR2, AES_KEYR3: if (!enable) bus_out_mux = key_bus;
            AES_IVR0, AES_IVR1, AES_IVR2, AES_IVR3: if (!enable) bus_out_mux = iv_bus;
        endcase
    end

    // Key Signals Decoding
    assign key_en = (4'b1000 >> PADDR[1:0]) & {4{(~PADDR[3] & PADDR[2] & access_permission & write_en)}};
    assign key_sel = ~PADDR[1:0] & {2{(PADDR[2] & access_permission)}};

    // IV Signals Decoding
    assign iv_sel = (4'b1000 >> PADDR[1:0]) & {4{(PADDR[3] & ~PADDR[2] & access_permission)}};
    assign iv_en = iv_sel & {4{write_en}};

    // Next State Logic
    always @(*) begin
        next_state = state;
        case(state)
            IDLE: begin
                access_permission = 1'b1;
                first_block_reg = 1'b1;
                if (enable && !key_deriv) cnt_reg = 2'b11;
            end
            INPUT: begin if (PADDR == AES_DINR && write_en) cnt_reg = 2'b11; end
            START: start_core_reg = 1'b1;
            WAIT: begin if (ccf_set) cnt_reg = 2'b11; if (ccf_set && key_deriv) enable <= 1'b0; end
            OUTPUT: begin first_block_reg = 1'b0; if (PADDR == AES_DOUTR && read_en && PENABLE) cnt_reg = 2'b11; end
        endcase
    end

    // Write and read enable signals
    assign write_en = PSEL & PENABLE & PWRITE;
    assign read_en = (PSEL & ~PWRITE) ? 1'b1 : 1'b0;

    // Write and read completed signals
    assign write_completed = (cnt_reg == 2'b11);
    assign read_completed = (cnt_reg == 2'b11);

    // Assertions
    // Configuration Register Write Enable
    config_reg_write_enable: assert property (
        @(posedge PCLK) disable iff (!PRESETn) $rose(aes_cr_wr_en) |-> (PSEL && PENABLE && PWRITE)
    ) else $error("Configuration Register Write Enable Violation");

    // State Transition from IDLE to INPUT
    state_transition_idle_to_input: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (state == IDLE && enable && !key_deriv) |-> (next_state == INPUT)
    ) else $error("State Transition from IDLE to INPUT Violation");

    // State Transition from INPUT to START
    state_transition_input_to_start: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (state == INPUT && write_completed && cnt_en) |-> (next_state == START)
    ) else $error("State Transition from INPUT to START Violation");

    // State Transition from START to WAIT
    state_transition_start_to_wait: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (state == START) |-> (next_state == WAIT)
    ) else $error("State Transition from START to WAIT Violation");

    // State Transition from WAIT to IDLE or OUTPUT
    state_transition_wait_to_idle_or_output: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (state == WAIT && ccf_set) |-> (next_state == (key_deriv ? IDLE : OUTPUT))
    ) else $error("State Transition from WAIT to IDLE or OUTPUT Violation");

    // State Transition from OUTPUT to INPUT
    state_transition_output_to_input: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (state == OUTPUT && read_completed && cnt_en) |-> (next_state == INPUT)
    ) else $error("State Transition from OUTPUT to INPUT Violation");

    // DMA Request Generation
    dma_request_generation: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (state == INPUT || state == IDLE) |-> (dma_req_wr == (dma_req ^ cnt_reg[0]) & dma_in_en & enable)
    ) else $error("DMA Request Generation Violation");

    // DMA Request Generation
    dma_request_generation: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (state == OUTPUT) |-> (dma_req_rd == (dma_req ^ cnt_reg[0]) & dma_out_en & enable)
    ) else $error("DMA Request Generation Violation");

    // APB Read Signal
    apb_read_signal: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (read_en) |-> (PRDATA == bus_out_mux)
    ) else $error("APB Read Signal Violation");

    // Key Signals Decoding
    key_signals_decoding: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == AES_KEYR0 || PADDR == AES_KEYR1 || PADDR == AES_KEYR2 || PADDR == AES_KEYR3) |-> (key_en == (4'b1000 >> PADDR[1:0]) & {4{(~PADDR[3] & PADDR[2] & access_permission & write_en)}})
    ) else $error("Key Signals Decoding Violation");

    // IV Signals Decoding
    iv_signals_decoding: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == AES_IVR0 || PADDR == AES_IVR1 || PADDR == AES_IVR2 || PADDR == AES_IVR3) |-> (iv_sel == (4'b1000 >> PADDR[1:0]) & {4{(PADDR[3] & ~PADDR[2] & access_permission)}})
    ) else $error("IV Signals Decoding Violation");

    // Write Error Flag
    write_error_flag: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (wr_err_en && errc && aes_cr_wr_en && access_permission) |-> (wr_err == 1'b0)
    ) else $error("Write Error Flag Violation");

    // Read Error Flag
    read_error_flag: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (rd_err_en && errc && aes_cr_wr_en && access_permission) |-> (rd_err == 1'b0)
    ) else $error("Read Error Flag Violation");

    // Computation Complete Flag
    computation_complete_flag: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (ccf_set) |-> (ccf == 1'b1)
    ) else $error("Computation Complete Flag Violation");

    // Interruption on Error Signals
    interruption_on_error_signals: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (ccf_set && ccf_ie) |-> (int_ccf == 1'b1)
    ) else $error("Interruption on Error Signals Violation");

    // Interruption on Error Signals
    interruption_on_error_signals: assert property (
        @(posedge PCLK) disable iff (!PRESETn) ((wr_err_en | rd_err_en) && err_ie) |-> (int_err == 1'b1)
    ) else $error("Interruption on Error Signals Violation");

    // First Block Signal
    first_block_signal: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (first_block_set) |-> (first_block == 1'b1)
    ) else $error("First Block Signal Violation");

    // First Block Signal
    first_block_signal: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (first_block_clear) |-> (first_block == 1'b0)
    ) else $error("First Block Signal Violation");

    // Output Mux
    output_mux: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == AES_CR) |-> (bus_out_mux == {{19{1'b0}}, aes_cr[10:7], 2'b00, aes_cr[6:0]})
    ) else $error("Output Mux Violation");

    // Output Mux
    output_mux: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == AES_SR) |-> (bus_out_mux == {{29{1'b0}}, wr_err, rd_err, (ccf_set && ~PENABLE) ? 1'b1 : (ccfc && aes_cr_wr_en) ? 1'b0 : ccf})
    ) else $error("Output Mux Violation");

    // Output Mux
    output_mux: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == AES_DOUTR && read_en && (ccf_set || ccf)) |-> (bus_out_mux == col_bus)
    ) else $error("Output Mux Violation");

    // Output Mux
    output_mux: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == AES_KEYR0 || PADDR == AES_KEYR1 || PADDR == AES_KEYR2 || PADDR == AES_KEYR3) |-> (bus_out_mux == key_bus)
    ) else $error("Output Mux Violation");

    // Output Mux
    output_mux: assert property (
        @(posedge PCLK) disable iff (!PRESETn) (PADDR == AES_IVR0 || PADDR == AES_IVR1 || PADDR == AES_IVR2 || PADDR == AES_IVR3) |-> (bus_out_mux == iv_bus)
    ) else $error("Output Mux Violation");

endmodule
```