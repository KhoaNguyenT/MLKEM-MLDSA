module NTTSampler_wrapper (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                ena_i,
    input   wire                gk_ena_i,
    input   wire                ec_ena_i,
    input   wire    [2:0]       k_i,
    input   wire    [255:0]     rho_i,
    // output  logic               oBuffer_fulla,
    // output  logic               f_oAck,
    // output  logic               f_oReady,
    // output  logic   [21*64-1:0] data_keccak_o,
    // output  logic               oReady,
    output  wire    [4:0]       runtimes,
    output  wire    [191:0]     Coeff_o,
    output  wire                valid_o,
    output  reg                 done_o
);

    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/
    wire  mode_i;
    assign mode_i = gk_ena_i & ~ec_ena_i;
    wire  [1:0] param_i;
    assign param_i  = (k_i == 2) ? 2'd1
                    : (k_i == 3) ? 2'd2
                    : (k_i == 4) ? 2'd3
                    : 0;
    // to Keccak
    wire  [63:0] iData, data_o;
    wire  [15:0] last_Block_o;
    wire  [21*64-1:0] oData;
    wire  [2:0] lnum_hash_o;
    wire  last_hash_o;
    // NTTSampler to Keccak
    wire  ena_hash_o, next_hash_o, rst_hash_o;
    // NTTSampler to GenInSample
    wire  ena_gen_o, next_gen_o;
    // CoeffNTT to NTTSampler;
    wire  done;
    reg   done_reg;
    
    wire  done_o_gen;
    wire  next_o;
    // IO
    wire    [191:0]     Coeff;
    assign  Coeff_o = (valid_o) ? Coeff : 0;

    wire                oBuffer_fulla;
    wire                f_oAck;
    wire                f_oReady;
    wire    [21*64-1:0] data_keccak_o;
    wire                oReady;
    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/
    wire  oBuffer_full, oBuffer_temp, oBuffer_temp_2;

    assign oBuffer_fulla = oBuffer_full & oBuffer_temp & oBuffer_temp_2;
    assign iData = (last_hash_o) ? {last_Block_o, 48'b0} : data_o;
    assign data_keccak_o = oData;
    // assign done_o = done & done_o_gen;
    
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            done_o  <= 0;
        end
        else begin
            if (done & done_o_gen) begin
                done_o <= 1;
            end
        end
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            done_reg  <= 0;
        end
        else begin
            if (done) begin
                done_reg  <= 1;
            end
            else if (ena_hash_o) begin
                done_reg  <= 0;
            end
        end
    end
    /*****************************************************************************
    *                              Internal Modules                             *
    *****************************************************************************/

    NTTSampler NTTSampler_m (
        .clk_i(clk_i),
        .rst_i(rst_i | done_o),
        .ena_i(ena_i),
        .cnext_hash_i(next_o && !done),
        .rst_hash_i(done),
        .rho_i(rho_i),
        .ena_hash_o(ena_hash_o),
        .next_hash_o(next_hash_o),
        .rst_hash_o(rst_hash_o),
        .data_o(data_o),
        .ena_gen_o(ena_gen_o),
        .next_gen_o(next_gen_o)
    );
    GenInSample GenInSample_m (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_gen_o),
        .next_i(next_gen_o),
        .mode_i(mode_i),
        .param_i(param_i),
        .last_Block_o(last_Block_o),
        .last_hash_o(last_hash_o),
        .lnum_hash_o(lnum_hash_o),
        .runtimes(runtimes),
        .done_o(done_o_gen)
    );
    CoeffNTT CoeffNTT_m (
        .clk_i(clk_i),
        .rst_i(rst_i | done_reg),
        .data_i(oData),
        .valid_i(oReady),
        .data_o(Coeff),
        .valid_o(valid_o),
        .rdone_o(next_o),
        .done_o(done)     // done one ring (256)
    );
    Keccak Keccak_m(
        .iClk(clk_i),
        .iRst(rst_i | rst_hash_o),
        .iMode(2'b10), // 128
        .i_SHA(1'b1),  // SHAKE	
        .iData(iData),
        .iReady(ena_hash_o | last_hash_o),
        .iLast(last_hash_o),
        .iByte_num(lnum_hash_o),
        .iCon_per(next_hash_o),
        .oBuffer_full(oBuffer_full), 	
        .oBuffer_temp(oBuffer_temp),
        .oBuffer_temp_2(oBuffer_temp_2),
        .f_oAck(f_oAck), 		
        .f_oReady(f_oReady),
        .oData(oData),
        .oReady(oReady)
    );
endmodule
