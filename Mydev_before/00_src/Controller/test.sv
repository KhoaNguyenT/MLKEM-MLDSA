module test (
    //controll signal
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               gk_ena_i,
    input   logic               ec_ena_i,
    input   logic               dc_ena_i,
    input   logic   [2:0]       k_i,
    input   logic   [191:0]     data_i,
    input   logic               valid_i,
    input   logic               done_i,

    // TEMP
    output  logic               BMUL_valid_o,
    output  logic   [191:0]     BMUL_Coeff_o,
    //debug
    output  logic   [191:0]     MUL_data_o,
    output  logic               MUL_valid_o,
    output  logic               MUL_pre_valid_o,
    output  logic   [255:0]     DC_K
);
    Controller_KG_EC Controller_KG_EC_inst(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .data_i(data_i),
        .valid_i(valid_i),
        .done_i(done_i),
        .BMUL_valid_o(BMUL_valid_o),
        .BMUL_Coeff_o(BMUL_Coeff_o),
        .MUL_data_o(MUL_data_o),
        .MUL_valid_o(MUL_valid_o),
        .MUL_pre_valid_o(MUL_pre_valid_o),
        .DC_K(DC_K)
    );
endmodule
