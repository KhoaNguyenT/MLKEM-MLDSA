module Encode (
    input   wire    [11:0]  in1,
    input   wire    [11:0]  in2,
    output  wire    [7:0]   out1,
    output  wire    [7:0]   out2,
    output  wire    [7:0]   out3
);
    assign out1 = in1[7:0];
    assign out2 = {in2[3:0], in1[11:8]};
    assign out3 = in2[11:4];
endmodule

