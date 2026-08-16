module WrapperDecompress # (
    parameter DATA_WIDTH = 192
    // parameter ADDR_WIDTH = 8
) (
    //  controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire    [4:0]               CBD_runs,
    
    input   wire                        shift_next_i,
    input   wire                        valid_m_i,
    input   wire    [DATA_WIDTH-1:0]    coeff_m_i,
    output  wire                        valid_o,
    output  wire    [DATA_WIDTH-1:0]    coeff_o
);
    
    wire            ena_m;
    wire            mode;
    wire            valid_m_o;
    wire            valid_DECAP_o;
    wire    [2:0]   runs;
    // wire            valid_m;
    wire    [263:0] coeff_m;
    wire    [DATA_WIDTH-1:0]    coeff_i;
    wire    [DATA_WIDTH-1:0]    coeff_m_o, coeff_u, coeff_v;

    assign  mode    =   (k_i == 4)  ?   1'b1: 1'b0;
    assign  coeff_o =   (ec_ena_i & ~dc_ena_i)  ?   coeff_m_o
                    :   (~ec_ena_i & dc_ena_i)  ?   ((runs != k_i)  ?   coeff_u :   coeff_v)
                    :   'b1;
    assign  valid_o =   (ec_ena_i & ~dc_ena_i)  ?   valid_m_o
                    :   (~ec_ena_i & dc_ena_i & (runs < k_i))  ?   valid_DECAP_o
                    :   valid_m_i;
    assign  coeff_i =   (~ec_ena_i & dc_ena_i & (runs < k_i))  ?   coeff_m[191:0]
                    :   coeff_m_i;
    Controller_Decompress #(
        .DATA_WIDTH(DATA_WIDTH)
        // .ADDR_WIDTH(ADDR_WIDTH)
    ) Controller_Decompress_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .CBD_runs(CBD_runs),
        .valid_m_i(valid_m_i),
        .coeff_m_i(coeff_m_i),
        .ena_m_o(ena_m),
        .coeff_m_o(coeff_m),
        .valid_o(valid_DECAP_o),
        .valid_m_o(valid_m_o),
        .runs(runs)
        // .valid_m_o(valid_m)
    );

    Decompress_m Decompress_m_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_m),
        .shift_next(shift_next_i),
        .data_i(coeff_m),
        .valid_o(valid_m_o),
        .data_o(coeff_m_o)
    );
    
    Decompress_U_poly Decompress_U_poly_inst (
        .id_i(mode),
        // .Coeff_i(coeff_m[191:0]),
        .Coeff_i(coeff_i),
        .Coeff_o(coeff_u)
    );
    Decompress_V_poly Decompress_V_poly_inst (
        .id_i(mode),
        // .Coeff_i(coeff_m[191:0]),
        .Coeff_i(coeff_i),
        .Coeff_o(coeff_v)
    );
endmodule
