module CoeffCBD (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                eta_i,
    input   wire    [1087:0]    data_i,
    input   wire                valid_i,
    
    output  wire    [191:0]     data_o,
    output  wire                valid_o,
    output  wire                next_o,
    output  wire                done_o
);
    
    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/
    wire            done_in;
    wire            valid_poly;
    wire            done_ring_o;
    wire            rst_ring;
    // wire            valid_i_reg;
    // CBDSampleIn to CBDSamplePoly
    wire    [95:0]  data;
    wire            valid;


    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/
    assign  valid_o     =   valid_poly & !done_ring_o;
    assign  next_o      =   done_in & !done_ring_o;
    assign  done_o      =   done_ring_o;
    assign  rst_ring    =   rst_i | done_ring_o;
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/
    /*****************************************************************************
    *                              Internal Modules                             *
    *****************************************************************************/

    CBDSampleIn CBDSampleIn_m (
        .clk_i(clk_i),
        .rst_i(rst_ring),
        .eta_i(eta_i),
        .data_i(data_i),
        .valid_i(valid_i),
        .data_o(data),
        .valid_o(valid),
        .done_o(done_in)
    );

    CBDSamplePoly CBDSamplePoly_m (
        .ena_i(valid),
        .eta_i(eta_i),
        .data_i(data),
        .coeff_o(data_o),
        .valid_o(valid_poly)
    );

    CBDSampleOut CBDSampleOut_m (
        .clk_i(clk_i),
        .rst_i(rst_ring),
        .valid_i(valid_poly),
        .done_ring_o(done_ring_o)
    );

endmodule
