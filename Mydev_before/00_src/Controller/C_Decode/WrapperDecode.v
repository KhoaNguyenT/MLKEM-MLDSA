module WrapperDecode # (
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8
)(
    //  controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        ec_inter_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire    [3:0]               NTT_runs,
    input   wire                        NTT_done_compute,
    input   wire                        NTT_done_one,
    output  wire                        DC_run_check,
    //  DECODE
    input   wire                        wvalid_i,
    input   wire    [DATA_WIDTH-1:0]    coeff_i,
    input   wire                        done_input_i,
    input   wire                        rvalid_i,
    // PACKBITS
    input   wire    [DATA_WIDTH-1:0]    PB_coeff_i,
    input   wire                        PB_valid_i,

    output  wire                        valid_decode,
    output  wire                        valid_rho,
    output  wire    [DATA_WIDTH-1:0]    coeff_o,
    output  wire    [DATA_WIDTH-1:0]    DEC_data_o,

    //  Tracking
    output  wire    [2:0]               state,
    output  wire                        wdone_o
);
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    // wire    [2:0]               state;
    wire    [DATA_WIDTH-1:0]    DEC_Ctrl_i;
    wire    [DATA_WIDTH-1:0]    DEC_coeff_i;
    wire    [2:0]               DEC_mode;
    wire    [DATA_WIDTH-1:0]    DEC_dout;
    // wire                        valid_controller;
// CONTROLLER to BRAM
    wire                        ena_bram;
    wire                        wea_bram;
    wire    [ADDR_WIDTH-1:0]    addr_bram;
    wire    [ADDR_WIDTH-1:0]    uncnt_rho_0;
    wire    [ADDR_WIDTH-1:0]    uncnt_rho_1;
    // wire    [DATA_WIDTH-1:0]    din_bram;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/

    assign  uncnt_rho_0 =   (k_i == 3'd2)   ?   8'd112
                        :   (k_i == 3'd3)   ?   8'd160
                        :   (k_i == 3'd4)   ?   8'd208
                        :   0;
    assign  uncnt_rho_1 =   (k_i == 3'd2)   ?   8'd113
                        :   (k_i == 3'd3)   ?   8'd161
                        :   (k_i == 3'd4)   ?   8'd209
                        :   0;
    assign  DEC_data_o  =   ((addr_bram == uncnt_rho_0) | (addr_bram == uncnt_rho_1))   ?   DEC_Ctrl_i
                        :   DEC_dout;
    assign  valid_rho   =   ((addr_bram == uncnt_rho_0) | (addr_bram == uncnt_rho_1));

    assign  DEC_coeff_i =   (PB_valid_i)    ?   PB_coeff_i  :   DEC_Ctrl_i;
/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/

    Controller_Decode #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )   Controller_Decode_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .ec_inter_i(ec_inter_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .NTT_runs(NTT_runs),
        .NTT_done_compute(NTT_done_compute),
        .NTT_done_one(NTT_done_one),
        .DC_run_check(DC_run_check),
        .wvalid_i(wvalid_i),
        .din_i_bram(coeff_i),
        .done_input_i(done_input_i),
        .rvalid_i(rvalid_i),
        .ena_o_bram(ena_bram),
        .wea_o_bram(wea_bram),
        .addr_o_bram(addr_bram),
        .din_o_bram(DEC_Ctrl_i),
        .DEC_mode(DEC_mode),
        .state(state),
        .valid_decode(valid_decode),
        .wdone_o(wdone_o)
    );

    DecodePoly DecodePoly_inst (
        .encoded(DEC_coeff_i),
        .mode(DEC_mode),
        .coeff_out(DEC_dout)
    );
    

    BRAM_1p # (
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) BRAM_inst (
        .clk (clk_i),
        .ena (ena_bram ),
        .wea (wea_bram ),
        .addr(addr_bram),
        .din (DEC_data_o),
        .dout(coeff_o)
    );
endmodule
