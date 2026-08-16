module Decode (
    input   wire  [7:0]     in1,
    input   wire  [7:0]     in2,
    input   wire  [7:0]     in3,
    output  wire  [11:0]    out1,
    output  wire  [11:0]    out2
);
    assign out1 = {in2[3:0], in1};
    assign out2 = {in3, in2[7:4]};
endmodule
