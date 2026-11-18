```systemverilog
module crc_control_unit_sva (
    input logic clk,
    input logic rst_n,
    input logic write,
    input logic reset_chain,
    output reg [1:0] byte_sel,
    output bypass_byte0,
    output buffer_full,
    output read_wait,
    output bypass_size,
    output set_crc_init_sel,
    output clear_crc_init_sel,
    output crc_out_en,
    output byte_en,
    output reset_pending
);
    // State definitions for state_full
    localparam EMPTY   = 2'b00;
    localparam WRITE_1 = 2'b01;
    localparam WRITE_2 = 2'b10;
    localparam BYPASS  = 2'b11;

    // State definitions for state_byte
    localparam IDLE   = 3'b100;
    localparam BYTE_0 = 3'b000;
    localparam BYTE_1 = 3'b001;
    localparam BYTE_2 = 3'b010;
    localparam BYTE_3 = 3'b011;

    // State definitions for state_reset
    localparam NO_RESET = 3'b000;
    localparam RESET    = 3'b001;
    localparam WAIT     = 3'b010;
    localparam WRITE    = 3'b011;
    localparam RESET_2  = 3'b100;

    // Coding for size signal
    localparam BYTE      = 2'b00;
    localparam HALF_WORD = 2'b01;
    localparam WORD      = 2'b10;

    // Internal signals
    reg [1:0] state_full;
    reg [2:0] state_byte;
    reg [2:0] state_reset;
    reg [1:0] next_state_full;
    reg [2:0] next_state_byte;
    reg [2:0] next_state_reset;
    wire last_byte;
    wire has_data;

    // FSM for management of writes in the input buffers
    always @(posedge clk) begin
        if (!rst_n)
            state_full <= EMPTY;
        else
            state_full <= next_state_full;
    end

    assign last_byte = (size_in == BYTE && state_byte == BYTE_0) ||
                       (size_in == HALF_WORD && state_byte == BYTE_1) ||
                       (size_in == WORD && state_byte == BYTE_3);

    always @(*) begin
        next_state_full = state_full;
        case (state_full)
            EMPTY: next_state_full = (write) ? WRITE_1 : EMPTY;
            WRITE_1: begin
                if (last_byte)
                    next_state_full = (write) ? BYPASS : WRITE_1;
                else
                    next_state_full = (write) ? WRITE_2 : WRITE_1;
            end
            WRITE_2: begin
                if (last_byte)
                    next_state_full = (write) ? BYPASS : WRITE_1;
            end
            BYPASS: begin
                if (last_byte && !write)
                    next_state_full = WRITE_1;
            end
        endcase
    end

    assign buffer_full = (state_full == WRITE_2 && !last_byte) ||
                         (state_full == BYPASS && !last_byte);

    assign read_wait = (state_byte != IDLE);

    assign bypass_byte0 = (state_full != BYPASS);

    assign has_data = (state_full == WRITE_2) ||
                      (state_full == BYPASS);

    always @(posedge clk) begin
        if (!rst_n)
            state_byte <= IDLE;
        else
            state_byte <= next_state_byte;
    end

    always @(*) begin
        next_state_byte = state_byte;
        case (state_byte)
            IDLE: next_state_byte = (write) ? BYTE_0 : IDLE;
            BYTE_0: begin
                if (size_in == BYTE)
                    next_state_byte = (write && !has_data) ? IDLE : BYTE_1;
                else
                    next_state_byte = BYTE_1;
            end
            BYTE_1: begin
                if (size_in == HALF_WORD)
                    next_state_byte = (has_data || (write && !buffer_full)) ? BYTE_0 : IDLE;
                else
                    next_state_byte = BYTE_2;
            end
            BYTE_2: next_state_byte = BYTE_3;
            BYTE_3: begin
                next_state_byte = (has_data || (write && !buffer_full)) ? BYTE_0 : IDLE;
            end
        endcase
    end

    always @(*) begin
        byte_sel = 2'b00;
        case (state_byte)
            BYTE_0: byte_sel = BYTE_0;
            BYTE_1: byte_sel = BYTE_1;
            BYTE_2: byte_sel = BYTE_2;
            BYTE_3: byte_sel = BYTE_3;
        endcase
    end

    assign bypass_size = !( (state_full != BYPASS && state_byte != BYTE_0) ||
                            (state_full == BYPASS)
                          );

    assign crc_out_en = (state_byte != IDLE);

    assign byte_en = (state_byte == BYTE_0 && (size_in == HALF_WORD || size_in == WORD) && state_full != BYPASS) ||
                     (last_byte && has_data);

    always @(posedge clk) begin
        if (!rst_n)
            state_reset <= NO_RESET;
        else
            state_reset <= next_state_reset;
    end

    always @(*) begin
        next_state_reset = state_reset;
        case (state_reset)
            NO_RESET: begin
                if ((reset_chain && !has_data && state_byte != IDLE && !last_byte) || (reset_chain && has_data && last_byte))
                    next_state_reset = RESET;
                if (reset_chain && has_data && !last_byte)
                    next_state_reset = WAIT;
            end
            RESET: begin
                if (last_byte)
                    next_state_reset = NO_RESET;
                else
                    next_state_reset = (write) ? WRITE : RESET;
            end
            WAIT: begin
                if (last_byte)
                    next_state_reset = (write) ? WRITE : RESET;
                else
                    next_state_reset = WAIT;
            end
            WRITE: begin
                if (reset_chain)
                    next_state_reset = (last_byte) ? RESET : RESET_2;
                else
                    next_state_reset = (last_byte) ? NO_RESET : WRITE;
            end
            RESET_2: begin
                if (last_byte)
                    next_state_reset = (write) ? WRITE : RESET;
                else
                    next_state_reset = RESET_2;
            end
        endcase
    end

    assign set_crc_init_sel = (state_byte == BYTE_0);

    assign clear_crc_init_sel = (state_reset == NO_RESET && last_byte && reset_chain) ||
                                (state_byte == IDLE && reset_chain) ||
                                (state_reset == RESET && last_byte) ||
                                (state_reset == WRITE && last_byte) ||
                                (state_reset == RESET_2 && last_byte);

    assign reset_pending = (state_reset != NO_RESET);

    // Assertions
    // Check that state_full transitions correctly
    state_full_transition: assert property (
        @(posedge clk) disable iff (!rst_n) $stable(state_full)
    ) else $error("state_full should not change during reset");

    // Check that state_byte transitions correctly
    state_byte_transition: assert property (
        @(posedge clk) disable iff (!rst_n) $stable(state_byte)
    ) else $error("state_byte should not change during reset");

    // Check that state_reset transitions correctly
    state_reset_transition: assert property (
        @(posedge clk) disable iff (!rst_n) $stable(state_reset)
    ) else $error("state_reset should not change during reset");

    // Check that byte_sel is set correctly
    byte_sel_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (byte_sel == state_byte)
    ) else $error("byte_sel should match state_byte");

    // Check that bypass_byte0 is set correctly
    bypass_byte0_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (bypass_byte0 == (state_full != BYPASS))
    ) else $error("bypass_byte0 should match state_full");

    // Check that buffer_full is set correctly
    buffer_full_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (buffer_full == ((state_full == WRITE_2 && !last_byte) || (state_full == BYPASS && !last_byte)))
    ) else $error("buffer_full should match state_full and last_byte");

    // Check that read_wait is set correctly
    read_wait_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (read_wait == (state_byte != IDLE))
    ) else $error("read_wait should match state_byte");

    // Check that bypass_size is set correctly
    bypass_size_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (bypass_size == !( (state_full != BYPASS && state_byte != BYTE_0) || (state_full == BYPASS) ))
    ) else $error("bypass_size should match state_full and state_byte");

    // Check that crc_out_en is set correctly
    crc_out_en_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (crc_out_en == (state_byte != IDLE))
    ) else $error("crc_out_en should match state_byte");

    // Check that byte_en is set correctly
    byte_en_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (byte_en == ((state_byte == BYTE_0 && (size_in == HALF_WORD || size_in == WORD) && state_full != BYPASS) || (last_byte && has_data)))
    ) else $error("byte_en should match state_byte, size_in, and last_byte");

    // Check that reset_pending is set correctly
    reset_pending_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (reset_pending == (state_reset != NO_RESET))
    ) else $error("reset_pending should match state_reset");

    // Check that set_crc_init_sel is set correctly
    set_crc_init_sel_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (set_crc_init_sel == (state_byte == BYTE_0))
    ) else $error("set_crc_init_sel should match state_byte");

    // Check that clear_crc_init_sel is set correctly
    clear_crc_init_sel_correct: assert property (
        @(posedge clk) disable iff (!rst_n) (clear_crc_init_sel == ((state_reset == NO_RESET && last_byte && reset_chain) || (state_byte == IDLE && reset_chain) || (state_reset == RESET && last_byte) || (state_reset == WRITE && last_byte) || (state_reset == RESET_2 && last_byte)))
    ) else $error("clear_crc_init_sel should match state_reset, state_byte, and last_byte");
endmodule
```