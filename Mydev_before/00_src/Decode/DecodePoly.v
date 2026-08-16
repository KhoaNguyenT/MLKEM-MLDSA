// module DecodePoly #(
//     parameter   WIDTH = 192,
//     parameter   NUM_INST = 192/24
// ) (
//     input  logic [WIDTH-1:0]    coeff_in,
//     output logic [WIDTH-1:0]    decoded
// );

//     genvar i;
//     generate
//         for (i = 0; i < NUM_INST; i ++) begin
//             //
//             localparam HIGH_BIT = 192 - (i*24) - 1;
//             // localparam LOW_BIT  = 192 - ((i+1)*24);
//             //
//             localparam IN1_H  = HIGH_BIT;   // 191
//             localparam IN1_L  = IN1_H - 8 + 1;
//             localparam IN2_H  = IN1_L - 1;
//             localparam IN2_L  = IN2_H - 8 + 1;
//             localparam IN3_H  = IN2_L - 1;
//             localparam IN3_L  = IN3_H - 8 + 1;
//             //
//             localparam OUT1_H = HIGH_BIT;   // 191
//             localparam OUT1_L = OUT1_H - 12 + 1;
//             localparam OUT2_H = OUT1_L - 1;
//             localparam OUT2_L = OUT2_H - 12 + 1;

//             Decode Decode_m (
//                 .in1(coeff_in[IN1_H:IN1_L]),
//                 .in2(coeff_in[IN2_H:IN2_L]),
//                 .in3(coeff_in[IN3_H:IN3_L]),
//                 .out1(decoded[OUT1_H:OUT1_L]),
//                 .out2(decoded[OUT2_H:OUT2_L])
//             );
//         end
//     endgenerate
    
// endmodule

module DecodePoly (
    input  wire  [191:0] encoded,
    input  wire  [2:0]   mode,
    output wire  [191:0] coeff_out
);

    wire  [191:0] dec_rev8;
    wire  [191:0] dec12, dec11, dec10, dec5, dec4;
    wire  [191:0] dec_sel;

    genvar i;

    // ================== UNREVERSE 8 BIT ==================
    generate
        for (i = 0; i < 24; i++) begin : GEN_UNREV8
            ReverseBits #(.WIDTH(8)) u_unrev8 (
                .in (encoded [8*i +: 8]),
                .out(dec_rev8[8*i +: 8])
            );
        end
    endgenerate

    // ================== MODE 0 : 16 × 12 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : DEC12
            localparam int MSB = 191 - (15-i)*12;
            ReverseBits #(.WIDTH(12)) r12 (
                .in (dec_rev8[MSB -: 12]),
                .out(dec12   [MSB -: 12])
            );
        end
    endgenerate

    // ================== MODE 1 : 16 × 11 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : DEC11
            localparam int MSB = 191 - (15-i)*11;
            ReverseBits #(.WIDTH(11)) r11 (
                .in (dec_rev8[MSB -: 11]),
                .out(dec11   [MSB -: 11])
            );
        end
    endgenerate
    assign dec11[191-16*11:0] = 0;

    // ================== MODE 2 : 16 × 10 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : DEC10
            localparam int MSB = 191 - (15-i)*10;
            ReverseBits #(.WIDTH(10)) r10 (
                .in (dec_rev8[MSB -: 10]),
                .out(dec10   [MSB -: 10])
            );
        end
    endgenerate
    assign dec10[191-16*10:0] = 0;

    // ================== MODE 3 : 16 × 5 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : DEC5
            localparam int MSB = 191 - (15-i)*5;
            ReverseBits #(.WIDTH(5)) r5 (
                .in (dec_rev8[MSB -: 5]),
                .out(dec5    [MSB -: 5])
            );
        end
    endgenerate
    assign dec5[191-16*5:0] = dec_rev8[191-16*5:0];

    // ================== MODE 4 : 16 × 4 bit ==================
    generate
        for (i = 15; i >= 0; i--) begin : DEC4
            localparam int MSB = 191 - (15-i)*4;
            ReverseBits #(.WIDTH(4)) r4 (
                .in (dec_rev8[MSB -: 4]),
                .out(dec4    [MSB -: 4])
            );
        end
    endgenerate
    assign dec4[191-16*4:0] = 0;

    // ================== SELECT MODE ==================
    // always_comb begin
    //     case (mode)
    //         3'd0: dec_sel = dec12;
    //         3'd1: dec_sel = dec11;
    //         3'd2: dec_sel = dec10;
    //         3'd3: dec_sel = dec5;
    //         3'd4: dec_sel = dec4;
    //         default: dec_sel = dec_rev8;
    //     endcase
    // end
    // always_comb begin
    //     for (int k = 0; k < 16; k++) begin
    //         case (mode)
    //             3'd0: dec_sel[191 - k*12 -: 12] = dec12[191 - k*12 -: 12];          // 12 bit
    //             3'd1: dec_sel[191 - k*12 -: 12] = {1'b0,  dec11[191 - k*11 -: 11]}; // 11 bit
    //             3'd2: dec_sel[191 - k*12 -: 12] = {2'b0,  dec10[191 - k*10 -: 10]}; // 10 bit
    //             3'd3: dec_sel[191 - k*12 -: 12] = {7'b0,  dec5[191 - k*5  -: 5 ]};  // 5 bit
    //             3'd4: dec_sel[191 - k*12 -: 12] = {8'b0,  dec4[191 - k*4  -: 4 ]};  // 4 bit
    //             default: dec_sel[191 - k*12 -: 12] = 12'b0;
    //         endcase
    //     end
    // end
    
    genvar k;
    generate
        for (k = 0; k < 16; k = k + 1) begin : GEN_DEC_SEL

            wire [11:0] sel_word;

            assign sel_word =
                (mode == 3'd0) ?  dec12[191 - k*12 -: 12] :
                (mode == 3'd1) ? {1'b0, dec11[191 - k*11 -: 11]} :
                (mode == 3'd2) ? {2'b0, dec10[191 - k*10 -: 10]} :
                (mode == 3'd3) ? {7'b0, dec5 [191 - k*5  -: 5 ]} :
                (mode == 3'd4) ? {8'b0, dec4 [191 - k*4  -: 4 ]} :
                                12'b0;

            assign dec_sel[191 - k*12 -: 12] = sel_word;

        end
    endgenerate


    assign coeff_out = dec_sel;

endmodule
