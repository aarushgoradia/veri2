```systemverilog
module cavlc_len_gen_sva (
    input logic clk,
    input logic rst_n,
    input logic [7:0] cavlc_state,
    input logic [4:0] len_read_total_coeffs_comb,
    input logic [4:0] len_read_levels_comb,
    input logic [3:0] len_read_total_zeros_comb,
    input logic [3:0] len_read_run_befores_comb,
    output logic [4:0] len_comb
);
    // Combinational logic, but still use clocked assertions
    always @(posedge clk) disable iff (!rst_n) begin
        // len_comb should be updated based on the current state
        case (cavlc_state)
            `cavlc_read_total_coeffs_s: assert property (len_comb == len_read_total_coeffs_comb);
            `cavlc_read_t1s_flags_s, `cavlc_read_level_prefix_s, `cavlc_read_level_suffix_s: assert property (len_comb == len_read_levels_comb);
            `cavlc_read_total_zeros_s: assert property (len_comb == len_read_total_zeros_comb);
            `cavlc_read_run_befores_s: assert property (len_comb == len_read_run_befores_comb);
            `cavlc_calc_level_s, `cavlc_idle_s: assert property (len_comb == 0);
            default: assert property (len_comb == 'bx);
        endcase
    end
endmodule
```