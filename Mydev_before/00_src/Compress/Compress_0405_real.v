module Compress_0405_real (
    input         iD,       // 0:d=4, 1:d=5
    input  [11:0] iCoeff,
    output [4:0]  oCoeff
);

    localparam [13:0] HALF_Q = 14'd104;  

    // t * a
    wire [12:0] ta = iD ? ({1'b0, iCoeff} << 1) : {1'b0, iCoeff};

    // + HALF_Q
    wire [13:0] sum1 = {1'b0, ta} + HALF_Q;

    // Barrett: div ≈ (sum1 * 20159) >> 26
    // 20159 = 16384 + 4096 - 256 - 64 - 1
    wire [27:0] mul =
          ({14'b0, sum1} << 14)
        + ({14'b0, sum1} << 12)
        - ({14'b0, sum1} << 8)
        - ({14'b0, sum1} << 6)
        -  {14'b0, sum1};

    wire [5:0] div = mul[27:22];

    // % t → lấy bit thấp
    assign oCoeff = iD ? div[4:0] : {1'b0, div[3:0]};

endmodule
