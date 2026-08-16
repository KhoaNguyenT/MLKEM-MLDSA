// module Compress_1_real (
//     input  [11:0] iCoeff,
//     output        oCoeff
// );
//     localparam POLY_Q_low = 12'd832;
//     localparam POLY_Q_high = 12'd2497;
//     assign oCoeff = ((iCoeff > POLY_Q_low) & (iCoeff < POLY_Q_high));
// endmodule

module Compress_1_real (
    input  wire  [11:0] iCoeff,
    output wire         oCoeff
);
    // Kyber Q = 3329
    localparam POLY_Q_LOW  = 13'd833;   // Q/4
    localparam POLY_Q_HIGH = 13'd2496;  // 3Q/4

    wire  [12:0] sub_low;
    wire  [12:0] sub_high;

    // iCoeff > 832  <=> iCoeff - 833 >= 0
    assign sub_low  = {1'b0, iCoeff} - POLY_Q_LOW;

    // iCoeff < 2497 <=> 2496 - iCoeff >= 0
    assign sub_high = POLY_Q_HIGH - {1'b0, iCoeff};

    // MSB = borrow flag
    assign oCoeff = ~sub_low[12] & ~sub_high[12];

endmodule
