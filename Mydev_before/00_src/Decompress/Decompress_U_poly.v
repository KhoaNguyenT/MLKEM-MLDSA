module Decompress_U_poly #(
    parameter integer NUM_INST = 16
)(
    input   wire                        id_i, // 0 : 10, 1 : 11
    input   wire  [NUM_INST*12-1:0]     Coeff_i,
    output  wire  [NUM_INST*12-1:0]     Coeff_o
);
    genvar i;
    generate
        for (i = 0; i < NUM_INST; i = i + 1) begin : GEN_DECOMPRESS
            wire [11:0] coeff_12b;

            Decompress_1011_real u_compress (
                .iD (id_i),
                .iCoeff(Coeff_i[i*12 +: 11]),
                .oCoeff(coeff_12b)
            );

            // zero-extend to 12 bits: MSB always 0
            // assign poly_coeff_10b[i*10 +: 10] = coeff_11b[9:0];
            // assign poly_coeff_11b[i*11 +: 11] = coeff_11b;
            assign Coeff_o[i*12 +: 12] = coeff_12b; 
        end
    endgenerate
endmodule
