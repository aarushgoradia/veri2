```systemverilog
module crc_comb_sva (
    input logic clk,
    input logic rst_n,
    input logic data_in,
    input logic [7:0] crc_in,
    input logic [7:0] crc_poly,
    input logic [3:0] crc_poly_size,
    output logic [7:0] crc_out
);
    // Reverse the crc_poly_size and MASK
    wire [3:0] crc_poly_size_reversed;
    wire [7:0] MASK_REVERSED;

    assign crc_poly_size_reversed[0] = crc_poly_size[3];
    assign crc_poly_size_reversed[1] = crc_poly_size[2];
    assign crc_poly_size_reversed[2] = crc_poly_size[1];
    assign crc_poly_size_reversed[3] = crc_poly_size[0];

    assign MASK_REVERSED[0] = MASK[7];
    assign MASK_REVERSED[1] = MASK[6];
    assign MASK_REVERSED[2] = MASK[5];
    assign MASK_REVERSED[3] = MASK[4];
    assign MASK_REVERSED[4] = MASK[3];
    assign MASK_REVERSED[5] = MASK[2];
    assign MASK_REVERSED[6] = MASK[1];
    assign MASK_REVERSED[7] = MASK[0];

    // Feedback calculation
    wire [8:0] feedback;
    assign feedback = crc_poly & {8{crc_in[7] ^ data_in}};

    // CRC in masked
    wire [7:0] crc_in_masked;
    assign crc_in_masked = crc_in[7:0] & (~(crc_poly_size_reversed[7:0] & MASK_REVERSED));

    // CRC out calculation
    assign crc_out = {crc_in_masked ^ feedback[8:1], feedback[0]};

    // Property to check the feedback calculation
    property p_feedback;
        @(posedge clk) disable iff (!rst_n) crc_poly == 8'hff |-> feedback == crc_poly & {8{crc_in[7] ^ data_in}};
    endproperty
    assert property (p_feedback) else $error("Feedback calculation is incorrect");

    // Property to check the crc_in_masked calculation
    property p_crc_in_masked;
        @(posedge clk) disable iff (!rst_n) crc_in == 8'h00 |-> crc_in_masked == 8'h00;
    endproperty
    assert property (p_crc_in_masked) else $error("crc_in_masked calculation is incorrect");

    // Property to check the crc_out calculation
    property p_crc_out;
        @(posedge clk) disable iff (!rst_n) crc_in == 8'h00 |-> crc_out == 8'h00;
    endproperty
    assert property (p_crc_out) else $error("crc_out calculation is incorrect");

    // Property to check the reset behavior
    property p_reset;
        @(posedge clk) disable iff (!rst_n) rst_n == 1'b0 |-> crc_out == 8'h00;
    endproperty
    assert property (p_reset) else $error("Reset behavior is incorrect");

    // Property to check the data_in behavior
    property p_data_in;
        @(posedge clk) disable iff (!rst_n) data_in == 1'b0 |-> crc_out == crc_in;
    endproperty
    assert property (p_data_in) else $error("data_in behavior is incorrect");

    // Property to check the crc_poly behavior
    property p_crc_poly;
        @(posedge clk) disable iff (!rst_n) crc_poly == 8'hff |-> crc_out == crc_in;
    endproperty
    assert property (p_crc_poly) else $error("crc_poly behavior is incorrect");

    // Property to check the crc_poly_size behavior
    property p_crc_poly_size;
        @(posedge clk) disable iff (!rst_n) crc_poly_size == 4'h00 |-> crc_out == crc_in;
    endproperty
    assert property (p_crc_poly_size) else $error("crc_poly_size behavior is incorrect");

    // Property to check the crc_in_masked behavior
    property p_crc_in_masked_behavior;
        @(posedge clk) disable iff (!rst_n) crc_in == 8'h00 |-> crc_in_masked == 8'h00;
    endproperty
    assert property (p_crc_in_masked_behavior) else $error("crc_in_masked behavior is incorrect");

    // Property to check the feedback behavior
    property p_feedback_behavior;
        @(posedge clk) disable iff (!rst_n) crc_in == 8'h00 |-> feedback == 8'h00;
    endproperty
    assert property (p_feedback_behavior) else $error("feedback behavior is incorrect");

    // Property to check the crc_out behavior
    property p_crc_out_behavior;
        @(posedge clk) disable iff (!rst_n) crc_in == 8'h00 |-> crc_out == 8'h00;
    endproperty
    assert property (p_crc_out_behavior) else $error("crc_out behavior is incorrect");
endmodule
```