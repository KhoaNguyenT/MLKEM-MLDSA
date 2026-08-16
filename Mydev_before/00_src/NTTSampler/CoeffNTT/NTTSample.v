module NTTSample (
  input  wire  [7:0]        C0_i,
  input  wire  [7:0]        C1_i,
  input  wire  [7:0]        C2_i,
  output wire  [11:0]       d0_o,
  output wire  [11:0]       d1_o,
  output wire               Valid_d0_o,
  output wire               Valid_d1_o
);
    // localparam q = 24'd3329;
    assign d0_o = {C1_i[3:0], C0_i}; // d1 = C[0] + 256 * (C[1] % 16)
    assign d1_o = {C2_i, C1_i[7:4]}; // d2 = (C[1] / 16) + 16 * C[2]

    // assign Valid_d0_o = (d0_o < 3329) ? 1'b1 : 1'b0;
    // assign Valid_d1_o = (d1_o < 3329) ? 1'b1 : 1'b0;


    // always @(*) begin
    //     casez (C1_i[3:0])
    //         4'b1101:begin
    //             if (|C0_i) Valid_d0_o = 0;
    //         end
    //         4'b111?:begin
    //             Valid_d0_o = 0;
    //         end
    //         default: Valid_d0_o = 1;
    //     endcase 
    // end

    // always @(*) begin
    //     casez (C2_i[7:4])
    //         4'b1101:begin
    //             if ((|C2_i[3:0]) | (|C1_i[7:4])) Valid_d1_o = 0;
    //         end
    //         4'b111?:begin
    //             Valid_d1_o = 0;
    //         end
    //         default: Valid_d1_o = 1;
    //     endcase 
    // end
    assign Valid_d0_o =
        ( (C1_i[3:0] == 4'b1101 && |C0_i) ||
        (C1_i[3:1] == 3'b111) ) ? 1'b0 : 1'b1;
    assign Valid_d1_o =
        ( (C2_i[7:4] == 4'b1101 &&
        (|C2_i[3:0] || |C1_i[7:4])) ||
        (C2_i[7:5] == 3'b111) ) ? 1'b0 : 1'b1;
endmodule
