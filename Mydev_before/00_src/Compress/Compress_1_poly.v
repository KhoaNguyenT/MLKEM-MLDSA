module Compress_1_poly (
    input  wire  [191:0] CMP_data_i,   // 16 × 12-bit
    output wire  [191:0]  CMP_data_o    // 16 × 1-bit
);
    wire    [15:0]   temp;
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_COMPRESS_REAL
            Compress_1_real u_compress_1_real (
                .iCoeff ( CMP_data_i[i*12 +: 12] ),
                .oCoeff ( temp[i] )
            );
        end
    endgenerate
    assign CMP_data_o = {temp, 176'b0};
endmodule
