module inputRegister_sva (
    input logic clk,
    input logic [`inputNumber-1:0] inputs,
    input logic [`inputAddrLen-1:0] inputReadAddr,
    input logic inputReadOut
);

// inputReadOut must equal the selected input bit.
    check_read_matches_selected_input: assert property (
        @(posedge clk) inputReadOut == inputs[inputReadAddr]
    );

// A zero address selects input[0].
    check_addr_zero_selects_input0: assert property (
        @(posedge clk) (inputReadAddr == 7'h00) |-> (inputReadOut == inputs[7'h00])
    );

// A maximum address selects input[127].
    check_addr_max_selects_input127: assert property (
        @(posedge clk) (inputReadAddr == 7'h7F) |-> (inputReadOut == inputs[7'h7F])
    );

// A zero input value drives a zero read.
    check_zero_input_drives_zero_read: assert property (
        @(posedge clk) (inputs[inputReadAddr] == 1'b0) |-> (inputReadOut == 1'b0)
    );

// A one input value drives a one read.
    check_one_input_drives_one_read: assert property (
        @(posedge clk) (inputs[inputReadAddr] == 1'b1) |-> (inputReadOut == 1'b1)
    );

endmodule
