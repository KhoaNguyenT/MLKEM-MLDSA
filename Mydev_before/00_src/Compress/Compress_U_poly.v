module Compress_U_poly #(
    parameter integer NUM_INST = 16
)(
    input   wire                        id_i, // 0 : 10, 1 : 11
    input   wire  [NUM_INST*12-1:0]     CMP_data_i,
    output  wire  [NUM_INST*12-1:0]     CMP_data_o
);
    wire    [159:0] poly_coeff_10b;
    wire    [175:0] poly_coeff_11b;
    genvar i;
    generate
        for (i = 0; i < NUM_INST; i = i + 1) begin : GEN_COMPRESS
            wire [10:0] coeff_11b;

            Compress_1011_real u_compress (
                .iD (id_i),
                .iCoeff(CMP_data_i[i*12 +: 12]),
                .oCoeff(coeff_11b)
            );

            // zero-extend to 12 bits: MSB always 0
            assign poly_coeff_10b[i*10 +: 10] = coeff_11b[9:0];
            assign poly_coeff_11b[i*11 +: 11] = coeff_11b;
            // assign CMP_data_o[i*12 +: 12] = {1'b0, coeff_11b};
        end
    endgenerate
    assign CMP_data_o = (id_i) ? {poly_coeff_11b, 16'b0} : {poly_coeff_10b, 32'b0};
endmodule
