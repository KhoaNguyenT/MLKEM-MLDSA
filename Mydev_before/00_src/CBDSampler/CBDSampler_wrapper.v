module CBDSampler_wrapper (
    input   wire                clk_i,
    input   wire                rst_i,
    input   wire                gk_ena_i,
    input   wire                ec_ena_i,
    input   wire    [2:0]       k_i,
    input   wire                ena_i,
    input   wire                NTT_done_compute_i,
    input   wire    [255:0]     sigma_i,
    output  wire    [4:0]       CBD_runs,
    output  wire    [191:0]     Coeff_o,
    output  wire                valid_o,
    output  reg                 done_o
);

    /*****************************************************************************
    *                 Internal Wires and Registers Declarations                 *
    *****************************************************************************/
    // to Keccak
    wire  [63:0] iData, data_o;
    wire  [15:0] last_Block_o;
    wire  [21*64-1:0] oData;
    wire  [2:0] lnum_hash_o;
    wire  last_hash_o;
    wire  Coeff_eta_o;
    // CBDSampler to Keccak
    wire  ena_hash_o, next_hash_o, rst_hash_o;
    // CBDSampler to GenInSample
    wire  ena_gen_o, next_gen_o;
    // CoeffCBD to CBDSampler;
    wire  done;
    wire  done_o_gen;
    wire  next_o;


    reg   done_reg;
    wire  valid_coeff;

    /*****************************************************************************
    *                            Combinational Logic                            *
    *****************************************************************************/
    wire  oBuffer_full, oBuffer_temp, oBuffer_temp_2;
    wire                oBuffer_fulla;
    wire                f_oAck;
    wire                f_oReady;
    wire                oReady;

    assign oBuffer_fulla = oBuffer_full & oBuffer_temp & oBuffer_temp_2 & f_oAck & f_oReady & (&oData) & oReady;
    assign iData = (last_hash_o) ? {last_Block_o, 48'b0} : data_o;
    assign valid_o = valid_coeff & !done_o;
    assign CBD_runs = last_Block_o[12:8];
    // assign done_o = done & done_o_gen;
    /*****************************************************************************
    *                             Sequential Logic                              *
    *****************************************************************************/
    always @(posedge clk_i) begin
        if (rst_i) begin
            done_o  <= 0;
        end
        else begin
            if (done_reg & done_o_gen & ~oBuffer_fulla) begin
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
            else if (oReady) begin
                done_reg  <= 0;
            end
        end
    end

    /*****************************************************************************
    *                              Internal Modules                             *
    *****************************************************************************/

    CBDSampler CBDSampler_m (
        .clk_i(clk_i),
        .rst_i(rst_i | done_o),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .k_i(k_i),
        .runtimes_i(last_Block_o[15:8]),
        .ena_i(ena_i),
        .cnext_hash_i(next_o && !done),
        .rst_hash_i(done),
        .sigma_i(sigma_i),
        .NTT_done_compute_i(NTT_done_compute_i),
        .Coeff_eta_o(Coeff_eta_o),
        .ena_hash_o(ena_hash_o),
        .next_hash_o(next_hash_o),
        .rst_hash_o(rst_hash_o),
        .data_o(data_o),
        .ena_gen_o(ena_gen_o),
        .next_gen_o(next_gen_o)
    );
    GenInSampleCBD GenInSampleCBD_m (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .ena_i(ena_gen_o),
        .next_i(next_gen_o),
        .gk_ena_i(gk_ena_i),
        .ec_ena_i(ec_ena_i),
        .k_i(k_i),
        .last_Block_o(last_Block_o),
        .last_hash_o(last_hash_o),
        .lnum_hash_o(lnum_hash_o),
        .done_o(done_o_gen)
    );
    CoeffCBD CoeffCBD_m (
        .clk_i(clk_i),
        .rst_i(rst_i | done_o),
        .eta_i(Coeff_eta_o),  // 0: eta=2, 1: eta=3
        .data_i(oData[1087:0]),
        .valid_i(oReady),
        .data_o(Coeff_o),
        .valid_o(valid_coeff),
        .next_o(next_o),
        .done_o(done)     // done one ring (256)
    );
    Keccak Keccak_m(
        .iClk(clk_i),
        .iRst(rst_i | rst_hash_o),
        .iMode(2'b01), // 256
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
