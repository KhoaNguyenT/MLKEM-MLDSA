module NTTSamplePoly (
    input   wire    [47:0]      data_i,
    input   wire                valid_i,
    output  wire    [47:0]      data_o,
    output  wire    [3:0]       valid_o
);

    wire  [3:0] valid_temp;
    assign valid_o[3] = valid_temp[3] & valid_i;
    assign valid_o[2] = valid_temp[2] & valid_i;
    assign valid_o[1] = valid_temp[1] & valid_i;
    assign valid_o[0] = valid_temp[0] & valid_i;
    
    /*****************************************************************************
    *                              Internal Modules                             *
    *****************************************************************************/

    NTTSample NTTSample_0 (
        .C0_i(data_i[47:40]),
        .C1_i(data_i[39:32]),
        .C2_i(data_i[31:24]),
        .d0_o(data_o[47:36]),
        .d1_o(data_o[35:24]),
        .Valid_d0_o(valid_temp[3]),
        .Valid_d1_o(valid_temp[2])
    );
    NTTSample NTTSample_1 (
        .C0_i(data_i[23:16]),
        .C1_i(data_i[15:8]),
        .C2_i(data_i[7:0]),
        .d0_o(data_o[23:12]),
        .d1_o(data_o[11:0]),
        .Valid_d0_o(valid_temp[1]),
        .Valid_d1_o(valid_temp[0])
    );
endmodule
