```systemverilog
module bit_reversal_sva (
    input logic CLK,
    input logic RESETn,
    input logic [DATA_SIZE - 1 : 0] data_in,
    input logic [1 : 0] rev_type,
    output logic [DATA_SIZE - 1 : 0] data_out
);
    localparam DATA_SIZE = 32;
    localparam NO_REVERSE = 2'b00; 
    localparam BYTE       = 2'b01;
    localparam HALF_WORD  = 2'b10;
    localparam WORD       = 2'b11;
    localparam TYPES = 4;

    wire [DATA_SIZE - 1 : 0] data_reversed[0 : 3];

    assign data_reversed[NO_REVERSE] = data_in; //bit order not affected

    generate
        genvar i, type;
        for(type = 1 ; type < TYPES; type = type + 1)
            for(i = 0; i < DATA_SIZE; i = i + 1)
                begin
                    if(i < `size)
                        assign data_reversed[type][i] = data_in[`size*((i/`size) + 1) - 1 - i];
                    else
                        assign data_reversed[type][i] = data_in[`size*((i/`size) + 1) - 1 - (i%(`size*(i/`size)))];
                end
    endgenerate

    // Output Mux
    assign data_out = data_reversed[rev_type];

    // Property to check that data_out is correctly assigned based on rev_type
    property p_data_out_assignment;
        @(posedge CLK) disable iff (!RESETn) data_out == data_reversed[rev_type];
    endproperty

    // Assert the property
    a_data_out_assignment: assert property (p_data_out_assignment)
        else $error("data_out is not correctly assigned based on rev_type");

    // Property to check that data_reversed[NO_REVERSE] is equal to data_in
    property p_no_reverse;
        @(posedge CLK) disable iff (!RESETn) data_reversed[NO_REVERSE] == data_in;
    endproperty

    // Assert the property
    a_no_reverse: assert property (p_no_reverse)
        else $error("data_reversed[NO_REVERSE] is not equal to data_in");

    // Property to check that data_reversed[BYTE] is correctly reversed by byte
    property p_byte_reverse;
        @(posedge CLK) disable iff (!RESETn) data_reversed[BYTE] == {data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24]};
    endproperty

    // Assert the property
    a_byte_reverse: assert property (p_byte_reverse)
        else $error("data_reversed[BYTE] is not correctly reversed by byte");

    // Property to check that data_reversed[HALF_WORD] is correctly reversed by half-word
    property p_half_word_reverse;
        @(posedge CLK) disable iff (!RESETn) data_reversed[HALF_WORD] == {data_in[15:0], data_in[31:16]};
    endproperty

    // Assert the property
    a_half_word_reverse: assert property (p_half_word_reverse)
        else $error("data_reversed[HALF_WORD] is not correctly reversed by half-word");

    // Property to check that data_reversed[WORD] is correctly reversed by word
    property p_word_reverse;
        @(posedge CLK) disable iff (!RESETn) data_reversed[WORD] == data_in;
    endproperty

    // Assert the property
    a_word_reverse: assert property (p_word_reverse)
        else $error("data_reversed[WORD] is not correctly reversed by word");

    // Property to check that data_reversed[3] is always equal to data_in
    property p_reversed_3;
        @(posedge CLK) disable iff (!RESETn) data_reversed[3] == data_in;
    endproperty

    // Assert the property
    a_reversed_3: assert property (p_reversed_3)
        else $error("data_reversed[3] is not always equal to data_in");

    // Property to check that data_reversed[2] is always equal to data_in
    property p_reversed_2;
        @(posedge CLK) disable iff (!RESETn) data_reversed[2] == data_in;
    endproperty

    // Assert the property
    a_reversed_2: assert property (p_reversed_2)
        else $error("data_reversed[2] is not always equal to data_in");

    // Property to check that data_reversed[1] is always equal to data_in
    property p_reversed_1;
        @(posedge CLK) disable iff (!RESETn) data_reversed[1] == data_in;
    endproperty

    // Assert the property
    a_reversed_1: assert property (p_reversed_1)
        else $error("data_reversed[1] is not always equal to data_in");

endmodule
```