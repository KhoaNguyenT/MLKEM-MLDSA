module Controller_NTTSampler (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                ena_i,
    input   wire                gk_ena_i,
    input   wire                ec_ena_i,
    input   wire    [2:0]       k_i,
    input   wire    [255:0]     rho_i,
    output  wire    [191:0]     Coeff_o,
    output  wire                valid_o,
    output  wire                done_o
);  
    wire  mode;
    assign mode = gk_ena_i & ~ec_ena_i;
    NTTSampler_wrapper NTTSampler_wrapper_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .rho_i(rho_i),
        .mode_i(mode),
        .k_i(k_i),
        .Coeff_o(Coeff_o),
        .valid_o(valid_o),
        .done_o(done_o)
    );
endmodule
