// module add (
//     input   logic [191:0] iA_flat, // 16 số x 12 bit = 192 bit
//     input   logic [191:0] iB_flat, // 16 số x 12 bit = 192 bit
//     input   logic         is_SUB, // 16 số x 12 bit = 192 bit
//     output  logic [191:0] oSum_flat // 16 kết quả x 12 bit = 192 bit
// );
//     localparam int NUM_LANES = 16;
//     localparam int WIDTH = 12;
//     genvar i;
//     generate
//         for (i = 0; i < NUM_LANES; i++) begin : gen_mod_adders
//         // Tính toán chỉ số bit cho từng lane
//         // Ví dụ: i=0 => [11:0], i=1 => [23:12], ..., i=15 => [191:180]
//             localparam int LSB = i * WIDTH;
//             localparam int MSB = LSB + WIDTH - 1;
//             add_1 #(
//                 .WIDTH(WIDTH)
//             ) add_1_inst (
//                 .a(iA_flat[MSB:LSB]),
//                 .b(iB_flat[MSB:LSB]),
//                 .result(oSum_flat[MSB:LSB])
//             );
//         end
//     endgenerate
// endmodule

module add (
    input   wire [191:0] iA_flat, // 16 số x 12 bit = 192 bit
    input   wire [191:0] iB_flat, // 16 số x 12 bit = 192 bit
    input   wire         is_SUB, // 16 số x 12 bit = 192 bit
    output  wire [191:0] oSum_flat // 16 kết quả x 12 bit = 192 bit
);
    localparam int NUM_LANES = 16;
    localparam int WIDTH = 12;
    wire [WIDTH:0] offset_temp [0:NUM_LANES-1];
    genvar i;
    generate
        for (i = 0; i < NUM_LANES; i++) begin : gen_offset
            localparam int LSB = i * WIDTH;
            localparam int MSB = LSB + WIDTH - 1;

            // always @(*) begin
            //     if (is_SUB)
            //         offset_temp[i] = ~{1'b0, iB_flat[MSB:LSB]} + 1'b1; // bù 2
            //     else
            //         offset_temp[i] = {1'b0, iB_flat[MSB:LSB]};
            // end
            assign offset_temp[i] = (is_SUB) 
                        ? (~{1'b0, iB_flat[MSB:LSB]} + 1'b1)  // bù 2
                        :  {1'b0, iB_flat[MSB:LSB]};
        end
    endgenerate
    generate
        for (i = 0; i < NUM_LANES; i++) begin : gen_mod_adders
        // Tính toán chỉ số bit cho từng lane
        // Ví dụ: i=0 => [11:0], i=1 => [23:12], ..., i=15 => [191:180]
            localparam int LSB = i * WIDTH;
            localparam int MSB = LSB + WIDTH - 1;
            add_1 #(
                .WIDTH(WIDTH)
            ) add_1_inst (
                .a({1'b0, iA_flat[MSB:LSB]}),
                .b(offset_temp[i]),
                .result(oSum_flat[MSB:LSB])
            );
        end
    endgenerate
endmodule
