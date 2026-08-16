
// module test (
//     input   logic           id_i,
//     input   logic   [11:0]  CMP_data_i,
//     output  logic   [10:0]  CMP_data_o
// ); 

//     Compress_1011_real Compress_1011_real_inst (
//         .iD(id_i),
//         .iCoeff(CMP_data_i),
//         .oCoeff(CMP_data_o)
//     );
// endmodule

module test (
    input   logic   [11:0]  CMP_data_i,
    output  logic           CMP_data_o
); 

    Compress_1_real Compress_1_real_inst (
        .iCoeff(CMP_data_i),
        .oCoeff(CMP_data_o)
    );
endmodule
