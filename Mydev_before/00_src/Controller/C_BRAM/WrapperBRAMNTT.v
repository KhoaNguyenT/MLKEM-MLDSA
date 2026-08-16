module WrapperBRAMNTT #(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8,
    parameter DEPTH      = (1 <<ADDR_WIDTH)
)(
    //controll signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    input   wire                        valid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,

    input   wire    [3:0]               NTT_runs,
    input   wire                        next_i,
    input   wire                        NTT_done_compute,
    output  wire                        stop_o,
    output  wire                        add_signal,
    output  wire                        valid_o,
    output  wire    [DATA_WIDTH-1:0]    data_o,
    output  wire                        done_o
);
    
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/

//  Controller to BRAM
    wire                        ena_bram;
    wire                        wea_bram;
    wire    [ADDR_WIDTH-1:0]    addr_bram;
    wire    [DATA_WIDTH-1:0]    data_bram;
/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/

    Controller_BRAM_NTT #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) Controller_BRAM_NTT_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .valid_i(valid_i),
        .data_i(data_i),
        .ena_o(ena_bram),
        .wea_o(wea_bram),
        .addr_o(addr_bram),
        .data_o(data_bram),
        .NTT_runs(NTT_runs),
        .next_i(next_i),
        .NTT_done_compute(NTT_done_compute),
        .stop_o(stop_o),
        .add_signal(add_signal),
        .valid_o(valid_o),
        .done_o(done_o)
    );

    BRAM_1p #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) BRAM_1p_inst (
        .clk (clk_i ),
        .ena (ena_bram),
        .wea (wea_bram),
        .addr(addr_bram),
        .din (data_bram),
        .dout(data_o)
    );
endmodule
