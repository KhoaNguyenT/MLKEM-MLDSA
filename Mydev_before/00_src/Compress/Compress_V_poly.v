module Compress_V_poly #(
    parameter integer NUM_INST = 16
)(
    input   wire                        id_i, // 0 : 10, 1 : 11
    input   wire  [NUM_INST*12-1:0]     CMP_data_i,
    output  wire  [NUM_INST*12-1:0]     CMP_data_o
);
    wire    [63:0] poly_coeff_04b;
    wire    [79:0] poly_coeff_05b;
    genvar i;
    generate
        for (i = 0; i < NUM_INST; i = i + 1) begin : GEN_COMPRESS
            wire [4:0] coeff_05b;

            Compress_0405_real u_compress (
                .iD (id_i),
                .iCoeff(CMP_data_i[i*12 +: 12]),
                .oCoeff(coeff_05b)
            );

            // zero-extend to 12 bits: MSB always 0
            assign poly_coeff_04b[i*4 +: 4] = coeff_05b[3:0];
            assign poly_coeff_05b[i*5 +: 5] = coeff_05b;
            // assign CMP_data_o[i*12 +: 12] = {7'b0, coeff_11b};
        end
    endgenerate
    assign CMP_data_o = (id_i) ? {poly_coeff_05b, 112'b0} : {poly_coeff_04b, 128'b0};
endmodule
