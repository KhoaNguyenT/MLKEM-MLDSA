module Decompress_1011_real (
    input   wire            iD,       // 10, 11
    input   wire    [10:0]  iCoeff,
    output  wire    [11:0]  oCoeff
);

    // ---- rounding offset 2^(d-1) ----
    wire  [10:0] t1;
    assign t1 = {iD, ~iD , 9'd0};

    // Q = 2^11 + 2^10 + 2^8 + 1
    wire  [22:0] temp_0;
    wire  [22:0] temp_1;
    wire  [22:0] temp_2;
    wire  [22:0] temp_3;
    wire  [22:0] prodQ;
    wire  [22:0] tmp_sum;

    assign temp_0   = {12'b0, iCoeff};
    assign temp_1   = {12'b0, iCoeff} << 8;
    assign temp_2   = {12'b0, iCoeff} << 10;
    assign temp_3   = {12'b0, iCoeff} << 11;
    assign prodQ    = temp_0 + temp_1+ temp_2 + temp_3;
    assign tmp_sum  = prodQ + {12'b0, t1};

    // ---- c?ng offset ----

    wire  temp;
    assign temp = &tmp_sum[9:0];
    // ---- output ----
    assign oCoeff = (iD) ? (tmp_sum[22:11]+ {11'b0, temp}) : tmp_sum[21:10];

endmodule

