
module top (		
    //controll signal
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               gk_ena_i,
    input   logic               ec_ena_i,
    input   logic               dc_ena_i,
    input   logic   [2:0]       k_i,
    input   logic   [31:0]      data_i_0,
    input   logic   [31:0]      data_i_1,
    input   logic   [31:0]      data_i_2,
    input   logic   [31:0]      data_i_3,
    input   logic   [31:0]      data_i_4,
    input   logic   [31:0]      data_i_5,
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
    logic               rst_reg;
    logic               gk_ena_reg;
    logic               ec_ena_reg;
    logic               dc_ena_reg;
    logic   [2:0]       k_reg;
    logic   [191:0]     data_reg;
    logic               valid_reg;
    logic               done_reg;
    always @(posedge clk_i) begin
        rst_reg <= rst_i;
        gk_ena_reg  <= gk_ena_i;
        ec_ena_reg  <= ec_ena_i;
        dc_ena_reg  <= dc_ena_i;
        k_reg   <= k_i;
        data_reg    <= {data_i_0, data_i_1, data_i_2, data_i_3, data_i_4, data_i_5};
        valid_reg   <= valid_i;
        done_reg    <= done_i;
    end

    test module_inst (
        .clk_i(clk_i),
        .rst_i(rst_reg),
        .gk_ena_i(gk_ena_reg),
        .ec_ena_i(ec_ena_reg),
        .dc_ena_i(dc_ena_reg),
        .k_i(k_reg),
        .data_i(data_reg),
        .valid_i(valid_reg),
        .done_i(done_reg),
        .BMUL_valid_o(BMUL_valid_o),
        .BMUL_Coeff_o(BMUL_Coeff_o),
        .MUL_data_o(MUL_data_o),
        .MUL_valid_o(MUL_valid_o),
        .MUL_pre_valid_o(MUL_pre_valid_o),
        .DC_K(DC_K)
    );
endmodule : top
