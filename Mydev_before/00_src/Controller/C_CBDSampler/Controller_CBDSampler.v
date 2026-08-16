module Controller_CBDSampler (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                ena_i,
    input   wire    [255:0]     sigma_i,
    input   wire                NTT_done_compute_i,
    output  wire    [191:0]     Coeff_o,
    output  wire                valid_o,
    output  wire                done_o
);

    CBDSampler_wrapper CBDSampler_wrapper_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .sigma_i(sigma_i),
        .NTT_done_compute_i(NTT_done_compute_i)
        .Coeff_o(Coeff_o),
        .valid_o(valid_o),
        .done_o(done_o)
    );
    
endmodule