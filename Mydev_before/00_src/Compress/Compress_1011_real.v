module Compress_1011_real (
    input         iD,       // 0:d=10, 1:d=11
    input  [11:0] iCoeff,
    output [10:0]  oCoeff
);

    localparam [19:0] HALF_Q = 20'd104;

    // t * a
    wire [18:0] ta = iD ? ({7'b0, iCoeff} << 7) : ({7'b0, iCoeff} << 6);

    // + HALF_Q
    wire [19:0] sum1 = {1'b0, ta} + HALF_Q;

    // Barrett: div ≈ (sum1 * 80636) >> 26
    // 80636 = 2^16 + 2^14 - 2^11 + 2^9 + 2^8 - 2^2
    wire [36:0] mul =
          ({17'b0, sum1} << 17)
        + ({17'b0, sum1} << 15)
        - ({17'b0, sum1} << 12)
        + ({17'b0, sum1} << 10)
        + ({17'b0, sum1} << 9)
        - ({17'b0, sum1} << 3)
        - ({17'b0, sum1});

    wire [11:0] div = mul[36:25];

    // % t → lấy bit thấp
    assign oCoeff = iD ? div[10:0] : {1'b0, div[9:0]};

endmodule
