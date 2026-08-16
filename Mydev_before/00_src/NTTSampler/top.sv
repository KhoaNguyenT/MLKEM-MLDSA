module top (		
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               ena_i,
    input   logic   [31:0]      rho_i_0,
    input   logic   [31:0]      rho_i_1,
    input   logic   [31:0]      rho_i_2,
    input   logic   [31:0]      rho_i_3,
    input   logic   [31:0]      rho_i_4,
    input   logic   [31:0]      rho_i_5,
    input   logic   [31:0]      rho_i_6,
    input   logic   [31:0]      rho_i_7,
    output  logic               oBuffer_fulla,
    output  logic               f_oAck,
    output  logic               f_oReady,
    output  logic   [21*64-1:0] data_keccak_o,
    output  logic               oReady,
    output  logic   [191:0]     Coeff_o,
    output  logic               valid_o
    output  logic               done_o
);
    logic   rst_i_reg, ena_i_reg;
    logic   [255:0] rho_reg;
    always @(posedge clk_i) begin
        rst_i_reg   <= rst_i;
        ena_i_reg   <= ena_i;
        rho_reg     <= {rho_i_0, rho_i_1, rho_i_2, rho_i_3, rho_i_4, rho_i_5, rho_i_6, rho_i_7};
    end

    test module_inst (
        .clk_i(clk_i),
        .rst_i(rst_i_reg),
        .ena_i(ena_i_reg),
        .rho_i(rho_reg),
        .oBuffer_fulla(oBuffer_fulla),
        .f_oAck(f_oAck),
        .f_oReady(f_oReady),
        .data_keccak_o(data_keccak_o),
        .oReady(oReady),
        .Coeff_o(Coeff_o),
        .valid_o(valid_o),
        .done_o(done_o)
    );
endmodule : top
