module WrapperKeccak # (
    parameter DATA_WIDTH = 192,
    parameter ADDR_WIDTH = 8
)(
    // Clock signal
    input   wire                        clk_i,
    input   wire                        rst_i,
    // mode
    input   wire                        gk_ena_i,
    input   wire                        ec_ena_i,
    input   wire                        dc_ena_i,
    input   wire    [2:0]               k_i,
    // Seed to BRAM
    input   wire    [DATA_WIDTH-1:0]    din_i,
    input   wire                        valid_i,
    input   wire                        done_i,
    // Next to BRAM
    input   wire    [DATA_WIDTH-1:0]    din_next_i,
    input   wire                        valid_next_i,
    input   wire                        done_next_i,
    // Out Keccak
    output  wire    [1343:0]            oData,
    output  wire                        ready_o,

    // I/O Wrapper
    input   wire                        ena_i,
    output  wire                        rvalid_indc_o,
    output  wire                        rtimes,
    output  wire    [2:0]               status_o,
    output  wire    [DATA_WIDTH-1:0]    dout_bram
);


/*****************************************************************************
*                             Local Parameters                               *
*****************************************************************************/
    localparam FIRST  = 1'b0;
    localparam SECOND = 1'b1;
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/

// CONTROLLER to KECCAK
    wire                        ena;
    wire    [1:0]               mode;
    wire                        SHA;
    wire                        valid;
    wire    [7:0]               ldata;
    wire                        last;
    wire                        lmode;
    wire                        rst_Keccak;

// KECCAK to CONTROLLER
    wire                        next;
    // wire                        ready;
    wire                        f_ready;

// CONTROLLER to BRAM
    // wire                        rtimes;
    wire                        ena_bram;
    wire                        wea_bram;
    wire    [ADDR_WIDTH-1:0]    addr_bram;
    wire    [DATA_WIDTH-1:0]    din_bram;

// BRAM to KECCAK
    wire    [DATA_WIDTH-1:0]    din_keccak_i;
    wire                        valid_keccak_i;
    wire                        done_keccak_i;
    // logic   [DATA_WIDTH-1:0]    dout_bram;
/*****************************************************************************
*                            Combinational Logic                             *
*****************************************************************************/

    // assign din_bram = din_i;
    // assign din_keccak_i = ((rtimes == FIRST) & ((gk_ena_i | ec_ena_i) & ~dc_ena_i))     ?   din_i
    //                     : (rtimes == SECOND | (~gk_ena_i & ~ec_ena_i & dc_ena_i))       ?   din_next_i
    //                     : 0;
    // assign valid_keccak_i = ((rtimes == FIRST) & ((gk_ena_i | ec_ena_i) & ~dc_ena_i))   ?   valid_i
    //                     : (rtimes == SECOND | (~gk_ena_i & ~ec_ena_i & dc_ena_i))       ?   valid_next_i
    //                     : 0;
    // assign done_keccak_i = ((rtimes == FIRST) & ((gk_ena_i | ec_ena_i) & ~dc_ena_i))    ?   done_i
    //                     : (rtimes == SECOND | (~gk_ena_i & ~ec_ena_i & dc_ena_i))       ?   done_next_i
    //                     : 0;
    assign din_keccak_i = (rtimes == FIRST)     ?   din_i
                        : (rtimes == SECOND)    ?   din_next_i
                        : 0;
    assign valid_keccak_i = (rtimes == FIRST)   ?   valid_i
                        : (rtimes == SECOND)    ?   valid_next_i
                        : 0;
    assign done_keccak_i = (rtimes == FIRST)    ?   done_i
                        : (rtimes == SECOND)    ?   done_next_i
                        : 0;
/*****************************************************************************
*                              Internal Modules                              *
*****************************************************************************/

    Controller_Keccak #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_controller_keccak_core (
        .clk_i (clk_i), 
        .rst_i (rst_i), 
        .gk_ena_i (gk_ena_i),
        .ec_ena_i (ec_ena_i),
        .dc_ena_i (dc_ena_i),
        .k (k_i),
        .din_i (din_keccak_i),
        .valid_i (valid_keccak_i),
        .done_i (done_keccak_i),
        .rtimes(rtimes),
        .ena_o_bram (ena_bram), 
        .wea_o_bram (wea_bram),
        .addr_o_bram(addr_bram),
        .din_o_bram (din_bram),
        .next_i (next),
        .ready_i (ready_o & f_ready),
        .ena_o (ena),
        .mode_o (mode),
        .SHA_o (SHA),
        .valid_o (valid),
        .ldata_o (ldata),
        .last_o (last),
        .lmode_o (lmode),
        .rst_o_Keccak (rst_Keccak),
        .ena_i (ena_i),
        .rvalid_indc_o (rvalid_indc_o),
        .status_o (status_o)
    );

    KeccakUnit KeccakUnit_inst(
        .clk_i(clk_i),
        .rst_i(rst_i | rst_Keccak),
        .ena_i(ena),
        .mode_i(mode),
        .SHA_i(~SHA),
        .data_i({dout_bram, 64'b0}), 
        .valid_i(valid),
        .ldata_i(ldata), 
        .last_i(last),
        .lmode_i(lmode),
        .next_o(next),
        .f_oReady(f_ready),
        .oData(oData),
        .oReady(ready_o)
    );

    BRAM_1p # (
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) BRAM_inst (
        .clk (clk_i),
        .ena (ena_bram ),
        .wea (wea_bram ),
        .addr(addr_bram),
        .din (din_bram ),
        .dout(dout_bram)
    );
endmodule
