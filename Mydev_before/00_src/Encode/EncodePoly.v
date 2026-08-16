// module EncodePoly (
//     input   wire    [191:0] coeff_in,
//     input   wire    [2:0]   mode,
//     output  wire    [191:0] encoded
// );
// // wire [191:0] temp_encoded;
// // assign encoded = (enable) ? temp_encoded : coeff_in;
//     Encode encode_inst0 (
//         .in1(coeff_in[191:180]),
//         .in2(coeff_in[179:168]),
//         .out1(encoded[191:184]),
//         .out2(encoded[183:176]),
//         .out3(encoded[175:168])
//     );
//     Encode encode_inst1 (
//         .in1(coeff_in[167:156]),
//         .in2(coeff_in[155:144]),
//         .out1(encoded[167:160]),
//         .out2(encoded[159:152]),
//         .out3(encoded[151:144])
//     );
//     Encode encode_inst2 (
//         .in1(coeff_in[143:132]),
//         .in2(coeff_in[131:120]),
//         .out1(encoded[143:136]),
//         .out2(encoded[135:128]),
//         .out3(encoded[127:120])
//     );
//     Encode encode_inst3 (
//         .in1(coeff_in[119:108]),
//         .in2(coeff_in[107:96]),
//         .out1(encoded[119:112]),
//         .out2(encoded[111:104]),
//         .out3(encoded[103:96])
//     );
//     Encode encode_inst4 (
//         .in1(coeff_in[95:84]),
//         .in2(coeff_in[83:72]),
//         .out1(encoded[95:88]),
//         .out2(encoded[87:80]),
//         .out3(encoded[79:72])
//     );
//     Encode encode_inst5 (
//         .in1(coeff_in[71:60]),
//         .in2(coeff_in[59:48]),
//         .out1(encoded[71:64]),
//         .out2(encoded[63:56]),
//         .out3(encoded[55:48])
//     );
//     Encode encode_inst6 (
//         .in1(coeff_in[47:36]),
//         .in2(coeff_in[35:24]),
//         .out1(encoded[47:40]),
//         .out2(encoded[39:32]),
//         .out3(encoded[31:24])
//     );
//     Encode encode_inst7 (
//         .in1(coeff_in[23:12]),
//         .in2(coeff_in[11:0]),
//         .out1(encoded[23:16]),
//         .out2(encoded[15:8]),
//         .out3(encoded[7:0])
//     );
// endmodule

module EncodePoly (
    input  wire  [191:0] coeff_in,
    input  wire  [2:0]   mode,
    output wire  [191:0] encoded
);

    wire  [191:0] enc12, enc11, enc10, enc5, enc4;
    wire  [191:0] enc_sel;   // kết quả sau mode
    wire  [191:0] enc_rev8;  // sau reverse 8-bit

    genvar i;

    // ================== MODE 0 : 16 × 12 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : GEN12
            localparam int MSB = 191 - (15-i)*12;
            ReverseBits #(.WIDTH(12)) r12 (
                .in (coeff_in[MSB -: 12]),
                .out(enc12   [MSB -: 12])
            );
        end
    endgenerate

    // ================== MODE 1 : 16 × 11 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : GEN11
            localparam int MSB = 191 - (15-i)*11;
            ReverseBits #(.WIDTH(11)) r11 (
                .in (coeff_in[MSB -: 11]),
                .out(enc11   [MSB -: 11])
            );
        end
    endgenerate
    assign enc11[191-16*11:0] = coeff_in[191-16*11:0];

    // ================== MODE 2 : 16 × 10 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : GEN10
            localparam int MSB = 191 - (15-i)*10;
            ReverseBits #(.WIDTH(10)) r10 (
                .in (coeff_in[MSB -: 10]),
                .out(enc10   [MSB -: 10])
            );
        end
    endgenerate
    assign enc10[191-16*10:0] = coeff_in[191-16*10:0];

    // ================== MODE 3 : 16 × 5 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : GEN5
            localparam int MSB = 191 - (15-i)*5;
            ReverseBits #(.WIDTH(5)) r5 (
                .in (coeff_in[MSB -: 5]),
                .out(enc5    [MSB -: 5])
            );
        end
    endgenerate
    assign enc5[191-16*5:0] = coeff_in[191-16*5:0];

    // ================== MODE 4 : 16 × 4 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : GEN4
            localparam int MSB = 191 - (15-i)*4;
            ReverseBits #(.WIDTH(4)) r4 (
                .in (coeff_in[MSB -: 4]),
                .out(enc4    [MSB -: 4])
            );
        end
    endgenerate
    assign enc4[191-16*4:0] = coeff_in[191-16*4:0];

    // ================== SELECT MODE ==================
    // always_comb begin
    //     case (mode)
    //         3'd0: enc_sel = enc12;
    //         3'd1: enc_sel = enc11;
    //         3'd2: enc_sel = enc10;
    //         3'd3: enc_sel = enc5;
    //         3'd4: enc_sel = enc4;
    //         3'd5: enc_sel = coeff_in;
    //         default: enc_sel = coeff_in;
    //     endcase
    // end
    assign enc_sel =
        (mode == 3'd0) ? enc12   :
        (mode == 3'd1) ? enc11   :
        (mode == 3'd2) ? enc10   :
        (mode == 3'd3) ? enc5    :
        (mode == 3'd4) ? enc4    :
                        coeff_in;
    // ================== REVERSE 8 BIT OUTPUT ==================
    generate
        for (i = 0; i < 24; i++) begin : GEN_REV8
            ReverseBits #(.WIDTH(8)) u_rev8 (
                .in (enc_sel [8*i +: 8]),
                .out(enc_rev8[8*i +: 8])
            );
        end
    endgenerate

    assign encoded = enc_rev8;

endmodule
