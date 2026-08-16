
module test (
    input        iD,       // 10, 11
    input  [10:0]iCoeff,
    output [11:0]oCoeff
);

Decompress_1011 Decompress_1011_inst (
    .iD(iD),
    .iCoeff(iCoeff),
    .oCoeff(oCoeff)
);
endmodule
