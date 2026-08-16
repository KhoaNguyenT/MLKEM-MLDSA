module test (	
    input   logic               clk_i,
    input   logic               rst_i,
    input   logic               ena_i,
    input   logic   [255:0]     rho_i,
    output  logic   [191:0]     Coeff_o,
    output  logic               valid_o,
    output  logic               done_o
);
 NTTSampler_wrapper module_inst (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .ena_i(ena_i),
    .rho_i(rho_i),
    .Coeff_o(Coeff_o),
    .valid_o(valid_o),
    .done_o(done_o)
 );
endmodule
