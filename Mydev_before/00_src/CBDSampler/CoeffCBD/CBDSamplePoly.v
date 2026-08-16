module CBDSamplePoly (
    input   wire           ena_i,
    input   wire           eta_i,               // 0: eta=2, 1: eta=3
    input   wire   [95:0]  data_i,        // 96-bit t? Keccak
    output  wire   [191:0] coeff_o,        // 16 h? s? * 12 bit = 192 bit
    output  wire           valid_o
);

    // === 16 nh�m bits ===
    wire [5:0] bits [0:15];

    assign bits[0] = (eta_i) ? data_i[93:88] : {2'd0, data_i[59:56]};
    assign bits[1] = (eta_i) ? {data_i[83:80],data_i[95:94]} : {2'd0, data_i[63:60]};
    assign bits[2] = (eta_i) ? {data_i[73:72],data_i[87:84]} : {2'd0, data_i[51:48]};
    assign bits[3] = (eta_i) ? data_i[79:74] : {2'd0, data_i[55:52]};
    assign bits[4] = (eta_i) ? data_i[69:64] : {2'd0, data_i[43:40]};
    assign bits[5] = (eta_i) ? {data_i[59:56],data_i[71:70]} : {2'd0, data_i[47:44]};
    assign bits[6] = (eta_i) ? {data_i[49:48],data_i[63:60]} : {2'd0, data_i[35:32]};
    assign bits[7] = (eta_i) ? data_i[55:50] : {2'd0, data_i[39:36]};
    assign bits[8] = (eta_i) ? data_i[45:40] : {2'd0, data_i[27:24]};
    assign bits[9] = (eta_i) ? {data_i[35:32],data_i[47:46]} : {2'd0, data_i[31:28]};
    assign bits[10]= (eta_i) ? {data_i[25:24],data_i[39:36]} : {2'd0, data_i[19:16]};
    assign bits[11]= (eta_i) ? data_i[31:26] : {2'd0, data_i[23:20]};
    assign bits[12]= (eta_i) ? data_i[21:16] : {2'd0, data_i[11:8]};
    assign bits[13]= (eta_i) ? {data_i[11:8],data_i[23:22]} : {2'd0, data_i[15:12]};
    assign bits[14]= (eta_i) ? {data_i[1:0],data_i[15:12]} : {2'd0, data_i[3:0]};
    assign bits[15]= (eta_i) ? data_i[7:2]   : {2'd0, data_i[7:4]};

    // === 16 h? s? sau compute (12 bit) ===
    wire [11:0] coeff [0:15];
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : compute_block
            CBDSample CBDSample_m (
                .bits_i(bits[i]),
                .eta_i(eta_i),
                .coeff_o(coeff[i])
            );
        end
    endgenerate

    assign  valid_o     = ena_i;
    assign  coeff_o     = (ena_i) ?{coeff[0],  coeff[1],  coeff[2],  coeff[3],
                                    coeff[4],  coeff[5],  coeff[6],  coeff[7],
                                    coeff[8],  coeff[9],  coeff[10], coeff[11],
                                    coeff[12], coeff[13], coeff[14], coeff[15]}
                                    : 192'b0;
endmodule
