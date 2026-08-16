module WrapperEncode (
    //  controll signal
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                gk_ena_i,
    input   wire                ec_ena_i,
    input   wire                dc_ena_i,
    input   wire    [2:0]       k_i,
    input   wire    [3:0]       NTT_runs,
    //  ENCODE I/O 
    //  CMP
    input   wire                uv_valid_i,
    input   wire    [191:0]     uv_data_i,
    //  NTT
    input   wire                s_valid_i,
    input   wire    [191:0]     s_hat_i,
    //  ADD
    input   wire                t_valid_i,
    input   wire    [191:0]     t_hat_i,

    output  wire                s_hat_valid_o,
    output  wire                t_hat_valid_o,
    output  wire                uv_valid_o,
    output  wire    [191:0]     coeff_o,
    output  wire                done_decap_o,
    input   wire                done_encode_i,
    output  wire                done_encode_o
);
/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
// localparam IDLE  = 3'b000;
localparam RUN1  = 3'b001;
localparam RUN2  = 3'b010;
// localparam RUNEC = 3'b011;
// localparam DONE  = 3'b111;
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
wire                valid_encode;
wire                valid_i;
// wire                s_hat_valid_o;
// wire                t_hat_valid_o;
wire    [2:0]       state;
wire    [2:0]       mode;
wire    [191:0]     coeff_i;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/
assign  s_hat_valid_o = valid_i & valid_encode & (state == RUN1);
assign  t_hat_valid_o = valid_i & valid_encode & (state == RUN2);
assign  uv_valid_o    = valid_i & (~gk_ena_i & (ec_ena_i | dc_ena_i));

assign  coeff_i = ((state == RUN1) & (gk_ena_i & ~ec_ena_i & ~dc_ena_i))   ?   s_hat_i
                : ((state == RUN2) & (gk_ena_i & ~ec_ena_i & ~dc_ena_i))   ?   t_hat_i
                : (~gk_ena_i & (ec_ena_i | dc_ena_i)) ? uv_data_i
                : 0;
assign  valid_i = ((state == RUN1) & (gk_ena_i & ~ec_ena_i & ~dc_ena_i))   ?   s_valid_i
                : ((state == RUN2) & (gk_ena_i & ~ec_ena_i & ~dc_ena_i))   ?   t_valid_i
                : (~gk_ena_i & (ec_ena_i | dc_ena_i)) ? uv_valid_i
                : 0;
/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/

    Controller_Encode   Controller_Encode_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .NTT_runs(NTT_runs),
        .mode(mode),
        .state(state),
        .valid_encode(valid_encode),
        .done_decap_o(done_decap_o),
        .done_encode_i(done_encode_i),
        .done_encode_o(done_encode_o)
    );

    EncodePoly EncodePoly_inst (
        .coeff_in(coeff_i),
        .mode(mode),
        .encoded(coeff_o)
    );
endmodule
