module WrapperBRAMINDC #(
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
    input   wire                        wdone_i,
    input   wire                        wvalid_i,
    input   wire                        rvalid_i,
    input   wire    [DATA_WIDTH-1:0]    data_i,

    input   wire                        next_i,
    output  wire                        valid_o,
    output  wire    [DATA_WIDTH-1:0]    data_o,
    output  wire                        done_o,

    input   wire                        ENC_dc_done_i,
    input   wire                        ENC_valid_i,
    input   wire    [DATA_WIDTH-1:0]    ENC_Coeff_i,
    output  reg                         Cipher_CMP_o
);
    
/*****************************************************************************
*                 Internal Wires and Registers Declarations                  *
*****************************************************************************/

//  Controller to BRAM
    wire                        valid_controller;
    wire                        valid_pack_i;
    wire                        valid_pack_o;
    wire                        ena_bram;
    wire                        wea_bram;
    wire                        done_temp;
    wire    [ADDR_WIDTH-1:0]    addr_bram;
    wire    [ADDR_WIDTH-1:0]    uncut;
    wire    [DATA_WIDTH-1:0]    data_bram;
    wire    [DATA_WIDTH-1:0]    data_pack;
    reg                         ENC_valid_reg;
    reg     [DATA_WIDTH-1:0]    ENC_data_reg;

    assign  valid_pack_i    = ((addr_bram <= uncut) && (addr_bram != 0)) ? valid_controller : 1'b0;
    assign  uncut           =   (k_i == 2)  ?   33
                            :   (k_i == 3)  ?   49
                            :   (k_i == 4)  ?   65
                            :   0;
    assign  valid_o         = (((addr_bram <= uncut) & (addr_bram != 0)) | valid_pack_o | (done_temp & valid_pack_o)) ? valid_pack_o   : valid_controller;
    assign  data_o          = (((addr_bram <= uncut) & (addr_bram != 0)) | valid_pack_o | (done_temp & valid_pack_o)) ? data_pack      : data_bram;
/*****************************************************************************
*                             Sequential wire                                *
*****************************************************************************/

    always @(posedge clk_i) begin
        if (rst_i) begin
            Cipher_CMP_o    <= 0;
            ENC_data_reg    <= 0;
            ENC_valid_reg   <= 0;
        end    
        else begin
            if (ENC_dc_done_i & ENC_valid_i) begin
                ENC_data_reg    <= ENC_Coeff_i;
                ENC_valid_reg   <= ENC_valid_i;
            end
            else begin
                ENC_data_reg    <= 0;
                ENC_valid_reg   <= 0;
            end
            if (ENC_dc_done_i & ENC_valid_reg) begin
                if (data_bram != ENC_data_reg) begin
                    Cipher_CMP_o    <= 1;
                end
                else begin
                    Cipher_CMP_o    <= 0;
                end
            end
        end
    end

/*****************************************************************************
*                             Internal Modules                               *
*****************************************************************************/

    Controller_BRAM_INDC #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) Controller_BRAM_INDC_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_i),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .dc_ena_i(dc_ena_i),
        .k_i(k_i),
        .wdone_i(wdone_i),
        .wvalid_i(wvalid_i),
        .rvalid_i(rvalid_i | ENC_valid_i),
        .ena_o(ena_bram),
        .wea_o(wea_bram),
        .addr_o(addr_bram),
        .next_i(next_i),
        .valid_o(valid_controller),
        .done_temp(done_temp),
        .done_o(done_o),
        .ENC_dc_done_i(ENC_dc_done_i),
        .ENC_valid_i(ENC_valid_i)
    );

    Packwords Packwords_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .data_i(data_bram[191:32]),
        .data_i_valid(valid_pack_i),
        .data_o(data_pack),
        .data_o_valid(valid_pack_o)
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
        .din (data_i),
        .dout(data_bram)
    );
endmodule
