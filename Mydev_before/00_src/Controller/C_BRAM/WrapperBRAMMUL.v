module WrapperBRAMMUL #(
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8,
    parameter DEPTH      = (1 <<ADDR_WIDTH)
)(
    input   wire                        clk_i,
    input   wire                        rst_i,
    input   wire                        ena_i,
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire    [2:0]               k_i,
    input   wire                        valid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,
    
    input   wire                        enr_i,
    input   wire                        enrgk_i,
    input   wire    [3:0]               NTT_runs,

    output  wire                        valid_o,
    output  wire    [DATA_WIDTH-1:0]    data_o
);

/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/
    wire                        enw_bram_o;
    wire    [ADDR_WIDTH-1:0]    addrin_bram_o;
    wire    [DATA_WIDTH-1:0]    data_bram_o;   
    wire    [ADDR_WIDTH-1:0]    addrout_bram_o;

    Controller_BRAM_MUL #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) Controller_BRAM_MUL_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .k_i(k_i),
        .valid_i(valid_i),
        .data_i(data_i),
        .enw_o(enw_bram_o),
        .addrin_o(addrin_bram_o),
        .data_o(data_bram_o),
        .enr_i(enr_i),
        .enrgk_i(enrgk_i),
        .NTT_runs(NTT_runs),
        .valid_o(valid_o),
        .addrout_o(addrout_bram_o)
    );

    BRAM_wr #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH(DEPTH)
    ) BRAM_wr_inst (
        .clk(clk_i),
        .we(enw_bram_o),
        .addr_write(addrin_bram_o),
        .din(data_bram_o),
        .addr_read(addrout_bram_o),
        .dout(data_o)
    );
endmodule
