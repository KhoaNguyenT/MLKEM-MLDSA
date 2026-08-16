module test (	
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               ena_i,

    input   logic   [1:0]       mode_i,// 0 => 512, 1 => 256, 2 => 128
    input   logic               SHA_i, // 0 => SHA, 1 => SHAKE
    input   logic   [255:0]     data_i, 
    input   logic               valid_i,
    input   logic   [7:0]       ldata_i, 
    input   logic               last_i,
    input   logic               lmode_i,
    
    output  logic               next_o,
    output  logic               f_oReady,
    output  logic   [1343:0]    oData,
    output  logic               oReady
);

    KeccakUnit KeccakUnit_inst(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .mode_i(mode_i),
        .SHA_i(SHA_i),
        .data_i(data_i), 
        .valid_i(valid_i),
        .ldata_i(ldata_i), 
        .last_i(last_i),
        .lmode_i(lmode_i),
        .next_o(next_o),
        .f_oReady(f_oReady),
        .oData(oData),
        .oReady(oReady)
    );
endmodule
