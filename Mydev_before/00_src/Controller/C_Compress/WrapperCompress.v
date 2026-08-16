module WrapperCompress #(
    parameter integer NUM_INST = 16
)(
    //controll signal
    input   wire                    clk_i,
    input   wire                    rst_i,
    input   wire                    gk_ena_i,
    input   wire                    ec_ena_i,
    input   wire                    dc_ena_i,
    input   wire    [2:0]           k_i,

    input   wire                    CMP_valid_i,
    input   wire  [NUM_INST*12-1:0] CMP_data_i,
    output  wire                    CMP_valid_o,
    output  wire  [NUM_INST*12-1:0] CMP_data_o,
    output  wire                    done_o
);

    localparam COMPRESS_U   = 3'b001;
    localparam WAIT         = 3'b010;
    localparam COMPRESS_V   = 3'b011;
    
    wire  [NUM_INST*12-1:0] CMP_data_1011;
    wire  [NUM_INST*12-1:0] CMP_data_0405;
    wire  [NUM_INST*12-1:0] CMP_data_1;
    wire  [2:0]             state;
    wire                    id_i_1011;
    wire                    id_i_0405;

    assign CMP_data_o   =   ((ec_ena_i & ~dc_ena_i) & (state == COMPRESS_U)) ? CMP_data_1011
                        :   ((ec_ena_i & ~dc_ena_i) & (state == COMPRESS_V)) ? CMP_data_0405
                        :   (~ec_ena_i & dc_ena_i) ? CMP_data_1
                        :   0;
    assign CMP_valid_o = (state != WAIT) ? CMP_valid_i : 1'b0;

    Controller_CMP Controller_CMP_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .k_i(k_i),
        .valid_i(CMP_valid_i),
        .id_i_1011(id_i_1011),
        .id_i_0405(id_i_0405),
        .state(state),
        .done_o(done_o)
    );
    
    Compress_U_poly # (
        .NUM_INST(NUM_INST)
    ) Compress_U_poly (
        .id_i(id_i_1011),
        .CMP_data_i(CMP_data_i),
        .CMP_data_o(CMP_data_1011)
    );
    Compress_V_poly # (
        .NUM_INST(NUM_INST)
    ) Compress_V_poly (
        .id_i(id_i_0405),
        .CMP_data_i(CMP_data_i),
        .CMP_data_o(CMP_data_0405)
    );

    Compress_1_poly Compress_1_poly_inst (
        .CMP_data_i(CMP_data_i),
        .CMP_data_o(CMP_data_1)
    );

endmodule
