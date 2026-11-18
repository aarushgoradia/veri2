```systemverilog
module uartRec_sva (
    input logic clk,
    input logic reset,
    input logic sTick,
    input logic rx,
    output logic rxDoneTick,
    output logic [7:0] dOut
);
    // UART receiver states
    localparam idle = 2'b00, start = 2'b01, data = 2'b10, stop = 2'b11;

    // Assertions
    // UART receiver should start in idle state
    initial begin
        assert property (@(posedge clk) disable iff (!reset) stateReg == idle) else $error("UART receiver should start in idle state");
    end

    // UART receiver should transition to start state when rx is activated
    uart_start: assert property (@(posedge clk) disable iff (!reset) (stateReg == idle && ~rx) |-> stateReg == start) else $error("UART receiver should transition to start state when rx is activated");

    // UART receiver should transition to data state after 7 samples in start state
    uart_data_start: assert property (@(posedge clk) disable iff (!reset) (stateReg == start && sTick && sReg == 7) |-> stateReg == data) else $error("UART receiver should transition to data state after 7 samples in start state");

    // UART receiver should transition to stop state after 15 samples in data state
    uart_data_stop: assert property (@(posedge clk) disable iff (!reset) (stateReg == data && sTick && sReg == 15) |-> stateReg == stop) else $error("UART receiver should transition to stop state after 15 samples in data state");

    // UART receiver should transition to idle state after stop bits
    uart_stop: assert property (@(posedge clk) disable iff (!reset) (stateReg == stop && sTick && sReg == (sbTick-1)) |-> stateReg == idle) else $error("UART receiver should transition to idle state after stop bits");

    // UART receiver should output the received data correctly
    uart_data_out: assert property (@(posedge clk) disable iff (!reset) (stateReg == stop && sTick && sReg == (sbTick-1)) |-> dOut == bReg) else $error("UART receiver should output the received data correctly");

    // UART receiver should reset to idle state on reset
    uart_reset: assert property (@(posedge clk) disable iff (!reset) reset |-> stateReg == idle) else $error("UART receiver should reset to idle state on reset");

endmodule
```