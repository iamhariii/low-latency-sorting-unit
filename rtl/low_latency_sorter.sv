// Low-latency 8-element unsigned sorting unit
// Architecture: fully combinational bitonic sorting network + output register.
// Latency: one rising clock edge from accepted input to valid sorted output.
// Throughput: one input vector per clock (no backpressure).
module low_latency_sorter #(
    parameter integer DATA_WIDTH = 16
) (
    input  logic                         clk,
    input  logic                         rst,       // synchronous, active-high
    input  logic                         in_valid,
    input  logic [8*DATA_WIDTH-1:0]      in_data,   // element 0 is least-significant slice
    output logic                         out_valid,
    output logic [8*DATA_WIDTH-1:0]      out_data
);

    logic [DATA_WIDTH-1:0] s0 [0:7];\n    logic [DATA_WIDTH-1:0] s1 [0:7];\n    logic [DATA_WIDTH-1:0] s2 [0:7];\n    logic [DATA_WIDTH-1:0] s3 [0:7];\n    logic [DATA_WIDTH-1:0] s4 [0:7];\n    logic [DATA_WIDTH-1:0] s5 [0:7];\n    logic [DATA_WIDTH-1:0] s6 [0:7];\n\n    // Stage 0: unpack the eight input elements.\n    assign s0[0] = in_data[0*DATA_WIDTH +: DATA_WIDTH];\n    assign s0[1] = in_data[1*DATA_WIDTH +: DATA_WIDTH];\n    assign s0[2] = in_data[2*DATA_WIDTH +: DATA_WIDTH];\n    assign s0[3] = in_data[3*DATA_WIDTH +: DATA_WIDTH];\n    assign s0[4] = in_data[4*DATA_WIDTH +: DATA_WIDTH];\n    assign s0[5] = in_data[5*DATA_WIDTH +: DATA_WIDTH];\n    assign s0[6] = in_data[6*DATA_WIDTH +: DATA_WIDTH];\n    assign s0[7] = in_data[7*DATA_WIDTH +: DATA_WIDTH];\n\n    // Six compare/exchange stages of an 8-input bitonic network.\n    assign s1[0] = ((s0[0] <= s0[1]) ? s0[0] : s0[1]);\n    assign s1[1] = ((s0[0] <= s0[1]) ? s0[1] : s0[0]);\n    assign s1[2] = ((s0[3] >= s0[2]) ? s0[3] : s0[2]);\n    assign s1[3] = ((s0[3] >= s0[2]) ? s0[2] : s0[3]);\n    assign s1[4] = ((s0[4] <= s0[5]) ? s0[4] : s0[5]);\n    assign s1[5] = ((s0[4] <= s0[5]) ? s0[5] : s0[4]);\n    assign s1[6] = ((s0[7] >= s0[6]) ? s0[7] : s0[6]);\n    assign s1[7] = ((s0[7] >= s0[6]) ? s0[6] : s0[7]);\n\n    assign s2[0] = ((s1[0] <= s1[2]) ? s1[0] : s1[2]);\n    assign s2[1] = ((s1[1] <= s1[3]) ? s1[1] : s1[3]);\n    assign s2[2] = ((s1[0] <= s1[2]) ? s1[2] : s1[0]);\n    assign s2[3] = ((s1[1] <= s1[3]) ? s1[3] : s1[1]);\n    assign s2[4] = ((s1[6] >= s1[4]) ? s1[6] : s1[4]);\n    assign s2[5] = ((s1[7] >= s1[5]) ? s1[7] : s1[5]);\n    assign s2[6] = ((s1[6] >= s1[4]) ? s1[4] : s1[6]);\n    assign s2[7] = ((s1[7] >= s1[5]) ? s1[5] : s1[7]);\n\n    assign s3[0] = ((s2[0] <= s2[1]) ? s2[0] : s2[1]);\n    assign s3[1] = ((s2[0] <= s2[1]) ? s2[1] : s2[0]);\n    assign s3[2] = ((s2[2] <= s2[3]) ? s2[2] : s2[3]);\n    assign s3[3] = ((s2[2] <= s2[3]) ? s2[3] : s2[2]);\n    assign s3[4] = ((s2[5] >= s2[4]) ? s2[5] : s2[4]);\n    assign s3[5] = ((s2[5] >= s2[4]) ? s2[4] : s2[5]);\n    assign s3[6] = ((s2[7] >= s2[6]) ? s2[7] : s2[6]);\n    assign s3[7] = ((s2[7] >= s2[6]) ? s2[6] : s2[7]);\n\n    assign s4[0] = ((s3[0] <= s3[4]) ? s3[0] : s3[4]);\n    assign s4[1] = ((s3[1] <= s3[5]) ? s3[1] : s3[5]);\n    assign s4[2] = ((s3[2] <= s3[6]) ? s3[2] : s3[6]);\n    assign s4[3] = ((s3[3] <= s3[7]) ? s3[3] : s3[7]);\n    assign s4[4] = ((s3[0] <= s3[4]) ? s3[4] : s3[0]);\n    assign s4[5] = ((s3[1] <= s3[5]) ? s3[5] : s3[1]);\n    assign s4[6] = ((s3[2] <= s3[6]) ? s3[6] : s3[2]);\n    assign s4[7] = ((s3[3] <= s3[7]) ? s3[7] : s3[3]);\n\n    assign s5[0] = ((s4[0] <= s4[2]) ? s4[0] : s4[2]);\n    assign s5[1] = ((s4[1] <= s4[3]) ? s4[1] : s4[3]);\n    assign s5[2] = ((s4[0] <= s4[2]) ? s4[2] : s4[0]);\n    assign s5[3] = ((s4[1] <= s4[3]) ? s4[3] : s4[1]);\n    assign s5[4] = ((s4[4] <= s4[6]) ? s4[4] : s4[6]);\n    assign s5[5] = ((s4[5] <= s4[7]) ? s4[5] : s4[7]);\n    assign s5[6] = ((s4[4] <= s4[6]) ? s4[6] : s4[4]);\n    assign s5[7] = ((s4[5] <= s4[7]) ? s4[7] : s4[5]);\n\n    assign s6[0] = ((s5[0] <= s5[1]) ? s5[0] : s5[1]);\n    assign s6[1] = ((s5[0] <= s5[1]) ? s5[1] : s5[0]);\n    assign s6[2] = ((s5[2] <= s5[3]) ? s5[2] : s5[3]);\n    assign s6[3] = ((s5[2] <= s5[3]) ? s5[3] : s5[2]);\n    assign s6[4] = ((s5[4] <= s5[5]) ? s5[4] : s5[5]);\n    assign s6[5] = ((s5[4] <= s5[5]) ? s5[5] : s5[4]);\n    assign s6[6] = ((s5[6] <= s5[7]) ? s5[6] : s5[7]);\n    assign s6[7] = ((s5[6] <= s5[7]) ? s5[7] : s5[6]);\n\n    // Register the sorted vector. Output data holds its last value when invalid.
    integer out_i;
    always_ff @(posedge clk) begin
        if (rst) begin
            out_valid <= 1'b0;
            out_data  <= '0;
        end else begin
            out_valid <= in_valid;
            if (in_valid) begin
                out_data[0*DATA_WIDTH +: DATA_WIDTH] <= s6[0];\n                out_data[1*DATA_WIDTH +: DATA_WIDTH] <= s6[1];\n                out_data[2*DATA_WIDTH +: DATA_WIDTH] <= s6[2];\n                out_data[3*DATA_WIDTH +: DATA_WIDTH] <= s6[3];\n                out_data[4*DATA_WIDTH +: DATA_WIDTH] <= s6[4];\n                out_data[5*DATA_WIDTH +: DATA_WIDTH] <= s6[5];\n                out_data[6*DATA_WIDTH +: DATA_WIDTH] <= s6[6];\n                out_data[7*DATA_WIDTH +: DATA_WIDTH] <= s6[7];\n            end
        end
    end

endmodule
