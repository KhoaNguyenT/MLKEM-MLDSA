module WrapperMul # (
    parameter DATA_WIDTH = 192
)(
    //controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,

    //  INPUT
    input   wire                        DEC_valid_i,
    input   wire    [DATA_WIDTH-1: 0]   DEC_data_i,

    input   wire                        BGEN_valid_i,
    input   wire    [DATA_WIDTH-1: 0]   BGEN_data_i,
    
    input   wire                        BNTT_valid_i,
    input   wire    [DATA_WIDTH-1: 0]   BNTT_data_i,
    //  OUTPUT
    output  wire                        MUL_valid_o,
    output  wire    [DATA_WIDTH-1: 0]   MUL_data_o
);
    
    wire                        MUL_pre_valid_o;
    wire                        valid_mul_o;
    wire    [DATA_WIDTH-1: 0]   Adata_mul_o;
    wire    [DATA_WIDTH-1: 0]   Bdata_mul_o;

/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/

    Controller_Mul # (
        .DATA_WIDTH(DATA_WIDTH)
    ) Controller_Mul_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .DEC_valid_i(DEC_valid_i),
        .DEC_data_i(DEC_data_i),
        .BGEN_valid_i(BGEN_valid_i),
        .BGEN_data_i(BGEN_data_i),
        .BNTT_valid_i(BNTT_valid_i),
        .BNTT_data_i(BNTT_data_i),
        .valid_mul_o(valid_mul_o),
        .Adata_mul_o(Adata_mul_o),
        .Bdata_mul_o(Bdata_mul_o),
        .pre_valid_mul_i(MUL_pre_valid_o),
        .valid_mul_i(MUL_valid_o)
    );

    MulMatrix MulMatrix_m (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .valid_data(valid_mul_o),
        .k(k_i),
        .a(Adata_mul_o),
        .b(Bdata_mul_o),
        .res(MUL_data_o),
        .valid_output(MUL_valid_o),
        .before_valid_output(MUL_pre_valid_o)
    );
endmodule
